CREATE TABLE [dbo].[RouteMaster_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RouteMaster_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RouteMaster_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RouteMaster_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RouteMaster_DELLOG] ADD CONSTRAINT [PK__RouteMaster_DELL__26B08FFB] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RouteMaster_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RouteMaster_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RouteMaster_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RouteMaster_DELLOG] TO [NSQL]
GO
