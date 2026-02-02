IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GTMLoop]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GTMLoop]
(
[PalletId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MsgId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Workstation] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EditWho] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL constraint [DF_GTMLoop_Facility] default ('')

) ON [PRIMARY]

ALTER TABLE [dbo].[GTMLoop] ADD CONSTRAINT [PK_GTMLoop_1] PRIMARY KEY CLUSTERED ([PalletId]) WITH (FILLFACTOR=80) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IDX_GTMloop_Workstation] ON [dbo].[GTMLoop] ([Workstation], [TaskDetailKey]) WITH (FILLFACTOR=80) ON [PRIMARY]

GRANT DELETE ON  [dbo].[GTMLoop] TO [NSQL]

GRANT INSERT ON  [dbo].[GTMLoop] TO [NSQL]

GRANT SELECT ON  [dbo].[GTMLoop] TO [NSQL]

GRANT UPDATE ON  [dbo].[GTMLoop] TO [NSQL]

END

ELSE 
BEGIN

 IF NOT EXISTS (SELECT *
                   FROM sys.columns
                   WHERE Name = 'Facility'
                     AND Object_ID = Object_ID('GTMLoop'))
        BEGIN
            Alter table dbo.GTMLoop 
			Add Facility nvarchar(50) constraint [DF_GTMLoop_Facility] default ('')
            EXEC sp_addextendedproperty N'MS_Description', 'Warehouse Facility code', 'SCHEMA', N'dbo', 'TABLE', N'GTMLoop', 'COLUMN', N'Facility'
        END


	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GTMLoop]') AND name = N'IDX_GTMloop_Workstation')
	BEGIN
		 Create index IDX_GTMloop_Workstation on [GTMLoop] ( Workstation, TaskDetailKey )
	END
            	
END


