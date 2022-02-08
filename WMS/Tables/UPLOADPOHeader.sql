CREATE TABLE [dbo].[UPLOADPOHeader]
(
[POkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POGROUP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADPOHeader_STATUS] DEFAULT ('0'),
[REMARKS] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadingDate] [datetime] NULL CONSTRAINT [DF_UPLOADPOHeader_LoadingDate] DEFAULT (getdate()),
[adddate] [datetime] NULL CONSTRAINT [DF_UPLOADPOHeader_adddate] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_externpokey] ON [dbo].[UPLOADPOHeader] ([ExternPOKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_pokey] ON [dbo].[UPLOADPOHeader] ([POkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_status] ON [dbo].[UPLOADPOHeader] ([STATUS]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPLOADPOHeader] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPLOADPOHeader] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPLOADPOHeader] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPLOADPOHeader] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADPOHeader', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADPOHeader', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADPOHeader', 'COLUMN', N'POkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADPOHeader', 'COLUMN', N'REMARKS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADPOHeader', 'COLUMN', N'Storerkey'
GO
