CREATE TABLE [RDT].[rdtReceiveSerialNoLog]
(
[ReceiveSerialNoLogKey] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[Func] [int] NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReceiveSerialNoLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtReceiveSerialNoLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReceiveSerialNoLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtReceiveSerialNoLog_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtReceiveSerialNoLog] ADD CONSTRAINT [PK_rdtReceiveSerialNoLog] PRIMARY KEY CLUSTERED ([ReceiveSerialNoLogKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtReceiveSerialNoLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtReceiveSerialNoLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtReceiveSerialNoLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtReceiveSerialNoLog] TO [NSQL]
GO
