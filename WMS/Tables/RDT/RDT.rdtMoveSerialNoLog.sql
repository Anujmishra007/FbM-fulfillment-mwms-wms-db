CREATE TABLE [RDT].[rdtMoveSerialNoLog]
(
[MoveSerialNoLogKey] [bigint] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[Func] [int] NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMoveSerialNoLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtMoveSerialNoLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMoveSerialNoLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtMoveSerialNoLog_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtMoveSerialNoLog] ADD CONSTRAINT [PK_rdtMoveSerialNoLog] PRIMARY KEY CLUSTERED ([MoveSerialNoLogKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtMoveSerialNoLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtMoveSerialNoLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtMoveSerialNoLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtMoveSerialNoLog] TO [NSQL]
GO
