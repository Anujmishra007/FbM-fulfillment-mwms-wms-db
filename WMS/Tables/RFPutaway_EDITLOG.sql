-- DROP TABLE dbo.RFPutaway_EDITLOG                                                           
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'RFPutaway_EDITLOG')
   CREATE TABLE dbo.RFPutaway_EDITLOG
   (
      EditLogKey        BIGINT IDENTITY( 1, 1) NOT NULL, 
   	StorerKey         NVARCHAR(15)   NOT NULL,
   	SKU               NVARCHAR(20)   NOT NULL,
   	LOT               NVARCHAR(10)   NOT NULL,
   	FromLOC           NVARCHAR(10)   NOT NULL,
   	SuggestedLOC      NVARCHAR(10)   NOT NULL,
   	ID                NVARCHAR(18)   NULL,
   	ptcid             NVARCHAR(18)   NOT NULL,
   	QTY               INT            NOT NULL,
   	AddDate           DATETIME       NULL,
   	AddWho            NVARCHAR(128)  NULL,
   	TrafficCop        NVARCHAR(1)    NULL,
   	ArchiveCop        NVARCHAR(1)    NULL,
   	CaseID            NVARCHAR(20)   NOT NULL,
   	FromID            NVARCHAR(20)   NOT NULL,
   	RowRef            INT            NOT NULL,
   	TaskDetailKey     NVARCHAR(10)   NOT NULL,
   	Func              INT            NOT NULL,
   	PABookingKey      INT            NOT NULL,
   	QTYPrinted        INT            NOT NULL,
   	EditDate          DATETIME       NULL,
   	EditWho           NVARCHAR(128)  NULL,
   	Receiptkey        NVARCHAR(10)   NULL,
   	ReceiptLineNumber NVARCHAR(5)    NULL,
   	UDF01             NVARCHAR(60)   NULL,
   	UDF02             NVARCHAR(60)   NULL,
   	UDF03             NVARCHAR(60)   NULL,
      CONSTRAINT PK_RFPutaway_EDITLOG PRIMARY KEY CLUSTERED (EditLogKey)
   )
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.RFPutaway_EDITLOG TO NSQL
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = 'RFPutaway update trigger insert the original record (before edit) into this table',
    @level0type = N'Schema', @level0name = dbo, 
    @level1type = N'Table',  @level1name = RFPutaway_EDITLOG;
GO
