SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* [PH] - LogiReport_Add_View in UAT Catalog_09Mar2022						*/
/* https://jiralfl.atlassian.net/browse/WMS-19129							*/
/* Date         Author      Ver.  Purposes									*/
/* 11-Mar-2022  JarekLim    1.0   Created									*/
/****************************************************************************/
CREATE OR ALTER VIEW [BI].[V_RDTLoginLog] AS
SELECT *
FROM RDT.RDTLoginLog WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_RDTLoginLog] TO [JReportRole]
GO

/*  Test view, permission, performance, results
EXECUTE AS LOGIN = 'JReportUserPH';  -- Set the execution context to JReport User.

SELECT SUSER_SNAME()

SELECT top 999 *
FROM BI.V_RDTLoginLog

REVERT;

sp_refreshview 'BI.V_RDTLoginLog'
*/
