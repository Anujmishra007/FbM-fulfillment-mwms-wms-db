CREATE TABLE [dbo].[TM_PickLog]
(
[SeqNo] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Mobile] DEFAULT (''),
[Func] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Func] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_StorerKey] DEFAULT (''),
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_UserName] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Facility] DEFAULT (''),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_TaskDetailKey] DEFAULT (''),
[PickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_PickDetailKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_LoadKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_SKU] DEFAULT (''),
[AltSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_AltSKU] DEFAULT (''),
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_LOC] DEFAULT (''),
[ToLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_ToLOC] DEFAULT (''),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_ID] DEFAULT (''),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_DropID] DEFAULT (''),
[PickQty] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_PickQty] DEFAULT (''),
[PDQty] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_PDQty] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Status] DEFAULT (''),
[Areakey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Areakey] DEFAULT (''),
[Col1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col1] DEFAULT (''),
[Col2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col2] DEFAULT (''),
[Col3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col3] DEFAULT (''),
[Col4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col4] DEFAULT (''),
[Col5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col5] DEFAULT (''),
[Col6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col6] DEFAULT (''),
[Col7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col7] DEFAULT (''),
[Col8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col8] DEFAULT (''),
[Col9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col9] DEFAULT (''),
[Col10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TM_PickLog_Col10] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_TM_PickLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TM_PickLog] ADD CONSTRAINT [PK_TM_PickLog] PRIMARY KEY CLUSTERED ([SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TM_PickLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TM_PickLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TM_PickLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TM_PickLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TM_PickLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'TM_PickLog', 'COLUMN', N'StorerKey'
GO
