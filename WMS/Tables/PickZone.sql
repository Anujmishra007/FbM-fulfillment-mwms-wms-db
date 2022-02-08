CREATE TABLE [dbo].[PickZone]
(
[PickZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_PickZone] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_Descr] DEFAULT (' '),
[InLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_InLoc] DEFAULT (' '),
[OutLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_OutLoc] DEFAULT (' '),
[Uom1PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_Uom1PickMethod] DEFAULT ('1'),
[Uom2PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_Uom2PickMethod] DEFAULT ('3'),
[Uom3PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_Uom3PickMethod] DEFAULT ('3'),
[Uom4PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_Uom4PickMethod] DEFAULT ('1'),
[Uom5PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_Uom5PickMethod] DEFAULT ('3'),
[Uom6PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_Uom6PickMethod] DEFAULT ('3'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PickZone_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PickZone_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[No_Pallet] [int] NULL,
[ZoneCategory] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickZone_ZoneCategory] DEFAULT ('N'),
[Pallet_type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickZone_Pallet_type] DEFAULT (' '),
[Floor] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickZone_Floor] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PickZone] ADD CONSTRAINT [PKPickZone] PRIMARY KEY CLUSTERED ([PickZone]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PickZone] TO [ALPHA\GTWMSinfosys]
GO
GRANT INSERT ON  [dbo].[PickZone] TO [ALPHA\GTWMSinfosys]
GO
GRANT SELECT ON  [dbo].[PickZone] TO [ALPHA\GTWMSinfosys]
GO
GRANT UPDATE ON  [dbo].[PickZone] TO [ALPHA\GTWMSinfosys]
GO
GRANT DELETE ON  [dbo].[PickZone] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PickZone] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PickZone] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PickZone] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'A zone is a collection of locations. When a pickzone is created, it is defining an area for the entire warehouse, and not just the pick process.', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Text description the zone', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The facility code where the zone is residing', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Staging location for inventory into the zone. This field was introduced for pick and drop functionality. In Loc represents the intermediate drop location that all products must pass through when going into a location in the pickzone', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'InLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'# Pallet - customized', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'No_Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This field was introduced for Pick and Drop functionality. Out Location represents the intermediate drop location that all product must pass through when leaving a location within the Pickzone', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'OutLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Type - customized', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'Pallet_type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Code that identifies the name of the pickzone', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'PickZone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pick method to use when picking cases in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'Uom1PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pick method to use when picking inner packs in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'Uom2PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pick method to use when picking pieces or eaches in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'Uom3PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pick method to use when picking pallets in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'Uom4PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Other pick method to use when picking in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'Uom5PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Other pick method to use when picking in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'Uom6PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone Category - customized', 'SCHEMA', N'dbo', 'TABLE', N'PickZone', 'COLUMN', N'ZoneCategory'
GO
