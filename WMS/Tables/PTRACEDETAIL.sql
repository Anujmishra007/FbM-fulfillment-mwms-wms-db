CREATE TABLE [dbo].[PTRACEDETAIL]
(
[PTRACETYPE] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PTRACEHEADKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PA_PutawayStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PA_PutawayStrategyLineNumber] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PTraceDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Reason] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PTRACEDETAIL] ADD CONSTRAINT [PKPTRACEDETAIL] PRIMARY KEY CLUSTERED ([PTRACEHEADKey], [PTraceDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PTRACEDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PTRACEDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PTRACEDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PTRACEDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying location.', 'SCHEMA', N'dbo', 'TABLE', N'PTRACEDETAIL', 'COLUMN', N'LocKey'
GO
