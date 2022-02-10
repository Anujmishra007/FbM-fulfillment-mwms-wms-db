CREATE TABLE [dbo].[RefKeyLookup]
(
[PickDetailkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pickslipno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RefKeyLookup_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RefKeyLookup_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RefKeyLookup] ADD CONSTRAINT [PK_RefKeyLookup] PRIMARY KEY CLUSTERED ([PickDetailkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RefKeyLookup_OrderInfo] ON [dbo].[RefKeyLookup] ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RefKeyLookup_PickSlipno] ON [dbo].[RefKeyLookup] ([Pickslipno]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RefKeyLookup] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RefKeyLookup] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RefKeyLookup] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RefKeyLookup] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RefKeyLookup', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'RefKeyLookup', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'RefKeyLookup', 'COLUMN', N'Loadkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'RefKeyLookup', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying pick detail.', 'SCHEMA', N'dbo', 'TABLE', N'RefKeyLookup', 'COLUMN', N'PickDetailkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying pick slip.', 'SCHEMA', N'dbo', 'TABLE', N'RefKeyLookup', 'COLUMN', N'Pickslipno'
GO
