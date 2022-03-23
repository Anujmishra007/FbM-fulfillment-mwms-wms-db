SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_LoadPlanRetDetail]
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
