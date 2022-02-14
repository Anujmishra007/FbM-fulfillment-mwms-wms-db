CREATE TABLE [dbo].[CARTONIZATION]
(
[CartonizationKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonizationGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_CartonizationGroup] DEFAULT (' '),
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_CartonType] DEFAULT (' '),
[CartonDescription] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_CartonDescription] DEFAULT (' '),
[UseSequence] [int] NOT NULL CONSTRAINT [DF_CARTONIZATION_UseSequence] DEFAULT ((1)),
[Cube] [float] NOT NULL CONSTRAINT [DF_CARTONIZATION_Cube] DEFAULT ((0)),
[MaxWeight] [float] NOT NULL CONSTRAINT [DF_CARTONIZATION_MaxWeight] DEFAULT ((0)),
[MaxCount] [int] NOT NULL CONSTRAINT [DF_CARTONIZATION_MaxCount] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CARTONIZATION_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CARTONIZATION_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[CartonWeight] [float] NULL CONSTRAINT [DF_CARTONIZATION_CartonWeight] DEFAULT ((0)),
[CartonLength] [float] NULL CONSTRAINT [DF_CARTONIZATION_CartonLength] DEFAULT ((0)),
[CartonWidth] [float] NULL CONSTRAINT [DF_CARTONIZATION_CartonWidth] DEFAULT ((0)),
[CartonHeight] [float] NULL CONSTRAINT [DF_CARTONIZATION_CartonHeight] DEFAULT ((0)),
[Barcode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Cartonization_Barcode] DEFAULT (''),
[FillTolerance] [int] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CARTONIZATION] ADD CONSTRAINT [PKCartonization] PRIMARY KEY CLUSTERED ([CartonizationKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Cartonization_01] ON [dbo].[CARTONIZATION] ([CartonizationGroup], [CartonType], [UseSequence]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CARTONIZATION] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CARTONIZATION] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CARTONIZATION] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CARTONIZATION] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CARTONIZATION] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cartonization allows users to coordinate all inventories loaded into a carton, whether the carton is a box or an ocean going container.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Detail information regarding the carton', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Height of carton.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonHeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cartonization group name', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonizationGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique key assigned by WMS to identify the carton', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonizationKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Length of carton.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonLength'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A descriptive name of the type or size of carton used, such as small or medium', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Weight', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Width of carton.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonWidth'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a commodity the carton can hold', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The maximum quantity of the Master Unit of Measure the carton can hold', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'MaxCount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The maximum gross weight the carton can hold', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'MaxWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A number that corresponds with the carton''s priority.   Use sequence is used to record the order in which a carton   should be selected within the cartonization group.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'UseSequence'
GO
