CREATE TABLE [dbo].[PickingInfo_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingInfo_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PickingInfo_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingInfo_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PickingInfo_DELLOG] ADD CONSTRAINT [PK__PickingInfo_DELL__7934A965] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PickingInfo_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PickingInfo_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PickingInfo_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PickingInfo_DELLOG] TO [NSQL]
GO
