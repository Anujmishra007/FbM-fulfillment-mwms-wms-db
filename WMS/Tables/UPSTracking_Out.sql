CREATE TABLE [dbo].[UPSTracking_Out]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[CartonID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UPSTracking_Out_CartonID] DEFAULT (''),
[CartonType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_CartonType] DEFAULT ('D'),
[WMS_RefKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UPSTracking_Out_WMS_RefKey] DEFAULT (''),
[WMS_RefType] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_WMS_RefType] DEFAULT (''),
[ShipToName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_ShipToName] DEFAULT (''),
[ShipToCompany] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_ShipToCompany] DEFAULT (''),
[ShipToAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_ShipToAddress1] DEFAULT (''),
[ShipToAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_ShipToAddress2] DEFAULT (''),
[ShipToAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_ShipToAddress3] DEFAULT (''),
[City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_City] DEFAULT (''),
[State] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_State] DEFAULT (''),
[Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_Zip] DEFAULT (''),
[Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_Country] DEFAULT (''),
[Phone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceIndicator] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_ServiceIndicator] DEFAULT (''),
[PaymentType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriAcctNo] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScdAcctNo] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToCompany] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToState] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsuranceFlag] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RetailPrice] [money] NULL CONSTRAINT [DF_UPSTracking_Out_RetailPrice] DEFAULT ((0)),
[PLD_RefNo1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_PLD_RefNo1] DEFAULT ((0)),
[PLD_RefNo2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPSTracking_Out_PLD_RefNo2] DEFAULT ((0)),
[PLD_RefNo3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PLD_RefNo4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_UPSTracking_Out_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UPSTracking_Out] ADD CONSTRAINT [PK_UPSTracking_Out] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPSTracking_Out] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPSTracking_Out] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPSTracking_Out] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPSTracking_Out] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPSTracking_Out', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number', 'SCHEMA', N'dbo', 'TABLE', N'UPSTracking_Out', 'COLUMN', N'Phone'
GO
