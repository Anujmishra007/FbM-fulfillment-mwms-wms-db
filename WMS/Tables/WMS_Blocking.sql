CREATE TABLE [dbo].[WMS_Blocking]
(
[EventType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parameters] [int] NOT NULL,
[Eventinfo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentTime] [datetime] NULL,
[spid] [int] NULL,
[blocking_ID] [int] NULL,
[hostname] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[program_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ind] ON [dbo].[WMS_Blocking] ([CurrentTime], [spid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMS_Blocking] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMS_Blocking] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMS_Blocking] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMS_Blocking] TO [NSQL]
GO
