CREATE TABLE [dbo].[NonInv]
(
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NonInvSku] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonInv_InvType] DEFAULT (' '),
[MaintainBalances] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonInv_MaintainBalances] DEFAULT (' '),
[LastLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonInv_LastLoc] DEFAULT (' '),
[CurrentBalance] [int] NULL CONSTRAINT [DF_NonInv_CurrentBalance] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonInv_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_NonInv_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonInv_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_NonInv_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[NonInv] ADD CONSTRAINT [PK_NonInv] PRIMARY KEY CLUSTERED ([Facility], [Storerkey], [NonInvSku]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[NonInv] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[NonInv] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[NonInv] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[NonInv] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[NonInv] TO [NSQL]
GO
