CREATE TABLE [dbo].[TriganticCC]
(
[CCKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty_Before] [int] NULL CONSTRAINT [DF_TriganticCC_Qty_Before] DEFAULT ((0)),
[Qty_After] [int] NULL CONSTRAINT [DF_TriganticCC_Qty_After] DEFAULT ((0)),
[Adddate] [datetime] NULL,
[AdjCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdjCodeDesc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdjType] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TriganticCC] ADD CONSTRAINT [PK_TriganticCC] PRIMARY KEY CLUSTERED ([CCKey], [Facility], [StorerKey], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TriganticCC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TriganticCC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TriganticCC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TriganticCC] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TriganticCC', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Cycle Count.', 'SCHEMA', N'dbo', 'TABLE', N'TriganticCC', 'COLUMN', N'CCKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'TriganticCC', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity after cycle count.', 'SCHEMA', N'dbo', 'TABLE', N'TriganticCC', 'COLUMN', N'Qty_After'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity before cycle count.', 'SCHEMA', N'dbo', 'TABLE', N'TriganticCC', 'COLUMN', N'Qty_Before'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'TriganticCC', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'TriganticCC', 'COLUMN', N'StorerKey'
GO
