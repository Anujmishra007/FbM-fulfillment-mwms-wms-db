IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Delete_ReceiptDetail_WIP]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_Delete_ReceiptDetail_WIP]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: isp_Delete_ReceiptDetail_WIP                        */  
/* Creation Date: 2020-09-21                                             */  
/* Copyright: LFL                                                        */  
/* Written by: Wan                                                       */  
/*                                                                       */  
/* Purpose: WMS-14739 - CN NIKE O2 WMS RFID Receiving Module             */
/*          ASN Header                                                   */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/* Version: 1.0                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */ 
/* 09-OCT-2020 Wan      1.0   Created                                   */
/*************************************************************************/   
CREATE PROCEDURE [dbo].[isp_Delete_ReceiptDetail_WIP] 
   @n_RowID    BIGINT         = 0 
,  @b_Success  INT            = 1   OUTPUT   
,  @n_Err      INT            = 0   OUTPUT
,  @c_Errmsg   NVARCHAR(255)  = ''  OUTPUT
AS  
BEGIN  
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue           INT = 1
         , @n_StartTCnt          INT = @@TRANCOUNT

     SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

  
   DELETE RECEIPTDETAIL_WIP
   WHERE RowID = @n_RowID

   IF @@ERROR <> 0
   BEGIN
      SET @n_continue = 3      
      SET @n_err = 89210
      SET @c_errmsg = 'NSQL' +CONVERT(CHAR(5),@n_err) + ': Update RECEIPTDETAIL_WIP Failed. (isp_Delete_ReceiptDetail_WIP)'
      GOTO QUIT_SP
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_Delete_ReceiptDetail_WIP'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
   REVERT      
END  
GO
GRANT EXECUTE ON [dbo].[isp_Delete_ReceiptDetail_WIP] TO nSQL 
GO


