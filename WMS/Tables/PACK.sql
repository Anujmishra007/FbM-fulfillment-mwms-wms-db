CREATE TABLE [dbo].[PACK]
(
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackDescr] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackUOM1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM1] DEFAULT (' '),
[CaseCnt] [float] NOT NULL CONSTRAINT [DF_PACK_CaseCnt] DEFAULT ((0)),
[ISWHQty1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty1] DEFAULT (' '),
[ReplenishUOM1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM1] DEFAULT ('N'),
[ReplenishZone1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone1] DEFAULT ('N'),
[CartonizeUOM1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM1] DEFAULT ('N'),
[LengthUOM1] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom1] DEFAULT ((0)),
[WidthUOM1] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom1] DEFAULT ((0)),
[HeightUOM1] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom1] DEFAULT ((0)),
[CubeUOM1] [float] NOT NULL CONSTRAINT [DF_PACK_CubeUOM1] DEFAULT ((0)),
[PackUOM2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM2] DEFAULT (' '),
[InnerPack] [float] NOT NULL CONSTRAINT [DF_PACK_InnerPack] DEFAULT ((0)),
[ISWHQty2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty2] DEFAULT (' '),
[ReplenishUOM2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM2] DEFAULT ('N'),
[ReplenishZone2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone2] DEFAULT ('N'),
[CartonizeUOM2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM2] DEFAULT ('N'),
[LengthUOM2] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom2] DEFAULT ((0)),
[WidthUOM2] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom2] DEFAULT ((0)),
[HeightUOM2] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom2] DEFAULT ((0)),
[CubeUOM2] [float] NOT NULL CONSTRAINT [DF_PACK_CubeUOM2] DEFAULT ((0)),
[PackUOM3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM3] DEFAULT (' '),
[Qty] [float] NOT NULL CONSTRAINT [DF_PACK_Qty] DEFAULT ((0)),
[ISWHQty3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty3] DEFAULT (' '),
[ReplenishUOM3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM3] DEFAULT ('Y'),
[ReplenishZone3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone3] DEFAULT ('N'),
[CartonizeUOM3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM3] DEFAULT ('N'),
[LengthUOM3] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom3] DEFAULT ((0)),
[WidthUOM3] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom3] DEFAULT ((0)),
[HeightUOM3] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom3] DEFAULT ((0)),
[CubeUOM3] [float] NOT NULL CONSTRAINT [DF_PACK_CubeUOM3] DEFAULT ((0)),
[PackUOM4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM4] DEFAULT (' '),
[Pallet] [float] NOT NULL CONSTRAINT [DF_PACK_Pallet] DEFAULT ((0)),
[ISWHQty4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty4] DEFAULT (' '),
[ReplenishUOM4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM4] DEFAULT ('N'),
[ReplenishZone4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone4] DEFAULT ('N'),
[CartonizeUOM4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM4] DEFAULT ('N'),
[LengthUOM4] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom4] DEFAULT ((0)),
[WidthUOM4] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom4] DEFAULT ((0)),
[HeightUOM4] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom4] DEFAULT ((0)),
[CubeUOM4] [float] NOT NULL CONSTRAINT [DF_PACK_CubeUOM4] DEFAULT ((0)),
[PalletWoodLength] [float] NOT NULL CONSTRAINT [DF_PACK_PalletWoodLength] DEFAULT ((0)),
[PalletWoodWidth] [float] NOT NULL CONSTRAINT [DF_PACK_PalletWoodWidth] DEFAULT ((0)),
[PalletWoodHeight] [float] NOT NULL CONSTRAINT [DF_PACK_PalletWoodHeight] DEFAULT ((0)),
[PalletTI] [int] NOT NULL CONSTRAINT [DF_PACK_PalletTI] DEFAULT ((0)),
[PalletHI] [int] NOT NULL CONSTRAINT [DF_PACK_PalletHI] DEFAULT ((0)),
[PackUOM5] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM5] DEFAULT (' '),
[Cube] [float] NOT NULL CONSTRAINT [DF_PACK_Cube] DEFAULT ((0)),
[ISWHQty5] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty5] DEFAULT (' '),
[PackUOM6] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM6] DEFAULT (' '),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_PACK_GrossWgt] DEFAULT ((0)),
[ISWHQty6] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty6] DEFAULT (' '),
[PackUOM7] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM7] DEFAULT (' '),
[NetWgt] [float] NOT NULL CONSTRAINT [DF_PACK_NetWgt] DEFAULT ((0)),
[ISWHQty7] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty7] DEFAULT (' '),
[PackUOM8] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACK_PackUOM8] DEFAULT (' '),
[OtherUnit1] [float] NOT NULL CONSTRAINT [DF_PACK_OtherUnit1] DEFAULT ((0)),
[ISWHQty8] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty8] DEFAULT (' '),
[ReplenishUOM8] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM8] DEFAULT ('N'),
[ReplenishZone8] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone8] DEFAULT ('N'),
[CartonizeUOM8] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM8] DEFAULT ('N'),
[LengthUOM8] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom8] DEFAULT ((0)),
[WidthUOM8] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom8] DEFAULT ((0)),
[HeightUOM8] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom8] DEFAULT ((0)),
[PackUOM9] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM9] DEFAULT (' '),
[OtherUnit2] [float] NOT NULL CONSTRAINT [DF_PACK_OtherUnit2] DEFAULT ((0)),
[ISWHQty9] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty9] DEFAULT (' '),
[ReplenishUOM9] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM9] DEFAULT ('N'),
[ReplenishZone9] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone9] DEFAULT ('N'),
[CartonizeUOM9] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM9] DEFAULT ('N'),
[LengthUOM9] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom9] DEFAULT ((0)),
[WidthUOM9] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom9] DEFAULT ((0)),
[HeightUOM9] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom9] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PACK_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PACK_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PACK] WITH NOCHECK ADD CONSTRAINT [CK_Pack_NoDuplicates1] CHECK ((isnull(rtrim([PackUOM1]),' ')=' ' OR isnull(rtrim([PackUOM4]),' ')=' ' OR rtrim([PackUOM1])<>rtrim([PackUOM4])))
GO
ALTER TABLE [dbo].[PACK] WITH NOCHECK ADD CONSTRAINT [CK_Pack_NoDuplicates2] CHECK ((isnull(rtrim([PackUOM2]),' ')=' ' OR isnull(rtrim([PackUOM3]),' ')=' ' OR rtrim([PackUOM2])<>rtrim([PackUOM3])))
GO
ALTER TABLE [dbo].[PACK] ADD CONSTRAINT [PKPack] PRIMARY KEY CLUSTERED ([PackKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PACK] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PACK] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PACK] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PACK] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PACK] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Together with UOM(s), the pack codes are used to determine the measurements in which the WMS uses to track products in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PACK', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Check box that determines whether cartonization routines run for each UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'CartonizeUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'CaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'cube', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'grosswgt', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'GrossWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Height:', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'InnerPack'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'netwgt', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'NetWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'OtherUnit1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'otherunit2', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'OtherUnit2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Text describing the pack code', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'packuom5', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'packuom6', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of tiers per pallet', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletHI'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of cases per tier', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletTI'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the physical pallet wood', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletWoodHeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the physical pallet wood', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletWoodLength'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the physical pallet wood', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletWoodWidth'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'replenishuom1', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'replenishuom2', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Check box that determines whether replenishment routings run for each UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM8'
GO
