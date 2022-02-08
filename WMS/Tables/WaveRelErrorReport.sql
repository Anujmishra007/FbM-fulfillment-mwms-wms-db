CREATE TABLE [dbo].[WaveRelErrorReport]
(
[SeqNo] [bigint] NOT NULL IDENTITY(1, 1),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LineText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WaveRelErrorReport_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WaveRelErrorReport_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WaveRelErrorReport] ADD CONSTRAINT [PK_WaveRelErrorReport] PRIMARY KEY CLUSTERED ([SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WaveRelErrorReport] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WaveRelErrorReport] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WaveRelErrorReport] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WaveRelErrorReport] TO [NSQL]
GO
