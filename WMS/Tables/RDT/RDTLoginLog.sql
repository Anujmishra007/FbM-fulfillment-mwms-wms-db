IF NOT EXISTS (SELECT 1
FROM sys.tables
WHERE name = 'RDTLoginLog' AND type = 'U')
BEGIN
   CREATE TABLE [RDT].[RDTLoginLog]
   (
   [RowRef] [int] NOT NULL IDENTITY(1, 1),
   [Mobile] [int] NOT NULL,
   [UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
   [ClientIP] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
   [Remarks] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTLoginLog_Remarks] DEFAULT (''),
   [AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDTLoginLog_AddDate] DEFAULT (getdate())
   ) ON [PRIMARY]

   ALTER TABLE [RDT].[RDTLoginLog] ADD CONSTRAINT [PK_RDTLoginLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]

   GRANT DELETE ON  [RDT].[RDTLoginLog] TO [NSQL]
   GRANT INSERT ON  [RDT].[RDTLoginLog] TO [NSQL]
   GRANT SELECT ON  [RDT].[RDTLoginLog] TO [NSQL]
   GRANT UPDATE ON  [RDT].[RDTLoginLog] TO [NSQL]
END
ELSE
BEGIN
   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTLoginLog' AND COLUMN_NAME = 'SessionID')
   BEGIN
      ALTER TABLE RDT.RDTLoginLog ADD SessionID NVARCHAR(60) NULL
      EXEC sp_addextendedproperty N'MS_Description', 'Session ID for RDT device', 'SCHEMA', N'RDT', 'TABLE', N'RDTLoginLog', 'COLUMN', N'SessionID'
   END
END
