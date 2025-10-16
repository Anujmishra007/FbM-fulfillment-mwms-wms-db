SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPRREC35                                            */
/* Creation Date: 13-Oct-2025                                              */
/* Copyright: MAERSK                                                       */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: [IND] PAGE – ASN FINALIZATION CR                               */
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
/* Date         Author   Ver   Purposes                                    */
/* 13-Oct-2025  AndyWu01 1.0   DEVOPS combine script                       */
/***************************************************************************/  
CREATE OR ALTER PROC [dbo].[ispPRREC35]  
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
		   @c_ReceiptGroup       NVARCHAR(50),
		   @c_StorerKey          NVARCHAR(50),
		   @c_CDLUUDF02          NVARCHAR(50),
		   @c_ParentUCC          NVARCHAR(50),
           @n_QTYReceived        INT,
		   @n_CTNSerialno        INT,
		   @c_SerialNoKey        NVARCHAR(10),
		   @c_Serialno           NVARCHAR(50),
		   @c_SourceKey          NVARCHAR(20),
           @c_SourceType         NVARCHAR(30),
		   @c_SKU                NVARCHAR(30),
		   @n_QTY                INT,
		   
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

   --Validation 1: Check ReceiptGroup = 'UCC'
   SELECT @c_ReceiptGroup = R.ReceiptGroup
        , @c_StorerKey    = R.StorerKey
   FROM RECEIPT R (NOLOCK)
   WHERE R.ReceiptKey = @c_Receiptkey

   SELECT @c_CDLUUDF02 = UDF02
   FROM Codelkup (NOLOCK)
   WHERE StorerKey = @c_StorerKey
     AND ListName  = 'RCPTGRP'
	 AND Code      = @c_ReceiptGroup

   IF ISNULL(@c_CDLUUDF02, '') <> 'UCC'
   BEGIN
      GOTO QUIT_SP
   END

   --Main Process
   IF @n_Continue IN (1,2) 
   BEGIN
   	  IF EXISTS(SELECT 1 FROM RECEIPT (NOLOCK) WHERE Receiptkey = @c_Receiptkey)
   	  BEGIN   	  	   	  	
	     SELECT @c_ParentUCC = RD.UserDefine01
		      , @n_QTYReceived = RD.QTYRECEIVED
           FROM RECEIPT R (NOLOCK)
           JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey
           WHERE R.ReceiptKey = @c_Receiptkey
           AND RD.ReceiptLineNumber = CASE WHEN ISNULL(@c_ReceiptLineNumber,'') <> '' THEN @c_ReceiptLineNumber ELSE RD.ReceiptLineNumber END

         SELECT @n_CTNSerialno = COUNT(Serialno)
           FROM MasterSerialno (NOLOCK) 
          WHERE StorerKey = @c_StorerKey
            AND ParentSerialNo  = @c_ParentUCC
            AND UnitType  <> 'UCC'
            
         IF EXISTS(@n_CTNSerialno <> @n_QTYReceived)
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63520
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': ReceiptQTY is not matched with counted child SerialNo! (ispPRREC35)' + ' ( '
                            +'SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
            GOTO QUIT_SP
         END 

         DECLARE CUR_REC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT @c_Serialno = Serialno
		      , @c_SKU = SKU
           FROM MasterSerialno (NOLOCK) 
          WHERE StorerKey = @c_StorerKey
            AND ParentSerialNo  = @c_ParentUCC
            AND UnitType  <> 'UCC'
         OPEN CUR_REC 
         
         FETCH NEXT FROM CUR_REC INTO @c_Serialno
         
         IF @@FETCH_STATUS <> -1
         BEGIN

            EXECUTE nspg_GetKey
              'SERIALNO'
            , 10
            , @c_SerialNoKey  OUTPUT
            , @b_success     OUTPUT
            , @n_err         OUTPUT
            , @c_errmsg      OUTPUT

            IF @b_success <> 1
            BEGIN
               SET @n_continue= 3
               SET @n_err  = 72800
               SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Generate SerialNoKey Failed. (ispPRREC35)'
                             + '( ' + RTRIM(@c_errmsg) + ' )'
            END

		    INSERT INTO SerialNo (SerialNoKey, Orderkey, OrderLineNumber, StorerKey, SKU, SerialNo, status, QTY)
            SELECT @c_SerialNoKey, '', '', @c_StorerKey, SKU, SerialNo, '1', 1
		      FROM MasterSerialno WITH (NOLOCK)
			 WHERE SerialNo = @c_Serialno

            SET @n_err = @@Error
				 
            IF @@Error <> 0  
            BEGIN  
               SET @n_continue = 3  
               SET @n_Err =  68011   
               SET @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5), @n_err) + ': Failed to INSERT SerialNo (ispPRREC35)'  
               GOTO QUIT_SP  
            END

            IF @n_Continue IN (1,2)
            BEGIN
               EXEC dbo.ispITrnSerialNoDeposit
                 @c_TranType     = 'DP'
               , @c_StorerKey    = @c_StorerKey
               , @c_SKU          = @c_SKU
               , @c_SerialNo     = @c_SerialNo
               , @n_QTY          = 1
               , @c_SourceKey    = @c_Receiptkey + @c_ReceiptLineNumber
               , @c_SourceType   = 'ispPRREC35'
               , @b_Success      = @b_Success     OUTPUT
               , @n_Err          = @n_Err         OUTPUT
               , @c_ErrMsg       = @c_ErrMsg      OUTPUT

               IF @n_err <> 0
               BEGIN
                  SET @n_continue = 3
               END
            END

         END

         FETCH NEXT FROM CUR_REC INTO @c_Serialno
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispPRREC35'
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
GRANT EXECUTE ON [dbo].[ispPRREC35] TO nSQL 
GO