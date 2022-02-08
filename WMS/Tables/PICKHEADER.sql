CREATE TABLE [dbo].[PICKHEADER]
(
[PickHeaderKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_WaveKey] DEFAULT (' '),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_OrderKey] DEFAULT (' '),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_ExternOrderKey] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_StorerKey] DEFAULT (' '),
[ConsigneeKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_ConsigneeKey] DEFAULT (' '),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_Priority] DEFAULT ('5'),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_Type] DEFAULT ('5'),
[Zone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_Zone] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_Status] DEFAULT ('0'),
[PickType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_PickType] DEFAULT ('3'),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PICKHEADER_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PICKHEADER_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PICKHEADER_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKHEADER_LoadKey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PICKHEADER] WITH NOCHECK ADD CONSTRAINT [CK_PICKHEADER_Status] CHECK ((rtrim([Status]) like '[0-9]'))
GO
ALTER TABLE [dbo].[PICKHEADER] ADD CONSTRAINT [PKPickHeader] PRIMARY KEY NONCLUSTERED ([PickHeaderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKHEADER_Consignee] ON [dbo].[PICKHEADER] ([ConsigneeKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKHEADER_ConsoOrderKey] ON [dbo].[PICKHEADER] ([ConsoOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKHD_LOADKEY] ON [dbo].[PICKHEADER] ([ExternOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKHEADER01] ON [dbo].[PICKHEADER] ([ExternOrderKey], [Zone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKHEADER_OrderKey] ON [dbo].[PICKHEADER] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKHEADER6] ON [dbo].[PICKHEADER] ([PickHeaderKey], [ExternOrderKey], [Zone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PICKHEADER_UNIQUE] ON [dbo].[PICKHEADER] ([WaveKey], [OrderKey], [ExternOrderKey], [ConsoOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKHEADER5] ON [dbo].[PICKHEADER] ([Zone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PICKHEADER] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PICKHEADER] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PICKHEADER] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PICKHEADER] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PICKHEADER] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Header.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'PickHeaderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'WaveKey'
GO
