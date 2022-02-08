CREATE TABLE [dbo].[WMS_sysProcess]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[currenttime] [datetime] NOT NULL,
[spid] [smallint] NOT NULL,
[Blocked] [smallint] NOT NULL,
[hostname] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[program_name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[net_address] [nvarchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[loginame] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[login_time] [datetime] NOT NULL,
[last_batch] [datetime] NOT NULL,
[Duration] [int] NOT NULL,
[Eventinfo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DB_Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WMS_sysProcess_DB_Name] DEFAULT (''),
[lastwaittype] [nchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WMS_sysProcess] ADD CONSTRAINT [PK__WMS_sysProcess__58F1F705] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WMS_sysProcessTime] ON [dbo].[WMS_sysProcess] ([currenttime], [last_batch]) INCLUDE ([program_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WMS_SysProcess_Currenttime_SPID] ON [dbo].[WMS_sysProcess] ([currenttime], [spid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMS_sysProcess] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMS_sysProcess] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMS_sysProcess] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMS_sysProcess] TO [NSQL]
GO
