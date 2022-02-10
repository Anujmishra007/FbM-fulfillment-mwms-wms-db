CREATE TABLE [dbo].[IDS_LP_VEHICLE]
(
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VehicleNumber] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Linenumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_LP_VEHICLE_Linenumber] DEFAULT (' '),
[EditDate] [datetime] NULL CONSTRAINT [DF_IDS_LP_VEHICLE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IDS_LP_VEHICLE_EditWho] DEFAULT (suser_sname()),
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_LP_VEHICLE_MBOLKEY] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[IDS_LP_VEHICLE] ADD CONSTRAINT [PK_IDS_LP_VEHICLE] PRIMARY KEY CLUSTERED ([Loadkey], [VehicleNumber], [MBOLKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[IDS_LP_VEHICLE] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[IDS_LP_VEHICLE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_LP_VEHICLE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_LP_VEHICLE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_LP_VEHICLE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_LP_VEHICLE', 'COLUMN', N'Loadkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'MBOL Number', 'SCHEMA', N'dbo', 'TABLE', N'IDS_LP_VEHICLE', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying the vehicle.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_LP_VEHICLE', 'COLUMN', N'VehicleNumber'
GO
