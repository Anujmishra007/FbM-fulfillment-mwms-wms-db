
-- drop table dbo.PickSerialNo
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PickSerialNo]') AND type in (N'U'))
BEGIN

CREATE TABLE dbo.PickSerialNo
   (
      PickSerialNoKey      BIGINT        NOT NULL IDENTITY( 1, 1), 
      PickDetailKey        NVARCHAR(36)  NOT NULL,
      StorerKey            NVARCHAR(15)  NOT NULL, 
      SKU                  NVARCHAR(20)  NOT NULL, 
      SerialNo             NVARCHAR(50)  NOT NULL, 
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

GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.PickSerialNo TO NSQL

IF NOT EXISTS (select 1 from sys.sysindexes where name = 'IX_PickSerialNo_PickDetailKey')
   CREATE INDEX IX_PickSerialNo_PickDetailKey ON dbo.PickSerialNo (PickDetailKey)


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'Serial no of a pick detail line',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'PickSerialNoKey',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = PickSerialNoKey;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'PickDetailKey',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = PickDetailKey;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'StorerKey',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = StorerKey;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'SKU',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = SKU;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'SerialNo',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = SerialNo;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'QTY',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = QTY;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'AddWho',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = AddWho;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'AddDate',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = AddDate;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'EditWho',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = EditWho;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'EditDate',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = EditDate;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'TrafficCop',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = TrafficCop;


EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'ArchiveCop',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = PickSerialNo, 
    @level2type = N'Column', @level2name = ArchiveCop;


END

ELSE 
BEGIN

	--ALTER COLUMN 
 IF  EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'PickDetailKey' AND Object_ID = Object_ID('dbo.PickSerialNo') and max_length <>72)
			BEGIN
				ALTER TABLE dbo.PickSerialNo 
				ALTER COLUMN PickDetailKey NVARCHAR(36)  NOT NULL;

			END


 IF  EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'SerialNo' AND Object_ID = Object_ID('dbo.PickSerialNo') and max_length <>100)
			BEGIN
				ALTER TABLE dbo.PickSerialNo 
				ALTER COLUMN SerialNo NVARCHAR(50) NOT NULL;
			END

END 
