SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_CLPDETAIL] 
AS 
SELECT [CLPOrderKey]
, [CLPOrderLineNumber]
, [POKey]
, [POLineNumber]
, [Qty]
, [CaseId]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [TimeStamp]
FROM [CLPDETAIL] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_CLPDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_CLPDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_CLPDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_CLPDETAIL] TO [NSQL]
GO
