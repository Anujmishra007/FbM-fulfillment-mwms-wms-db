SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
--[CN] Create new BI view for Jreport https://jiralfl.atlassian.net/browse/WMS-19447
/* Date           Author      Ver.  Purposes                               */
/* 26-April-2021  JarekLim    1.0   Created                                */
/***************************************************************************/
CREATE OR ALTER VIEW [BI].[V_BUILDPARM]  AS
SELECT *
FROM dbo.BUILDPARM WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_BUILDPARM] TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JReportUserCN'

SELECT SUSER_SNAME()

SELECT * FROM [BI].[V_BUILDPARM]
revert;
*/

