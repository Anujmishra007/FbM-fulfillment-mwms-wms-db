IF NOT EXISTS (SELECT *
FROM sys.tables
WHERE name = 'CartonTrack' AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[CartonTrack]
    (
        [RowRef] [int] NOT NULL IDENTITY(1, 1),
        [TrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [CarrierName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_CarrierName] DEFAULT (' '),
        [KeyName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_KeyName] DEFAULT (' '),
        [LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_LabelNo] DEFAULT (' '),
        [CarrierRef1] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_CarrierRef1] DEFAULT (' '),
        [CarrierRef2] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_CarrierRef2] DEFAULT (' '),
        [AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_AddWho] DEFAULT (suser_sname()),
        [AddDate] [datetime] NULL CONSTRAINT [DF_CartonTrack_AddDate] DEFAULT (getdate()),
        [EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_EditWho] DEFAULT (suser_sname()),
        [EditDate] [datetime] NULL CONSTRAINT [DF_CartonTrack_EditDate] DEFAULT (getdate()),
        [ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [InvDespatchDate] [datetime] NULL,
        [ActualDeliveryDate] [datetime] NULL,
        [UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_UDF01] DEFAULT (''),
        [UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_UDF02] DEFAULT (''),
        [UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_UDF03] DEFAULT (''),
        [TrackingURL] [nvarchar] (200) NULL,
        [VendorTrackingURL] [nvarchar] (200) NULL,
        [PrintData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_PrintData] DEFAULT (''),
        [Cost] [float] NULL CONSTRAINT [DF_CartonTrack_Cost] DEFAULT 0
    ) ON [PRIMARY]

    ALTER TABLE [dbo].[CartonTrack] ADD CONSTRAINT [PK_CartonTrack] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
    CREATE NONCLUSTERED INDEX [IX_CARTONTRACK_03] ON [dbo].[CartonTrack] ([CarrierName], [KeyName], [CarrierRef2], [LabelNo]) ON [PRIMARY]
    CREATE NONCLUSTERED INDEX [idx_cartontrack_LabelNo] ON [dbo].[CartonTrack] ([LabelNo]) ON [PRIMARY]
    CREATE UNIQUE NONCLUSTERED INDEX [idx_cartontrack_TrackingNo] ON [dbo].[CartonTrack] ([TrackingNo], [CarrierName]) ON [PRIMARY]
    GRANT SELECT ON  [dbo].[CartonTrack] TO [JReportRole]
    GRANT DELETE ON  [dbo].[CartonTrack] TO [NSQL]
    GRANT INSERT ON  [dbo].[CartonTrack] TO [NSQL]
    GRANT SELECT ON  [dbo].[CartonTrack] TO [NSQL]
    GRANT UPDATE ON  [dbo].[CartonTrack] TO [NSQL]
    EXEC sp_addextendedproperty N'MS_Description', N'Actual Delivery Date.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'ActualDeliveryDate'
    EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'AddDate'
    EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'AddWho'
    EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'EditDate'
    EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'EditWho'
    EXEC sp_addextendedproperty N'MS_Description', N'Inventory Despatch Date.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'InvDespatchDate'
    EXEC sp_addextendedproperty N'MS_Description', N'ZPL Template for Direct Printing', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'PrintData'
    EXEC sp_addextendedproperty N'MS_Description', N'User define field 1.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'UDF01'
    EXEC sp_addextendedproperty N'MS_Description', N'User define field 2.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'UDF02'
    EXEC sp_addextendedproperty N'MS_Description', N'User define field 3.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'UDF03'
    EXEC sp_addextendedproperty N'MS_Description', N'URL for TrackYourParcel website.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'TrackingURL'
    EXEC sp_addextendedproperty N'MS_Description', N'Tracking URL from supplier', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'VendorTrackingURL'
    EXEC sp_addextendedproperty N'MS_Description', N'Total charges per parcel', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'Cost'
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1
    FROM sys.columns
    WHERE Name = 'TrackingURL' AND Object_ID = Object_ID('CartonTrack'))
            BEGIN
        ALTER TABLE CartonTrack ADD TrackingURL NVARCHAR(200) NULL;
        EXEC sp_addextendedproperty N'MS_Description', N'URL for TrackYourParcel website.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'TrackingURL'
    END
    IF NOT EXISTS (SELECT 1
    FROM sys.columns
    WHERE Name = 'VendorTrackingURL' AND Object_ID = Object_ID('CartonTrack'))
            BEGIN
        ALTER TABLE CartonTrack ADD VendorTrackingURL NVARCHAR(200) NULL;
        EXEC sp_addextendedproperty N'MS_Description', N'Tracking URL from supplier', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'VendorTrackingURL'
    END
    IF NOT EXISTS (SELECT 1
    FROM sys.columns
    WHERE Name = 'Cost' AND Object_ID = Object_ID('CartonTrack'))
            BEGIN
        ALTER TABLE CartonTrack ADD Cost FLOAT NULL CONSTRAINT [DF_CartonTrack_Cost] DEFAULT 0;
        EXEC sp_addextendedproperty N'MS_Description', N'Total charges per parcel', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'Cost'
    END
END