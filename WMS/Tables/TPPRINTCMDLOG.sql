CREATE TABLE [dbo].[TPPRINTCMDLOG]
(
[JobNo] [bigint] NOT NULL,
[CartonNo] [int] NOT NULL,
[PrintCMD] [nvarchar] (max) NULL,
[PrintServerIP] [nvarchar] (20) NULL,
[PrintServerPort] [nvarchar] (5) NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF__TPPRINTCM__AddDa__46083E73] DEFAULT (getdate()),
[AddWho] [nvarchar] (18) NULL CONSTRAINT [DF__TPPRINTCM__AddWh__46FC62AC] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF__TPPRINTCM__EditD__47F086E5] DEFAULT (getdate()),
[EditWho] [nvarchar] (18) NULL CONSTRAINT [DF__TPPRINTCM__EditW__48E4AB1E] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPPRINTCMDLOG] ADD CONSTRAINT [PK_TPPRINTCMDLOG] PRIMARY KEY CLUSTERED ([JobNo], [CartonNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TPPRINTCMDLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TPPRINTCMDLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TPPRINTCMDLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TPPRINTCMDLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trade Partner Print command log', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCMDLOG', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Added By User Date', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCMDLOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Added By User ID', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCMDLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'CartonNo', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCMDLOG', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edited By User Date', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCMDLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edited By User ID', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCMDLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Print Job Number', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCMDLOG', 'COLUMN', N'JobNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Print Command', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTCMDLOG', 'COLUMN', N'PrintCMD'
GO
