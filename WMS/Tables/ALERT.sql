CREATE TABLE [dbo].[ALERT]
(
[AlertKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModuleName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AlertMessage] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Severity] [int] NOT NULL CONSTRAINT [DF_ALERT_Severity] DEFAULT ((5)),
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_ALERT_LogDate] DEFAULT (getdate()),
[UserId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ALERT_UserId] DEFAULT (suser_sname()),
[NotifyId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ALERT_NotifyId] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ALERT_Status] DEFAULT ('0'),
[Resolution] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ALERT_Resolution] DEFAULT (' '),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[Activity] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_Activity] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_Storerkey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_SKU] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_UOM] DEFAULT (''),
[UOMQty] [int] NULL CONSTRAINT [DF_ALERT_UOMQty] DEFAULT ((0)),
[Qty] [int] NULL CONSTRAINT [DF_ALERT_Qty] DEFAULT ((0)),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_Lot] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_Loc] DEFAULT (''),
[ID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_ID] DEFAULT (''),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_TaskDetailKey] DEFAULT (''),
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_UCCNo] DEFAULT (''),
[ResolveDate] [datetime] NULL,
[TaskDetailKey2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_TaskDetailKey2] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ALERT] ADD CONSTRAINT [PKALert] PRIMARY KEY CLUSTERED ([AlertKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ALERT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ALERT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ALERT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ALERT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Alert.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'AlertKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Message displayed when alert ', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'AlertMessage'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of stored procedures.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'ModuleName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The level of severity.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'Severity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Username/login ID of staff who logged in during the alert.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'UserId'
GO
