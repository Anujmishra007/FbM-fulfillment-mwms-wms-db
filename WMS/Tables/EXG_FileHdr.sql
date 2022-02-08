CREATE TABLE [dbo].[EXG_FileHdr]
(
[file_key] [int] NOT NULL IDENTITY(1, 1),
[EXG_Hdr_ID] [int] NOT NULL,
[TargetFolder] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_TargetFolder] DEFAULT (''),
[filename] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_filename] DEFAULT (''),
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EXG_FileHdr_status] DEFAULT ((0)),
[try] [int] NOT NULL CONSTRAINT [DF_EXG_FileHdr_try] DEFAULT ((0)),
[ParamVal1] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal1] DEFAULT (''),
[ParamVal2] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal2] DEFAULT (''),
[ParamVal3] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal3] DEFAULT (''),
[ParamVal4] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal4] DEFAULT (''),
[ParamVal5] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal5] DEFAULT (''),
[ParamVal6] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal6] DEFAULT (''),
[ParamVal7] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal7] DEFAULT (''),
[ParamVal8] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal8] DEFAULT (''),
[ParamVal9] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal9] DEFAULT (''),
[ParamVal10] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_ParamVal10] DEFAULT (''),
[Delimiter] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RetryFlag] [bit] NULL CONSTRAINT [DF_EXG_FileHdr_RetryFlag] DEFAULT ((0)),
[AddWho] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_EXG_FileHdr_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXG_FileHdr_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_EXG_FileHdr_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EXG_FileHdr] ADD CONSTRAINT [PK_EXG_FileHdr] PRIMARY KEY CLUSTERED ([file_key]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EXG_FileHdr] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[EXG_FileHdr] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[EXG_FileHdr] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[EXG_FileHdr] TO [NSQL]
GO
EXEC sp_addextendedproperty N'AddDate', N'first date for this new records', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'AddWho', N'first person who add this new records', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'Delimiter', N'Used to split the each columns in LineText1 and LineText2 in EXG_FileDet ', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'Delimiter'
GO
EXEC sp_addextendedproperty N'EditDate', N'Edit date for the next updates', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'EditWho', N'Who edit this records', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'EXG_Hdr_ID', N'Primary key in GTApps.dbo.EXG_Hdr Table', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'EXG_Hdr_ID'
GO
EXEC sp_addextendedproperty N'file_key', N'Primary file key for EXG_File Hdr. Foreign key for EXG_FileDet', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'file_key'
GO
EXEC sp_addextendedproperty N'filename', N'Excel file name', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'filename'
GO
EXEC sp_addextendedproperty N'ParamVal1', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal1'
GO
EXEC sp_addextendedproperty N'ParamVal10', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal10'
GO
EXEC sp_addextendedproperty N'ParamVal2', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal2'
GO
EXEC sp_addextendedproperty N'ParamVal3', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal3'
GO
EXEC sp_addextendedproperty N'ParamVal4', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal4'
GO
EXEC sp_addextendedproperty N'ParamVal5', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal5'
GO
EXEC sp_addextendedproperty N'ParamVal6', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal6'
GO
EXEC sp_addextendedproperty N'ParamVal7', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal7'
GO
EXEC sp_addextendedproperty N'ParamVal8', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal8'
GO
EXEC sp_addextendedproperty N'ParamVal9', N'Filter parameter value for Excel Generator', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'ParamVal9'
GO
EXEC sp_addextendedproperty N'RetryFlag', N'Retry config on or off. On, will auto retry. Off, do nothing', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'RetryFlag'
GO
EXEC sp_addextendedproperty N'status', N'EXG_FileHdr status flag W,0,5,9. ', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'status'
GO
EXEC sp_addextendedproperty N'TargetFolder', N'Excel Generate path location', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'TargetFolder'
GO
EXEC sp_addextendedproperty N'try', N'EXG_FileHdr try count.', 'SCHEMA', N'dbo', 'TABLE', N'EXG_FileHdr', 'COLUMN', N'try'
GO
