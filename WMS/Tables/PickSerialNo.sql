
-- drop table dbo.PickSerialNo
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PickSerialNo')
   CREATE TABLE dbo.PickSerialNo
   (
      PickSerialNoKey      BIGINT        NOT NULL IDENTITY( 1, 1), 
      PickDetailKey        NVARCHAR(18)  NOT NULL,
      StorerKey            NVARCHAR(15)  NOT NULL, 
      SKU                  NVARCHAR(20)  NOT NULL, 
      SerialNo             NVARCHAR(30)  NOT NULL, 
      QTY                  INT           NOT NULL, 
      -- ID                   NVARCHAR(18) NOT NULL, 
      AddWho               NVARCHAR(128) NOT NULL CONSTRAINT DF_PickSerialNo_AddWho   DEFAULT (SUSER_SNAME()), 
      AddDate              DATETIME      NOT NULL CONSTRAINT DF_PickSerialNo_AddDate  DEFAULT (GETDATE()), 
      EditWho              NVARCHAR(128) NOT NULL CONSTRAINT DF_PickSerialNo_EditWho  DEFAULT (SUSER_SNAME()), 
      EditDate             DATETIME      NOT NULL CONSTRAINT DF_PickSerialNo_EditDate DEFAULT (GETDATE()), 
      TrafficCop           NVARCHAR( 1)  NULL, 
      ArchiveCop           NVARCHAR( 1)  NULL, 
      CONSTRAINT PK_PickSerialNo PRIMARY KEY CLUSTERED (PickSerialNoKey)
   )
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.PickSerialNo TO NSQL
GO

IF NOT EXISTS (select 1 from sys.sysindexes where name = 'IX_PickSerialNo_PickDetailKey')
   CREATE INDEX IX_PickSerialNo_PickDetailKey ON dbo.PickSerialNo (PickDetailKey)
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'Serial no of a pick detail line',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'PickSerialNoKey',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = PickSerialNoKey;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'PickDetailKey',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = PickDetailKey;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'StorerKey',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = StorerKey;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'SKU',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = SKU;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'SerialNo',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = SerialNo;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'QTY',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = QTY;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'AddWho',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = AddWho;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'AddDate',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = AddDate;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'EditWho',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = EditWho;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'EditDate',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = EditDate;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'TrafficCop',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = TrafficCop;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'ArchiveCop',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = ArchiveCop;
GO
