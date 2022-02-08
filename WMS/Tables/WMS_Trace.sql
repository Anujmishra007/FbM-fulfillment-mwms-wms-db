CREATE TABLE [dbo].[WMS_Trace]
(
[EventType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parameters] [int] NOT NULL,
[Eventinfo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentTime] [datetime] NULL,
[spid] [int] NULL,
[RowNo] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WMS_Trace] ADD CONSTRAINT [PK_WMS_Trace] PRIMARY KEY NONCLUSTERED ([RowNo]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ind] ON [dbo].[WMS_Trace] ([CurrentTime], [spid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_wms_trace_spid] ON [dbo].[WMS_Trace] ([spid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMS_Trace] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMS_Trace] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMS_Trace] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMS_Trace] TO [NSQL]
GO
