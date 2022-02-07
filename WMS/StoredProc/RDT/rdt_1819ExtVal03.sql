IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdt_1819ExtVal03]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [rdt].[rdt_1819ExtVal03]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1819ExtVal03                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 31-07-2017  1.0  Ung      WMS-2528 Created                           */
/************************************************************************/

CREATE PROC [rdt].[rdt_1819ExtVal03] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFromID         NVARCHAR( 18),
   @cSuggLOC        NVARCHAR( 10),
   @cPickAndDropLOC NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 1819 -- Putaway by ID
   BEGIN
      IF @nStep = 2 -- ToLoc
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Check override suggested LOC
            IF @cSuggLOC <> '' AND @cToLOC <> @cSuggLOC
            BEGIN
               -- Check ToLOC is VNA
               IF EXISTS( SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC AND LocationCategory = 'VNA')
               BEGIN
                  -- Check ToLOC has inventory
                  IF EXISTS( SELECT TOP 1 1 FROM dbo.LOTxLOCxID WITH (NOLOCK) WHERE QTY - QTYPicked > 0)
                  BEGIN
                     SET @nErrNo = 113151
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Unusable LOC
                     GOTO Quit
                  END
               END
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

GRANT EXECUTE ON [rdt].[rdt_1819ExtVal03] TO NSQL
GO
