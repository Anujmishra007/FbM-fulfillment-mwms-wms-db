CREATE TABLE [dbo].[TRIDENTSCHEDULER]
(
[TridentSchedulerKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Hikey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HiImpExp] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NextRunDate] [datetime] NULL,
[LastRunDate] [datetime] NULL,
[Frequency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRIDENTSCHEDULER_Frequency] DEFAULT ('D'),
[StartWindow] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartString] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnableFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRIDENTSCHEDULER_EnableFlag] DEFAULT ('D'),
[SkipDays] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SkipTime] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_TRIDENTSCHEDULER_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRIDENTSCHEDULER_AddWho] DEFAULT (user_name(NULL))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TRIDENTSCHEDULER] ADD CONSTRAINT [PKscheduler] PRIMARY KEY NONCLUSTERED ([TridentSchedulerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TRIDENTSCHEDULER] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TRIDENTSCHEDULER] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TRIDENTSCHEDULER] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TRIDENTSCHEDULER] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRIDENTSCHEDULER', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRIDENTSCHEDULER', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Host Interface.', 'SCHEMA', N'dbo', 'TABLE', N'TRIDENTSCHEDULER', 'COLUMN', N'Hikey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Trident Scheduler.', 'SCHEMA', N'dbo', 'TABLE', N'TRIDENTSCHEDULER', 'COLUMN', N'TridentSchedulerKey'
GO
