IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GTMTask]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GTMTask]
(
[SeqNo] [int] NOT NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PalletID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_OrderKey] DEFAULT (''),
[WorkStation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_WorkStation] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_Status] DEFAULT (''),
[ErrMsg] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_ErrMsg] DEFAULT (''),
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_FromLoc] DEFAULT (''),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_ToLoc] DEFAULT (''),
[FinalLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_FinalLoc] DEFAULT (''),
[LogicalFromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_LogicalFromLoc] DEFAULT (''),
[LogicalToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_LogicalToLoc] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GTMTask_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_GTMTask_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GTMTask_EditWho] DEFAULT (suser_sname()),
[Facility] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL constraint [DF_GTMTask_Facility] default ('')

) ON [PRIMARY]

ALTER TABLE [dbo].[GTMTask] ADD CONSTRAINT [PK_GTMTask] PRIMARY KEY CLUSTERED ([TaskDetailKey]) ON [PRIMARY]

GRANT DELETE ON  [dbo].[GTMTask] TO [NSQL]

GRANT INSERT ON  [dbo].[GTMTask] TO [NSQL]

GRANT SELECT ON  [dbo].[GTMTask] TO [NSQL]

GRANT UPDATE ON  [dbo].[GTMTask] TO [NSQL]

END

ELSE
BEGIN

   IF NOT EXISTS (SELECT *
                   FROM sys.columns
                   WHERE Name = 'Facility'
                     AND Object_ID = Object_ID('GTMTask'))
        BEGIN
            Alter table dbo.GTMTask 
			Add Facility nvarchar(50) NULL constraint [DF_GTMTask_Facility] default ('')

            EXEC sp_addextendedproperty N'MS_Description', 'Warehouse Facility code', 'SCHEMA', N'dbo', 'TABLE', N'GTMTask', 'COLUMN', N'Facility'
        END
        	
END
