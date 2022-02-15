CREATE TABLE [RDT].[rdtPackLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[Weight] [float] NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[Adddate] [datetime] NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EditDate] [datetime] NOT NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPackLog] ADD CONSTRAINT [PK_rdtPackLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPackLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPackLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPackLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPackLog] TO [NSQL]
GO
