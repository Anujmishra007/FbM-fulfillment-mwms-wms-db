CREATE TABLE [dbo].[KIT]
(
[KITKey] [nvarchar] (10) NOT NULL,
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_KIT_StorerKey] DEFAULT (' '),
[ToStorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_KIT_ToStorerKey] DEFAULT (' '),
[Type] [nvarchar] (12) NOT NULL CONSTRAINT [DF_KIT_Type] DEFAULT (' '),
[OpenQty] [int] NOT NULL CONSTRAINT [DF_KIT_OpenQty] DEFAULT ((0)),
[Status] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KIT_Status] DEFAULT ('0'),
[EffectiveDate] [datetime] NULL CONSTRAINT [DF_KIT_EffectiveDate] DEFAULT (getdate()),
[ReasonCode] [nvarchar] (10) NULL,
[CustomerRefNo] [nvarchar] (10) NULL,
[Remarks] [nvarchar] (200) NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_KIT_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_KIT_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_KIT_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_KIT_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) NULL,
[ArchiveCop] [nvarchar] (1) NULL,
[Timestamp] [timestamp] NOT NULL,
[GenerateHOCharges] [nvarchar] (10) NULL,
[GenerateIS_HiCharges] [nvarchar] (10) NULL,
[Facility] [nvarchar] (5) NULL CONSTRAINT [DF_KIT_Facility] DEFAULT ('F1'),
[USRDEF1] [nvarchar] (18) NULL CONSTRAINT [DF_KIT_USRDEF1] DEFAULT (' '),
[USRDEF2] [nvarchar] (18) NULL CONSTRAINT [DF_KIT_USRDEF2] DEFAULT (' '),
[USRDEF3] [nvarchar] (18) NULL CONSTRAINT [DF_KIT_USRDEF3] DEFAULT (' '),
[ActionFlag] [nvarchar] (1) NULL CONSTRAINT [DF_KIT_ActionFlag] DEFAULT ('0'),
[ExternKitKey] [nvarchar] (20) NULL CONSTRAINT [DF_KIT_ExternKitKey] DEFAULT (' '),
[USRDEF4] [nvarchar] (30) NULL CONSTRAINT [DF_KIT_USRDEF4] DEFAULT (''),
[USRDEF5] [nvarchar] (30) NULL CONSTRAINT [DF_KIT_USRDEF5] DEFAULT (''),
[USRDEF6] [datetime] NULL,
[USRDEF7] [datetime] NULL,
[USRDEF8] [nvarchar] (30) NULL CONSTRAINT [DF_KIT_USRDEF8] DEFAULT (''),
[USRDEF9] [nvarchar] (30) NULL CONSTRAINT [DF_KIT_USRDEF9] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[KIT] ADD CONSTRAINT [PK_KIT] PRIMARY KEY CLUSTERED ([KITKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[KIT] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[KIT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[KIT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[KIT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[KIT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Kitting is the process of placing two or more items together to form one group or product, to be sold as one single item. Inventory updates itself by accounting for each individual part and crediting the whole thing as a unit. A kit is essentially a BOM (bill of material) that is not part of manufacturing.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Action flag', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ActionFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer reference number', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'CustomerRefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Kitting used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ExternKitKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Calculate a Handling out charge to be applied to the From Storer for service handling charges', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'GenerateHOCharges'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Calculate both initial storage and handling in charges to be applied to the To Storer for service and handling', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'GenerateIS_HiCharges'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Kitting.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'KITKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reason', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Timestamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer to whom the ownership of product is transferred', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'ToStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of Shipment Order. The default is Standard', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'KIT', 'COLUMN', N'USRDEF3'
GO
