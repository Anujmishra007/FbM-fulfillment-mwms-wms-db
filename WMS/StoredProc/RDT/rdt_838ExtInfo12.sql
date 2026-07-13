SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtInfo12                                    */
/* Copyright      : Maersk                                              */
/* Customer       : AEOMX                                               */
/*                                                                      */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2026-07-01 1.0  JackC       FCR-12984 Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtInfo12] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @tVar           VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cSuggestedCartonType   NVARCHAR( 20) = '',
      @cFromDropID            NVARCHAR( 20) = '',
      @cPickStatus            NVARCHAR( 1) 
      
   IF @nFunc = 838 -- Pack
   BEGIN
      IF (@nStep = 1 AND @nAfterStep = 1)-- Scn 1 to Scn 2
         OR (@nStep = 5 AND @nAfterStep = 2) -- Scn 5 to Scn 2
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cFromDropID = Value FROM @tVar WHERE Variable = '@cFromDropID'

            IF @cFromDropID <> ''
            BEGIN
               SELECT TOP 1 
                  @cSuggestedCartonType = ISNULL(Cartontype, '') 
               FROM dbo.PickDetail WITH (NOLOCK) 
               WHERE StorerKey = @cStorerKey AND DropID = @cFromDropID
            END

            SET @cExtendedInfo = 'Carton Type: ' + @cSuggestedCartonType -- Remaining Pack Qty
            GOTO Quit   
         END
      END--st1>2, st5>2

      IF(@nStep = 3 AND @nAfterStep = 3) -- Scan SKU on st3
      BEGIN
         DECLARE 
            @nTotalPickQty INT = 0,
            @nTotalPackQty INT = 0,
            @nRemainingPackQty INT = 0
            
         SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerKey)
         IF @cPickStatus = '0'
            SET @cPickStatus = '5'

         SELECT @cFromDropID = Value FROM @tVar WHERE Variable = '@cFromDropID'
               
         SELECT @nTotalPickQty = SUM(Qty)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND DropID = @cFromDropID
            AND Status = @cPickStatus

         SELECT @nTotalPackQty = SUM(Qty)
         FROM dbo.PackDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND DropID = @cFromDropID

         SET @nRemainingPackQty = ISNULL(@nTotalPickQty,0) - ISNULL(@nTotalPackQty,0)

         SET @cExtendedInfo = 'REM to PACK: ' + ISNULL(TRY_CAST(@nRemainingPackQty AS NVARCHAR( 20)), '')
         GOTO Quit 
      END--st3
   END

   Quit:

END
GO

GRANT EXECUTE ON  [RDT].[rdt_838ExtInfo12] TO [NSQL]
GO
