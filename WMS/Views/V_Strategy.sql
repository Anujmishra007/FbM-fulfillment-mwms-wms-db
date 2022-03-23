SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_Strategy]
AS
SELECT [StrategyKey]
, [Descr]
, [PreAllocateStrategyKey]
, [AllocateStrategyKey]
, [ReplenishmentStrategyKey]
, [PutawayStrategyKey]
, [PickStrategyKey]
, [TTMStrategyKey]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [VASStrategyKey]
, [ABCPAStrategyKey]
, [TransferStrategyKey]
FROM [Strategy] (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_Strategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_Strategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_Strategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_Strategy] TO [NSQL]
GO
