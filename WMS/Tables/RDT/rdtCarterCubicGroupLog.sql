CREATE TABLE [RDT].[rdtCarterCubicGroupLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCarterCubicGroupLog_CartonGroup] DEFAULT (''),
[BUSR3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCarterCubicGroupLog_BUSR3] DEFAULT (''),
[Style] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCarterCubicGroupLog_Style] DEFAULT (''),
[Size] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCarterCubicGroupLog_Size] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCarterCubicGroupLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtCarterCubicGroupLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtCarterCubicGroupLog] ADD CONSTRAINT [PK_rdtCarterCubicGroupLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtCarterCubicGroupLog_CartonGroup_BUSR3_Style_Size] ON [RDT].[rdtCarterCubicGroupLog] ([CartonGroup], [BUSR3], [Style], [Size]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtCarterCubicGroupLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtCarterCubicGroupLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtCarterCubicGroupLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtCarterCubicGroupLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Table to keep track which type of SKU had done cubic scan.', 'SCHEMA', N'RDT', 'TABLE', N'rdtCarterCubicGroupLog', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'BUSR3', 'SCHEMA', N'RDT', 'TABLE', N'rdtCarterCubicGroupLog', 'COLUMN', N'BUSR3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'CartonGroup', 'SCHEMA', N'RDT', 'TABLE', N'rdtCarterCubicGroupLog', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Size', 'SCHEMA', N'RDT', 'TABLE', N'rdtCarterCubicGroupLog', 'COLUMN', N'Size'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Style', 'SCHEMA', N'RDT', 'TABLE', N'rdtCarterCubicGroupLog', 'COLUMN', N'Style'
GO
