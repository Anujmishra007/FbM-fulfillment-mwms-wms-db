CREATE TABLE [dbo].[PackInfo_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackInfo_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackInfo_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackInfo_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PackInfo_DELLOG] ADD CONSTRAINT [PK__PackInfo_DELLOG__69C77D4C] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PackInfo_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackInfo_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackInfo_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackInfo_DELLOG] TO [NSQL]
GO
