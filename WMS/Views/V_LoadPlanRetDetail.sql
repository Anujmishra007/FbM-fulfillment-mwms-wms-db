SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[V_LoadPlanRetDetail]
AS
SELECT     LoadKey, LoadLineNumber, ReceiptKey, ExternReceiptKey, AddWho, AddDate, EditWho, EditDate, TrafficCop, ArchiveCop, Weight, Cube, 
                      ExternLoadKey, ExternLineNo
FROM         dbo.LoadPlanRetDetail WITH (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_LoadPlanRetDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_LoadPlanRetDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_LoadPlanRetDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_LoadPlanRetDetail] TO [NSQL]
GO
