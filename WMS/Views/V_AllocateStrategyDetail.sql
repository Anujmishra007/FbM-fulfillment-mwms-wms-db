SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_AllocateStrategyDetail]
AS
SELECT [AllocateStrategyKey]
, [AllocateStrategyLineNumber]
, [DESCR]
, [UOM]
, [PickCode]
, [LocationTypeOverride]
, [LocationTypeOverRideStripe]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [AllocateStrategyDetail] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_AllocateStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_AllocateStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_AllocateStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_AllocateStrategyDetail] TO [NSQL]
GO
