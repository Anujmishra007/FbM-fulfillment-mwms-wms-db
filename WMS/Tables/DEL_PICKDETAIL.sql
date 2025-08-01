IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEL_PICKDETAIL]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DEL_PICKDETAIL]
(
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_CaseID] DEFAULT (' '),
[PickHeaderKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_AltSku] DEFAULT (' '),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_UOM] DEFAULT (' '),
[UOMQty] [int] NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_UOMQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_Qty] DEFAULT ((0)),
[QtyMoved] [int] NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_QtyMoved] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_Status] DEFAULT ('0'),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_DropID] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_Loc] DEFAULT ('UNKNOWN'),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_ID] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_PackKey] DEFAULT (' '),
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_UpdateSource] DEFAULT ('0'),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_ToLoc] DEFAULT (' '),
[DoReplenish] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_DoReplenish] DEFAULT ('N'),
[ReplenishZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_ReplenishZone] DEFAULT (' '),
[DoCartonize] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_DoCartonize] DEFAULT ('N'),
[PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_PickMethod] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_WaveKey] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptimizeCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_ShipFlag] DEFAULT ('0'),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDetailKey] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_TaskDetailKey] DEFAULT (' '),
[TaskManagerReasonKey] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_TaskManagerReasonKey] DEFAULT (' '),
[Notes] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_Notes] DEFAULT (' '),
[MoveRefKey] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_MoveRefKey] DEFAULT (' '),
[Channel_ID] [bigint] NULL  CONSTRAINT [DF_DEL_PICKDETAIL_Channel_ID] DEFAULT (' '),
[SourceType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_PICKDETAIL_SourceType] DEFAULT (' '),
[DeleteBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_DeleteBy] DEFAULT (suser_sname()),
[DeleteDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_PICKDETAIL_DeleteDate] DEFAULT (getdate())
) ON [PRIMARY]

ALTER TABLE [dbo].[DEL_PICKDETAIL] ADD CONSTRAINT [PK_Del_PickDetail] PRIMARY KEY CLUSTERED ([PickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

GRANT DELETE ON  [dbo].[DEL_PICKDETAIL] TO [NSQL]

GRANT INSERT ON  [dbo].[DEL_PICKDETAIL] TO [NSQL]

GRANT SELECT ON  [dbo].[DEL_PICKDETAIL] TO [NSQL]

GRANT UPDATE ON  [dbo].[DEL_PICKDETAIL] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', 'Alternate Commodity ID to be linked to the Master Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'AltSku'

EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'CartonGroup'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Case.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'CaseID'

EXEC sp_addextendedproperty N'MS_Description', 'This field is populated by the system once a sorter scans the ID that is used to identify the customer∆s outbound packing container. This allows the sorter to apply the Drop ID label to the outbound container and simply scan the barcode for the location to verify proper sortation. The system then records the sort into the Drop ID assigned to the scanned sortation location.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'DropID'

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'EditWho'

EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'ID'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'Loc'

EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'Lot'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'OrderKey'

EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'PackKey'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Detail.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'PickDetailKey'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Header.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'PickHeaderKey'

EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pick Slip.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'PickSlipNo'

EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'Qty'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the products.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'Sku'

EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'Storerkey'

EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'TrafficCop'

EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'UOM'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'WaveKey'

END

ELSE 
BEGIN 


	--ALTER COLUMN 
 IF  EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'CaseID' AND Object_ID = Object_ID('dbo.DEL_PICKDETAIL') and max_length <>40)
			BEGIN
				ALTER TABLE dbo.DEL_PICKDETAIL 
				ALTER COLUMN [CaseID]  [nvarchar] (20) NOT NULL;

			END


--ADD COLUMN 

			IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'TaskDetailKey' AND Object_ID = Object_ID('dbo.DEL_PICKDETAIL'))
			BEGIN
				ALTER TABLE dbo.DEL_PICKDETAIL ADD [TaskDetailKey] [nvarchar](10) NULL CONSTRAINT [DF_DEL_PICKDETAIL_TaskDetailKey] DEFAULT (' ');
				EXEC sp_addextendedproperty N'MS_Description', 'TaskDetailKey', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'TaskDetailKey'
				
			END


			IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'TaskManagerReasonKey' AND Object_ID = Object_ID('dbo.DEL_PICKDETAIL'))
			BEGIN
				ALTER TABLE dbo.DEL_PICKDETAIL ADD [TaskManagerReasonKey] [nvarchar](10) NULL CONSTRAINT [DF_DEL_PICKDETAIL_TaskManagerReasonKey] DEFAULT (' ');
				EXEC sp_addextendedproperty N'MS_Description', 'TaskManagerReasonKey', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'TaskManagerReasonKey'
				
			END



			IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'Notes' AND Object_ID = Object_ID('dbo.DEL_PICKDETAIL'))
			BEGIN
				ALTER TABLE dbo.DEL_PICKDETAIL ADD [Notes] [nvarchar](4000) NULL CONSTRAINT [DF_DEL_PICKDETAIL_Notes] DEFAULT (' ');
				EXEC sp_addextendedproperty N'MS_Description', 'Notes', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'Notes'
				
			END


			IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'MoveRefKey' AND Object_ID = Object_ID('dbo.DEL_PICKDETAIL'))
			BEGIN
				ALTER TABLE dbo.DEL_PICKDETAIL ADD [MoveRefKey] [nvarchar](10) NULL CONSTRAINT [DF_DEL_PICKDETAIL_MoveRefKey] DEFAULT (' ');
				EXEC sp_addextendedproperty N'MS_Description', 'MoveRefKey', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'MoveRefKey'
				
			END



			IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'Channel_ID' AND Object_ID = Object_ID('dbo.DEL_PICKDETAIL'))
			BEGIN
				ALTER TABLE dbo.DEL_PICKDETAIL ADD [Channel_ID] [bigint] NULL  CONSTRAINT [DF_DEL_PICKDETAIL_Channel_ID] DEFAULT (' ');
				EXEC sp_addextendedproperty N'MS_Description', 'Channel_ID', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'Channel_ID'
				
			END




			IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'SourceType' AND Object_ID = Object_ID('dbo.DEL_PICKDETAIL'))
			BEGIN
				ALTER TABLE dbo.DEL_PICKDETAIL ADD [SourceType] [nvarchar](50) NULL CONSTRAINT [DF_DEL_PICKDETAIL_SourceType] DEFAULT (' ');
				EXEC sp_addextendedproperty N'MS_Description', 'SourceType', 'SCHEMA', N'dbo', 'TABLE', N'DEL_PICKDETAIL', 'COLUMN', N'SourceType'
				
			END
			
			
END