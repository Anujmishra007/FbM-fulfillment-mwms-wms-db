IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[RDTSCNHeader]') AND type in (N'U'))
BEGIN
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


ALTER TABLE [RDT].[RDTSCNHeader] ADD CONSTRAINT [PK_RDTSCNHeader] PRIMARY KEY CLUSTERED ([scn], [lang_code]) ON [PRIMARY]


GRANT DELETE ON  [RDT].[RDTSCNHeader] TO [NSQL]

GRANT INSERT ON  [RDT].[RDTSCNHeader] TO [NSQL]

GRANT SELECT ON  [RDT].[RDTSCNHeader] TO [NSQL]

GRANT UPDATE ON  [RDT].[RDTSCNHeader] TO [NSQL]


END 

ELSE 
BEGIN 

			 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'Func' AND Object_ID = Object_ID('RDT.RDTSCNHeader'))
			BEGIN

				ALTER TABLE [RDT].[RDTSCNHeader] ADD Func [int] NULL ;
				EXEC sp_addextendedproperty N'MS_Description', 'Func', 'SCHEMA', N'RDT', 'TABLE', N'RDTSCNHeader', 'COLUMN', N'Func'
				
			END

			 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'Scn_SeqNo' AND Object_ID = Object_ID('RDT.RDTSCNHeader'))
			BEGIN

				ALTER TABLE [RDT].[RDTSCNHeader] ADD Scn_SeqNo [int] NULL ;
				EXEC sp_addextendedproperty N'MS_Description', 'Scn_SeqNo', 'SCHEMA', N'RDT', 'TABLE', N'RDTSCNHeader', 'COLUMN', N'Scn_SeqNo'
				
			END

			 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'ScreenFormat' AND Object_ID = Object_ID('RDT.RDTSCNHeader'))
			BEGIN

				ALTER TABLE [RDT].[RDTSCNHeader] ADD ScreenFormat  [nvarchar] (10) CONSTRAINT [DF_rdtScnHeader_ScreenFormat] DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'ScreenFormat', 'SCHEMA', N'RDT', 'TABLE', N'RDTSCNHeader', 'COLUMN', N'ScreenFormat'
				
			END


END



