if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdtMsg2Script]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdtMsg2Script]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdtMsg2Script                                       */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Generate message script from database                       */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2012-04-28 1.0  Ung      Created                                     */
/* 2013-10-01 1.1  Ung      Support multi language                      */
/* 2014-01-08 1.2  KHLim    Use QUOTENAME function (KHLim01)            */
/************************************************************************/

CREATE PROC RDT.rdtMsg2Script
   @nMsgIDStart INT, 
   @nMsgIDEnd   INT = 0, 
   @nFuncID     INT = 0, 
   @cLangCode NVARCHAR( 3) = N'ENG'
AS
BEGIN
   IF @nMsgIDEnd = 0
      SET @nMsgIDEnd = @nMsgIDStart
   
   IF @nMsgIDStart <> @nMsgIDEnd
   BEGIN
      PRINT '-- ??'
      PRINT 'exec rdt.rdtDropMsg ' + 
         CAST( @nMsgIDStart AS NVARCHAR(10) ) + ', ' + 
         CAST( @nMsgIDEnd AS NVARCHAR(10) ) + 
         CASE WHEN @cLangCode = 'ENG' THEN '' ELSE ', ''' + @cLangCode + '''' END
      PRINT ''
   END
   
   DECLARE @cMsgText NVARCHAR(215)
   DECLARE @nMsgFuncID INT
   DECLARE @nMsgID INT

   DECLARE curMsg CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT Message_ID, ISNULL( Message_Text, ''), ISNULL( Func, 0)
      FROM RDT.RDTMSG WITH (NOLOCK)
      WHERE Message_ID >= @nMsgIDStart
         AND Message_ID <= @nMsgIDEnd
         AND Lang_Code = @cLangCode
      ORDER BY Message_ID
   OPEN curMsg
   FETCH NEXT FROM curMsg INTO @nMsgID, @cMsgText, @nMsgFuncID
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF RTRIM(@cMsgText) <> ''
         PRINT 'execute rdt.rdtAddMsg ' + 
            CAST( @nMsgID AS NVARCHAR(10) ) + 
            ', 10, ' + 
            'N' + QUOTENAME(LEFT( @cMsgText + SPACE(20), 20),'''') + ', ' +   --KHLim01
            'N''' + CASE WHEN @cLangCode = 'ENG' THEN 'us_english' ELSE @cLangCode END + ''' ' +
            CASE WHEN @nMsgFuncID <> 0 THEN ', ' + CAST( @nMsgFuncID AS NVARCHAR( 5)) 
                 WHEN @nFuncID <> 0 THEN ', ' + CAST( @nFuncID AS NVARCHAR( 5)) 
                 ELSE ''
            END
      
      FETCH NEXT FROM curMsg INTO @nMsgID, @cMsgText, @nMsgFuncID
   END
   CLOSE curMsg
   DEALLOCATE curMsg
END
GO
GRANT EXECUTE ON RDT.rdtMsg2Script TO NSQL
GO
