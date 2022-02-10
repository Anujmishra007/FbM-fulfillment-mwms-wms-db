CREATE TABLE [dbo].[WCSRoutingDetail]
(
[WCSKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToteNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_Zone] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_Status] DEFAULT ('0'),
[ActionFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_ActionFlag] DEFAULT (' '),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WCSRoutingDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WCSRoutingDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WCSRoutingDetail_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WCSRoutingDetail] ADD CONSTRAINT [PK_WCSRoutingDetail] PRIMARY KEY CLUSTERED ([WCSKey], [RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WCSRoutingDetail_ToteNo] ON [dbo].[WCSRoutingDetail] ([ToteNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WCSRoutingDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WCSRoutingDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WCSRoutingDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WCSRoutingDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WCSRoutingDetail', 'COLUMN', N'TrafficCop'
GO
