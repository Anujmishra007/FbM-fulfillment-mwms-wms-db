SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_RDSSize]
as
SElect
RDSSizeLine	,
Storerkey	,
SizeCode	,
AddDate	,
AddWho	,
EditDate	,
EditWho	,
ArchiveCop	,
TrafficCop
FROM RDSSize with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_RDSSize] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_RDSSize] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_RDSSize] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_RDSSize] TO [NSQL]
GO
