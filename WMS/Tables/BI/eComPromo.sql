CREATE TABLE [BI].[eComPromo]
(
[PromoID] [smallint] NOT NULL IDENTITY(1, 1),
[PromoType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [smalldatetime] NOT NULL,
[EndDate] [smalldatetime] NOT NULL,
[DaysAgo] [smallint] NOT NULL,
[IncludeArchive] [bit] NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_eComPromo_AddDate] DEFAULT (getdate()),
[AddWho] [sys].[sysname] NOT NULL CONSTRAINT [DF_eComPromo_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_eComPromo_EditDate] DEFAULT (getdate()),
[EditWho] [sys].[sysname] NOT NULL CONSTRAINT [DF_eComPromo_EditWho] DEFAULT (suser_sname()),
[FreqInterval] [smallint] NOT NULL CONSTRAINT [DF_eComPromo_FreqInterval] DEFAULT ((10))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
ALTER TABLE [BI].[eComPromo] ADD CONSTRAINT [PK_eComPromo] PRIMARY KEY CLUSTERED ([PromoID]) ON [PRIMARY]
GO
GRANT INSERT ON  [BI].[eComPromo] TO [NSQL]
GO
GRANT SELECT ON  [BI].[eComPromo] TO [NSQL]
GO
GRANT UPDATE ON  [BI].[eComPromo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'e-Commerce Configuration table for customer forecast & promo period.', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date time when added the record', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Login name who added the record', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date time when edited the record', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Login name who edited the record', 'SCHEMA', N'BI', 'TABLE', N'eComPromo', 'COLUMN', N'EditWho'
GO
