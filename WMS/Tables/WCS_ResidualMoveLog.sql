CREATE TABLE [dbo].[WCS_ResidualMoveLog]
(
[SerialNo] [int] NOT NULL IDENTITY(1, 1),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ResidualQty] [int] NULL CONSTRAINT [DF_WCS_ResidualMoveLog_ResidualQty] DEFAULT ((0)),
[QtyPutawayed] [int] NULL CONSTRAINT [DF_WCS_ResidualMoveLog_QtyPutawayed] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_WCS_ResidualMoveLog_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WCS_ResidualMoveLog_EditDate] DEFAULT (getdate()),
[PreMoveQty] [int] NULL CONSTRAINT [DF_WCS_ResidualMoveLog_PreMoveQty] DEFAULT ((0)),
[ActualMoveQty] [int] NULL CONSTRAINT [DF_WCS_ResidualMoveLog_ActualMoveQty] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WCS_ResidualMoveLog] ADD CONSTRAINT [PK_WCS_ResidualMoveLog_PK] PRIMARY KEY CLUSTERED ([SerialNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WCS_ResidualMoveLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WCS_ResidualMoveLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WCS_ResidualMoveLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WCS_ResidualMoveLog] TO [NSQL]
GO
