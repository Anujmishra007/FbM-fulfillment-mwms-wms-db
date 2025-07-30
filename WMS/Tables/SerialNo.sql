IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SerialNo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SerialNo]
(
[SerialNoKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NULL CONSTRAINT [DF_SerialNo_Qty] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_SerialNo_AddDate] DEFAULT (getdate()),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SerialNo_Status] DEFAULT ('0'),
[LotNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_SerialNo_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SerialNo_EditWho] DEFAULT (suser_sname()),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERIALNO_ID] DEFAULT (''),
[ExternStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERIALNO_ExternStatus] DEFAULT ('0'),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERIALNO_PickSlipNo] DEFAULT (''),
[CartonNo] [int] NULL CONSTRAINT [DF_SERIALNO_CartonNo] DEFAULT ((0)),
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERIALNO_LabelLine] DEFAULT (''),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine05] DEFAULT (''),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UCCNo] DEFAULT ('')
) ON [PRIMARY]

GRANT DELETE ON  [dbo].[SerialNo] TO [NSQL]

GRANT INSERT ON  [dbo].[SerialNo] TO [NSQL]

GRANT SELECT ON  [dbo].[SerialNo] TO [NSQL]

GRANT UPDATE ON  [dbo].[SerialNo] TO [NSQL]


ALTER TABLE [dbo].[SerialNo] ADD CONSTRAINT [PK_SerialNo] PRIMARY KEY NONCLUSTERED ([SerialNoKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE CLUSTERED INDEX [IX_SerialNo_Orders] ON [dbo].[SerialNo] ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SerialNo_Pack] ON [dbo].[SerialNo] ([PickSlipNo], [CartonNo], [LabelLine]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_StorerKey_SerialNo] ON [dbo].[SerialNo] ([StorerKey], [SerialNo]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SerialNo_UCCNo] ON [dbo].[SerialNo] ([UCCNo], [SKU], [StorerKey]) INCLUDE ([SerialNo], [Status]) ON [PRIMARY]

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', N'Packing - Carton #', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'CartonNo'

EXEC sp_addextendedproperty N'MS_Description', N'ExternStatus', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'ExternStatus'

EXEC sp_addextendedproperty N'MS_Description', N'Packing - Label Line #', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'LabelLine'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'OrderKey'

EXEC sp_addextendedproperty N'MS_Description', N'Packing - Pick Slip #', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'PickSlipNo'

EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'Qty'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Serial Number.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'SerialNoKey'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'SKU'

EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'StorerKey'

EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'TrafficCop'

EXEC sp_addextendedproperty N'MS_Description', N'UCC No', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UCCNo'

EXEC sp_addextendedproperty N'MS_Description', 'User define 01', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine01'

EXEC sp_addextendedproperty N'MS_Description', 'User define 02', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine02'

EXEC sp_addextendedproperty N'MS_Description', 'User define 03', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine03'

EXEC sp_addextendedproperty N'MS_Description', 'User define 04', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine04'

EXEC sp_addextendedproperty N'MS_Description', 'User define 05', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine05'

END

ELSE
BEGIN

--ALTER COLUMN 
IF EXISTS (SELECT * FROM SYS.COLUMNS WHERE name = 'SerialNo' AND Object_ID = Object_ID('[dbo].[SerialNo]') AND max_length <> 100)
BEGIN
	ALTER TABLE [dbo].[SerialNo]
	ALTER COLUMN [SerialNo] [nvarchar](50) NOT NULL;

END


END