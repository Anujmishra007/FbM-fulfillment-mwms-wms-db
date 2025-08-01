
IF NOT EXISTS( SELECT 1 FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID = 649 AND Message_Type = 'FNC')
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType) 
   VALUES (649, 'ENG', 'FNC', 'Bundle SKU', 'rdtfnc_BundleSKU', 1)
GO

-- DROP TABLE rdt.rdtBundleSKULog
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'rdtBundleSKULog')
   CREATE TABLE rdt.rdtBundleSKULog 
   (
      RowRef         INT            NOT NULL IDENTITY( 1, 1), 
      GroupKey       INT            NOT NULL CONSTRAINT DF_rdtBundleSKULog_GroupKey DEFAULT (0), 
      Mobile         INT            NOT NULL, 
      WorkOrderKey   NVARCHAR(10)   NOT NULL, 
      Type           NVARCHAR(5)    NOT NULL, 
      StorerKey      NVARCHAR(15)   NOT NULL, 
      SKU            NVARCHAR(20)   NOT NULL, 
      QTY            INT            NOT NULL, 
      SerialNo       NVARCHAR(50)   NOT NULL, 
      UserDefine01   NVARCHAR(18)   NOT NULL CONSTRAINT DF_rdtBundleSKULog_UserDefine01 DEFAULT (''), 
      UserDefine02   NVARCHAR(18)   NOT NULL CONSTRAINT DF_rdtBundleSKULog_UserDefine02 DEFAULT (''), 
      AddWho         NVARCHAR(18)   NOT NULL CONSTRAINT DF_rdtBundleSKULog_AddWho       DEFAULT (SUSER_SNAME()), 
      AddDate        DATETIME       NOT NULL CONSTRAINT DF_rdtBundleSKULog_AddDate      DEFAULT (GETDATE()), 
      EditWho        NVARCHAR(18)   NOT NULL CONSTRAINT DF_rdtBundleSKULog_EditWho      DEFAULT (SUSER_SNAME()), 
      EditDate       DATETIME       NOT NULL CONSTRAINT DF_rdtBundleSKULog_EditDate     DEFAULT (GETDATE()), 
      CONSTRAINT PK_rdtBundleSKULog PRIMARY KEY CLUSTERED (RowRef)
   )
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON rdt.rdtBundleSKULog TO NSQL
GO


IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'RDT', N'TABLE',N'rdtBundleSKULog', NULL,NULL))
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'Logitech bundle SKU (kitting)',
    @level0type = N'Schema', @level0name = rdt, 
    @level1type = N'Table',  @level1name = rdtBundleSKULog;
GO


-- ALTER COLUMN

	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'AddWho' AND Object_ID = Object_ID('RDT.rdtBundleSKULog') and max_length < 500)
   BEGIN
      ALTER table rdt.rdtBundleSKULog
      ALTER column  AddWho nvarchar(128) NULL
   END
	IF EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'EditWho' AND Object_ID = Object_ID('RDT.rdtBundleSKULog') and max_length < 500)
   BEGIN
      ALTER table rdt.rdtBundleSKULog
      ALTER column  EditWho nvarchar(128) NULL
   END

GO