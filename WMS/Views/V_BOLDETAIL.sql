SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_BOLDETAIL] 
AS 
SELECT [BolKey]
, [BolLineNumber]
, [OrderKey]
, [Description]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [TimeStamp]
FROM [BOLDETAIL] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_BOLDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_BOLDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_BOLDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_BOLDETAIL] TO [NSQL]
GO
