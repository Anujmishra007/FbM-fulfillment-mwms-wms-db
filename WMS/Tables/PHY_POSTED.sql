CREATE TABLE [dbo].[PHY_POSTED]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_POSTED_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_POSTED_Sku] DEFAULT (' '),
[QtyTeamA] [int] NOT NULL CONSTRAINT [DF_PHY_POSTED_QtyTeamA] DEFAULT ((0)),
[QtyLOTxLOCxID] [int] NOT NULL CONSTRAINT [DF_PHY_POSTED_QtyLOTxLOCxID] DEFAULT ((0)),
[ErrorMessage] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PHY_POSTED] ADD CONSTRAINT [PKPHY_POSTED] PRIMARY KEY NONCLUSTERED ([StorerKey], [Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PHY_POSTED] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PHY_POSTED] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PHY_POSTED] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PHY_POSTED] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the products.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_POSTED', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PHY_POSTED', 'COLUMN', N'StorerKey'
GO
