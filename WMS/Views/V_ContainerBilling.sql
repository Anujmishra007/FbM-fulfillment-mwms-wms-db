SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_ContainerBilling] 
AS 
SELECT [ContainerBillingKey]
, [DocType]
, [ContainerType]
, [Descr]
, [Rate]
, [Base]
, [TaxGroupKey]
, [GLDistributionKey]
, [CostRate]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
FROM [ContainerBilling] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_ContainerBilling] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ContainerBilling] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ContainerBilling] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ContainerBilling] TO [NSQL]
GO
