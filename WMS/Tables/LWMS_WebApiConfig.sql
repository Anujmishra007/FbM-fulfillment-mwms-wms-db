CREATE TABLE [dbo].[LWMS_WebApiConfig]
(
[SeqNo] [int] NOT NULL IDENTITY(1, 1),
[OperationType] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_OperationType] DEFAULT (' '),
[TargetDB] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_TargetDB] DEFAULT (' '),
[TargetSchema] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_TargetSchema] DEFAULT (' '),
[WSPostingSP01] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_WSPostingSP01] DEFAULT (' '),
[SPTJSON] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_SPTJSON] DEFAULT ('Y'),
[SPTXML] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_SPTXML] DEFAULT ('Y'),
[Descr] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LWMS_WebApiConfig_Descr] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LWMS_WebApiConfig_EditDate] DEFAULT (getdate()),
[ResponseOriContent] [int] NULL CONSTRAINT [DF_LWMS_WebApiConfig_ResponseOriContent] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LWMS_WebApiConfig] ADD CONSTRAINT [PK_LWMS_WebApiConfig] PRIMARY KEY CLUSTERED ([SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LWMS_WebApiConfig_Index01] ON [dbo].[LWMS_WebApiConfig] ([OperationType], [WSPostingSP01]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LWMS_WebApiConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LWMS_WebApiConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LWMS_WebApiConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LWMS_WebApiConfig] TO [NSQL]
GO
