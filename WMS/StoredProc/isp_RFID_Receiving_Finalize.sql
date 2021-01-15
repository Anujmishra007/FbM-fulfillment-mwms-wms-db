IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_RFID_Receiving_Finalize]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_RFID_Receiving_Finalize]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: isp_RFID_Receiving_Finalize                         */  
/* Creation Date: 2020-09-22                                             */  
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
/* 09-OCT-2020 Wan      1.0   Created                                    */
/*************************************************************************/   
CREATE PROCEDURE [dbo].[isp_RFID_Receiving_Finalize] 
   @c_ReceiptKey        NVARCHAR(10)   = ''
,  @b_Success           INT            = 1   OUTPUT   
,  @n_Err               INT            = 0   OUTPUT
,  @c_Errmsg            NVARCHAR(255)  = ''  OUTPUT
AS  
BEGIN  
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue           INT = 1
         , @n_StartTCnt          INT = @@TRANCOUNT

         , @n_Cnt                INT          = 0 
         , @c_Facility           NVARCHAR(5)  = ''
         , @c_Storerkey          NVARCHAR(15) = ''
         , @c_CarrierRef         NVARCHAR(18) = ''

   IF EXISTS ( SELECT 1
               FROM RECEIPT RH WITH (NOLOCK)
               WHERE RH.ReceiptKey = @c_ReceiptKey
               AND   RH.ASNStatus = '9'
            )
   BEGIN
      SET @n_Continue = 3
      SET @n_err = 89010   
      SET @c_errmsg= 'NSQL'+CONVERT(char(5),@n_err)+': ASN is closed'
                     + '. (isp_RFID_Receiving_Finalize)'   
      GOTO QUIT_SP   
   END

   IF EXISTS ( SELECT 1
               FROM RECEIPTDETAIL RD WITH (NOLOCK)
               WHERE RD.ReceiptKey = @c_ReceiptKey
               AND RD.FinalizeFlag = 'Y'
               )
   BEGIN
      SET @n_continue = 3      
      SET @n_err = 88020
      SET @c_errmsg = 'NSQL' +CONVERT(CHAR(5),@n_err) + ': Finalized ASN Detail is found. (isp_RFID_Receiving_Finalize)'
      GOTO QUIT_SP
   END

   EXEC dbo.ispFinalizeReceipt
        @c_ReceiptKey         = @c_ReceiptKey
      , @c_ReceiptLineNumber  = ''   
      , @b_Success            = @b_Success OUTPUT   
      , @n_Err                = @n_Err     OUTPUT
      , @c_Errmsg             = @c_Errmsg  OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_continue = 3      
      SET @n_err = 88030
      SET @c_errmsg = 'NSQL' +CONVERT(CHAR(5),@n_err) + ': Update RECEIPTDETAIL_WIP Failed. (isp_RFID_Receiving_Finalize)'
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_RFID_Receiving_Finalize'
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
GRANT EXECUTE ON [dbo].[isp_RFID_Receiving_Finalize] TO nSQL 
GO


