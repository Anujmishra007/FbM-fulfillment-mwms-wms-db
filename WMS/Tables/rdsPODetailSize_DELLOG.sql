CREATE TABLE [dbo].[rdsPODetailSize_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[rdsPONo] [int] NOT NULL,
[rdsPOLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPODetailSize_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdsPODetailSize_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPODetailSize_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rdsPODetailSize_DELLOG] ADD CONSTRAINT [PK__rdsPODetailSize___407A839F] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rdsPODetailSize_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsPODetailSize_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsPODetailSize_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsPODetailSize_DELLOG] TO [NSQL]
GO
