CREATE TABLE [dbo].[ControlTable]
(
[type] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ControlTable_type] DEFAULT ('I'),
[filename] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ControlTable_filename] DEFAULT (' '),
[trandate] [datetime] NOT NULL CONSTRAINT [DF_ControlTable_trandate] DEFAULT (getdate()),
[rec_upload] [int] NOT NULL CONSTRAINT [DF_ControlTable_rec_upload] DEFAULT ((0)),
[rec_posted] [int] NOT NULL CONSTRAINT [DF_ControlTable_rec_posted] DEFAULT ((0)),
[totalqty] [int] NOT NULL CONSTRAINT [DF_ControlTable_totalqty] DEFAULT ((0)),
[addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ControlTable_addwho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_ControlTable_Idx] ON [dbo].[ControlTable] ([type], [filename]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ControlTable] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ControlTable] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ControlTable] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ControlTable] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ControlTable', 'COLUMN', N'addwho'
GO
