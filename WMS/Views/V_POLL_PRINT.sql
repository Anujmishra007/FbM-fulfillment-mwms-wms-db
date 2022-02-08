SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_POLL_PRINT] 
AS 
SELECT [printtype]
, [orderkey]
, [caseid]
, [dropid]
, [status]
, [EffectiveDate]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [POLL_PRINT] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_POLL_PRINT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_POLL_PRINT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_POLL_PRINT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_POLL_PRINT] TO [NSQL]
GO
