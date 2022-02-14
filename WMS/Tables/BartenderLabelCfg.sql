CREATE TABLE [dbo].[BartenderLabelCfg]
(
[LabelSerialNo] [int] NOT NULL IDENTITY(1, 1),
[LabelType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Key01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_Key01] DEFAULT (''),
[Key02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_Key02] DEFAULT (''),
[Key03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_Key03] DEFAULT (''),
[Key04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_Key04] DEFAULT (''),
[Key05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_Key05] DEFAULT (''),
[TemplatePath] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_TemplatePath] DEFAULT (''),
[StoreProcedure] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_StoreProcedure] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BartenderLabelCfg_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_AddWho] DEFAULT (suser_sname()),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_Storerkey] DEFAULT (''),
[FilePath] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_FilePath] DEFAULT (''),
[LOGFILE] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_LOGFILE] DEFAULT ('N'),
[Field01] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field02] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field03] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BTPrinterID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BartenderLabelCfg_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderLabelCfg_EditWho] DEFAULT (suser_sname()),
[ZPLPrinting] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BartenderLabelCfg_ZPLPrinting] DEFAULT ('0')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BartenderLabelCfg] ADD CONSTRAINT [PK_BartenderLabelCfg] PRIMARY KEY CLUSTERED ([LabelSerialNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BartenderLabelCfg] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BartenderLabelCfg] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BartenderLabelCfg] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BartenderLabelCfg] TO [NSQL]
GO
