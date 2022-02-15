SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/***************************************************************************/
--[CN] Create new BI view for Jreport https://jiralfl.atlassian.net/browse/WMS-15982
/* Date         Author      Ver.  Purposes                                 */
/* 06-Jan-2021  KHLim       1.0   Created                                  */
/***************************************************************************/

CREATE   VIEW [BI].[V_RDTReport]  AS  
SELECT *
FROM RDT.RDTReport WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_RDTReport] TO [JReportRole]
GO
