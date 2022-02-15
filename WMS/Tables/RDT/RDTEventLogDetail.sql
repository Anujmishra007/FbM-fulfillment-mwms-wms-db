CREATE TABLE [RDT].[RDTEventLogDetail]
(
[EventLogID] [int] NULL CONSTRAINT [DF_RDTEventLogDetail_EventLogID] DEFAULT ((0)),
[RowRef] [int] NULL CONSTRAINT [DF_RDTEventLogDetail_RowRef] DEFAULT ((0)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTEventLogDetail_Facility] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTEventLogDetail_StorerKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTEventLogDetail_SKU] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTEventLogDetail_UOM] DEFAULT (''),
[QTY] [int] NULL CONSTRAINT [DF_RDTEventLogDetail_QTY] DEFAULT ((0)),
[DocRefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTEventLogDetail_DocRefNo] DEFAULT (''),
[AddDate] [datetime] NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTEventLogDetail_ArchiveCop] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTEventLogDetail] WITH NOCHECK ADD CONSTRAINT [FK_RDTEventLogDetail_RowRef] FOREIGN KEY ([RowRef]) REFERENCES [RDT].[RDTEventLog] ([RowRef])
GO
GRANT DELETE ON  [RDT].[RDTEventLogDetail] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTEventLogDetail] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTEventLogDetail] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTEventLogDetail] TO [NSQL]
GO
