CREATE TABLE [dbo].[UnauthorizeAccess]
(
[AddDate] [datetime] NOT NULL,
[SPID] [int] NOT NULL,
[ProgramName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UnauthorizeAccess_ProgramName] DEFAULT (''),
[HostName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UnauthorizeAccess_HostName] DEFAULT (''),
[Login_Time] [datetime] NULL,
[Login_ID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UnauthorizeAccess_Login_ID] DEFAULT (' '),
[Net_Address] [nchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UnauthorizeAccess] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UnauthorizeAccess] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UnauthorizeAccess] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UnauthorizeAccess] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UnauthorizeAccess', 'COLUMN', N'AddDate'
GO
