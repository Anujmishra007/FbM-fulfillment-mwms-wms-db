CREATE TABLE [RDT].[rdtTaskManagerConfig]
(
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTaskManagerConfig_TaskType] DEFAULT (''),
[TaskDesc] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTaskManagerConfig_TaskDesc] DEFAULT (' '),
[Function_ID] [int] NOT NULL CONSTRAINT [DF_rdtTaskManagerConfig_Function_ID] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtTaskManagerConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTaskManagerConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_rdtTaskManagerConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTaskManagerConfig_EditWho] DEFAULT (suser_sname()),
[Step] [int] NOT NULL CONSTRAINT [DF_rdtTaskManagerConfig_Step] DEFAULT ((1))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE TRIGGER [RDT].[ntrRDTTaskManagerConfigUpdate] 
ON [RDT].[rdtTaskManagerConfig] 
FOR UPDATE 
AS
BEGIN
   UPDATE rdt.rdtTaskManagerConfig WITH (ROWLOCK)
    SET EditDate = GETDATE(),
        EditWho = SUSER_SNAME()
   FROM rdt.rdtTaskManagerConfig, INSERTED
   WHERE rdt.rdtTaskManagerConfig.TaskType = INSERTED.TaskType
END
GO
ALTER TABLE [RDT].[rdtTaskManagerConfig] ADD CONSTRAINT [PK_rdtTaskManagerConfig] PRIMARY KEY CLUSTERED ([TaskType]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtTaskManagerConfig] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtTaskManagerConfig] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtTaskManagerConfig] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtTaskManagerConfig] TO [NSQL]
GO
