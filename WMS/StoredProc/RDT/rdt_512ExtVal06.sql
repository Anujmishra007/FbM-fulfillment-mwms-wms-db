SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_512ExtVal06                                     */
/* Customer: Maersk WMS                                                 */
/* Purpose: For ONBR                                                    */
/*                                                                      */
/* Called from: rdtfnc_Move_LOC                                         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2025-12-11  1.0  ELB012     UWP-45367 PROJECT - RITM8172881          */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_512ExtVal06] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15), 
   @cFromLOC         NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @cToID            NVARCHAR( 18),
   @cOption          NVARCHAR( 1), 
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   IF @nFunc = 512 -- Move by LOC
   BEGIN      
      IF @nStep = 2 -- To LOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @cToIDMandatory           NVARCHAR(30)
               
            SET @cToIDMandatory = rdt.RDTGetConfig( @nFunc, 'ToIDMandatory', @cStorerKey)

            IF @cToIDMandatory = '1'
            BEGIN
               IF @cToID = ''
               BEGIN
                  SET @nErrNo = 253501
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --Need To ID
                  GOTO QUIT
               END 
            END

            IF EXISTS(SELECT 1 FROM DBO.LOTXLOCXID WITH (NOLOCK) WHERE ID = @cToID AND QTY > 0 AND LOC <> @cFromLOC AND StorerKey = @cStorerKey)
            BEGIN
               SET @nErrNo = 253502
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --ID IN USE
               GOTO QUIT
            END
         END
      END
   END

QUIT:
END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_512ExtVal06 TO NSQL
GO
