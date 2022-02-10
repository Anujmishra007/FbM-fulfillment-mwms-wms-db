CREATE TABLE [dbo].[CourierSortingCode]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[ShipperKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CourierSortingCode_ShipperKey] DEFAULT (''),
[State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CourierSortingCode_State] DEFAULT (''),
[City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CourierSortingCode_City] DEFAULT (''),
[Province] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CourierSortingCode_Province] DEFAULT (''),
[Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CourierSortingCode_Zip] DEFAULT (''),
[SortingCode1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CourierSortingCode_SortingCode1] DEFAULT (''),
[SortingCode2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CourierSortingCode_SortingCode2] DEFAULT (''),
[SortingCode3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CourierSortingCode_SortingCode3] DEFAULT (''),
[EffectiveDate] [datetime] NULL,
[Comment] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CourierSortingCode_Comment] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CourierSortingCode_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CourierSortingCode_AddWho] DEFAULT (suser_name()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CourierSortingCode_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CourierSortingCode_EditWho] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CourierSortingCode] ADD CONSTRAINT [PK_CourierSortingCode] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CourierSortingCode_DF01] ON [dbo].[CourierSortingCode] ([ShipperKey], [Zip]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CourierSortingCode] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CourierSortingCode] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CourierSortingCode] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CourierSortingCode] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'It contents each courier own sorting code by representing state, city, province or zip.', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Create date', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Created by person', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of address', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Remarks', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'Comment'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edit date', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edit by person', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Effective date of defined sorting code', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Province of address', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'Province'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique sequence id', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Defined WMS courier code', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'ShipperKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'First defined sorting code', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'SortingCode1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Second defined sorting code', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'SortingCode2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Third defined sorting code', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'SortingCode3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State of address', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip code of address', 'SCHEMA', N'dbo', 'TABLE', N'CourierSortingCode', 'COLUMN', N'Zip'
GO
