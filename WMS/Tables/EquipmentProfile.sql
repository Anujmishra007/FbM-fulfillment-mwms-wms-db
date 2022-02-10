CREATE TABLE [dbo].[EquipmentProfile]
(
[EquipmentProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EquipmentProfile_EquipmentProfileKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EquipmentProfile_Descr] DEFAULT (' '),
[MaximumWeight] [float] NOT NULL CONSTRAINT [DF_EquipmentProfile_MaximumWeight] DEFAULT ((9999999.0)),
[WeightReductionPerLevel] [float] NOT NULL CONSTRAINT [DF_EquipmentProfile_WeightReductionPerLevel] DEFAULT ((0.0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_EquipmentProfile_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EquipmentProfile_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_EquipmentProfile_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EquipmentProfile_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaximumLevel] [int] NOT NULL CONSTRAINT [DF_equipmentprofile_MaximumLevel] DEFAULT ((0)),
[MaximumHeight] [float] NOT NULL CONSTRAINT [DF_equipmentprofile_MaximumHeight] DEFAULT ((0.0)),
[MaximumPallet] [int] NOT NULL CONSTRAINT [DF_EquipmentProfile_MaximumPallet] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EquipmentProfile] ADD CONSTRAINT [PKEquipmentProfile] PRIMARY KEY CLUSTERED ([EquipmentProfileKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EquipmentProfile] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[EquipmentProfile] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[EquipmentProfile] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[EquipmentProfile] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'An equipment profile identifies each piece of equipment used in the facility and defines any restrictions associated with the equipment. You can exclude an equipment profile from certain zones (i.e. a piece of equipment may be unable to access the zone due to size or weight).', 'SCHEMA', N'dbo', 'TABLE', N'EquipmentProfile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'EquipmentProfile', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'EquipmentProfile', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of equipment profile.', 'SCHEMA', N'dbo', 'TABLE', N'EquipmentProfile', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'EquipmentProfile', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'EquipmentProfile', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the new equipment profile.', 'SCHEMA', N'dbo', 'TABLE', N'EquipmentProfile', 'COLUMN', N'EquipmentProfileKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The maximum gross weight the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'EquipmentProfile', 'COLUMN', N'MaximumWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'EquipmentProfile', 'COLUMN', N'TrafficCop'
GO
