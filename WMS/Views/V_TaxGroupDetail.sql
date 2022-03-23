SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_TaxGroupDetail]
AS
SELECT [TaxGroupKey]
, [TaxRateKey]
, [GLDistributionKey]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
FROM [TaxGroupDetail] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_TaxGroupDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TaxGroupDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TaxGroupDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TaxGroupDetail] TO [NSQL]
GO
