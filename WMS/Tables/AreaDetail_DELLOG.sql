CREATE TABLE [dbo].[AreaDetail_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AreaDetail_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AreaDetail_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AreaDetail_DELLOG] ADD CONSTRAINT [PK__AreaDeta__78C9779760F5381E] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AreaDetail_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AreaDetail_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AreaDetail_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AreaDetail_DELLOG] TO [NSQL]
GO
