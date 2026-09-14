SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: ispSKUDC20                                         */
/* Creation Date: 10/06/2026                                            */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-13430 HK -On Running SCE Ecom Packing Decode Logic      */
/*                                                                      */
/*                                                                      */
/* Called By: isp_SKUDecode_Wrapper                                     */
/*                                                                      */
/* GitHub Version: 1.0                                                  */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 10-JUN-2026 CSC166   1.0   FCR-13430 - Initial                       */
/* 18-AUG-2026 CSC166   1.0   FCR-13430 - duplicate record validation   */
/* 03-SEP-2026 CSC166   1.0   FCR-13430 - Add PickSlipNo to validation  */
/************************************************************************/

CREATE OR ALTER   PROCEDURE [dbo].[ispSKUDC20]
     @c_Storerkey        NVARCHAR(15)
   , @c_Sku              NVARCHAR(60)
   , @c_NewSku           NVARCHAR(60)      OUTPUT
   , @c_Code01           NVARCHAR(60) = '' OUTPUT
   , @c_Code02           NVARCHAR(60) = '' OUTPUT
   , @c_Code03           NVARCHAR(60) = '' OUTPUT
   , @b_Success          INT          = 1  OUTPUT
   , @n_Err              INT          = 0  OUTPUT
   , @c_ErrMsg           NVARCHAR(250)= '' OUTPUT
   , @c_Pickslipno       NVARCHAR(10) = ''
   , @n_CartonNo         INT = 0
   , @c_UCCNo            NVARCHAR(20) = ''  --Pack by UCC when UCCtoDropID = '1' 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue     INT = 1
         , @n_StartTcnt    INT = @@TRANCOUNT
         , @c_TempSku      NVARCHAR(60) = ''
		 , @c_TempSN       NVARCHAR(60) = ''

   SELECT @b_success = 1, @n_err = 0, @c_errmsg = ''   
   
   SET @c_TempSku = @c_Sku
    
   IF LEN(RTRIM(@c_Sku)) = 37                    
   BEGIN                                  	                  
      SELECT @c_TempSku = LEFT(@c_Sku,13)   
	  SELECT @c_TempSN	= RIGHT(@c_Sku,24)   
   END  

   -- Duplicate record validation in PackSerialNo
   IF EXISTS(SELECT 1 FROM PackSerialNo(NOLOCK) WHERE Storerkey = @c_Storerkey AND SKU = @c_TempSku AND SerialNo = @c_TempSN AND PickSlipNo = @c_Pickslipno)
   BEGIN
		SET @n_Continue = 3;
		SET @n_Err      = 90050;
		SET @c_ErrMsg   = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
						+ ': Error - Duplicate record ' + @c_Sku + ' PickSlipNo: ' + @c_Pickslipno;
		GOTO QUIT_SP;
   END

   -- if LEN not 37 then proceed with current SKU value without any decoding                                                   
   SELECT @c_NewSku = @c_TempSku

QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process AND Return
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'ispSKUDC20'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END -- End Procedure
