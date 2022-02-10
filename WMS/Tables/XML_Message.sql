CREATE TABLE [dbo].[XML_Message]
(
[RowID] [bigint] NOT NULL IDENTITY(1, 1),
[BatchNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Server_IP] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XML_Message_Server_IP] DEFAULT (''),
[Server_Port] [int] NULL CONSTRAINT [DF_XML_Message_Server_Port] DEFAULT ((0)),
[XML_Message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XML_Message_XML_Message] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XML_Message_Status] DEFAULT ('0'),
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XML_Message_RefNo] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_XML_Message_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XML_Message_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_XML_Message_EditDate] DEFAULT (getdate()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XML_Message] ADD CONSTRAINT [PK_XML_Message] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_XML_Message_01] ON [dbo].[XML_Message] ([BatchNo], [RowID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[XML_Message] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[XML_Message] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[XML_Message] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[XML_Message] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'XML_Message', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'XML_Message', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'XML_Message', 'COLUMN', N'EditDate'
GO
