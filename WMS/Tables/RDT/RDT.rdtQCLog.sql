CREATE TABLE [RDT].[rdtQCLog]
(
[SeqNo] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCLog_StorerKey] DEFAULT (' '),
[PalletID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCLog_PalletID] DEFAULT (' '),
[ScanNo] [int] NOT NULL CONSTRAINT [DF_rdtQCLog_ScanNo] DEFAULT ((0)),
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCLog_TranType] DEFAULT (' '),
[CartonID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCLog_CartonID] DEFAULT (' '),
[TriageFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCLog_TriageFlag] DEFAULT ('N'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCLog_AddWho] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtQCLog_AddDate] DEFAULT (getdate()),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCLog_Status] DEFAULT ('0'),
[MissingCtn] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCLog_MissingCtn] DEFAULT (' '),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Completed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCLog_Completed] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtQCLog] ADD CONSTRAINT [PK_rdtQCLog] PRIMARY KEY CLUSTERED ([SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_rdtQCLog_PalletID_CartonID] ON [RDT].[rdtQCLog] ([PalletID], [CartonID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtQCLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtQCLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtQCLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtQCLog] TO [NSQL]
GO
