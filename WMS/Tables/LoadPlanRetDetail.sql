CREATE TABLE [dbo].[LoadPlanRetDetail]
(
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternReceiptKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanRetDetail_addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LoadPlanRetDetail_adddate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanRetDetail_editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LoadPlanRetDetail_editdate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [float] NOT NULL CONSTRAINT [DF_LoadPlanRetDetail_Weight] DEFAULT ((0.0)),
[Cube] [float] NOT NULL CONSTRAINT [DF_LoadPlanRetDetail_Cube] DEFAULT ((0.0)),
[ExternLoadKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanRetDetail_ExternLoadKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanRetDetail_ExternLineNo] DEFAULT (' ')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[LoadPlanRetDetail] ADD CONSTRAINT [PK_LoadPlanRetDetail] PRIMARY KEY CLUSTERED ([LoadKey], [LoadLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LoadPlanRetDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LoadPlanRetDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LoadPlanRetDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LoadPlanRetDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'ExternLoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Receipt used by Storer.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'ExternReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Receipt.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'ReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanRetDetail', 'COLUMN', N'TrafficCop'
GO
