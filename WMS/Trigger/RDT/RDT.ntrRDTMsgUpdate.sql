SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE TRIGGER [RDT].[ntrRDTMsgUpdate]
ON  [RDT].[RDTMsg]
FOR UPDATE
AS
IF @@ROWCOUNT = 0
BEGIN
RETURN
END
   SET NOCOUNT ON
   SET ANSI_NULLS OFF   
   SET QUOTED_IDENTIFIER OFF
	 SET CONCAT_NULL_YIELDS_NULL OFF
	 
   DECLARE @nMessage_ID INT
   DECLARE @cLang_Code  NVARCHAR( 3)
   DECLARE @cMessage_Type NVARCHAR( 3)
   DECLARE @cMessage_Text NVARCHAR( 125)

   SET @nMessage_ID = 0
   SET @cLang_Code = ''
   SET @cMessage_Type = ''

   WHILE (1=1)
   BEGIN
      SELECT TOP 1
         @nMessage_ID = Message_ID, 
         @cLang_Code = Lang_Code, 
         @cMessage_Type = Message_Type, 
         @cMessage_Text = Message_Text
      FROM inserted
      WHERE (CAST( Message_ID AS NVARCHAR( 5)) + Lang_Code + Message_Type) >
            (CAST( @nMessage_ID AS NVARCHAR( 5)) + @cLang_Code + @cMessage_Type)
      ORDER BY CAST( Message_ID AS NVARCHAR( 5)) + Lang_Code + Message_Type

      IF @@ROWCOUNT = 0 
         BREAK

      IF @cMessage_Type = 'DSP'
         -- Change the message from ''99999 XXXXXX...'' to ''99999^XXXXXX...''
         -- Handheld will produce a beep sound when encounter ''^'' character
         IF IsNumeric( LEFT( @cMessage_Text, 5)) = 1 AND SUBSTRING( @cMessage_Text, 6, 1) = ' '
            UPDATE RDT.RDTMsg SET
               Message_Text = IsNULL( STUFF( @cMessage_Text, 6, 1, '^'), @cMessage_Text)
            WHERE Message_ID = @nMessage_ID
               AND Lang_Code = @cLang_Code
               AND Message_Type = @cMessage_Type
   END

GO