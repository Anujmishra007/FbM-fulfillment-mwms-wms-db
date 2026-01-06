IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReceiptSerialNo_DEL]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ReceiptSerialNo_DEL](
[RowRef] INT IDENTITY (1,1) NOT NULL,
[ReceiptSerialNoKey] [bigint] NOT NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiptLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[UCCNo] [nvarchar](20) NULL,
--[DelWho] [nvarchar](128) NOT NULL CONSTRAINT [DF_ReceiptSerialNo_DEL_DelWho]  DEFAULT (suser_sname()),
--[DelDate] [datetime] NOT NULL CONSTRAINT [DF_ReceiptSerialNo_DEL_DelDate]  DEFAULT (GETDATE())
CONSTRAINT [PK_ReceiptSerialNo_DEL] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

END