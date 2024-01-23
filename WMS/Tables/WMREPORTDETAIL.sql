
IF NOT EXISTS (SELECT 1 FROM sysObjects WHERE name = 'WMREPORTDETAIL')
BEGIN
   CREATE TABLE [dbo].[WMREPORTDETAIL]
   (
   [RowID] [bigint] NOT NULL IDENTITY(1, 1),
   [ReportID] [nvarchar] (10) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportID] DEFAULT (''),
   [ReportLineNo] [nvarchar] (5) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportLineNo] DEFAULT (''),
   [ReportTitle] [nvarchar] (60) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportTitle] DEFAULT (''),
   [Storerkey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_Storerkey] DEFAULT (''),
   [Facility] [nvarchar] (15) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_Facility] DEFAULT (''),
   [UserName] [nvarchar] (128) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_UserName] DEFAULT (''),
   [ComputerName] [nvarchar] (30) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ComputerName] DEFAULT (''),
   [PrintGroup] [nvarchar] (10) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_PrintGroup] DEFAULT (''),
   [PrintType] [nvarchar] (30) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_PrintType] DEFAULT (''),
   [ReportTemplate] [nvarchar] (4000) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportTemplate] DEFAULT (''),
   [PrePrintSP] [nvarchar] (50) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_PrePrintSP] DEFAULT (''),
   [CriteriaMatching01] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_CriteriaMatching01] DEFAULT (''),
   [CriteriaMatching02] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_CriteriaMatching02] DEFAULT (''),
   [CriteriaMatching03] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_CriteriaMatching03] DEFAULT (''),
   [CriteriaMatching04] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_CriteriaMatching04] DEFAULT (''),
   [CriteriaMatching05] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_CriteriaMatching05] DEFAULT (''),
   [ReportLineDesc] [nvarchar] (60) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportLineDesc] DEFAULT (''),
   [AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_AddWho] DEFAULT (suser_sname()),
   [AddDate] [datetime] NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_AddDate] DEFAULT (getdate()),
   [EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_EditWho] DEFAULT (suser_sname()),
   [EditDate] [datetime] NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_EditDate] DEFAULT (getdate()),
   [TrafficCop] [nchar] (1) NULL,
   [ArchiveCop] [nchar] (1) NULL,
   [ReportFormat] [nvarchar] (1) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportFormat] DEFAULT (''),
   [ReportParmName1] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName1] DEFAULT (''),
   [ReportParmName2] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName2] DEFAULT (''),
   [ReportParmName3] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName3] DEFAULT (''),
   [ReportParmName4] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName4] DEFAULT (''),
   [ReportParmName5] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName5] DEFAULT (''),
   [ReportParmName6] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName6] DEFAULT (''),
   [ReportParmName7] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName7] DEFAULT (''),
   [ReportParmName8] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName8] DEFAULT (''),
   [ReportParmName9] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName9] DEFAULT (''),
   [ReportParmName10] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName10] DEFAULT (''),
   [ReportParmName11] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName11] DEFAULT (''),
   [ReportParmName12] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName12] DEFAULT (''),
   [ReportParmName13] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName13] DEFAULT (''),
   [ReportParmName14] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName14] DEFAULT (''),
   [ReportParmName15] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName15] DEFAULT (''),
   [ReportParmName16] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName16] DEFAULT (''),
   [ReportParmName17] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName17] DEFAULT (''),
   [ReportParmName18] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName18] DEFAULT (''),
   [ReportParmName19] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName19] DEFAULT (''),
   [ReportParmName20] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportParmName20] DEFAULT (''),
   [ReportCatalog] [nvarchar] (100) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_ReportCatalog] DEFAULT (''),
   [PreGenRptDataSP] [nvarchar] (50) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_PreGenRptDataSP] DEFAULT ('')
   ) ON [PRIMARY]
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'WM Report Header', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', NULL, NULL
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'AddDate'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'AddWho'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Computer Name', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ComputerName'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 1', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching01'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 2', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching02'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 3', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching03'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 4', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching04'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 5', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching05'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'EditDate'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'EditWho'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'Facility'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Pre Generate Report Data Stored Procedure', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'PreGenRptDataSP'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Pre Print Process Stored Procedure Name ', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'PrePrintSP'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Print Group', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'PrintGroup'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Print Type; BARTENDER/DATAWINDOW/DIRECTPRN', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'PrintType'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Logi Catalog', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportCatalog'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Format', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportFormat'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report ID', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportID'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Description for the Report Detail Line #', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportLineDesc'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Line #', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportLineNo'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 1', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName1'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 10', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName10'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 11', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName11'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 12', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName12'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 13', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName13'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 14', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName14'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 15', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName15'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 16', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName16'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 17', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName17'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 18', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName18'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 19', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName19'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 2', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName2'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 20', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName20'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 3', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName3'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 4', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName4'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 5', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName5'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 6', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName6'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 7', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName7'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 8', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName8'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 9', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName9'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Template:LabelType,datawindow name,ZPL or IPL template string', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportTemplate'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Title', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportTitle'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Report Row ID', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'RowID'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'Storerkey'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'TrafficCop'
   ;
   EXEC sp_addextendedproperty N'MS_Description', N'User Login', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'UserName'
   ;
