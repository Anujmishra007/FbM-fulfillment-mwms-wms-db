IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[RDTTRace]') AND type in (N'U'))
BEGIN
    CREATE TABLE [RDT].[RDTTRace]
    (
    [Mobile] [int] NOT NULL,
    [InFunc] [int] NOT NULL CONSTRAINT [DF_RDTTRace_InFunc] DEFAULT ((0)),
    [InScn] [int] NOT NULL CONSTRAINT [DF_RDTTRace_InScn] DEFAULT ((0)),
    [InStep] [int] NOT NULL CONSTRAINT [DF_RDTTRace_InStep] DEFAULT ((0)),
    [OutFunc] [int] NOT NULL CONSTRAINT [DF_RDTTRace_OutFunc] DEFAULT ((0)),
    [OutScn] [int] NOT NULL CONSTRAINT [DF_RDTTRace_OutScn] DEFAULT ((0)),
    [OutStep] [int] NOT NULL CONSTRAINT [DF_RDTTRace_OutStep] DEFAULT ((0)),
    [Usr] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTTRace_Usr] DEFAULT (suser_sname()),
    [StartTime] [datetime] NOT NULL CONSTRAINT [DF_RDTTRace_StartTime] DEFAULT (getdate()),
    [EndTime] [datetime] NOT NULL CONSTRAINT [DF_RDTTRace_EndTime] DEFAULT (getdate()),
    [TimeTaken] [int] NULL CONSTRAINT [DF_RDTTRace_TimeTaken] DEFAULT ((0)),
    [ROWREF] [int] NOT NULL IDENTITY(1, 1),
    [ScnTime] [int] NULL CONSTRAINT [DF_RDTTRace_ScnTime] DEFAULT ((0))
    ) ON [PRIMARY]
    
    ALTER TABLE [RDT].[RDTTRace] ADD CONSTRAINT [PKRDTTRace] PRIMARY KEY CLUSTERED ([ROWREF]) WITH (FILLFACTOR=90) ON [PRIMARY]
    
    GRANT SELECT ON  [RDT].[RDTTRace] TO [JReportRole]
    
    GRANT DELETE ON  [RDT].[RDTTRace] TO [NSQL]
    
    GRANT INSERT ON  [RDT].[RDTTRace] TO [NSQL]
    
    GRANT SELECT ON  [RDT].[RDTTRace] TO [NSQL]
    
    GRANT UPDATE ON  [RDT].[RDTTRace] TO [NSQL]
    
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('rdt.RDTTRace') AND name = 'TraceID')
    ALTER TABLE [RDT].[RDTTRace] ADD [TraceID] NVARCHAR(100) NULL;
