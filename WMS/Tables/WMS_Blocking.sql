
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WMS_Blocking]') AND type in (N'U'))
BEGIN
	
	CREATE TABLE [dbo].[WMS_Blocking]
(
[EventType] [nvarchar] (30) NOT NULL,
[parameters] [int] NOT NULL,
[Eventinfo] [nvarchar] (4000) NULL,
[CurrentTime] [datetime] NULL,
[spid] [int] NULL,
[blocking_ID] [int] NULL,
[hostname] [nvarchar] (128) NULL,
[program_name] [nvarchar] (128) NULL,
[sql_handle_text] nvarchar(4000) NULL,
) ON [PRIMARY]

CREATE CLUSTERED INDEX [ind] ON [dbo].[WMS_Blocking] ([CurrentTime], [spid]) WITH (FILLFACTOR=90) ON [PRIMARY]

END
ELSE
BEGIN
	
    IF NOT EXISTS (SELECT * FROM sys.columns
                   WHERE Name = 'sql_handle_text' AND Object_ID = Object_ID('[dbo].[WMS_Blocking]'))
        BEGIN		
						
					alter table WMS_Blocking
					add sql_handle_text nvarchar(4000)
				END

END
GO

GRANT DELETE ON  [dbo].[WMS_Blocking] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMS_Blocking] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMS_Blocking] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMS_Blocking] TO [NSQL]
GO
