SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: TouchPadAddMsg                                       */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2023-03-17 1.0  yeekung  Created                                     */
/* 2024-01-21 1.1  YeeKung  TPS-995 Remove add System message (yeekung01)*/
/************************************************************************/

CREATE OR ALTER PROCEDURE API.TouchPadAddMsg  (
   @nMsgID        INT, 
   @nSeverity     INT, 
   @nMsg          nvarchar(255), 
   @cLang         sysname = 'us_english' , 
   @nFuncID       int = 0, 
   @nEventType    int = 0   
)
AS
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLangCode NVARCHAR(3)

   IF @cLang = 'ENG' 
      SET @cLang = 'us_english'

   IF @cLang = 'us_english'
      SET @cLangCode = 'ENG'
   ELSE
      SET @cLangCode = @cLang
       
   -- Add message to RDT
   IF EXISTS (SELECT Message_ID FROM API.TouchPadErrmsg 
      WHERE Message_ID = @nMsgID
         AND Lang_Code = @cLangCode
         AND Message_Type = 'DSP' )
      PRINT 'Message ' + LTRIM( CAST( @nMsgID AS NVARCHAR( 10))) + ' already exists in API.TouchPadGetMessage'
   ELSE
      INSERT INTO API.TouchPadErrmsg (Message_ID, Lang_Code, Message_Type, Message_Text, EventType)
      VALUES (@nMsgID, @cLangCode, 'DSP', @nMsg, @nEventType )  
