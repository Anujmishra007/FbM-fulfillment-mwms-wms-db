SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/******************************************************************************/
/* Copyright: MaerSK                                                          */
/*                                                                            */
/* Purpose: Check if the request is a duplicate one, if yes, return outMessage*/
/*                                                                            */
/* Updates:                                                                   */
/* Date         Author   Rev  Purposes                                        */
/* 2025-11-06   NickT    1.0  UWP-43698 Create                                */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdtCheckDuplicateRequest] (
   @nMobile       INT,
   @cInMessage    NVARCHAR(1024),  
   @nErrNo        INT               OUTPUT,
   @cErrMsg       NVARCHAR( 1024)   OUTPUT,
   @OutMessage    NVARCHAR(MAX)     OUTPUT,
   @nDuplicateRequestFlag INT         OUTPUT,
   @cTraceID      NVARCHAR( 100)    OUTPUT
)
AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE
      @nStartIndex INT,
      @nLength     INT

   SET @nDuplicateRequestFlag = 0

   -- Get TraceID
   SET @cTraceID = ''
   SET @nStartIndex = CHARINDEX( 'traceID="', @cInMessage)
   IF @nStartIndex > 0
   BEGIN
      SET @nStartIndex = @nStartIndex + LEN( 'traceID="')
      SET @nLength = CHARINDEX( '"', SUBSTRING( @cInMessage, @nStartIndex, LEN( @cInMessage)))
      SET @cTraceID = SUBSTRING( @cInMessage, @nStartIndex, ABS( @nLength - 1))
   END

   IF ISNULL(@cTraceID, '') <> ''
   BEGIN
      SET @OutMessage = ''

      SELECT @OutMessage = MessageOut 
      FROM RDT.RDTMOBTraceID WITH (NOLOCK) 
      WHERE Mobile = @nMobile 
         AND TraceID = @cTraceID

      IF @@ROWCOUNT > 0
         SET @nDuplicateRequestFlag = 1

      IF @OutMessage IS NOT NULL AND TRIM(@OutMessage) <> ''
         RETURN
      ELSE
      BEGIN
         SET @OutMessage =
            '<tordt number="' + RTRIM( CAST( @nMobile AS NVARCHAR( 10))) + '" status="CHKEXE">' +
               '<field typ="output" x="00" y="01" value="Execution is"/>' +
               '<field typ="output" x="00" y="02" value="in progress,"/>' +
               '<field typ="output" x="00" y="03" value="please wait."/>' +
            '</tordt>'
      END
      RETURN
   END

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdtCheckDuplicateRequest TO NSQL
GO
