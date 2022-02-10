SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_TTMStrategyDetail] 
AS 
SELECT [TTMStrategyKey]
, [TTMStrategyLineNumber]
, [Descr]
, [TaskType]
, [TTMPickCode]
, [TTMOverride]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [TTMStrategyDetail] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_TTMStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TTMStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TTMStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TTMStrategyDetail] TO [NSQL]
GO
