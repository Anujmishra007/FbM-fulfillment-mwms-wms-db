CREATE TABLE [dbo].[IDS_VEHICLE]
(
[VehicleNumber] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VehicleDescr] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [float] NULL,
[Volume] [float] NULL,
[Method] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrierkey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Agent] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_IDS_VEHICLE_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IDS_VEHICLE_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_IDS_VEHICLE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IDS_VEHICLE_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[IDS_VEHICLE] ADD CONSTRAINT [PK_IDS_VEHICLE] PRIMARY KEY CLUSTERED ([VehicleNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDS_VEHICLE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_VEHICLE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_VEHICLE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_VEHICLE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Setup the vehicles or transports details for automatic load planning calculation', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Carrier.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'Carrierkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the vehicle.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'VehicleDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying the vehicle.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'VehicleNumber'
GO
