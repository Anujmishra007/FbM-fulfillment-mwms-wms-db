CREATE TABLE [RDT].[NSQLConfig]
(
[Function_ID] [int] NOT NULL CONSTRAINT [DF_NSQLConfig_Function_ID] DEFAULT ((0)),
[ConfigKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NSQLValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLConfig_NSQLValue] DEFAULT (' '),
[NSQLDefault] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLConfig_NSQLDefault] DEFAULT (' '),
[NSQLDescrip] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_NSQLConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_NSQLConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLConfig_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/* 28-Oct-2013  TLTING     Review Editdate column update                */

CREATE TRIGGER [RDT].[ntrNSQLConfigUpdate] ON [RDT].[NSQLConfig] 
FOR UPDATE AS
BEGIN 
IF @@ROWCOUNT = 0
BEGIN
RETURN
END
   SET NOCOUNT ON
   SET ANSI_NULLS OFF   
   SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF

 IF  NOT UPDATE(EditDate)
 BEGIN 	 	
   UPDATE rdt.NSQLConfig SET 
      EditDate = GETDATE(),
      EditWho = SUSER_SNAME()
   FROM rdt.NSQLConfig, INSERTED
   WHERE rdt.NSQLConfig.Function_ID = INSERTED.Function_ID
      AND rdt.NSQLConfig.ConfigKey = INSERTED.ConfigKey
 END        
END

GO
ALTER TABLE [RDT].[NSQLConfig] ADD CONSTRAINT [PK_NSQLConfig] PRIMARY KEY CLUSTERED ([Function_ID], [ConfigKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[NSQLConfig] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[NSQLConfig] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[NSQLConfig] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[NSQLConfig] TO [NSQL]
GO
