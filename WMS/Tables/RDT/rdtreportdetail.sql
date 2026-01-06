IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtReportDetail]') AND type in (N'U'))
BEGIN
CREATE TABLE [RDT].[rdtReportDetail](
	[StorerKey] [nvarchar](15) NOT NULL,
	[ReportType] [nvarchar](10) NOT NULL,
	[RptDesc] [nvarchar](60) NULL,
	[SUBPlatform] [nvarchar](20) NOT NULL,
	[DataWindow] [nvarchar](50) NOT NULL,
	[TargetDB] [nvarchar](20) NULL,
	[AddDate] [datetime] NULL,
	[AddWho] [nvarchar](128) NULL,
	[EditWho] [nvarchar](128) NULL,
	[EditDate] [datetime] NULL,
	[parm1_label] [nvarchar](30) NULL,
	[parm2_label] [nvarchar](30) NULL,
	[parm3_label] [nvarchar](30) NULL,
	[parm4_label] [nvarchar](30) NULL,
	[parm5_label] [nvarchar](30) NULL,
	[parm6_label] [nvarchar](30) NULL,
	[parm7_label] [nvarchar](30) NULL,
	[parm8_label] [nvarchar](30) NULL,
	[parm9_label] [nvarchar](30) NULL,
	[parm10_label] [nvarchar](30) NULL,
	[PrintTemplate] [nvarchar](max) NULL,
	[PrintTemplateSP] [nvarchar](40) NULL,
	[Function_ID] [int] NOT NULL,
	[ProcessType] [nvarchar](15) NOT NULL,
	[ProcessSP] [nvarchar](50) NOT NULL,
	[PaperType] [nvarchar](10) NOT NULL,
	[NoOfCopy] [int] NOT NULL,
	[Facility] [nvarchar](5) NOT NULL,
	[JReportCatalog] [nvarchar](100) NULL,
	[JReportFileName] [nvarchar](250) NULL,
	[JReportFlag] [nvarchar](10) NULL,
	[ReportLineDesc] [nvarchar](60) NULL,
	[ReportFormat] [nvarchar](1) NOT NULL,
	[ReportParmName1] [nvarchar](100) NOT NULL,
	[ReportParmName2] [nvarchar](100) NOT NULL,
	[ReportParmName3] [nvarchar](100) NOT NULL,
	[ReportParmName4] [nvarchar](100) NOT NULL,
	[ReportParmName5] [nvarchar](100) NOT NULL,
	[ReportParmName6] [nvarchar](100) NOT NULL,
	[ReportParmName7] [nvarchar](100) NOT NULL,
	[ReportParmName8] [nvarchar](100) NOT NULL,
	[ReportParmName9] [nvarchar](100) NOT NULL,
	[ReportParmName10] [nvarchar](100) NOT NULL,
	[ReportParmName11] [nvarchar](100) NOT NULL,
	[ReportParmName12] [nvarchar](100) NOT NULL,
	[ReportParmName13] [nvarchar](100) NOT NULL,
	[ReportParmName14] [nvarchar](100) NOT NULL,
	[ReportParmName15] [nvarchar](100) NOT NULL,
	[ReportParmName16] [nvarchar](100) NOT NULL,
	[ReportParmName17] [nvarchar](100) NOT NULL,
	[ReportParmName18] [nvarchar](100) NOT NULL,
	[ReportParmName19] [nvarchar](100) NOT NULL,
	[ReportParmName20] [nvarchar](100) NOT NULL,
	[ReportCatalog] [nvarchar](100) NOT NULL,
	[PreGenRptDataSP] [nvarchar](50) NOT NULL,
	[AutoPrint] [nvarchar](1) NOT NULL,
	[PrintSettings] [nvarchar](4000) NOT NULL,
	[PostPrintSP] [nvarchar](50) NULL,
	[PaperSizeWxH] [nvarchar](15) NOT NULL,
	[DCropWidth] [nvarchar](10) NOT NULL,
	[DCropHeight] [nvarchar](10) NOT NULL,
	[IsLandScape] [nvarchar](1) NOT NULL,
	[IsColor] [nvarchar](1) NOT NULL,
	[IsDuplex] [nvarchar](1) NOT NULL,
	[IsCollate] [nvarchar](1) NOT NULL,
	[IsPaperPrinter] [nvarchar](1) NOT NULL,
	[DefaultPrinterID] [nvarchar](30) NOT NULL,
	[PrintNextOnFail] [int] NOT NULL,
	[FileFolder] [nvarchar](200) NOT NULL,
	[SQL_Select] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_RDTReportDetail] PRIMARY KEY CLUSTERED 
