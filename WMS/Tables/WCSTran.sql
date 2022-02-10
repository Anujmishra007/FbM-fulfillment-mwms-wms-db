CREATE TABLE [dbo].[WCSTran]
(
[MessageID] [int] NOT NULL IDENTITY(1, 1),
[MessageName] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageNum] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_MessageNum] DEFAULT (''),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_TaskDetailKey] DEFAULT (''),
[WCSMessageID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_WCSMessageID] DEFAULT (''),
[OrigMessageID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_OrigMessageID] DEFAULT (''),
[PalletID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_FromLoc] DEFAULT (''),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ToLoc] DEFAULT (''),
[Priority] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Priority] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Status] DEFAULT (''),
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ReasonCode] DEFAULT (''),
[ErrMsg] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ErrMsg] DEFAULT (''),
[UD1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD1] DEFAULT (''),
[UD2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD2] DEFAULT (''),
[UD3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD3] DEFAULT (''),
[UD4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD4] DEFAULT (''),
[UD5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_UD5] DEFAULT (''),
[ImgFolderPath] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFolderPath] DEFAULT (''),
[ImgFileName1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName1] DEFAULT (''),
[ImgFileName2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName2] DEFAULT (''),
[ImgFileName3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName3] DEFAULT (''),
[ImgFileName4] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName4] DEFAULT (''),
[ImgFileName5] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_ImgFileName5] DEFAULT (''),
[Param1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param1] DEFAULT (''),
[Param2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param2] DEFAULT (''),
[Param3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param3] DEFAULT (''),
[Param4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param4] DEFAULT (''),
[Param5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param5] DEFAULT (''),
[Param6] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param6] DEFAULT (''),
[Param7] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param7] DEFAULT (''),
[Param8] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param8] DEFAULT (''),
[Param9] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param9] DEFAULT (''),
[Param10] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_Param10] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_WCSTran_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WCSTran_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WCSTran_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WCSTran] ADD CONSTRAINT [PK_WCSTran] PRIMARY KEY CLUSTERED ([MessageID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WCSTran] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WCSTran] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WCSTran] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WCSTran] TO [NSQL]
GO
