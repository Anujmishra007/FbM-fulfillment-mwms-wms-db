CREATE TABLE [dbo].[LEAF_Chart_DET]
(
[RowRefNo] [bigint] NOT NULL IDENTITY(1, 1),
[ChartName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LEAF_Chart_DET_ChartName] DEFAULT (''),
[Param] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LEAF_Chart_DET_Param] DEFAULT (''),
[DataType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LEAF_Chart_DET_DataType] DEFAULT (''),
[Label] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LEAF_Chart_DET_Label] DEFAULT (''),
[OperationType] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LEAF_Chart_DET_OperationType] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LEAF_Chart_DET_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LEAF_Chart_DET_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LEAF_Chart_DET_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LEAF_Chart_DET_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEAF_Chart_DET] ADD CONSTRAINT [PK_LEAF_Chart_DET] PRIMARY KEY CLUSTERED ([RowRefNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEAF_Chart_DET] ADD CONSTRAINT [FK_LEAF_Chart_DET] FOREIGN KEY ([ChartName]) REFERENCES [dbo].[LEAF_Chart_HDR] ([ChartName])
GO
GRANT DELETE ON  [dbo].[LEAF_Chart_DET] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LEAF_Chart_DET] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LEAF_Chart_DET] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LEAF_Chart_DET] TO [NSQL]
GO
