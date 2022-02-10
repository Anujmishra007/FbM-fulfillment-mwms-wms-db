CREATE TABLE [dbo].[rdsOrderDetail_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[rdsOrderNo] [int] NOT NULL,
[rdsOrderLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdsOrderDetail_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rdsOrderDetail_DELLOG] ADD CONSTRAINT [PK__rdsOrderDetail_D__1E505424] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rdsOrderDetail_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsOrderDetail_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsOrderDetail_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsOrderDetail_DELLOG] TO [NSQL]
GO
