CREATE TABLE [dbo].[DropidDetail_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[Dropid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChildId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DropidDetail_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_DropidDetail_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DropidDetail_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropidDetail_DELLOG] ADD CONSTRAINT [PK__DropidDetail_DEL__7E987D00] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DropidDetail_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DropidDetail_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DropidDetail_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DropidDetail_DELLOG] TO [NSQL]
GO
