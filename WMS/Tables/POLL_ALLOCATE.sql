CREATE TABLE [dbo].[POLL_ALLOCATE]
(
[orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_POLL_ALLOCATE_EffectiveDate] DEFAULT (getdate()),
[RetryCount] [int] NOT NULL CONSTRAINT [DF_POLL_ALLOCATE_RetryCount] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_POLL_ALLOCATE_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_ALLOCATE_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_POLL_ALLOCATE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_ALLOCATE_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [timestamp] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[POLL_ALLOCATE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[POLL_ALLOCATE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[POLL_ALLOCATE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[POLL_ALLOCATE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POLL_ALLOCATE', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_ALLOCATE', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POLL_ALLOCATE', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_ALLOCATE', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_ALLOCATE', 'COLUMN', N'orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_ALLOCATE', 'COLUMN', N'TrafficCop'
GO
