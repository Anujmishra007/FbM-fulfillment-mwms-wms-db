SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* [TW] LogiReport Create Views in BI Schema								*/
/* https://jiralfl.atlassian.net/browse/WMS-18479							*/
/* Date         Author      Ver.  Purposes									*/
/* 29-Nov-2021  BLLim       1.0   Created									*/
/****************************************************************************/
CREATE OR ALTER VIEW [BI].[V_RDTMSG]  AS
SELECT *
FROM RDT.RDTMSG WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_RDTMSG] TO [JReportRole]
GO
