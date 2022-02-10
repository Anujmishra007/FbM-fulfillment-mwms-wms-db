CREATE TABLE [RDT].[RDTXML_Elm]
(
[mobile] [int] NOT NULL,
[typ] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[x] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[y] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[length] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltext] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTXML_Elm_ltext] DEFAULT (''),
[dcolor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTXML_Elm_dcolor] DEFAULT (''),
[vmatch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTXML_Elm_vmatch] DEFAULT (''),
[Rowid] [int] NOT NULL IDENTITY(1, 1),
[WebGroup] [int] NULL,
[WebColType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTXML_Elm] ADD CONSTRAINT [PKRDTXML_Elm] PRIMARY KEY CLUSTERED ([Rowid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RDTXML_Elm_Mobile] ON [RDT].[RDTXML_Elm] ([mobile], [id], [typ]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTXML_Elm] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTXML_Elm] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTXML_Elm] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTXML_Elm] TO [NSQL]
GO