END

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'AutoPrint'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD AutoPrint        NVARCHAR(1) NOT NULL  CONSTRAINT [DF_WMREPORTDETAIL_AutoPrint] DEFAULT ('N')
END

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'AutoPrint'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Auto Print after an action' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'AutoPrint'
   ;
END

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'PostPrintSP'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE WMREPORTDETAIL ADD PostPrintSP  NVARCHAR(50) NULL;
END

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'PostPrintSP'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Post Print SP - Custom SP to be executed after Print' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'PostPrintSP'
   ;
END 

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'PaperSizeWxH'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD PaperSizeWxH        NVARCHAR(15) NOT NULL  CONSTRAINT [DF_WMREPORTDETAIL_PaperSizeWxH] DEFAULT ('')
END

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'DCropWidth'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD DCropWidth        NVARCHAR(10) NOT NULL  CONSTRAINT [DF_WMREPORTDETAIL_DCropWidth] DEFAULT ('0')
END

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'DCropHeight'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD DCropHeight        NVARCHAR(10) NOT NULL  CONSTRAINT [DF_WMREPORTDETAIL_DCropHeight] DEFAULT ('0')
END

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'IsLandScape'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD IsLandScape    NVARCHAR(1) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_IsLandScape] DEFAULT('0')
END      


IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'IsColor'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD IsColor    NVARCHAR(1) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_IsColor] DEFAULT('0')
END  


IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'IsDuplex'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD IsDuplex    NVARCHAR(1) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_IsDuplex] DEFAULT('0')
END  

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'IsCollate'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD IsCollate    NVARCHAR(1) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_IsCollate] DEFAULT('0')
END  


IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'PaperSizeWxH'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Paper Size Setting (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'PaperSizeWxH'
   ;
END

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'DCropWidth'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CropWidth (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'DCropWidth'
   ;
END

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'DCropHeight'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'DCropHeight (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'DCropHeight'
   ;
END


IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'IsLandScape'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Landscape Setting (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'IsLandScape'
   ;
END

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'IsColor'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Color Settings (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'IsColor'
   ;
END 


IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'IsDuplex'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Duplex Settings (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'IsDuplex'
   ;
END 

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'IsCollate'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Collate Setting (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'IsCollate'
   ;
END

-- Extend CriteriaMatching05 Column Lenth to MAX
IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'CriteriaMatching05'
               AND so.name = 'WMREPORTDETAIL'
               AND sc.length = -1
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL DROP CONSTRAINT [DF_WMREPORTDETAIL_CriteriaMatching05];
   ALTER TABLE dbo.WMREPORTDETAIL ALTER COLUMN CriteriaMatching05 NVARCHAR(MAX) NULL ;
   ALTER TABLE dbo.WMREPORTDETAIL ADD CONSTRAINT [DF_WMREPORTDETAIL_CriteriaMatching05] DEFAULT ('') FOR  CriteriaMatching05;
END

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'IsPaperPrinter'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD IsPaperPrinter    NVARCHAR(1) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_IsPaperPrinter] DEFAULT('')
END      

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'DefaultPrinterID'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD DefaultPrinterID        NVARCHAR(30) NOT NULL  CONSTRAINT [DF_WMREPORTDETAIL_DefaultPrinterID] DEFAULT ('')
END

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'PrintNextOnFail'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD PrintNextOnFail    INT NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_PrintNextOnFail] DEFAULT(0)
END  


IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'FileFolder'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD FileFolder    NVARCHAR(200) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_FileFolder] DEFAULT('')
END  

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'SQL_Select'
               AND so.name = 'WMREPORTDETAIL'
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL
      ADD SQL_Select    NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_WMREPORTDETAIL_SQL_Select] DEFAULT('')
END 

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'IsPaperPrinter'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Paper/Label Printer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'IsPaperPrinter'
   ;
END

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'DefaultPrinterID'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Default Printer ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'DefaultPrinterID'
   ;
END

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'PrintNextOnFail'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Next Record On current printing Fail' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'PrintNextOnFail'
   ;
END 

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'FileFolder'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'File Folder (Interface PDF)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'FileFolder'
   ;
END 

IF NOT EXISTS (SELECT 1
               FROM sys.extended_properties AS ep  
               JOIN syscolumns AS s (NOLOCK) ON ep.[major_id]=s.id  AND ep.minor_id = s.colorder
               WHERE [major_id] = OBJECT_ID('WMREPORTDETAIL') AND ep.[name] = N'MS_Description'
               AND s.NAME = 'SQL_Select'
              )
BEGIN
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SQL Select get report filename' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WMREPORTDETAIL', @level2type=N'COLUMN',@level2name=N'SQL_Select'
   ;
END 

IF NOT EXISTS (SELECT 1 FROM syscolumns sc
               JOIN sysObjects so ON so.id = sc.id
               WHERE sc.name = 'PreGenRptDataSP'
               AND so.name = 'WMREPORTDETAIL'
               AND sc.length = 2000
)
BEGIN
   ALTER TABLE dbo.WMREPORTDETAIL DROP CONSTRAINT [DF_WMREPORTDETAIL_PreGenRptDataSP];
   ALTER TABLE dbo.WMREPORTDETAIL ALTER COLUMN PreGenRptDataSP NVARCHAR(1000) NOT NULL;
   ALTER TABLE dbo.WMREPORTDETAIL ADD CONSTRAINT [DF_WMREPORTDETAIL_PreGenRptDataSP] DEFAULT ('') FOR PreGenRptDataSP;
END