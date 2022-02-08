CREATE TABLE [dbo].[WorkStationLoc]
(
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Location] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMMVWS] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMMVFG] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMMVOPC] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStationLoc_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_WorkStationLoc_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStationLoc_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkStationLoc_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkStationLoc] ADD CONSTRAINT [PK_WorkStationLoc] PRIMARY KEY CLUSTERED ([WorkStation], [LocType], [Location]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkStationLoc] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkStationLoc] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkStationLoc] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkStationLoc] TO [NSQL]
GO
