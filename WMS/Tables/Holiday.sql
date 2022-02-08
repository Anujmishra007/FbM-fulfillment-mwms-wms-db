CREATE TABLE [dbo].[Holiday]
(
[HolidayKey] [int] NOT NULL IDENTITY(1, 1),
[Holiday] [datetime] NOT NULL,
[DayDesc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DayOfWeek] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Holiday] ADD CONSTRAINT [PK_Holiday] PRIMARY KEY CLUSTERED ([HolidayKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Holiday] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Holiday] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Holiday] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Holiday] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Setup the holidays for the facility. Information will be used during order processing', 'SCHEMA', N'dbo', 'TABLE', N'Holiday', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of holiday.', 'SCHEMA', N'dbo', 'TABLE', N'Holiday', 'COLUMN', N'DayDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Holiday.', 'SCHEMA', N'dbo', 'TABLE', N'Holiday', 'COLUMN', N'HolidayKey'
GO
