IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_InventoryHoldASN_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_InventoryHoldASN_Wrapper]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: WM.lsp_InventoryHoldASN_Wrapper                     */  
/* Creation Date: 09-OCT-2018                                            */  
/* Copyright: LFL                                                        */  
/* Written by: Wan                                                       */  
/*                                                                       */  
/* Purpose: LFWM-1281 - Stored Procedures for Kitting functionalities    */
/*        :                                                              */  
/* Called By:                                                            */  
/*                                                                       */  
/*                                                                       */  
/* Version: 1.0                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */ 
/* 2020-11-30  Wan01    1.1   Add Big Outer Begin Try..End Try to enable */
/*                            Revert when Raise error                    */
/*************************************************************************/   
CREATE PROCEDURE [WM].[lsp_InventoryHoldASN_Wrapper]
      @c_ReceiptKey           NVARCHAR(10)
    , @c_ReceiptLineNumber    NVARCHAR(5) = ''
    , @b_Success              INT=1 OUTPUT
    , @n_Err                  INT=0 OUTPUT
    , @c_ErrMsg               NVARCHAR(250)=''  OUTPUT
    , @c_UserName             NVARCHAR(128)=''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE @n_Continue        INT = 1
         , @n_StartTCnt       INT = @@TRANCOUNT

   DECLARE @c_ASNReason       NVARCHAR(10)= ''
     
   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] 
            @c_UserName = @c_UserName  OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
                
   EXECUTE AS LOGIN = @c_UserName

   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END
             
   EXECUTE AS LOGIN = @c_UserName   

   BEGIN TRY -- (Wan01) - START  
      SET @c_ASNReason = ''
      SELECT @c_ASNReason = ISNULL(RTRIM(R.ASNReason),'')
      FROM RECEIPT R WITH (NOLOCK)
      WHERE R.Receiptkey = @c_ReceiptKey

      BEGIN TRY
         EXEC dbo.ispInventoryHoldByReceipt
               @c_ReceiptKey = @c_ReceiptKey
            , @c_ReceiptLineNumber=@c_ReceiptLineNumber
            , @c_ReasonCode = @c_ASNReason              
            , @b_Success    = @b_Success       OUTPUT
            , @n_Err        = @n_Err           OUTPUT
            , @c_ErrMsg     = @c_ErrMsg        OUTPUT
      END TRY 
      BEGIN CATCH
         IF (XACT_STATE()) = -1  
         BEGIN
            ROLLBACK TRAN
         END

         WHILE @@TRANCOUNT < @n_StartTCNT
         BEGIN
            BEGIN TRAN
         END
                           
         SET @n_err = 555101
         SET @c_ErrMsg  = ERROR_MESSAGE()
         SET @c_ErrMsg  = 'NSQL' + CONVERT(CHAR(6), @n_err) 
                        + ': Error Executing lsp_HoldReceiptLot_Wrapper. (lsp_InventoryHoldASN_Wrapper)'
                        + ' (' + @c_ErrMsg + ')'
      END CATCH    
               
      IF @b_success = 0 OR @n_Err <> 0        
      BEGIN        
         SET @n_Continue = 3      
         GOTO EXIT_SP
      END        
   END TRY

   BEGIN CATCH
      SET @n_continue = 3
      SET @c_ErrMsg = 'Inventory Hold For ASN fail. (lsp_InventoryHoldASN_Wrapper) ( SQLSvr MESSAGE=' + ERROR_MESSAGE() + ' ) '
      GOTO EXIT_SP
   END CATCH -- (Wan01) - END  
       
   EXIT_SP:       
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_InventoryHoldASN_Wrapper'
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
END -- End Procedure
GO
GRANT EXECUTE ON [WM].[lsp_InventoryHoldASN_Wrapper] TO nSQL 
GO

