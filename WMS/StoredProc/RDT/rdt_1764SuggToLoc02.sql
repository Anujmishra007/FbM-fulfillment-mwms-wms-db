SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1764SuggToLoc02                                       */
/* Copyright      : Maersk                                                    */
/* Customer       : USA Levis                                                 */
/*                                                                            */
/* Date        Rev    Author    Purposes                                      */
/* 2025-09-10  1.0.0  NickT     FCR-7730. Display PND as suggested Loc        */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764SuggToLoc02] (
   @nMobile            INT,
   @nFunc              INT,
   @cLangCode          NVARCHAR( 3),
   @cUserName          NVARCHAR( 18),
   @cTaskDetailKey     NVARCHAR( 10),
   @cSuggToLOC         NVARCHAR( 10),
   @cNewSuggToLOC      NVARCHAR( 10) OUTPUT,
   @nErrNo             INT           OUTPUT,
   @cErrMsg            NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nCurrentStep        INT,
      @nInputKey           INT,
      @cOption             NVARCHAR(1),
      @cStorerKey          NVARCHAR(15),
      @cSuggSKU            NVARCHAR(20),
      @cFacility           NVARCHAR(5)

   SELECT 
      @nCurrentStep     = Step,
      @nInputKey        = InputKey,
      @cOption          = I_Field01,
      @cStorerKey       = StorerKey,
      @cFacility        = Facility
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1764
   BEGIN
      IF @nCurrentStep = 5 -- Next Task
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            IF @cOption = '9' -- Close Pallet
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
                  SET @cNewSuggToLOC = 'PND'
               END
               ELSE
                  SET @cNewSuggToLOC = @cSuggToLOC
            END
         END
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1764SuggToLoc02] TO NSQL
GO