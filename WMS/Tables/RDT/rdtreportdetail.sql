/****** Object:  Table [RDT].[rdtReportDetail]    Script Date: 4/2/2024 6:45:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_Datawindow]  DEFAULT ('') FOR [DataWindow]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_AddDate]  DEFAULT (getdate()) FOR [AddDate]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_EditDate]  DEFAULT (getdate()) FOR [EditDate]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_PrintTemplate]  DEFAULT ('') FOR [PrintTemplate]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_PrintTemplateSP]  DEFAULT ('') FOR [PrintTemplateSP]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_Function_ID]  DEFAULT ((0)) FOR [Function_ID]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_ProcessType]  DEFAULT ('') FOR [ProcessType]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_ProcessSP]  DEFAULT ('') FOR [ProcessSP]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_PaperType]  DEFAULT ('') FOR [PaperType]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetailNoOfCopy]  DEFAULT ((1)) FOR [NoOfCopy]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportdetail_Facility]  DEFAULT ('') FOR [Facility]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportLineDesc]  DEFAULT ('') FOR [ReportLineDesc]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportFormat]  DEFAULT ('') FOR [ReportFormat]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName1]  DEFAULT ('') FOR [ReportParmName1]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName2]  DEFAULT ('') FOR [ReportParmName2]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName3]  DEFAULT ('') FOR [ReportParmName3]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName4]  DEFAULT ('') FOR [ReportParmName4]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName5]  DEFAULT ('') FOR [ReportParmName5]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName6]  DEFAULT ('') FOR [ReportParmName6]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName7]  DEFAULT ('') FOR [ReportParmName7]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName8]  DEFAULT ('') FOR [ReportParmName8]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName9]  DEFAULT ('') FOR [ReportParmName9]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName10]  DEFAULT ('') FOR [ReportParmName10]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName11]  DEFAULT ('') FOR [ReportParmName11]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName12]  DEFAULT ('') FOR [ReportParmName12]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName13]  DEFAULT ('') FOR [ReportParmName13]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName14]  DEFAULT ('') FOR [ReportParmName14]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName15]  DEFAULT ('') FOR [ReportParmName15]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName16]  DEFAULT ('') FOR [ReportParmName16]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName17]  DEFAULT ('') FOR [ReportParmName17]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName18]  DEFAULT ('') FOR [ReportParmName18]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName19]  DEFAULT ('') FOR [ReportParmName19]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_ReportParmName20]  DEFAULT ('') FOR [ReportParmName20]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_PreGenRptDataSP]  DEFAULT ('') FOR [PreGenRptDataSP]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_AutoPrint]  DEFAULT ('N') FOR [AutoPrint]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_PrintSettings]  DEFAULT ('') FOR [PrintSettings]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_PaperSizeWxH]  DEFAULT ('') FOR [PaperSizeWxH]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_DCropWidth]  DEFAULT ('0') FOR [DCropWidth]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_DCropHeight]  DEFAULT ('0') FOR [DCropHeight]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsLandScape]  DEFAULT ('0') FOR [IsLandScape]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsColor]  DEFAULT ('0') FOR [IsColor]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsDuplex]  DEFAULT ('0') FOR [IsDuplex]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsCollate]  DEFAULT ('0') FOR [IsCollate]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_IsPaperPrinter]  DEFAULT ('') FOR [IsPaperPrinter]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_DefaultPrinterID]  DEFAULT ('') FOR [DefaultPrinterID]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_PrintNextOnFail]  DEFAULT ((0)) FOR [PrintNextOnFail]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_FileFolder]  DEFAULT ('') FOR [FileFolder]
GO

ALTER TABLE [RDT].[rdtReportDetail] ADD  CONSTRAINT [DF_RDTReportDetail_SQL_Select]  DEFAULT ('') FOR [SQL_Select]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Different printing method (QCOMMANDER, DATAWINDOW, BARTENDER)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ProcessType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mainly for customize report parameter mapping' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ProcessSP'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PaperType=LABEL or blank (report)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PaperType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print out no of copy same label / report. Default=1' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'NoOfCopy'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Description for the Report Detail Line #' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportLineDesc'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Format' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportFormat'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 1' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName1'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 2' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName2'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 3' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName3'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 4' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName4'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 5' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName5'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 6' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName6'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 7' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName7'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 8' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName8'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 9' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName9'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 10' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName10'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 11' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName11'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 12' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName12'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 13' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName13'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 14' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName14'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 15' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName15'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 16' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName16'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 17' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName17'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 18' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName18'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 19' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName19'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Report Parameter Name 20' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'ReportParmName20'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pre Generate Report Data Stored Procedure' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PreGenRptDataSP'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Auto Print after an action' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'AutoPrint'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Settings' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PrintSettings'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Paper Size Setting (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PaperSizeWxH'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CropWidth (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'DCropWidth'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'DCropHeight (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'DCropHeight'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Landscape Setting (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsLandScape'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Color Settings (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsColor'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Duplex Settings (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsDuplex'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Collate Setting (Need for CloudPrintTask)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsCollate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Paper/Label Printer' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'IsPaperPrinter'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Default Printer ID' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'DefaultPrinterID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Print Next Record On current printing Fail' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'PrintNextOnFail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'File Folder (Interface PDF)' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'FileFolder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SQL Select get report filename' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail', @level2type=N'COLUMN',@level2name=N'SQL_Select'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'WM Report Header' , @level0type=N'SCHEMA',@level0name=N'RDT', @level1type=N'TABLE',@level1name=N'rdtReportDetail'
GO