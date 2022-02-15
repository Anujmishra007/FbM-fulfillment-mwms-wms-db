CREATE TABLE [RDT].[rdtPPALog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPALog_PickSlipNo] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPALog_OrderKey] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPALog_StorerKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPALog_SKU] DEFAULT (''),
[PQTY] [int] NOT NULL CONSTRAINT [DF_rdtPPALog_PQTY] DEFAULT ((0)),
[CQTY] [int] NOT NULL CONSTRAINT [DF_rdtPPALog_CQTY] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPALog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPPALog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPALog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPPALog_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPPALog] ADD CONSTRAINT [PK_rdtPPALog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPPALog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPPALog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPPALog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPPALog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'PPA by cases and pieces, instead of lum sum total.', 'SCHEMA', N'RDT', 'TABLE', N'rdtPPALog', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Check QTY', 'SCHEMA', N'RDT', 'TABLE', N'rdtPPALog', 'COLUMN', N'CQTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick QTY', 'SCHEMA', N'RDT', 'TABLE', N'rdtPPALog', 'COLUMN', N'PQTY'
GO
