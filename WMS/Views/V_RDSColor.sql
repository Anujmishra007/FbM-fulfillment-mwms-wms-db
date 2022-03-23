SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_RDSColor]
as
SElect
RDSColorLine	,
Storerkey	,
ColorCode	,
AddDate	,
AddWho	,
EditDate	,
EditWho	,
ArchiveCop	,
TrafficCop
FROM RDSColor with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_RDSColor] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_RDSColor] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_RDSColor] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_RDSColor] TO [NSQL]
GO
