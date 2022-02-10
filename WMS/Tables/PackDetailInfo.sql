CREATE TABLE [dbo].[PackDetailInfo]
(
[PackDetailInfoKey] [bigint] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetailInfo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackDetailInfo_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetailInfo_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PackDetailInfo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PackDetailInfo] ADD CONSTRAINT [PK_PackDetailInfo] PRIMARY KEY CLUSTERED ([PackDetailInfoKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetailInfo_PickSlipNo_CartonNo_LabelNo_LabelLine] ON [dbo].[PackDetailInfo] ([PickSlipNo], [CartonNo], [LabelNo], [LabelLine]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PackDetailInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackDetailInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackDetailInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackDetailInfo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional data of a pack detail line', 'SCHEMA', N'dbo', 'TABLE', N'PackDetailInfo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'QTY under this data', 'SCHEMA', N'dbo', 'TABLE', N'PackDetailInfo', 'COLUMN', N'QTY'
GO
