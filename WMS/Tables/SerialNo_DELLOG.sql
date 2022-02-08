CREATE TABLE [dbo].[SerialNo_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[SerialNoKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SerialNo_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_SerialNo_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SerialNo_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SerialNo_DELLOG] ADD CONSTRAINT [PK__SerialNo__78C97797289F0220] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SerialNo_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SerialNo_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SerialNo_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SerialNo_DELLOG] TO [NSQL]
GO
