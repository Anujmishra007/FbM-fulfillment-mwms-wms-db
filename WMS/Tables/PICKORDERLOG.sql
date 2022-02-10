CREATE TABLE [dbo].[PICKORDERLOG]
(
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SPID] [int] NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKORDERLOG_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PICKORDERLOG] ADD CONSTRAINT [PK_PICKORDERLOG] PRIMARY KEY CLUSTERED ([Orderkey], [Zone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PICKORDERLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PICKORDERLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PICKORDERLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PICKORDERLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKORDERLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'PICKORDERLOG', 'COLUMN', N'Orderkey'
GO
