
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WMS_Trace]') AND type in (N'U'))
BEGIN
	
CREATE TABLE [dbo].[WMS_Trace]
(
[EventType] [nvarchar] (30) NOT NULL,
[parameters] [int] NOT NULL,
[Eventinfo] [nvarchar] (4000) NULL,
[CurrentTime] [datetime] NULL,
[spid] [int] NULL,
[RowNo] [bigint] NOT NULL IDENTITY(1, 1),
[sql_handle_text] nvarchar(4000) NULL,
) ON [PRIMARY]

ALTER TABLE [dbo].[WMS_Trace] ADD CONSTRAINT [PK_WMS_Trace] PRIMARY KEY NONCLUSTERED ([RowNo]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]

CREATE CLUSTERED INDEX [ind] ON [dbo].[WMS_Trace] ([CurrentTime], [spid]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_wms_trace_spid] ON [dbo].[WMS_Trace] ([spid]) ON [PRIMARY]
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns
                   WHERE Name = 'sql_handle_text' AND Object_ID = Object_ID('[dbo].[WMS_Trace]'))
        BEGIN	
					alter table dbo.WMS_trace
				  add sql_handle_text nvarchar(4000) NULL
				END
 
	
END
GO

GRANT DELETE ON  [dbo].[WMS_Trace] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMS_Trace] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMS_Trace] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMS_Trace] TO [NSQL]
GO
