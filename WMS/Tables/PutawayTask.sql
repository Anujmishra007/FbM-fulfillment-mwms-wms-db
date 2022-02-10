CREATE TABLE [dbo].[PutawayTask]
(
[Transkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayTask_Status] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_PutawayTask_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayTask_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_PutawayTask_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayTask_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PutawayTask] ADD CONSTRAINT [PK_PutawayTask] PRIMARY KEY CLUSTERED ([Transkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PutawayTask] ON [dbo].[PutawayTask] ([ID], [FromLoc], [ToLoc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PutawayTask_1] ON [dbo].[PutawayTask] ([ID], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PutawayTask] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PutawayTask] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PutawayTask] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PutawayTask] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unqiue code identifying task detail.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'TaskDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying transfer.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayTask', 'COLUMN', N'Transkey'
GO
