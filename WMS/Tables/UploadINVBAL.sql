CREATE TABLE [dbo].[UploadINVBAL]
(
[STORERKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_STORERKEY] DEFAULT (' '),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_SKU] DEFAULT (' '),
[LOCATION] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_LOCATION] DEFAULT (' '),
[lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_lottable01] DEFAULT (' '),
[lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_lottable02] DEFAULT (' '),
[lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_lottable03] DEFAULT (' '),
[lottable04] [datetime] NULL CONSTRAINT [DF_UploadINVBAL_lottable04] DEFAULT ((0)),
[lottable05] [datetime] NULL CONSTRAINT [DF_UploadINVBAL_lottable05] DEFAULT ((0)),
[QTY] [int] NULL CONSTRAINT [DF_UploadINVBAL_QTY] DEFAULT ((0)),
[STATUS] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_STATUS] DEFAULT ('1'),
[RUNNING] [int] NOT NULL IDENTITY(1, 1),
[UploadStatus] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_UploadStatus] DEFAULT ('NO'),
[Reason] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_Reason] DEFAULT (' '),
[OldLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_OldLocation] DEFAULT (' '),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADINVBAL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADINVBAL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADINVBAL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADINVBAL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADINVBAL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADINVBAL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADINVBAL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadINVBAL_Channel] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UploadINVBAL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UploadINVBAL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UploadINVBAL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UploadINVBAL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying a physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'UploadINVBAL', 'COLUMN', N'LOCATION'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'UploadINVBAL', 'COLUMN', N'QTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'UploadINVBAL', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UploadINVBAL', 'COLUMN', N'STORERKEY'
GO
