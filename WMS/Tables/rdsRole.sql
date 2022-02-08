CREATE TABLE [dbo].[rdsRole]
(
[RoleID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RoleDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdsRole_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsRole_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rdsRole] ADD CONSTRAINT [PK_rdsRole] PRIMARY KEY CLUSTERED ([RoleID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rdsRole] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsRole] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsRole] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsRole] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsRole', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsRole', 'COLUMN', N'AddWho'
GO
