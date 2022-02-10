SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_PutawayTask] 
AS 
SELECT [Transkey]
, [TaskDetailKey]
, [ID]
, [SKU]
, [FromLoc]
, [ToLoc]
, [Status]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
FROM [PutawayTask] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_PutawayTask] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PutawayTask] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PutawayTask] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PutawayTask] TO [NSQL]
GO
