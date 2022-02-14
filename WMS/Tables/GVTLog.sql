CREATE TABLE [dbo].[GVTLog]
(
[GVTLogKey] [int] NOT NULL IDENTITY(1, 1),
[Tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GVTLog_Tablename] DEFAULT (' '),
[Key1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GVTLog_Key1] DEFAULT (' '),
[Key2] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GVTLog_Key2] DEFAULT (' '),
[Key3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GVTLog_Key3] DEFAULT (' '),
[TransmitFlag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GVTLog_TransmitFlag] DEFAULT ('0'),
[TransmitBatch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GVTLog_TransmitBatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GVTLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GVTLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_GVTLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GVTLog_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO


ALTER TABLE [dbo].[GVTLog] ADD CONSTRAINT [PKGVTLog] PRIMARY KEY CLUSTERED ([GVTLogKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_GVTLog_CIdx] ON [dbo].[GVTLog] ([Tablename], [Key1], [Key2], [Key3]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GVTLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GVTLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GVTLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GVTLog] TO [NSQL]
GO
