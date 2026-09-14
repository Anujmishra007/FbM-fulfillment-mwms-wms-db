SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Proc: isp_GetSNFRLBL04                                         */
/* Creation Date: 10-JUN-2026                                            */
/* Copyright: Maersk                                                     */
/* Written by:                                                           */
/*                                                                       */
/* Purpose: FCR-13430 HK -On Running SCE Ecom Packing Decode Logic       */
/*        :                                                              */
/*                                                                       */
/* Called By:  ECOM PACK Sku. isp_GetSNFromScanLabel_Wrapper             */
/*          :  Storerconfig - GetSNFromScanLabel                         */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 10-JUN-2026 CSC166   1.0   FCR-13430 - Initial	                     */
/*************************************************************************/
CREATE OR ALTER   PROC [dbo].[isp_GetSNFRLBL04]
           @c_Storerkey       NVARCHAR(15)
         , @c_Sku             NVARCHAR(20)
         , @c_ScanLabel       NVARCHAR(60)
         , @c_SerialNo        NVARCHAR(30)   OUTPUT
         , @b_Success         INT            OUTPUT
         , @n_Err             INT            OUTPUT
         , @c_ErrMsg          NVARCHAR(255)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt       INT
          ,@n_Continue        INT
          --,@c_SerialNoCapture NVARCHAR(1)

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @n_err      = 0
   SET @c_errmsg   = ''

   SET @c_SerialNo = ''

   IF LEN(RTRIM(@c_ScanLabel)) = 37                    
   BEGIN                                  	                  
      SELECT @c_SerialNo = RIGHT(@c_ScanLabel,24)   
   END  
   
QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_GetSNFRLBL04'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
