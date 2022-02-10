CREATE TABLE [dbo].[MBOLShipLog]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MBOLShipLog] ADD CONSTRAINT [PKMBOLShipLog] PRIMARY KEY CLUSTERED ([MBOLKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MBOLShipLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MBOLShipLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MBOLShipLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MBOLShipLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLShipLog', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLShipLog', 'COLUMN', N'StorerKey'
GO
