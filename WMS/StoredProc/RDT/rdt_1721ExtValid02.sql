SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**************************************************************************/
/* Store procedure: rdt_1721ExtValid02                                    */
/* Copyright      : Maersk                                                */
/* Customer       : Levis                                                 */
/*                                                                        */
/* Called from: rdtfnc_Pallet_Move                                        */
/*                                                                        */
/* Purpose: Check ID                                                      */
/*                                                                        */
/* Modifications log:                                                     */
/* Date        Rev    Author   Purposes                                   */
/* 2025-08-27  1.0.0  NickT    FCR-7160 Validation to stop UR to QI loc   */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1721ExtValid02] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 15),
   @cStorer          NVARCHAR( 15),
   @cID              NVARCHAR( 20),
   @cToLOC           NVARCHAR( 10),
   @cSuggestLoc      NVARCHAR( 15),
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
BEGIN
   

   IF @nFunc = 1721 -- Pallet Move
   BEGIN
      IF @nStep = 2 -- Scan To Location
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE 
               @cFromLOC               NVARCHAR( 10),
               @cFromLocHOSTWHCODE     NVARCHAR( 10),
               @cToLocHOSTWHCODE       NVARCHAR( 10)

            SELECT TOP 1 @cFromLOC = Loc
            FROM dbo.PalletDetail WITH (NOLOCK)
            WHERE PalletKey = @cID

            SELECT @cFromLocHOSTWHCODE = HOSTWHCODE
            FROM dbo.LOC WITH(NOLOCK)
            WHERE LOC = @cFromLOC

            SELECT @cToLocHOSTWHCODE = HOSTWHCODE
            FROM dbo.LOC WITH(NOLOCK)
            WHERE LOC = @cToLOC
            
            IF @cFromLocHOSTWHCODE = 'UR' AND @cToLocHOSTWHCODE = 'QI'
            BEGIN
               SET @nErrNo = 245451
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ToLoc is QI
               GOTO Quit
            END
         END
      END
   END

   Quit:


END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1721ExtValid02 TO NSQL
GO
