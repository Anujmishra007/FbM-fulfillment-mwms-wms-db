CREATE TABLE [dbo].[InterfaceLog]
(
[InterfaceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternSourceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TranCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TranStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TranDate] [datetime] NULL,
[Userdefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InterfaceLog_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InterfaceLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_InterfaceLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InterfaceLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_InterfaceLog_EditDate] DEFAULT (getdate()),
[Msgtext] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[InterfaceLog] ADD CONSTRAINT [PK_InterfaceLog] PRIMARY KEY CLUSTERED ([InterfaceKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INTERFACELOG_SKU] ON [dbo].[InterfaceLog] ([StorerKey], [Sku]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INTERFACELOG_TranCode] ON [dbo].[InterfaceLog] ([TranCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InterfaceLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[InterfaceLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[InterfaceLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[InterfaceLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Source used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'ExternSourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Interface.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'InterfaceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying source.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying transaction.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'TranCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of transaction made.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'TranDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying User.', 'SCHEMA', N'dbo', 'TABLE', N'InterfaceLog', 'COLUMN', N'UserID'
GO
