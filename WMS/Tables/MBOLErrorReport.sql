CREATE TABLE [dbo].[MBOLErrorReport]
(
[SeqNo] [bigint] NOT NULL IDENTITY(1, 1),
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LineText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_MBOLErrorReport_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLErrorReport_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MBOLErrorReport] ADD CONSTRAINT [PK_MBOLErrorReport] PRIMARY KEY CLUSTERED ([SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MBOLErrorReport] ON [dbo].[MBOLErrorReport] ([MBOLKey], [ErrorNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MBOLErrorReport] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MBOLErrorReport] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MBOLErrorReport] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MBOLErrorReport] TO [NSQL]
GO
