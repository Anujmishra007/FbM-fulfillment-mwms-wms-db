CREATE TABLE [RDT].[rdtBOMCreationLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentSKU] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComponentSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Style] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_rdtBOMCreationLog_Qty] DEFAULT ((0)),
[SequenceNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileNo] [int] NOT NULL CONSTRAINT [DF_rdtBOMCreationLog_MobileNo] DEFAULT ((0)),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtBOMCreationLog_Status] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtBOMCreationLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtBOMCreationLog] ADD CONSTRAINT [PKrdtBOMCreationLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtBOMCreationLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtBOMCreationLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtBOMCreationLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtBOMCreationLog] TO [NSQL]
GO
