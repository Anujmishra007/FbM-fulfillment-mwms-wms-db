CREATE TABLE [RDT].[RDTSchedule]
(
[ScheduleID] [int] NOT NULL IDENTITY(1, 1),
[Type] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TimeInterval] [int] NOT NULL CONSTRAINT [DF_RDTSchedule_TimeInterval] DEFAULT ((0)),
[IntervalType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTSchedule_IntervalType] DEFAULT ('S'),
[CheckWeekDay] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_CheckWeekDay] DEFAULT ('N'),
[Mon] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_Mon] DEFAULT ('N'),
[Teu] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_Teu] DEFAULT ('N'),
[Wed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_Wed] DEFAULT ('N'),
[Thu] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_Thu] DEFAULT ('N'),
[Fri] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_Fri] DEFAULT ('N'),
[Sat] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_Sat] DEFAULT ('N'),
[Sun] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_Sun] DEFAULT ('N'),
[CheckTimeRestric] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_CheckTimeRestric] DEFAULT ('N'),
[StartingFrom] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EndingAt] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckDateRestric] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_CheckDateRestric] DEFAULT ('N'),
[EffectiveFrom] [datetime] NULL,
[EffectiveTill] [datetime] NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_RDTSchedule_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSchedule_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTSchedule] ADD CONSTRAINT [PK_RDTSchedule] PRIMARY KEY CLUSTERED ([ScheduleID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTSchedule] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTSchedule] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTSchedule] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTSchedule] TO [NSQL]
GO
