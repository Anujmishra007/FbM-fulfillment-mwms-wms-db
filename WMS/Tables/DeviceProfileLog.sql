CREATE TABLE [dbo].[DeviceProfileLog]
(
[DeviceProfileKey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_DeviceProfileLog_DeviceProfileKey] DEFAULT (''),
[DeviceProfileLogKey] [nvarchar] (10) NOT NULL,
[OrderKey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_DeviceProfileLog_OrderKey] DEFAULT (' '),
[DropID] [nvarchar] (20) NOT NULL CONSTRAINT [DF_DeviceProfileLog_DropID] DEFAULT ('0'),
[Status] [nvarchar] (10) NOT NULL CONSTRAINT [DF_DeviceProfileLog_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_DeviceProfileLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_DeviceProfileLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_DeviceProfileLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_DeviceProfileLog_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) NULL,
[UserDefine01] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine05] DEFAULT (' '),
[UserDefine06] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine06] DEFAULT (' '),
[UserDefine07] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine07] DEFAULT (' '),
[UserDefine08] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) NOT NULL CONSTRAINT [DF_DeviceProfileLog_UserDefine10] DEFAULT (' '),
[ConsigneeKey] [nvarchar] (15) NULL CONSTRAINT [DF_DeviceProfileLog_ConsigneeKey] DEFAULT (''),
[RowRef] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO

--DISABLE TRIGGER [dbo].[ntrDeviceProfileLogUpdate] ON [dbo].[DeviceProfileLog]
--GO
ALTER TABLE [dbo].[DeviceProfileLog] ADD CONSTRAINT [PK_DeviceProfileLog] PRIMARY KEY CLUSTERED ([DeviceProfileKey], [DeviceProfileLogKey], [OrderKey], [DropID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DeviceProfileLog_DropID] ON [dbo].[DeviceProfileLog] ([DropID], [OrderKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DeviceProfileLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DeviceProfileLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DeviceProfileLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DeviceProfileLog] TO [NSQL]
GO
