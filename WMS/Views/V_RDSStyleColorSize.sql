SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create view [dbo].[V_RDSStyleColorSize]
as
SElect
SeqNo	,
Storerkey	,
UPC	,
Style	,
Color	,
Sizes	,
Measurement	,
Status	,
AddDate	,
AddWho	,
EditDate	,
EditWho	,
ArchiveCop	,
TrafficCop	
FROM RDSStyleColorSize with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_RDSStyleColorSize] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_RDSStyleColorSize] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_RDSStyleColorSize] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_RDSStyleColorSize] TO [NSQL]
GO
