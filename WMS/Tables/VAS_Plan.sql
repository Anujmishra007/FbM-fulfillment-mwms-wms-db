CREATE TABLE [dbo].[VAS_Plan]
(
[VASPlanKey] [bigint] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Plan_StorerKey] DEFAULT (''),
[Brand] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Plan_Brand] DEFAULT (''),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Plan_Type] DEFAULT (''),
[SeqNo] [int] NOT NULL CONSTRAINT [DF_VAS_Plan_SeqNo] DEFAULT ((0)),
[RepackCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Plan_RepackCode] DEFAULT (''),
[SOSDate] [datetime] NULL,
[PlanDate] [datetime] NULL,
[DemandQty] [int] NOT NULL CONSTRAINT [DF_VAS_Plan_DemandQty] DEFAULT ((0)),
[AllocatedQty] [int] NOT NULL CONSTRAINT [DF_VAS_Plan_AllocatedQty] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Plan_UOM] DEFAULT (''),
[KITKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Plan_KITKey] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_VAS_Plan_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Plan_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_VAS_Plan_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Plan_EditWho] DEFAULT (suser_sname()),
[VASDemandKey] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VAS_Plan] ADD CONSTRAINT [PK_VAS_Plan] PRIMARY KEY CLUSTERED ([VASPlanKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VAS_Plan] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VAS_Plan] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VAS_Plan] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VAS_Plan] TO [NSQL]
GO
