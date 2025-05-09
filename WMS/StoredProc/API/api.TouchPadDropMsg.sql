
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: TouchPadDropMsg                                     */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2023-03-17 1.0  yeekung  Created                                     */
/* 2024-01-21 1.1  YeeKung  TPS-995 Remove add System message (yeekung01)*/
/************************************************************************/

CREATE OR ALTER PROCEDURE API.TouchPadDropMsg 
   @nMsgIDFrom INT, 
   @nMsgIDTo   INT = NULL, 
   @cLangCode  NVARCHAR(3) = 'ENG'
AS BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nMsgIDTo IS NULL
      SET @nMsgIDTo = @nMsgIDFrom

   DECLARE @tMsg TABLE
   (
      ERROR INT
   )

   SET NOCOUNT ON
   INSERT INTO @tMsg
   SELECT Message_ID 
   FROM API.TouchPadErrmsg 
   WHERE Message_ID BETWEEN @nMsgIDFrom AND @nMsgIDTo

   DECLARE @nError INT
   DECLARE @curMsg CURSOR
   SET @curMsg = CURSOR LOCAL FAST_FORWARD FOR
      SELECT ERROR FROM @tMsg
   OPEN @curMsg 
   FETCH NEXT FROM @curMsg INTO @nError
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Drop message on RDT
      DELETE API.TouchPadErrmsg 
      WHERE Lang_Code = @cLangCode
         AND Message_Type = 'DSP'
         AND Message_ID = @nError
      IF @@ROWCOUNT = 1
         PRINT 'Message ' + LTRIM( CAST( @nError AS NVARCHAR( 10))) + ' deleted in api.TouchPadErrmsg'
      ELSE
         PRINT 'Message ' + LTRIM( CAST( @nError AS NVARCHAR( 10))) + ' NOT FOUND in api.TouchPadErrmsg'

      FETCH NEXT FROM @curMsg INTO @nError
   END
   SET NOCOUNT OFF
END
