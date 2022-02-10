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
GO
ALTER TABLE [dbo].[GenericWebServiceHost_Process] ADD CONSTRAINT [PK_WebServiceHost_Process] PRIMARY KEY CLUSTERED ([RequestMessageName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GenericWebServiceHost_Process] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GenericWebServiceHost_Process] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GenericWebServiceHost_Process] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GenericWebServiceHost_Process] TO [NSQL]
GO
