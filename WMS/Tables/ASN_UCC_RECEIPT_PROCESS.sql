CREATE TABLE [dbo].[ASN_UCC_RECEIPT_PROCESS]
(
    [ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ASN_UCC_RECEIPT_PROCESS_StorerKey] DEFAULT (' '),
    [Facility] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ASN_UCC_RECEIPT_PROCESS_Facility] DEFAULT (' '),
    [Scenario] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Status] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ExpectedCount] [int] NULL,
    [MatchedCount] [int] NULL,
    [EnrichedCount] [int] NULL,
    [RetryCount] [int] NOT NULL CONSTRAINT [DF_ASN_UCC_RECEIPT_PROCESS_RetryCount] DEFAULT (0),
    [LockedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [LockTime] [datetime] NULL,
    [SlaDeadline] [datetime] NULL,
    [SlaBreached] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ASN_UCC_RECEIPT_PROCESS_SlaBreached] DEFAULT ('N'),
    [LastError] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [StartTime] [datetime] NULL,
    [EndTime] [datetime] NULL,
    [TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AddDate] [datetime] NOT NULL CONSTRAINT [DF_ASN_UCC_RECEIPT_PROCESS_AddDate] DEFAULT (getdate()),
    [AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ASN_UCC_RECEIPT_PROCESS_AddWho] DEFAULT (suser_sname()),
    [EditDate] [datetime] NULL,
    [EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    ) ON [PRIMARY]
    GO

ALTER TABLE [dbo].[ASN_UCC_RECEIPT_PROCESS] ADD CONSTRAINT [PKASN_UCC_RECEIPT_PROCESS] PRIMARY KEY CLUSTERED ([ReceiptKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
    GO

-- Supports RecoveryScheduler.findStaleProcessing()
CREATE INDEX IX_ASN_UCC_RECEIPT_PROCESS_Status_LockTime
    ON [dbo].[ASN_UCC_RECEIPT_PROCESS] (Status, LockTime)
    GO

-- Supports SlaScheduler.findSlaBreaches()
CREATE INDEX IX_ASN_UCC_RECEIPT_PROCESS_Status_Sla
    ON [dbo].[ASN_UCC_RECEIPT_PROCESS] (Status, SlaBreached, SlaDeadline)
    GO

    GRANT SELECT ON [dbo].[ASN_UCC_RECEIPT_PROCESS] TO [JReportRole]
    GO
    GRANT DELETE ON [dbo].[ASN_UCC_RECEIPT_PROCESS] TO [NSQL]
GO
GRANT INSERT ON [dbo].[ASN_UCC_RECEIPT_PROCESS] TO [NSQL]
GO
GRANT SELECT ON [dbo].[ASN_UCC_RECEIPT_PROCESS] TO [NSQL]
    GO
    GRANT UPDATE ON [dbo].[ASN_UCC_RECEIPT_PROCESS] TO [NSQL]
              GO

              EXEC sp_addextendedproperty N'MS_Description', 'Tracks per-receipt ASN/UCC enrichment processing state, scenario classification, retry/lock ownership, and SLA tracking for the async completion gate.', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', NULL, NULL
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Receipt number - primary key, references RECEIPT.ReceiptKey', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'ReceiptKey'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'owner of the goods', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'StorerKey'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'facility code', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'Facility'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Classified processing scenario: HAPPY_FLOW, SHORT_SHIPMENT, or MISSING_DATA', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'Scenario'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Current processing status: READY, PROCESSING, SUCCESS, FAILED, MANUAL_FIX_REQUIRED', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'Status'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Total number of RECEIPTDETAIL lines expected to be enriched for this receipt', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'ExpectedCount'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Number of RECEIPTDETAIL lines that found a matching UCC record', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'MatchedCount'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Number of RECEIPTDETAIL lines successfully enriched so far (cumulative across chunks)', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'EnrichedCount'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Number of times this receipt has been reclaimed after a stale/crashed processing attempt', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'RetryCount'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Pod/instance identifier that currently holds the processing lock on this receipt', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'LockedBy'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Timestamp when the current processing lock was acquired', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'LockTime'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Deadline by which unresolved enrichment failures must be fixed before SLA is considered breached', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'SlaDeadline'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Y/N flag indicating whether the SlaDeadline has been breached', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'SlaBreached'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Most recent error message recorded for this receipt''s processing attempt', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'LastError'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Timestamp when processing for this receipt started', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'StartTime'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Timestamp when processing for this receipt completed (success or terminal failure)', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'EndTime'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'TrafficCop'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Archive control flag', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'ArchiveCop'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'TimeStamp'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'AddDate'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'AddWho'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'EditDate'
              GO
              EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ASN_UCC_RECEIPT_PROCESS', 'COLUMN', N'EditWho'
              GO