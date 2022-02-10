SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/***************************************************************************/
--[KR] - JReport_Add_View in PRD Catalog_20210128 https://jiralfl.atlassian.net/browse/WMS-16274
/* Date         Author      Ver.  Purposes                                 */
/* 01-Feb-2021  KHLim       1.0   Created                                  */
/***************************************************************************/

CREATE   VIEW [BI].[V_ReceiptInfo]  AS  
SELECT *
FROM dbo.ReceiptInfo WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_ReceiptInfo] TO [JReportRole]
GO
