SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--https://jiralfl.atlassian.net/browse/WMS-14815

CREATE  VIEW  [BI].[V_rdtSortAndPackLOC]
AS
SELECT * 
FROM RDT.rdtSortAndPackLOC WITH (NOLOCK)
GO
GRANT SELECT ON  [BI].[V_rdtSortAndPackLOC] TO [JReportRole]
GO
