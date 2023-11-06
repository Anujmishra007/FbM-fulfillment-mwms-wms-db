SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispASNFZ26                                            */
/* Creation Date: 16-OCT-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: WMS-23935 - CN Costco2 finalize ASN insert sku lot info into   */
/*          docinfo                                                        */
/*                                                                         */
/* Called By: ispPostFinalizeReceiptWrapper                                */
/*            Storerconfig PostFinalizeReceiptSP                           */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 16-OCT-2022  NJOW    1.0   DevOps Combine Script                        */
/***************************************************************************/  
CREATE OR ALTER PROC [dbo].[ispASNFZ26]  
(     @c_Receiptkey        NVARCHAR(10)   
  ,   @b_Success           INT           OUTPUT
  ,   @n_Err               INT           OUTPUT
  ,   @c_ErrMsg            NVARCHAR(255) OUTPUT   
  ,   @c_ReceiptLineNumber NVARCHAR(5)=''
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
      
   DECLARE @n_Continue           INT
         , @n_StartTranCount     INT
         , @c_SKU                NVARCHAR(20)
         , @c_Userdefine01       NVARCHAR(30)
         , @c_Storerkey          NVARCHAR(15)
         , @c_lot                NVARCHAR(10)

   SELECT @b_Success = 1, @n_Err = 0, @c_ErrMsg = '', @n_Continue = 1, @n_StartTranCount = @@TRANCOUNT                  
     
   IF @@TRANCOUNT = 0
      BEGIN TRAN
   
   IF @n_Continue IN(1,2)
   BEGIN
      DECLARE CUR_RD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT RD.Storerkey, RD.SKU, ITRN.Lot, R.Userdefine01
         FROM RECEIPT R WITH (NOLOCK)
         JOIN RECEIPTDETAIL RD WITH (NOLOCK) ON R.Receiptkey = RD.Receiptkey
         JOIN ITRN WITH (NOLOCK) ON ITRN.TranType = 'DP' 
                                AND ITRN.SourceKey = RD.ReceiptKey + RD.ReceiptLineNumber
                                AND ITRN.StorerKey = RD.StorerKey AND ITRN.Sku = RD.SKU
                                AND LEFT(ITRN.SourceType,16) = 'ntrReceiptDetail'
         WHERE R.ReceiptKey = @c_Receiptkey
         AND RD.ReceiptLineNumber = CASE WHEN ISNULL(@c_ReceiptLineNumber,'') <> '' 
                                      THEN @c_ReceiptLineNumber 
                                      ELSE ReceiptLineNumber END
      GROUP BY RD.Storerkey, RD.SKU, ITRN.Lot, R.Userdefine01
      ORDER BY RD.Sku, ITRN.Lot
      
      OPEN CUR_RD 

      FETCH NEXT FROM CUR_RD INTO @c_Storerkey, @c_SKU, @c_Lot, @c_Userdefine01

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN(1,2)
      BEGIN      	 
      	 IF NOT EXISTS(SELECT 1 
      	               FROM DOCINFO (NOLOCK)
      	               WHERE Storerkey = @c_Storerkey
      	               AND Key1 = @c_Sku
      	               AND Key2 = @c_Lot
      	               AND TableName = 'QUARANTINE'
      	               AND DataType = 'LOT')
      	 BEGIN
      	    INSERT INTO DOCINFO (TableName, DataType, Storerkey, Key1, Key2, key3, data, lineseq)
      	       VALUES ('QUARANTINE', 'LOT', @c_Storerkey, @c_Sku, @c_Lot, '', @c_Userdefine01, 0)
      	    
            SET @n_err = @@ERROR
            
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63200  
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Insert into DOCINFO Table. (ispASNFZ26)' 
                              + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
            END
      	    
      	 END              
      	 
         FETCH NEXT FROM CUR_RD INTO @c_Storerkey, @c_SKU, @c_Lot, @c_Userdefine01      	
      END
   	  CLOSE CUR_RD
   	  DEALLOCATE CUR_RD      
   END
                                         
QUIT_SP:

   IF CURSOR_STATUS('LOCAL', 'CUR_RD') IN (0 , 1)
   BEGIN
      CLOSE CUR_RD
      DEALLOCATE CUR_RD   
   END

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