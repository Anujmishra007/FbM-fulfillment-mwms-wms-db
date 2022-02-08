CREATE TABLE [dbo].[LoadPlan_SUP_Detail]
(
[RowRefNo] [bigint] NOT NULL IDENTITY(1, 1),
[TYPE] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_TYPE] DEFAULT ('0'),
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_PickMethod] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_Loc] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_SKU] DEFAULT (''),
[Div] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_Div] DEFAULT (''),
[Class] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_Class] DEFAULT (''),
[Measurement] [int] NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_Measurement] DEFAULT ((0)),
[CartonNo] [int] NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_CartonNo] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_Qty] DEFAULT ((0)),
[QUOM] [int] NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_QUOM] DEFAULT ((0)),
[TotalCarton] [int] NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_TotalCarton] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_SUP_Detail_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoadPlan_SUP_Detail] ADD CONSTRAINT [PK_LoadPlan_SUP_Detail] PRIMARY KEY CLUSTERED ([RowRefNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LoadPlan_SUP_Detail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LoadPlan_SUP_Detail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LoadPlan_SUP_Detail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LoadPlan_SUP_Detail] TO [NSQL]
GO
