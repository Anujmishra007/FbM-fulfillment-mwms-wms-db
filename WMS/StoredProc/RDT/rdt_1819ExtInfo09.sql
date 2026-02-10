SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1819ExtInfo09                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Customer: DAIMLER TRUCK AG                                           */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-02-10 1.0  Jackc    FCR-9755 Created                            */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1819ExtInfo09] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nAfterStep      INT,
   @nInputKey       INT,
   @cFromID         NVARCHAR( 18),
   @cSuggLOC        NVARCHAR( 10),
   @cPickAndDropLOC NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @cExtendedInfo   NVARCHAR( 20) OUTPUT,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
) AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cFacility   NVARCHAR( 5)
   DECLARE @cPAZone     NVARCHAR(20)
   DECLARE @cLocaisle     NVARCHAR(20)

   SELECT @cFacility = Facility FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nAfterStep = 5 -- Successful putaway
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         SET @cExtendedInfo = 'SCANNED: ' + @cToLOC
      END
   END
GO
GRANT EXECUTE ON  [RDT].[rdt_1819ExtInfo09] TO [NSQL]
GO
