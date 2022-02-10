CREATE TABLE [dbo].[TPPRINTERGROUP]
(
[TPPrinterGroup] [nvarchar] (20) NOT NULL,
[PrinterPlatform] [nvarchar] (30) NOT NULL CONSTRAINT [DF_TPPRINTERGROUP_PrinterPlatform] DEFAULT (''),
[Description] [nvarchar] (60) NOT NULL CONSTRAINT [DF_TPPRINTERGROUP_Description] DEFAULT (''),
[IPAddress] [nvarchar] (40) NOT NULL CONSTRAINT [DF_TPPRINTERGROUP_IPAddress] DEFAULT (''),
[PortNo] [nvarchar] (5) NOT NULL CONSTRAINT [DF_TPPRINTERGROUP_PortNo] DEFAULT (''),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_TPPRINTERGROUP_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TPPRINTERGROUP_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_TPPRINTERGROUP_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TPPRINTERGROUP_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPPRINTERGROUP] ADD CONSTRAINT [PK_TPPRINTERGROUP] PRIMARY KEY CLUSTERED ([TPPrinterGroup], [PrinterPlatform]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TPPRINTERGROUP] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TPPRINTERGROUP] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TPPRINTERGROUP] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TPPRINTERGROUP] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trade Partner Printer Group Configuration', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTERGROUP', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Added By User Date', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTERGROUP', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Added By User ID', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTERGROUP', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTERGROUP', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edited By User Date', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTERGROUP', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edited By User ID', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTERGROUP', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'IPAddress', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTERGROUP', 'COLUMN', N'IPAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PortNo', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTERGROUP', 'COLUMN', N'PortNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PortNo', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTERGROUP', 'COLUMN', N'PrinterPlatform'
GO
