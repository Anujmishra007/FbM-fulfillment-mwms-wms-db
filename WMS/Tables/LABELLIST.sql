CREATE TABLE [dbo].[LABELLIST]
(
[LabelName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_LabelName] DEFAULT (' '),
[LabelDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_LabelDesc] DEFAULT (' '),
[LabelType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_LabelType] DEFAULT (' '),
[DefaultPrinter] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_DefaultPrinter] DEFAULT (' '),
[PrinterType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_PrinterType] DEFAULT (' '),
[DWName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_DWName] DEFAULT (' '),
[PredownloadFile] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_PredownloadFile] DEFAULT (' '),
[DownloadFile] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_DownloadFile] DEFAULT (' '),
[UseTimer] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LABELLIST_UseTimer] DEFAULT (' '),
[TimerInterval] [int] NULL CONSTRAINT [DF_LABELLIST_TimerInterval] DEFAULT ((0)),
[Resolution] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_Resolution] DEFAULT (' '),
[LayOut] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_layout] DEFAULT (' '),
[PrintPos] [int] NOT NULL CONSTRAINT [DF_LABELLIST_printpos] DEFAULT ((1)),
[Port] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_port] DEFAULT ('L1'),
[ClearPrintBuffer] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_ClearPrintBuffer] DEFAULT ('Y'),
[LLMSUB] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LABELLIST_llmsub] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LABELLIST] ADD CONSTRAINT [PKLABELLIST] PRIMARY KEY CLUSTERED ([LabelName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LABELLIST] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LABELLIST] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LABELLIST] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LABELLIST] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Label.', 'SCHEMA', N'dbo', 'TABLE', N'LABELLIST', 'COLUMN', N'LabelDesc'
GO
