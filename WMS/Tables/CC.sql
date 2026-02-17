SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CC]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CC](
	[CCKey] [nvarchar](10) NOT NULL,
	[Storerkey] [nvarchar](15) NOT NULL,
	[Sku] [nvarchar](20) NOT NULL,
	[Loc] [nvarchar](10) NOT NULL,
	[TaskDetailKey] [nvarchar](10) NOT NULL,
	[Status] [nvarchar](10) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[Timestamp] [timestamp] NOT NULL,
	[Facility] [nvarchar](5) NULL,
 CONSTRAINT [PKCC] PRIMARY KEY NONCLUSTERED 
(
	[CCKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CC]') AND name = N'IDX_CC_STATUS')
CREATE NONCLUSTERED INDEX [IDX_CC_STATUS] ON [dbo].[CC]
(
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CC]') AND name = N'IDX_CC_TASKDETAILKEY')
CREATE NONCLUSTERED INDEX [IDX_CC_TASKDETAILKEY] ON [dbo].[CC]
(
	[TaskDetailKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CC_StorerKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CC] ADD  CONSTRAINT [DF_CC_StorerKey]  DEFAULT (' ') FOR [Storerkey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CC_Sku]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CC] ADD  CONSTRAINT [DF_CC_Sku]  DEFAULT (' ') FOR [Sku]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CC_Loc]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CC] ADD  CONSTRAINT [DF_CC_Loc]  DEFAULT (' ') FOR [Loc]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CC_TDK]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CC] ADD  CONSTRAINT [DF_CC_TDK]  DEFAULT (' ') FOR [TaskDetailKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CC_Status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CC] ADD  CONSTRAINT [DF_CC_Status]  DEFAULT ('0') FOR [Status]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CC_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CC] ADD  CONSTRAINT [DF_CC_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CC_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CC] ADD  CONSTRAINT [DF_CC_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CC_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CC] ADD  CONSTRAINT [DF_CC_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CC_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CC] ADD  CONSTRAINT [DF_CC_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'CCKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying Cycle Count.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'CCKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'Storerkey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique key to the Storer record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'Storerkey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'Sku'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying the product.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'Sku'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'Loc'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying the physical Location in the facility.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'Loc'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'TaskDetailKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying Task Detail.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'TaskDetailKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'AddDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information added. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'AddDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'AddWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID added the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'AddWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'EditDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'EditDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'EditWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'EditWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'TrafficCop'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'TrafficCop'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'CC', N'COLUMN',N'Facility'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A building or place that provide services for effective warehouse management. Identified by unique code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CC', @level2type=N'COLUMN',@level2name=N'Facility'
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CC]') AND type in (N'U'))
   GRANT SELECT, INSERT, DELETE, UPDATE ON [dbo].[CC] TO [NSQL]
GO
IF EXISTS(SELECT TOP 1 1 FROM sys.columns where object_id=OBJECT_ID(N'[dbo].[CC]') AND name='Storerkey' AND TYPE_NAME(system_type_id)='nvarchar' AND max_length < 30)
   ALTER TABLE [dbo].[CC] ALTER COLUMN [Storerkey] [nvarchar](15) NOT NULL
GO
