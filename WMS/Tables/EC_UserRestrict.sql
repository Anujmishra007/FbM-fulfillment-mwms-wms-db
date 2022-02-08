CREATE TABLE [dbo].[EC_UserRestrict]
(
[UserName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EC_UserRestrict_Type] DEFAULT (''),
[Value] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_EC_UserRestrict_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_UserRestrict_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EC_UserRestrict] ADD CONSTRAINT [PK_EC_UserRestrict] PRIMARY KEY CLUSTERED ([UserName], [Type], [Value]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EC_UserRestrict] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[EC_UserRestrict] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[EC_UserRestrict] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[EC_UserRestrict] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'EC_UserRestrict', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'EC_UserRestrict', 'COLUMN', N'AddWho'
GO
