CREATE TABLE [dbo].[Section]
(
[SectionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Section_SectionKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Section_Descr] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Section_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Section_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Section_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Section_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Section] ADD CONSTRAINT [PKSection] PRIMARY KEY CLUSTERED ([SectionKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Section] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Section] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Section] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Section] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A section is a collection of areas.', 'SCHEMA', N'dbo', 'TABLE', N'Section', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Section', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Section', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the section.', 'SCHEMA', N'dbo', 'TABLE', N'Section', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Section', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Section', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The name of the section in the warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'Section', 'COLUMN', N'SectionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'Section', 'COLUMN', N'TrafficCop'
GO
