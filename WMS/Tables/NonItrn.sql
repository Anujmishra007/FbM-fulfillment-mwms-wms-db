CREATE TABLE [dbo].[NonItrn]
(
[NonItrnKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NonInvSku] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonItrn_TranType] DEFAULT (' '),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonItrn_ToLoc] DEFAULT (' '),
[Qty] [int] NULL CONSTRAINT [DF_NonItrn_Qty] DEFAULT ((0)),
[ReferenceNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonItrn_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_NonItrn_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonItrn_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_NonItrn_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[NonItrn] ADD CONSTRAINT [PK_NonItrn] PRIMARY KEY CLUSTERED ([NonItrnKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[NonItrn] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[NonItrn] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[NonItrn] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[NonItrn] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[NonItrn] TO [NSQL]
GO
