CREATE TABLE [dbo].[Orders_PI_Encrypted]
(
[Rowrefkey] [int] NOT NULL IDENTITY(1, 1),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_Contact1] [varbinary] (500) NOT NULL,
[C_Contact2] [varbinary] (500) NOT NULL,
[C_Company] [varbinary] (500) NOT NULL,
[C_Address1] [varbinary] (500) NOT NULL,
[C_Address2] [varbinary] (500) NOT NULL,
[C_Address3] [varbinary] (500) NOT NULL,
[C_Address4] [varbinary] (500) NOT NULL,
[C_City] [varbinary] (500) NOT NULL,
[C_State] [varbinary] (500) NOT NULL,
[C_Zip] [varbinary] (500) NOT NULL,
[C_Country] [varbinary] (500) NOT NULL,
[C_Phone1] [varbinary] (500) NOT NULL,
[C_Phone2] [varbinary] (500) NOT NULL,
[C_Fax1] [varbinary] (500) NOT NULL,
[C_Fax2] [varbinary] (500) NOT NULL,
[B_contact1] [varbinary] (500) NOT NULL,
[B_Contact2] [varbinary] (500) NOT NULL,
[B_Company] [varbinary] (500) NOT NULL,
[B_Address1] [varbinary] (500) NOT NULL,
[B_Address2] [varbinary] (500) NOT NULL,
[B_Address3] [varbinary] (500) NOT NULL,
[B_Address4] [varbinary] (500) NOT NULL,
[B_City] [varbinary] (500) NOT NULL,
[B_State] [varbinary] (500) NOT NULL,
[B_Zip] [varbinary] (500) NOT NULL,
[B_Country] [varbinary] (500) NOT NULL,
[B_Phone1] [varbinary] (500) NOT NULL,
[B_Phone2] [varbinary] (500) NOT NULL,
[B_Fax1] [varbinary] (500) NOT NULL,
[B_Fax2] [varbinary] (500) NOT NULL,
[M_Contact1] [varbinary] (500) NOT NULL,
[M_Contact2] [varbinary] (500) NOT NULL,
[M_Company] [varbinary] (500) NOT NULL,
[M_Address1] [varbinary] (500) NOT NULL,
[M_Address2] [varbinary] (500) NOT NULL,
[M_Address3] [varbinary] (500) NOT NULL,
[M_Address4] [varbinary] (500) NOT NULL,
[M_City] [varbinary] (500) NOT NULL,
[M_State] [varbinary] (500) NOT NULL,
[M_Zip] [varbinary] (500) NOT NULL,
[M_Country] [varbinary] (500) NOT NULL,
[M_Phone1] [varbinary] (500) NOT NULL,
[M_Phone2] [varbinary] (500) NOT NULL,
[M_Fax1] [varbinary] (500) NOT NULL,
[M_Fax2] [varbinary] (500) NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Orders_PI_Encrypted_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Orders_PI_Encrypted_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Orders_PI_Encrypted_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Orders_PI_Encrypted_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Orders_PI_Encrypted] ADD CONSTRAINT [PKOrders_PI_Encrypted] PRIMARY KEY CLUSTERED ([Rowrefkey]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Orders_PI_Encrypted_Orderkey] ON [dbo].[Orders_PI_Encrypted] ([Orderkey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Orders_PI_Encrypted] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Orders_PI_Encrypted] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Orders_PI_Encrypted] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Orders_PI_Encrypted] TO [NSQL]
GO
