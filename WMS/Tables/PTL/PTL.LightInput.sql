CREATE TABLE [PTL].[LightInput]
(
[SerialNo] [bigint] NOT NULL IDENTITY(1, 1),
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DevicePosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InputStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InputData] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightInput_InputData] DEFAULT (''),
[OutputData] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightInput_OutputData] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightInput_Status] DEFAULT ('0'),
[ErrorMessage] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightInput_ErrorMessage] DEFAULT (''),
[NoOfTry] [int] NULL CONSTRAINT [DF_LightInput_NoOfTry] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LightInput_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LightInput_EditDate] DEFAULT (getdate()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [PTL].[LightInput] ADD CONSTRAINT [PK_LightInput] PRIMARY KEY CLUSTERED ([SerialNo]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
GRANT DELETE ON  [PTL].[LightInput] TO [NSQL]
GO
GRANT INSERT ON  [PTL].[LightInput] TO [NSQL]
GO
GRANT SELECT ON  [PTL].[LightInput] TO [NSQL]
GO
GRANT UPDATE ON  [PTL].[LightInput] TO [NSQL]
GO
