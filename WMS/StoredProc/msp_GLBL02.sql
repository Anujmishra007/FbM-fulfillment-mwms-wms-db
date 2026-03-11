SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: msp_GLBL02                                          */
/* Creation Date: 11-Mar-2026                                            */
/* Copyright: Maersk Logistics                                           */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-11521/UWP-50475 - UK Columbia SportWear GenLabelNo_SP    */
/*                                                                       */
/* Called By: isp_GenLabelNo_Wrapper                                     */
/*                                                                       */
/* Version: 1.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 11-Mar-2026 WLChooi  1.0   Initial Version                            */
/*************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_GLBL02] (
         @c_PickSlipNo   NVARCHAR(10)
      ,  @n_CartonNo     INT
      ,  @c_LabelNo      NVARCHAR(20)   OUTPUT 
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt          INT
         , @n_Continue           INT
         , @b_Success            INT
         , @n_Err                INT
         , @c_ErrMsg             NVARCHAR(255)

   DECLARE @c_Storerkey          NVARCHAR(15)   = ''
         , @c_CompanyPrefix      NVARCHAR(40)   = ''
         , @n_LBLNoLength        INT            = 0

   DECLARE @c_Identifier         NVARCHAR(2)    = ''
         , @c_Extension          NVARCHAR(1)    = ''
         , @c_nCounter           NVARCHAR(25)   = ''
         , @c_Keyname            NVARCHAR(30)   = ''
         , @n_CheckDigit         INT = 0
         , @n_TotalOddCnt        INT = 0
         , @n_TotalEvenCnt       INT = 0
         , @n_Add                INT = 0
         , @n_Remain             INT = 0
         , @n_CharIndex          INT = 0

   SET @n_StartTCnt        = @@TRANCOUNT
   SET @n_Continue         = 1
   SET @b_Success          = 0
   SET @n_Err              = 0
   SET @c_ErrMsg           = ''
   SET @c_Storerkey= ''

   SELECT @c_Storerkey = P.Storerkey
   FROM dbo.PACKHEADER P WITH (NOLOCK)
   WHERE P.PickSlipNo = @c_PickSlipNo

   IF @c_Storerkey = '' 
   BEGIN
      SET @c_LabelNo = 'ERROR-1001'
      GOTO QUIT_SP
   END

   SELECT @c_CompanyPrefix = ISNULL(SUSR5,'')
   FROM dbo.STORER WITH (NOLOCK) 
   WHERE StorerKey = @c_Storerkey
   
   IF ISNULL(@c_CompanyPrefix, '') = ''
      SET @c_CompanyPrefix = '0195982'

   SET @c_Identifier = '00'
   SET @c_Extension = '0'
   SET @c_LabelNo = ''
   SET @c_Keyname = 'CSCGS1Label'
   SET @n_LBLNoLength = 9

   EXECUTE nspg_GetKey @c_Keyname
                     , @n_LBLNoLength
                     , @c_nCounter OUTPUT
                     , @b_success   = @b_success OUTPUT
                     , @n_err       = @n_err OUTPUT
                     , @c_errmsg    = @c_errmsg OUTPUT
                     , @b_resultset = 0
                     , @n_batch     = 1

   -- GS1 Label Number
   SET @c_LabelNo = @c_Identifier + @c_Extension + TRIM(@c_CompanyPrefix) + TRIM(@c_nCounter)

   IF ISNUMERIC(@c_LabelNo) <> 1
   BEGIN
      SET @c_LabelNo = 'ERROR-1002'
      GOTO QUIT_SP          
   END

   SET @n_Add = 0
   SET @n_Remain = 0
   SET @n_CheckDigit = 0

   WHILE @n_CharIndex <= LEN(RTRIM(@c_LabelNo))
   BEGIN
      IF @n_CharIndex % 2 = 1 -- Odd positions: multiply by 3
         SET @n_TotalOddCnt = @n_TotalOddCnt + (CAST(SUBSTRING(@c_LabelNo, @n_CharIndex, 1) AS INT) * 3) 
      ELSE 
         SET @n_TotalEvenCnt = @n_TotalEvenCnt + (CAST(SUBSTRING(@c_LabelNo, @n_CharIndex, 1) AS INT) * 1) 

      SET @n_CharIndex = @n_CharIndex + 1
   END -- End While
   
   SET @n_Add = @n_TotalOddCnt + @n_TotalEvenCnt
   SET @n_Remain = @n_Add % 10
   SET @n_CheckDigit = 10 - @n_Remain

   IF @n_CheckDigit = 10
      SET @n_CheckDigit = 0

   SET @c_LabelNo = ISNULL(TRIM(@c_LabelNo), '') + CAST(@n_CheckDigit AS NVARCHAR(1))

   QUIT_SP:

   IF @n_Continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_Success = 0
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_GLBL02'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[msp_GLBL02] TO [NSQL]
GO