CREATE TABLE [dbo].[UPLOADC4POHeader]
(
[POkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POGROUP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADC4POHeader_STATUS] DEFAULT ('0'),
[REMARKS] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadingDate] [datetime] NULL CONSTRAINT [DF_UPLOADC4POHeader_LoadingDate] DEFAULT (getdate()),
[adddate] [datetime] NULL CONSTRAINT [DF_UPLOADC4POHeader_adddate] DEFAULT (getdate()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_UploadC4POHeader_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UploadC4POHeader_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[UPLOADC4POHeader] ADD CONSTRAINT [PK_UPLOADC4POHeader] PRIMARY KEY CLUSTERED ([POkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPLOADC4POHeader_ExtPOKey] ON [dbo].[UPLOADC4POHeader] ([ExternPOKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPLOADC4POHeader] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPLOADC4POHeader] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPLOADC4POHeader] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPLOADC4POHeader] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'POkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'REMARKS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'Storerkey'
GO
