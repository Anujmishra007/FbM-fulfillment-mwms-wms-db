CREATE OR ALTER VIEW dbo.V_ASN_Total_Expected_Received_Qty AS
SELECT
    ReceiptKey,
    SUM(QtyExpected) AS TotalExpectedQty,
    SUM(QtyReceived+BeforeReceivedQty)  AS TotalReceivedQty
FROM
    RECEIPTDETAIL (NOLOCK)
GROUP BY
    ReceiptKey;