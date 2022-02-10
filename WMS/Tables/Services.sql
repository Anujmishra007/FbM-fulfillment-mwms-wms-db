CREATE TABLE [dbo].[Services]
(
[Servicekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Services_Descrip] DEFAULT (' '),
[SupportFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Services_SupportFlag] DEFAULT ('A'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Services_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Services_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Services_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Services_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Services] WITH NOCHECK ADD CONSTRAINT [CK_SERV_SupportFlag] CHECK (([SupportFLag]='D' OR [SupportFLag]='I' OR [SupportFLag]='A'))
GO
ALTER TABLE [dbo].[Services] ADD CONSTRAINT [PKService] PRIMARY KEY CLUSTERED ([Servicekey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Services] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Services] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Services] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Services] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Services', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Services', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the services.', 'SCHEMA', N'dbo', 'TABLE', N'Services', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Services', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Services', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Service.', 'SCHEMA', N'dbo', 'TABLE', N'Services', 'COLUMN', N'Servicekey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'Services', 'COLUMN', N'TrafficCop'
GO
