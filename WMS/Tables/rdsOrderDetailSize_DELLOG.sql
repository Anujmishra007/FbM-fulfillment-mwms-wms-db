CREATE TABLE [dbo].[rdsOrderDetailSize_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[rdsOrderNo] [int] NOT NULL,
[rdsOrderLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetailSize_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdsOrderDetailSize_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetailSize_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rdsOrderDetailSize_DELLOG] ADD CONSTRAINT [PK__rdsOrderDetailSi__4A98EAB6] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rdsOrderDetailSize_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsOrderDetailSize_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsOrderDetailSize_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsOrderDetailSize_DELLOG] TO [NSQL]
GO
