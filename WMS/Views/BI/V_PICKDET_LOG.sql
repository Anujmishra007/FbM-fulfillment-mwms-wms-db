SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/***************************************************************************/
--[IN] HM Add New BI View - PICKDET_LOG on JReport https://jiralfl.atlassian.net/browse/WMS-15677
/* Date         Author      Ver.  Purposes                                 */
/* 10-Nov-2020  KHLim       1.1   Created                                  */
/***************************************************************************/

CREATE   VIEW [BI].[V_PICKDET_LOG]  AS  
SELECT *
FROM dbo.PICKDET_LOG WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_PICKDET_LOG] TO [JReportRole]
GO
