IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PackSerialNo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PackSerialNo](
[PackSerialNoKey] [bigint] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[PickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackSerialNo_PickDetailKey] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackSerialNo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackSerialNo_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackSerialNo_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PackSerialNo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Barcode] [nvarchar](500) NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[PackSerialNo] ADD CONSTRAINT [PK_PackSerialNo] PRIMARY KEY CLUSTERED ([PackSerialNoKey]) ON [PRIMARY]



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PackSerialNo]') AND name = N'IDX_PACKSERIALNO_SERIALNO')
CREATE NONCLUSTERED INDEX [IDX_PACKSERIALNO_SERIALNO] ON [dbo].[PackSerialNo]
(
   [SerialNo] ASC,
   [StorerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PackSerialNo]') AND name = N'IX_PackSerialNo_LabelNo_SKU')
CREATE NONCLUSTERED INDEX [IX_PackSerialNo_LabelNo_SKU] ON [dbo].[PackSerialNo]
(
   [LabelNo] ASC,
   [StorerKey] ASC,
   [SKU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PackSerialNo]') AND name = N'IX_PACKSERIALNO_pickdetailkey')
CREATE NONCLUSTERED INDEX [IX_PACKSERIALNO_pickdetailkey] ON [dbo].[PackSerialNo]
(
   [PickDetailKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]



IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PackSerialNo]') AND name = N'IX_PackSerialNo_PickSlipNo_CartonNo_LabelNo_LabelLine')
CREATE NONCLUSTERED INDEX [IX_PackSerialNo_PickSlipNo_CartonNo_LabelNo_LabelLine] ON [dbo].[PackSerialNo]
(
   [PickSlipNo] ASC,
   [CartonNo] ASC,
   [LabelNo] ASC,
   [LabelLine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]



GRANT DELETE ON  [dbo].[PackSerialNo] TO [NSQL]

GRANT INSERT ON  [dbo].[PackSerialNo] TO [NSQL]

GRANT SELECT ON  [dbo].[PackSerialNo] TO [NSQL]

GRANT UPDATE ON  [dbo].[PackSerialNo] TO [NSQL]


IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'PackSerialNo', NULL,NULL))
   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serial no of a pack detail line' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PackSerialNo'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'PackSerialNo', N'COLUMN',N'PickDetailKey'))
   EXEC sp_addextendedproperty N'MS_Description', 'Optional link to PickDetail, mainly for outbound interface', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', 'COLUMN', N'PickDetailKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'PackSerialNo', N'COLUMN',N'QTY'))
   EXEC sp_addextendedproperty N'MS_Description', 'QTY this serial no represent (could be more than 1)', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', 'COLUMN', N'QTY'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'PackSerialNo', N'COLUMN',N'Barcode'))
   EXEC sp_addextendedproperty N'MS_Description', 'Barcode', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', 'COLUMN', N'Barcode'

END

ELSE 
BEGIN 
   IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PackSerialNo]') AND name = N'IX_PackSerialNo_LabelNo_SKU')
   CREATE NONCLUSTERED INDEX [IX_PackSerialNo_LabelNo_SKU] ON [dbo].[PackSerialNo]
   (
      [LabelNo] ASC,
      [StorerKey] ASC,
      [SKU] ASC
   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

   IF NOT EXISTS (SELECT 1
         FROM sys.columns
         WHERE Name = 'Barcode' AND Object_ID = Object_ID('dbo.PackSerialNo'))
   BEGIN

      ALTER TABLE [dbo].[PackSerialNo] ADD Barcode nvarchar(500) NULL ;
      EXEC sp_addextendedproperty N'MS_Description', 'Barcode', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', 'COLUMN', N'Barcode'
   
   END

END