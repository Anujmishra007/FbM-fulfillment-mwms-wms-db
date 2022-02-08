CREATE TABLE [RDT].[RDTCfg_User]
(
[Function_ID] [int] NOT NULL,
[Config] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [int] NOT NULL CONSTRAINT [DF_RDTCfg_User_Value] DEFAULT ((0)),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCfg_User_Storerkey] DEFAULT (' ')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTCfg_User] ADD CONSTRAINT [PK_RDTCfg_User] PRIMARY KEY CLUSTERED ([Function_ID], [Config], [Storerkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTCfg_User] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTCfg_User] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTCfg_User] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTCfg_User] TO [NSQL]
GO
