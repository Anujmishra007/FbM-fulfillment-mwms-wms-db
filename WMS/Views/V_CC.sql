SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_CC]
AS
SELECT [CCKey]
, [Storerkey]
, [Sku]
, [Loc]
, [TaskDetailKey]
, [Status]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [Timestamp]
, [Facility]
FROM [CC] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_CC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_CC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_CC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_CC] TO [NSQL]
GO
