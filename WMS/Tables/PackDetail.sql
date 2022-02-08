CREATE TABLE [dbo].[PackDetail]
(
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_PackDetail_Qty] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetail_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackDetail_Adddate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetail_Editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PackDetail_Editdate] DEFAULT (getdate()),
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackDetail_RefNo] DEFAULT (' '),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpQty] [int] NULL CONSTRAINT [DF_PackDetail_ExpQty] DEFAULT ((0)),
[UPC] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetail_DropID] DEFAULT (' '),
[RefNo2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackDetail_RefNo2] DEFAULT (' '),
[LOTTABLEVALUE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackDetail_LOTTABLEVALUE] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PackDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PackDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackDetail] TO [NSQL]
GO

ALTER TABLE [dbo].[PackDetail] ADD CONSTRAINT [PKPackDetail] PRIMARY KEY CLUSTERED ([PickSlipNo], [CartonNo], [LabelNo], [LabelLine]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_DROPID] ON [dbo].[PackDetail] ([DropID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_LblNo_SKU] ON [dbo].[PackDetail] ([LabelNo], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_RefNo2] ON [dbo].[PackDetail] ([RefNo2]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_StorerKey_RefNo] ON [dbo].[PackDetail] ([StorerKey], [RefNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_Pickslipno_Storer_Sku] ON [dbo].[PackDetail] ([StorerKey], [SKU], [PickSlipNo]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PackDetail] WITH NOCHECK ADD CONSTRAINT [FK_PackDetail_PackHeader] FOREIGN KEY ([PickSlipNo]) REFERENCES [dbo].[PackHeader] ([PickSlipNo])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton No.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Label.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'LabelNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pickslip No.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reference No.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'RefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'StorerKey'
GO
