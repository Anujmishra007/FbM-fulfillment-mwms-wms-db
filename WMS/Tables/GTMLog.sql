IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GTMLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GTMLog]
(
[Logids] [bigint] NOT NULL IDENTITY(1, 1),
[PalletId] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDetailKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MsgType] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromLoc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToLoc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogDate] [datetime] NULL,
[EditBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrMsg] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrCode] [int] NULL,
[Facility] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL constraint [DF_GTMLog_Facility] default ('')
) ON [PRIMARY]

ALTER TABLE [dbo].[GTMLog] ADD CONSTRAINT [PK_GTM_CallLog] PRIMARY KEY CLUSTERED ([Logids]) WITH (FILLFACTOR=80) ON [PRIMARY]

GRANT DELETE ON  [dbo].[GTMLog] TO [NSQL]

GRANT INSERT ON  [dbo].[GTMLog] TO [NSQL]

GRANT SELECT ON  [dbo].[GTMLog] TO [NSQL]

GRANT UPDATE ON  [dbo].[GTMLog] TO [NSQL]


END

ELSE
BEGIN
	

   IF NOT EXISTS (SELECT *
                   FROM sys.columns
                   WHERE Name = 'Facility'
                     AND Object_ID = Object_ID('GTMLog'))
        BEGIN
            Alter table dbo.GTMLog 
			Add Facility nvarchar(50) NOT NULL constraint [DF_GTMLog_Facility] default ('');

            EXEC sp_addextendedproperty N'MS_Description', 'Warehouse Facility code', 'SCHEMA', N'dbo', 'TABLE', N'GTMLog', 'COLUMN', N'Facility'
        END

   		
	
END