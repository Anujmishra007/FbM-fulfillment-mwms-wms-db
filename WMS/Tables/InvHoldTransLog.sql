CREATE TABLE [dbo].[InvHoldTransLog]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvHoldTransLog_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvHoldTransLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_InvHoldTransLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvHoldTransLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_InvHoldTransLog_EditDate] DEFAULT (getdate()),
[Msgtext] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvHoldTransLog] ADD CONSTRAINT [PK_InvHoldTransLog] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InvHoldTransLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[InvHoldTransLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[InvHoldTransLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[InvHoldTransLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Row.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'RowID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the source.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying User.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldTransLog', 'COLUMN', N'UserID'
GO
