CREATE TABLE [dbo].[TempMoveSku]
(
[MoveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL,
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempMoveSku_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TempMoveSku] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TempMoveSku] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TempMoveSku] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TempMoveSku] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ID or Tag number assigned to the Commodity to be moved. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'FromID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination. ', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Move.', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'MoveKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'New ID or Tag number to be assigned to the Commodity at the location. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'ToID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'TempMoveSku', 'COLUMN', N'ToLoc'
GO
