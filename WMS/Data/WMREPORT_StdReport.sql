--sp_help StdReportCfg

IF NOT EXISTS (SELECT 1 FROM sysObjects so 
           WHERE so.name = 'StdReportCfg'
           )
BEGIN
   CREATE TABLE [dbo].[StdReportCfg](
      [RowID]                    [INT]             IDENTITY(1,1) NOT NULL,
      [ModuleID]                 [NVARCHAR](30)    NOT NULL CONSTRAINT [DF_StdReportCfg_ModuleID]                    DEFAULT (''),
      [ReportType]               [NVARCHAR](30)    NOT NULL CONSTRAINT [DF_StdReportCfg_ReportType]                  DEFAULT (''),
      [ReportTitle]              [NVARCHAR](60)    NOT NULL CONSTRAINT [DF_StdReportCfg_ReportTitle]                 DEFAULT (''),
      [PrintType]                [NVARCHAR](30)    NOT NULL CONSTRAINT [DF_StdReportCfg_PrintType]                   DEFAULT (''),
      [HeaderCfg]                [NVARCHAR](MAX)   NOT NULL CONSTRAINT [DF_StdReportCfg_HeaderCfg]                   DEFAULT (''),
      [DetailCfg]                [NVARCHAR](MAX)   NOT NULL CONSTRAINT [DF_StdReportCfg_DetailCfg]                   DEFAULT (''),
      [AddDate]                  [DATETIME]        NOT NULL CONSTRAINT [DF_StdReportCfg_AddDate]                     DEFAULT (GETDATE()),
      [AddWho]                   [NVARCHAR](128)   NOT NULL CONSTRAINT [DF_StdReportCfg_AddWho]                      DEFAULT (SUSER_SNAME()),
      [EditDate]                 [DATETIME]        NOT NULL CONSTRAINT [DF_StdReportCfg_EditDate]                    DEFAULT (GETDATE()),
      [EditWho]                  [NVARCHAR](128)   NOT NULL CONSTRAINT [DF_StdReportCfg_EditWho]                     DEFAULT (SUSER_SNAME()),
    CONSTRAINT [PK_StdReportCfg] PRIMARY KEY CLUSTERED 
   (
      [RowID] ASC
   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
   ) ON [PRIMARY]
   ;


   GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[StdReportCfg] TO nSQL 
   ;                                                                                 

   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'StdReportCfg table'  , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Unique Row ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'RowID'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Module ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'ModuleID'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'ReportType'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Title' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'ReportTitle'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'PrintType'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Header Columns Configuration' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'HeaderCfg'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Detail Columns Configuration' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'DetailCfg'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID added the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'AddWho'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date in which the load is created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'AddDate'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'EditWho'
   ;
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StdReportCfg', @level2type=N'COLUMN',@level2name=N'EditDate'
   ;
END



