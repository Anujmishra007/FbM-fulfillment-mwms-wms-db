SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Orders_PI_Encrypted]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Orders_PI_Encrypted](
	[Rowrefkey] [int] IDENTITY(1,1) NOT NULL,
	[Orderkey] [nvarchar](10) NULL,
	[C_Contact1] [varbinary](3000) NULL,
	[C_Contact2] [varbinary](1000) NULL,
	[C_Company] [varbinary](1000) NULL,
	[C_Address1] [varbinary](1000) NULL,
	[C_Address2] [varbinary](1000) NULL,
	[C_Address3] [varbinary](1000) NULL,
	[C_Address4] [varbinary](1000) NULL,
	[C_City] [varbinary](1000) NULL,
	[C_State] [varbinary](1000) NULL,
	[C_Zip] [varbinary](1000) NULL,
	[C_Country] [varbinary](1000) NULL,
	[C_Phone1] [varbinary](3000) NULL,
	[C_Phone2] [varbinary](1000) NULL,
	[C_Fax1] [varbinary](1000) NULL,
	[C_Fax2] [varbinary](1000) NULL,
	[B_contact1] [varbinary](1000) NULL,
	[B_Contact2] [varbinary](1000) NULL,
	[B_Company] [varbinary](1000) NULL,
	[B_Address1] [varbinary](1000) NULL,
	[B_Address2] [varbinary](1000) NULL,
	[B_Address3] [varbinary](1000) NULL,
	[B_Address4] [varbinary](1000) NULL,
	[B_City] [varbinary](1000) NULL,
	[B_State] [varbinary](1000) NULL,
	[B_Zip] [varbinary](1000) NULL,
	[B_Country] [varbinary](1000) NULL,
	[B_Phone1] [varbinary](1000) NULL,
	[B_Phone2] [varbinary](1000) NULL,
	[B_Fax1] [varbinary](1000) NULL,
	[B_Fax2] [varbinary](1000) NULL,
	[M_Contact1] [varbinary](1000) NULL,
	[M_Contact2] [varbinary](1000) NULL,
	[M_Company] [varbinary](1000) NULL,
	[M_Address1] [varbinary](1000) NULL,
	[M_Address2] [varbinary](1000) NULL,
	[M_Address3] [varbinary](1000) NULL,
	[M_Address4] [varbinary](1000) NULL,
	[M_City] [varbinary](1000) NULL,
	[M_State] [varbinary](1000) NULL,
	[M_Zip] [varbinary](1000) NULL,
	[M_Country] [varbinary](1000) NULL,
	[M_Phone1] [varbinary](1000) NULL,
	[M_Phone2] [varbinary](1000) NULL,
	[M_Fax1] [varbinary](1000) NULL,
	[M_Fax2] [varbinary](1000) NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
 CONSTRAINT [PKOrders_PI_Encrypted] PRIMARY KEY CLUSTERED 
(
	[Rowrefkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Orders_PI_Encrypted]') AND name = N'IX_Orders_PI_Encrypted_Orderkey')
CREATE UNIQUE NONCLUSTERED INDEX [IX_Orders_PI_Encrypted_Orderkey] ON [dbo].[Orders_PI_Encrypted]
(
	[Orderkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_Orders_PI_Encrypted_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Orders_PI_Encrypted] ADD  CONSTRAINT [DF_Orders_PI_Encrypted_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_Orders_PI_Encrypted_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Orders_PI_Encrypted] ADD  CONSTRAINT [DF_Orders_PI_Encrypted_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_Orders_PI_Encrypted_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Orders_PI_Encrypted] ADD  CONSTRAINT [DF_Orders_PI_Encrypted_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_Orders_PI_Encrypted_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Orders_PI_Encrypted] ADD  CONSTRAINT [DF_Orders_PI_Encrypted_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO


--FCR-15921
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'Orders_PI_Encrypted' AND COLUMN_NAME = 'C_Contact1' AND CHARACTER_MAXIMUM_LENGTH = 3000)
BEGIN
ALTER TABLE dbo.Orders_PI_Encrypted ALTER COLUMN C_Contact1 VARBINARY (3000) NULL
END
--FCR-15921
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'Orders_PI_Encrypted' AND COLUMN_NAME = 'C_Phone1' AND CHARACTER_MAXIMUM_LENGTH = 3000)
BEGIN
ALTER TABLE dbo.Orders_PI_Encrypted ALTER COLUMN C_Phone1 VARBINARY (3000) NULL
END