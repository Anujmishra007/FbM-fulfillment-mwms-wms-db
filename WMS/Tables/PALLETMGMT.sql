CREATE TABLE [dbo].[PALLETMGMT]
(
[PMKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_PMKey] DEFAULT (''),
[Sourcekey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_Sourcekey] DEFAULT (''),
[Sourcetype] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_Sourcetype] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_Facility] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_Status] DEFAULT ('0'),
[DispatchDate] [datetime] NULL,
[DeliveryDate] [datetime] NULL,
[EffectiveDate] [datetime] NULL,
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETMGMT_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_PALLETMGMT_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETMGMT_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_PALLETMGMT_Editdate] DEFAULT (getdate()),
[Trafficcop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PALLETMGMT] ADD CONSTRAINT [PK_PALLETMGMT] PRIMARY KEY CLUSTERED ([PMKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PALLETMGMT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PALLETMGMT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PALLETMGMT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PALLETMGMT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet Management', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created On Date', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created by', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archivecop', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Archivecop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Delivery Date', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'DeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Dispatch Date', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'DispatchDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits on', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits by', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Effective Date', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management Key', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'PMKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source key', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Sourcekey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source type; ASN,SO,MBOL,LOADPLAN', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Sourcetype'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trafficcop', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Trafficcop'
GO
