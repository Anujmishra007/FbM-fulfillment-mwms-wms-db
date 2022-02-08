CREATE TABLE [dbo].[BillOfMaterial_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ComponentSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BillOfMaterial_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BillOfMaterial_DELLOG] ADD CONSTRAINT [PK__BillOfMaterial_D__21EBDADE] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BillOfMaterial_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BillOfMaterial_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BillOfMaterial_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BillOfMaterial_DELLOG] TO [NSQL]
GO
