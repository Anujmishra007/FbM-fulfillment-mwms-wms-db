SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/***************************************************************************************/
--TH-Create VIEW on Database (THWMS) on PROD  https://jiralfl.atlassian.net/browse/WMS-18766
/* Date         Author      Ver.  Purposes									                  */
/* 14-Jan-2022  gywong      1.0   Created									                     */
/***************************************************************************************/
CREATE OR ALTER  VIEW [BI].[V_TH_DMCTH_Daily_Reports_Receipt] AS 
SELECT
   R.StorerKey,
   R.Facility,
   R.ReceiptKey,
   R.RECType,
   R.Status,
   R.EditDate,
   R.ExternReceiptKey,
   R.CarrierReference,
   R.CarrierKey,
   R.CarrierName,
   RD.Sku,
   S.DESCR,
   RD.Lottable01,
   RD.Lottable02,
   RD.Lottable04,
   RD.Lottable03,
   RD.Lottable05,
   RD.ToLoc,
   P.PackUOM3,
   P.CaseCnt,
   RD.QtyReceived 

FROM dbo.RECEIPT R with (nolock)
LEFT OUTER JOIN dbo.RECEIPTDETAIL RD with (nolock) ON R.ReceiptKey = RD.ReceiptKey AND R.StorerKey = RD.StorerKey
LEFT OUTER JOIN dbo.SKU S with (nolock) ON RD.StorerKey = S.StorerKey AND RD.Sku = S.Sku
LEFT OUTER JOIN dbo.PACK P with (nolock) ON S.PACKKey = P.PackKey 

WHERE R.StorerKey = 'DMCTH' 
AND  R.ReceiptDate = convert(date, getdate() - 5) 
AND R.Status = '9'

GO

GRANT SELECT ON  [BI].[V_TH_DMCTH_Daily_Reports_Receipt]  TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JReportUserTH'

SELECT SUSER_SNAME()

SELECT * FROM  [BI].[V_TH_DMCTH_Daily_Reports_Receipt] 

revert;
*/



