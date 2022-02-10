CREATE TABLE [dbo].[CODELKUP]
(
[LISTNAME] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Short] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Long] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CODELKUP_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CODELKUP_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CODELKUP_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CODELKUP_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[Notes2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_Storerkey] DEFAULT (' '),
[UDF01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF01] DEFAULT (' '),
[UDF02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF02] DEFAULT (' '),
[UDF03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF03] DEFAULT (' '),
[UDF04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF04] DEFAULT (' '),
[UDF05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_UDF05] DEFAULT (' '),
[code2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Codelkup_code2] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CODELKUP] ADD CONSTRAINT [PKCODELKUP] PRIMARY KEY CLUSTERED ([LISTNAME], [Code], [Storerkey], [code2]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CODELKUP_SHORT] ON [dbo].[CODELKUP] ([Short], [LISTNAME], [UDF01]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CODELKUP_STORERKEY] ON [dbo].[CODELKUP] ([Storerkey], [LISTNAME], [Short]) INCLUDE ([Description]) WITH (FILLFACTOR=85) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CODELKUP] WITH NOCHECK ADD CONSTRAINT [FK_CODELKUP_LISTNAME_01] FOREIGN KEY ([LISTNAME]) REFERENCES [dbo].[CODELIST] ([LISTNAME])
GO
GRANT SELECT ON  [dbo].[CODELKUP] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CODELKUP] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CODELKUP] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CODELKUP] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CODELKUP] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of listname.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information regarding code lookup.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information regarding code lookup.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CODELKUP', 'COLUMN', N'TrafficCop'
GO
