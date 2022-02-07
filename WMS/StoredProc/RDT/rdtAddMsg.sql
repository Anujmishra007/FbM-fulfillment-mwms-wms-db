if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdtAddMsg]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdtAddMsg]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/******************************************************************************/ 
/* Copyright: IDS                                                             */ 
/* Purpose: Add RDT MSG to Master and RDTMSG Table                            */ 
/*                                                                            */ 
/* Modifications log:                                                         */ 
/*                                                                            */ 
/* Date       Rev  Author     Purposes                                        */ 
/* 2006-09-26 1.0             Created                                         */ 
/* 2011-09-11 1.1  Vicky      Add in EventType                                */  
/* 2012-02-23 1.2  ChewKP     Add in Func (ChewKP01)                          */
/* 2013-10-01 1.3  Ung        Support multi language                          */
/******************************************************************************/

CREATE PROCEDURE rdt.rdtAddMsg (
   @nMsgID        INT, 
   @nSeverity     INT, 
   @nMsg          nvarchar(255), 
   @cLang         sysname = 'us_english' , 
   @nFuncID       int = 0, -- (ChewKP01)
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
       
   -- Add message to SQL
   IF EXISTS (SELECT error FROM master.dbo.sysmessages WHERE error = @nMsgID)
   BEGIN
      IF @cLangCode = 'ENG'
         PRINT 'Message ' + LTRIM( CAST( @nMsgID AS NVARCHAR( 10))) + ' already exists in master.dbo.sysmessages'
   END
   ELSE
      EXECUTE master.dbo.sp_addmessage @nMsgID, @nSeverity, @nMsg, @cLang
      
   -- Add message to RDT
   IF EXISTS (SELECT Message_ID FROM rdt.RDTMsg 
      WHERE Message_ID = @nMsgID
         AND Lang_Code = @cLangCode
         AND Message_Type = 'DSP' )
      PRINT 'Message ' + LTRIM( CAST( @nMsgID AS NVARCHAR( 10))) + ' already exists in rdt.RDTMsg'
   ELSE
      INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, EventType, Func) -- (ChewKP01)
      VALUES (@nMsgID, @cLangCode, 'DSP', @nMsg, @nEventType , @nFuncID)  -- (ChewKP01)
GO
GRANT EXECUTE ON RDT.rdtAddMsg TO NSQL
GO
