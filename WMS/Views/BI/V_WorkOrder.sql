SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* TH - LogiReport(JReport) - Add view to BI Schema						*/
/* https://jiralfl.atlassian.net/browse/WMS-23519							*/
/* Date         Author      Ver.  Purposes									*/
/* 30-Aug-2023  ZiWei    1.0   Created									*/
/****************************************************************************/
CREATE OR ALTER VIEW [BI].[V_WorkOrder] AS
SELECT *
FROM dbo.V_WorkOrder WITH (NOLOCK)
GO

GRANT SELECT ON  [BI].[V_WorkOrder] TO [JReportRole]
GO

/*
EXECUTE AS LOGIN ='JREPORTUSERTH'

SELECT SUSER_SNAME(), USER_NAME()

SELECT * FROM [BI].[V_WorkOrder]

REVERT

SELECT TOP 99 * FROM ExecutionLog ORDER BY 1 DESC

*/
