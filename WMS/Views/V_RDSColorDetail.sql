SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create view [dbo].[V_RDSColorDetail]
as
SElect
RDSColorLine	,
Storerkey	,
SeqNo	,
ColorCode	,
ColorAbbrev	,
Descr	,
AddDate	,
AddWho	,
EditDate	,
EditWho	,
ArchiveCop	,
TrafficCop	
FROM RDSColorDetail with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_RDSColorDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_RDSColorDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_RDSColorDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_RDSColorDetail] TO [NSQL]
GO
