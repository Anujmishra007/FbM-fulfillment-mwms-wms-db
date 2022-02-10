CREATE TABLE [dbo].[DOCLKUP]
(
[ConsigneeGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SkuGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShelfLife] [int] NULL CONSTRAINT [DF_DOCLKUP_ShelfLife] DEFAULT ((0)),
[DocumentType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DOCLKUP_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DOCLKUP_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DOCLKUP_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DOCLKUP_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DOCLKUP_UserDefine05] DEFAULT (' '),
[UserDefine06] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DOCLKUP_UserDefine06] DEFAULT (' '),
[UserDefine07] [datetime] NULL,
[UserDefine08] [datetime] NULL,
[UserDefine09] [int] NULL,
[UserDefine10] [float] NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_DOCLKUP_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DOCLKUP_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_DOCLKUP_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DOCLKUP_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DOCLKUP] ADD CONSTRAINT [PK_DOCLKUP] PRIMARY KEY CLUSTERED ([ConsigneeGroup], [SkuGroup]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DOCLKUP] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DOCLKUP] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DOCLKUP] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DOCLKUP] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customized. Not for used in standard', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The group in which the consignees are categorized', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'ConsigneeGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The type of the document e.g. Orders for now', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'DocumentType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The shelf life of the SKU which normally works together with the Consignee group and SKU group', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'ShelfLife'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The product group', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'SkuGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 1', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 2', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 3', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 4', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 5', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 6', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 7', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 8', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 9', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined 10', 'SCHEMA', N'dbo', 'TABLE', N'DOCLKUP', 'COLUMN', N'UserDefine10'
GO
