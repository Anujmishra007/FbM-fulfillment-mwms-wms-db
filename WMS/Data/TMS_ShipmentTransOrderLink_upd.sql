IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TMS_ShipmentTransOrderLink]') AND type in (N'U'))
BEGIN

CREATE TABLE [dbo].[TMS_ShipmentTransOrderLink]
(
	[Rowref] [int] NOT NULL IDENTITY(1, 1),
	[ProvShipmentID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShipmentGID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AddDate] [datetime] NULL CONSTRAINT [DF_TMS_ShipmentTransOrderLink_AddDate]  DEFAULT (getdate()),
	[AddWho] [nvarchar](128) NULL CONSTRAINT [DF_TMS_ShipmentTransOrderLink_AddWho]  DEFAULT (suser_name()),
	[EditWho] [nvarchar](128) NULL CONSTRAINT [DF_TMS_ShipmentTransOrderLink_EditWho]  DEFAULT (suser_name()),
	[ArchiveCop] [nvarchar](1) NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[TMS_ShipmentTransOrderLink] ADD CONSTRAINT [PKTMS_ShipmentTransOrderLink] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]

GRANT DELETE ON  [dbo].[TMS_ShipmentTransOrderLink] TO [NSQL]
GRANT INSERT ON  [dbo].[TMS_ShipmentTransOrderLink] TO [NSQL]
GRANT SELECT ON  [dbo].[TMS_ShipmentTransOrderLink] TO [NSQL]
GRANT UPDATE ON  [dbo].[TMS_ShipmentTransOrderLink] TO [NSQL]
END


ELSE 
BEGIN 
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'AddDate' AND Object_ID = Object_ID('dbo.TMS_ShipmentTransOrderLink'))
			BEGIN

				ALTER TABLE dbo.TMS_ShipmentTransOrderLink ADD AddDate [datetime] NULL CONSTRAINT [DF_TMS_ShipmentTransOrderLink_AddDate]  DEFAULT (getdate());
				EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TMS_ShipmentTransOrderLink', 'COLUMN', N'AddDate'
				
			END

		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'AddWho' AND Object_ID = Object_ID('dbo.TMS_ShipmentTransOrderLink'))
			BEGIN

				ALTER TABLE dbo.TMS_ShipmentTransOrderLink ADD AddWho [nvarchar](128) NULL CONSTRAINT [DF_TMS_ShipmentTransOrderLink_AddWho]  DEFAULT (suser_name());
				EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMS_ShipmentTransOrderLink', 'COLUMN', N'AddWho'
				
			END

		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'EditDate' AND Object_ID = Object_ID('dbo.TMS_ShipmentTransOrderLink'))


		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'EditWho' AND Object_ID = Object_ID('dbo.TMS_ShipmentTransOrderLink'))
			BEGIN

				ALTER TABLE dbo.TMS_ShipmentTransOrderLink ADD EditWho [nvarchar](128) NULL CONSTRAINT [DF_TMS_ShipmentTransOrderLink_EditWho]  DEFAULT (suser_name());
				EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMS_ShipmentTransOrderLink', 'COLUMN', N'EditWho'
				
			END

		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'ArchiveCop' AND Object_ID = Object_ID('dbo.TMS_ShipmentTransOrderLink'))
			BEGIN

				ALTER TABLE dbo.TMS_ShipmentTransOrderLink ADD ArchiveCop [nvarchar](1) NULL;
				EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'TMS_ShipmentTransOrderLink', 'COLUMN', N'ArchiveCop'

				
			END


END
