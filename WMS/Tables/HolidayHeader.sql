CREATE TABLE [dbo].[HolidayHeader]
(
[HolidayKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HolidayDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [datetime] NULL,
[UserDefine05] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HolidayHeader_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_HolidayHeader_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HolidayHeader_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_HolidayHeader_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[HolidayHeader] ADD CONSTRAINT [PK_HolidayHeader] PRIMARY KEY CLUSTERED ([HolidayKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HolidayHeader] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[HolidayHeader] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[HolidayHeader] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[HolidayHeader] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the holiday code e.g. Malaysia Holidays', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'HolidayDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the collection of holidays', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'HolidayKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine01', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine02', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine03', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine04', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine05', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine05'
GO
