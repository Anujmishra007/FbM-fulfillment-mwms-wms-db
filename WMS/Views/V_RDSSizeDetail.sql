SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_RDSSizeDetail]
as
SElect
RDSSizeLine	,
SeqNo	,
Storerkey	,
SizeCode	,
Sizes	,
Measurement	,
AddDate	,
AddWho	,
EditDate	,
EditWho	,
ArchiveCop	,
TrafficCop
FROM RDSSizeDetail with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_RDSSizeDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_RDSSizeDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_RDSSizeDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_RDSSizeDetail] TO [NSQL]
GO
