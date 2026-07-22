
IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'BUILDWAVELOG'
                 AND type in (N'U'))
BEGIN

    CREATE TABLE [dbo].[BUILDWAVELOG]
    (
    [BatchNo] [bigint] NOT NULL IDENTITY(1, 1),
    [SessionNo] [bigint] NOT NULL CONSTRAINT [DF_BUILDWAVELOG_SessionNo] DEFAULT (''),
    [Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_Facility] DEFAULT (''),
    [Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_Storerkey] DEFAULT (''),
    [BuildParmGroup] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_BuildParmGroup] DEFAULT (''),
    [BuildParmKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_BuildParmKey] DEFAULT (''),
    [BuildParmString] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_BuildParmString] DEFAULT (''),
    [Duration] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_Duration] DEFAULT (''),
    [TotalWaveCnt] [int] NOT NULL CONSTRAINT [DF_BUILDWAVELOG_TotalWaveCnt] DEFAULT ((0)),
    [UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF01] DEFAULT (''),
    [UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF02] DEFAULT (''),
    [UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF03] DEFAULT (''),
    [UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF04] DEFAULT (''),
    [UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_UDF05] DEFAULT (''),
    [Status] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_Status] DEFAULT ('0'),
    [AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_AddWho] DEFAULT (suser_sname()),
    [AddDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDWAVELOG_AddDate] DEFAULT (getdate()),
    [EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDWAVELOG_EditWho] DEFAULT (suser_sname()),
    [EditDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDWAVELOG_EditDate] DEFAULT (getdate()),
    [TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    ) ON [PRIMARY]
    
    ALTER TABLE [dbo].[BUILDWAVELOG] ADD CONSTRAINT [PK_BUILDWAVELOG] PRIMARY KEY CLUSTERED ([BatchNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
    
    CREATE NONCLUSTERED INDEX [IDX_BUILDWAVELOG_SessionNo] ON [dbo].[BUILDWAVELOG] ([SessionNo]) ON [PRIMARY]
    
    GRANT DELETE ON  [dbo].[BUILDWAVELOG] TO [NSQL]
    
    GRANT INSERT ON  [dbo].[BUILDWAVELOG] TO [NSQL]
    
    GRANT SELECT ON  [dbo].[BUILDWAVELOG] TO [NSQL]
    
    GRANT UPDATE ON  [dbo].[BUILDWAVELOG] TO [NSQL]
    
    EXEC sp_addextendedproperty N'MS_Description', N'Build Wave Log', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', NULL, NULL
    
    EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'AddDate'
    
    EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID creates the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'AddWho'
    
    EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'ArchiveCop'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'BatchNo'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Build Wave Parameter Group', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'BuildParmGroup'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Build Wave Parameter Code', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'BuildParmKey'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Build Wave Parameter SQL', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'BuildParmString'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Duration', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'Duration'
     
    EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'EditDate'
    
    EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'EditWho'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'Facility'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Build Wave SessionNo', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'SessionNo'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'Storerkey'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Total Wave Count', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'TotalWaveCnt'
    
    EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'TrafficCop'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF01'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF02'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF03'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF04'
    
    EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BUILDWAVELOG', 'COLUMN', N'UDF05'
    
END


IF NOT EXISTS (SELECT 1
                FROM sys.indexes
                WHERE name = 'IX_BUILDWAVELOG_BuildParmGroup_BuildParmKey'
                  AND object_id = OBJECT_ID('dbo.BUILDWAVELOG'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_BUILDWAVELOG_BuildParmGroup_BuildParmKey]
	ON [dbo].[BUILDWAVELOG] ([BuildParmGroup],[BuildParmKey])
END