(
	[StorerKey] ASC,
	[ReportType] ASC,
	[SUBPlatform] ASC,
	[Function_ID] ASC,
	[Facility] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_Datawindow]  DEFAULT ('') FOR [DataWindow]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_AddDate]  DEFAULT (getdate()) FOR [AddDate]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_EditDate]  DEFAULT (getdate()) FOR [EditDate]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_PrintTemplate]  DEFAULT ('') FOR [PrintTemplate]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_PrintTemplateSP]  DEFAULT ('') FOR [PrintTemplateSP]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_Function_ID]  DEFAULT ((0)) FOR [Function_ID]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_ProcessType]  DEFAULT ('') FOR [ProcessType]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_ProcessSP]  DEFAULT ('') FOR [ProcessSP]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_PaperType]  DEFAULT ('') FOR [PaperType]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetailNoOfCopy]  DEFAULT ((1)) FOR [NoOfCopy]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_Facility]  DEFAULT ('') FOR [Facility]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportLineDesc]  DEFAULT ('') FOR [ReportLineDesc]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportFormat]  DEFAULT ('') FOR [ReportFormat]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName1]  DEFAULT ('') FOR [ReportParmName1]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName2]  DEFAULT ('') FOR [ReportParmName2]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName3]  DEFAULT ('') FOR [ReportParmName3]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName4]  DEFAULT ('') FOR [ReportParmName4]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName5]  DEFAULT ('') FOR [ReportParmName5]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName6]  DEFAULT ('') FOR [ReportParmName6]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName7]  DEFAULT ('') FOR [ReportParmName7]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName8]  DEFAULT ('') FOR [ReportParmName8]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName9]  DEFAULT ('') FOR [ReportParmName9]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName10]  DEFAULT ('') FOR [ReportParmName10]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName11]  DEFAULT ('') FOR [ReportParmName11]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName12]  DEFAULT ('') FOR [ReportParmName12]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName13]  DEFAULT ('') FOR [ReportParmName13]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName14]  DEFAULT ('') FOR [ReportParmName14]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName15]  DEFAULT ('') FOR [ReportParmName15]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName16]  DEFAULT ('') FOR [ReportParmName16]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName17]  DEFAULT ('') FOR [ReportParmName17]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName18]  DEFAULT ('') FOR [ReportParmName18]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName19]  DEFAULT ('') FOR [ReportParmName19]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName20]  DEFAULT ('') FOR [ReportParmName20]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_PreGenRptDataSP]  DEFAULT ('') FOR [PreGenRptDataSP]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_AutoPrint]  DEFAULT ('N') FOR [AutoPrint]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_PrintSettings]  DEFAULT ('') FOR [PrintSettings]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_PaperSizeWxH]  DEFAULT ('') FOR [PaperSizeWxH]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_DCropWidth]  DEFAULT ('0') FOR [DCropWidth]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_DCropHeight]  DEFAULT ('0') FOR [DCropHeight]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsLandScape]  DEFAULT ('0') FOR [IsLandScape]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsColor]  DEFAULT ('0') FOR [IsColor]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsDuplex]  DEFAULT ('0') FOR [IsDuplex]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsCollate]  DEFAULT ('0') FOR [IsCollate]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsPaperPrinter]  DEFAULT ('') FOR [IsPaperPrinter]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_DefaultPrinterID]  DEFAULT ('') FOR [DefaultPrinterID]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_PrintNextOnFail]  DEFAULT ((0)) FOR [PrintNextOnFail]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_FileFolder]  DEFAULT ('') FOR [FileFolder]

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_SQL_Select]  DEFAULT ('') FOR [SQL_Select]

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Different printing method (QCOMMANDER, DATAWINDOW, BARTENDER)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ProcessType'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mainly for customize report parameter mapping' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ProcessSP'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PaperType=LABEL or blank (report)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PaperType'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print out no of copy same label / report. Default=1' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'NoOfCopy'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Description for the Report Detail Line #' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportLineDesc'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Format' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportFormat'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 1' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName1'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 2' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName2'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 3' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName3'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 4' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName4'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 5' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName5'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 6' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName6'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 7' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName7'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 8' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName8'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 9' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName9'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 10' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName10'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 11' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName11'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 12' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName12'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 13' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName13'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 14' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName14'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 15' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName15'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 16' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName16'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 17' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName17'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 18' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName18'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 19' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName19'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 20' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName20'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pre Generate Report Data Stored Procedure' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PreGenRptDataSP'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Auto Print after an action' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'AutoPrint'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Settings' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PrintSettings'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Paper Size Setting (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PaperSizeWxH'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CropWidth (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'DCropWidth'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'DCropHeight (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'DCropHeight'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Landscape Setting (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsLandScape'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Color Settings (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsColor'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Duplex Settings (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsDuplex'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Collate Setting (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsCollate'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Paper/Label Printer' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsPaperPrinter'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Default Printer ID' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'DefaultPrinterID'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Next Record On current printing Fail' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PrintNextOnFail'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'File Folder (Interface PDF)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'FileFolder'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SQL Select get report filename' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'SQL_Select'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'WM Report Header' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail'


END

ELSE 
BEGIN 

 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'ReportCatalog' AND Object_ID = Object_ID('RDT.rdtReportDetail'))
			BEGIN

			    ALTER TABLE [RDT].[rdtReportDetail]
				ADD ReportCatalog [nvarchar](100) NOT NULL CONSTRAINT [DF_RDTReportDetail_ReportCatalog]  DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'Logi Catalog', 'SCHEMA', N'RDT', 'TABLE', N'rdtReportDetail', 'COLUMN', N'ReportCatalog'
				
			END



END
