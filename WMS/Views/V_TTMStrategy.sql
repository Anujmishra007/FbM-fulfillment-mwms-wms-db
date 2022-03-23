SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_TTMStrategy]
AS
SELECT [TTMStrategyKey]
, [Descr]
, [InterleaveTasks]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [TTMStrategy] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_TTMStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TTMStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TTMStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TTMStrategy] TO [NSQL]
GO
