SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_AllocateStrategy] 
AS 
SELECT [AllocateStrategyKey]
, [Descr]
, [RetryIfQtyRemain]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [AllocateStrategy] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_AllocateStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_AllocateStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_AllocateStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_AllocateStrategy] TO [NSQL]
GO
