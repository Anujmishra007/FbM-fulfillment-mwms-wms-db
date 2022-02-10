CREATE TABLE [dbo].[AllocShortageLog]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderedQty] [int] NOT NULL CONSTRAINT [DF_AllocShortageLog_OrderedQty] DEFAULT ((0)),
[AllocatedQty] [int] NOT NULL CONSTRAINT [DF_AllocShortageLog_AllocatedQty] DEFAULT ((0)),
[QtyOnHand] [int] NOT NULL CONSTRAINT [DF_AllocShortageLog_QtyOnHand] DEFAULT ((0)),
[QtyOnHold] [int] NOT NULL CONSTRAINT [DF_AllocShortageLog_QtyOnHold] DEFAULT ((0)),
[QtyReceiptInProgress] [int] NOT NULL CONSTRAINT [DF_AllocShortageLog_QtyReceiptInProgress] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AllocShortageLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocShortageLog_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AllocShortageLog] ADD CONSTRAINT [PK_AllocShortageLog] PRIMARY KEY CLUSTERED ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[AllocShortageLog] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[AllocShortageLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AllocShortageLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AllocShortageLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AllocShortageLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AllocShortageLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'AllocShortageLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'AllocShortageLog', 'COLUMN', N'StorerKey'
GO
