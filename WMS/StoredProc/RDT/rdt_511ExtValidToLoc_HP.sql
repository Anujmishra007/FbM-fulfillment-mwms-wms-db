SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: [rdt_511ExtValidToLoc_HP]                                 */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: CHECK LOC IS DAMAGE                                               */
/*                                                                            */
/* Date        Rev  Author     Purposes                                       */
/* 10-08-2025  1.0  JBI034     WMS-12635 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtValidToLoc_HP] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cFromID          NVARCHAR( 18),    
   @cFromLOC         NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @cToID            NVARCHAR( 18),
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

  IF @nFunc = 511 -- Move by ID
   BEGIN
      IF @nStep = 3 -- To LOC
          BEGIN
            IF @nInputKey = 1 -- ENTER
               BEGIN
                  IF (SELECT LocationFlag FROM dbo.LOC WHERE LOC = @cToLOC) = 'INACTIVE'
                     BEGIN
                        SET @nErrNo = 60511  -- LOCATION IS HOLD BUT LPN IS OK
                     GOTO Quit
                      END
               END
         END
   END


   QUIT:

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_511ExtValidToLoc_HP] TO NSQL
GO
