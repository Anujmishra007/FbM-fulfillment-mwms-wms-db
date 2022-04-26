

CREATE TABLE rdt.rdtECOMQABatchLog 
(
   RowRef         INT            NOT NULL IDENTITY( 1, 1), 
   Mobile         INT            NOT NULL, 
   BatchNo        NVARCHAR( 10)  NOT NULL, 
   Station        NVARCHAR( 10)  NOT NULL, 
   OrderKey       NVARCHAR( 10)  NOT NULL, 
   StorerKey      NVARCHAR( 15)  NOT NULL, 
   SKU            NVARCHAR( 20)  NOT NULL, 
   QTYExpected    INT            NOT NULL, 
   QTY            INT            NOT NULL CONSTRAINT DF_rdtECOMQABatchLog_QTY      DEFAULT (0), 
   AddWho         NVARCHAR( 128) NOT NULL CONSTRAINT DF_rdtECOMQABatchLog_AddWho   DEFAULT (SUSER_SNAME()), 
   AddDate        DATETIME       NOT NULL CONSTRAINT DF_rdtECOMQABatchLog_AddDate  DEFAULT (GETDATE()), 
   EditWho        NVARCHAR( 128) NOT NULL CONSTRAINT DF_rdtECOMQABatchLog_EditWho  DEFAULT (SUSER_SNAME()), 
   EditDate       DATETIME       NOT NULL CONSTRAINT DF_rdtECOMQABatchLog_EditDate DEFAULT (GETDATE()), 
   CONSTRAINT PK_rdtECOMQABatchLog PRIMARY KEY CLUSTERED (RowRef)
)
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON rdt.rdtECOMQABatchLog TO NSQL
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'Table use by RDT ECOM QA Batch (FN650)',
    @level0type = N'Schema', @level0name = rdt, 
    @level1type = N'Table',  @level1name = rdtECOMQABatchLog
GO
