CREATE TABLE [dbo].[VAS_Demand]
(
[VASDemandKey] [bigint] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_StorerKey] DEFAULT (''),
[Brand] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_Brand] DEFAULT (''),
[Catogry] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Charge] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_Charge] DEFAULT (''),
[VASMode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_VASMode] DEFAULT (''),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_DEMAND_Type] DEFAULT (''),
[OperationType] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_OperationType] DEFAULT (''),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_Priority] DEFAULT (''),
[RepackCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_RepackCode] DEFAULT (''),
[SOSDate] [datetime] NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_VAS_DEMAND_Qty] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_DEMAND_UOM] DEFAULT (''),
[SKUReady] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_SKUReady] DEFAULT (''),
[BOMReady] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_BOMReady] DEFAULT (''),
[PIReady] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_PIReady] DEFAULT (''),
[PMReady] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_PMReady] DEFAULT (''),
[ComponentReady] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_ComponentReady] DEFAULT (''),
[Status] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_Status] DEFAULT ('WAIT'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_VAS_Demand_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_VAS_Demand_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Demand_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VAS_Demand] ADD CONSTRAINT [PK_VAS_Demand] PRIMARY KEY CLUSTERED ([VASDemandKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VAS_Demand] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VAS_Demand] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VAS_Demand] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VAS_Demand] TO [NSQL]
GO
