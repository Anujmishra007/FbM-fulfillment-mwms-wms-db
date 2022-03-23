SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_Locbak]
AS
SELECT [Loc]
, [LocationType]
, [PutawayZone]
, [InventoryDate]
, [Adddate]
, [Addwho]
, [Editdate]
, [Editwho]
FROM [Locbak] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_Locbak] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_Locbak] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_Locbak] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_Locbak] TO [NSQL]
GO
