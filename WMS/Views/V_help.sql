SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_help] 
AS 
SELECT [topic]
, [context]
, [langid]
, [shorthelp]
, [extendedhelpurl]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [help] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_help] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_help] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_help] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_help] TO [NSQL]
GO
