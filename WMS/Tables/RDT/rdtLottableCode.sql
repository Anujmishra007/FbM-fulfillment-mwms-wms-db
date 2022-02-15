CREATE TABLE [RDT].[rdtLottableCode]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[LottableCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Function_ID] [int] NOT NULL,
[LottableNo] [int] NOT NULL,
[Visible] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Editable] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Required] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence] [int] NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtLottableCode_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtLottableCode_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtLottableCode_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtLottableCode_EditDate] DEFAULT (getdate()),
[FormatSP] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtLottableCode_FormatSP] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtLottableCode_Description] DEFAULT (''),
[ProcessSP] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtLottableCode_ProcessSP] DEFAULT (''),
[ProcessType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtLottableCode_ProcessType] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtLottableCode] ADD CONSTRAINT [CK_rdtLottableCode_Editable] CHECK (([Editable]='0' OR [Editable]='1'))
GO
ALTER TABLE [RDT].[rdtLottableCode] ADD CONSTRAINT [CK_rdtLottableCode_LottableNo] CHECK (([LottableNo]>=(1) AND [LottableNo]<=(15)))
GO
ALTER TABLE [RDT].[rdtLottableCode] ADD CONSTRAINT [CK_rdtLottableCode_Process] CHECK (([ProcessType]='' AND [ProcessSP]='' OR [ProcessType]<>'' AND [ProcessSP]<>''))
GO
ALTER TABLE [RDT].[rdtLottableCode] ADD CONSTRAINT [CK_rdtLottableCode_ProcessType] CHECK (([ProcessType]='BOTH' OR [ProcessType]='POST' OR [ProcessType]='PRE' OR [ProcessType]=''))
GO
ALTER TABLE [RDT].[rdtLottableCode] ADD CONSTRAINT [CK_rdtLottableCode_Required] CHECK (([Required]='0' OR [Required]='1'))
GO
ALTER TABLE [RDT].[rdtLottableCode] ADD CONSTRAINT [CK_rdtLottableCode_Sequence] CHECK (([Sequence]>=(1) AND [Sequence]<=(15)))
GO
ALTER TABLE [RDT].[rdtLottableCode] ADD CONSTRAINT [CK_rdtLottableCode_Visible] CHECK (([Visible]='0' OR [Visible]='1'))
GO
ALTER TABLE [RDT].[rdtLottableCode] ADD CONSTRAINT [PK_rdtLottableCode] PRIMARY KEY CLUSTERED ([LottableCode], [Function_ID], [StorerKey], [LottableNo], [Sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtLottableCode] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtLottableCode] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtLottableCode] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtLottableCode] TO [NSQL]
GO
