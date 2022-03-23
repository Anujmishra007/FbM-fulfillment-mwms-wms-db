SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* New View required for J report											*/
/* https://jiralfl.atlassian.net/browse/WMS-16190							*/
/* Date         Author      Ver.  Purposes									*/
/* 25-Jan-2021  BLLim       1.0   Created									*/
/****************************************************************************/
CREATE OR ALTER VIEW [BI].[V_RDTPPA] AS
SELECT *
FROM RDT.RDTPPA WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_RDTPPA] TO [JReportRole]
GO
