CREATE TABLE [dbo].[TBL_ArchiveConfig](
	[RowRefNo] [int] NOT NULL,
	[Arc_code] [nvarchar](125) NOT NULL,
	[Arc_def_schedule] [int] NOT NULL,
	[Category] [nvarchar](10) NULL,
	[Description] [nvarchar](500) NULL,
	[Enabled] [nvarchar](1) NOT NULL,
	[Type] [int] NOT NULL,
	[StoredProcedure] [nvarchar](150) NOT NULL,
	[StoredProcedure2] [nvarchar](150) NULL,
	[ArchiveKey] [nvarchar](10) NULL,
	[SourceDB] [nvarchar](20) NOT NULL,
	[ArchiveDB] [nvarchar](20) NOT NULL,
	[TableSchema] [nvarchar](5) NOT NULL,
	[SrcTableName] [nvarchar](125) NOT NULL,
   [TgtTableName] [nvarchar](128) NULL,
	[DateColumn] [nvarchar](20) NOT NULL,
	[Threshold] [int] NOT NULL,
	[SQLCondition] [nvarchar](4000) NULL,
	[Key1Name] [nvarchar](128) NOT NULL,
	[Key2Name] [nvarchar](128) NULL,
	[Key3Name] [nvarchar](128) NULL,
	[Key4Name] [nvarchar](128) NULL,
	[Key5Name] [nvarchar](128) NULL,
	[Key6Name] [nvarchar](128) NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_TBL_ArchiveConfig] PRIMARY KEY CLUSTERED 
(
	[RowRefNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
create unique index IDX_TBL_ArchiveConfig_ArcCode on TBL_ArchiveConfig (Arc_code, Arc_def_schedule, Type)
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Arc_code]  DEFAULT ('') FOR [Arc_code]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Arc_def_schedule]  DEFAULT ('0') FOR [Arc_def_schedule]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Category]  DEFAULT ('WMS') FOR [Category]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Enabled]  DEFAULT ('') FOR [Enabled]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Type]  DEFAULT ('0') FOR [Type]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_StoredProcedure]  DEFAULT ('') FOR [StoredProcedure]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_StoredProcedure2]  DEFAULT ('') FOR [StoredProcedure2]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_ArchiveKey]  DEFAULT ('') FOR [ArchiveKey]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_SourceDBName]  DEFAULT ('') FOR [SourceDB]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_ArchiveDBName]  DEFAULT ('') FOR [ArchiveDB]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_TableSchema]  DEFAULT ('dbo') FOR [TableSchema]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_TableName]  DEFAULT ('') FOR [SrcTableName]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_DateColumn]  DEFAULT ('') FOR [DateColumn]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Threshold]  DEFAULT ('30') FOR [Threshold]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_SQLCondition]  DEFAULT ('') FOR [SQLCondition]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Key1Name]  DEFAULT ('') FOR [Key1Name]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Key2Name]  DEFAULT ('') FOR [Key2Name]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Key3Name]  DEFAULT ('') FOR [Key3Name]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Key4Name]  DEFAULT ('') FOR [Key4Name]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Key5Name]  DEFAULT ('') FOR [Key5Name]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_Key6Name]  DEFAULT ('') FOR [Key6Name]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_TgtTableName]  DEFAULT ('') FOR [TgtTableName]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_AddDate]  DEFAULT (getdate()) FOR [AddDate]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_AddWho]  DEFAULT (suser_name()) FOR [AddWho]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_EditDate]  DEFAULT (getdate()) FOR [EditDate]
GO

ALTER TABLE [dbo].[TBL_ArchiveConfig] ADD  CONSTRAINT [DF_TBL_ArchiveConfig_EditWho]  DEFAULT (suser_name()) FOR [EditWho]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_ArchiveConfig', @level2type=N'COLUMN',@level2name=N'RowRefNo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Archived Table Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_ArchiveConfig', @level2type=N'COLUMN',@level2name=N'Arc_code'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Archived Defined Schedule' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_ArchiveConfig', @level2type=N'COLUMN',@level2name=N'Arc_def_schedule'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Category - WMS, DTSITF, RDT, etc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_ArchiveConfig', @level2type=N'COLUMN',@level2name=N'Category'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 - Generic, 2 - Customised , 3 - Others ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_ArchiveConfig', @level2type=N'COLUMN',@level2name=N'Type'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column Key customized for Date data type ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TBL_ArchiveConfig', @level2type=N'COLUMN',@level2name=N'Key6Name'
GO


