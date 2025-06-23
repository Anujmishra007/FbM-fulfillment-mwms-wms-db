SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RFPUTAWAY_DEL]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RFPUTAWAY_DEL](
	[StorerKey] [nvarchar](15) NOT NULL,
	[Sku] [nvarchar](20) NOT NULL,
	[Lot] [nvarchar](10) NOT NULL,
	[FromLoc] [nvarchar](10) NOT NULL,
	[SuggestedLoc] [nvarchar](10) NOT NULL,
	[Id] [nvarchar](18) NULL,
	[ptcid] [nvarchar](18) NOT NULL,
	[qty] [int] NOT NULL,
	[AddDate] [datetime] NULL,
	[AddWho] [nvarchar](128) NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[CaseID] [nvarchar](20) NOT NULL,
	[FromID] [nvarchar](18) NOT NULL,
	[RowRef] [int] NOT NULL,
	[DelDate] [datetime] NULL,
	[DelWho] [nvarchar](128) NOT NULL,
	[TaskDetailKey] [nvarchar](10) NOT NULL,
	[Func] [int] NOT NULL,
	[PABookingKey] [int] NOT NULL,
	[QTYPrinted] [int] NOT NULL,
	[EditDate] [datetime] NULL,
	[EditWho] [nvarchar](128) NULL,
	[Receiptkey] [nvarchar](10) NULL,
	[ReceiptLineNumber] [nvarchar](5) NULL,
	[UDF01] [nvarchar](60) NULL,
	[UDF02] [nvarchar](60) NULL,
	[UDF03] [nvarchar](60) NULL,
CONTRAINT PK_RFPUTAWAY_DEL PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_RFPutaway_DEL_DelDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RFPUTAWAY_DEL] ADD  CONSTRAINT [DF_RFPutaway_DEL_DelDate]  DEFAULT (getdate()) FOR [DelDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_RFPutaway_DEL_DelWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RFPUTAWAY_DEL] ADD  CONSTRAINT [DF_RFPutaway_DEL_DelWho]  DEFAULT (suser_sname()) FOR [DelWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_RFPutaway_DEL_ReceiptKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RFPUTAWAY_DEL] ADD  CONSTRAINT [DF_RFPutaway_DEL_ReceiptKey]  DEFAULT ('') FOR [Receiptkey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_RFPutaway_DEL_ReceiptLineNumber]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RFPUTAWAY_DEL] ADD  CONSTRAINT [DF_RFPutaway_DEL_ReceiptLineNumber]  DEFAULT ('') FOR [ReceiptLineNumber]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_RFPutaway_DEL_UDF01]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RFPUTAWAY_DEL] ADD  CONSTRAINT [DF_RFPutaway_DEL_UDF01]  DEFAULT ('') FOR [UDF01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_RFPutaway_DEL_UDF02]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RFPUTAWAY_DEL] ADD  CONSTRAINT [DF_RFPutaway_DEL_UDF02]  DEFAULT ('') FOR [UDF02]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_RFPutaway_DEL_UDF03]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RFPUTAWAY_DEL] ADD  CONSTRAINT [DF_RFPutaway_DEL_UDF03]  DEFAULT ('') FOR [UDF03]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'RFPUTAWAY_DEL', N'COLUMN', N'Receiptkey'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Receipt Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RFPUTAWAY_DEL', @level2type=N'COLUMN',@level2name=N'Receiptkey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'RFPUTAWAY_DEL', N'COLUMN', N'ReceiptLineNumber'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Receipt Line Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RFPUTAWAY_DEL', @level2type=N'COLUMN',@level2name=N'ReceiptLineNumber'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'RFPUTAWAY_DEL', N'COLUMN', N'UDF01'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User define field 01' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RFPUTAWAY_DEL', @level2type=N'COLUMN',@level2name=N'UDF01'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'RFPUTAWAY_DEL', N'COLUMN', N'UDF02'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User define field 02' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RFPUTAWAY_DEL', @level2type=N'COLUMN',@level2name=N'UDF02'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'RFPUTAWAY_DEL', N'COLUMN', N'UDF03'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User define field 03' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RFPUTAWAY_DEL', @level2type=N'COLUMN',@level2name=N'UDF03'
GO


