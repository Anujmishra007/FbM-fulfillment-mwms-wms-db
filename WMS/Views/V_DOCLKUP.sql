SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_DOCLKUP]
AS
SELECT [ConsigneeGroup]
, [SkuGroup]
, [ShelfLife]
, [DocumentType]
, [UserDefine01]
, [UserDefine02]
, [UserDefine03]
, [UserDefine04]
, [UserDefine05]
, [UserDefine06]
, [UserDefine07]
, [UserDefine08]
, [UserDefine09]
, [UserDefine10]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
FROM [DOCLKUP] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_DOCLKUP] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_DOCLKUP] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_DOCLKUP] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_DOCLKUP] TO [NSQL]
GO
