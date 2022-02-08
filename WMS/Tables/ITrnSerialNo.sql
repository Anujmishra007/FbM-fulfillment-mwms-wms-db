CREATE TABLE [dbo].[ITrnSerialNo]
(
[ITrnSerialNoKey] [bigint] NOT NULL IDENTITY(1, 1),
[ITrnKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ITrnSerialNo_AddDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ITrnSerialNo] ADD CONSTRAINT [PK_ITrnSerialNo] PRIMARY KEY CLUSTERED ([ITrnSerialNoKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ITrnSerialNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ITrnSerialNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ITrnSerialNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ITrnSerialNo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'ITrn for serial no (record inserted when QTY belong to serial no changed)', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Link to ITrn.ITrnKey', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'ITrnKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'QTY this serial no represent (could be more than 1)', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'QTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Document + line that trigger insert this record', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Stored procedure that insert this record', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'SourceType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Same as ITrn.TranType (currently only DP=Deposit)', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'TranType'
GO
