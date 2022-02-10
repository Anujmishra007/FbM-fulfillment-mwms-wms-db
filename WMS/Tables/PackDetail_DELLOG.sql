CREATE TABLE [dbo].[PackDetail_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetail_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackDetail_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetail_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PackDetail_DELLOG] ADD CONSTRAINT [PK__PackDetail_DELLO__330C453F] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PackDetail_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackDetail_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackDetail_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackDetail_DELLOG] TO [NSQL]
GO
