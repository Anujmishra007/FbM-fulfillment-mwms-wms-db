SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_593ReleaseTote                                     */
/* Copyright: Maersk                                                       */
/* Customer: USA Levis                                                     */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2026-05-12 1.0  NickT    FCR-12667  Created                             */
/* 2026-05-20 2.0  AKH114   UWP-57077                                      */
/***************************************************************************/

CREATE OR ALTER PROC rdt.rdt_593ReleaseTote (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 5),
   @cParam1    NVARCHAR(20),  -- DropID
   @cParam2    NVARCHAR(20),
   @cParam3    NVARCHAR(20),
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE 
   @cDropID       NVARCHAR(20)

   SET @cDropID = ISNULL(TRIM(@cParam1), '')

   IF @cDropID = ''
   BEGIN
      SET @nErrNo  = 266251
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- DropID Required
      GOTO Quit
   END


   BEGIN TRY
      EXEC RDT.isp_ArchiveDropId_rdt
         @cToteID             = @cDropID
         ,@cStorerKey         = @cStorerKey
         ,@cPrefix            = ''
         ,@cLangCode          = @cLangCode
         ,@nErrNo             = @nErrNo OUTPUT
         ,@cErrMsg            = @cErrMsg OUTPUT
   END TRY
   BEGIN CATCH
      SET @nErrNo  = 266254
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --  Execute isp_ArchiveDropId_rdt failed
      GOTO Quit
   END CATCH

   IF @nErrNo <> 0
   BEGIN
      GOTO Quit
   END

   IF EXISTS(SELECT 1 
            FROM dbo.Transmitlog2 WITH (NOLOCK) 
            WHERE TableName = 'WSSortTotRel' 
               AND Key1 = @cDropID
               AND Key3 = @cStorerKey)
   BEGIN
      DECLARE 
            @cMsg01 NVARCHAR(20) = @cDropID,
            @cMsg02 NVARCHAR(20) = 'Tote has been', 
            @cMsg03 NVARCHAR(20) = 'archived and ', 
            @cMsg04 NVARCHAR(20) = 'released.', 
            @cMsg05 NVARCHAR(20) = '',
            @cMsg06 NVARCHAR(20) = '', 
            @cMsg07 NVARCHAR(20) = '', 
            @cMsg08 NVARCHAR(20) = '', 
            @cMsg09 NVARCHAR(20) = ''
      EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
         @nErrNo = @nErrNo,
         @cErrMsg = @cErrMsg,
         @cLine01 = @cMsg01,
         @cLine02 = @cMsg02,
         @cLine03 = @cMsg03,
         @cLine04 = @cMsg04,
         @cLine05 = @cMsg05,
         @cLine06 = @cMsg06,
         @cLine07 = @cMsg07,
         @cLine08 = @cMsg08,
         @cLine09 = @cMsg09,
         @nDisplayMsg = 0
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_593ReleaseTote TO NSQL
GO