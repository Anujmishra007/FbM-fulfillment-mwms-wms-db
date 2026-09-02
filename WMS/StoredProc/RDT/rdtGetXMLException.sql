SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store Procedure: rdtGetXMLException                                        */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Build the <exception> XML node                                    */
/*                                                                            */
/* Date         Ver.  Author    Purposes                                      */
/* 2026-09-01   1.0.0 JackC     UWP-57695 Created                             */
/******************************************************************************/

CREATE OR ALTER PROC [rdt].[rdtGetXMLException]
(
   @nMobile         INT,
   @cTraceID        NVARCHAR(100)    = '',
   @cMobRecErrMsg   NVARCHAR(125),
   @cFacility       NVARCHAR(5)      = '',
   @cStorerKey      NVARCHAR(15)     = '',
   @cXMLException   NVARCHAR(MAX)    OUTPUT,
   @nErrNo          INT              OUTPUT,
   @cErrMsg         NVARCHAR(1024)   OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @cXMLException = ''
   SET @nErrNo        = 0
   SET @cErrMsg       = ''

   IF ISNULL(@cMobRecErrMsg,'') <> '' AND CHARINDEX('275451', ISNULL(@cMobRecErrMsg, '')) > 0
   BEGIN
      DECLARE @cExceptionMsg NVARCHAR(4000) = ''

      SELECT TOP 1 @cExceptionMsg = ISNULL(MsgData, '')
      FROM rdt.rdtLog WITH (NOLOCK)
      WHERE Mobile  = @nMobile
        AND MsgType = 'SQLException'
      ORDER BY RowRef DESC

      IF @cExceptionMsg <> ''
         SET @cXMLException = '<exception value="' + rdt.rdtReplaceSpecialCharInXMLData(@cExceptionMsg) + '"/>'
   END

Quit:
   RETURN
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdtGetXMLException] TO NSQL
GO
