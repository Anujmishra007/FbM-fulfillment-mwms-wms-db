CREATE TABLE [RDT].[rdtDynamicModuleLibrary]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[ProcessType] [nvarchar] (10) NOT NULL,
[Category] [nvarchar] (20) NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_Category] DEFAULT (''),
[Seq] [int] NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_Seq] DEFAULT ((0)),
[Description] [nvarchar] (max) NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_Description] DEFAULT (''),
[SP] [nvarchar] (50) NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_SP] DEFAULT (''),
[Script] [nvarchar] (max) NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_Script] DEFAULT (''),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_EditDate] DEFAULT (getdate()),
[Name] [nvarchar] (50) NOT NULL CONSTRAINT [DF_rdtDynamicModuleLibrary_Name] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtDynamicModuleLibrary] ADD CONSTRAINT [PK_rdtDynamicModuleLibrary] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
