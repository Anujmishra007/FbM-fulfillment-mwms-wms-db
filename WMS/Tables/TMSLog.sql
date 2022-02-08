CREATE TABLE [dbo].[TMSLog]
(
[TMSLogKey] [int] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_Tablename] DEFAULT (' '),
[key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_Key1] DEFAULT (' '),
[key2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_Key2] DEFAULT (' '),
[key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_Key3] DEFAULT (' '),
[TransmitFlag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_TransmitFlag] DEFAULT ('0'),
[TransmitBatch] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_TransmitBatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TMSLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TMSLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMSLog_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TMSLog] ADD CONSTRAINT [PKTMSLog] PRIMARY KEY NONCLUSTERED ([TMSLogKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TMSLOG_CIdx] ON [dbo].[TMSLog] ([TableName], [key1], [key2], [key3]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TMSLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TMSLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TMSLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying TMS Log.', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'TMSLogKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TMSLog', 'COLUMN', N'TrafficCop'
GO
