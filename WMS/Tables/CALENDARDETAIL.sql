CREATE TABLE [dbo].[CALENDARDETAIL]
(
[CalendarGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PeriodEnd] [datetime] NOT NULL,
[SplitDate] [datetime] NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CALENDARDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CALENDARDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CALENDARDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CALENDARDETAIL_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CALENDARDETAIL] ADD CONSTRAINT [PKCalendarDetail] PRIMARY KEY CLUSTERED ([CalendarGroup], [PeriodEnd]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CALENDARDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_CalendarDet_Calendar_01] FOREIGN KEY ([CalendarGroup]) REFERENCES [dbo].[CALENDAR] ([CalendarGroup])
GO
GRANT DELETE ON  [dbo].[CALENDARDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CALENDARDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CALENDARDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CALENDARDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CALENDARDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'CALENDARDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CALENDARDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CALENDARDETAIL', 'COLUMN', N'EditWho'
GO
