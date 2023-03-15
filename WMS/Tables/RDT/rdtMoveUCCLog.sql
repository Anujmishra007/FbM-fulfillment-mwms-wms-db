-- drop table rdt.rdtMoveUCCLog
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'rdtMoveUCCLog')
   CREATE TABLE rdt.rdtMoveUCCLog 
   (
      RowRef      INT IDENTITY(1,1) NOT NULL,
      StorerKey   NVARCHAR(15)      NOT NULL, 
      RecNo       INT               NOT NULL, 
      UCCNo       NVARCHAR(20)      NOT NULL, 
      AddWho      NVARCHAR(128)     NOT NULL CONSTRAINT DF_rdtMoveUCCLog_AddWho     DEFAULT (SUSER_NAME()),
      AddDate     DATETIME          NOT NULL CONSTRAINT DF_rdtMoveUCCLog_AddDate    DEFAULT (GETDATE()),
      CONSTRAINT PK_rdtMoveUCCLog PRIMARY KEY CLUSTERED (RowRef)
   )
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON rdt.rdtMoveUCCLog TO NSQL
GO

/*
IF NOT EXISTS (select 1 from sys.sysindexes where name = 'IX_rdtMoveUCCLog01')
   CREATE UNIQUE INDEX IX_rdtMoveUCCLog01 ON rdt.rdtMoveUCCLog (UCCNo, StorerKey)
GO
*/

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'Move UCC module, temporary table containing UCC to be moved',
    @level0type = N'Schema', @level0name = RDT, 
    @level1type = N'Table',  @level1name = rdtMoveUCCLog;
GO
