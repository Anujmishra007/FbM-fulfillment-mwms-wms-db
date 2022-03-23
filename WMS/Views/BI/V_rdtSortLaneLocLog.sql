SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--https://jiralfl.atlassian.net/browse/WMS-11749
CREATE OR ALTER VIEW [BI].[V_rdtSortLaneLocLog]
AS
SELECT *
FROM RDT.rdtSortLaneLocLog WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_rdtSortLaneLocLog] TO [JReportRole]
GO
