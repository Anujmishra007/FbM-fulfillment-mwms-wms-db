CREATE TABLE [dbo].[DeviceProfile]
(
[DeviceProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_DeviceProfileKey] DEFAULT (''),
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_IPAddress] DEFAULT (' '),
[PortNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_PortNo] DEFAULT (' '),
[DeviceType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_DeviceType] DEFAULT ('0'),
[DeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_DeviceID] DEFAULT ('0'),
[DevicePosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_DevicePosition] DEFAULT ('0'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_DeviceProfile_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_DeviceProfile_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceProfileLogKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DeviceProfile_DeviceProfileLogKey] DEFAULT (''),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DeviceProfile_Priority] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DeviceProfile_StorerKey] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogicalPOS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_LogicalPOS] DEFAULT (''),
[LogicalName] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_LogicalName] DEFAULT (''),
[Col] [int] NOT NULL CONSTRAINT [DF_DeviceProfile_Col] DEFAULT ((0)),
[Row] [int] NOT NULL CONSTRAINT [DF_DeviceProfile_Row] DEFAULT ((0))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeviceProfile] ADD CONSTRAINT [PK_DeviceProfile] PRIMARY KEY CLUSTERED ([DeviceProfileKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_DeviceProfile_Device] ON [dbo].[DeviceProfile] ([DeviceID], [DevicePosition]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DEVICEPROFILE_Loc] ON [dbo].[DeviceProfile] ([Loc]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DeviceProfile] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DeviceProfile] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DeviceProfile] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DeviceProfile] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cart matrix col setup', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'Col'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Link DevicePosition to location table', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Light logical name (easier to key-in, compare to hardware position)', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'LogicalName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Light logical position (for sorting)', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'LogicalPOS'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cart matrix row setup', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'Row'
GO
