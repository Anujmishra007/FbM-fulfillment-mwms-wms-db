CREATE TABLE [dbo].[PutawayZone]
(
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_PutawayZone] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Descr] DEFAULT (' '),
[InLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_InLoc] DEFAULT (' '),
[OutLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_OutLoc] DEFAULT (' '),
[Uom1PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom1PickMethod] DEFAULT ('1'),
[Uom2PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom2PickMethod] DEFAULT ('3'),
[Uom3PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom3PickMethod] DEFAULT ('3'),
[Uom4PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom4PickMethod] DEFAULT ('1'),
[Uom5PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom5PickMethod] DEFAULT ('3'),
[Uom6PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Uom6PickMethod] DEFAULT ('3'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayZone_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayZone_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[No_Pallet] [int] NULL,
[ZoneCategory] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayZone_ZoneCategory] DEFAULT ('N'),
[Pallet_type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayZone_Pallet_type] DEFAULT (' '),
[Floor] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PUTAWAYZONE_Floor] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PutawayZone] ADD CONSTRAINT [PKPutawayZone] PRIMARY KEY CLUSTERED ([PutawayZone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PutawayZone] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PutawayZone] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PutawayZone] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PutawayZone] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PutawayZone] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A zone is a collection of locations. When a putaway zone is created, it is defining an area for the entire warehouse, and not just the putaway process.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Text description the zone', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The facility code where the zone is residing', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Staging location for inventory into the zone. This field was introduced for pick and drop functionality. In Loc represents the intermediate drop location that all products must pass through when going into a location in the putaway zone', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'InLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', '# Pallet - customized', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'No_Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This field was introduced for Pick and Drop functionality. Out Location represents the intermediate drop location that all product must pass through when leaving a location within the Putaway Zone', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'OutLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet Type - customized', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Pallet_type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code that identifies the name of the putaway zone', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'PutawayZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking cases in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom1PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom2PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking pieces or eaches in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom3PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking pallets in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom4PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Other pick method to use when picking in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom5PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Other pick method to use when picking in the zone. Options include: RF Directed, RF Assited Type 1, RF Assisted Type 2, List, Other 1 and Other 2', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'Uom6PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zone Category - customized', 'SCHEMA', N'dbo', 'TABLE', N'PutawayZone', 'COLUMN', N'ZoneCategory'
GO
