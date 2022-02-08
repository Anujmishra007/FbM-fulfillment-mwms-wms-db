CREATE TABLE [dbo].[CartonList]
(
[CartonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrWeight] [float] NULL,
[CurrCube] [float] NULL,
[CurrCount] [float] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seqno] [int] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonList_AddWho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_CartonList_Adddate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CartonList] ADD CONSTRAINT [PK_CartonList] PRIMARY KEY CLUSTERED ([CartonKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CartonList] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CartonList] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CartonList] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CartonList] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CartonList] TO [NSQL]
GO
