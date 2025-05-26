IF NOT EXISTS (SELECT *
         FROM sys.tables
         WHERE name = 'PTLTRAN'
            AND type = 'U')
BEGIN
	CREATE TABLE [PTL].[PTLTRAN]
	(
	[PTLKey] [bigint] NOT NULL IDENTITY(1, 1),
	[IPAddress] [nvarchar] (40) NOT NULL CONSTRAINT [DF_PTLTRAN_IPAddress] DEFAULT (''),
	[DevicePosition] [nvarchar] (10) NOT NULL CONSTRAINT [DF_PTLTRAN_DevicePosition] DEFAULT (''),
	[DeviceID] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTRAN_DeviceID] DEFAULT (''),
	[Status] [nvarchar] (2) NOT NULL CONSTRAINT [DF_PTLTran_Status] DEFAULT ('0'),
	[LightMode] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_LightMode] DEFAULT (''),
	[LightUp] [nvarchar] (1) NULL CONSTRAINT [DF_PTLTran_LightUp] DEFAULT ('0'),
	[LightSequence] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_LightSequence] DEFAULT (''),
	[PTLType] [nvarchar] (20) NOT NULL,
	[SourceKey] [nvarchar] (20) NULL CONSTRAINT [DF_PTLTRAN_SourceKey] DEFAULT (''),
	[DropID] [nvarchar] (20) NULL CONSTRAINT [DF_PTLTran_DropID] DEFAULT (''),
	[CaseID] [nvarchar] (20) NULL CONSTRAINT [DF_PTLTran_CaseID] DEFAULT (''),
	[RefPTLKey] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_RefPTLKey] DEFAULT (''),
	[StorerKey] [nvarchar] (15) NULL CONSTRAINT [DF_PTLTran_Storerkey] DEFAULT (''),
	[OrderKey] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_OrderKey] DEFAULT (''),
	[ConsigneeKey] [nvarchar] (15) NULL CONSTRAINT [DF_PTLTran_ConsigneeKey] DEFAULT (''),
	[SKU] [nvarchar] (20) NULL CONSTRAINT [DF_PTLTran_SKU] DEFAULT (''),
	[LOC] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_LOC] DEFAULT (''),
	[LOT] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_LOT] DEFAULT (''),
	[UOM] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_UOM] DEFAULT (''),
	[ExpectedQty] [int] NULL CONSTRAINT [DF_PTLTran_ExpectedQty] DEFAULT (''),
	[Qty] [int] NULL CONSTRAINT [DF_PTLTran_Qty] DEFAULT (''),
	[Remarks] [nvarchar] (500) NULL CONSTRAINT [DF_PTLTran_Remarks] DEFAULT (''),
	[DisplayValue] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_DisplayValue] DEFAULT (''),
	[ReceiveValue] [nvarchar] (50) NULL CONSTRAINT [DF_PTLTran_ReceiveValue] DEFAULT (''),
	[DeviceProfileLogKey] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_DeviceProfileLogKey] DEFAULT (''),
	[Func] [int] NULL CONSTRAINT [DF_PTLTRAN_Func] DEFAULT ((0)),
	[AddDate] [datetime] NULL CONSTRAINT [DF_PTLTran_AddDate] DEFAULT (getdate()),
	[AddWho] [nvarchar] (128) NULL CONSTRAINT [DF_PTLTran_AddWho] DEFAULT (suser_sname()),
	[EditDate] [datetime] NULL CONSTRAINT [DF_PTLTran_EditDate] DEFAULT (getdate()),
	[EditWho] [nvarchar] (128) NULL CONSTRAINT [DF_PTLTran_EditWho] DEFAULT (suser_sname()),
	[TrafficCop] [nvarchar] (1) NULL,
	[ArchiveCop] [nvarchar] (1) NULL,
	[GroupKey] [int] NOT NULL CONSTRAINT [DF_PTLTRAN_GroupKey] DEFAULT ((0)),
	[SourceType] [nvarchar] (50) NOT NULL CONSTRAINT [DF_PTLTRAN_SourceType] DEFAULT (isnull(object_name(@@procid),'')),
	[Lottable01] [nvarchar] (18) NOT NULL CONSTRAINT [DF_PTLTran_Lottable01] DEFAULT (''),
	[Lottable02] [nvarchar] (18) NOT NULL CONSTRAINT [DF_PTLTran_Lottable02] DEFAULT (''),
	[Lottable03] [nvarchar] (18) NOT NULL CONSTRAINT [DF_PTLTran_Lottable03] DEFAULT (''),
	[Lottable04] [datetime] NULL,
	[Lottable05] [datetime] NULL,
	[Lottable06] [nvarchar] (30) NOT NULL CONSTRAINT [DF_PTLTran_Lottable06] DEFAULT (''),
	[Lottable07] [nvarchar] (30) NOT NULL CONSTRAINT [DF_PTLTran_Lottable07] DEFAULT (''),
	[Lottable08] [nvarchar] (30) NOT NULL CONSTRAINT [DF_PTLTran_Lottable08] DEFAULT (''),
	[Lottable09] [nvarchar] (30) NOT NULL CONSTRAINT [DF_PTLTran_Lottable09] DEFAULT (''),
	[Lottable10] [nvarchar] (30) NOT NULL CONSTRAINT [DF_PTLTran_Lottable10] DEFAULT (''),
	[Lottable11] [nvarchar] (30) NOT NULL CONSTRAINT [DF_PTLTran_Lottable11] DEFAULT (''),
	[Lottable12] [nvarchar] (30) NOT NULL CONSTRAINT [DF_PTLTran_Lottable12] DEFAULT (''),
	[Lottable13] [datetime] NULL,
	[Lottable14] [datetime] NULL,
	[Lottable15] [datetime] NULL,
	[MessageNum] [nvarchar] (10) NULL CONSTRAINT [DF_PTLTran_MessageNum] DEFAULT (''),
	[ID] [nvarchar] (18) NULL CONSTRAINT [DF_PTLTran_ID] DEFAULT (''),
	[Facility] [nvarchar] (5) NULL CONSTRAINT [DF_PTLTran_Facility] DEFAULT ('')
	) ON [PRIMARY]
	ALTER TABLE [PTL].[PTLTRAN] ADD CONSTRAINT [PK_PTLTran] PRIMARY KEY CLUSTERED ([PTLKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
	
	CREATE NONCLUSTERED INDEX [IX_PTLTran_CaseID] ON [PTL].[PTLTRAN] ([CaseID], [StorerKey]) ON [PRIMARY]
	
	CREATE NONCLUSTERED INDEX [IDX_PTLTRAN_DeviceID] ON [PTL].[PTLTRAN] ([DeviceID], [DevicePosition]) WITH (FILLFACTOR=80) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [IDX_PTLTRAN_02] ON [PTL].[PTLTRAN] ([DeviceID], [LightUp]) WITH (FILLFACTOR=80) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [IDX_PTLTRAN_01] ON [PTL].[PTLTRAN] ([DeviceProfileLogKey], [DevicePosition]) WITH (FILLFACTOR=80) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [IX_PTLTran_Key1] ON [PTL].[PTLTRAN] ([IPAddress], [DevicePosition], [Status]) WITH (FILLFACTOR=80) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [IX_PTLTran_Orderkey] ON [PTL].[PTLTRAN] ([OrderKey], [SKU]) ON [PRIMARY]

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable01 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable01'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable02 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable02'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable03 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable03'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable04 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable04'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable05 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable05'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable06 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable06'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable07 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable07'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable08 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable08'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable09 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable09'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable10 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable10'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable11 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable11'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable12 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable12'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable13 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable13'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable14 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable14'

	EXEC sp_addextendedproperty N'MS_Description', N'Store Lottable15 Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Lottable15'

	EXEC sp_addextendedproperty N'MS_Description', N'Store MessageNum Value', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'MessageNum'

	EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Facility'

END
ELSE
BEGIN

	IF NOT EXISTS (SELECT *
                     FROM sys.columns
                     WHERE Name = 'ID'
                     AND Object_ID = Object_ID('PTL.PTLTRAN'))
   BEGIN
      ALTER TABLE [PTL].[PTLTRAN]
      ADD [ID] [nvarchar] (18) NULL CONSTRAINT [DF_PTLTran_ID] DEFAULT ('');

		EXEC sp_addextendedproperty N'MS_Description', N'ID', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'ID'
   END



	IF NOT EXISTS (SELECT *
                     FROM sys.columns
                     WHERE Name = 'Facility'
                     AND Object_ID = Object_ID('PTL.PTLTRAN'))
   BEGIN
      ALTER TABLE [PTL].[PTLTRAN]
      ADD Facility NVARCHAR(5) NULL CONSTRAINT [DF_PTLTran_Facility] DEFAULT ('');

		EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'PTL', 'TABLE', N'PTLTRAN', 'COLUMN', N'Facility'
   END
END

GRANT DELETE ON  [PTL].[PTLTRAN] TO [NSQL]
GO
GRANT INSERT ON  [PTL].[PTLTRAN] TO [NSQL]
GO
GRANT SELECT ON  [PTL].[PTLTRAN] TO [NSQL]
GO
GRANT UPDATE ON  [PTL].[PTLTRAN] TO [NSQL]
GO

