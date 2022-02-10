SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/****************************************************************************/
/* [TW] LogiReport Create Views in BI Schema								*/
/* https://jiralfl.atlassian.net/browse/WMS-18479							*/
/* Date         Author      Ver.  Purposes									*/
/* 29-Nov-2021  BLLim       1.0   Created									*/
/****************************************************************************/

CREATE   VIEW [BI].[V_RDTWATTEAMLOG]  AS  
SELECT *
FROM RDT.RDTWATTEAMLOG WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_RDTWATTEAMLOG] TO [JReportRole]
GO
