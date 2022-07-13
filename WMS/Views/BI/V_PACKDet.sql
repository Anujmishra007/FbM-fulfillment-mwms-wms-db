SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************************/
--CN Jreport Add View to BI Schema https://jiralfl.atlassian.net/browse/WMS-20125
/* Date           Author      Ver.  Purposes									          */
/* 01-JUL-2022   TyrionYu     1.0   Raise Ticket									      */
/* 06-JUL-2022   JarekLim     1.1   Create BI view                                        */
/******************************************************************************************/
CREATE OR ALTER VIEW [BI].[V_PACKDet] AS
SELECT *
  FROM dbo.PACKDet WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_PACKDet] TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JREPORTUSERCN'

SELECT SUSER_SNAME()

SELECT top 999 * FROM [BI].[V_PACKDet]
revert;
*/


