CREATE TABLE [dbo].[StoreToLocDetail]
(
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StoreToLocDetail_Status] DEFAULT ('1'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StoreToLocDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_StoreToLocDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StoreToLocDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_StoreToLocDetail_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocFull] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StoreToLocDetail_LocFull] DEFAULT ('N'),
[StoreGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StoreToLocDetail_StoreGroup] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StoreToLocDetail] ADD CONSTRAINT [PK_StoreToLocDetail] PRIMARY KEY CLUSTERED ([ConsigneeKey], [LOC]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[StoreToLocDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StoreToLocDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StoreToLocDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StoreToLocDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StoreToLocDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'StoreToLocDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Consigneekey', 'SCHEMA', N'dbo', 'TABLE', N'StoreToLocDetail', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StoreToLocDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'StoreToLocDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location', 'SCHEMA', N'dbo', 'TABLE', N'StoreToLocDetail', 'COLUMN', N'LOC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'StoreToLocDetail', 'COLUMN', N'TrafficCop'
GO
