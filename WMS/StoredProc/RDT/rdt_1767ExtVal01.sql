SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/**************************************************************************/
/* Store procedure: rdt_1767ExtVal01                                      */
/* Copyright: LF Logistics                                                */
/*                                                                        */
/* Purpose: Check empty pallet                                            */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2025-08-29 1.0.0  NickT      UWP-40373 Levis UCC counting validation   */
/**************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1767ExtVal01 (
   @nMobile             INT,           
   @nFunc               INT,           
   @cLangCode           NVARCHAR( 3),  
   @nStep               INT,           
   @nInputKey           INT,           
   @cFacility           NVARCHAR( 5), 
   @cStorerKey          NVARCHAR( 15), 
   @cTaskDetailKey      NVARCHAR( 10),
   @cUCC                NVARCHAR( 20), 
   @nErrNo              INT            OUTPUT, 
   @cErrMsg             NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 1767 -- TM Cycle Count UCC
   BEGIN
      IF @nStep = 1 -- UCC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @cUCCStatus     NVARCHAR( 1)
            SET @cUCCStatus = ''

            SELECT @cUCCStatus = Status
            FROM dbo.UCC WITH ( NOLOCK )
            WHERE StorerKey = @cStorerKey
              AND UCCNo = @cUCC

            IF @cUCCStatus IN ('5','6') -- replenished to/picking done
            BEGIN
               SET @nErrNo = 245701
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UCC Does Not Exist'
               GOTO Quit
            END
         END
      END
   END
END

Quit:
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_1767ExtVal01] TO nSQL 
GO
