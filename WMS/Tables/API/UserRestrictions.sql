CREATE TABLE [API].[UserRestrictions]
(
[RowRefNo] [int] NOT NULL IDENTITY(1, 1),
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserRestrictions_UserName] DEFAULT (''),
[Restrictions] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UserRestrictions_Restrictions] DEFAULT (''),
[Value] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserRestrictions_Value] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserRestrictions_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_UserRestrictions_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserRestrictions_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_UserRestrictions_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [API].[UserRestrictions] ADD CONSTRAINT [PK_OMS.UserRestrictions] PRIMARY KEY CLUSTERED ([RowRefNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [API].[UserRestrictions] TO [NSQL]
GO
GRANT INSERT ON  [API].[UserRestrictions] TO [NSQL]
GO
GRANT SELECT ON  [API].[UserRestrictions] TO [NSQL]
GO
GRANT UPDATE ON  [API].[UserRestrictions] TO [NSQL]
GO
