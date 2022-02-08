CREATE TABLE [dbo].[BUILDPARMDETAIL]
(
[BuildParmKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMDETAIL_BuildParmKey] DEFAULT (''),
[BuildParmLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMDETAIL_BuildParmLineNo] DEFAULT (''),
[Description] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMDETAIL_Description] DEFAULT (''),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMDETAIL_Type] DEFAULT (''),
[ConditionLevel] [int] NULL CONSTRAINT [DF_BUILDPARMDETAIL_ConditionLevel] DEFAULT ((0)),
[FieldName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARMDETAIL_FieldName] DEFAULT (''),
[OrAnd] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARMDETAIL_OrAnd] DEFAULT (''),
[Operator] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARMDETAIL_Operator] DEFAULT (''),
[Value] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARMDETAIL_Value] DEFAULT (''),
[UDF01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARMDETAIL_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARMDETAIL_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARMDETAIL_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARMDETAIL_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARMDETAIL_UDF05] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMDETAIL_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDPARMDETAIL_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMDETAIL_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDPARMDETAIL_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuildValue] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMDETAIL_BuildValue] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUILDPARMDETAIL] ADD CONSTRAINT [PK_BUILDPARMDETAIL] PRIMARY KEY CLUSTERED ([BuildParmKey], [BuildParmLineNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BUILDPARMDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BUILDPARMDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BUILDPARMDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BUILDPARMDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter Detail', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter key', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'BuildParmKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter Line #', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'BuildParmLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ReleaseValue', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'BuildValue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Condition Level', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'ConditionLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Criteria Description', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Column Name', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'FieldName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Operator', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'Operator'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Or / And', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'OrAnd'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 1', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 2', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 3', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 4', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 5', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'UDF05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMDETAIL', 'COLUMN', N'Value'
GO
