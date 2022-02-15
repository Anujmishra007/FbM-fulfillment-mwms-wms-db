CREATE TABLE [RDT].[rdtProgramRights]
(
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramID] [int] NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtProgramRights_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtProgramRights] ADD CONSTRAINT [PK_rdtProgramRights] PRIMARY KEY CLUSTERED ([UserName], [ProgramID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtProgramRights] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtProgramRights] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtProgramRights] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtProgramRights] TO [NSQL]
GO
