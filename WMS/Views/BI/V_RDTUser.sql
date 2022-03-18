SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/****************************************************************************/
/* [PH] - LogiReport_Add_View in UAT Catalog_15Mar2022						*/
/* https://jiralfl.atlassian.net/browse/WMS-19207							*/
/* Date         Author      Ver.  Purposes									*/
/* 18-Mar-2022  JarekLim    1.0   Created									*/
/****************************************************************************/

CREATE   VIEW [BI].[V_RDTUser] AS 
SELECT *
FROM dbo.V_RDTUser WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_RDTUser] TO [JReportRole]
GO

GRANT SELECT ON  [BI].[V_RDTUser] TO [JReportRole]
GO

/*
EXECUTE AS LOGIN ='JREPORTUSERPH'

SELECT SUSER_SNAME(), USER_NAME()

SELECT * FROM [BI].[V_RDTUser]

REVERT

SELECT TOP 99 * FROM ExecutionLog ORDER BY 1 DESC

*/