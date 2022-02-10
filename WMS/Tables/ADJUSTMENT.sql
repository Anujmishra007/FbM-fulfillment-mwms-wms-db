CREATE TABLE [dbo].[ADJUSTMENT]
(
[AdjustmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENT_StorerKey] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_ADJUSTMENT_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ADJUSTMENT_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENT_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ADJUSTMENT_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENT_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerRefNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdjustmentType] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remarks] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromToWhse] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrintFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_PrintFlag] DEFAULT ('N'),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_UserDefine10] DEFAULT (' '),
[FinalizedFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_FinalizedFlag] DEFAULT ('N'),
[DocType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENT_DocType] DEFAULT ('A')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ADJUSTMENT] ADD CONSTRAINT [PKADJUSTMENT] PRIMARY KEY CLUSTERED ([AdjustmentKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[ADJUSTMENT] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[ADJUSTMENT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ADJUSTMENT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ADJUSTMENT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ADJUSTMENT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Adjustment is a transaction that allows authorized personnel to change the current system stock level so that it agrees with the amount of stock that is ôphysicallyö there. Exceed provides the capability to create an adjustment ticket that can contain any number of adjustments. Adjustments are documents, like ASN and PO. The document leaves an audit trail of information related to the adjustment(s). An inventory transaction of type ôAdjustmentö is also created.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the adjustment ticket (system generated number)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'AdjustmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'type of adjustment', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'AdjustmentType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'customer''s reference number', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'CustomerRefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'document type', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'DocType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the date on which the adjustment should take place', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'facility code', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'to confirm the adjustment.  Upon finalization, the stock is either increased (positive adjustment) or decreased (negative adjustment).', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'FinalizedFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Logical warehouse code (LOGICALWH)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'FromToWhse'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This command sets the flag which controls the amount of output.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'PrintFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'any remarks / notes', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'owner of the goods', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'TimeStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine06', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine07', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENT', 'COLUMN', N'UserDefine10'
GO
