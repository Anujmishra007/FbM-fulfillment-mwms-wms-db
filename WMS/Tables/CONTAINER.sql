CREATE TABLE [dbo].[CONTAINER]
(
[ContainerKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CONTAINER_Status] DEFAULT ('0'),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CONTAINER_Vessel] DEFAULT (' '),
[Voyage] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CONTAINER_voyage] DEFAULT (' '),
[CarrierKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrieragent] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETA] [datetime] NULL,
[ETADestination] [datetime] NULL,
[BookingReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seal01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CONTAINER_seal01] DEFAULT (' '),
[Seal02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CONTAINER_seal02] DEFAULT (' '),
[Seal03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CONTAINER_seal03] DEFAULT (' '),
[ContainerType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CONTAINER_containertype] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_CONTAINER_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CONTAINER_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CONTAINER_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CONTAINER_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CONTAINER_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_container_MBOLKey] DEFAULT (' '),
[ExternContainerKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Container_ExternContainerKey] DEFAULT (''),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Container_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Container_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Container_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Container_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Container_UserDefine05] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Container_Loc] DEFAULT (''),
[ContainerSize] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Container_ContainerSize] DEFAULT (''),
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Container_Loadkey] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CONTAINER] WITH NOCHECK ADD CONSTRAINT [CK_CONTAINER_Status] CHECK (([Status]='9' OR [Status]='0' OR [Status]='5' OR [Status]='3'))
GO
ALTER TABLE [dbo].[CONTAINER] ADD CONSTRAINT [PKCONTAINER] PRIMARY KEY CLUSTERED ([ContainerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Container_mbolkey] ON [dbo].[CONTAINER] ([MBOLKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CONTAINER] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CONTAINER] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CONTAINER] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CONTAINER] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CONTAINER] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Carrier.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Container.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'ContainerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Container Size', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'ContainerSize'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load Plan Number', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'Loadkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINER', 'COLUMN', N'TrafficCop'
GO
