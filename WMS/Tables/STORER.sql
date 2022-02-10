CREATE TABLE [dbo].[STORER]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_Type] DEFAULT ('1'),
[Company] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VAT] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Company] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes1] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreditLimit] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORER_CreditLimit] DEFAULT ('0'),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORER_Cartongroup] DEFAULT ('STD'),
[PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORER_Pickcode] DEFAULT ('NSPFIFO'),
[CreatePATaskOnRFReceipt] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORER_CreatePATaskOnRFReceipt] DEFAULT ('0'),
[CalculatePutAwayLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORER_CalculatePutAwayLocation] DEFAULT ('2'),
[Status] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_STORER_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_STORER_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinShelfLife] [int] NULL CONSTRAINT [DF_STORER_MinShelfLife] DEFAULT ((0)),
[Logo] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_Logo] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LabelPrice] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TolerancePctg] [int] NULL,
[Pallet] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsigneeFor] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_SUSR1] DEFAULT (' '),
[SUSR2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_SUSR2] DEFAULT (' '),
[SUSR3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_SUSR3] DEFAULT (' '),
[SUSR4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_SUSR4] DEFAULT (' '),
[SUSR5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_SUSR5] DEFAULT (' '),
[Secondary] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_Secondary] DEFAULT (' '),
[XDockStrategykey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Storer_XDockStrategyKey] DEFAULT ('STD'),
[StrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_StrategyKey] DEFAULT (' '),
[CtnPickQty] [int] NOT NULL CONSTRAINT [DF_Storer_CtnPickQty] DEFAULT ((0)),
[CustomerGroupCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORER_CustomerGroupCode] DEFAULT (' '),
[CustomerGroupName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_CustomerGroupName] DEFAULT (' '),
[MarketSegment] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORER_MarketSegment] DEFAULT (' '),
[ABCLogic] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORER_ABCLogic] DEFAULT (' '),
[ABCPeriod] [int] NOT NULL CONSTRAINT [DF_STORER_ABCPeriod] DEFAULT ((0)),
[WorkDayPerWeek] [int] NOT NULL CONSTRAINT [DF_STORER_WorkDayPerWeek] DEFAULT ((0)),
[PercentA] [float] NOT NULL CONSTRAINT [DF_STORER_PercentA] DEFAULT ((0)),
[PercentB] [float] NOT NULL CONSTRAINT [DF_STORER_PercentB] DEFAULT ((0)),
[PickFaceMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductGrouping] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickLocFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORER_PickLocFlag] DEFAULT ('Y'),
[TransportChargeGroup] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PalletMgmtFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PMAccountNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ABCCalendarKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_ABCCalendarKey] DEFAULT (''),
[AutoFinalizeABC] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_AutoFinalizeABC] DEFAULT ('N'),
[UpdateCCDay] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_UpdateCCDay] DEFAULT ('N'),
[CalcZeroMoveAsC] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_CalcZeroMoveAsC] DEFAULT ('N'),
[ABCCalcByPickQty] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORER_ABCCalcByPickQty] DEFAULT ('N'),
[SalesChannel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Storer_SalesChannel] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[STORER] ADD CONSTRAINT [PKStorer] PRIMARY KEY CLUSTERED ([StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ConsigneeFor_SUSR1] ON [dbo].[STORER] ([ConsigneeFor], [SUSR1]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_STORER_CustomerGroupCode] ON [dbo].[STORER] ([CustomerGroupCode]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[STORER] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[STORER] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[STORER] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[STORER] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[STORER] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A storer is the owner of the goods that are stored in the facility. Exceed also uses the Storer table to house other values such as Consignee/Customer codes, Carrier codes, and Bill To codes.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Calculate ABC By Pick Qty', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'ABCCalcByPickQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ABC Period Evaluate by Calendar date setup', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'ABCCalendarKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address Line 1', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address Line 2', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address Line 3', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address Line 4', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Auto Finalize Pending ABC', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'AutoFinalizeABC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Billing Address Line 1.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Billing Address Line 2.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Billing Address Line 3.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Billing Address Line 4.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The city where the billing company resides.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The company that receive and pay the bill.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This storer''s 1st preferred Billing Contact.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This storer''s 2nd preferred Billing Contact.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The billing company''s 1st preferred fax no.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The billing company''s 2nd preferred fax no.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The ISO Country Code (HK, JP) for the billing company.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The Billing company''s 1st preferred Phone no.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The billing company''s 2nd preferred Phone no.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The state where the billing company resides.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The Zip/Postal code of the billing company.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'B_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'If Create PA Task on RF Receipt is set to 1  or 2, this fields controls when Task  Management calculates the putaway  location.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'CalculatePutAwayLocation'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Calculate Zero Movement Stock As C', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'CalcZeroMoveAsC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The default or preferred cartonisation group for this storer.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City where the storer resides.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the company associated with the Storer or long description of the record type.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'If this storer is a consignee, specify its consignor (usually the seller) in this field.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'ConsigneeFor'
GO
EXEC sp_addextendedproperty N'MS_Description', '1st contact person for this storer.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', '2nd contact person for this storer.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country where the storer resides.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Used in Task Manager environment.  Decide whether a Putaway task should be created automatically upon the goods receipt via RF (radio frequency).', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'CreatePATaskOnRFReceipt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The credit limit for this storer.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'CreditLimit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Not used at the moment.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'CtnPickQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This storer''s 1st preferred email id.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Email1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This storer''s 2nd preferred email id.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Email2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The warehouse where the Storer is assigned to.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This storer''s 1st preferred fax no.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This storer''s 2nd preferred fax no.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ISO Country Code (eg HK=Hong Kong, US = United States).', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer minimum SKU shelf life.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'MinShelfLife'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Field for notes, or remarks.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Notes1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Field for additional notes or remarks.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum total pallets for a Storer.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management Flag', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'PalletMgmtFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This storer''s 1st preferred phone no.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This storer''s 2nd preferred phone no.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Picking.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PMA Account No', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'PMAccountNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Distribution channels like wholesalers, retailers, distributors along with Orders', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'SalesChannel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Not used at the moment.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Secondary'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State where the storer resides', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer status in your facility, typically Active,  Inactive, or Hold. This field is notational  only and does not prevent product from  being received or shipped.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the storer record. This should be an abbreviation of the customer''s company name or of the record type associated with the Storer. This is the only required field on the Form tab.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'StrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined 1 which can be used for reference purposes.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'SUSR1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined 2 which can be used for reference purposes.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'SUSR2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined 3 which can be used for reference purposes.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'SUSR3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined 4 which can be used for reference purposes.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'SUSR4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined 5 which can be used for reference purposes.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'SUSR5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'General tolerance percentage allowed for receipts.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'TolerancePctg'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', '1=Storer, 2=Consignee, 3=Carrier, 4=Bill To, 5=Vendor, 9=Broker/Other', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update Sku''s Cycle Count Day', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'UpdateCCDay'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Value Added Tax group.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'VAT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Crossdock strategy that the Storer uses during crossdock operations.', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'XDockStrategykey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip Code', 'SCHEMA', N'dbo', 'TABLE', N'STORER', 'COLUMN', N'Zip'
GO
