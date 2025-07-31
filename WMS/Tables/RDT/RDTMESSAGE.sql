IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[RDTMESSAGE]') AND type in (N'U'))
BEGIN
    CREATE TABLE [RDT].[RDTMESSAGE]
    (
    [SeqNo] [int] NOT NULL IDENTITY(1, 1),
    [Mobile] [int] NOT NULL,
    [Message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [MessageOut] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AddDate] [datetime] NULL CONSTRAINT [DF_RDTMESSAGE_AddDate] DEFAULT (getdate()),
    [InFunc] [int] NULL,
    [InScn] [int] NULL,
    [InStep] [int] NULL,
    [TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [HashValue] [tinyint] NOT NULL CONSTRAINT [DF_RDTMessage_HashValue] DEFAULT (abs(checksum(newid())%(256)))
    ) ON [PRIMARY]
    
    ALTER TABLE [RDT].[RDTMESSAGE] ADD CONSTRAINT [PKRDTMESSAGE] PRIMARY KEY NONCLUSTERED ([SeqNo]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
    
    CREATE CLUSTERED INDEX [IX_RDTMessage_HashValue] ON [RDT].[RDTMESSAGE] ([HashValue], [SeqNo]) ON [PRIMARY]
    
    GRANT DELETE ON  [RDT].[RDTMESSAGE] TO [NSQL]
    
    GRANT INSERT ON  [RDT].[RDTMESSAGE] TO [NSQL]
    
    GRANT SELECT ON  [RDT].[RDTMESSAGE] TO [NSQL]
    
    GRANT UPDATE ON  [RDT].[RDTMESSAGE] TO [NSQL]
    
END
ELSE
BEGIN
    ALTER TABLE [RDT].[RDTMESSAGE] ADD [TraceID] [nvarchar] (100) NULL
END