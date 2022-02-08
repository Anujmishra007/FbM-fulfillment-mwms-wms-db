CREATE TABLE [dbo].[CODELIST]
(
[LISTNAME] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DESCRIPTION] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CODELIST_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CODELIST_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CODELIST_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CODELIST_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[ListGroup] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CODELIST_TYPE] DEFAULT (''),
[UDF01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CODELIST_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CODELIST_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CODELIST_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CODELIST_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CODELIST_UDF05] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CODELIST] ADD CONSTRAINT [PKCodeList] PRIMARY KEY CLUSTERED ([LISTNAME]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CODELIST] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CODELIST] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CODELIST] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CODELIST] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CODELIST] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of listname. ', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'DESCRIPTION'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'List Name', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'LISTNAME'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Code list Type', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 01', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 02', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 03', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 04', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 05', 'SCHEMA', N'dbo', 'TABLE', N'CODELIST', 'COLUMN', N'UDF05'
GO
