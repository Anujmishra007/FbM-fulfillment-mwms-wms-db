IF NOT EXISTS ( SELECT * FROM SYS.objects WHERE object_id = OBJECT_ID (N'[RDT].[RDTMsg]'))
BEGIN
CREATE TABLE [RDT].[RDTMsg]
(
[Message_ID] [int] NOT NULL,
[Lang_Code] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Message_Type] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Message_Text] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StoredProcName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMsg_StoredProcName] DEFAULT (''),
[EventType] [int] NOT NULL CONSTRAINT [DF_RDTMsg_EventType] DEFAULT ((0)),
[Func] [int] NULL CONSTRAINT [DF_RDTMsg_Func] DEFAULT ((0)),
[URL] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTMsg_URL] DEFAULT (''),
[DMLoadSQL] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMsg_DMLoadSQL] DEFAULT (''),
[DMSaveSQL] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTMsg_DMSaveSQL] DEFAULT (''),
[Scn] [int] NOT NULL CONSTRAINT [DF_RDTMsg_Scn] DEFAULT ((0)),
[Message_Text_Long] [NVARCHAR] (250) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL CONSTRAINT DF_RDTMsg_Message_Text_Long DEFAULT('')
) ON [PRIMARY]



ALTER TABLE [RDT].[RDTMsg] ADD CONSTRAINT [PK_RDTMsg] PRIMARY KEY CLUSTERED ([Message_ID], [Lang_Code], [Message_Type]) WITH (FILLFACTOR=90) ON [PRIMARY]

GRANT DELETE ON  [RDT].[RDTMsg] TO [NSQL]

GRANT INSERT ON  [RDT].[RDTMsg] TO [NSQL]

GRANT SELECT ON  [RDT].[RDTMsg] TO [NSQL]

GRANT UPDATE ON  [RDT].[RDTMsg] TO [NSQL]

END

ELSE 
BEGIN 


		IF NOT EXISTS ( SELECT * FROM SYS.columns WHERE NAME ='DMLoadSQL' AND object_id =OBJECT_ID (N'[RDT].[RDTMsg]'))
		BEGIN 
			ALTER TABLE [RDT].[RDTMsg]
			ADD [DMLoadSQL] [nvarchar](4000) NOT NULL CONSTRAINT [DF_RDTMsg_DMLoadSQL] DEFAULT ('');
			EXEC sp_addextendedproperty N'MS_Description', N'DMLoadSQL', 'SCHEMA', N'RDT', 'TABLE', N'RDTMsg', 'COLUMN', N'DMLoadSQL'

		END 


		IF NOT EXISTS ( SELECT * FROM SYS.columns WHERE NAME ='DMSaveSQL' AND object_id =OBJECT_ID (N'[RDT].[RDTMsg]'))
		BEGIN 
			ALTER TABLE [RDT].[RDTMsg]
			ADD [DMSaveSQL] [nvarchar](4000) NOT NULL CONSTRAINT [DF_RDTMsg_DMSaveSQL] DEFAULT ('');
			EXEC sp_addextendedproperty N'MS_Description', N'DMSaveSQL', 'SCHEMA', N'RDT', 'TABLE', N'RDTMsg', 'COLUMN', N'DMSaveSQL'

		END 


		IF NOT EXISTS ( SELECT * FROM SYS.columns WHERE NAME ='Scn' AND object_id =OBJECT_ID (N'[RDT].[RDTMsg]'))
		BEGIN 
			ALTER TABLE [RDT].[RDTMsg]
			ADD [Scn] [int] NOT NULL CONSTRAINT [DF_RDTMsg_Scn] DEFAULT ((0));
			EXEC sp_addextendedproperty N'MS_Description', N'Scn', 'SCHEMA', N'RDT', 'TABLE', N'RDTMsg', 'COLUMN', N'Scn'

		END 
END




--SET QUOTED_IDENTIFIER OFF
--GO
--SET ANSI_NULLS OFF
--GO

--CREATE TRIGGER [RDT].[ntrRDTMsgUpdate]
--ON  [RDT].[RDTMsg]
--FOR UPDATE
--AS
--IF @@ROWCOUNT = 0
--BEGIN
--RETURN
--END
--   SET NOCOUNT ON
--   SET ANSI_NULLS OFF   
--   SET QUOTED_IDENTIFIER OFF
--	 SET CONCAT_NULL_YIELDS_NULL OFF
	 
--   DECLARE @nMessage_ID INT
--   DECLARE @cLang_Code  NVARCHAR( 3)
--   DECLARE @cMessage_Type NVARCHAR( 3)
--   DECLARE @cMessage_Text NVARCHAR( 125)

--   SET @nMessage_ID = 0
--   SET @cLang_Code = ''
--   SET @cMessage_Type = ''

--   WHILE (1=1)
--   BEGIN
--      SELECT TOP 1
--         @nMessage_ID = Message_ID, 
--         @cLang_Code = Lang_Code, 
--         @cMessage_Type = Message_Type, 
--         @cMessage_Text = Message_Text
--      FROM inserted
--      WHERE (CAST( Message_ID AS NVARCHAR( 5)) + Lang_Code + Message_Type) >
--            (CAST( @nMessage_ID AS NVARCHAR( 5)) + @cLang_Code + @cMessage_Type)
--      ORDER BY CAST( Message_ID AS NVARCHAR( 5)) + Lang_Code + Message_Type

--      IF @@ROWCOUNT = 0 
--         BREAK

--      IF @cMessage_Type = 'DSP'
--         -- Change the message from ''99999 XXXXXX...'' to ''99999^XXXXXX...''
--         -- Handheld will produce a beep sound when encounter ''^'' character
--         IF IsNumeric( LEFT( @cMessage_Text, 5)) = 1 AND SUBSTRING( @cMessage_Text, 6, 1) = ' '
--            UPDATE RDT.RDTMsg SET
--               Message_Text = IsNULL( STUFF( @cMessage_Text, 6, 1, '^'), @cMessage_Text)
--            WHERE Message_ID = @nMessage_ID
--               AND Lang_Code = @cLang_Code
--               AND Message_Type = @cMessage_Type
--   END
