SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1764ExtValid02                                        */
/* Purpose:                                                                   */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2025-06-16   Dennis    1.0.0 FCR-3959 Created                              */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764ExtValid02
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cFacility         NVARCHAR( 5)
   DECLARE @cSuggSKU          NVARCHAR( 20)
   DECLARE @cSuggFromLOC      NVARCHAR( 10)
   DECLARE @cPQTY             NVARCHAR( 5)
   DECLARE @cMQTY             NVARCHAR( 5)
   DECLARE @cFieldAttr14      NVARCHAR( 1)
   DECLARE @cFieldAttr15      NVARCHAR( 1)
   DECLARE @cOutField14       NVARCHAR( 60)
   DECLARE @cOutField15       NVARCHAR( 60)
   DECLARE @cInField14        NVARCHAR( 60)
   DECLARE @cInField15        NVARCHAR( 60)
   DECLARE @cPUOM             NVARCHAR( 1)
   DECLARE @nQTY_RPL          INT
   DECLARE @nQTY              INT

   SELECT @cFacility = Facility, 
          @cFieldAttr14 = FieldAttr14, 
          @cFieldAttr15 = FieldAttr15, 
          @cInField14 = I_Field14, 
          @cInField15 = I_Field15, 
          @cOutField14 = O_Field14, 
          @cOutField15 = O_Field15,
          @cPUOM  = V_UOM,
          @cStorerKey = StorerKey
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 4 -- UCC/Qty
      BEGIN
         SELECT
            @cSuggSKU = Sku,
            @cSuggFromLOC = FromLOC,
            @nQTY_RPL     = QTY
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey

         SET @cPQTY = CASE WHEN @cFieldAttr14 = 'O' THEN @cOutField14 ELSE @cInField14 END
         SET @cMQTY = CASE WHEN @cFieldAttr15 = 'O' THEN @cOutField15 ELSE @cInField15 END

         -- Calc total QTY in master UOM
         SET @nQTY = rdt.rdtConvUOMQTY( @cStorerKey, @cSuggSKU, @cPQTY, @cPUOM, 6) -- Convert to QTY in master UOM
         SET @nQTY = @nQTY + CAST( @cMQTY AS INT)

         IF @nQty <> 0 AND @nQty <> @nQTY_RPL
         BEGIN
            SET @nErrNo = 240201
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Qty
            GOTO Quit
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

GRANT EXECUTE ON rdt.rdt_1764ExtValid02 TO NSQL
GO