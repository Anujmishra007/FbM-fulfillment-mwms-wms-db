CREATE TABLE [dbo].[TaxGroup]
(
[TaxGroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SupportFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxGroup_SupportFlag] DEFAULT ('A'),
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxGroup_Descrip] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaxGroup_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxGroup_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TaxGroup_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxGroup_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaxGroup] WITH NOCHECK ADD CONSTRAINT [CK_TaxGroup_SupportFlag] CHECK (([SupportFLag]='D' OR [SupportFLag]='I' OR [SupportFLag]='A'))
GO
ALTER TABLE [dbo].[TaxGroup] ADD CONSTRAINT [PKTAXGROUP] PRIMARY KEY CLUSTERED ([TaxGroupKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TaxGroup] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaxGroup] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaxGroup] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaxGroup] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroup', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroup', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Tax Group.', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroup', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroup', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroup', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Group.', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroup', 'COLUMN', N'TaxGroupKey'
GO
