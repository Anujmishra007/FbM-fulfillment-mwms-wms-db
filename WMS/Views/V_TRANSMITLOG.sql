SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_TRANSMITLOG] 
AS 
SELECT [transmitlogkey]
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
FROM [TRANSMITLOG] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_TRANSMITLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TRANSMITLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TRANSMITLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TRANSMITLOG] TO [NSQL]
GO
