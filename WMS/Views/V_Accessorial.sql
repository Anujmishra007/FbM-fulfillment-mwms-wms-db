SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_Accessorial] 
AS 
SELECT [Accessorialkey]
, [Descrip]
, [SupportFlag]
, [StorerKey]
, [SKU]
, [ServiceKey]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [Timestamp]
FROM [Accessorial] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_Accessorial] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_Accessorial] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_Accessorial] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_Accessorial] TO [NSQL]
GO
