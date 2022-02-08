CREATE TABLE [dbo].[OrderInfo_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderInfo_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_OrderInfo_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderInfo_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderInfo_DELLOG] ADD CONSTRAINT [PK__OrderInfo_DELLOG__01342732] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderInfo_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OrderInfo_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OrderInfo_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OrderInfo_DELLOG] TO [NSQL]
GO
