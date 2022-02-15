CREATE TABLE [PTL].[LightStatus]
(
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LightStatus_IPAddress] DEFAULT (''),
[DevicePosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LightStatus_DevicePosition] DEFAULT (''),
[DeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LightStatus_DeviceID] DEFAULT (''),
[Func] [int] NOT NULL CONSTRAINT [DF_LightStatus_Func] DEFAULT ((0)),
[Step] [int] NOT NULL CONSTRAINT [DF_LightStatus_Step] DEFAULT ((0)),
[Status] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LightStatus_Status] DEFAULT ('0'),
[PTLKey] [bigint] NULL,
[PTLType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LightStatus_UserName] DEFAULT (''),
[DisplayValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiveValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LightCmd] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiveTime] [datetime] NULL,
[Remarks] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightStatus_Remarks] DEFAULT (''),
[ErrorMessage] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightStatus_ErrorMessage] DEFAULT (''),
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightStatus_SourceKey] DEFAULT (''),
[DeviceProfileLogKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_LightStatus_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightStatus_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_LightStatus_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightStatus_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [PTL].[LightStatus] ADD CONSTRAINT [PK_PTLLightLog] PRIMARY KEY CLUSTERED ([IPAddress], [DevicePosition]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [PTL].[LightStatus] TO [NSQL]
GO
GRANT INSERT ON  [PTL].[LightStatus] TO [NSQL]
GO
GRANT SELECT ON  [PTL].[LightStatus] TO [NSQL]
GO
GRANT UPDATE ON  [PTL].[LightStatus] TO [NSQL]
GO
