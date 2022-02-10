CREATE TABLE [dbo].[TraceTM]
(
[Seqno] [int] NOT NULL IDENTITY(1, 1),
[SP] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TraceTM] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TraceTM] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TraceTM] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TraceTM] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TraceTM', 'COLUMN', N'AddDate'
GO
