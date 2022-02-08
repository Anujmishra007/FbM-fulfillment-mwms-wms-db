CREATE TABLE [dbo].[WMREPORT]
(
[ReportID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ReportID] DEFAULT (''),
[ReportTitle] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ReportTitle] DEFAULT (''),
[ModuleID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ModuleID] DEFAULT (''),
[PrintMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_PrintMethod] DEFAULT (''),
[ReportType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ReportType] DEFAULT (''),
[NoOfKeyFieldParms] [int] NOT NULL CONSTRAINT [DF_WMREPORT_NoOfKeyFieldParms] DEFAULT ((0)),
[KeyFieldName1] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName1] DEFAULT (''),
[KeyFieldName2] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName2] DEFAULT (''),
[KeyFieldName3] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName3] DEFAULT (''),
[KeyFieldName4] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName4] DEFAULT (''),
[KeyFieldName5] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName5] DEFAULT (''),
[KeyFieldName6] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName6] DEFAULT (''),
[KeyFieldName7] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName7] DEFAULT (''),
[KeyFieldName8] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName8] DEFAULT (''),
[KeyFieldName9] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName9] DEFAULT (''),
[KeyFieldName10] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName10] DEFAULT (''),
[KeyFieldName11] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName11] DEFAULT (''),
[KeyFieldName12] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName12] DEFAULT (''),
[KeyFieldName13] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName13] DEFAULT (''),
[KeyFieldName14] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName14] DEFAULT (''),
[KeyFieldName15] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldName15] DEFAULT (''),
[KeyFieldParmLabel1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel1] DEFAULT (''),
[KeyFieldParmLabel2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel2] DEFAULT (''),
[KeyFieldParmLabel3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel3] DEFAULT (''),
[KeyFieldParmLabel4] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel4] DEFAULT (''),
[KeyFieldParmLabel5] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel5] DEFAULT (''),
[KeyFieldParmLabel6] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel6] DEFAULT (''),
[KeyFieldParmLabel7] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel7] DEFAULT (''),
[KeyFieldParmLabel8] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel8] DEFAULT (''),
[KeyFieldParmLabel9] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel9] DEFAULT (''),
[KeyFieldParmLabel10] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel10] DEFAULT (''),
[KeyFieldParmLabel11] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel11] DEFAULT (''),
[KeyFieldParmLabel12] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel12] DEFAULT (''),
[KeyFieldParmLabel13] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel13] DEFAULT (''),
[KeyFieldParmLabel14] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel14] DEFAULT (''),
[KeyFieldParmLabel15] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_KeyFieldParmLabel15] DEFAULT (''),
[ExtendedParm1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParm1] DEFAULT (''),
[ExtendedParm2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParm2] DEFAULT (''),
[ExtendedParm3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParm3] DEFAULT (''),
[ExtendedParm4] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParm4] DEFAULT (''),
[ExtendedParm5] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParm5] DEFAULT (''),
[ExtendedParmDefault1] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParmDefault1] DEFAULT (''),
[ExtendedParmDefault2] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParmDefault2] DEFAULT (''),
[ExtendedParmDefault3] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParmDefault3] DEFAULT (''),
[ExtendedParmDefault4] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParmDefault4] DEFAULT (''),
[ExtendedParmDefault5] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_ExtendedParmDefault5] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WMREPORT_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMREPORT_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WMREPORT_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WMREPORT] ADD CONSTRAINT [PK_WMREPORT] PRIMARY KEY CLUSTERED ([ReportID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_WMREPORT_MODULEID] ON [dbo].[WMREPORT] ([ModuleID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMREPORT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMREPORT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMREPORT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMREPORT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'WM Report Header', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Label 1', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParm1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Label 2', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParm2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Label 3', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParm3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Label 4', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParm4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Label 5', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParm5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Default Value 1', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParmDefault1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Default Value 2', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParmDefault2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Default Value 3', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParmDefault3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Default Value 4', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParmDefault4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameter Default Value 5', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ExtendedParmDefault5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 1', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 10', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 11', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 12', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName12'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 13', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName13'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 14', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName14'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 15', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 2', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 3', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 4', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 5', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 6', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 7', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 8', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Name 9', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldName9'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 1', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 10', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 11', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 12', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel12'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 13', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel13'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 14', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel14'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 15', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 2', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 3', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 4', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 5', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 6', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 7', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 8', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key Field Parm Label 9', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'KeyFieldParmLabel9'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Module ID', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ModuleID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'No Of KeyFieldParms Required ', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'NoOfKeyFieldParms'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Print Method (Bartender/WM)', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'PrintMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report ID', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ReportID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Title', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ReportTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Type', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'ReportType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WMREPORT', 'COLUMN', N'TrafficCop'
GO
