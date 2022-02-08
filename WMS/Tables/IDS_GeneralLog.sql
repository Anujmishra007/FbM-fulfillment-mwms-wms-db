CREATE TABLE [dbo].[IDS_GeneralLog]
(
[LogKey] [int] NOT NULL IDENTITY(1, 1),
[UDF01] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF02] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF03] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF04] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF05] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF06] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF07] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF08] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF09] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF10] [datetime] NULL,
[LogDate] [datetime] NULL CONSTRAINT [DF_IDS_GeneralLog_LogDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IDS_GeneralLog] ADD CONSTRAINT [PK_IDS_GeneralLog] PRIMARY KEY CLUSTERED ([LogKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IDS_GeneralLog] ON [dbo].[IDS_GeneralLog] ([UDF01], [UDF02], [UDF03], [UDF04]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDS_GeneralLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_GeneralLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_GeneralLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_GeneralLog] TO [NSQL]
GO
