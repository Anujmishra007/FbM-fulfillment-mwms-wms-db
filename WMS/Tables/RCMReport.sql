CREATE TABLE [dbo].[RCMReport]
(
[ComputerName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PB_Datawindow] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rpt_Printer] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RCMReport_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RCMReport_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RCMReport_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RCMReport_EditDate] DEFAULT (getdate()),
[ExtendParmName1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmDefault1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault1] DEFAULT (''),
[ExtendParmDefault2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault2] DEFAULT (''),
[ExtendParmDefault3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault3] DEFAULT (''),
[ExtendParmDefault4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault4] DEFAULT (''),
[ExtendParmDefault5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault5] DEFAULT (''),
[AutoPrint] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RCMREPORT_AutoPrint] DEFAULT ('N'),
[JReportCatalog] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JReportFileName] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JReportFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmDefault6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault6] DEFAULT (''),
[ExtendParmDefault7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault7] DEFAULT (''),
[ExtendParmDefault8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault8] DEFAULT (''),
[ExtendParmDefault9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault9] DEFAULT (''),
[ExtendParmDefault10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault10] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RCMReport] ADD CONSTRAINT [PKRCMReport] PRIMARY KEY CLUSTERED ([ComputerName], [StorerKey], [ReportType]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RCMReport] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RCMReport] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RCMReport] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RCMReport] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Auto Print at end of a event/function', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'AutoPrint'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 10 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 6 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 7 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 8 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 9 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault9'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 10 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 6 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 7 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 8 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 9 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'StorerKey'
GO
