CREATE TABLE [dbo].[SHIFT]
(
[Sequence] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShiftDescr] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SHIFT_ShiftDescr] DEFAULT (''),
[Day] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SHIFT_Day] DEFAULT (''),
[ShiftNumber] [int] NOT NULL,
[TimeFrom] [datetime] NOT NULL,
[TimeTo] [datetime] NOT NULL,
[Labour] [int] NULL,
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SHIFT_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_SHIFT_AddDate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SHIFT_Editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_SHIFT_EditDate] DEFAULT (getdate()),
[Productivity] [numeric] (8, 2) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SHIFT] ADD CONSTRAINT [PK_SHIFT] PRIMARY KEY CLUSTERED ([Sequence]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SHIFT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SHIFT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SHIFT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SHIFT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SHIFT', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'SHIFT', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SHIFT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'SHIFT', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Sequence', 'SCHEMA', N'dbo', 'TABLE', N'SHIFT', 'COLUMN', N'Sequence'
GO
