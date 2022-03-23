SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_PreAllocateStrategy]
AS
SELECT [PreAllocateStrategyKey]
, [Descr]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [PreAllocateStrategy] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_PreAllocateStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PreAllocateStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PreAllocateStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PreAllocateStrategy] TO [NSQL]
GO
