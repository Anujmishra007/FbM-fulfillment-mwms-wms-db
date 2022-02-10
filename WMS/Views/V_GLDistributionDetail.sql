SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_GLDistributionDetail] 
AS 
SELECT [GLDistributionKey]
, [GLDistributionLineNumber]
, [ChartofAccountsKey]
, [GLDistributionPct]
, [Descrip]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
FROM [GLDistributionDetail] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_GLDistributionDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_GLDistributionDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_GLDistributionDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_GLDistributionDetail] TO [NSQL]
GO
