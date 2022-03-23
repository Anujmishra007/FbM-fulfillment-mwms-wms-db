SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_TariffDetail]
AS
SELECT [TariffDetailKey]
, [TariffKey]
, [ChargeType]
, [Descrip]
, [Rate]
, [Base]
, [MasterUnits]
, [RoundMasterUnits]
, [UOMShow]
, [TaxGroupKey]
, [GLDistributionKey]
, [MinimumCharge]
, [MinimumGroup]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [CostRate]
, [CostBase]
, [CostMasterUnits]
, [CostUOMShow]
, [UOM1Mult]
, [UOM2Mult]
, [UOM3Mult]
, [UOM4Mult]
FROM [TariffDetail] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_TariffDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TariffDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TariffDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TariffDetail] TO [NSQL]
GO
