CREATE TABLE [dbo].[CheckUpKPIDetail]
(
[KPIDet] [int] NOT NULL IDENTITY(1, 1),
[KPI] [int] NOT NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CheckUpKPIDetail_Type] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [numeric] (25, 3) NULL,
[RunDate] [datetime] NULL CONSTRAINT [DF_CheckUpKPIDetail_RunDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CheckUpKPIDetail] ADD CONSTRAINT [PK_CheckUpKPIDetail] PRIMARY KEY CLUSTERED ([KPIDet]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CheckUpKPIDetail_01] ON [dbo].[CheckUpKPIDetail] ([KPI], [StorerKey], [Facility]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CheckUpKPIDetail_RunDate] ON [dbo].[CheckUpKPIDetail] ([RunDate], [KPI]) INCLUDE ([StorerKey], [Value]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CheckUpKPIDetail] ADD CONSTRAINT [FK_CheckUpKPIDetail_CheckUpKPI] FOREIGN KEY ([KPI]) REFERENCES [dbo].[CheckUpKPI] ([KPI])
GO
GRANT DELETE ON  [dbo].[CheckUpKPIDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CheckUpKPIDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CheckUpKPIDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CheckUpKPIDetail] TO [NSQL]
GO
