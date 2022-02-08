CREATE TABLE [RDT].[rdtDynamicModule]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Func] [int] NOT NULL,
[Scn] [int] NOT NULL,
[FieldNo] [nvarchar] (20) NOT NULL CONSTRAINT [DF_rdtDynamicModule_FieldNo] DEFAULT (''),
[SeqNo] [int] NOT NULL CONSTRAINT [DF_rdtDynamicModule_SeqNo] DEFAULT ((0)),
[ProcessType] [nvarchar] (10) NOT NULL,
[PrevScn] [int] NOT NULL CONSTRAINT [DF_rdtDynamicModule_PrevScn] DEFAULT ((0)),
[NextScn] [int] NOT NULL CONSTRAINT [DF_rdtDynamicModule_NextScn] DEFAULT ((0)),
[PrevSP] [nvarchar] (50) NOT NULL CONSTRAINT [DF_rdtDynamicModule_PrevSP] DEFAULT (''),
[NextSP] [nvarchar] (50) NOT NULL CONSTRAINT [DF_rdtDynamicModule_NextSP] DEFAULT (''),
[PrevSQL] [nvarchar] (max) NOT NULL CONSTRAINT [DF_rdtDynamicModule_PrevSQL] DEFAULT (''),
[NextSQL] [nvarchar] (max) NOT NULL CONSTRAINT [DF_rdtDynamicModule_NextSQL] DEFAULT (''),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtDynamicModule_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtDynamicModule_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtDynamicModule_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtDynamicModule_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtDynamicModule] ADD CONSTRAINT [PK_RDTDynamicModule] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
