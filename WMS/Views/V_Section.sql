SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_Section]
AS
SELECT [SectionKey]
, [Descr]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [Section] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_Section] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_Section] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_Section] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_Section] TO [NSQL]
GO
