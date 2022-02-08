CREATE TABLE [dbo].[InventoryQC_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[QC_Key] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQC_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_InventoryQC_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InventoryQC_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InventoryQC_DELLOG] ADD CONSTRAINT [PK__InventoryQC_DELL__04266DCD] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InventoryQC_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[InventoryQC_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[InventoryQC_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[InventoryQC_DELLOG] TO [NSQL]
GO
