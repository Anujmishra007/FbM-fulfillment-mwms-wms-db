/************************************************************************/
/* Stored Proc: API.isp_ECOMP_PrePrintCheck01                           */
/* Creation Date: 06-MAR-2026                                           */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-10057 - UA PACKLIST Pre-Print Check                     */
/*            UA Customized Pre-Print Check for PACKLIST                */
/*          1. Skip PACKLIST if Orders.userdefine03 exists in           */
/*             codelkup NOPACKLIST (storerkey = 'UA')                   */
/*                                                                      */
/* Called By: API.isp_ECOMP_PrePrintCheck_Wrapper                       */
/*                                                                      */
/* Return Value (@b_Success):                                           */
/*   0 = Error / Fail                                                   */
/*   1 = Print                                                          */
/*   2 = Not To Print (skip silently)                                   */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 06-MAR-2026  Sean    1.0   Initial                                   */
/************************************************************************/
CREATE OR ALTER PROC [API].[isp_ECOMP_PrePrintCheck01]
           @c_PickSlipNo      NVARCHAR(10)
         , @c_ReportType      NVARCHAR(30)
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

         , @c_Orderkey        NVARCHAR(10)   
         , @c_ECOMFlag        NVARCHAR(1)

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue  = 1
   SET @n_Err       = 0
   SET @c_ErrMsg    = ''
   SET @c_Orderkey  = ''
   SET @c_ECOMFlag  = ''

   WHILE @@TRANCOUNT > 0
   BEGIN 
      COMMIT TRAN
   END

   -- Only apply custom logic for PACKLIST report type
   IF @c_ReportType <> 'PACKLIST'
   BEGIN
      GOTO QUIT_SP
   END

   -- Step 1: Get Orderkey from PackHeader
   SELECT @c_Orderkey = ISNULL(RTRIM(Orderkey), '')
   FROM dbo.PACKHEADER (NOLOCK)
   WHERE PickSlipNo = @c_PickSlipNo

   IF @c_Orderkey = ''
   BEGIN
      GOTO QUIT_SP
   END

   -- Check 1: Orders.userdefine03 in codelkup NOPACKLIST (storerkey = 'UA') → skip packing list
   --          Only reached if ECOMFlag is neither 'S' nor 'M'
   IF EXISTS (
      SELECT 1
      FROM dbo.ORDERS O (NOLOCK)
      JOIN dbo.CODELKUP CL (NOLOCK)
          ON  CL.ListName  = 'NOPACKLIST'
          AND CL.StorerKey = 'UA'
          AND CL.Long      = O.userdefine03
      WHERE O.Orderkey = @c_Orderkey
   )
   BEGIN
      SET @n_Continue = 2   -- Not To Print
      GOTO QUIT_SP
   END

   -- All checks passed → proceed to print
   SET @n_Continue = 1

QUIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return
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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_ECOMP_PrePrintCheck01'
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
GRANT EXECUTE ON [API].[isp_ECOMP_PrePrintCheck01] TO nSQL 
GO