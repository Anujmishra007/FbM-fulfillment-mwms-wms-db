CREATE TABLE [dbo].[OTMLOG]
(
[OTMLOGKey] [int] NOT NULL IDENTITY(1, 1),
[Tablename] [nvarchar] (30) NOT NULL CONSTRAINT [DF_OTMLOG_Tablename] DEFAULT (' '),
[Key1] [nvarchar] (10) NOT NULL CONSTRAINT [DF_OTMLOG_Key1] DEFAULT (' '),
[Key2] [nvarchar] (5) NOT NULL CONSTRAINT [DF_OTMLOG_Key2] DEFAULT (' '),
[Key3] [nvarchar] (20) NOT NULL CONSTRAINT [DF_OTMLOG_Key3] DEFAULT (' '),
[TransmitFlag] [nvarchar] (5) NOT NULL CONSTRAINT [DF_OTMLOG_TransmitFlag] DEFAULT ('0'),
[TransmitBatch] [nvarchar] (30) NULL CONSTRAINT [DF_OTMLOG_TransmitBatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_OTMLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_OTMLOG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_OTMLOG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_OTMLOG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) NULL,
[ArchiveCop] [nvarchar] (1) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[OTMLOG] ADD CONSTRAINT [PKOTMLOG] PRIMARY KEY CLUSTERED ([OTMLOGKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_OTMLOG_CIdx] ON [dbo].[OTMLOG] ([Tablename], [Key1], [Key2], [Key3]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OTMLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OTMLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OTMLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OTMLOG] TO [NSQL]
GO
