CREATE TABLE [dbo].[POLL_UPDATE]
(
[PollUpdateKey] [int] NOT NULL IDENTITY(1, 1),
[UpdateString] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_UPDATE_UpdateString] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_UPDATE_Status] DEFAULT ('0'),
[RetryCount] [int] NOT NULL CONSTRAINT [DF_POLL_UPDATE_RetryCount] DEFAULT ((0)),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_POLL_UPDATE_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_POLL_UPDATE_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_UPDATE_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_POLL_UPDATE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_POLL_UPDATE_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[POLL_UPDATE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[POLL_UPDATE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[POLL_UPDATE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[POLL_UPDATE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POLL_UPDATE', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_UPDATE', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'POLL_UPDATE', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_UPDATE', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Poll Update.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_UPDATE', 'COLUMN', N'PollUpdateKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'POLL_UPDATE', 'COLUMN', N'TrafficCop'
GO
