CREATE TABLE [dbo].[BTB_Shipment]
(
[BTB_ShipmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipmentDate] [datetime] NOT NULL,
[ShipToCountry] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_ShipToCountry] DEFAULT (''),
[Vessel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_Vessel] DEFAULT (''),
[BLNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_BLNo] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_Storerkey] DEFAULT (''),
[FormType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_FormType] DEFAULT (''),
[PermitNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_PermitNo] DEFAULT (''),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine08] DEFAULT (''),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine10] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_Shipment_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_Shipment_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_SHIPMENT_Status] DEFAULT ('0')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BTB_Shipment] ADD CONSTRAINT [PK__BTB_Ship__3809C58544C0098F] PRIMARY KEY CLUSTERED ([BTB_ShipmentKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BTB_Shipment] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BTB_Shipment] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BTB_Shipment] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BTB_Shipment] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BL No', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'BLNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'BTB_ShipmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Form Type', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'FormType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permit No', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'PermitNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipment Date', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'ShipmentDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ship To Country', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'ShipToCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BTB Shipment Status', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 06', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 07', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 08', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 09', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 10', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vessel', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'Vessel'
GO
