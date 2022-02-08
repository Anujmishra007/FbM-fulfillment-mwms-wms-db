CREATE TABLE [dbo].[PACKLOG]
(
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackDescr] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OldPackUOM1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OldCaseCnt] [float] NOT NULL,
[PackUOM1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseCnt] [float] NOT NULL,
[OLDPackUOM2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OLDInnerPack] [float] NOT NULL,
[PackUOM2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InnerPack] [float] NOT NULL,
[OLDPackUOM3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OLDQty] [float] NOT NULL,
[PackUOM3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [float] NOT NULL,
[OLDPackUOM4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OLDPallet] [float] NOT NULL,
[PackUOM4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pallet] [float] NOT NULL,
[EditDate] [datetime] NOT NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OLDLengthUOM1] [float] NOT NULL CONSTRAINT [DF_PACKLOG_OLDLengthUOM1] DEFAULT ((0)),
[LengthUOM1] [float] NOT NULL CONSTRAINT [DF_PACKLOG_LengthUOM1] DEFAULT ((0)),
[OLDWidththUOM1] [float] NOT NULL CONSTRAINT [DF_PACKLOG_OLDWidththUOM1] DEFAULT ((0)),
[WidthUOM1] [float] NOT NULL CONSTRAINT [DF_PACKLOG_WidthUOM1] DEFAULT ((0)),
[OLDHeightUOM1] [float] NOT NULL CONSTRAINT [DF_PACKLOG_OLDHeightUOM1] DEFAULT ((0)),
[HeightUOM1] [float] NOT NULL CONSTRAINT [DF_PACKLOG_HeightUOM1] DEFAULT ((0)),
[OLDCubeUOM1] [float] NOT NULL CONSTRAINT [DF_PACKLOG_OLDCubeUOM1] DEFAULT ((0)),
[CubeUOM1] [float] NOT NULL CONSTRAINT [DF_PACKLOG_CubeUOM1] DEFAULT ((0))
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PACKLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PACKLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PACKLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PACKLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PACKLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PACKLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Pack.', 'SCHEMA', N'dbo', 'TABLE', N'PACKLOG', 'COLUMN', N'PackDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'PACKLOG', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A portable platform designed to allow a forklift or a pallet jack to lift, move and store various loads.', 'SCHEMA', N'dbo', 'TABLE', N'PACKLOG', 'COLUMN', N'Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PACKLOG', 'COLUMN', N'Qty'
GO
