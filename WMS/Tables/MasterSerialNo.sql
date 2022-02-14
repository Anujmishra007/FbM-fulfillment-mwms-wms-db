CREATE TABLE [dbo].[MasterSerialNo]
(
[MasterSerialNoKey] [bigint] NOT NULL IDENTITY(1, 1),
[LocationCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_LocationCode] DEFAULT (''),
[UnitType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_UnitType] DEFAULT (''),
[PartnerType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_PartnerType] DEFAULT (''),
[SerialNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_SerialNo] DEFAULT (''),
[ElectronicSN] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ElectronicSN] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_Sku] DEFAULT (''),
[ItemID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ItemID] DEFAULT (''),
[ItemDescr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ItemDescr] DEFAULT (''),
[ChildQty] [int] NULL CONSTRAINT [DF_MasterSerialNo_ChildQty] DEFAULT ((0)),
[ParentSerialNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ParentSerialNo] DEFAULT (''),
[ParentSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_ParentSku] DEFAULT (''),
[ParentItemID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ParentItemID] DEFAULT (''),
[ParentProdLine] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_ParentProdLine] DEFAULT (''),
[VendorSerialNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_VendorSerialNo] DEFAULT (''),
[VendorLotNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_VendorLotNo] DEFAULT (''),
[LotNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_LotNo] DEFAULT (''),
[Revision] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Revision] DEFAULT (''),
[CreationDate] [datetime] NULL,
[Source] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Source] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Status] DEFAULT ('0'),
[Attribute1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Attribute1] DEFAULT (''),
[Attribute2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Attribute2] DEFAULT (''),
[Attribute3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_Attribute3] DEFAULT (''),
[RequestID] [int] NULL CONSTRAINT [DF_MasterSerialNo_RequestID] DEFAULT ((0)),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MasterSerialNo_UserDefine03] DEFAULT (''),
[UserDefine04] [datetime] NULL,
[UserDefine05] [datetime] NULL,
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_AddWho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_MasterSerialNo_AddDate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MasterSerialNo_EditWho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_MasterSerialNo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[MasterSerialNo] ADD CONSTRAINT [PK__MasterSe__1EE8ACD625D8D096] PRIMARY KEY CLUSTERED ([MasterSerialNoKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MasterSerialNo_Serailno] ON [dbo].[MasterSerialNo] ([SerialNo], [Storerkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MasterSerialNo_SkuParentSN] ON [dbo].[MasterSerialNo] ([Storerkey], [Sku], [ParentSerialNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MasterSerialNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MasterSerialNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MasterSerialNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MasterSerialNo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Master Serial Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Attribute 1', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Attribute1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Attribute 2', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Attribute2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Attribute 3', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Attribute3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Child Qty', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ChildQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Serial # Creation Date', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'CreationDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Electronic Serial #', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ElectronicSN'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Item Description', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ItemDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Item ID', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ItemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location Code', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'LocationCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lot Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'LotNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Master Serial Number Key', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'MasterSerialNoKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent Item ID', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ParentItemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent Product Line', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ParentProdLine'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent Serial Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ParentSerialNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent Sku', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'ParentSku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Partner Type', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'PartnerType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Request ID', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'RequestID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Revision', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Revision'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Serial Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'SerialNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku ', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Source'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Serial # Status', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit Type', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UnitType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor Lot Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'VendorLotNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor Serial Number', 'SCHEMA', N'dbo', 'TABLE', N'MasterSerialNo', 'COLUMN', N'VendorSerialNo'
GO
