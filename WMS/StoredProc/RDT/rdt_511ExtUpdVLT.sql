
/************************************************************************/
/* Store procedure: [rdt_511ExtUpdVLT]                                  */
/* Copyright: Maersk                                                    */
/*                                                                      */
/*                                                                      */
/* Date       VER    Author   Purpose                                   */
/* 15/07/24   1.0    PPA374	  Clearing outstanding pending moves        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtUpdVLT] (
@nMobile    INT,
@nFunc      INT,
@cLangCode  NVARCHAR( 3),
@nStep      INT,
@nInputKey  INT,
@cFacility  NVARCHAR( 5),
@cStorerKey NVARCHAR( 15),
@cFromID    NVARCHAR( 18),
@cFromLOC   NVARCHAR( 10),
@cToLOC     NVARCHAR( 10),
@nErrNo     INT           OUTPUT,
@cErrMsg    NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   IF @nStep = 3 -- To Loc
      -- Clearing outstanding pending moves, as since ID is moved, it is not required anymore.
      BEGIN
         update LOTxLOCxID
         set PendingMoveIN = 0
         where id = @cFromID and PendingMoveIN > 0 and StorerKey = @cStorerKey and ID <> ''
      END
END
GO
GRANT EXECUTE ON [RDT].[rdt_511ExtUpdVLT] TO [NSQL]
GO
