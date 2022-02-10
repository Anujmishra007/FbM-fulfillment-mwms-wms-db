SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--https://jiralfl.atlassian.net/browse/WMS-11749
CREATE VIEW [dbo].[V_rdtSortLaneLocLog]
AS
SELECT * 
FROM RDT.rdtSortLaneLocLog WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_rdtSortLaneLocLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_rdtSortLaneLocLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_rdtSortLaneLocLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_rdtSortLaneLocLog] TO [NSQL]
GO
