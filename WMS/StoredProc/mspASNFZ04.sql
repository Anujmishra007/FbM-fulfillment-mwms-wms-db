SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: mspASNFZ04                                            */
/* Creation Date: 2026-03-05                                               */
/* Copyright: Maersk                                                       */
/* Written by: Wan                                                         */
/*                                                                         */
/* Purpose: FCR-10206 - SAU DAMMAM Putaway Strategy                        */
/*        :                                                                */
/*                                                                         */
/* Called By: ispPostFinalizeReceiptWrapper                                */
/*          : Storerconfig 'PostFinalizeReceiptSP'                         */
/* Version: V2                                                             */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author   Ver   Purposes                                     */
/* 2026-03-05  Wan      1.0   Created.                                     */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[mspASNFZ04]
   @c_Receiptkey  NVARCHAR(10)
,  @b_Success     INT                = 1  OUTPUT
,  @n_Err         INT                = 0  OUTPUT
,  @c_ErrMsg      NVARCHAR(255)      = '' OUTPUT
,  @c_ReceiptLineNumber  NVARCHAR(5) = ''
 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCount     INT   = @@TRANCOUNT
         , @n_Continue        INT   = 1

         , @n_Debug           INT   = 0
         , @c_ASNStatus       NVARCHAR(10) = ''
         , @c_UserName        NVARCHAR(128)= ''
   
   SET @b_Success  = 1   
   SET @n_Err      = 0   
   SET @c_ErrMsg   = ''  
   SET @c_UserName = dbo.Fnc_GetUserName() 

   SELECT @c_ASNStatus = RECEIPT.ASNStatus
   FROM RECEIPT WITH (NOLOCK)
   WHERE RECEIPT.ReceiptKey = @c_ReceiptKey

   IF @c_ASNStatus <> '9'
   BEGIN
      GOTO QUIT_SP
   END
    
   EXEC [WM].[lsp_ASNReleasePATask_Wrapper]
         @c_ReceiptKey        = @c_Receiptkey  
      ,  @b_Success           = @b_Success      OUTPUT
      ,  @n_Err               = @n_Err          OUTPUT
      ,  @c_ErrMsg            = @c_ErrMsg       OUTPUT
      ,  @n_WarningNo         = 1       
      ,  @c_ProceedWithWarning= 'Y'     
      ,  @c_UserName          = @c_UserName

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3
   END

   QUIT_SP:
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCount
      BEGIN
         ROLLBACK TRAN
      END
   END
   ELSE
   BEGIN
      SET @b_success = 1
   END
 
   RETURN
END
GO
GRANT EXECUTE ON [dbo].[mspASNFZ04] TO nSQL
GO


