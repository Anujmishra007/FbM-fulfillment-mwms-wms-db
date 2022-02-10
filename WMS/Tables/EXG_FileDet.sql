CREATE TABLE [dbo].[EXG_FileDet]
(
[file_key] [int] NOT NULL,
[SeqNo] [int] NOT NULL IDENTITY(1, 1),
[EXG_Hdr_ID] [int] NOT NULL,
[FileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileDet_FileName] DEFAULT (''),
[SheetName] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileDet_SheetName] DEFAULT (''),
[Status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EXG_FileDet_Status] DEFAULT ('0'),
[LineText1] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileDet_LineText1] DEFAULT (''),
[LineText2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileDet_LineText2] DEFAULT (''),
[ErrMsg] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileDet_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_EXG_FileDet_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileDet_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_EXG_FileDet_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EXG_FileDet] ADD CONSTRAINT [PK_EXG_FileDet] PRIMARY KEY CLUSTERED ([file_key], [SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EXG_FileDet] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[EXG_FileDet] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[EXG_FileDet] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[EXG_FileDet] TO [NSQL]
GO
EXEC sp_addextendedproperty N'AddDate', N'first date for this new records', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'AddWho', N'first person who add this new records', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'EditDate', N'Edit date for the next updates', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'EditWho', N'Who edit this records', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'ErrMsg', N'Error Message for this record.', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'ErrMsg'
GO
EXEC sp_addextendedproperty N'EXG_Hdr_ID', N'Primary key in GTApps.dbo.EXG_Hdr Table', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'EXG_Hdr_ID'
GO
EXEC sp_addextendedproperty N'file_key', N'Primary file key for EXG_File Hdr. Foreign key for EXG_FileDet', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'file_key'
GO
EXEC sp_addextendedproperty N'FileName', N'Excel file name', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'FileName'
GO
EXEC sp_addextendedproperty N'LineText1', N'Excel whole line content split by delimiter', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'LineText1'
GO
EXEC sp_addextendedproperty N'LineText2', N'Excel whole line content split by delimiter', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'LineText2'
GO
EXEC sp_addextendedproperty N'SeqNo', N'Incremental Sequence No.', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'SeqNo'
GO
EXEC sp_addextendedproperty N'SheetName', N'Excel Sheet Name', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'SheetName'
GO
EXEC sp_addextendedproperty N'Status', N'EXG_FileDet status. Flag W,0,5,9', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileDet', 'COLUMN', N'Status'
GO
