CREATE TABLE [dbo].[EXCEPTIONHANDLING]
(
[RowRef] [bigint] NOT NULL CONSTRAINT [DF_EXCEPTIONHANDLING_RowRef] DEFAULT ((0)),
[Sourcekey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EXCEPTIONHANDLING_Sourcekey] DEFAULT (''),
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EXCEPTIONHANDLING_SourceType] DEFAULT (''),
[ModuleType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EXCEPTIONHANDLING_ModuleType] DEFAULT ('PACK'),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_Storerkey] DEFAULT (''),
[ExceptionCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_ExceptionCode] DEFAULT (''),
[ExceptionMsg] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_ExceptionMsg] DEFAULT (''),
[ProcessMsg] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_ProcessMsg] DEFAULT (''),
[ProcessWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_ProcessWho] DEFAULT (''),
[ProcessDate] [datetime] NULL CONSTRAINT [DF_EXCEPTIONHANDLING_ProcessDate] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EXCEPTIONHANDLING_Status] DEFAULT ('0'),
[UDF01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_UDF05] DEFAULT (''),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_EXCEPTIONHANDLING_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXCEPTIONHANDLING_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_EXCEPTIONHANDLING_Editdate] DEFAULT (getdate()),
[Trafficcop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EXCEPTIONHANDLING] ADD CONSTRAINT [PK_EXCEPTIONHANDLING] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EXCEPTIONHANDLING] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[EXCEPTIONHANDLING] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[EXCEPTIONHANDLING] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[EXCEPTIONHANDLING] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Exception Handling', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created On Date', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created by', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archivecop', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Archivecop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits on', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits by', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Exception Code; from codelkup', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'ExceptionCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Exception Message', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'ExceptionMsg'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Module type; PACK, ORDER', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'ModuleType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Process On Date', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'ProcessDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Process Message', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'ProcessMsg'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Process by', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'ProcessWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Row Reference', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source key', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Sourcekey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source type; ASN,ORD,ADJ,TRF,IQC,MV, WO', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'SourceType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trafficcop', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'Trafficcop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefined 1', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefined 2', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefined 3', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefined 4', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefined 5', 'SCHEMA', N'dbo', 'TABLE', N'EXCEPTIONHANDLING', 'COLUMN', N'UDF05'
GO
