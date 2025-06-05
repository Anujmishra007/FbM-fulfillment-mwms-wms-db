IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'PALLETDETAIL' AND type = 'U')
BEGIN
   CREATE TABLE [dbo].[PALLETDETAIL]
   (
   [PalletKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
   [PalletLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
   [CaseId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETDETAIL_CaseId] DEFAULT (' '),
   [StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_StorerKey] DEFAULT (' '),
   [Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_Sku] DEFAULT (' '),
   [Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_Loc] DEFAULT ('UNKNOWN'),
   [Qty] [int] NOT NULL CONSTRAINT [DF_PALLETDETAIL_Qty] DEFAULT ((0)),
   [Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_Status] DEFAULT ('0'),
   [AddDate] [datetime] NOT NULL CONSTRAINT [DF_PALLETDETAIL_AddDate] DEFAULT (getdate()),
   [AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_AddWho] DEFAULT (suser_sname()),
   [EditDate] [datetime] NOT NULL CONSTRAINT [DF_PALLETDETAIL_EditDate] DEFAULT (getdate()),
   [EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_EditWho] DEFAULT (suser_sname()),
   [TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine01] DEFAULT (''),
   [UserDefine02] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine02] DEFAULT (''),
   [UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine03] DEFAULT (''),
   [UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine04] DEFAULT (''),
   [UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine05] DEFAULT (''),
   [SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETDETAIL_SourceType] DEFAULT (''),
   [SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETDETAIL_Sourcekey] DEFAULT (''),
   [Receiptkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETDETAIL_Receiptkey] DEFAULT (''),
   [ReceiptLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETDETAIL_ReceiptLineNumber] DEFAULT (''),
   [OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETDETAIL_OrderLineNumber] DEFAULT ('')     
   ) ON [PRIMARY]
      
   ALTER TABLE [dbo].[PALLETDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_PALLETDETAIL_Status] CHECK (([Status]>='0' AND [Status]<='9'))
   
   ALTER TABLE [dbo].[PALLETDETAIL] ADD CONSTRAINT [PKPalletDetail] PRIMARY KEY CLUSTERED ([PalletKey], [PalletLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
   
   CREATE NONCLUSTERED INDEX [IDX_PalletDetail01] ON [dbo].[PALLETDETAIL] ([StorerKey], [CaseId]) ON [PRIMARY]
   
   ALTER TABLE [dbo].[PALLETDETAIL] ADD CONSTRAINT [FK_PALLETDETAIL_LOC_01] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
   
   GRANT SELECT ON  [dbo].[PALLETDETAIL] TO [JReportRole]
   
   GRANT DELETE ON  [dbo].[PALLETDETAIL] TO [NSQL]
   
   GRANT INSERT ON  [dbo].[PALLETDETAIL] TO [NSQL]
   
   GRANT SELECT ON  [dbo].[PALLETDETAIL] TO [NSQL]
   
   GRANT UPDATE ON  [dbo].[PALLETDETAIL] TO [NSQL]
   
   EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'AddDate'
   
   EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'AddWho'
   
   EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Case.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'CaseId'
   
   EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'EditDate'
   
   EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'EditWho'
   
   EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'Loc'
   
   EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pallet.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'PalletKey'
   
   EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pallet.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'PalletLineNumber'
   
   EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'Qty'
   
   EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'Sku'
   
   EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'StorerKey'
   
   EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'TrafficCop'   
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT *
                   FROM sys.columns
                   WHERE Name = 'SourceType'
                   AND Object_ID = Object_ID('PALLETDETAIL'))
    BEGIN
        ALTER TABLE PALLETDETAIL
            ADD SourceType NVARCHAR(30) NULL CONSTRAINT [DF_PALLETDETAIL_SourceType] DEFAULT ('');
        EXEC sp_addextendedproperty N'MS_Description', 'I-Inbound O-Outbound U-User Interface etc..', 'SCHEMA', N'dbo', 'TABLE',
             N'PALLETDETAIL', 'COLUMN', N'SourceType'
    END
    
   IF NOT EXISTS (SELECT *
                   FROM sys.columns
                   WHERE Name = 'SourceKey'
                   AND Object_ID = Object_ID('PALLETDETAIL'))
    BEGIN
        ALTER TABLE PALLETDETAIL
            ADD SourceKey NVARCHAR(20) NULL CONSTRAINT [DF_PALLETDETAIL_Sourcekey] DEFAULT ('');
        EXEC sp_addextendedproperty N'MS_Description', 'Type I : Receiptkey + ReceiptLineNumber Type O : Orderkey + OrderLineNumber Type U : Blank etc..', 'SCHEMA', N'dbo', 'TABLE',
             N'PALLETDETAIL', 'COLUMN', N'SourceKey'
    END
    
   IF NOT EXISTS (SELECT *
                   FROM sys.columns
                   WHERE Name = 'Receiptkey'
                   AND Object_ID = Object_ID('PALLETDETAIL'))
    BEGIN
        ALTER TABLE PALLETDETAIL
            ADD Receiptkey NVARCHAR(10) NULL CONSTRAINT [DF_PALLETDETAIL_Receiptkey] DEFAULT ('');
        EXEC sp_addextendedproperty N'MS_Description', 'Linkage to ASN', 'SCHEMA', N'dbo', 'TABLE',
             N'PALLETDETAIL', 'COLUMN', N'Receiptkey'
    END
    
   IF NOT EXISTS (SELECT *
                   FROM sys.columns
                   WHERE Name = 'ReceiptLineNumber'
                   AND Object_ID = Object_ID('PALLETDETAIL'))
    BEGIN
        ALTER TABLE PALLETDETAIL
            ADD ReceiptLineNumber NVARCHAR(5) NULL CONSTRAINT [DF_PALLETDETAIL_ReceiptLineNumber] DEFAULT ('');
        EXEC sp_addextendedproperty N'MS_Description', 'Linkage to ASN line', 'SCHEMA', N'dbo', 'TABLE',
             N'PALLETDETAIL', 'COLUMN', N'ReceiptLineNumber'
    END
    
   IF NOT EXISTS (SELECT *
                   FROM sys.columns
                   WHERE Name = 'OrderLineNumber'
                   AND Object_ID = Object_ID('PALLETDETAIL'))
    BEGIN
        ALTER TABLE PALLETDETAIL
            ADD OrderLineNumber NVARCHAR(5) NULL CONSTRAINT [DF_PALLETDETAIL_OrderLineNumber] DEFAULT ('');
        EXEC sp_addextendedproperty N'MS_Description', 'Linkage to SO line', 'SCHEMA', N'dbo', 'TABLE',
             N'PALLETDETAIL', 'COLUMN', N'OrderLineNumber'
    END                
END


/*  
--  5 May 22022  extend field size UserDefine02

ALTER TABLE dbo.PALLETDETAIL
ALTER COLUMN UserDefine02 NVARCHAR (40) 
GO 

 
*/
