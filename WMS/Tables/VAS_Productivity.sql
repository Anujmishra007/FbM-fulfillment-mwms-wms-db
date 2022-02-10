CREATE TABLE [dbo].[VAS_Productivity]
(
[VASPRODKEY] [bigint] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Productivity_SKU] DEFAULT (''),
[Dep] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Productivity_Dep] DEFAULT (''),
[Productivity] [float] NOT NULL CONSTRAINT [DF_VAS_Productivity_Productivity] DEFAULT ((0)),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Productivity_Type] DEFAULT (''),
[MaxKITQty] [int] NOT NULL CONSTRAINT [DF_VAS_Productivity_MaxKITQty] DEFAULT ((0)),
[Machine] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Productivity_Machine] DEFAULT (''),
[MachineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Productivity_MachineNo] DEFAULT (''),
[MaxCapacity] [int] NOT NULL CONSTRAINT [DF_VAS_Productivity_MaxCapacity] DEFAULT ((0)),
[MachineQty] [int] NOT NULL CONSTRAINT [DF_VAS_Productivity_MachineQty] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_VAS_Productivity_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Productivity_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_VAS_Productivity_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VAS_Productivity_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VAS_Productivity] ADD CONSTRAINT [PK_VAS_Productivity_1] PRIMARY KEY CLUSTERED ([VASPRODKEY]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VAS_Productivity] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VAS_Productivity] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VAS_Productivity] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VAS_Productivity] TO [NSQL]
GO
