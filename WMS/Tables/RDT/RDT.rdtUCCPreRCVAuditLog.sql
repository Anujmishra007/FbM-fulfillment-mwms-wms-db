CREATE TABLE [RDT].[rdtUCCPreRCVAuditLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[NewUCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_NewUCCNo] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_StorerKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_SKU] DEFAULT (''),
[QTY] [int] NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_QTY] DEFAULT ((0)),
[OrgUCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_OrgUCCNo] DEFAULT (''),
[ExternKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_ExternKey] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_Status] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtUCCPreRCVAuditLog_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtUCCPreRCVAuditLog] ADD CONSTRAINT [PK_rdtUCCPreRCVAuditLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtUCCPreRCVAuditLog_TrolleyNo_UCCNo] ON [RDT].[rdtUCCPreRCVAuditLog] ([NewUCCNo], [StorerKey], [SKU]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtUCCPreRCVAuditLog_RefNo1_StorerKey] ON [RDT].[rdtUCCPreRCVAuditLog] ([OrgUCCNo], [StorerKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtUCCPreRCVAuditLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtUCCPreRCVAuditLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtUCCPreRCVAuditLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtUCCPreRCVAuditLog] TO [NSQL]
GO
