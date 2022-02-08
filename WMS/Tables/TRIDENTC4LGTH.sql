CREATE TABLE [dbo].[TRIDENTC4LGTH]
(
[TridentSchedulerKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Hikey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HiImpExp] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NextRunDate] [datetime] NULL,
[LastRunDate] [datetime] NULL,
[Frequency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRIDENTC4LGTH_Frequency] DEFAULT ('D'),
[StartWindow] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartString] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnableFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SkipDays] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRIDENTC4LGTH_SkipDays] DEFAULT ('D'),
[SkipTime] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_TRIDENTC4LGTH_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRIDENTC4LGTH_AddWho] DEFAULT (user_name(NULL))
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [PKscheduler] ON [dbo].[TRIDENTC4LGTH] ([TridentSchedulerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TRIDENTC4LGTH] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TRIDENTC4LGTH] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TRIDENTC4LGTH] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TRIDENTC4LGTH] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRIDENTC4LGTH', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRIDENTC4LGTH', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Host Interface.', 'SCHEMA', N'dbo', 'TABLE', N'TRIDENTC4LGTH', 'COLUMN', N'Hikey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Trident Scheduler.', 'SCHEMA', N'dbo', 'TABLE', N'TRIDENTC4LGTH', 'COLUMN', N'TridentSchedulerKey'
GO
