CREATE TABLE [dbo].[rdsGrantedStorer]
(
[UserId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdsGrantedStorer_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsGrantedStorer_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rdsGrantedStorer] ADD CONSTRAINT [PK_lrdsGrantedStorer] PRIMARY KEY CLUSTERED ([UserId], [StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rdsGrantedStorer] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsGrantedStorer] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsGrantedStorer] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsGrantedStorer] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsGrantedStorer', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsGrantedStorer', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'rdsGrantedStorer', 'COLUMN', N'StorerKey'
GO
