CREATE TABLE [dbo].[DocStatusTrack]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DocStatusTrack_TableName] DEFAULT (''),
[DocumentNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DocStatusTrack_DocumentNo] DEFAULT (''),
[Key1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DocStatusTrack_Key1] DEFAULT (''),
[Key2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DocStatusTrack_key2] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DocStatusTrack_Storerkey] DEFAULT (''),
[DocStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DocStatusTrack_DocStatus] DEFAULT ((0)),
[TransDate] [datetime] NULL CONSTRAINT [DF_DocStatusTrack_TransDate] DEFAULT (getdate()),
[Userdefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine06] [datetime] NULL,
[Userdefine07] [datetime] NULL,
[Userdefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Finalized] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DocStatusTrack_Finalized] DEFAULT ('N'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DocStatusTrack_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_DocStatusTrack_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DocStatusTrack_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_DocStatusTrack_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashValue] [tinyint] NOT NULL CONSTRAINT [DF_DocStatusTrack_HashValue] DEFAULT (abs(checksum(newid())%(256))),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DocStatusTrack_Facility] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DocStatusTrack] ADD CONSTRAINT [PK_DocStatusTrack] PRIMARY KEY NONCLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_DocStatusTrack_HASHVALUE] ON [dbo].[DocStatusTrack] ([HashValue], [RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocStatusTrack] ON [dbo].[DocStatusTrack] ([TableName], [DocumentNo], [Key1], [Key2]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DocStatusTrack] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DocStatusTrack] TO [NSQL]
GO
GRANT REFERENCES ON  [dbo].[DocStatusTrack] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DocStatusTrack] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DocStatusTrack] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Facility', 'SCHEMA', N'dbo', 'TABLE', N'DocStatusTrack', 'COLUMN', N'Facility'
GO
