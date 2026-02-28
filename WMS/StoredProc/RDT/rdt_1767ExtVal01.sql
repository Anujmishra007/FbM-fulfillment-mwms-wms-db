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
/* 2026-02-24 1.1.0  NickT      UWP-48421 Block function if UCC is 3,4,H, */
/*                              and it is in other location               */
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

   DECLARE @cSuggestLoc NVARCHAR(10)

   SELECT @cSuggestLoc = V_Loc
   FROM RDT.RDTMOBREC (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1767 -- TM Cycle Count UCC
   BEGIN
      IF @nStep = 1 -- UCC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @cUCCStatus     NVARCHAR( 1)
            DECLARE @cUCCLoc        NVARCHAR( 10)
            SET @cUCCStatus = ''

            SELECT @cUCCStatus = Status,
               @cUCCLoc = Loc
            FROM dbo.UCC WITH ( NOLOCK )
            WHERE StorerKey = @cStorerKey
              AND UCCNo = @cUCC

            IF @cSuggestLoc <> @cUCCLoc
            BEGIN
               IF @cUCCStatus = '3'
               BEGIN
                  SET @nErrNo = 245702
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UCC is allocated in different location'
                  GOTO Quit
               END
               ELSE IF @cUCCStatus = '4'
               BEGIN
                  SET @nErrNo = 245703
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UCC is allocated in different location'
                  GOTO Quit
               END
               ELSE IF @cUCCStatus = 'H'
               BEGIN
                  SET @nErrNo = 245704
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UCC is on Hold in different location'
                  GOTO Quit
               END
            END

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
