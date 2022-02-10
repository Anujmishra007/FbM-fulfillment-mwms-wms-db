CREATE TABLE [dbo].[VoiceAssignmentDetail]
(
[AssignmentID] [bigint] NOT NULL,
[SeqNo] [int] NOT NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VoiceAssignmentDetail_ContainerID] DEFAULT (''),
[LabelPrinted] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VoiceAssignmentDetail_LabelPrinted] DEFAULT ('N'),
[Qty] [int] NULL CONSTRAINT [DF_VoiceAssignmentDetail_Qty] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_VoiceAssignmentDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VoiceAssignmentDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_VoiceAssignmentDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VoiceAssignmentDetail_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VoiceAssignmentDetail] ADD CONSTRAINT [PK_VoiceAssignmentDetail] PRIMARY KEY CLUSTERED ([AssignmentID], [SeqNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VoiceAssignmentDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VoiceAssignmentDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VoiceAssignmentDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VoiceAssignmentDetail] TO [NSQL]
GO
