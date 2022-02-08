SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [BI].[V_TH_BONC_Inboundreport] AS 
SELECT
   R.StorerKey,
   R.POKey,
   R.ExternReceiptKey,
   RD.Sku,
   S.DESCR,
   RD.QtyExpected,
   RD.QtyReceived,
   RD.ToId,
   case
      when
         RD.Lottable01 = 'UR' 
      then
         'Saleable' 
      else
         RD.Lottable01 
   end AS 'Status'
, RD.Lottable02, RD.Lottable03, RD.Lottable04, RD.Lottable05 
FROM dbo.RECEIPT R with (nolock)
JOIN dbo.RECEIPTDETAIL RD with (nolock) ON R.ReceiptKey = RD.ReceiptKey 
      AND R.StorerKey = RD.StorerKey 
JOIN dbo.SKU S with (nolock) ON RD.Sku = S.Sku 
      AND RD.StorerKey = S.StorerKey
WHERE R.StorerKey = 'BONC' 
AND convert(varchar, R.EditDate, 112) >= convert(varchar, getdate() - 1, 112) 
AND R.ASNStatus = '9'
GO
GRANT SELECT ON  [BI].V_TH_BONC_Inboundreport TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JReportUserTH'
SELECT SUSER_SNAME()
SELECT * FROM [BI].[V_TH_BONC_Inboundreport]

REVERT;
*/