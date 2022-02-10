CREATE TABLE [dbo].[FACILITY]
(
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine05] DEFAULT (' '),
[UserDefine06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine06] DEFAULT (' '),
[UserDefine07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine07] DEFAULT (' '),
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine10] DEFAULT (' '),
[UserDefine11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine11] DEFAULT (' '),
[UserDefine12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine12] DEFAULT (' '),
[UserDefine13] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine13] DEFAULT (' '),
[UserDefine14] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine14] DEFAULT (' '),
[UserDefine15] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine15] DEFAULT (' '),
[UserDefine16] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine16] DEFAULT (' '),
[UserDefine17] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine17] DEFAULT (' '),
[UserDefine18] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine18] DEFAULT (' '),
[UserDefine19] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine19] DEFAULT (' '),
[UserDefine20] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine20] DEFAULT (' '),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FACILITY_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_FACILITY_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FACILITY_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_FACILITY_EditDate] DEFAULT (getdate()),
[TMS_Interface] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Facility_TMS_Interface] DEFAULT (' '),
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
[TimeZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FACILITY_Type] DEFAULT (' '),
[SqFeet] [int] NOT NULL CONSTRAINT [DF_FACILITY_SqFeet] DEFAULT ((0)),
[Longitude] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_Longitude] DEFAULT (' '),
[Latitude] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_Latitude] DEFAULT (' '),
[NoOfDoors] [int] NULL CONSTRAINT [DF_Facility_NoOfDoors] DEFAULT ('0'),
[LeaseType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationHours] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FacilityFor] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_FacilityFor] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FACILITY] ADD CONSTRAINT [PK_FACILITY] PRIMARY KEY CLUSTERED ([Facility]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[FACILITY] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[FACILITY] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[FACILITY] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[FACILITY] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[FACILITY] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A facility is also known as a warehouse, distribution center, satellite etc.', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address 1', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address 2', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address 3', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'address 4', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contact Person 1', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contact Person 2', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the facility', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Email Address', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Email1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Email Address', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Email2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key that identifies the warehouse   or distribution center', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Phone number', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Phone number', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transportation management interface code', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'TMS_Interface'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. It is used to store the flag to indicated whether Pallet ID is required', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. Indicates the facility type', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. Default the TO LOCATION', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. Stores the sub inventory code', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. Stores the facility description', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine16'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine17'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine18'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine19'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine20'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip/ Postal', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Zip'
GO
