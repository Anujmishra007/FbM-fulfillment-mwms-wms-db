CREATE TABLE [dbo].[DBStatusTrack]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[ObjName] [sys].[sysname] NOT NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TSQL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DBStatusTrack_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_DBStatusTrack_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DBStatusTrack] ADD CONSTRAINT [PK_DBStatusTrack] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DBStatusTrack] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DBStatusTrack] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DBStatusTrack] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DBStatusTrack] TO [NSQL]
GO
