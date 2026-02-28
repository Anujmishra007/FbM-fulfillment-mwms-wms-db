SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Order_AutomationStatus](
	[RowRefNo] [bigint] IDENTITY(1,1) NOT NULL,
	[OrderKey] [nvarchar](10) NOT NULL,
	[AutomationStatus] [nvarchar](20) NULL,
	[AddWho] [nvarchar](128) NULL,
	[AddDate] [datetime] NULL,
	[EditWho] [nvarchar](128) NULL,
	[EditDate] [datetime] NULL,
	[TrafficCop] [nchar](1) NULL,
	[ArchiveCop] [nchar](1) NULL,
 CONSTRAINT [PK_Order_AutomationStatus] PRIMARY KEY CLUSTERED 
(
	[RowRefNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

 

CREATE UNIQUE NONCLUSTERED INDEX [IDX_Order_AutomationStatus] ON [dbo].[Order_AutomationStatus]
(
	[OrderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


ALTER AUTHORIZATION ON [dbo].[Order_AutomationStatus] TO  SCHEMA OWNER 
GO

ALTER TABLE [dbo].[Order_AutomationStatus] ADD  CONSTRAINT [DF_Order_AutomationStatus_AutomationStatus]  DEFAULT ('') FOR [AutomationStatus]
GO

ALTER TABLE [dbo].[Order_AutomationStatus] ADD  CONSTRAINT [DF_Order_AutomationStatus_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
GO

ALTER TABLE [dbo].[Order_AutomationStatus] ADD  CONSTRAINT [DF_Order_AutomationStatus_AddDate]  DEFAULT (getdate()) FOR [AddDate]
GO

ALTER TABLE [dbo].[Order_AutomationStatus] ADD  CONSTRAINT [DF_Order_AutomationStatus_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
GO

ALTER TABLE [dbo].[Order_AutomationStatus] ADD  CONSTRAINT [DF_Order_AutomationStatus_EditDate]  DEFAULT (getdate()) FOR [EditDate]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying Orders.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Order_AutomationStatus', @level2type=N'COLUMN',@level2name=N'OrderKey'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID added the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Order_AutomationStatus', @level2type=N'COLUMN',@level2name=N'AddWho'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information added. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Order_AutomationStatus', @level2type=N'COLUMN',@level2name=N'AddDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Order_AutomationStatus', @level2type=N'COLUMN',@level2name=N'EditWho'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Order_AutomationStatus', @level2type=N'COLUMN',@level2name=N'EditDate'
GO


