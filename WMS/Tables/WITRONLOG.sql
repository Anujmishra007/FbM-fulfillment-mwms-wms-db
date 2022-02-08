CREATE TABLE [dbo].[WITRONLOG]
(
[WitronLogKey] [int] NOT NULL IDENTITY(1, 1),
[Tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WITRONLOG_Tablename] DEFAULT (' '),
[Key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WITRONLOG_Key1] DEFAULT (' '),
[Key2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WITRONLOG_Key2] DEFAULT (' '),
[Key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WITRONLOG_Key3] DEFAULT (' '),
[TransmitFlag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WITRONLOG_TransmitFlag] DEFAULT ('0'),
[TransmitBatch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WITRONLOG_TransmitBatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WITRONLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WITRONLOG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WITRONLOG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WITRONLOG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WITRONLOG] ADD CONSTRAINT [PKWITRONLOG] PRIMARY KEY CLUSTERED ([WitronLogKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_WITRONLOG_CIdx] ON [dbo].[WITRONLOG] ([Tablename], [Key1], [Key2], [Key3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WITRONLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WITRONLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WITRONLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WITRONLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WITRONLOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WITRONLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WITRONLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WITRONLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WITRONLOG', 'COLUMN', N'TrafficCop'
GO
