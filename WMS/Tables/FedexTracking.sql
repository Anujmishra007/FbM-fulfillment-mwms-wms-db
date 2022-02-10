CREATE TABLE [dbo].[FedexTracking]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrackingNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdateSource] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_FedexTracking_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FedexTracking_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_FedexTracking_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FedexTracking_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FedexTracking] ADD CONSTRAINT [PK_FedexTracking] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FedexTracking] ON [dbo].[FedexTracking] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FedexTracking1] ON [dbo].[FedexTracking] ([PickSlipNo], [CartonNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FedexTracking] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[FedexTracking] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[FedexTracking] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[FedexTracking] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'FedexTracking', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'FedexTracking', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'FedexTracking', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'FedexTracking', 'COLUMN', N'EditWho'
GO
