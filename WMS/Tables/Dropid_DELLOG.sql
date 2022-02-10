CREATE TABLE [dbo].[Dropid_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[Dropid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Dropid_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Dropid_DELLOG] ADD CONSTRAINT [PK__Dropid_DELLOG__6DA2FB28] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Dropid_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Dropid_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Dropid_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Dropid_DELLOG] TO [NSQL]
GO
