CREATE TABLE [dbo].[PTLTrafficDetail]
(
[UserID] [nvarchar] (128) NOT NULL,
[PTLKey] [bigint] NOT NULL,
[MonitorID] [nvarchar] (20) NOT NULL,
[USERNO] [int] NOT NULL CONSTRAINT [DF_PTLTrafficDetail_USERNO] DEFAULT ('0'),
[TrafficData] [nvarchar] (max) NULL CONSTRAINT [DF_PTLTrafficDetail_TrafficData] DEFAULT (''),
[Status] [nvarchar] (1) NOT NULL CONSTRAINT [DF_PTLTrafficDetail_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_PTLTrafficDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PTLTrafficDetail_AddDate] DEFAULT (getdate()),
[Remarks] [nvarchar] (60) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PTLTrafficDetail] ADD CONSTRAINT [PK_PTLTrafficDetail] PRIMARY KEY CLUSTERED ([PTLKey], [MonitorID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PTLTrafficDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PTLTrafficDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PTLTrafficDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PTLTrafficDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Monitor ID', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'MonitorID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PTL Key', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'PTLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Traffic Data', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'TrafficData'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User ID', 'SCHEMA', N'dbo', 'TABLE', N'PTLTrafficDetail', 'COLUMN', N'UserID'
GO
