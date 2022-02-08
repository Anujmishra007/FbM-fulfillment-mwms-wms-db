CREATE TABLE [RDT].[SwapUCC]
(
[Func] [int] NULL,
[UCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewUCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplenGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_SwapUCC_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SwapUCC_AddWho] DEFAULT (suser_sname()),
[UCCStatus] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewUCCStatus] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[SwapUCC] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[SwapUCC] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[SwapUCC] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[SwapUCC] TO [NSQL]
GO
