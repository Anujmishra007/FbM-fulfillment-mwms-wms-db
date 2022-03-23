SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_PreAllocateStrategyDetail]
AS
SELECT [PreAllocateStrategyKey]
, [PreAllocateStrategyLineNumber]
, [DESCR]
, [UOM]
, [PreAllocatePickCode]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [PreAllocateStrategyDetail] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_PreAllocateStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PreAllocateStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PreAllocateStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PreAllocateStrategyDetail] TO [NSQL]
GO
