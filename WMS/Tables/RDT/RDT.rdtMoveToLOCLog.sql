CREATE TABLE [RDT].[rdtMoveToLOCLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[FromLOC] [nvarchar] (10) NOT NULL,
[FromID] [nvarchar] (18) NOT NULL,
[StorerKey] [nvarchar] (15) NOT NULL,
[SKU] [nvarchar] (20) NOT NULL,
[QTY] [int] NOT NULL,
[ToLOC] [nvarchar] (10) NOT NULL,
[ToID] [nvarchar] (18) NOT NULL,
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtMoveToLOCLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtMoveToLOCLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtMoveToLOCLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtMoveToLOCLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtMoveToLOCLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtMoveToLOCLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Temporary table use by RDT Move To LOC (FN617)', 'SCHEMA', N'RDT', 'TABLE', N'rdtMoveToLOCLog', NULL, NULL
GO
