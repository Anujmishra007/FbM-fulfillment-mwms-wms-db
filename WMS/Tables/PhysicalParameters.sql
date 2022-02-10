CREATE TABLE [dbo].[PhysicalParameters]
(
[PhysicalParmKey] [int] NOT NULL CONSTRAINT [DF_PhysicalParameters_PhysicalParmKey] DEFAULT (' '),
[StorerKeyMin] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PhysicalParameters_StorerKeyMin] DEFAULT (' '),
[StorerKeyMax] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PhysicalParameters_StorerKeyMax] DEFAULT (' '),
[SkuMin] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PhysicalParameters_SkuMin] DEFAULT (' '),
[SkuMax] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PhysicalParameters_SkuMax] DEFAULT (' ')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PhysicalParameters] ADD CONSTRAINT [PKPhysicalParameters] PRIMARY KEY NONCLUSTERED ([PhysicalParmKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PhysicalParameters] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PhysicalParameters] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PhysicalParameters] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PhysicalParameters] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Physical Parameter.', 'SCHEMA', N'dbo', 'TABLE', N'PhysicalParameters', 'COLUMN', N'PhysicalParmKey'
GO
