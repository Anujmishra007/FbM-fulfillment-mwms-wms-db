CREATE TABLE [RDT].[rdtCPVKitLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[GroupKey] [int] NOT NULL CONSTRAINT [DF_rdtCPVKitLog_GroupKey] DEFAULT ((0)),
[Mobile] [int] NOT NULL,
[KitKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExpectedQTY] [int] NOT NULL,
[QTY] [int] NOT NULL,
[Barcode] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCPVKitLog_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCPVKitLog_Lottable08] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCPVKitLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtCPVKitLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCPVKitLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtCPVKitLog_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtCPVKitLog] ADD CONSTRAINT [PK_rdtCPVKitLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtCPVKitLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtCPVKitLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtCPVKitLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtCPVKitLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'CPV scanned 2D barcode data for kitting.', 'SCHEMA', N'RDT', 'TABLE', N'rdtCPVKitLog', NULL, NULL
GO
