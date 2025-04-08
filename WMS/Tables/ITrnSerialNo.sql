IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'ITrnSerialNo' AND type = 'U')
BEGIN
CREATE TABLE [dbo].[ITrnSerialNo]
(
[ITrnSerialNoKey] [bigint] NOT NULL IDENTITY(1, 1),
[ITrnKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ITrnSerialNo_AddDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lot]  DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Loc]  DEFAULT (' '),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_ID]  DEFAULT (' '),
[LOTTABLE01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable01] DEFAULT (' '),
[LOTTABLE02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable02] DEFAULT (' '),
[LOTTABLE03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable03] DEFAULT (' '),
[LOTTABLE04] [datetime] NULL,
[LOTTABLE05] [datetime] NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable06] DEFAULT (' '),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable07] DEFAULT (' '),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable08] DEFAULT (' '),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable09] DEFAULT (' '),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable10] DEFAULT (' '),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable11] DEFAULT (' '),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable12] DEFAULT (' '),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Channel] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Channel_ID] [bigint] NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITrnSerialNo_UCCNo] DEFAULT (' ')
) ON [PRIMARY]

ALTER TABLE [dbo].[ITrnSerialNo] ADD CONSTRAINT [PK_ITrnSerialNo] PRIMARY KEY CLUSTERED ([ITrnSerialNoKey]) ON [PRIMARY]

GRANT DELETE ON  [dbo].[ITrnSerialNo] TO [NSQL]

GRANT INSERT ON  [dbo].[ITrnSerialNo] TO [NSQL]

GRANT SELECT ON  [dbo].[ITrnSerialNo] TO [NSQL]

GRANT UPDATE ON  [dbo].[ITrnSerialNo] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', 'ITrn for serial no (record inserted when QTY belong to serial no changed)', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', NULL, NULL

EXEC sp_addextendedproperty N'MS_Description', 'Link to ITrn.ITrnKey', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'ITrnKey'

EXEC sp_addextendedproperty N'MS_Description', 'QTY this serial no represent (could be more than 1)', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'QTY'

EXEC sp_addextendedproperty N'MS_Description', 'Document + line that trigger insert this record', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'SourceKey'

EXEC sp_addextendedproperty N'MS_Description', 'Stored procedure that insert this record', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'SourceType'

EXEC sp_addextendedproperty N'MS_Description', 'Same as ITrn.TranType (currently only DP=Deposit)', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'TranType'

EXEC sp_addextendedproperty N'MS_Description', N'Lot', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lot'

EXEC sp_addextendedproperty N'MS_Description', N'Loc', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Loc'

EXEC sp_addextendedproperty N'MS_Description', N'ID', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'ID'

EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE01', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE01'

EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE02', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE02'

EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE03', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE03'

EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE04', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE04'

EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE05', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE05'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable06', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable06'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable07', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable07'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable08', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable08'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable09', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable09'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable10', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable10'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable11', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable11'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable12', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable12'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable13', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable13'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable14', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable14'

EXEC sp_addextendedproperty N'MS_Description', N'Lottable15', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable15'

EXEC sp_addextendedproperty N'MS_Description', N'Channel', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Channel'

EXEC sp_addextendedproperty N'MS_Description', N'Channel_ID', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Channel_ID'

EXEC sp_addextendedproperty N'MS_Description', N'UCCNo', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'UCCNo'
END
ELSE
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lot' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lot NVARCHAR(10) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lot]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'Lot', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lot'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Loc' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Loc NVARCHAR(10) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Loc]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'Loc', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Loc'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'ID' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD ID NVARCHAR(18) NOT NULL CONSTRAINT [DF_ITrnSerialNo_ID]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'ID', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'ID'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'LOTTABLE01' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD LOTTABLE01 NVARCHAR(18) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable01]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE01', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE01'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'LOTTABLE02' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD LOTTABLE02 NVARCHAR(18) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable02]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE02', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE02'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'LOTTABLE03' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD LOTTABLE03 NVARCHAR(18) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable03]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE03', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE03'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'LOTTABLE04' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD LOTTABLE04 datetime NULL;
					EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE04', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE04'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'LOTTABLE05' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD LOTTABLE05 datetime NULL;
					EXEC sp_addextendedproperty N'MS_Description', N'LOTTABLE05', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'LOTTABLE05'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable06' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable06 NVARCHAR(30) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable06]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable06', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable06'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable07' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable07 NVARCHAR(30) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable07]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable07', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable07'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable08' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable08 NVARCHAR(30) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable08]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable08', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable08'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable09' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable09 NVARCHAR(30) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable09]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable09', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable09'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable10' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable10 NVARCHAR(30) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable10]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable10', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable10'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable11' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable11 NVARCHAR(30) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable11]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable11', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable11'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable12' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable12 NVARCHAR(30) NOT NULL CONSTRAINT [DF_ITrnSerialNo_Lottable12]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable12', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable12'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable13' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable13 datetime NULL;
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable13', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable13'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable14' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable14 datetime NULL;
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable14', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable14'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Lottable15' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Lottable15 datetime NULL;
					EXEC sp_addextendedproperty N'MS_Description', N'Lottable15', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Lottable15'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Channel' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Channel nvarchar(18) NULL;
					EXEC sp_addextendedproperty N'MS_Description', N'Channel', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Channel'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'Channel_ID' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD Channel_ID bigint NULL;
					EXEC sp_addextendedproperty N'MS_Description', N'Channel_ID', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'Channel_ID'
				END
END
BEGIN
		IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'UCCNo' AND Object_ID = Object_ID('ITrnSerialNo'))
				BEGIN
					ALTER TABLE ITrnSerialNo ADD UCCNo nvarchar(20) NOT NULL CONSTRAINT [DF_ITrnSerialNo_UCCNo]  DEFAULT (' ');
					EXEC sp_addextendedproperty N'MS_Description', N'UCCNo', 'SCHEMA', N'dbo', 'TABLE', N'ITrnSerialNo', 'COLUMN', N'UCCNo'
				END
END
