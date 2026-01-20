SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispASNFZ26                                            */
/* Creation Date: 13-Oct-2025                                              */
/* Copyright: MAERSK                                                       */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: [IND] PAGE – ASN FINALIZATION CR                               */
/*                                                                         */
/* Called By: ispPostFinalizeReceiptWrapper                                */
/*            Storerconfig: PostFinalizeReceiptSP                          */
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
CREATE OR ALTER PROC [dbo].[ispASNFZ26]  
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
		   @c_Facility           NVARCHAR(50),
		   @c_CDLUUDF02          NVARCHAR(50),
		   @c_ParentUCC          NVARCHAR(50),
		   @c_LOC                NVARCHAR(50) = '',
		   @c_ID                 NVARCHAR(50) = '',
		   @c_LOT                NVARCHAR(50) = '',
           @n_QTYReceived        INT,
		   @n_CTNSerialno        INT,
		   @c_SerialNoKey        NVARCHAR(10),
		   @c_Serialno           NVARCHAR(50),
		   @c_SourceKey          NVARCHAR(20),
           @c_SourceType         NVARCHAR(30),
		   @c_SKU                NVARCHAR(30),
		   @c_SerialnoCapture    NVARCHAR(30),
		   @n_QTY                INT,
		   @c_SerialNoUpdateLotLocID   NVARCHAR(10) = '',
		   @c_ReceiptLineNumber2 NVARCHAR(5),
		   @n_ChildQTY           INT
           
   SELECT @b_Success = 1, @n_Err = 0, @c_ErrMsg = '', @n_Continue = 1, @n_StartTranCount = @@TRANCOUNT                                                     

   --Validation 1: Check ReceiptGroup = 'UCC'
   SELECT @c_ReceiptGroup = R.ReceiptGroup
        , @c_StorerKey    = R.StorerKey
		, @c_Facility     = R.Facility
   FROM RECEIPT R (NOLOCK)
   WHERE R.ReceiptKey = @c_Receiptkey

   SELECT @c_CDLUUDF02 = UDF01
   FROM Codelkup (NOLOCK)
   WHERE StorerKey = @c_StorerKey
     AND ListName  = 'RECEIPTGRP'
	 AND Code      = @c_ReceiptGroup

   IF ISNULL(@c_CDLUUDF02, '') <> 'UCC'
   BEGIN
      GOTO QUIT_SP
   END

   SELECT @c_SerialNoUpdateLotLocID = fsgr.Authority FROM dbo.fnc_SelectGetRight(@c_Facility, @c_Storerkey, '', 'SerialNoUpdateLotLocID')AS fsgr

   --Main Process
   IF @n_Continue IN (1,2) 
   BEGIN
   	  IF EXISTS(SELECT 1 FROM RECEIPT (NOLOCK) WHERE Receiptkey = @c_Receiptkey)
   	  BEGIN   	  	   	  	
         DECLARE CUR_REC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	        SELECT RD.ReceiptLineNumber
                 , RD.UserDefine01
		         , RD.BeforeReceivedQty
              FROM RECEIPT R (NOLOCK)
              JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey
              WHERE R.ReceiptKey = @c_Receiptkey
              AND RD.ReceiptLineNumber = CASE WHEN ISNULL(@c_ReceiptLineNumber,'') <> '' THEN @c_ReceiptLineNumber ELSE RD.ReceiptLineNumber END

         OPEN CUR_REC 

         FETCH NEXT FROM CUR_REC INTO @c_ReceiptLineNumber2, @c_ParentUCC, @n_QTYReceived

         WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN(1,2)
         BEGIN
            SELECT @n_CTNSerialno = SUM(ChildQTY)
              FROM MasterSerialno (NOLOCK) 
             WHERE StorerKey = @c_StorerKey
               AND ParentSerialNo  = @c_ParentUCC
               AND UnitType  <> 'UCC'
            
            IF @n_CTNSerialno <> @n_QTYReceived
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63520
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': ReceiptQTY is not matched with counted child SerialNo! (ispASNFZ26)' + ' ( '
                               +'SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
               GOTO QUIT_SP
            END 

            DECLARE CUR_Serial_REC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT Serialno, SKU, ChildQTY
                 FROM MasterSerialno (NOLOCK) 
                WHERE StorerKey = @c_StorerKey
                  AND ParentSerialNo  = @c_ParentUCC
                  AND UnitType  <> 'UCC'
            OPEN CUR_Serial_REC 
         
            FETCH NEXT FROM CUR_Serial_REC INTO @c_Serialno, @c_SKU, @n_ChildQTY
         
            WHILE @@FETCH_STATUS <> -1
            BEGIN

               IF NOT EXISTS(SELECT 1 FROM SerialNo (nolock) where StorerKey = @c_StorerKey AND SKU = @c_SKU AND SerialNo = @c_Serialno)
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
                     SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Generate SerialNoKey Failed. (ispASNFZ26)'
                                   + '( ' + RTRIM(@c_errmsg) + ' )'
                  END

                  SELECT @c_SerialnoCapture = SerialnoCapture
			        FROM SKU (NOLOCK)
			       WHERE StorerKey = @c_StorerKey
			         AND Facility  = @c_Facility
			         AND SKU = @c_SKU

                  IF @c_SerialnoCapture in ('1','2') AND @c_SerialNoUpdateLotLocID = '1'
			      BEGIN

	                 SELECT TOP 1 @c_LOC = RD.ToLoc
		                  , @c_ID = RD.ToID
				      	   , @c_LOT = RD.ToLOT
                       FROM RECEIPT R (NOLOCK)
                       JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey
                       WHERE R.ReceiptKey = @c_Receiptkey
                       AND RD.ReceiptLineNumber = CASE WHEN ISNULL(@c_ReceiptLineNumber,'') <> '' THEN @c_ReceiptLineNumber ELSE RD.ReceiptLineNumber END
                     ORDER BY DateReceived DESC

                  END

		          INSERT INTO SerialNo (SerialNoKey, Orderkey, OrderLineNumber, StorerKey, SKU, SerialNo, status, QTY, Loc, ID, Lot, UCCNo)
                  SELECT @c_SerialNoKey, '', '', @c_StorerKey, SKU, SerialNo, '1', @n_ChildQTY, @c_LOC, @c_ID, @c_LOT, @c_ParentUCC
		            FROM MasterSerialno WITH (NOLOCK)
			       WHERE SerialNo = @c_Serialno

                  SET @n_err = @@Error
				 
                  IF @@Error <> 0  
                  BEGIN  
                     SET @n_continue = 3  
                     SET @n_Err =  68011   
                     SET @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5), @n_err) + ': Failed to INSERT SerialNo (ispASNFZ26)'  
                     GOTO QUIT_SP  
                  END

                  IF @n_Continue IN (1,2)
                  BEGIN
                     SELECT @c_SourceKey    = @c_Receiptkey + @c_ReceiptLineNumber2
                     EXEC dbo.ispITrnSerialNoDeposit
                       @c_TranType     = 'DP'
                     , @c_StorerKey    = @c_StorerKey
                     , @c_SKU          = @c_SKU
                     , @c_SerialNo     = @c_SerialNo
                     , @n_QTY          = @n_ChildQTY
                     , @c_SourceKey    = @c_SourceKey
                     , @c_SourceType   = 'ispASNFZ26'
                     , @b_Success      = @b_Success     OUTPUT
                     , @n_Err          = @n_Err         OUTPUT
                     , @c_ErrMsg       = @c_ErrMsg      OUTPUT
			   
                     IF @n_err <> 0
                     BEGIN
                        SET @n_continue = 3
                     END
                  END
               END
               FETCH NEXT FROM CUR_Serial_REC INTO @c_Serialno, @c_SKU, @n_ChildQTY
            END
            CLOSE CUR_Serial_REC
            DEALLOCATE CUR_Serial_REC

            FETCH NEXT FROM CUR_REC INTO @c_ReceiptLineNumber2, @c_ParentUCC, @n_QTYReceived
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispASNFZ26'
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
GRANT EXECUTE ON [dbo].[ispASNFZ26] TO nSQL 
GO