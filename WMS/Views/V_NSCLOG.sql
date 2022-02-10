SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_NSCLOG] 
AS 
SELECT [nsclogkey]
, [tablename]
, [key1]
, [key2]
, [key3]
, [transmitflag]
, [transmitbatch]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [NSCLOG] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_NSCLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_NSCLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_NSCLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_NSCLOG] TO [NSQL]
GO
