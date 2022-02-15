CREATE TABLE [RDT].[rdtSpooler]
(
[SpoolerGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSpooler_Description] DEFAULT (''),
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSpooler_IPAddress] DEFAULT (''),
[PortNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSpooler_PortNo] DEFAULT (''),
[Command] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSpooler_Command] DEFAULT (''),
[IniFilePath] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSpooler_IniFilePath] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSpooler_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSpooler_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSpooler_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSpooler_EditDate] DEFAULT (getdate()),
[Spooler] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSpooler_Spooler] DEFAULT (''),
[TCPSpoolerVersion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSpooler_TCPSpoolerVersion] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtSpooler] ADD CONSTRAINT [PK_rdtSpooler] PRIMARY KEY CLUSTERED ([SpoolerGroup]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtSpooler] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSpooler] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSpooler] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSpooler] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Use by printing thru QCommander', 'SCHEMA', N'RDT', 'TABLE', N'rdtSpooler', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Command that QCommander listener execute when being notify', 'SCHEMA', N'RDT', 'TABLE', N'rdtSpooler', 'COLUMN', N'Command'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Setting file of the QCommander', 'SCHEMA', N'RDT', 'TABLE', N'rdtSpooler', 'COLUMN', N'IniFilePath'
GO
EXEC sp_addextendedproperty N'MS_Description', 'IPAddress of QCommander listener', 'SCHEMA', N'RDT', 'TABLE', N'rdtSpooler', 'COLUMN', N'IPAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Port of QCommander listener', 'SCHEMA', N'RDT', 'TABLE', N'rdtSpooler', 'COLUMN', N'PortNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Printer Spooler Name', 'SCHEMA', N'RDT', 'TABLE', N'rdtSpooler', 'COLUMN', N'Spooler'
GO
