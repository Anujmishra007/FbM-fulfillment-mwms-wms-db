SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[POD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[POD](
	[Mbolkey] [nvarchar](10) NOT NULL,
	[Mbollinenumber] [nvarchar](5) NOT NULL,
	[LoadKey] [nvarchar](10) NULL,
	[OrderKey] [nvarchar](10) NULL,
	[BuyerPO] [nvarchar](20) NULL,
	[ExternOrderKey] [nvarchar](50) NULL,
	[InvoiceNo] [nvarchar](20) NULL,
	[Status] [nvarchar](10) NULL,
	[ActualDeliveryDate] [datetime] NULL,
	[InvDespatchDate] [datetime] NULL,
	[PodReceivedDate] [datetime] NULL,
	[PodFiledDate] [datetime] NULL,
	[InvCancelDate] [datetime] NULL,
	[RedeliveryDate] [datetime] NULL,
	[RedeliveryCount] [int] NULL,
	[FullRejectDate] [datetime] NULL,
	[ReturnRefNo] [nvarchar](30) NULL,
	[PartialRejectDate] [datetime] NULL,
	[RejectReasonCode] [nvarchar](10) NULL,
	[PoisonFormDate] [datetime] NULL,
	[PoisonFormNo] [nvarchar](10) NULL,
	[ChequeNo] [nvarchar](10) NULL,
	[ChequeAmount] [money] NULL,
	[ChequeDate] [datetime] NULL,
	[Notes] [nvarchar](4000) NULL,
	[Notes2] [nvarchar](4000) NULL,
	[PODDef01] [nvarchar](30) NULL,
	[PODDef02] [nvarchar](30) NULL,
	[PODDef03] [nvarchar](30) NULL,
	[PODDef04] [nvarchar](30) NULL,
	[PODDef05] [nvarchar](30) NULL,
	[PODDef06] [nvarchar](30) NULL,
	[PODDef07] [nvarchar](30) NULL,
	[PODDef08] [nvarchar](30) NULL,
	[PODDef09] [nvarchar](30) NULL,
	[PODDate01] [datetime] NULL,
	[PODDate02] [datetime] NULL,
	[PODDate03] [datetime] NULL,
	[PODDate04] [datetime] NULL,
	[PODDate05] [datetime] NULL,
	[TrackCol01] [nvarchar](30) NULL,
	[TrackCol02] [nvarchar](30) NULL,
	[TrackCol03] [nvarchar](30) NULL,
	[TrackCol04] [nvarchar](30) NULL,
	[TrackCol05] [nvarchar](30) NULL,
	[TrackDate01] [datetime] NULL,
	[TrackDate02] [datetime] NULL,
	[TrackDate03] [datetime] NULL,
	[TrackDate04] [datetime] NULL,
	[TrackDate05] [datetime] NULL,
	[AddWho] [nvarchar](128) NULL,
	[AddDate] [datetime] NULL,
	[EditWho] [nvarchar](128) NULL,
	[EditDate] [datetime] NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[FinalizeFlag] [nvarchar](1) NULL,
	[Storerkey] [nvarchar](15) NULL,
	[SpecialHandling] [nvarchar](1) NULL,
	[Latitude] [nvarchar](15) NULL,
	[Longtitude] [nvarchar](15) NULL,
	[ExternLoadKey] [nvarchar](30) NULL,
	[RefDocID] [nvarchar](110) NULL,
	[Notes3] [nvarchar](4000) NULL,
	[TrackCol06] [nvarchar](100) NULL,
	[TrackCol07] [nvarchar](100) NULL,
	[TrackCol08] [nvarchar](100) NULL,
	[TrackCol09] [nvarchar](100) NULL,
	[ActualGrossWeight] DECIMAL (9,3) NULL ,
	[ActualGrossVolume] DECIMAL (9,3) NULL ,
	[ActualShipUnitCount] DECIMAL (9,0) NULL,
	[ActualPieceCount] DECIMAL (9,0) NULL 
 CONSTRAINT [PK_POD] PRIMARY KEY CLUSTERED 
(
	[Mbolkey] ASC,
	[Mbollinenumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[POD]') AND name = N'IX_POD_ExtOrdKey')
CREATE NONCLUSTERED INDEX [IX_POD_ExtOrdKey] ON [dbo].[POD]
(
	[ExternOrderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[POD]') AND name = N'IX_POD_InvoiceNo')
CREATE NONCLUSTERED INDEX [IX_POD_InvoiceNo] ON [dbo].[POD]
(
	[InvoiceNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[POD]') AND name = N'IX_POD_OrderKey')
CREATE NONCLUSTERED INDEX [IX_POD_OrderKey] ON [dbo].[POD]
(
	[OrderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_POD_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[POD] ADD  CONSTRAINT [DF_POD_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_POD_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[POD] ADD  CONSTRAINT [DF_POD_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_POD_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[POD] ADD  CONSTRAINT [DF_POD_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_POD_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[POD] ADD  CONSTRAINT [DF_POD_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_POD_FinalizeFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[POD] ADD  CONSTRAINT [DF_POD_FinalizeFlag]  DEFAULT ('N') FOR [FinalizeFlag]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_POD_SpecialHandling]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[POD] ADD  CONSTRAINT [DF_POD_SpecialHandling]  DEFAULT ('N') FOR [SpecialHandling]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_POD_ExternLoadKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[POD] ADD  CONSTRAINT [DF_POD_ExternLoadKey]  DEFAULT ('') FOR [ExternLoadKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'Mbolkey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying Master Bill of Lading.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'Mbolkey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'LoadKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying loading.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'LoadKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'OrderKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'WMS Shipment Order number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'OrderKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'ExternOrderKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Order reference number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'ExternOrderKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'InvoiceNo'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer invoice number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'InvoiceNo'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'Status'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Proof of delivery status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'Status'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'ActualDeliveryDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The actual delivery date of goods' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'ActualDeliveryDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'InvDespatchDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date in which the goods is supposed to be delivered according to the invoice' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'InvDespatchDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PodReceivedDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date in which the proof of delivery was received' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PodReceivedDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PodFiledDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date in which the POD document was filed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PodFiledDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'InvCancelDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date in which the invoice has been cancelled' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'InvCancelDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'RedeliveryDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date in which the goods have to be re-delivered to the customer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'RedeliveryDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'RedeliveryCount'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The total number of times the goods have been delivered to the customer but not successful' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'RedeliveryCount'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'FullRejectDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date in which the delivery was fully rejected' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'FullRejectDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'ReturnRefNo'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document reference# on the returns' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'ReturnRefNo'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PartialRejectDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date in which the delivery was partially rejected' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PartialRejectDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'RejectReasonCode'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The reason why the delivery has been rejected' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'RejectReasonCode'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PoisonFormDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document date for the delivery which carries drugs (poison)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PoisonFormDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PoisonFormNo'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document number for the delivery which carries drugs (poison)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PoisonFormNo'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'ChequeNo'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cheque number - payment for the invoice/delivery' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'ChequeNo'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'ChequeAmount'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cheque amount to be paid for the delivery' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'ChequeAmount'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'ChequeDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cheque date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'ChequeDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'Notes'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'Notes'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'Notes2'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional information. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'Notes2'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PODDef01'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POD User defined01' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PODDef01'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PODDef02'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POD User defined02' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PODDef02'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PODDef03'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POD User defined03' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PODDef03'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PODDef04'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POD User defined04' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PODDef04'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PODDef05'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POD User defined05' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PODDef05'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PODDef06'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POD User defined06' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PODDef06'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PODDef07'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POD User defined07' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PODDef07'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'PODDef09'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POD User defined09' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'PODDef09'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'TrackCol02'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tracking 2:' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'TrackCol02'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'AddWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID added the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'AddWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'AddDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information added. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'AddDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'EditWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'EditWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'EditDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'EditDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'TrafficCop'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'TrafficCop'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'FinalizeFlag'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To finalize the POD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'FinalizeFlag'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'Storerkey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Storerkey' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'Storerkey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'SpecialHandling'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Notes on the delivery special handling' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'SpecialHandling'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', N'COLUMN',N'ExternLoadKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Extern LoadKey from Load plan, is linkage from OTM to WMS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD', @level2type=N'COLUMN',@level2name=N'ExternLoadKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'POD', NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Proof of delivery is a method to establish the fact that the recipient received the content sent by the sender.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'POD'
GO

--FCR-12859
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'ActualGrossWeight' AND Object_ID = Object_ID('dbo.POD'))
BEGIN
	ALTER TABLE dbo.POD ADD [ActualGrossWeight] DECIMAL (9,3) NULL;
	EXEC sp_addextendedproperty N'MS_Description', 'Actual gross weight in KG during pickup/delivery.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ActualGrossWeight'
				
END
GO

--DROP CONSTRAINT 
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'DF_POD_ActualGrossWeight' AND parent_object_id = OBJECT_ID('dbo.POD'))
BEGIN
    ALTER TABLE dbo.POD DROP CONSTRAINT DF_POD_ActualGrossWeight ;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'ActualGrossVolume' AND Object_ID = Object_ID('dbo.POD'))
BEGIN
	ALTER TABLE dbo.POD ADD [ActualGrossVolume] DECIMAL (9,3) NULL ;
	EXEC sp_addextendedproperty N'MS_Description', 'Actual gross volume in CBM during pickup/delivery.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ActualGrossVolume'
				
END
GO

--DROP CONSTRAINT 
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'DF_POD_ActualGrossVolume' AND parent_object_id = OBJECT_ID('dbo.POD'))
BEGIN
    ALTER TABLE dbo.POD DROP CONSTRAINT DF_POD_ActualGrossVolume ;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'ActualShipUnitCount' AND Object_ID = Object_ID('dbo.POD'))
BEGIN
	ALTER TABLE dbo.POD ADD [ActualShipUnitCount] DECIMAL (9,0) NULL ;
	EXEC sp_addextendedproperty N'MS_Description', 'Actual PALLET/CARTON count during pickup/delivery.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ActualShipUnitCount'
				
END
GO

--DROP CONSTRAINT 
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'DF_POD_ActualShipUnitCount' AND parent_object_id = OBJECT_ID('dbo.POD'))
BEGIN
    ALTER TABLE dbo.POD DROP CONSTRAINT DF_POD_ActualShipUnitCount ;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'ActualPieceCount' AND Object_ID = Object_ID('dbo.POD'))
BEGIN
	ALTER TABLE dbo.POD ADD [ActualPieceCount] DECIMAL (9,0) NULL ;
	EXEC sp_addextendedproperty N'MS_Description', 'Actual piece count during pickup/delivery.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ActualPieceCount'
				
END
GO

--DROP CONSTRAINT 
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'DF_POD_ActualPieceCount' AND parent_object_id = OBJECT_ID('dbo.POD'))
BEGIN
    ALTER TABLE dbo.POD DROP CONSTRAINT DF_POD_ActualPieceCount ;
END
GO
	