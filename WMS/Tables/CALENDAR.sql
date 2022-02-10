CREATE TABLE [dbo].[CALENDAR]
(
[CalendarGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CALENDAR_Description] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Calendar_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Calendar_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Calendar_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Calendar_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CALENDAR] ADD CONSTRAINT [PKCalendar] PRIMARY KEY CLUSTERED ([CalendarGroup]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CALENDAR] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CALENDAR] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CALENDAR] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CALENDAR] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CALENDAR', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CALENDAR', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of calendar.', 'SCHEMA', N'dbo', 'TABLE', N'CALENDAR', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CALENDAR', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CALENDAR', 'COLUMN', N'EditWho'
GO
