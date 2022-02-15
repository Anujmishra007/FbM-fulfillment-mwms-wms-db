CREATE TABLE [RDT].[RDTDynamicPickLog_DELLOG]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonNo] [int] NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DelDate] [datetime] NULL CONSTRAINT [DF_RDTDynamicPickLog_DELLOG_DelDate] DEFAULT (getdate()),
[DelWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDynamicPickLog_DELLOG_DelWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTDynamicPickLog_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTDynamicPickLog_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTDynamicPickLog_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTDynamicPickLog_DELLOG] TO [NSQL]
GO
