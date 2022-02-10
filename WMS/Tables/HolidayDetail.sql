CREATE TABLE [dbo].[HolidayDetail]
(
[HolidayKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HolidayDate] [datetime] NOT NULL,
[HolidayDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [datetime] NULL,
[UserDefine05] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HolidayDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_HolidayDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HolidayDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_HolidayDetail_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[HolidayDetail] ADD CONSTRAINT [PK_HolidayDetail] PRIMARY KEY CLUSTERED ([HolidayKey], [HolidayDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HolidayDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[HolidayDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[HolidayDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[HolidayDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Individual date that is a holiday', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'HolidayDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the holiday e.g. National Day or Christmas etc', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'HolidayDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Holiday.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'HolidayKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine01', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine02', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine03', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine04', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine05', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine05'
GO
