
CREATE TABLE [dbo].[ASN_UCC_ENRICHMENT_FAILURE]
(
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [UCCNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [UCCRowRef] int NOT NULL,
    [FailureReason] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [FailureCategory] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [DetectedAt] [datetime] NOT NULL CONSTRAINT [DF_ASN_UCC_ENRICHMENT_FAILURE_DetectedAt] DEFAULT (getdate()),
    [ResolvedFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ASN_UCC_ENRICHMENT_FAILURE_ResolvedFlag] DEFAULT ('N'),
    [ResolvedAt] [datetime] NULL,
    [ResolvedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AddDate] [datetime] NOT NULL CONSTRAINT [DF_ASN_UCC_ENRICHMENT_FAILURE_AddDate] DEFAULT (getdate()),
    [AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ASN_UCC_ENRICHMENT_FAILURE_AddWho] DEFAULT (suser_sname()),
    [EditDate] [datetime] NULL,
    [EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    ) ON [PRIMARY]
    GO

ALTER TABLE [dbo].[ASN_UCC_ENRICHMENT_FAILURE] ADD CONSTRAINT [PKASN_UCC_ENRICHMENT_FAILURE] PRIMARY KEY CLUSTERED ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
    GO

ALTER TABLE [dbo].[ASN_UCC_ENRICHMENT_FAILURE] ADD CONSTRAINT [UQ_ASN_UCC_FAIL] UNIQUE NONCLUSTERED (ReceiptKey, UCCNo, FailureCategory)
    GO

-- Supports CompletionGateService.evaluate() -> countUnresolved()/resolveIfNowMatched()
-- (the most frequently executed query in the entire feature)
CREATE INDEX IX_ASN_UCC_FAIL_Receipt ON [dbo].[ASN_UCC_ENRICHMENT_FAILURE] (ReceiptKey, ResolvedFlag)
    GO

    GRANT SELECT ON [dbo].[ASN_UCC_ENRICHMENT_FAILURE] TO [JReportRole]
    GO
    GRANT DELETE ON [dbo].[ASN_UCC_ENRICHMENT_FAILURE] TO [NSQL]
GO
GRANT INSERT ON [dbo].[ASN_UCC_ENRICHMENT_FAILURE] TO [NSQL]
GO
GRANT SELECT ON [dbo].[ASN_UCC_ENRICHMENT_FAILURE] TO [NSQL]
    GO
    GRANT UPDATE ON [dbo].[ASN_UCC_ENRICHMENT_FAILURE] TO [NSQL]
              GO

              EXEC sp_addextendedproperty N'MS_Description', 'Records individual UCC-to-RECEIPTDETAIL enrichment mismatches/failures that require manual resolution or are auto-resolved once matching UCC data becomes available.', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', NULL, NULL
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Surrogate identity key for this failure record', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'Id'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Receipt number this failure is associated with, references RECEIPT.ReceiptKey', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'ReceiptKey'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'UCC number that could not be matched/enriched', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'UCCNo'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'UCC_RowRef number that could not be matched/enriched', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'UCCRowRef'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Human-readable description of why enrichment failed', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'FailureReason'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Failure classification, e.g. UNMATCHED, MISMATCHED', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'FailureCategory'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Timestamp when this failure was first detected', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'DetectedAt'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Y/N flag indicating whether this failure has since been resolved', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'ResolvedFlag'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Timestamp when this failure was resolved', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'ResolvedAt'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Username/login ID or system process that resolved this failure', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'ResolvedBy'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'TrafficCop'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Archive control flag', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'ArchiveCop'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'TimeStamp'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'AddDate'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'AddWho'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'EditDate'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_ENRICHMENT_FAILURE', 'COLUMN', N'EditWho'
              GO