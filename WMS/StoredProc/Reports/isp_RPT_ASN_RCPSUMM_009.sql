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
/* GitLab Version: 1.1                                                   */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author  Ver   Purposes                                    */
/* 08-May-2023 WZPang  1.0   DevOps Combine Script                       */
/* 29-Aug-2023 WLChooi 1.1   UWP-7322 - Show UDF04 (WL01)                */
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
        , ShowUDF04 = ISNULL(CL.Short,'N')   --WL01 S
        , Userdefine04 = ISNULL(RECEIPT.Userdefine04,'')
   FROM RECEIPTDETAIL (NOLOCK)
   JOIN RECEIPT (NOLOCK) ON (RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey)
   JOIN STORER (NOLOCK) ON (RECEIPT.StorerKey = STORER.StorerKey)
   JOIN SKU (NOLOCK) ON (SKU.StorerKey = RECEIPTDETAIL.StorerKey) AND (SKU.Sku = RECEIPTDETAIL.Sku)
   JOIN PACK (NOLOCK) ON (SKU.PACKKey = PACK.PackKey)
   JOIN LOC (NOLOCK) ON (LOC.Loc = RECEIPTDETAIL.ToLoc)
   JOIN LOTXLOCXID (NOLOCK) ON (LOTXLOCXID.Id = RECEIPTDETAIL.ToId)
   LEFT JOIN CODELKUP CL (NOLOCK) ON CL.Listname = 'REPORTCFG' 
                                 AND CL.Storerkey = RECEIPT.Storerkey 
                                 AND CL.Code = 'ShowUDF04' 
                                 AND CL.Long = 'RPT_ASN_RCPSUMM_009' 
                                 AND CL.Short = 'Y'
   WHERE (RECEIPT.ReceiptKey = @c_Receiptkey)
   AND (LOTXLOCXID.Qty > 0)   --WL01 E
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
          , ISNULL(CL.Short,'N')   --WL01
          , ISNULL(RECEIPT.Userdefine04,'')   --WL01

END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_RCPSUMM_009] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_RCPSUMM_009] TO [LogiReportRoleWM]
GO