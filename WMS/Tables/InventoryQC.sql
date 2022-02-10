CREATE TABLE [dbo].[InventoryQC]
(
[QC_Key] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Reason] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TradeReturnKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Refno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQC_addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_InventoryQC_adddate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQC_editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_InventoryQC_editdate] DEFAULT (getdate()),
[from_facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[to_facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqc_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqc_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqc_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqc_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqc_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqc_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqc_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqc_UserDefine10] DEFAULT (' '),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InventoryQC_FinalizeFlag] DEFAULT ('N'),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[InventoryQC] ADD CONSTRAINT [PK_InventoryQC] PRIMARY KEY CLUSTERED ([QC_Key]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[InventoryQC] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[InventoryQC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[InventoryQC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[InventoryQC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[InventoryQC] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Inventory QC has been created and modified to accommodate the transfer of stock between different facilities. The current Transfer option only permits internal transfer of stock within the warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer will take place', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is the flag that indicates where the transaction has been finalized', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'FinalizeFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'key in the facility from which the goods will be transferred from', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'from_facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Any additional notes or comments', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'System running number for reference', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'QC_Key'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicate the type of transfer', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'Reason'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is used to store the reference number (if any)', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'Refno'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of Customer', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Key in the destination facility', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'to_facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicate the return document number', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQC', 'COLUMN', N'TradeReturnKey'
GO
