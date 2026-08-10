-- drop table rdt.rdtPutawaySkipLOCLog
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'rdtPutawaySkipLOCLog')
   CREATE TABLE rdt.rdtPutawaySkipLOCLog 
   (
      RowRef      INT IDENTITY(1,1) NOT NULL,
      Mobile      INT               NOT NULL,
      Func        INT               NOT NULL,
      LOC         NVARCHAR(10)      NOT NULL, 
      AddWho      NVARCHAR(128)     NOT NULL CONSTRAINT DF_rdtPutawaySkipLOCLog_AddWho     DEFAULT (SUSER_NAME()),
      AddDate     DATETIME          NOT NULL CONSTRAINT DF_rdtPutawaySkipLOCLog_AddDate    DEFAULT (GETDATE()),
      CONSTRAINT PK_rdtPutawaySkipLOCLog PRIMARY KEY CLUSTERED (RowRef)
   )
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON rdt.rdtPutawaySkipLOCLog TO NSQL
GO

IF NOT EXISTS (select 1 from sys.sysindexes where name = 'IX_rdtPutawaySkipLOCLog01')
   CREATE INDEX IX_rdtPutawaySkipLOCLog01 ON rdt.rdtPutawaySkipLOCLog (LOC, Func, Mobile)
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'Temporary table used in putaway skip LOC feature',
    @level0type = N'Schema', @level0name = RDT, 
    @level1type = N'Table',  @level1name = rdtPutawaySkipLOCLog;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'RowRef',
    @level0type = N'Schema', @level0name = RDT, 
    @level1type = N'Table',  @level1name = rdtPutawaySkipLOCLog, 
    @level2type = N'Column', @level2name = RowRef;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'Mobile',
    @level0type = N'Schema', @level0name = RDT, 
    @level1type = N'Table',  @level1name = rdtPutawaySkipLOCLog, 
    @level2type = N'Column', @level2name = Mobile;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'Func',
    @level0type = N'Schema', @level0name = RDT, 
    @level1type = N'Table',  @level1name = rdtPutawaySkipLOCLog, 
    @level2type = N'Column', @level2name = Func;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'LOC',
    @level0type = N'Schema', @level0name = RDT, 
    @level1type = N'Table',  @level1name = rdtPutawaySkipLOCLog, 
    @level2type = N'Column', @level2name = LOC;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'AddWho',
    @level0type = N'Schema', @level0name = RDT, 
    @level1type = N'Table',  @level1name = rdtPutawaySkipLOCLog, 
    @level2type = N'Column', @level2name = AddWho;
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'AddDate',
    @level0type = N'Schema', @level0name = RDT, 
    @level1type = N'Table',  @level1name = rdtPutawaySkipLOCLog, 
    @level2type = N'Column', @level2name = AddDate;
GO