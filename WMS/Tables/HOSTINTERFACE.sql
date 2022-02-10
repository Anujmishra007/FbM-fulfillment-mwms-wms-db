CREATE TABLE [dbo].[HOSTINTERFACE]
(
[hikey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hiprocess] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hidescrip] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hidescrip] DEFAULT (' '),
[hifile1] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hifile1] DEFAULT (' '),
[hifile2] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hifile2] DEFAULT (' '),
[hifile3] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hifile3] DEFAULT (' '),
[hifile4] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hifile4] DEFAULT (' '),
[hifile5] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hifile5] DEFAULT (' '),
[hifile6] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hifile6] DEFAULT (' '),
[hifile1type] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hifile1type] DEFAULT (' '),
[hifile2type] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hifile2type] DEFAULT (' '),
[hifile3type] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hifile3type] DEFAULT (' '),
[hifile4type] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hifile4type] DEFAULT (' '),
[hifile5type] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hifile5type] DEFAULT (' '),
[hifile6type] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hifile6type] DEFAULT (' '),
[hilogfile] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hilogfile] DEFAULT (' '),
[hidopost] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hidopost] DEFAULT ('Y'),
[hiusetimer] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hiusetimer] DEFAULT ('N'),
[hitimerinterval] [int] NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hitimerinterval] DEFAULT ((0)),
[hiimpexp] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hiimpexp] DEFAULT ('I'),
[hidirectdwimport] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hidirectdwimport] DEFAULT ('N'),
[hidefaultstorer] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hidefaultstorer] DEFAULT (' '),
[hierasefiles] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hierasefiles] DEFAULT ('Y'),
[hirevheader] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hirevdetail] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hirevsubdetail] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hiheader] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hidetail] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hisubdetail] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hirevother1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hirevother2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hirevother3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hiother1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hiother2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hiother3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hipreruncommand] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hipostruncommand] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hiprintdoc1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprintdoc1] DEFAULT ('N'),
[hiprintdoc2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprintdoc2] DEFAULT ('N'),
[hiprintdoc3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprintdoc3] DEFAULT ('N'),
[hiprintdoc4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprintdoc4] DEFAULT ('N'),
[hiprintdoc5] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprintdoc5] DEFAULT ('N'),
[hiprintdoc6] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprintdoc6] DEFAULT ('N'),
[hiprinter1] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprinter1] DEFAULT (' '),
[hiprinter2] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprinter2] DEFAULT (' '),
[hiprinter3] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprinter3] DEFAULT (' '),
[hiprinter4] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprinter4] DEFAULT (' '),
[hiprinter5] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprinter5] DEFAULT (' '),
[hiprinter6] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiprinter6] DEFAULT (' '),
[Autocreatepalheader] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_Autocreatepalheader] DEFAULT ('N'),
[hiAutoShipPallet] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiAutoShipPallet] DEFAULT ('N'),
[Autocreatectrheader] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_Autocreatectrheader] DEFAULT ('N'),
[hiAutoShipContainer] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_hiAutoShipContainer] DEFAULT ('N'),
[hidoOP] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hidoop] DEFAULT ('N'),
[hiOPKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Hostinterface_hiOPKey] DEFAULT ('STD'),
[HiAddSku] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_HiAddSku] DEFAULT ('N'),
[HiAddStorer] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_HOSTINTERFACE_HiAddStorer] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HOSTINTERFACE] ADD CONSTRAINT [PKHOSTINTERFACE] PRIMARY KEY CLUSTERED ([hikey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HOSTINTERFACE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[HOSTINTERFACE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[HOSTINTERFACE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[HOSTINTERFACE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of host interface.', 'SCHEMA', N'dbo', 'TABLE', N'HOSTINTERFACE', 'COLUMN', N'hidescrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Host Interface.', 'SCHEMA', N'dbo', 'TABLE', N'HOSTINTERFACE', 'COLUMN', N'hikey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Host Interface OP.', 'SCHEMA', N'dbo', 'TABLE', N'HOSTINTERFACE', 'COLUMN', N'hiOPKey'
GO
