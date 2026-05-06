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
      @cUserName           NVARCHAR(128),
      @cSKUVerified        NVARCHAR(20),
      @nQty                INT,
      @nTaskQTY            INT,
      @cAreaKey            NVARCHAR(20),
      @cPickMethod         NVARCHAR(10),
	  @cFromLoc            NVARCHAR(20)

   SELECT TOP 1
      @cFacility    = Facility,
      @cStorerKey   = StorerKey,
      @cUserName    = UserName,
      @nInputKey    = InputKey,
      @cSKUVerified = ISNULL(V_String25,0),
      @nQty         = I_Field15
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SELECT TOP 1 @nTaskQTY = Qty, @cAreaKey = AreaKey, @cPickMethod = PickMethod FROM TaskDetail WITH(NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 4 -- Qty
      BEGIN
         IF @nInputKey = 1 --Enter
         BEGIN
            IF (@cSKUVerified <> '1' AND @nQty <> 0 AND @nQty <> @nTaskQTY)
            OR (@cSKUVerified = '1' AND @nQty <> @nTaskQTY)
               BEGIN
                  SET @nErrNo = 218269
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
         END
      END

      IF @nStep = 6 -- ToLoc
      BEGIN
         SELECT
            @cSuggToLOC       = ToLOC,
            @cSuggSKU         = SKU,
			@cFromLoc         = FromLoc
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND TaskDetailKey = @cTaskDetailKey

         IF @cToLOC <> @cSuggToLOC 
         AND NOT EXISTS(SELECT 1 FROM LOC (NOLOCK) 
         WHERE LOC = @cToLOC AND LocationCategory = 'INTRANSIT' AND Facility = @cFacility AND @cAreaKey = 'MOTHERSONS' AND @cPickMethod = 'PP')
         BEGIN
            SET @nErrNo = 180041
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Location
            GOTO QUIT
         END

		 IF EXISTS(
		    SELECT 1 FROM LOC (NOLOCK) 
            WHERE LOC = @cToLOC 
			   AND LocationCategory = 'INTRANSIT' 
			   AND Facility = @cFacility 
			   AND @cAreaKey = 'MOTHERSONS'
	     )
		 AND EXISTS(
		    SELECT 1 FROM LOC (NOLOCK) 
            WHERE LOC = @cFromLoc 
			   AND LocationCategory = 'INTRANSIT' 
			   AND Facility = @cFacility 
			   AND @cAreaKey = 'MOTHERSONS'
	     )
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
