CREATE TABLE [dbo].[BTB_ShipmentDetail]
(
[BTB_ShipmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BTB_ShipmentListNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BTB_ShipmentLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_FormNo] DEFAULT (''),
[HSCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_HSCode] DEFAULT (''),
[PermitNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_PermitNo] DEFAULT (''),
[IssuedDate] [datetime] NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Sku] DEFAULT (''),
[SkuDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_SkuDescr] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UOM] DEFAULT (''),
[Price] [float] NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Price] DEFAULT ((0.00)),
[Currency] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Currency] DEFAULT (''),
[QtyExported] [int] NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_QtyExported] DEFAULT ((0)),
[Wavekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Wavekey] DEFAULT (''),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine08] DEFAULT (''),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine10] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BTB_ShipmentDetail_IssueCountry] DEFAULT (''),
[IssueAuthority] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BTB_ShipmentDetail_IssueAuthority] DEFAULT (''),
[BTBShipItem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_BTBShipItem] DEFAULT (''),
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_SHIPMENTDETAIL_ExternOrderkey] DEFAULT (''),
[CustomLotNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_SHIPMENTDETAIL_CustomLotNo] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BTB_ShipmentDetail] ADD CONSTRAINT [PK__BTB_Ship__D106209936B2EC37] PRIMARY KEY CLUSTERED ([BTB_ShipmentKey], [BTB_ShipmentListNo], [BTB_ShipmentLineNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BTB_ShipmentDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BTB_ShipmentDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BTB_ShipmentDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BTB_ShipmentDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back FTA', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment Running #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'BTB_ShipmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment Line #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'BTB_ShipmentLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment List Running #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'BTB_ShipmentListNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BTB Shipment Item', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'BTBShipItem'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Currency', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Currency'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Custom Lot #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'CustomLotNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Extern Order Number', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Form No', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'FormNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'HSCode', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'HSCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Issuing Authority', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'IssueAuthority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Issuing Country', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'IssueCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Issued Date', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'IssuedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permit No', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'PermitNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Price', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Exported Qty', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'QtyExported'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku Description', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'SkuDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 06', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 07', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 08', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 09', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 10', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Wave #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Wavekey'
GO
