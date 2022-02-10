CREATE TABLE [dbo].[DocInfo]
(
[RecordID] [bigint] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Key1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Key2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DocInfo_StorerKey] DEFAULT (''),
[LineSeq] [int] NOT NULL,
[Data] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DocInfo_Data] DEFAULT (''),
[DataType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DocInfo_DataType] DEFAULT (''),
[StoredProc] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DocInfo_StoredProc] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_DocInfo_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DocInfo_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocInfo] ADD CONSTRAINT [PK_DocInfo] PRIMARY KEY CLUSTERED ([RecordID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocInfo_Key1] ON [dbo].[DocInfo] ([Key1], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocInfo_Key3] ON [dbo].[DocInfo] ([Key3], [Key1]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DocInfo_01] ON [dbo].[DocInfo] ([TableName], [StorerKey], [Key1], [Key2], [Key3]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[DocInfo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[DocInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DocInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DocInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DocInfo] TO [NSQL]
GO
