CREATE TABLE [dbo].[OrderSelectionCondition]
(
[OrderSelectionKey] [nvarchar] (10) NOT NULL,
[OrderSelectionLineNumber] [nvarchar] (5) NOT NULL,
[Description] [nvarchar] (250) NULL,
[Type] [nvarchar] (10) NULL,
[ConditionGroup] [nvarchar] (10) NULL,
[OperatorAndOr] [nvarchar] (10) NULL,
[FieldName] [nvarchar] (50) NULL,
[Operator] [nvarchar] (10) NULL,
[Value] [nvarchar] (4000) NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderSelectionCondition] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OrderSelectionCondition] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OrderSelectionCondition] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OrderSelectionCondition] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Build wave criteria additional condition definable by user', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Grouping of condition', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', 'COLUMN', N'ConditionGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of condition', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Field name', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', 'COLUMN', N'FieldName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Condition operator', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', 'COLUMN', N'Operator'
GO
EXEC sp_addextendedproperty N'MS_Description', 'AND OR Operator', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', 'COLUMN', N'OperatorAndOr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order Selection Primary Key', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', 'COLUMN', N'OrderSelectionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order Selection Line Number', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', 'COLUMN', N'OrderSelectionLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of condition', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Condition value', 'SCHEMA', N'dbo', 'TABLE', N'OrderSelectionCondition', 'COLUMN', N'Value'
GO
