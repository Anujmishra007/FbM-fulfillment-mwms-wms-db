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
GO
EXEC sp_addextendedproperty N'MS_Description', N'WM Report Header', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Computer Name', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ComputerName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 1', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 2', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 3', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 4', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Criteria Matching 5', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'CriteriaMatching05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pre Generate Report Data Stored Procedure', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'PreGenRptDataSP'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pre Print Process Stored Procedure Name ', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'PrePrintSP'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Print Group', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'PrintGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Print Type; BARTENDER/DATAWINDOW/DIRECTPRN', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'PrintType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Logi Catalog', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportCatalog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Format', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportFormat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report ID', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Description for the Report Detail Line #', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportLineDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Line #', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 1', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 10', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 11', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 12', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName12'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 13', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName13'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 14', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName14'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 15', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 16', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName16'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 17', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName17'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 18', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName18'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 19', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName19'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 2', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 20', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName20'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 3', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 4', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 5', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 6', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 7', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 8', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Parameter Name 9', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportParmName9'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Template:LabelType,datawindow name,ZPL or IPL template string', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Title', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'ReportTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Row ID', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'RowID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Login', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORTDETAIL', 'COLUMN', N'UserName'
GO
