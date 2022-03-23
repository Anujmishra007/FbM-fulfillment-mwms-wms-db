SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_TRANSMITLOG2]
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
FROM [TRANSMITLOG2] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_TRANSMITLOG2] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TRANSMITLOG2] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TRANSMITLOG2] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TRANSMITLOG2] TO [NSQL]
GO
