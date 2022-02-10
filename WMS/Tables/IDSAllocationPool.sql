CREATE TABLE [dbo].[IDSAllocationPool]
(
[AllocPoolId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_IDSAllocationPool_AllocPoolId] DEFAULT (newid()),
[SourceKey] [nvarchar] (15) NOT NULL,
[WinUserLogin] [nvarchar] (18) NOT NULL CONSTRAINT [DF_IDSAllocationPool_WinUserLogin] DEFAULT (' '),
[WinComputerName] [nvarchar] (18) NOT NULL,
[Priority] [int] NOT NULL CONSTRAINT [DF_IDSAllocationPool_Priority] DEFAULT ((9)),
[Status] [nvarchar] (5) NOT NULL CONSTRAINT [DF_IDSAllocationPool_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_IDSAllocationPool_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_IDSAllocationPool_AddWho] DEFAULT (suser_sname()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_IDSAllocationPool_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_IDSAllocationPool_EditDate] DEFAULT (getdate()),
[SourceType] [nvarchar] (10) NULL CONSTRAINT [DF_IDSAllocationPool_SourceType] DEFAULT ('L'),
[Remarks] [nvarchar] (60) NULL,
[MsgText] [nvarchar] (215) NULL,
[ExtendParms] [nvarchar] (250) NULL,
[Wavekey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_IDSAllocationPool_Wavekey] DEFAULT (''),
[AllocateCmd] [nvarchar] (1024) NOT NULL CONSTRAINT [DF_IDSAllocationPool_AllocateCmd] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[IDSAllocationPool] ADD CONSTRAINT [PK_IDSAllocationPool] PRIMARY KEY CLUSTERED ([AllocPoolId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDSAllocationPool] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDSAllocationPool] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDSAllocationPool] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDSAllocationPool] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Allocate Command', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'AllocateCmd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying IDS Allocation Pool.', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'AllocPoolId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'sourcekey', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Wavekey', 'SCHEMA', N'dbo', 'TABLE', N'IDSAllocationPool', 'COLUMN', N'Wavekey'
GO
