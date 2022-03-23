SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_LOTxBILLDATE]
AS
SELECT [Lot]
, [TariffKey]
, [LotBillThruDate]
, [LastActivity]
, [QtyBilledBalance]
, [QtyBilledGrossWeight]
, [QtyBilledNetWeight]
, [QtyBilledCube]
, [AnniversaryStartDate]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
FROM [LOTxBILLDATE] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_LOTxBILLDATE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_LOTxBILLDATE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_LOTxBILLDATE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_LOTxBILLDATE] TO [NSQL]
GO
