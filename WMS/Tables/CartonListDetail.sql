CREATE TABLE [dbo].[CartonListDetail]
(
[CartonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NULL,
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Orderkey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonListDetail_Orderkey] DEFAULT (''),
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonListDetail_AddWho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_CartonListDetail_Adddate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CartonListDetail] ADD CONSTRAINT [PKCartonListDetail] PRIMARY KEY CLUSTERED ([CartonKey], [SKU], [PickDetailKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CartonListDetail_Orderkey] ON [dbo].[CartonListDetail] ([Orderkey], [SKU]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CartonListDetail_PDkey] ON [dbo].[CartonListDetail] ([PickDetailKey], [SKU]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CartonListDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CartonListDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CartonListDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CartonListDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CartonListDetail] TO [NSQL]
GO
