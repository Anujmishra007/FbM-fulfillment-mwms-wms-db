IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[POD]') AND type in (N'U'))
BEGIN
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


ALTER TABLE [dbo].[POD] ADD CONSTRAINT [PK_POD] PRIMARY KEY CLUSTERED ([Mbolkey], [Mbollinenumber]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_POD_ExtOrdKey] ON [dbo].[POD] ([ExternOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_POD_InvoiceNo] ON [dbo].[POD] ([InvoiceNo]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_POD_OrderKey] ON [dbo].[POD] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]


GRANT DELETE ON  [dbo].[POD] TO [NSQL]

GRANT INSERT ON  [dbo].[POD] TO [NSQL]

GRANT SELECT ON  [dbo].[POD] TO [NSQL]

GRANT UPDATE ON  [dbo].[POD] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', 'Proof of delivery is a method to establish the fact that the recipient received the content sent by the sender.', 'SCHEMA', N'dbo', 'TABLE', N'POD', NULL, NULL

EXEC sp_addextendedproperty N'MS_Description', 'The actual delivery date of goods', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ActualDeliveryDate'

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', 'Cheque amount to be paid for the delivery', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ChequeAmount'

EXEC sp_addextendedproperty N'MS_Description', 'Cheque date', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ChequeDate'

EXEC sp_addextendedproperty N'MS_Description', 'Cheque number - payment for the invoice/delivery', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ChequeNo'

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'EditWho'

EXEC sp_addextendedproperty N'MS_Description', 'Extern LoadKey from Load plan, is linkage from OTM to WMS', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ExternLoadKey'

EXEC sp_addextendedproperty N'MS_Description', 'Customer Order reference number', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ExternOrderKey'

EXEC sp_addextendedproperty N'MS_Description', 'To finalize the POD', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'FinalizeFlag'

EXEC sp_addextendedproperty N'MS_Description', 'Date in which the delivery was fully rejected', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'FullRejectDate'

EXEC sp_addextendedproperty N'MS_Description', 'The date in which the invoice has been cancelled', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'InvCancelDate'

EXEC sp_addextendedproperty N'MS_Description', 'The date in which the goods is supposed to be delivered according to the invoice', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'InvDespatchDate'

EXEC sp_addextendedproperty N'MS_Description', 'Customer invoice number', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'InvoiceNo'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'LoadKey'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Mbolkey'

EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Notes'

EXEC sp_addextendedproperty N'MS_Description', 'Additional information. ', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Notes2'

EXEC sp_addextendedproperty N'MS_Description', 'WMS Shipment Order number', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'OrderKey'

EXEC sp_addextendedproperty N'MS_Description', 'Date in which the delivery was partially rejected', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PartialRejectDate'

EXEC sp_addextendedproperty N'MS_Description', 'POD User defined01', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef01'

EXEC sp_addextendedproperty N'MS_Description', 'POD User defined02', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef02'

EXEC sp_addextendedproperty N'MS_Description', 'POD User defined03', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef03'

EXEC sp_addextendedproperty N'MS_Description', 'POD User defined04', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef04'

EXEC sp_addextendedproperty N'MS_Description', 'POD User defined05', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef05'

EXEC sp_addextendedproperty N'MS_Description', 'POD User defined06', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef06'

EXEC sp_addextendedproperty N'MS_Description', 'POD User defined07', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef07'

EXEC sp_addextendedproperty N'MS_Description', 'POD User defined09', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PODDef09'

EXEC sp_addextendedproperty N'MS_Description', 'The date in which the POD document was filed', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PodFiledDate'

EXEC sp_addextendedproperty N'MS_Description', 'The date in which the proof of delivery was received', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PodReceivedDate'

EXEC sp_addextendedproperty N'MS_Description', 'Document date for the delivery which carries drugs (poison)', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PoisonFormDate'

EXEC sp_addextendedproperty N'MS_Description', 'Document number for the delivery which carries drugs (poison)', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'PoisonFormNo'

EXEC sp_addextendedproperty N'MS_Description', 'The total number of times the goods have been delivered to the customer but not successful', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'RedeliveryCount'

EXEC sp_addextendedproperty N'MS_Description', 'The date in which the goods have to be re-delivered to the customer', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'RedeliveryDate'

EXEC sp_addextendedproperty N'MS_Description', 'The reason why the delivery has been rejected', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'RejectReasonCode'

EXEC sp_addextendedproperty N'MS_Description', 'Document reference# on the returns', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'ReturnRefNo'

EXEC sp_addextendedproperty N'MS_Description', 'Notes on the delivery special handling', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'SpecialHandling'

EXEC sp_addextendedproperty N'MS_Description', 'Proof of delivery status', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Status'

EXEC sp_addextendedproperty N'MS_Description', 'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Storerkey'

EXEC sp_addextendedproperty N'MS_Description', 'Tracking 2:', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'TrackCol02'

EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'TrafficCop'

END

ELSE
BEGIN

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'Notes3' AND Object_ID = Object_ID('dbo.POD'))
BEGIN
	ALTER TABLE dbo.POD ADD [Notes3] [nvarchar] (4000) NULL;
	EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'Notes3'
				
END



IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'TrackCol06' AND Object_ID = Object_ID('dbo.POD'))
BEGIN
	ALTER TABLE dbo.POD ADD [TrackCol06] [nvarchar] (100) NULL;
	EXEC sp_addextendedproperty N'MS_Description', 'TrackCol06', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'TrackCol06'
				
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'TrackCol07' AND Object_ID = Object_ID('dbo.POD'))
BEGIN
	ALTER TABLE dbo.POD ADD [TrackCol07] [nvarchar] (100) NULL;
	EXEC sp_addextendedproperty N'MS_Description', 'TrackCol07', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'TrackCol07'
				
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'TrackCol08' AND Object_ID = Object_ID('dbo.POD'))
BEGIN
	ALTER TABLE dbo.POD ADD [TrackCol08] [nvarchar] (100) NULL;
	EXEC sp_addextendedproperty N'MS_Description', 'TrackCol08', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'TrackCol08'
				
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'TrackCol09' AND Object_ID = Object_ID('dbo.POD'))
BEGIN
	ALTER TABLE dbo.POD ADD [TrackCol09] [nvarchar] (100) NULL;
	EXEC sp_addextendedproperty N'MS_Description', 'TrackCol09', 'SCHEMA', N'dbo', 'TABLE', N'POD', 'COLUMN', N'TrackCol09'
				
END


END


