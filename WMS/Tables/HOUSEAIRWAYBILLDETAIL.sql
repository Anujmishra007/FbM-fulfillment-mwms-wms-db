CREATE TABLE [dbo].[HOUSEAIRWAYBILLDETAIL]
(
[HAWBKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HAWBLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_HAWBLineNumber] DEFAULT (' '),
[NumberOfPieces] [int] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_NumberOfPieces] DEFAULT ((1)),
[GrossWeight] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_GrossWeight] DEFAULT ((0)),
[UOMWeight] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_UOMWeight] DEFAULT (' '),
[RateClass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_RateClass] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Sku] DEFAULT (' '),
[SkuDescription] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_SkuDescription] DEFAULT (' '),
[ChargeableWeight] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_ChargeableWeight] DEFAULT ((0)),
[Rate] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Rate] DEFAULT ((0)),
[Extension] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Extension] DEFAULT ((0)),
[UOMVolume] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_UOMVolume] DEFAULT (' '),
[Length] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Length] DEFAULT ((0)),
[Width] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Width] DEFAULT ((0)),
[Height] [float] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_Height] DEFAULT ((0)),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOUSEAIRWAYBILLDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [timestamp] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[HOUSEAIRWAYBILLDETAIL] ADD CONSTRAINT [PKHouseAirWayBillDetail] PRIMARY KEY CLUSTERED ([HAWBKEY], [HAWBLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[HOUSEAIRWAYBILLDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying House Airway Bill.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'HAWBKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about House Airway Bill Detail.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'SkuDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'HOUSEAIRWAYBILLDETAIL', 'COLUMN', N'TrafficCop'
GO
