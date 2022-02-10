CREATE TABLE [dbo].[TableDeleteLog]
(
[Seq_No] [int] NOT NULL IDENTITY(1, 1),
[DeleteDate] [datetime] NOT NULL CONSTRAINT [DF_TableDeleteLog_DeleteDate] DEFAULT (getdate()),
[DeleteBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TableDeleteLog_DeleteBy] DEFAULT (suser_sname()),
[TableName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Col1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TableDeleteLog_Col1] DEFAULT (''),
[Col2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TableDeleteLog_Col2] DEFAULT (''),
[Col3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TableDeleteLog_Col3] DEFAULT (''),
[Col4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TableDeleteLog_Col4] DEFAULT (''),
[Col5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TableDeleteLog_Col5] DEFAULT (''),
[Remarks] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TableDeleteLog_Remarks] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TableDeleteLog] ADD CONSTRAINT [PK_TableDeleteLog] PRIMARY KEY CLUSTERED ([Seq_No]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TableDeleteLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TableDeleteLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TableDeleteLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TableDeleteLog] TO [NSQL]
GO
