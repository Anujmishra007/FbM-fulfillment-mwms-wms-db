SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_GLDistribution] 
AS 
SELECT [GLDistributionKey]
, [SupportFlag]
, [Descrip]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
FROM [GLDistribution] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_GLDistribution] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_GLDistribution] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_GLDistribution] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_GLDistribution] TO [NSQL]
GO
