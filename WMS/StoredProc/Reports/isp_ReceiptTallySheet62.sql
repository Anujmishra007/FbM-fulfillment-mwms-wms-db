IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_ReceiptTallySheet62]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_ReceiptTallySheet62]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Proc: isp_ReceiptTallySheet62                                 */  
/* Creation Date: 17-Jun-2019                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: WMS-9446 SG - THG - Inbound Tally Sheet                     */   
/*        :                                                             */  
/* Called By: r_receipt_tallysheet62                                    */
/*            copy from r_receipt_tallysheet50                          */  
/*          :                                                           */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver Purposes                                  */  
/************************************************************************/ 

CREATE PROC [dbo].[isp_ReceiptTallySheet62]  
            @c_ReceiptKeyStart   NVARCHAR(10)  
         ,  @c_ReceiptKeyEnd     NVARCHAR(10)  
         ,  @c_StorerKeyStart    NVARCHAR(15)  
         ,  @c_StorerKeyEnd      NVARCHAR(15) 
       ,  @c_UserID            NVARCHAR(80) = ''
  
AS  
BEGIN   
   SET NOCOUNT ON        
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF    
  
    SELECT STORER.Company,
        RECEIPT.ReceiptKey,  
         ISNULL(RECEIPT.CarrierReference,'') as CarrierReference,
         RECEIPT.StorerKey, 
         RECEIPT.CarrierName,
         RECEIPT.Editwho,
         RECEIPT.ReceiptDate,
         RECEIPTDETAIL.Sku,
         RECEIPTDETAIL.Lottable02,
         SKU.DESCR,
         RECEIPTDETAIL.Lottable04,
         RECEIPTDETAIL.UOM,
         SUM(RECEIPTDETAIL.QtyExpected) AS QtyExp,
         RECEIPT.CarrierAddress1,
         RECEIPT.POkey,
         RECEIPTDETAIL.Lottable03,
         ISNULL(RECEIPT.Signatory,'') AS Signatory,
         RECEIPT.Userdefine01,
         RECEIPT.Facility,
         RECEIPTDETAIL.lottable01,
         RECEIPT.Containerkey, 
         RECEIPT.ContainerType AS containertype,  
         RECEIPTDETAIL.ReceiptLinenumber,--
         CASE WHEN ISNULL(SKU.BUSR9,'') in ('Yes','Y') THEN 'OLD' ELSE 'NEW' END AS SkuFlag,
         SKU.grosswgt as SGrossWgt,
         SKU.Length  as SLength,
       --  CONVERT(CHAR(20),@c_UserID) AS userid,
         RECEIPT.ExternReceiptKey,
         SKU.Width   as SWidth,
         SKU.Height  as SHeight,
         SKU.Shelflife,
         convert(nvarchar(10),DATEADD(DAY,SKU.Shelflife,RECEIPT.ReceiptDate),101) As ExpDate,
         ISNULL(SKU.IVAS,'') AS IVAS,
         SKU.BUSR1
         ,SKU.Putawayzone sku_putawayzone  
         ,RECEIPTDETAIL.AltSku 
    FROM RECEIPT (nolock)
         JOIN RECEIPTDETAIL (nolock) ON RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey
         JOIN STORER (nolock) ON RECEIPTDETAIL.StorerKey = STORER.StorerKey
         JOIN SKU (nolock) ON  SKU.StorerKey = RECEIPTDETAIL.StorerKey AND SKU.Sku = RECEIPTDETAIL.Sku
   WHERE ( RECEIPT.ReceiptKey >= @c_ReceiptKeyStart ) AND
         ( REceipt.receiptkey <= @c_ReceiptKeyEnd ) AND
         ( RECEIPT.Storerkey >=  @c_StorerKeyStart ) AND
         ( RECEIPT.Storerkey <=  @c_StorerKeyEnd ) AND
         (RECEIPT.RECType = "NORMAL" OR RECEIPT.RECType = "RETURN")
   GROUP BY STORER.Company,
         RECEIPT.ReceiptKey,
         ISNULL(RECEIPT.CarrierReference,''),
         RECEIPT.StorerKey,
         RECEIPT.CarrierName,
         RECEIPT.ReceiptDate,
         RECEIPTDETAIL.Sku,
         RECEIPTDETAIL.Lottable02,
         SKU.DESCR,
         RECEIPTDETAIL.Lottable04,
         RECEIPTDETAIL.UOM,
         RECEIPT.CarrierAddress1,
         RECEIPT.POkey,
         RECEIPTDETAIL.Lottable03,
         ISNULL(RECEIPT.Signatory,''),
         RECEIPT.Userdefine01,
         RECEIPT.Facility,
         RECEIPTDETAIL.lottable01,
         RECEIPT.Containerkey,
         RECEIPT.ContainerType,
         RECEIPTDETAIL.ReceiptLinenumber,
        -- ISNULL(CLR.Code,''),
         RECEIPT.ExternReceiptKey,
         SKU.Shelflife,
         SKU.IVAS,
         SKU.BUSR1
         ,SKU.Putawayzone
         ,RECEIPTDETAIL.AltSku
         ,RECEIPT.Editwho
         ,CASE WHEN ISNULL(SKU.BUSR9,'') in ('Yes','Y') THEN 'OLD' ELSE 'NEW' END, 
         SKU.grosswgt,
         SKU.Length,
         SKU.Width,
         SKU.Height
    ORDER BY RECEIPT.ReceiptKey, RECEIPTDETAIL.ReceiptLinenumber
  
END
GO
GRANT EXECUTE ON [dbo].[isp_ReceiptTallySheet62] TO nSQL 
GO
