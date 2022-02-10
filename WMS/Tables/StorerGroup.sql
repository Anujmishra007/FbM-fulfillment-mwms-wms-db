CREATE TABLE [dbo].[StorerGroup]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerGroup_StorerGroup] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerGroup_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_StorerGroup_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerGroup_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_StorerGroup_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StorerGroup] ADD CONSTRAINT [PK_StorerGroup] PRIMARY KEY CLUSTERED ([StorerGroup], [StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[StorerGroup] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StorerGroup] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StorerGroup] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StorerGroup] TO [NSQL]
GO
