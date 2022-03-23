SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_AccessorialDetail]
AS
SELECT [Accessorialkey]
, [AccessorialDetailkey]
, [Descrip]
, [Rate]
, [Base]
, [MasterUnits]
, [UomShow]
, [TaxGroupKey]
, [GLDistributionKey]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [Timestamp]
, [CostRate]
, [CostBase]
, [CostMasterUnits]
, [CostUOMShow]
FROM [AccessorialDetail] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_AccessorialDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_AccessorialDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_AccessorialDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_AccessorialDetail] TO [NSQL]
GO
