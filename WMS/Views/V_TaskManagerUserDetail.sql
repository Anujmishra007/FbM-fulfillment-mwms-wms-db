SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_TaskManagerUserDetail] 
AS 
SELECT [UserKey]
, [UserLineNumber]
, [PermissionType]
, [AreaKey]
, [Permission]
, [Descr]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [TaskManagerUserDetail] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_TaskManagerUserDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TaskManagerUserDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TaskManagerUserDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TaskManagerUserDetail] TO [NSQL]
GO
