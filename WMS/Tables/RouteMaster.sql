CREATE TABLE [dbo].[RouteMaster]
(
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TruckType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Volume] [float] NULL,
[Weight] [float] NULL,
[CarrierKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_RouteMaster_AddDate] DEFAULT (getdate()),
[ZipCodeFrom] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_ZipCodeFrom] DEFAULT (' '),
[ZipCodeTo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_ZipCodeTo] DEFAULT (' '),
[SelfDelivery] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HandledByWH] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoOfDrops] [int] NULL,
[TMS_Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMS_Interface] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_TMS_Interface] DEFAULT (' '),
[ScheduleKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_ScheduleKey] DEFAULT (' '),
[EditDate] [datetime] NULL CONSTRAINT [DF_RouteMaster_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RouteMaster] ADD CONSTRAINT [PK_RouteMaster] PRIMARY KEY CLUSTERED ([Route]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[RouteMaster] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[RouteMaster] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RouteMaster] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RouteMaster] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RouteMaster] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Setup the available delivery routes. It is used in Order Processing', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the transporter', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'CarrierDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter code. Vendor which performs the transportation', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the route', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether the warehouse will be handling the deliveries for the particular route', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'HandledByWH'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total number of drops the truck will perform for the route', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'NoOfDrops'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the route', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'Route'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TMS interface information - not used at the moment', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'ScheduleKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates this route does not have any drops and deliveries are done by the salesman', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'SelfDelivery'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TMS interface information - not used at the moment', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'TMS_Interface'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TMS interface information - not used at the moment', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'TMS_Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of truck with capacity', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'TruckType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The max volume in which the truck carries', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'Volume'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The max weight in which the truck can carry', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The starting point post code', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'ZipCodeFrom'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The destination post code  - final drop', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'ZipCodeTo'
GO
