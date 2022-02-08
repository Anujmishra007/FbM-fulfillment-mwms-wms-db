CREATE TABLE [dbo].[WAVEDETAIL]
(
[WaveDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVEDETAIL_OrderKey] DEFAULT (' '),
[ProcessFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVEDETAIL_ProcessFlag] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WAVEDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVEDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WAVEDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVEDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WAVEDETAIL] ADD CONSTRAINT [PKWAVEDETAIL] PRIMARY KEY CLUSTERED ([WaveDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WAVEDETAIL_OrderKey] ON [dbo].[WAVEDETAIL] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WAVEDETAIL_WaveKey] ON [dbo].[WAVEDETAIL] ([WaveKey], [WaveDetailKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[WAVEDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[WAVEDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WAVEDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WAVEDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WAVEDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave Detail.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'WaveDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'WaveKey'
GO
