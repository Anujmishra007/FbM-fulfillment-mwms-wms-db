IF NOT EXISTS ( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID (N'[dbo].[TCPSocket_Process]')  AND TYPE IN ('N','U'))
BEGIN

CREATE TABLE [dbo].[TCPSocket_Process]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SprocName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESCR] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient1] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient2] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient3] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient4] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient5] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TCPSocket_Process_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_Process_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TCPSocket_Process_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_Process_EditWho] DEFAULT (suser_sname()),
[MessageGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_Process_MessageGroup] DEFAULT (''),
[ACKData] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_Process_ACKData] DEFAULT (''),
[Facility] nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_Process_Facility]  DEFAULT ('')
) ON [PRIMARY]

ALTER TABLE [dbo].[TCPSocket_Process] ADD CONSTRAINT [PK_TCPSocket_Process] PRIMARY KEY CLUSTERED ([MessageName], [MessageGroup], [StorerKey]) ON [PRIMARY]

GRANT DELETE ON  [dbo].[TCPSocket_Process] TO [NSQL]

GRANT INSERT ON  [dbo].[TCPSocket_Process] TO [NSQL]

GRANT SELECT ON  [dbo].[TCPSocket_Process] TO [NSQL]

GRANT UPDATE ON  [dbo].[TCPSocket_Process] TO [NSQL]

END 

ELSE 
BEGIN

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'ACKData' AND Object_ID = Object_ID('dbo.TCPSocket_Process'))
BEGIN
	ALTER TABLE dbo.TCPSocket_Process ADD ACKData [nvarchar](4000) NOT NULL CONSTRAINT [DF_TCPSocket_Process_ACKData] DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'ACKData', 'SCHEMA', N'DBO', 'TABLE', N'TCPSocket_Process', 'COLUMN', N'ACKData'
				
END


IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Facility' AND Object_ID = Object_ID('dbo.TCPSocket_Process'))
BEGIN
	ALTER TABLE dbo.TCPSocket_Process ADD Facility nvarchar(5) NULL CONSTRAINT [DF_TCPSocket_Process_Facility]  DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'Facility', 'SCHEMA', N'DBO', 'TABLE', N'TCPSocket_Process', 'COLUMN', N'Facility'
				
END

END 
