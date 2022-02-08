CREATE TABLE [RDT].[RDTUser]
(
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FullName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultStorer] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultFacility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultLangCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultMenu] [int] NULL,
[DefaultUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastLogin] [datetime] NULL CONSTRAINT [DF_RDTUser_LastLogin] DEFAULT (getdate()),
[MultiLogin] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUser_MultiLogin] DEFAULT ('Y'),
[DefaultPrinter] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileNo_Display] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUSER_MobileNo_Display] DEFAULT ('Y'),
[Date_Format] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUSER_Date_Format] DEFAULT (' '),
[SQLUserAddDate] [datetime] NULL,
[DefaultPrinter_Paper] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUSER_Active] DEFAULT ('1'),
[DefaultLightColor] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUser_DefaultLightColor] DEFAULT (''),
[DefaultStorerGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTUSER_DefaultStorerGroup] DEFAULT (''),
[VoiceProfileNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultDeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUser_DefaultDeviceID] DEFAULT (''),
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTUSER_AreaKey] DEFAULT (''),
[OPSPosition] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtuser_OPSPosition] DEFAULT (''),
[AllowResumeSession] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUser_AllowResumeSession] DEFAULT (''),
[SCEPrinterGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTUser_SCEPrinterGroup] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTUser] ADD CONSTRAINT [PK_RDTUser] PRIMARY KEY CLUSTERED ([UserName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTUser] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTUser] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTUser] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTUser] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Allow/Disallow Resume RDT User Session', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'AllowResumeSession'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store AreaKey Value', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'AreaKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Default Device ID', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'DefaultDeviceID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Operation Position', 'SCHEMA', N'RDT', 'TABLE', N'RDTUser', 'COLUMN', N'OPSPosition'
GO
