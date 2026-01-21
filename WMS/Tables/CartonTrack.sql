SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CartonTrack]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CartonTrack](
	[RowRef] [int] IDENTITY(1,1) NOT NULL,
	[TrackingNo] [nvarchar](40) NULL,
	[CarrierName] [nvarchar](30) NULL,
	[KeyName] [nvarchar](30) NULL,
	[LabelNo] [nvarchar](25) NULL,
	[CarrierRef1] [nvarchar](100) NULL,
	[CarrierRef2] [nvarchar](40) NULL,
	[AddWho] [nvarchar](128) NULL,
	[AddDate] [datetime] NULL,
	[EditWho] [nvarchar](128) NULL,
	[EditDate] [datetime] NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[InvDespatchDate] [datetime] NULL,
	[ActualDeliveryDate] [datetime] NULL,
	[UDF01] [nvarchar](30) NULL,
	[UDF02] [nvarchar](30) NULL,
	[UDF03] [nvarchar](30) NULL,
	[PrintData] [nvarchar](max) NULL,
	[TrackingURL] [nvarchar](200) NULL,
	[VendorTrackingURL] [nvarchar](200) NULL,
	[Cost] [float] NULL,
 CONSTRAINT [PK_CartonTrack] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END

GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CartonTrack]') AND name = N'idx_cartontrack_LabelNo')
CREATE NONCLUSTERED INDEX [idx_cartontrack_LabelNo] ON [dbo].[CartonTrack]
(
	[LabelNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CartonTrack]') AND name = N'idx_cartontrack_TrackingNo')
CREATE UNIQUE NONCLUSTERED INDEX [idx_cartontrack_TrackingNo] ON [dbo].[CartonTrack]
(
	[TrackingNo] ASC,
	[CarrierName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CartonTrack]') AND name = N'IX_CARTONTRACK_03')
CREATE NONCLUSTERED INDEX [IX_CARTONTRACK_03] ON [dbo].[CartonTrack]
(
	[CarrierName] ASC,
	[KeyName] ASC,
	[CarrierRef2] ASC,
	[LabelNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_CarrierName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_CarrierName]  DEFAULT (' ') FOR [CarrierName]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_KeyName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_KeyName]  DEFAULT (' ') FOR [KeyName]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_LabelNo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_LabelNo]  DEFAULT (' ') FOR [LabelNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__CartonTra__Carri__0E2903D0]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF__CartonTra__Carri__0E2903D0]  DEFAULT (' ') FOR [CarrierRef1]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__CartonTra__Carri__0F1D2809]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF__CartonTra__Carri__0F1D2809]  DEFAULT (' ') FOR [CarrierRef2]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_UDF01]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_UDF01]  DEFAULT ('') FOR [UDF01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_UDF02]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_UDF02]  DEFAULT ('') FOR [UDF02]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_UDF03]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_UDF03]  DEFAULT ('') FOR [UDF03]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_PrintData]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_PrintData]  DEFAULT ('') FOR [PrintData]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_Cost]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack] ADD  CONSTRAINT [DF_CartonTrack_Cost]  DEFAULT ((0)) FOR [Cost]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'AddWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID added the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'AddWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'AddDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information added. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'AddDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'EditWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'EditWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'EditDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'EditDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'InvDespatchDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inventory Despatch Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'InvDespatchDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'ActualDeliveryDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actual Delivery Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'ActualDeliveryDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'UDF01'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User define field 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'UDF01'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'UDF02'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User define field 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'UDF02'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'UDF03'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User define field 3.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'UDF03'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'PrintData'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ZPL Template for Direct Printing' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'PrintData'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'TrackingURL'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'URL for TrackYourParcel website.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'TrackingURL'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CartonTrack', N'COLUMN',N'VendorTrackingURL'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tracking URL from supplier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CartonTrack', @level2type=N'COLUMN',@level2name=N'VendorTrackingURL'
GO


IF NOT EXISTS (SELECT 1
FROM sys.columns
WHERE Name = 'PrintData' AND Object_ID = Object_ID('dbo.CartonTrack'))
        BEGIN
    ALTER TABLE CartonTrack ADD PrintData NVARCHAR(MAX) NULL;
    EXEC sp_addextendedproperty N'MS_Description', N'ZPL Template for Direct Printing', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'PrintData'
END
IF NOT EXISTS (SELECT 1
FROM sys.columns
WHERE Name = 'TrackingURL' AND Object_ID = Object_ID('dbo.CartonTrack'))
        BEGIN
    ALTER TABLE CartonTrack ADD TrackingURL NVARCHAR(200) NULL;
    EXEC sp_addextendedproperty N'MS_Description', N'URL for TrackYourParcel website.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'TrackingURL'
END
IF NOT EXISTS (SELECT 1
FROM sys.columns
WHERE Name = 'VendorTrackingURL' AND Object_ID = Object_ID('dbo.CartonTrack'))
BEGIN
    ALTER TABLE CartonTrack ADD VendorTrackingURL NVARCHAR(200) NULL;
    EXEC sp_addextendedproperty N'MS_Description', N'Tracking URL from supplier', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'VendorTrackingURL'
END
IF NOT EXISTS (SELECT 1
FROM sys.columns
WHERE Name = 'Cost' AND Object_ID = Object_ID('dbo.CartonTrack'))
        BEGIN
    ALTER TABLE CartonTrack ADD Cost FLOAT NULL CONSTRAINT [DF_CartonTrack_Cost] DEFAULT 0;
    EXEC sp_addextendedproperty N'MS_Description', N'Total charges per parcel', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'Cost'
END

--FCR-9954
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'CartonTrack' AND COLUMN_NAME = 'CarrierRef1' AND CHARACTER_MAXIMUM_LENGTH = 40)
BEGIN
ALTER TABLE dbo.CartonTrack ALTER COLUMN CarrierRef1 NVARCHAR (100) NULL
END