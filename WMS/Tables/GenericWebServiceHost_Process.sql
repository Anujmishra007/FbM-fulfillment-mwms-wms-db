IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenericWebServiceHost_Process]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GenericWebServiceHost_Process]
(
[RequestMessageName] [nvarchar] (30) NOT NULL,
[ResponseMessageName] [nvarchar] (30) NOT NULL,
[SprocName] [nvarchar] (50) NOT NULL,
[DESCR] [nvarchar] (100) NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_EditWho] DEFAULT (suser_sname()),
[StorerKey] [nvarchar] (15) NULL,
[Recipient1] [nvarchar] (125) NULL,
[Recipient2] [nvarchar] (125) NULL,
[Recipient3] [nvarchar] (125) NULL,
[Recipient4] [nvarchar] (125) NULL,
[Recipient5] [nvarchar] (125) NULL,
[LinkedServer] [nvarchar] (128) NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_LinkedServer] DEFAULT (''),
[DatabaseName] [nvarchar] (128) NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_DatabaseName] DEFAULT (''),
[SchemaName] [nvarchar] (128) NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_SchemaName] DEFAULT ('')
) ON [PRIMARY]

ALTER TABLE [dbo].[GenericWebServiceHost_Process] ADD CONSTRAINT [PK_WebServiceHost_Process] PRIMARY KEY CLUSTERED ([RequestMessageName]) WITH (FILLFACTOR=90) ON [PRIMARY]

GRANT DELETE ON  [dbo].[GenericWebServiceHost_Process] TO [NSQL]

GRANT INSERT ON  [dbo].[GenericWebServiceHost_Process] TO [NSQL]

GRANT SELECT ON  [dbo].[GenericWebServiceHost_Process] TO [NSQL]

GRANT UPDATE ON  [dbo].[GenericWebServiceHost_Process] TO [NSQL]

END

ELSE
BEGIN 

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'LinkedServer' AND Object_ID = Object_ID('dbo.GenericWebServiceHost_Process'))
BEGIN
	ALTER TABLE dbo.GenericWebServiceHost_Process ADD [LinkedServer] [nvarchar] (128) NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_LinkedServer] DEFAULT ('') ;
	EXEC sp_addextendedproperty N'MS_Description', 'LinkedServer', 'SCHEMA', N'DBO', 'TABLE', N'GenericWebServiceHost_Process', 'COLUMN', N'LinkedServer'
				
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'DatabaseName' AND Object_ID = Object_ID('dbo.GenericWebServiceHost_Process'))
BEGIN
	ALTER TABLE dbo.GenericWebServiceHost_Process ADD [DatabaseName] [nvarchar] (128) NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_DatabaseName] DEFAULT ('') ;
	EXEC sp_addextendedproperty N'MS_Description', 'DatabaseName', 'SCHEMA', N'DBO', 'TABLE', N'GenericWebServiceHost_Process', 'COLUMN', N'DatabaseName'
				
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'SchemaName' AND Object_ID = Object_ID('dbo.GenericWebServiceHost_Process'))
BEGIN
	ALTER TABLE dbo.GenericWebServiceHost_Process ADD [SchemaName] [nvarchar] (128) NOT NULL CONSTRAINT [DF_GenericWebServiceHost_Process_SchemaName] DEFAULT ('') ;
	EXEC sp_addextendedproperty N'MS_Description', 'SchemaName', 'SCHEMA', N'DBO', 'TABLE', N'GenericWebServiceHost_Process', 'COLUMN', N'SchemaName'
				
END

END
