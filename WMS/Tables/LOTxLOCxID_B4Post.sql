CREATE TABLE [dbo].[LOTxLOCxID_B4Post]
(
[CCKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_Lot] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_Loc] DEFAULT ('UNKNOWN'),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_Id] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_Sku] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_Qty] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_QtyPicked] DEFAULT ((0)),
[QtyExpected] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_QtyExpected] DEFAULT ((0)),
[QtyPickInProcess] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_QtyPickInProcess] DEFAULT ((0)),
[PendingMoveIN] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_PendingMoveIN] DEFAULT ((0)),
[ArchiveQty] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_ArchiveQty] DEFAULT ((0)),
[ArchiveDate] [datetime] NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_ArchiveDate] DEFAULT ('01/01/1901'),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyReplen] [int] NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_QtyReplen] DEFAULT ((0)),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LOTxLOCxID_B4Post_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOTxLOCxID_B4Post] ADD CONSTRAINT [PKLOTxLOCxID_B4Post] PRIMARY KEY CLUSTERED ([CCKey], [Lot], [Loc], [Id]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LOTxLOCxID_B4Post] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LOTxLOCxID_B4Post] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LOTxLOCxID_B4Post] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LOTxLOCxID_B4Post] TO [NSQL]
GO
