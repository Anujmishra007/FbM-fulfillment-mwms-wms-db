CREATE TABLE [dbo].[OrderToLocDetail]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderToLocDetail_Loc] DEFAULT (' '),
[CartonID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderToLocDetail_CartonID] DEFAULT (' '),
[Wavekey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderToLocDetail_Wavekey] DEFAULT (' '),
[PTSZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderToLocDetail_PTSZone] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderToLocDetail_Status] DEFAULT ('1'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderToLocDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_OrderToLocDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderToLocDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_OrderToLocDetail_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StoreGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderToLocDetail_StoreGroup] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderToLocDetail] ADD CONSTRAINT [PK_OrderToLocDetail] PRIMARY KEY CLUSTERED ([OrderKey], [LOC]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderToLocDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OrderToLocDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OrderToLocDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OrderToLocDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderToLocDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderToLocDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Carton ID', 'SCHEMA', N'dbo', 'TABLE', N'OrderToLocDetail', 'COLUMN', N'CartonID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderToLocDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderToLocDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location', 'SCHEMA', N'dbo', 'TABLE', N'OrderToLocDetail', 'COLUMN', N'LOC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order Key', 'SCHEMA', N'dbo', 'TABLE', N'OrderToLocDetail', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'OrderToLocDetail', 'COLUMN', N'TrafficCop'
GO
