CREATE TABLE [dbo].[UPSReturnTrackNo]
(
[Rowid] [bigint] NOT NULL IDENTITY(1, 1),
[Pickslipno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Labelno] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL CONSTRAINT [DF_UPSReturnTrackNo_Qty] DEFAULT ((0)),
[RefNo01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RePrint] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSReturnTrackNo_RePrint] DEFAULT ('N'),
[ADDDate] [datetime] NULL CONSTRAINT [DF_UPSReturnTrackNo_ADDDate] DEFAULT (getdate()),
[ADDWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSReturnTrackNo_ADDWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UPSReturnTrackNo] ADD CONSTRAINT [PK_UPSReturnTrackNo] PRIMARY KEY CLUSTERED ([Rowid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UPSReturnTrackNo_Orderkey] ON [dbo].[UPSReturnTrackNo] ([Orderkey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UPSReturnTrackNo_Pickslipno] ON [dbo].[UPSReturnTrackNo] ([Pickslipno], [Labelno], [Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UPSReturnTrackNo_RefNo01] ON [dbo].[UPSReturnTrackNo] ([RefNo01]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPSReturnTrackNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPSReturnTrackNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPSReturnTrackNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPSReturnTrackNo] TO [NSQL]
GO
