SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_RPT_ASN_TALLYSHT_003_1                              */
/* Platform: V2                                                         */
/* Creation Date: 29-Feb-2024                                           */
/* Copyright: Maersk                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-24973 - Migrate tallysheet r_receipt_tallysheet24 to    */
/*          Logireport                                                  */
/*                                                                      */
/* Called By: RPT_ASN_TALLYSHT_003                                      */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 29-Feb-2024 WLChooi  1.0   DevOps Combine Script                     */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_ASN_TALLYSHT_003_1]
(
   @c_Receiptkey NVARCHAR(10)
 , @c_POKey      NVARCHAR(18) = ''
 , @c_Username   NVARCHAR(250) = ''
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue INT = 1

   SELECT RECEIPT.StorerKey
        , RECEIPT.ReceiptKey
        , RECEIPT.Facility
        , [dbo].[fnc_ConvSFTimeZone](RECEIPT.StorerKey, RECEIPT.Facility, RECEIPT.EditDate) AS EditDate
        , PO.SellerName
        , PO.SellerAddress1
        , RECEIPTDETAIL.Lottable02
        , RECEIPTDETAIL.Sku
        , SKU.DESCR
        , RECEIPTDETAIL.UOM
        , ISNULL(RECEIPTDETAIL.QtyExpected, 0) AS QtyExpected
        , ISNULL(RECEIPTDETAIL.QtyReceived, 0) AS QtyReceived
        , ISNULL(@c_Username, '') AS Username
        , RECEIPTDETAIL.ExternReceiptKey
        , RECEIPTDETAIL.POKey
        , RECEIPTDETAIL.PackKey
        , SKU.Size
        , RECEIPT.RECType
        , CONVERT(NVARCHAR(250), RECEIPT.Notes) AS Notes
        , RECEIPT.ReceiptKey + ISNULL(RECEIPTDETAIL.POKey, '') AS Group1
        , Discrepancy = IIF(ISNULL(RECEIPTDETAIL.QtyReceived, 0) - ISNULL(RECEIPTDETAIL.QtyExpected, 0) > 0, '+', '')
                      + CAST(ISNULL(RECEIPTDETAIL.QtyReceived, 0) - ISNULL(RECEIPTDETAIL.QtyExpected, 0) AS NVARCHAR)
        , COUNT(DISTINCT RECEIPTDETAIL.SKU) AS TotalSKU
        , SUM(RECEIPTDETAIL.QtyExpected) AS TotalQty
        , [dbo].[fnc_ConvSFTimeZone](RECEIPT.StorerKey, RECEIPT.Facility, GETDATE()) AS CurrentDateTime
   FROM RECEIPT WITH (NOLOCK)
   JOIN RECEIPTDETAIL WITH (NOLOCK) ON (RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey)
   JOIN SKU WITH (NOLOCK) ON (RECEIPTDETAIL.Sku = SKU.Sku AND RECEIPTDETAIL.StorerKey = SKU.StorerKey)
   LEFT OUTER JOIN PO WITH (NOLOCK) ON (RECEIPTDETAIL.POKey = PO.POKey)
   WHERE RECEIPT.ReceiptKey = @c_Receiptkey
   AND RECEIPTDETAIL.POKey = @c_POKey
   GROUP BY RECEIPT.StorerKey
          , RECEIPT.ReceiptKey
          , RECEIPT.Facility
          , RECEIPT.EditDate
          , PO.SellerName
          , PO.SellerAddress1
          , RECEIPTDETAIL.Lottable02
          , RECEIPTDETAIL.Sku
          , SKU.DESCR
          , RECEIPTDETAIL.UOM
          , ISNULL(RECEIPTDETAIL.QtyExpected, 0)
          , ISNULL(RECEIPTDETAIL.QtyReceived, 0)
          , RECEIPTDETAIL.ExternReceiptKey
          , RECEIPTDETAIL.POKey
          , RECEIPTDETAIL.PackKey
          , SKU.Size
          , RECEIPT.RECType
          , CONVERT(NVARCHAR(250), RECEIPT.Notes)
          , ISNULL(RECEIPTDETAIL.POKey, '')
          , RECEIPT.Facility
END