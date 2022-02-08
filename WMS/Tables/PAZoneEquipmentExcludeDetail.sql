CREATE TABLE [dbo].[PAZoneEquipmentExcludeDetail]
(
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PAZoneEquipmentExcludeDetail_PutawayZone] DEFAULT (' '),
[EquipmentProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PAZoneEquipmentExcludeDetail_EquipmentProfileKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PAZoneEquipmentExcludeDetail_Descr] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PAZoneEquipmentExcludeDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PAZoneEquipmentExcludeDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PAZoneEquipmentExcludeDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PAZoneEquipmentExcludeDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAZoneEquipmentExcludeDetail] ADD CONSTRAINT [PKPAZoneEquipmentExcludeDetail] PRIMARY KEY NONCLUSTERED ([PutawayZone], [EquipmentProfileKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PAZoneEquipmentExcludeDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PAZoneEquipmentExcludeDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PAZoneEquipmentExcludeDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PAZoneEquipmentExcludeDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PAZoneEquipmentExcludeDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PAZoneEquipmentExcludeDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Putaway Zone Equiment Exclude Detail.', 'SCHEMA', N'dbo', 'TABLE', N'PAZoneEquipmentExcludeDetail', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PAZoneEquipmentExcludeDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PAZoneEquipmentExcludeDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the new equipment profile.', 'SCHEMA', N'dbo', 'TABLE', N'PAZoneEquipmentExcludeDetail', 'COLUMN', N'EquipmentProfileKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Putaway location for the Commodity in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PAZoneEquipmentExcludeDetail', 'COLUMN', N'PutawayZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PAZoneEquipmentExcludeDetail', 'COLUMN', N'TrafficCop'
GO
