CREATE TABLE [RDT].[rdtCPVOrderLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[Barcode] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Remark] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCPVOrderLog_Remark] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCPVOrderLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtCPVOrderLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtCPVOrderLog] ADD CONSTRAINT [PK_rdtCPVOrderLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtCPVOrderLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtCPVOrderLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtCPVOrderLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtCPVOrderLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Employee ID must be unique.', 'SCHEMA', N'RDT', 'TABLE', N'rdtCPVOrderLog', NULL, NULL
GO
