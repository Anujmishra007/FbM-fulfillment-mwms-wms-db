CREATE TABLE [PTL].[LFLightLinkLOG]
(
[SerialNo] [int] NOT NULL IDENTITY(1, 1),
[Application] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocalEndPoint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RemoteEndPoint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceIPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LFLightLinkLOG_DeviceIPAddress] DEFAULT (''),
[SourceKey] [bigint] NULL CONSTRAINT [DF_LFLightLinkLOG_SourceKey] DEFAULT ((0)),
[MessageType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Data] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACKData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LFLightLinkLOG_ACKData] DEFAULT (''),
[StartTime] [datetime] NULL,
[EndTime] [datetime] NULL,
[ErrMsg] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LFLightLinkLOG_Status] DEFAULT ('0'),
[NoOfTry] [int] NOT NULL CONSTRAINT [DF_LFLightLinkLOG_NoOfTry] DEFAULT ((0)),
[EmailSent] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LFLightLinkLOG_EmailSent] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LFLightLinkLOG_AddDate] DEFAULT (getdate()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [PTL].[LFLightLinkLOG] ADD CONSTRAINT [PK_LFLightLinkLOG] PRIMARY KEY CLUSTERED ([SerialNo]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
GRANT DELETE ON  [PTL].[LFLightLinkLOG] TO [NSQL]
GO
GRANT INSERT ON  [PTL].[LFLightLinkLOG] TO [NSQL]
GO
GRANT SELECT ON  [PTL].[LFLightLinkLOG] TO [NSQL]
GO
GRANT UPDATE ON  [PTL].[LFLightLinkLOG] TO [NSQL]
GO
