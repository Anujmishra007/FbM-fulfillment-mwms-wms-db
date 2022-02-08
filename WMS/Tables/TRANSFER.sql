CREATE TABLE [dbo].[TRANSFER]
(
[TransferKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFER_FromStorerKey] DEFAULT (' '),
[ToStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFER_ToStorerKey] DEFAULT (' '),
[Type] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OpenQty] [int] NOT NULL CONSTRAINT [DF_TRANSFER_OpenQty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFER_Status] DEFAULT ('0'),
[GenerateHOCharges] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFER_GenerateHOCharges] DEFAULT ('1'),
[GenerateIS_HICharges] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFER_GenerateIS_HICharges] DEFAULT ('1'),
[ReLot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_ReLot] DEFAULT ('0'),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSFER_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSFER_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFER_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSFER_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFER_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerRefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_CustomerRefNo] DEFAULT (' '),
[Remarks] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_Remarks] DEFAULT (' '),
[Facility] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Transfer_Facility] DEFAULT (' '),
[PrintFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFER_UserDefine10] DEFAULT (' '),
[ToFacility] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Transfer_ToFacility] DEFAULT (' ')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TRANSFER] ADD CONSTRAINT [CK_TRANSFER_Status] CHECK ((rtrim([Status]) like '[0-9]' OR rtrim([Status])='CANC'))
GO
ALTER TABLE [dbo].[TRANSFER] ADD CONSTRAINT [PKTRANSFER] PRIMARY KEY CLUSTERED ([TransferKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TRANSFER] WITH NOCHECK ADD CONSTRAINT [FK_TRANSFER_STORER_01] FOREIGN KEY ([FromStorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
ALTER TABLE [dbo].[TRANSFER] WITH NOCHECK ADD CONSTRAINT [FK_TRANSFER_STORER_02] FOREIGN KEY ([ToStorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
GRANT SELECT ON  [dbo].[TRANSFER] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[TRANSFER] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TRANSFER] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TRANSFER] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TRANSFER] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transfer is one of the functions that are available in Exceed WMS to help the users to manage the flow of goods in the warehouse or facility. The Transfer ticket is used to transfer goods between facilities and/or storers. It allows the user to transfer goods from one storerÆs inventory to another storerÆs inventory in a single process. The inventory transfer creates a deposit transaction and a withdrawal in the inventory module.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'customer reference number', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'CustomerRefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The facility or warehouse where the product is originally stored', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer to whom the ownership of product is transferred', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'FromStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Calculate a Handling out charge to be applied to the From Storer for service handling charges', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'GenerateHOCharges'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Calculate both initial storage and handling in charges to be applied to the To Storer for service and handling', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'GenerateIS_HICharges'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This command sets the flag which controls the amount of output.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'PrintFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The reason for the transfer', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Refers to the re-generation of lot number to the specific products transfer', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'ReLot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'any notes / remarks', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status of the transfer', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'Timestamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The facility in which the product will be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'ToFacility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer to whom the ownership of product is transferred', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'ToStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'It''s used to identify a specific transfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'TransferKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of transfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine06', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine07', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFER', 'COLUMN', N'UserDefine10'
GO
