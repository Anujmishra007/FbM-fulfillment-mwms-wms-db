CREATE TABLE [RDT].[RDTUCC]
(
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUCC_ReceiptKey] DEFAULT (' '),
[ExternKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_RDTUCC_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUCC_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_RDTUCC_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTUCC_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTUCC] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTUCC] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTUCC] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTUCC] TO [NSQL]
GO
