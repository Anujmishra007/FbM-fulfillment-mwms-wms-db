CREATE TABLE [dbo].[AreaDetail]
(
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_AreaKey] DEFAULT (' '),
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_PutawayZone] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AreaDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AreaDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AreaDetail] ADD CONSTRAINT [PKAreaDetail] PRIMARY KEY CLUSTERED ([AreaKey], [PutawayZone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[AreaDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[AreaDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AreaDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AreaDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AreaDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'An area is a collection of zones. Each zone can be in one or more areas.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Area Detail.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'AreaKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zone to which the Location is assigned.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'PutawayZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AreaDetail', 'COLUMN', N'TrafficCop'
GO
