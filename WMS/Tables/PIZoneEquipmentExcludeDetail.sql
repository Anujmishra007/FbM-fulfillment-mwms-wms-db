CREATE TABLE [dbo].[PIZoneEquipmentExcludeDetail]
(
[PickZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PIZoneEquipmentExcludeDetail_PickZone] DEFAULT (' '),
[EquipmentProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PIZoneEquipmentExcludeDetail_EquipmentProfileKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PIZoneEquipmentExcludeDetail_Descr] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PIZoneEquipmentExcludeDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PIZoneEquipmentExcludeDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PIZoneEquipmentExcludeDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PIZoneEquipmentExcludeDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PIZoneEquipmentExcludeDetail] ADD CONSTRAINT [PKPIZoneEquipmentExcludeDetail] PRIMARY KEY NONCLUSTERED ([PickZone], [EquipmentProfileKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PIZoneEquipmentExcludeDetail] TO [ALPHA\GTWMSinfosys]
GO
GRANT INSERT ON  [dbo].[PIZoneEquipmentExcludeDetail] TO [ALPHA\GTWMSinfosys]
GO
GRANT SELECT ON  [dbo].[PIZoneEquipmentExcludeDetail] TO [ALPHA\GTWMSinfosys]
GO
GRANT UPDATE ON  [dbo].[PIZoneEquipmentExcludeDetail] TO [ALPHA\GTWMSinfosys]
GO
GRANT DELETE ON  [dbo].[PIZoneEquipmentExcludeDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PIZoneEquipmentExcludeDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PIZoneEquipmentExcludeDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PIZoneEquipmentExcludeDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PIZoneEquipmentExcludeDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PIZoneEquipmentExcludeDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of PickZone Equiment Exclude Detail.', 'SCHEMA', N'dbo', 'TABLE', N'PIZoneEquipmentExcludeDetail', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PIZoneEquipmentExcludeDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PIZoneEquipmentExcludeDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying the new equipment profile.', 'SCHEMA', N'dbo', 'TABLE', N'PIZoneEquipmentExcludeDetail', 'COLUMN', N'EquipmentProfileKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Putaway location for the Commodity in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PIZoneEquipmentExcludeDetail', 'COLUMN', N'PickZone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PIZoneEquipmentExcludeDetail', 'COLUMN', N'TrafficCop'
GO
