CREATE TABLE [dbo].[UploadC4PODetail]
(
[POkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PoLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOkey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternLinenumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyOrdered] [int] NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadC4PODetail_UOM] DEFAULT ('PIECE'),
[MODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadC4PODetail_STATUS] DEFAULT ('0'),
[REMARKS] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adddate] [datetime] NULL CONSTRAINT [DF_UploadC4PODetail_adddate] DEFAULT (getdate()),
[Best_bf_Date] [datetime] NULL CONSTRAINT [DF_UploadC4PODetail_Best_bf_Date] DEFAULT (getdate()),
[RFF] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StoreOrderNo] [nvarchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StoreID] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_UploadC4PODetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UploadC4PODetail_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[UploadC4PODetail] ADD CONSTRAINT [PK_UploadC4PODetail] PRIMARY KEY CLUSTERED ([POkey], [PoLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UploadC4PODetail_ExtOrdKey] ON [dbo].[UploadC4PODetail] ([ExternPOkey], [ExternLinenumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UploadC4PODetail_SKU] ON [dbo].[UploadC4PODetail] ([Storerkey], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UploadC4PODetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UploadC4PODetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UploadC4PODetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UploadC4PODetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UploadC4PODetail', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UploadC4PODetail', 'COLUMN', N'Storerkey'
GO
