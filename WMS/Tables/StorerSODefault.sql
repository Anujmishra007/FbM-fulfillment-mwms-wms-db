CREATE TABLE [dbo].[StorerSODefault]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillTo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Door] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stop] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destination] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Terms] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryPlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_StorerSODefault_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerSODefault_AddWho] DEFAULT (suser_sname()),
[xDockLane] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSoDefault_XDockLane] DEFAULT (' '),
[XDockRoute] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XDockSTOP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CutOffHour] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CutOffMin] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryTerm] [int] NULL CONSTRAINT [DF_StorerSODefault_DeliveryTerm] DEFAULT ((0)),
[Mon] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Mon] DEFAULT ((0)),
[Tue] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Tue] DEFAULT ((0)),
[Wed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Wed] DEFAULT ((0)),
[Thu] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Thu] DEFAULT ((0)),
[Fri] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Fri] DEFAULT ((0)),
[Sat] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Sat] DEFAULT ((0)),
[Sun] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_Sun] DEFAULT ((0)),
[HolidayKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_ScheduleKey] DEFAULT (' '),
[AddrOvrFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerSODefault_AddrOvrFlag] DEFAULT (' '),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_StorerSODefault_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerSODefault_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[StorerSODefault] ADD CONSTRAINT [PK_StorerSODefault] PRIMARY KEY CLUSTERED ([StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[StorerSODefault] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[StorerSODefault] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StorerSODefault] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StorerSODefault] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StorerSODefault] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer Sales Order Default is built to accommodate the orders data default during the orders import', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'billto', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'BillTo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'door', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'Door'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying holiday.', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'HolidayKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order Type', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'OrderType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Shedule.', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'ScheduleKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer Key', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'xdockstop', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefault', 'COLUMN', N'XDockSTOP'
GO
