CREATE TABLE [dbo].[ApptId]
(
[ApptId] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDateTime] [datetime] NULL,
[EndDateTime] [datetime] NULL,
[ApptType] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Dock] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipmentType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BookingDate] [datetime] NULL,
[DocumentNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleType] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleNo] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingLine] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefined1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefined2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefined3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefined4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefined5] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ApptId_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ApptId_Adddate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ApptId_Editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ApptId_Editdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApptId] ADD CONSTRAINT [PKAPPTID] PRIMARY KEY CLUSTERED ([ApptId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ApptId] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ApptId] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ApptId] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ApptId] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Carrier.', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the container.', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'ContainerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Document.', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'DocumentNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of Document.', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'DocumentType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional comments.', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'Notes1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional comments.', 'SCHEMA', N'dbo', 'TABLE', N'ApptId', 'COLUMN', N'Notes2'
GO
