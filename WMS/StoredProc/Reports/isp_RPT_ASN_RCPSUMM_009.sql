SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure:isp_RPT_ASN_RCPSUMM_009                              */
/* Creation Date: 08-May-2023                                            */
/* Copyright: Maersk                                                     */
/* Written by: WZPang                                                    */
/*                                                                       */
/* Purpose: WMS-22403                                                    */
/*                                                                       */
/* Called By: RPT_ASN_RCPSUMM_009                                        */
/*                                                                       */
/* GitLab Version: 1.0                                                   */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author  Ver   Purposes                                    */
/* 08-May-2023 WZPang  1.0   DevOps Combine Script                       */
/*************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_ASN_RCPSUMM_009]
(@c_Receiptkey NVARCHAR(10))
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET ANSI_DEFAULTS OFF

   SELECT RECEIPTDETAIL.Sku
        , RECEIPTDETAIL.QtyReceived
        , RECEIPTDETAIL.EditDate
        , RECEIPTDETAIL.ToLoc
        , RECEIPTDETAIL.ToId
        , RECEIPTDETAIL.ToLot
        , RECEIPTDETAIL.PutawayLoc
        , RECEIPTDETAIL.POKey
        , RECEIPT.ReceiptKey
        , RECEIPT.ExternReceiptKey
        , RECEIPT.Status
        , SKU.DESCR
        , PACK.PackUOM1
        , PACK.CaseCnt
        , PACK.PackUOM3
        , STORER.Company
        , RECEIPT.Facility             
        , PA_QTY = CASE RECEIPTDETAIL.PutawayLoc
                        WHEN ' ' THEN 0
                        ELSE RECEIPTDETAIL.QtyReceived END
        , RECEIPT.AddWho               
        , RECEIPT.FinalizeDate         
        , RECEIPT.AddDate              
        , RECEIPT.StorerKey            
        , RECEIPT.ReceiptDate          
        , RECEIPT.SellerName           
        , RECEIPTDETAIL.Lottable03     
        , RECEIPTDETAIL.QtyExpected    
        , RECEIPTDETAIL.ConditionCode
        , LOTXLOCXID.Loc
   FROM RECEIPTDETAIL (NOLOCK)
      , RECEIPT (NOLOCK)
      , STORER (NOLOCK)
      , PACK (NOLOCK)
      , LOC (NOLOCK)
      , SKU (NOLOCK)
      , LOTXLOCXID (NOLOCK)
   WHERE (SKU.StorerKey = RECEIPTDETAIL.StorerKey)
   AND   (SKU.Sku = RECEIPTDETAIL.Sku)
   AND   (SKU.PACKKey = PACK.PackKey)
   AND   (RECEIPTDETAIL.StorerKey = STORER.StorerKey)
   AND   (LOC.Loc = RECEIPTDETAIL.ToLoc)
   AND   (RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey)
   AND   (RECEIPT.ReceiptKey = @c_Receiptkey)
   AND   (LOTXLOCXID.Id = RECEIPTDETAIL.ToId AND LOTXLOCXID.Qty > 0)
   GROUP BY RECEIPTDETAIL.Sku
          , RECEIPTDETAIL.QtyReceived
          , RECEIPTDETAIL.EditDate
          , RECEIPTDETAIL.ToLoc
          , RECEIPTDETAIL.ToId
          , RECEIPTDETAIL.ToLot
          , RECEIPTDETAIL.PutawayLoc
          , RECEIPTDETAIL.POKey
          , RECEIPT.ReceiptKey
          , RECEIPT.ExternReceiptKey
          , RECEIPT.Status
          , SKU.DESCR
          , PACK.PackUOM1
          , PACK.CaseCnt
          , PACK.PackUOM3
          , STORER.Company
          , RECEIPT.Facility        
          , RECEIPT.AddWho               
          , RECEIPT.FinalizeDate         
          , RECEIPT.AddDate              
          , RECEIPT.StorerKey            
          , RECEIPT.ReceiptDate          
          , RECEIPT.SellerName           
          , RECEIPTDETAIL.Lottable03     
          , RECEIPTDETAIL.QtyExpected    
          , RECEIPTDETAIL.ConditionCode
          , LOTXLOCXID.Loc

END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_RCPSUMM_009] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_RCPSUMM_009] TO [LogiReportRoleWM]
GO