CREATE TABLE [dbo].[CBOL]
(
[CBOLKey] [int] NOT NULL,
[CBOLReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_CBOLReference] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_Facility] DEFAULT ('F1'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CBOL_Status] DEFAULT ('0'),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CBOL_Type] DEFAULT ((0)),
[RoutingDate] [datetime] NOT NULL CONSTRAINT [DF_CBOL_RoutingDate] DEFAULT (getdate()),
[PickupDate] [datetime] NOT NULL CONSTRAINT [DF_CBOL_PickupDate] DEFAULT (getdate()),
[DepartureDate] [datetime] NOT NULL CONSTRAINT [DF_CBOL_DepartureDate] DEFAULT (getdate()),
[ArivalDate] [datetime] NOT NULL CONSTRAINT [DF_CBOL_ArivalDate] DEFAULT (getdate()),
[CancelDate] [datetime] NOT NULL CONSTRAINT [DF_CBOL_CancelDate] DEFAULT (getdate()),
[RoutingCIDNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_RoutingCIDNo] DEFAULT (''),
[SCAC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_SCAC] DEFAULT (''),
[ProNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_ProNumber] DEFAULT (''),
[VehicleContainer] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_VehicleContainer] DEFAULT (''),
[SealNo] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_SealNo] DEFAULT (''),
[CountedBy] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_CountedBy] DEFAULT (''),
[ChargeCollected] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_ChargeCollected] DEFAULT (''),
[TrailerLoadBy] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_TrailerLoadBy] DEFAULT (''),
[Carrierkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CBOL_Carrierkey] DEFAULT (''),
[CTNTYPE1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_CTNTYPE1] DEFAULT (''),
[CTNTYPE2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_CTNTYPE2] DEFAULT (''),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL CONSTRAINT [DF_CBOL_UserDefine06] DEFAULT (getdate()),
[UserDefine07] [datetime] NULL CONSTRAINT [DF_CBOL_UserDefine07] DEFAULT (getdate()),
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_UserDefine10] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CBOL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CBOL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CBOL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CBOL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Consigneekey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CBOL_Consigneekey] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CBOL] ADD CONSTRAINT [PK_CBOL] PRIMARY KEY CLUSTERED ([CBOLKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CBOL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CBOL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CBOL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CBOL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The Consolidated Master Bill of Lading (CBOL) is used to combine multiple MBOL, pallets, or containers being transported via the Carrier. If the status is changed to ôShippedö, all goods down to the case level are shipped from inventory.', 'SCHEMA', N'dbo', 'TABLE', N'CBOL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CBOL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CBOL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CBOL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CBOL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CBOL', 'COLUMN', N'TrafficCop'
GO
