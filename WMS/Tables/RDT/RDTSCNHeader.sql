CREATE TABLE [RDT].[RDTSCNHeader]
(
[scn] [int] NOT NULL,
[scndescr] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lang_code] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[adddate] [datetime] NULL CONSTRAINT [DF_RDTSCNHeader_adddate] DEFAULT (getdate()),
[addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSCNHeader_addwho] DEFAULT (suser_sname()),
[editddate] [datetime] NULL CONSTRAINT [DF_RDTSCNHeader_editddate] DEFAULT (getdate()),
[editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTSCNHeader_editwho] DEFAULT (suser_sname()),
[Func] [int] NULL,
[Scn_SeqNo] [int] NULL,
[ScreenFormat] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtScnHeader_ScreenFormat] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTSCNHeader] ADD CONSTRAINT [PK_RDTSCNHeader] PRIMARY KEY CLUSTERED ([scn], [lang_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTSCNHeader] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTSCNHeader] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTSCNHeader] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTSCNHeader] TO [NSQL]
GO
