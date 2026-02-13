SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/********************************************************************************/
/* Store procedure: rdt_1764ExtValid06                                          */
/* Purpose  :                                                                   */
/* Customer : USA Levis                                                         */
/*                                                                              */
/* Modifications log:                                                           */
/*                                                                              */
/* Date         Author    Ver.    Purposes                                      */
/* 2025-09-10   NickT     1.0.0   FCR-7730 If suggested loc is PND,             */
/********************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764ExtValid06
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @cTaskdetailKey  NVARCHAR( 10),
   @cToLoc          NVARCHAR( 10),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT,
   @nAfterStep      INT = 0,
   @cDropID         NVARCHAR( 20) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cSuggToLOC          NVARCHAR(10),
      @cToLocType          NVARCHAR(10),
      @cFacility           NVARCHAR(5),
      @cStorerKey          NVARCHAR(15),
      @cSuggSKU            NVARCHAR(20),
      @nInputKey           INT,
      @nCurrentStep        INT,
      @cUserName           NVARCHAR(128)

   SELECT 
      @cFacility = Facility,
      @cStorerKey = StorerKey,
      @cUserName = UserName,
      @nInputKey     = InputKey
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 6 -- ToLoc
      BEGIN
         SELECT
            @cSuggToLOC       = ToLOC,
            @cSuggSKU         = SKU
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND TaskDetailKey = @cTaskDetailKey

         IF @cToLOC <> @cSuggToLOC 
         AND NOT EXISTS(SELECT 1 FROM LOC (NOLOCK) 
         WHERE LOC = @cToLOC AND LocationCategory = 'INTRANSIT' AND Facility = @cFacility)
         BEGIN
            SET @nErrNo = 180041
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Location
            GOTO QUIT
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

GRANT EXECUTE ON rdt.rdt_1764ExtValid06 TO NSQL
GO