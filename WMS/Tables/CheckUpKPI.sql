CREATE TABLE [dbo].[CheckUpKPI]
(
[KPI] [int] NOT NULL IDENTITY(1, 1),
[KPICode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Category] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TypeOfSymbol] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CheckUpKPI_TypeOfSymbol] DEFAULT (''),
[Enabled] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CheckUpKPI_Enabled] DEFAULT ('N'),
[DisplayOnDashboard] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CheckUpKPI_DisplayOnDashboard] DEFAULT ('  '),
[PrimaryWidgetFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CheckUpKPI_PrimaryWidgetFlag] DEFAULT ('N'),
[YlMin] [int] NOT NULL,
[YlMax] [int] NOT NULL,
[SQL] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CheckUpKPI_SQL] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CheckUpKPI_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CheckUpKPI_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CheckUpKPI_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CheckUpKPI_EditWho] DEFAULT (suser_sname()),
[LastRunDate] [datetime] NULL,
[SQL_DrillDown] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CheckUpKPI_SQL_DrillDown] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CheckUpKPI] ADD CONSTRAINT [PK_CheckUpKPI] PRIMARY KEY CLUSTERED ([KPI]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CheckUpKPI] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CheckUpKPI] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CheckUpKPI] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CheckUpKPI] TO [NSQL]
GO
