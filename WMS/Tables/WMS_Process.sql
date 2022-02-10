CREATE TABLE [dbo].[WMS_Process]
(
[CurrentTime] [datetime] NULL,
[spid] [smallint] NOT NULL,
[kpid] [smallint] NOT NULL,
[blocked] [smallint] NOT NULL,
[waittype] [binary] (2) NOT NULL,
[waittime] [int] NOT NULL,
[lastwaittype] [nchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[waitresource] [nchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dbid] [smallint] NOT NULL,
[uid] [smallint] NOT NULL,
[cpu] [int] NOT NULL,
[physical_io] [bigint] NOT NULL,
[memusage] [int] NOT NULL,
[login_time] [datetime] NOT NULL,
[last_batch] [datetime] NOT NULL,
[ecid] [smallint] NOT NULL,
[open_tran] [smallint] NOT NULL,
[status] [nchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sid] [binary] (86) NOT NULL,
[hostname] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[program_name] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hostprocess] [nchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd] [nchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nt_domain] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nt_username] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[net_address] [nchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[net_library] [nchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[loginame] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[context_info] [binary] (128) NOT NULL,
[sql_handle] [binary] (20) NOT NULL,
[stmt_start] [int] NOT NULL,
[stmt_end] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [clus_time_spid] ON [dbo].[WMS_Process] ([CurrentTime], [spid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMS_Process] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMS_Process] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMS_Process] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMS_Process] TO [NSQL]
GO
