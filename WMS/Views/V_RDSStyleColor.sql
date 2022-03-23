SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_RDSStyleColor]
as
SElect
LinesNo	,
Storerkey	,
Style	,
Color	,
Descr	,
Status	,
AddDate	,
AddWho	,
EditDate	,
EditWho	,
ArchiveCop	,
TrafficCop
FROM RDSStyleColor with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_RDSStyleColor] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_RDSStyleColor] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_RDSStyleColor] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_RDSStyleColor] TO [NSQL]
GO
