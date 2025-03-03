SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkOrder]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[WorkOrder](
	[WorkOrderKey] [nvarchar](10) NOT NULL,
	[ExternWorkOrderKey] [nvarchar](20) NULL,
	[StorerKey] [nvarchar](15) NOT NULL,
	[Facility] [nvarchar](5) NOT NULL,
	[Status] [nvarchar](10) NULL,
	[ExternStatus] [nvarchar](10) NULL,
	[Type] [nvarchar](12) NOT NULL,
	[Reason] [nvarchar](10) NOT NULL,
	[TotalPrice] [money] NULL,
	[GenerateCharges] [nvarchar](10) NOT NULL,
	[Remarks] [nvarchar](215) NULL,
	[Notes1] [nvarchar](215) NULL,
	[Notes2] [nvarchar](215) NULL,
	[WkOrdUdef1] [nvarchar](50) NULL,
	[WkOrdUdef2] [nvarchar](18) NULL,
	[WkOrdUdef3] [nvarchar](18) NULL,
	[WkOrdUdef4] [nvarchar](18) NULL,
	[WkOrdUdef5] [nvarchar](18) NULL,
	[AddDate] [datetime] NULL,
	[AddWho] [nvarchar](128) NULL,
	[EditDate] [datetime] NULL,
	[EditWho] [nvarchar](128) NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[WkOrdUdef6] [datetime] NULL,
	[WkOrdUdef7] [datetime] NULL,
	[WkOrdUdef8] [nvarchar](50) NULL,
	[WkOrdUdef9] [nvarchar](30) NULL,
	[WkOrdUdef10] [nvarchar](30) NULL,
 CONSTRAINT [PK_WorkOrder] PRIMARY KEY CLUSTERED 
(
	[WorkOrderKey] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[WorkOrder]') AND name = N'IX_WORKORDER_ExternWorkOrdKey')
CREATE NONCLUSTERED INDEX [IX_WORKORDER_ExternWorkOrdKey] ON [dbo].[WorkOrder]
(
	[ExternWorkOrderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_WorkOrderKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_WorkOrderKey]  DEFAULT (' ') FOR [WorkOrderKey]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_ExternWorkOrderKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_ExternWorkOrderKey]  DEFAULT (' ') FOR [ExternWorkOrderKey]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_StorerKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_StorerKey]  DEFAULT (' ') FOR [StorerKey]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_Facility]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_Facility]  DEFAULT (' ') FOR [Facility]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_Status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_Status]  DEFAULT ('0') FOR [Status]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_ExternStatus]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_ExternStatus]  DEFAULT ('0') FOR [ExternStatus]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_Type]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_Type]  DEFAULT (' ') FOR [Type]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_Reason]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_Reason]  DEFAULT (' ') FOR [Reason]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_TotalPrice]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_TotalPrice]  DEFAULT ((0)) FOR [TotalPrice]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_GenerateCharges]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_GenerateCharges]  DEFAULT ('No') FOR [GenerateCharges]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_Remarks]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_Remarks]  DEFAULT (' ') FOR [Remarks]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_Notes1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_Notes1]  DEFAULT (' ') FOR [Notes1]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_Notes2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_Notes2]  DEFAULT (' ') FOR [Notes2]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_OvasUdef1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_OvasUdef1]  DEFAULT (' ') FOR [WkOrdUdef1]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_OvasUdef2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_OvasUdef2]  DEFAULT (' ') FOR [WkOrdUdef2]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_OvasUdef3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_OvasUdef3]  DEFAULT (' ') FOR [WkOrdUdef3]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_OvasUdef4]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_OvasUdef4]  DEFAULT (' ') FOR [WkOrdUdef4]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_OvasUdef5]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_OvasUdef5]  DEFAULT (' ') FOR [WkOrdUdef5]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_WkOrdUdef6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_WkOrdUdef6]  DEFAULT (' ') FOR [WkOrdUdef6]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_WkOrdUdef7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_WkOrdUdef7]  DEFAULT (' ') FOR [WkOrdUdef7]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_WkOrdUdef8]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_WkOrdUdef8]  DEFAULT (' ') FOR [WkOrdUdef8]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_WkOrdUdef9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_WkOrdUdef9]  DEFAULT (' ') FOR [WkOrdUdef9]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_WorkOrder_WkOrdUdef10]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WorkOrder] ADD  CONSTRAINT [DF_WorkOrder_WkOrdUdef10]  DEFAULT (' ') FOR [WkOrdUdef10]
END

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'WorkOrderKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'use the default' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'WorkOrderKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'ExternWorkOrderKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'this field stores the external Workorder reference number (if any)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'ExternWorkOrderKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'StorerKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'type the name of the storer whom the goods belong to' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'StorerKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'Facility'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'key in the facility from which the goods are residing' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'Facility'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'Status'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'Status'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'ExternStatus'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the external workorder status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'ExternStatus'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'Type'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'key in the Workorder type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'Type'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'Reason'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the reason of the Workorder activities' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'Reason'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'TotalPrice'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the total price of the transactions which is computed based on the detail lines' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'TotalPrice'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'GenerateCharges'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'indicate whether charges are to be generated' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'GenerateCharges'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'Remarks'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'any remarks or notes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'Remarks'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'Notes1'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Additional information about workorder.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'Notes1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'Notes2'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'instructions on the Workorder are to be recorded here' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'Notes2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'AddDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information added. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'AddDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'AddWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID added the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'AddWho'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'EditDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'EditDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'EditWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'EditWho'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'TrafficCop'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'TrafficCop'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'WkOrdUdef6'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Work Order Userdefine 6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'WkOrdUdef6'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'WkOrdUdef7'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Work Order Userdefine 7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'WkOrdUdef7'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'WkOrdUdef8'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Work Order Userdefine 8' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'WkOrdUdef8'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'WkOrdUdef9'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Work Order Userdefine 9' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'WkOrdUdef9'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'WorkOrder', N'COLUMN',N'WkOrdUdef10'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Work Order Userdefine 10' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WorkOrder', @level2type=N'COLUMN',@level2name=N'WkOrdUdef10'

END
ELSE
BEGIN
   IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'WorkOrder' AND COLUMN_NAME = 'WkOrdUdef1' AND CHARACTER_MAXIMUM_LENGTH = 18)
   BEGIN
   ALTER TABLE dbo.WorkOrder ALTER COLUMN WkOrdUdef1 NVARCHAR (50) NULL
   END
END
