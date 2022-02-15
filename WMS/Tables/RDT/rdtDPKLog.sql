CREATE TABLE [RDT].[rdtDPKLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[DropID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyMove] [int] NOT NULL,
[PAQty] [int] NOT NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BOMSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Taskdetailkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserKey] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtDPKLog_UserKey] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtDPKLog] ADD CONSTRAINT [PK_rdtDPKLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtDPKLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtDPKLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtDPKLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtDPKLog] TO [NSQL]
GO
