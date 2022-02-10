CREATE TABLE [dbo].[WMSFieldsList]
(
[ProcessID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMSFieldsList_ProcessID] DEFAULT (' '),
[FieldID] [int] NOT NULL,
[ColID] [int] NOT NULL,
[ColName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMSFieldsList_ColName] DEFAULT (' '),
[AddDate] [datetime] NULL CONSTRAINT [DF_WMSFieldsList_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WMSFieldsList_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WMSFieldsList_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WMSFieldsList_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WMSFieldsList] ADD CONSTRAINT [PK_WMSFieldsList] PRIMARY KEY CLUSTERED ([ProcessID], [FieldID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Seq_ind] ON [dbo].[WMSFieldsList] ([ProcessID], [ColName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMSFieldsList] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMSFieldsList] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMSFieldsList] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMSFieldsList] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSFieldsList', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMSFieldsList', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSFieldsList', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMSFieldsList', 'COLUMN', N'EditWho'
GO
