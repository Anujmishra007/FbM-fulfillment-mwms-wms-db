CREATE TABLE [dbo].[RFPUTAWAY_DELLOG]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SuggestedLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptcid] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qty] [int] NOT NULL,
[AddDate] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RowRef] [int] NOT NULL,
[DelDate] [datetime] NULL CONSTRAINT [DF_RFPutaway_DELLOG_DelDate] DEFAULT (getdate()),
[DelWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFPutaway_DELLOG_DelWho] DEFAULT (suser_sname()),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Func] [int] NOT NULL,
[PABookingKey] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RFPUTAWAY_DELLOG] ADD CONSTRAINT [PK__RFPUTAWA__50738165DF7FC121] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RFPUTAWAY_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RFPUTAWAY_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RFPUTAWAY_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RFPUTAWAY_DELLOG] TO [NSQL]
GO
