CREATE TABLE [dbo].[VoiceAssignment]
(
[AssignmentID] [bigint] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroupID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VoiceAssignment_UserName] DEFAULT (suser_sname()),
[Status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VoiceAssignment_Status] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_VoiceAssignment_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_VoiceAssignment_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VoiceAssignment] ADD CONSTRAINT [PK_VoiceAssignment] PRIMARY KEY CLUSTERED ([AssignmentID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VoiceAssignment] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VoiceAssignment] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VoiceAssignment] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VoiceAssignment] TO [NSQL]
GO
