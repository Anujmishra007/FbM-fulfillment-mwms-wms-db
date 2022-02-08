CREATE TABLE [dbo].[WorkOrderJobMove_DelLog]
(
[WOMoveKey] [bigint] NOT NULL,
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JobLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[PickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobReservekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginalLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobMove_DelLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_WorkOrderJobMove_DelLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderJobMove_DelLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderJobMove_DelLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderJobMove_DelLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderJobMove_DelLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Deleted Workorderjobmove reference table', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s FromLoc', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s ID', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s Job #', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'JobKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s Job line #', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'JobLine'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s JobReserveKey', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'JobReservekey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s PickMethod', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s Qty', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s ToLoc', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkOrderJobMove''s WOMovekey', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobMove_DelLog', 'COLUMN', N'WOMoveKey'
GO
