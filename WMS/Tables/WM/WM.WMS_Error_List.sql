CREATE TABLE [WM].[WMS_Error_List]
(
[RowRefNo] [bigint] NOT NULL IDENTITY(1, 1),
[ErrGroupKey] [int] NOT NULL CONSTRAINT [DF_WMS_Error_List_ErrGroupKey] DEFAULT ((0)),
[TableName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMS_Error_List_TableName] DEFAULT (''),
[SourceType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMS_Error_List_SourceType] DEFAULT (''),
[RefKey1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMS_Error_List_RefKey1] DEFAULT (''),
[RefKey2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMS_Error_List_RefKey2] DEFAULT (''),
[RefKey3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMS_Error_List_RefKey3] DEFAULT (''),
[LogWarningNo] [int] NOT NULL CONSTRAINT [DF_WMS_Error_List_LogWarningNo] DEFAULT (''),
[WriteType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMS_Error_List_WriteType] DEFAULT ('ERROR'),
[ErrCode] [int] NOT NULL CONSTRAINT [DF_WMS_Error_List_ErrCode] DEFAULT (''),
[ErrMsg] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WMS_Error_List_ErrMsg] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [WM].[WMS_Error_List] ADD CONSTRAINT [PK_WMS_Error_List] PRIMARY KEY CLUSTERED ([RowRefNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [WM].[WMS_Error_List] TO [NSQL]
GO
GRANT INSERT ON  [WM].[WMS_Error_List] TO [NSQL]
GO
GRANT SELECT ON  [WM].[WMS_Error_List] TO [NSQL]
GO
GRANT UPDATE ON  [WM].[WMS_Error_List] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'WM WMS_Error_List table', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Error Code', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'ErrCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Error Group Key.', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'ErrGroupKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Error Message', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'ErrMsg'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Warning No to be return to SCE for reference', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'LogWarningNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reference Key 1.', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'RefKey1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reference Key 2.', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'RefKey2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reference Key 3.', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'RefKey3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Row Reference #.', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'RowRefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source Type - SP Name.', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'SourceType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Table Name.', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'TableName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Write Type - Error, Warning or Question', 'SCHEMA', N'WM', 'TABLE', N'WMS_Error_List', 'COLUMN', N'WriteType'
GO
