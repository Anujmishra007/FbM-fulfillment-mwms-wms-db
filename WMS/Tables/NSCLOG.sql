CREATE TABLE [dbo].[NSCLOG]
(
[nsclogkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_Tablename] DEFAULT (' '),
[key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_Key1] DEFAULT (' '),
[key2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_Key2] DEFAULT (' '),
[key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_Key3] DEFAULT (' '),
[transmitflag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_transmitflag] DEFAULT ('0'),
[transmitbatch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NSCLOG_transmitbatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_NSCLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_NSCLOG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSCLOG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[NSCLOG] ADD CONSTRAINT [PKNSCLOG] PRIMARY KEY CLUSTERED ([nsclogkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NSCLOG_CIdx] ON [dbo].[NSCLOG] ([tablename], [key1], [key2], [key3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[NSCLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[NSCLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[NSCLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[NSCLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying NSC Log.', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'nsclogkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'NSCLOG', 'COLUMN', N'TrafficCop'
GO
