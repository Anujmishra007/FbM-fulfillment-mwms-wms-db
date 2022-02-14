CREATE TABLE [dbo].[CASEMANIFEST]
(
[CaseId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_Sku] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_Loc] DEFAULT ('UNKNOWN'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_Status] DEFAULT ('0'),
[ExpectedReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ExpectedReceiptKey] DEFAULT (' '),
[ExpectedPOKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ExpectedPOKey] DEFAULT (' '),
[ReceivedReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ReceivedReceiptKey] DEFAULT (' '),
[ReceivedPOKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ReceivedPOKey] DEFAULT (' '),
[ReceiptDate] [datetime] NOT NULL CONSTRAINT [DF_CASEMANIFEST_ReceiptDate] DEFAULT (getdate()),
[ExpectedClpOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ExpectedClpOrderKey] DEFAULT (' '),
[ShippedClpOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ShippedClpOrderKey] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_CASEMANIFEST_Qty] DEFAULT ((0)),
[ShipStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ShipStatus] DEFAULT ('0'),
[Shipdate] [datetime] NOT NULL CONSTRAINT [DF_CASEMANIFEST_Shipdate] DEFAULT (getdate()),
[OSDCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_OSDCode] DEFAULT (' '),
[OSDQTY] [int] NOT NULL CONSTRAINT [DF_CASEMANIFEST_OSDQTY] DEFAULT ((0)),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_ID] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CASEMANIFEST_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CASEMANIFEST_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CASEMANIFEST_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CASEMANIFEST] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CASEMANIFEST] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CASEMANIFEST] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CASEMANIFEST] TO [NSQL]
GO

ALTER TABLE [dbo].[CASEMANIFEST] WITH NOCHECK ADD CONSTRAINT [CK_CASEMANIFEST_CaseId] CHECK ((NOT [CaseId]=' '))
GO
ALTER TABLE [dbo].[CASEMANIFEST] WITH NOCHECK ADD CONSTRAINT [CK_CASMAN_ShipStatus] CHECK (([ShipStatus]>='0' AND [ShipStatus]<='9'))
GO
ALTER TABLE [dbo].[CASEMANIFEST] WITH NOCHECK ADD CONSTRAINT [CK_CASMAN_Status] CHECK (([Status]>='0' AND [Status]<='9'))
GO
ALTER TABLE [dbo].[CASEMANIFEST] ADD CONSTRAINT [PKCASEMANIFEST] PRIMARY KEY CLUSTERED ([CaseId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CASEMANIFEST] ADD CONSTRAINT [FK_CASEMANIFEST_LOC_01] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
ALTER TABLE [dbo].[CASEMANIFEST] WITH NOCHECK ADD CONSTRAINT [FK_CASEMANIFEST_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Case ID', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'CaseId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying expected CLP order.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ExpectedClpOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Expected Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ExpectedPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Expected Receipt.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ExpectedReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated to case manifest.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of receipt issued.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ReceiptDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Received Purchase Orders. ', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ReceivedPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Received Receipt.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ReceivedReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of shipping.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'Shipdate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying shipped CLP order.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'ShippedClpOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CASEMANIFEST', 'COLUMN', N'TrafficCop'
GO
