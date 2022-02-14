CREATE TABLE [dbo].[Exe2OW_AllocPickShip]
(
[seq_no] [int] NOT NULL IDENTITY(1, 1),
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BatchNo] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Actioncode] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_Exe2OW_AllocPickShip_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_Exe2OW_AllocPickShip_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Exe2OW_AllocPickShip] ADD CONSTRAINT [PK_Exe2OW_AllocPickShip] PRIMARY KEY CLUSTERED ([seq_no]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Exe2OW_AllocPickShip] ON [dbo].[Exe2OW_AllocPickShip] ([ExternOrderkey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Exe2OW_AllocPickShip] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Exe2OW_AllocPickShip] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Exe2OW_AllocPickShip] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Exe2OW_AllocPickShip] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Action.', 'SCHEMA', N'dbo', 'TABLE', N'Exe2OW_AllocPickShip', 'COLUMN', N'Actioncode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Exe2OW_AllocPickShip', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Exe2OW_AllocPickShip', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'Exe2OW_AllocPickShip', 'COLUMN', N'ExternOrderkey'
GO
