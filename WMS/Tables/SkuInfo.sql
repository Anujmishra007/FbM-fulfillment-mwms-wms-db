CREATE TABLE [dbo].[SkuInfo]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExtendedField01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField01] DEFAULT (' '),
[ExtendedField02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField02] DEFAULT (' '),
[ExtendedField03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField03] DEFAULT (' '),
[ExtendedField04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField04] DEFAULT (' '),
[ExtendedField05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField05] DEFAULT (' '),
[ExtendedField06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField06] DEFAULT (' '),
[ExtendedField07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField07] DEFAULT (' '),
[ExtendedField08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField08] DEFAULT (' '),
[ExtendedField09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField09] DEFAULT (' '),
[ExtendedField10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField10] DEFAULT (' '),
[ExtendedField11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField11] DEFAULT (' '),
[ExtendedField12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField12] DEFAULT (' '),
[ExtendedField13] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField13] DEFAULT (' '),
[ExtendedField14] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField14] DEFAULT (' '),
[ExtendedField15] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField15] DEFAULT (' '),
[ExtendedField16] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField16] DEFAULT (' '),
[ExtendedField17] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField17] DEFAULT (' '),
[ExtendedField18] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField18] DEFAULT (' '),
[ExtendedField19] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField19] DEFAULT (' '),
[ExtendedField20] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_ExtendedField20] DEFAULT (' '),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_SkuInfo_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuInfo_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_SkuInfo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendedField21] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendedField22] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SkuInfo] ADD CONSTRAINT [PK_SkuInfo] PRIMARY KEY CLUSTERED ([Storerkey], [Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[SkuInfo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[SkuInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SkuInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SkuInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SkuInfo] TO [NSQL]
GO
