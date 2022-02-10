CREATE TABLE [dbo].[rdsORDERS]
(
[rdsOrderNo] [int] NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_StorerKey] DEFAULT (' '),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_ExternOrderKey] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderDate] [datetime] NOT NULL CONSTRAINT [DF_rdsORDERS_OrderDate] DEFAULT (getdate()),
[DeliveryDate] [datetime] NOT NULL CONSTRAINT [DF_rdsORDERS_DeliveryDate] DEFAULT (getdate()),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_Priority] DEFAULT ('5'),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_ConsigneeKey] DEFAULT (' '),
[C_Contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Company] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_State] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_vat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerPO] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_BillToKey] DEFAULT (' '),
[B_contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Company] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_State] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Vat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarkforKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_MarkforKey] DEFAULT (' '),
[M_Contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Company] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_State] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_vat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncoTerm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PmtTerm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpenQty] [int] NULL CONSTRAINT [DF_rdsORDERS_OpenQty] DEFAULT ((0)),
[PlannedQty] [int] NULL CONSTRAINT [DF_rdsORDERS_PlannedQty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_Status] DEFAULT ('0'),
[DischargePlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryPlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntermodalVehicle] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_IntermodalVehicle] DEFAULT (' '),
[CountryOfOrigin] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryDestination] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_UpdateSource] DEFAULT ('0'),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_Type] DEFAULT ('0'),
[OrderGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_OrderGroup] DEFAULT (' '),
[Door] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_Door] DEFAULT ('99'),
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_Route] DEFAULT ('99'),
[Stop] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_Stop] DEFAULT ('99'),
[Notes] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes2] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL CONSTRAINT [DF_rdsORDERS_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NULL,
[ContainerType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerQty] [int] NULL,
[BilledContainerQty] [int] NULL CONSTRAINT [DF_rdsORDERS_BilledContainerQty] DEFAULT ((0)),
[SOStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_SOStatus] DEFAULT ('0'),
[InvoiceNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_InvoiceNo] DEFAULT (' '),
[InvoiceAmount] [float] NULL CONSTRAINT [DF_rdsORDERS_InvoiceAmount] DEFAULT ((0.00)),
[Salesman] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_Salesman] DEFAULT (' '),
[GrossWeight] [float] NULL CONSTRAINT [DF_rdsORDERS_GROSSWEIGHT] DEFAULT ((0)),
[Capacity] [float] NULL CONSTRAINT [DF_rdsORDERS_CAPACITY] DEFAULT ((0)),
[PrintFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_PrintFlag] DEFAULT ('N'),
[Rdd] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_Rdd] DEFAULT (' '),
[SequenceNo] [int] NULL CONSTRAINT [DF_rdsORDERS_Sequenceno] DEFAULT ((99999999)),
[Rds] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_Rds] DEFAULT ('N'),
[SectionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrintDocDate] [datetime] NULL,
[LabelPrice] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_POKey] DEFAULT (' '),
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_ExternPOKey] DEFAULT (' '),
[XDockFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_XdockFlag] DEFAULT ('0'),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_UserDefine10] DEFAULT (' '),
[Issued] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryNote] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PODCust] [datetime] NULL,
[PODArrive] [datetime] NULL,
[PODReject] [datetime] NULL,
[PODUser] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_PODUser] DEFAULT (' '),
[XDockPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialHandling] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsORDERS_SpecialHandling] DEFAULT ('N'),
[RoutingTool] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdsORDERS_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdsORDERS_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsORDERS_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[rdsORDERS] ADD CONSTRAINT [PK_rdsORDERS_1] PRIMARY KEY CLUSTERED ([rdsOrderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdsORDERS_ExtOrd] ON [dbo].[rdsORDERS] ([StorerKey], [ExternOrderKey], [BuyerPO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rdsORDERS] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsORDERS] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsORDERS] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsORDERS] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'B_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'B_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'B_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'B_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'B_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'B_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'B_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'C_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'M_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'M_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'M_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'M_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'rdsORDERS', 'COLUMN', N'TrafficCop'
GO
