CREATE TABLE [dbo].[PalletLabel]
(
[PLID] [int] NOT NULL IDENTITY(1, 1),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Tablename] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletLabel_Tablename] DEFAULT (''),
[HDKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletLabel_HDKey] DEFAULT (''),
[DTKey] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletLabel_DTKey] DEFAULT (''),
[PrintFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletLabel_PrintFlag] DEFAULT ('Y'),
[PhotoFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletLabel_PhotoFlag] DEFAULT ('Y'),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletLabel_Status] DEFAULT ('0'),
[Parm1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parm2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parm3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parm4] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parm5] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parm6] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parm7] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parm8] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parm9] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parm10] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PalletLabel_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletLabel_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PalletLabel_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletLabel_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PalletLabel] ADD CONSTRAINT [PK_PalletLabel] PRIMARY KEY CLUSTERED ([PLID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PalletLabel_ID] ON [dbo].[PalletLabel] ([ID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PalletLabel] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PalletLabel] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PalletLabel] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PalletLabel] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Label (Project Merlion) #315821 http://sos.lfapps.net/bt/form1/TicketView.htx?TICKET_ID=315821', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Detail key (ReceiptLineNumber, WorkOrderLineNumber)', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'DTKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Header key (Eg ReceiptKey, WorkOrderKey, JobOrderkey)', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'HDKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet ID / Movable Unit where the Commodity will be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UDF field, bartender printing parameter', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Parm9'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Photo Flag = Y or N to indicate whether to capture photo or not', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'PhotoFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Identifier of the Pallet Label', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'PLID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Print Flag = Y or N to indicate whether to print or not', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'PrintFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status from 0 - 9 to indicate status of label printing.', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tablename which the HDKey and DTKey ref to (Eg Receipt)', 'SCHEMA', N'dbo', 'TABLE', N'PalletLabel', 'COLUMN', N'Tablename'
GO
