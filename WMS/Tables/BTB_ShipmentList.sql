CREATE TABLE [dbo].[BTB_ShipmentList]
(
[BTB_ShipmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BTB_ShipmentListNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_Storerkey] DEFAULT (''),
[COO] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_COO] DEFAULT (''),
[BTBFNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_BTBFNo] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_ShipmentList_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_ShipmentList_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BTB_ShipmentList] ADD CONSTRAINT [PK__BTB_Ship__A8A22DBEA7AF1413] PRIMARY KEY CLUSTERED ([BTB_ShipmentKey], [BTB_ShipmentListNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BTB_ShipmentList_COO] ON [dbo].[BTB_ShipmentList] ([BTB_ShipmentKey], [BTB_ShipmentListNo], [Storerkey], [COO]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BTB_ShipmentList] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BTB_ShipmentList] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BTB_ShipmentList] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BTB_ShipmentList] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'BTB_ShipmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment Listing', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'BTB_ShipmentListNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BTBFNo', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'BTBFNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'COO', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'COO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'TrafficCop'
GO
