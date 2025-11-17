-- UWP-43698 Create RDTMOBTraceID table to log TraceID for each mobile request
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[RDTMOBTraceID]') AND type in (N'U'))
BEGIN
 CREATE TABLE [RDT].[RDTMOBTraceID]
   (
      [Mobile] [int] NOT NULL,
      [UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBTraceID_UserName] DEFAULT ('RDT'),
      [TraceID] [nvarchar](100)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMOBTraceID_TraceID] DEFAULT(''),
      [InTime] [datetime] NULL CONSTRAINT [DF_RDTMOBTraceID_InTime] DEFAULT (GETDATE()),
      [OutTime] [datetime] NULL CONSTRAINT [DF_RDTMOBTraceID_OutTime] DEFAULT (GETDATE()),
      [Message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
      [MessageOut] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
   ) ON [PRIMARY]

   ALTER TABLE [RDT].[RDTMOBTraceID] ADD CONSTRAINT [PK_RDTMOBTraceID] PRIMARY KEY CLUSTERED ([Mobile]) WITH (FILLFACTOR=90) ON [PRIMARY]

   IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[RDT].[RDTMOBTraceID]') AND name = N'IX_RDTMOBTraceID_Username')
      CREATE NONCLUSTERED INDEX [IX_RDTMOBTraceID_Username] ON [RDT].[RDTMOBTraceID] ([UserName]) ON [PRIMARY]

   IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[RDT].[RDTMOBTraceID]') AND name = N'IX_RDTMOBTraceID_TraceID')
      CREATE NONCLUSTERED INDEX [IX_RDTMOBTraceID_TraceID] ON [RDT].[RDTMOBTraceID] ([TraceID]) ON [PRIMARY]

   GRANT DELETE ON  [RDT].[RDTMOBTraceID] TO [NSQL]
   GRANT INSERT ON  [RDT].[RDTMOBTraceID] TO [NSQL]
   GRANT SELECT ON  [RDT].[RDTMOBTraceID] TO [NSQL]
   GRANT UPDATE ON  [RDT].[RDTMOBTraceID] TO [NSQL]
END
