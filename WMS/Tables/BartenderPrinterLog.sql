CREATE TABLE [dbo].[BartenderPrinterLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NULL,
[Field01] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderPrinterLog_Field01] DEFAULT (''),
[Field02] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderPrinterLog_Field02] DEFAULT (''),
[Field03] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderPrinterLog_Field03] DEFAULT (''),
[LogDate] [datetime] NULL CONSTRAINT [DF_BartenderPrinterLog_LogDate] DEFAULT (getdate()),
[AddDate] [datetime] NULL CONSTRAINT [DF_BartenderPrinterLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BartenderPrinterLog] ADD CONSTRAINT [PK_BartenderPrinterLog] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BartenderPrinterLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BartenderPrinterLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BartenderPrinterLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BartenderPrinterLog] TO [NSQL]
GO
