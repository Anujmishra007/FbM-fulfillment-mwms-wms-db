CREATE TABLE [RDT].[rdtCPVAdjustmentLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[ADJKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCPVAdjustmentLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtCPVAdjustmentLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCPVAdjustmentLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtCPVAdjustmentLog_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtCPVAdjustmentLog] ADD CONSTRAINT [PK_rdtCPVAdjustmentLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtCPVAdjustmentLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtCPVAdjustmentLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtCPVAdjustmentLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtCPVAdjustmentLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'CPV scanned 2D barcode data for adjustment.', 'SCHEMA', N'RDT', 'TABLE', N'rdtCPVAdjustmentLog', NULL, NULL
GO
