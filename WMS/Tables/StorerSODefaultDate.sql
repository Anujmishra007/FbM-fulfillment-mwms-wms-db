CREATE TABLE [dbo].[StorerSODefaultDate]
(
[rowref] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompareDate] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerSODefaultDate_CompareDate] DEFAULT ('AddDate'),
[Operator] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CutOffTime] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerSODefaultDate_CutOffTime] DEFAULT ('00:00'),
[MinQty] [int] NOT NULL CONSTRAINT [DF_StorerSODefaultDate_MinQty] DEFAULT ((0)),
[MaxQty] [int] NOT NULL CONSTRAINT [DF_StorerSODefaultDate_MaxQty] DEFAULT ((0)),
[ProcessTime] [int] NOT NULL,
[ProcessType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerSODefaultDate_ProcessType] DEFAULT ('D'),
[Priority] [int] NOT NULL CONSTRAINT [DF_StorerSODefaultDate_Priority] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StorerSODefaultDate] ADD CONSTRAINT [PK_StorerDespatchDate_1] PRIMARY KEY CLUSTERED ([rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[StorerSODefaultDate] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StorerSODefaultDate] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StorerSODefaultDate] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StorerSODefaultDate] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'StorerSODefaultDate', 'COLUMN', N'StorerKey'
GO
