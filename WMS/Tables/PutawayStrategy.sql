CREATE TABLE [dbo].[PutawayStrategy]
(
[PutawayStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategy_Descr] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayStrategy_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategy_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayStrategy_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategy_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PutawayStrategy] ADD CONSTRAINT [PKPutawayStrategy] PRIMARY KEY CLUSTERED ([PutawayStrategyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PutawayStrategy] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PutawayStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PutawayStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PutawayStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PutawayStrategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A putaway sub strategy controls how the system determines generating putaway tasks. This header table contains the key to the putaway sub strategy and a description of what it does or how it applies to the facilityÆs operations.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a description of the putaway sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a unique code identifying the putaway sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'PutawayStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategy', 'COLUMN', N'TrafficCop'
GO
