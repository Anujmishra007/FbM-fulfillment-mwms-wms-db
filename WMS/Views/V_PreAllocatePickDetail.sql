SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_PreAllocatePickDetail]
AS
SELECT [PreAllocatePickDetailKey]
, [OrderKey]
, [OrderLineNumber]
, [Storerkey]
, [Sku]
, [Lot]
, [UOM]
, [UOMQty]
, [Qty]
, [Packkey]
, [WaveKey]
, [PreAllocateStrategyKey]
, [PreAllocatePickCode]
, [DoCartonize]
, [PickMethod]
, [RunKey]
, [EffectiveDate]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [PreAllocatePickDetail] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_PreAllocatePickDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PreAllocatePickDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PreAllocatePickDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PreAllocatePickDetail] TO [NSQL]
GO
