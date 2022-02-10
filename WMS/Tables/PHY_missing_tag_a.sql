CREATE TABLE [dbo].[PHY_missing_tag_a]
(
[InventoryTag] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PHY_missing_tag_a_InventoryTag] DEFAULT (' ')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PHY_missing_tag_a] ADD CONSTRAINT [PKPHY_missing_tag_a] PRIMARY KEY NONCLUSTERED ([InventoryTag]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PHY_missing_tag_a] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PHY_missing_tag_a] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PHY_missing_tag_a] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PHY_missing_tag_a] TO [NSQL]
GO
