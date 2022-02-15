CREATE TABLE [RDT].[RDTDynamicModuleRegister]
(
[RowRefNo] [bigint] NOT NULL IDENTITY(1, 1),
[FuncID] [int] NULL,
[ScreenID] [int] NULL,
[UserName] [nvarchar] (128) NULL CONSTRAINT [DF_RDTDynamicModuleRegister_UserName] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_RDTDynamicModuleRegister_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTDynamicModuleRegister] ADD CONSTRAINT [PK__RDTDynam__9879279DC3446C52] PRIMARY KEY CLUSTERED ([RowRefNo]) ON [PRIMARY]
GO
