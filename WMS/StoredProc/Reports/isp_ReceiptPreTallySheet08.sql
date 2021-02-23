IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_ReceiptPreTallySheet08]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_ReceiptPreTallySheet08]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Proc: isp_ReceiptPreTallySheet08                              */  
/* Creation Date: 11-Jan-2021                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: WLChooi                                                  */  
/*                                                                      */  
/* Purpose: WMS-16005 - [PH] - Adidas Ecom - PreTally Sheet             */   
/*        :                                                             */  
/* Called By: r_receipt_pre_tallysheet08                                */
/*          :                                                           */  
/* GitLab Version: 1.0                                                  */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver Purposes                                  */  
/************************************************************************/ 

CREATE PROC [dbo].[isp_ReceiptPreTallySheet08]  
            @c_ReceiptStart   NVARCHAR(10)  
         ,  @c_ReceiptEnd     NVARCHAR(10)  
         ,  @c_StorerStart    NVARCHAR(15)  
         ,  @c_StorerEnd      NVARCHAR(15) 
         ,  @c_userid         NVARCHAR(20) = ''
  
AS  
BEGIN   
   SET NOCOUNT ON        
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF    
   
   DECLARE @n_continue INT = 1, @n_err INT = 0, @c_errmsg NVARCHAR(255) = '', @b_Success INT = 1
         , @n_StartTCnt INT = @@TRANCOUNT, @c_GetReceiptKey NVARCHAR(10)
   
   IF (@n_continue = 1 OR @n_continue = 2)
   BEGIN
      SELECT R.Receiptkey
           , R.ReceiptDate
           , R.POKey
           , R.StorerKey
           , R.Facility
           , R.ExternReceiptKey
           , RD.Sku
           , S.DESCR
           , RD.UOM
           , SUM(RD.QtyExpected) AS QtyExpected
           , S.Style
      FROM RECEIPT R (NOLOCK)
      JOIN RECEIPTDETAIL RD (NOLOCK)ON R.ReceiptKey = RD.ReceiptKey
      JOIN SKU S (NOLOCK) ON S.StorerKey = R.StorerKey AND S.Sku = RD.Sku
      WHERE R.StorerKey BETWEEN @c_StorerStart AND @c_StorerEnd
      AND R.ReceiptKey BETWEEN @c_ReceiptStart AND @c_ReceiptEnd
      GROUP BY R.Receiptkey
             , R.ReceiptDate
             , R.POKey
             , R.StorerKey
             , R.Facility
             , R.ExternReceiptKey
             , RD.Sku
             , S.DESCR
             , RD.UOM
             , S.Style
      ORDER BY R.ReceiptKey, S.Style, RD.Sku
   END
   
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
  
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_ReceiptPreTallySheet08'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
   END  
   ELSE  
   BEGIN  
      SET @b_Success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         COMMIT TRAN  
      END  
   END  
    
   WHILE @@TRANCOUNT < @n_StartTCnt   
      BEGIN TRAN;     
  
END
GO
GRANT EXECUTE ON [dbo].[isp_ReceiptPreTallySheet08] TO nSQL 
GO
