CREATE TABLE [dbo].[Locbak]
(
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocationType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InventoryDate] [datetime] NOT NULL,
[Adddate] [datetime] NULL CONSTRAINT [DF_Locbak_Adddate] DEFAULT (getdate()),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Locbak_AddWho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_Locbak_Editdate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Locbak_Editwho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Locbak] ADD CONSTRAINT [PK_locbak] PRIMARY KEY CLUSTERED ([InventoryDate], [Loc]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Locbak] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Locbak] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Locbak] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Locbak] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Locbak', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Locbak', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Locbak', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Locbak', 'COLUMN', N'Editwho'
GO
