SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: API.isp_ECOMP_PrePrintCheck_Wrapper                     */
/* Creation Date: 06-MAR-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by: Sean                                                     */
/* Purpose: FCR-10057 - UA PACKLIST Pre-Print Check                     */  
/*                                                                      */  
/* Called By:                                                           */  
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 06-MAR-2026 Sean     1.0   Initial                                   */
/************************************************************************/
CREATE OR ALTER PROC [API].[isp_ECOMP_PrePrintCheck_Wrapper]
           @c_PickSlipNo      NVARCHAR(10)
         , @c_ReportType      NVARCHAR(30)
         , @c_StorerKey       NVARCHAR(15)
         , @c_Facility        NVARCHAR(5)
         , @b_Success         INT            OUTPUT
         , @n_Err             INT            OUTPUT
         , @c_ErrMsg          NVARCHAR(255)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt       INT
         , @n_Continue        INT

         , @c_SPCode          NVARCHAR(100)  
         , @c_ReportTypes     NVARCHAR(200)  

         , @c_SQL             NVARCHAR(4000)
         , @c_SQLArgument     NVARCHAR(4000)

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue  = 1
   SET @n_Err       = 0
   SET @c_ErrMsg    = ''
   SET @c_SPCode    = ''
   SET @c_ReportTypes = ''

   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

   SET @b_Success = 1
   EXEC nspGetRight
         @c_Facility  = @c_Facility
      ,  @c_StorerKey = @c_StorerKey
      ,  @c_sku       = NULL
      ,  @c_ConfigKey = 'EPACKPrePrintValidate_SP'
      ,  @b_Success   = @b_Success    OUTPUT
      ,  @c_authority = @c_SPCode     OUTPUT
      ,  @n_err       = @n_Err        OUTPUT
      ,  @c_errmsg    = @c_ErrMsg     OUTPUT
      ,  @c_Option1   = @c_ReportTypes OUTPUT

   IF @b_Success <> 1
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 62010
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                      + ': Error executing nspGetRight - EPACKPrePrintValidate_SP.'
                      + ' (isp_ECOMP_PrePrintCheck_Wrapper)'
      GOTO QUIT_SP
   END

   IF ISNULL(RTRIM(@c_SPCode), '') = ''
   BEGIN
      GOTO QUIT_SP
   END

   IF NOT EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_SPCode) AND type = 'P')
   BEGIN
      GOTO QUIT_SP
   END

   IF ISNULL(RTRIM(@c_ReportTypes), '') <> ''
   BEGIN
      IF NOT EXISTS (
         SELECT 1
         FROM dbo.fnc_DelimSplit(',', @c_ReportTypes)
         WHERE ColValue = @c_ReportType
      )
      BEGIN
         GOTO QUIT_SP
      END
   END

   SET @c_SQL = 'EXEC [API].[' + RTRIM(@c_SPCode) + '] '
              + '  @c_PickSlipNo = @c_PickSlipNo'
              + ', @c_ReportType = @c_ReportType'
              + ', @b_Success    = @b_Success  OUTPUT'
              + ', @n_Err        = @n_Err      OUTPUT'
              + ', @c_ErrMsg     = @c_ErrMsg   OUTPUT'

   SET @c_SQLArgument = N'  @c_PickSlipNo  NVARCHAR(10)'
                      + ', @c_ReportType  NVARCHAR(30)'
                      + ', @b_Success     INT           OUTPUT'
                      + ', @n_Err         INT           OUTPUT'
                      + ', @c_ErrMsg      NVARCHAR(255) OUTPUT'

   EXEC sp_ExecuteSql @c_SQL
                    , @c_SQLArgument
                    , @c_PickSlipNo
                    , @c_ReportType
                    , @b_Success  OUTPUT
                    , @n_Err      OUTPUT
                    , @c_ErrMsg   OUTPUT

   -- Step 6: Handle return value from customized SP
   --         0 = Error, 1 = Print, 2 = Not To Print
   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3
      IF ISNULL(@c_ErrMsg, '') = ''
      BEGIN
         SET @n_Err    = 62020
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                       + ': Error executing ' + RTRIM(@c_SPCode) + '.'
                       + ' (isp_ECOMP_PrePrintCheck_Wrapper)'
      END
      GOTO QUIT_SP
   END

   -- @b_Success = 1 (Print) or 2 (Not To Print) → pass through to caller
   SET @n_Continue = @b_Success

QUIT_SP:
   IF @n_Continue = 3  -- Error occurred
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_ECOMP_PrePrintCheck_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = @n_Continue  -- 1 = Print, 2 = Not To Print
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END -- procedure
GO
GRANT EXECUTE ON [API].[isp_ECOMP_PrePrintCheck_Wrapper] TO nSQL
GO