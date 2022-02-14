CREATE TABLE [dbo].[ChannelTransfer]
(
[ChannelTransferKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternChannelTransferKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_ExternChannelTransferKey] DEFAULT (' '),
[FromStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_FromStorerKey] DEFAULT (' '),
[ToStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_ToStorerKey] DEFAULT (' '),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_Type] DEFAULT (' '),
[OpenQty] [int] NOT NULL CONSTRAINT [DF_ChannelTransfer_OpenQty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_Status] DEFAULT ('0'),
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_ReasonCode] DEFAULT (' '),
[CustomerRefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_CustomerRefNo] DEFAULT (' '),
[Remarks] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_Remarks] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_Facility] DEFAULT (' '),
[ToFacility] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_ToFacility] DEFAULT (' '),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine05] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ChannelTransfer_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ChannelTransfer_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ChannelTransfer] ADD CONSTRAINT [PKChannelTransfer] PRIMARY KEY CLUSTERED ([ChannelTransferKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChannelTransfer_ExternKey] ON [dbo].[ChannelTransfer] ([FromStorerKey], [ExternChannelTransferKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChannelTransfer] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChannelTransfer] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChannelTransfer] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChannelTransfer] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'ChannelTransfer is one of the functions that are available in Exceed WMS to help the users to manage the flow of goods in the warehouse or facility. The ChannelTransfer ticket is used to ChannelTransfer goods between Channels and/or storers. It allows the user to ChannelTransfer goods from one storerÆs inventory to another storerÆs inventory in a single process. The inventory ChannelTransfer creates a deposit transaction and a withdrawal in the inventory module.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify a specific ChannelTransfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ChannelTransferKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'customer reference number', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'CustomerRefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify a specific an External ChannelTransfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ExternChannelTransferKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The facility or warehouse where the product is originally stored', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer from whom the ownership of product is ChannelTransferred', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'FromStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason for the ChannelTransfer', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'any notes / remarks', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status of the ChannelTransfer', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The facility in which the product will be ChannelTransferred to', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ToFacility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer to whom the ownership of product is ChannelTransferred', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ToStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of ChannelTransfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine05'
GO
