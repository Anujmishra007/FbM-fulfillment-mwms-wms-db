SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/********************************************************************************/
/* Store procedure: rdt_1764ExtValid04                                          */
/* Purpose  :                                                                   */
/* Customer : USA Levis                                                         */
/*                                                                              */
/* Modifications log:                                                           */
/*                                                                              */
/* Date         Author    Ver.    Purposes                                      */
/* 2025-09-10   NickT     1.0.0   FCR-7730 If suggested loc is PND,             */
/*                                user only can scan PND location               */
/* 2025-10-15   NickT     1.1.0   FCR-7928 Cannot go back if task is short      */
/********************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764ExtValid04
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
      @nInputKey           INT

   SELECT 
      @cFacility     = Facility,
      @cStorerKey    = StorerKey,
      @nInputKey     = InputKey
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 5 -- Next Task
      BEGIN
         IF @nInputKey = 0 -- ESC
         BEGIN
            -- Current task is SHORT, cannot go back
            IF EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey AND Status = '9')
               AND EXISTS (SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey AND Status = '4' AND Qty = 0)
            BEGIN
               SET @nErrNo = 246603
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Task is SHORT, cannot go back
               GOTO Quit
            END
         END
      END
      ELSE IF @nStep = 6 -- ToLoc
      BEGIN
         SELECT
            @cSuggToLOC       = ToLOC,
            @cSuggSKU         = SKU
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND TaskDetailKey = @cTaskDetailKey

         -- If SKU is SORTABLE AND CONVEYABLE, ToLoc is a PND Location, display PND as suggested location.
         -- Else display TaskDetail.ToLoc as suggested location
         IF EXISTS (SELECT 1 
                     FROM dbo.SKUInfo WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND SKU = @cSuggSKU
                        AND ISNULL(ExtendedField06, '') = 'SORTABLE'
                        AND ISNULL(ExtendedField07, '') = 'CONVEYABLE')
            AND EXISTS (SELECT 1
                        FROM dbo.LOC WITH(NOLOCK)
                        WHERE Facility = @cFacility
                           AND Loc = @cSuggToLOC
                           AND LocationType = 'PND')
         BEGIN
            SELECT @cToLocType = LocationType
            FROM dbo.LOC WITH(NOLOCK)
            WHERE Facility = @cFacility
               AND Loc = @cToLoc

            IF ISNULL(@cToLocType, '') <> 'PND'
            BEGIN
               SET @nErrNo = 246601
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location is not PND
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            IF @cSuggToLOC <> @cToLoc
            BEGIN
               SET @nErrNo = 246602
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLoc is different as suggested Loc
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

GRANT EXECUTE ON rdt.rdt_1764ExtValid04 TO NSQL
GO