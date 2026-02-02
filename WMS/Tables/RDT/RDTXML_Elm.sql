IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[RDTXML_Elm]') AND type in (N'U'))
BEGIN

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

ALTER TABLE [RDT].[RDTXML_Elm] ADD CONSTRAINT [PKRDTXML_Elm] PRIMARY KEY CLUSTERED ([Rowid]) WITH (FILLFACTOR=90) ON [PRIMARY]


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[RDT].[RDTXML_Elm]') AND name = N'IX_RDTXML_Elm_Mobile')
CREATE NONCLUSTERED INDEX [IX_RDTXML_Elm_Mobile] ON [RDT].[RDTXML_Elm]
(
	[mobile] ASC,
	[id] ASC,
	[typ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]


GRANT DELETE ON  [RDT].[RDTXML_Elm] TO [NSQL]

GRANT INSERT ON  [RDT].[RDTXML_Elm] TO [NSQL]

GRANT SELECT ON  [RDT].[RDTXML_Elm] TO [NSQL]

GRANT UPDATE ON  [RDT].[RDTXML_Elm] TO [NSQL]

END 


ELSE 
BEGIN 

		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'WebGroup' AND Object_ID = Object_ID('RDT.RDTXML_Elm'))
			BEGIN

				ALTER TABLE [RDT].[RDTXML_Elm] ADD WebGroup INT NULL ;
				EXEC sp_addextendedproperty N'MS_Description', 'WebGroup', 'SCHEMA', N'RDT', 'TABLE', N'RDTXML_Elm', 'COLUMN', N'WebGroup'
				
			END


			 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'WebColType' AND Object_ID = Object_ID('RDT.RDTXML_Elm'))
			BEGIN

				ALTER TABLE [RDT].[RDTXML_Elm] ADD WebColType [nvarchar] (20) NULL ;
				EXEC sp_addextendedproperty N'MS_Description', 'WebColType', 'SCHEMA', N'RDT', 'TABLE', N'RDTXML_Elm', 'COLUMN', N'WebColType'
				
			END

END