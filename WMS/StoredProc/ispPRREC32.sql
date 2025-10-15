SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPRREC32                                            */
/* Creation Date: 03-JAN-2024                                              */
/* Copyright: MAERSK                                                       */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: WMS-24439 AU Levis finalize ASN Update missing line info for   */
/*          unknown Sku received from RDT.                                 */
/*                                                                         */
/* Called By: ispPreFinalizeReceiptWrapper                                 */
/*            Storerconfig: PreFinalizeReceiptSP                           */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 03-JAN-2024  NJOW    1.0   DEVOPS combine script                        */
/* 10-Oct-2025  SSA01   1.1  UWP-42248 -Enhanced session management        */
/***************************************************************************/  
CREATE OR ALTER PROC [dbo].[ispPRREC32]  
(     @c_Receiptkey  NVARCHAR(10)  
  ,   @c_ReceiptLineNumber  NVARCHAR(5) = ''      
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT   
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
      
   DECLARE @n_Continue           INT,
           @n_StartTranCount     INT,
           @c_ReceiptLineNumber2 NVARCHAR(5),
           @c_ExternReceiptkey   NVARCHAR(50),
           @c_ExternLineNo       NVARCHAR(20),
           @c_UserDefine02       NVARCHAR(30),
           @c_UserDefine03       NVARCHAR(30),
           @n_Userdefine02_Cnt   INT = 0,
           @n_ExternLineNo       INT = 0,
           @n_UserDefine03       INT = 0,
           @n_ExternLineNo_Len   INT = 6,
           @n_UserDefine03_Len   INT = 6
           
   SELECT @b_Success = 1, @n_Err = 0, @c_ErrMsg = '', @n_Continue = 1, @n_StartTranCount = @@TRANCOUNT                                                     

   --Main Process
   IF @n_Continue IN (1,2) 
   BEGIN
   	  IF EXISTS(SELECT 1 FROM RECEIPT (NOLOCK) WHERE Receiptkey = @c_Receiptkey AND DocType = 'R')
   	  BEGIN   	  	   	  	
         DECLARE CUR_REC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT RD.ReceiptLineNumber, R.ExternReceiptkey
            FROM RECEIPT R (NOLOCK)
            JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey
            WHERE R.ReceiptKey = @c_Receiptkey
            AND RD.ReceiptLineNumber = CASE WHEN ISNULL(@c_ReceiptLineNumber,'') <> '' THEN @c_ReceiptLineNumber ELSE RD.ReceiptLineNumber END
            AND (RD.ExternReceiptkey = '' OR RD.ExternReceiptkey IS NULL)
         
         OPEN CUR_REC 
         
         FETCH NEXT FROM CUR_REC INTO @c_ReceiptLineNumber2, @c_ExternReceiptkey
         
         IF @@FETCH_STATUS <> -1
         BEGIN
            SELECT @c_ExternLineNo = MAX(ExternLineNo), 
                   @c_UserDefine02 = MAX(UserDefine02), 
                   @c_UserDefine03 = MAX(UserDefine03),
                   @n_Userdefine02_Cnt = COUNT(DISTINCT Userdefine02)
            FROM RECEIPTDETAIL (NOLOCK) 
            WHERE Receiptkey = @c_Receiptkey
            
            IF EXISTS(SELECT 1 FROM RECEIPTDETAIL(NOLOCK) WHERE Receiptkey = @c_Receiptkey AND ISNULL(Userdefine02,'') = '')
               SET @n_Userdefine02_Cnt = @n_Userdefine02_Cnt - 1
               
            IF @n_Userdefine02_Cnt > 1 
               SET @c_Userdefine02 = ''            
               
            IF ISNUMERIC(@c_ExternLineNo) = 1
            BEGIN
               SET @n_ExternLineNo = CAST(@c_ExternLineNo AS INT)
               SET @n_ExternLineNo_Len = LEN(RTRIM(@c_ExternLineNo))
            END   

            IF ISNUMERIC(@c_Userdefine03) = 1
            BEGIN
               SET @n_UserDefine03 = CAST(@c_UserDefine03 AS INT)
               SET @n_UserDefine03_Len = LEN(RTRIM(@c_UserDefine03))
            END
         END
         
         WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN(1,2)
         BEGIN
         	  SET @n_ExternLineNo = @n_ExternLineNo + 1
         	  SET @c_ExternLineNo = RIGHT('0000000000' + LTRIM(RTRIM(CAST(@n_ExternLineNo AS NVARCHAR))), @n_ExternLineNo_Len)

         	  SET @n_UserDefine03 = @n_UserDefine03 + 1
         	  SET @c_UserDefine03 = RIGHT('0000000000' + LTRIM(RTRIM(CAST(@n_UserDefine03 AS NVARCHAR))), @n_UserDefine03_Len)
                     	           	        
            UPDATE RECEIPTDETAIL WITH (ROWLOCK)
            SET ExternReceiptkey = @c_ExternReceiptkey
              , ExternLineNo = @c_ExternLineNo
              , UserDefine02 = @c_UserDefine02
              , UserDefine03 = @c_UserDefine03
              , QtyExpected = BeforeReceivedQty
              --, TrafficCop   = NULL             
              , EditWho      = dbo.fnc_GetUserName()        --(SSA01)
              , EditDate     = dbo.fnc_GetDate()    --(SSA01)
            WHERE Receiptkey = @c_Receiptkey
            AND ReceiptLineNumber = @c_ReceiptLineNumber2
            
            SELECT @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63520
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update RECEIPTDETAIL Table Failed! (ispPRREC32)' + ' ( '
                               +'SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
            END 
         
            FETCH NEXT FROM CUR_REC INTO @c_ReceiptLineNumber2, @c_ExternReceiptkey
         END
         CLOSE CUR_REC
         DEALLOCATE CUR_REC
      END
   END 

QUIT_SP:
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispPRREC32'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCount  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN
   END 
END
GO
GRANT EXECUTE ON [dbo].[ispPRREC32] TO nSQL 
GO
