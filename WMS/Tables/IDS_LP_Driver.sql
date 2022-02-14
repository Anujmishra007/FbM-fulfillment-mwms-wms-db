CREATE TABLE [dbo].[IDS_LP_Driver]
(
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Linenumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_LP_Driver_Linenumber] DEFAULT (' '),
[EditDate] [datetime] NULL CONSTRAINT [DF_IDS_LP_DRIVER_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IDS_LP_DRIVER_EditWho] DEFAULT (suser_sname()),
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_LP_DRIVER_MBOLKEY] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[IDS_LP_Driver] ADD CONSTRAINT [PK_IDS_LP_Driver] PRIMARY KEY CLUSTERED ([Loadkey], [DriverCode], [MBOLKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[IDS_LP_Driver] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[IDS_LP_Driver] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_LP_Driver] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_LP_Driver] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_LP_Driver] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying driver.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_LP_Driver', 'COLUMN', N'DriverCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_LP_Driver', 'COLUMN', N'Loadkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'MBOL Number', 'SCHEMA', N'dbo', 'TABLE', N'IDS_LP_Driver', 'COLUMN', N'MBOLKey'
GO
