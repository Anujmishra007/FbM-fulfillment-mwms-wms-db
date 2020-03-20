IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispASNFZ03]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispASNFZ03]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispASNFZ03                                            */
/* Creation Date: 06-FEB-2015                                              */
/* Copyright: LF                                                           */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: SOS#331745-CN H&M-LDW InterfaceLog CR for Return Receiving     */
/*                                                                         */
/* Called By:                                                              */
/*                                                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/***************************************************************************/  
CREATE PROC [dbo].[ispASNFZ03]  
(     @c_Receiptkey  NVARCHAR(10)   
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT   
  ,   @c_ReceiptLineNumber NVARCHAR(5)=''
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
      
   DECLARE @n_Continue INT,
           @n_StartTranCount INT,
           @c_InterfaceLogID NVARCHAR(10),
           @c_Storerkey NVARCHAR(15),
           @c_ReceiptLineNo NVARCHAR(5),
           @c_SKU NVARCHAR(20),
           @n_QtyReceived INT,
           @c_UOM NVARCHAR(10),
           @c_Lot NVARCHAR(10),
           @c_ExternReceiptkey NVARCHAR(30)        
                      
   SELECT @b_Success=1, @n_Err=0, @c_ErrMsg='', @n_Continue = 1, @n_StartTranCount=@@TRANCOUNT            
   
   DECLARE ASN_CUR CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT RD.Storerkey, RD.ReceiptLineNumber, RD.Sku, SUM(RD.QtyReceived) AS QtyReceived, RD.UOM, ITRN.Lot, RD.ExternReceiptkey
      FROM RECEIPT R (NOLOCK)
      JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey 
      JOIN ITRN (NOLOCK) ON ITRN.Storerkey = R.Storerkey AND ITRN.TranType = 'DP' AND ITRN.SourceType = 'ntrReceiptDetailUpdate'  
                         AND ITRN.Sourcekey = RD.Receiptkey + RD.ReceiptLineNumber
      WHERE RD.Lottable03 = 'RET'
      AND R.Receiptkey = @c_Receiptkey
      AND RD.Finalizeflag = 'Y'
      AND R.Doctype = 'R'
      AND RD.ReceiptLineNumber = CASE WHEN ISNULL(@c_ReceiptLineNumber,'') <> '' THEN @c_ReceiptLineNumber ELSE RD.ReceiptLineNumber END
      GROUP BY RD.Storerkey, RD.ReceiptLineNumber, RD.Sku, RD.UOM, ITRN.Lot, RD.ExternReceiptkey
      ORDER BY RD.ReceiptLineNumber

   OPEN ASN_CUR

	 FETCH NEXT FROM ASN_CUR INTO @c_Storerkey, @c_ReceiptLineNo, @c_Sku, @n_QtyReceived, @c_UOM, @c_Lot, @c_ExternReceiptkey

	 WHILE @@FETCH_STATUS <> -1
	 BEGIN
      SELECT @b_success = 1  

      EXECUTE dbo.nspg_getkey_DTSITF
        'InterfaceLogID'     
       , 10  
       , @c_InterfaceLogID OUTPUT  
       , @b_success OUTPUT  
       , @n_err     OUTPUT  
       , @c_errmsg  OUTPUT  
      
      IF NOT @b_success = 1  
      BEGIN  
         SET @n_continue = 3  
         SET @n_err = 68006  
         SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))   
                 + ': Unable To Obtain InterfaceLogID. (ispASNFZ03) '   
                 + '( sqlsvr message=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '  
         GOTO QUIT_SP  
      END  

      INSERT INTO INTERFACELOG (Interfacekey, Sourcekey, Storerkey, ExternSourcekey, Tablename, Sku, Qty, UOM,  
                                UserId, TranCode, TranStatus, TranDate, Userdefine01, Userdefine02, Status)
                        VALUES (@c_InterfaceLogID, @c_Receiptkey, @c_Storerkey, @c_ReceiptLineNo, 'HMRTN', @c_Sku, @n_QtyReceived, @c_UOM, 
                                SUSER_SNAME(), @c_Lot, '', GetDate(), @c_ExternReceiptkey, CAST(@n_QtyReceived AS NVARCHAR), '0')
	 	  
      FETCH NEXT FROM ASN_CUR INTO @c_Storerkey, @c_ReceiptLineNo, @c_Sku, @n_QtyReceived, @c_UOM, @c_Lot, @c_ExternReceiptkey
	 END
   CLOSE ASN_CUR      
	 DEALLOCATE ASN_CUR
  
   QUIT_SP:
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispASNFZ03'
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

GRANT EXECUTE ON [dbo].[ispASNFZ03] TO nSQL 
GO
