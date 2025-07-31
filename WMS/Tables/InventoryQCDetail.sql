IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'InventoryQCDetail' AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[InventoryQCDetail]
      (
      [QC_Key] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [QCLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [OriginalQty] [numeric] (18, 0) NOT NULL CONSTRAINT [DF_InventoryQCDetail_OriginalQty] DEFAULT ((0)),
      [Qty] [numeric] (18, 0) NOT NULL CONSTRAINT [DF_InventoryQCDetail_Qty] DEFAULT ((0)),
      [FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [FromLot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [FromID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [ToQty] [numeric] (18, 0) NOT NULL CONSTRAINT [DF_InventoryQCDetail_ToQty] DEFAULT ((0)),
      [ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQCDetail_ToID] DEFAULT (' '),
      [ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQCDetail_ToLOC] DEFAULT (' '),
      [Reason] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQCDetail_Reason] DEFAULT (' '),
      [Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQCDetail_Status] DEFAULT ('0'),
      [AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQCDetail_addwho] DEFAULT (suser_sname()),
      [AddDate] [datetime] NOT NULL CONSTRAINT [DF_InventoryQCDetail_adddate] DEFAULT (getdate()),
      [EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQCDetail_editwho] DEFAULT (suser_sname()),
      [EditDate] [datetime] NOT NULL CONSTRAINT [DF_InventoryQCDetail_editdate] DEFAULT (getdate()),
      [TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
      [ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
      [UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqcdetail_UserDefine01] DEFAULT (' '),
      [UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqcdetail_UserDefine02] DEFAULT (' '),
      [UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqcdetail_UserDefine03] DEFAULT (' '),
      [UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqcdetail_UserDefine04] DEFAULT (' '),
      [UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqcdetail_UserDefine05] DEFAULT (' '),
      [UserDefine06] [datetime] NULL,
      [UserDefine07] [datetime] NULL,
      [UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqcdetail_UserDefine08] DEFAULT ('N'),
      [UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqcdetail_UserDefine09] DEFAULT (' '),
      [UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_inventoryqcdetail_UserDefine10] DEFAULT (' '),
      [FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InventoryQCDetail_FinalizeFlag] DEFAULT ('N'),
      [Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_INVENTORYQCDETAIL_Channel] DEFAULT (''),
      [Channel_ID] [bigint] NULL CONSTRAINT [DF_INVENTORYQCDETAIL_Channel_ID] DEFAULT ((0)),
      [FromPalletType] [nvarchar] (10) NOT NULL CONSTRAINT [DF_INVENTORYQCDETAIL_FromPalletType] DEFAULT (''),
      [ToPalletType] [nvarchar] (10) NOT NULL CONSTRAINT [DF_INVENTORYQCDETAIL_ToPalletType] DEFAULT (''),
      [PalletType] [nvarchar] (10) NULL CONSTRAINT [DF_INVENTORYQCDETAIL_PalletType] DEFAULT ('')

      ) ON [PRIMARY]

      GRANT DELETE ON  [dbo].[InventoryQCDetail] TO [NSQL]

      GRANT INSERT ON  [dbo].[InventoryQCDetail] TO [NSQL]

      GRANT SELECT ON  [dbo].[InventoryQCDetail] TO [NSQL]

      GRANT UPDATE ON  [dbo].[InventoryQCDetail] TO [NSQL]


      ALTER TABLE [dbo].[InventoryQCDetail] ADD CONSTRAINT [PK_InventoryQCDetail] PRIMARY KEY CLUSTERED ([QC_Key], [QCLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]

      ALTER TABLE [dbo].[InventoryQCDetail] WITH NOCHECK ADD CONSTRAINT [FK_InventoryQCDetail_SKU_01] FOREIGN KEY ([StorerKey], [SKU]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])

      EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'AddDate'

      EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'AddWho'

      EXEC sp_addextendedproperty N'MS_Description', N'Channel( ECOM, RETAIL )', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'Channel'

      EXEC sp_addextendedproperty N'MS_Description', N'Channel ID', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'Channel_ID'

      EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'EditDate'

      EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'EditWho'

      EXEC sp_addextendedproperty N'MS_Description', 'This is the flag that indicates where the transaction has been finalized', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'FinalizeFlag'

      EXEC sp_addextendedproperty N'MS_Description', 'The pallet id of the stock that you want to transfer (populate once you select the commodity)', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'FromID'

      EXEC sp_addextendedproperty N'MS_Description', 'The location in which the commodity is stored', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'FromLoc'

      EXEC sp_addextendedproperty N'MS_Description', 'The lot number of the stock that you want to transfer (populate once you select the commodity)', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'FromLot'

      EXEC sp_addextendedproperty N'MS_Description', 'The pack code to use for the transferred commodity. The field fills in automatically once you have entered the SKU', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'PackKey'

      EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying QC.', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'QC_Key'

      EXEC sp_addextendedproperty N'MS_Description', 'Document line number', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'QCLineNo'

      EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'Qty'

      EXEC sp_addextendedproperty N'MS_Description', 'The reason for the transfer', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'Reason'

      EXEC sp_addextendedproperty N'MS_Description', 'SKU to be transferred; This can be done by keying in the SKU or you can perform a look up where the system will list the Lot/Location/Movable Unit (LOTxLOCxID) inventory on hand', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'SKU'

      EXEC sp_addextendedproperty N'MS_Description', 'Status will change to ''9'' after completed transfer stock with finalize flag =''Y''', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'Status'

      EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'StorerKey'

      EXEC sp_addextendedproperty N'MS_Description', 'The new pallet id in which the commodity will be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'ToID'

      EXEC sp_addextendedproperty N'MS_Description', 'The location in which the commodity will be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'ToLoc'

      EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'TrafficCop'

      EXEC sp_addextendedproperty N'MS_Description', 'Use default unless you wish to use a different unit of measurement', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UOM'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine01'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine02'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine03'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine04'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine05'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine06', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine06'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine07', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine07'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine08'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine09'

      EXEC sp_addextendedproperty N'MS_Description', 'IQC userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN', N'UserDefine10'

      EXEC sp_addextendedproperty N'MS_Description', 'From Pallet Type' , 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN',N'FromPalletType'

      EXEC sp_addextendedproperty N'MS_Description', 'To Pallet Type' , 'SCHEMA', N'dbo', 'TABLE', N'InventoryQCDetail', 'COLUMN',N' ToPalletType'
 END
 ELSE
     BEGIN
          --IF EXISTS (SELECT 1
 		       --        FROM sys.columns
 		       --        WHERE Name = 'PalletType' AND Object_ID = Object_ID('InventoryQCDetail'))
          --BEGIN
          --    ALTER TABLE INVENTORYQCDETAIL DROP CONSTRAINT DF_INVENTORYQCDETAIL_PalletType;
          --    ALTER TABLE INVENTORYQCDETAIL DROP COLUMN PalletType;
          --END
          IF NOT EXISTS (SELECT *
                             FROM sys.columns
                             WHERE Name = 'FromPalletType'
                               AND Object_ID = Object_ID('InventoryQCDetail'))
                  BEGIN
                      ALTER TABLE InventoryQCDetail
                          ADD FromPalletType NVARCHAR(10) NOT NULL CONSTRAINT [DF_INVENTORYQCDETAIL_FromPalletType] DEFAULT ('');
                      EXEC sp_addextendedproperty N'MS_Description', 'From Pallet Type', 'SCHEMA', N'dbo', 'TABLE',
                           N'InventoryQCDetail', 'COLUMN', N'FromPalletType'
                  END
          IF NOT EXISTS (SELECT *
                             FROM sys.columns
                             WHERE Name = 'ToPalletType'
                               AND Object_ID = Object_ID('InventoryQCDetail'))
                  BEGIN
                      ALTER TABLE InventoryQCDetail
                          ADD ToPalletType NVARCHAR(10) NOT NULL CONSTRAINT [DF_INVENTORYQCDETAIL_ToPalletType] DEFAULT ('');
                      EXEC sp_addextendedproperty N'MS_Description', 'To Pallet Type', 'SCHEMA', N'dbo', 'TABLE',
                           N'InventoryQCDetail', 'COLUMN', N'ToPalletType'
                  END

          IF NOT EXISTS (SELECT *
                             FROM sys.columns
                             WHERE Name = 'PalletType'
                               AND Object_ID = Object_ID('InventoryQCDetail'))
                  BEGIN
                      ALTER TABLE InventoryQCDetail
                      ADD PalletType NVARCHAR(10) NULL CONSTRAINT [DF_INVENTORYQCDETAIL_PalletType] DEFAULT ('');
                      EXEC sp_addextendedproperty N'MS_Description', 'Pallet Type', 'SCHEMA', N'dbo', 'TABLE',
                           N'InventoryQCDetail', 'COLUMN', N'PalletType'
                  END

    END
