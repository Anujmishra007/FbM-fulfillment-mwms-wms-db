CREATE TABLE [dbo].[TPPRINTCONFIG]
(
[Storerkey] [nvarchar] (15) NOT NULL,
[Shipperkey] [nvarchar] (15) NOT NULL,
[Module] [nvarchar] (20) NOT NULL CONSTRAINT [DF_TPPRINTCONFIG_Module] DEFAULT (''),
[ReportType] [nvarchar] (10) NOT NULL CONSTRAINT [DF_TPPRINTCONFIG_ReportType] DEFAULT (''),
[PrePrint_StoredProc] [nvarchar] (30) NOT NULL,
[TPPrint_StoredProc] [nvarchar] (30) NOT NULL,
[Platform] [nvarchar] (30) NOT NULL CONSTRAINT [DF_TPPRINTCONFIG_Platform] DEFAULT (''),
[Description] [nvarchar] (250) NULL,
[ActiveFlag] [nvarchar] (5) NOT NULL,
[UDF01] [nvarchar] (200) NULL DEFAULT (''),
[UDF02] [nvarchar] (200) NULL DEFAULT (''),
[UDF03] [nvarchar] (200) NULL DEFAULT (''),
[UDF04] [nvarchar] (500) NULL DEFAULT (''),
[UDF05] [nvarchar] (4000) NULL DEFAULT (''),
[AddDate] [datetime] NULL DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NULL DEFAULT (suser_sname()),
[EditDate] [datetime] NULL DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NULL DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TPPRINTCONFIG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TPPRINTCONFIG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TPPRINTCONFIG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TPPRINTCONFIG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trade Partner Printing Configuration', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enable or Disable flag', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'ActiveFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Added By User Date', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Added By User ID', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Setting Description', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edited By User Date', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edited By User ID', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Application Module', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'Module'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Printing Platform', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'Platform'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Custom Pre-Print SP', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'PrePrint_StoredProc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Report Type', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'ReportType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipper', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'Shipperkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Custom TP Print SP', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'TPPrint_StoredProc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCONFIG', 'COLUMN', N'UDF05'
GO
