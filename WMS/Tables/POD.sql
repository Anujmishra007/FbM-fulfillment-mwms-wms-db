CREATE TABLE [dbo].[POD]
(
[Mbolkey] [nvarchar] (10) NOT NULL,
[Mbollinenumber] [nvarchar] (5) NOT NULL,
[LoadKey] [nvarchar] (10) NULL,
[OrderKey] [nvarchar] (10) NULL,
[BuyerPO] [nvarchar] (20) NULL,
[ExternOrderKey] [nvarchar] (50) NULL,
[InvoiceNo] [nvarchar] (20) NULL,
[Status] [nvarchar] (10) NULL,
[ActualDeliveryDate] [datetime] NULL,
[InvDespatchDate] [datetime] NULL,
[PodReceivedDate] [datetime] NULL,
[PodFiledDate] [datetime] NULL,
[InvCancelDate] [datetime] NULL,
[RedeliveryDate] [datetime] NULL,
[RedeliveryCount] [int] NULL,
[FullRejectDate] [datetime] NULL,
[ReturnRefNo] [nvarchar] (30) NULL,
[PartialRejectDate] [datetime] NULL,
[RejectReasonCode] [nvarchar] (10) NULL,
[PoisonFormDate] [datetime] NULL,
[PoisonFormNo] [nvarchar] (10) NULL,
[ChequeNo] [nvarchar] (10) NULL,
[ChequeAmount] [money] NULL,
[ChequeDate] [datetime] NULL,
[Notes] [nvarchar] (4000) NULL,
[Notes2] [nvarchar] (4000) NULL,
[PODDef01] [nvarchar] (30) NULL,
[PODDef02] [nvarchar] (30) NULL,
[PODDef03] [nvarchar] (30) NULL,
[PODDef04] [nvarchar] (30) NULL,
[PODDef05] [nvarchar] (30) NULL,
[PODDef06] [nvarchar] (30) NULL,
[PODDef07] [nvarchar] (30) NULL,
[PODDef08] [nvarchar] (30) NULL,
[PODDef09] [nvarchar] (30) NULL,
[PODDate01] [datetime] NULL,
[PODDate02] [datetime] NULL,
[PODDate03] [datetime] NULL,
[PODDate04] [datetime] NULL,
[PODDate05] [datetime] NULL,
[TrackCol01] [nvarchar] (30) NULL,
[TrackCol02] [nvarchar] (30) NULL,
[TrackCol03] [nvarchar] (30) NULL,
[TrackCol04] [nvarchar] (30) NULL,
[TrackCol05] [nvarchar] (30) NULL,
[TrackDate01] [datetime] NULL,
[TrackDate02] [datetime] NULL,
[TrackDate03] [datetime] NULL,
[TrackDate04] [datetime] NULL,
[TrackDate05] [datetime] NULL,
[AddWho] [nvarchar] (128) NULL CONSTRAINT [DF_POD_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_POD_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NULL CONSTRAINT [DF_POD_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_POD_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) NULL,
[ArchiveCop] [nvarchar] (1) NULL,
[FinalizeFlag] [nvarchar] (1) NULL CONSTRAINT [DF_POD_FinalizeFlag] DEFAULT ('N'),
[Storerkey] [nvarchar] (15) NULL,
[SpecialHandling] [nvarchar] (1) NULL CONSTRAINT [DF_POD_SpecialHandling] DEFAULT ('N'),
[Latitude] [nvarchar] (15) NULL,
[Longtitude] [nvarchar] (15) NULL,
[ExternLoadKey] [nvarchar] (30) NULL CONSTRAINT [DF_POD_ExternLoadKey] DEFAULT (''),
[RefDocID] [nvarchar] (110) NULL,
[Notes3] [nvarchar] (4000) NULL,
[TrackCol06] [nvarchar] (100) NULL,
[TrackCol07] [nvarchar] (100) NULL,
[TrackCol08] [nvarchar] (100) NULL,
[TrackCol09] [nvarchar] (100) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[POD] ADD CONSTRAINT [PK_POD] PRIMARY KEY CLUSTERED ([Mbolkey], [Mbollinenumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_POD_ExtOrdKey] ON [dbo].[POD] ([ExternOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_POD_InvoiceNo] ON [dbo].[POD] ([InvoiceNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_POD_OrderKey] ON [dbo].[POD] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[POD] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[POD] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[POD] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[POD] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[POD] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Proof of delivery is a method to establish the fact that the recipient received the content sent by the sender.', 'SCHEMA', N'dbo', 'TABLE', N'POD', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'The actual delivery date of goods', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ActualDeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cheque amount to be paid for the delivery', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ChequeAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cheque date', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ChequeDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cheque number - payment for the invoice/delivery', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ChequeNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Extern LoadKey from Load plan, is linkage from OTM to WMS', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ExternLoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer Order reference number', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'To finalize the POD', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'FinalizeFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date in which the delivery was fully rejected', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'FullRejectDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the invoice has been cancelled', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'InvCancelDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the goods is supposed to be delivered according to the invoice', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'InvDespatchDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer invoice number', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Mbolkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information. ', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'WMS Shipment Order number', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date in which the delivery was partially rejected', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PartialRejectDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'POD User defined01', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'POD User defined02', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'POD User defined03', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'POD User defined04', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'POD User defined05', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'POD User defined06', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'POD User defined07', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'POD User defined09', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the POD document was filed', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PodFiledDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the proof of delivery was received', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PodReceivedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Document date for the delivery which carries drugs (poison)', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PoisonFormDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Document number for the delivery which carries drugs (poison)', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PoisonFormNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The total number of times the goods have been delivered to the customer but not successful', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'RedeliveryCount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the goods have to be re-delivered to the customer', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'RedeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The reason why the delivery has been rejected', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'RejectReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Document reference# on the returns', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ReturnRefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Notes on the delivery special handling', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'SpecialHandling'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Proof of delivery status', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracking 2:', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'TrackCol02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'TrafficCop'
GO
