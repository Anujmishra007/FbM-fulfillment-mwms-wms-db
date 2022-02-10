CREATE TABLE [dbo].[GeekPlusRBT_InvSync]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[TranID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_TranID] DEFAULT (''),
[MsgCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_MsgCode] DEFAULT (''),
[Message] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_Message] DEFAULT (''),
[SkuAmount] [int] NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_SkuAmount] DEFAULT ((0)),
[TotalPageNum] [int] NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_TotalPageNum] DEFAULT ((0)),
[CurrentPage] [int] NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_CurrentPage] DEFAULT ((0)),
[PageSize] [int] NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_PageSize] DEFAULT ((0)),
[OwnerCode] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_OwnerCode] DEFAULT (''),
[SkuCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_SkuCode] DEFAULT (''),
[SkuLevel] [int] NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_SkuLevel] DEFAULT ((0)),
[Amount] [int] NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_Amount] DEFAULT ((0)),
[AuditDate] [bigint] NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_AuditDate] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GeekPlusRBT_InvSync_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GeekPlusRBT_InvSync] ADD CONSTRAINT [PKGeekPlusRBT_InvSync] PRIMARY KEY NONCLUSTERED ([ID]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GeekPlusRBT_InvSync] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GeekPlusRBT_InvSync] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GeekPlusRBT_InvSync] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GeekPlusRBT_InvSync] TO [NSQL]
GO
