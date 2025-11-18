SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtInfo07                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev Author      Purposes                                  */
/* 2025-11-17 1.0  NickT       UWP-43907 Merge from V0 WMS-25533        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtInfo07] (
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

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 3 AND  -- SKU QTY
         @nAfterStep = 3 -- Remain in same screen
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @nQTY INT = (SELECT TOP 1 Value FROM @tVar WHERE Variable = '@nQTY')
            
            -- Packed
            IF @nQTY > 0
            BEGIN
               DECLARE @cPickSlipNo NVARCHAR( 10) = (SELECT TOP 1 Value FROM @tVar WHERE Variable = '@cPickSlipNo')
               DECLARE @cFromDropID NVARCHAR( 20) = (SELECT TOP 1 Value FROM @tVar WHERE Variable = '@cFromDropID')
               DECLARE @cSKU        NVARCHAR( 20) = (SELECT TOP 1 Value FROM @tVar WHERE Variable = '@cSKU')
               DECLARE @cOrderKey   NVARCHAR( 10)
               DECLARE @cNotes      NVARCHAR( 500)
               
               -- Get pickslip info
               SELECT @cOrderKey = OrderKey FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo
               
               -- Get OrderDetail info
               SELECT TOP 1 
                  @cNotes = ISNULL( Notes, '')
               FROM dbo.OrderDetail WITH (NOLOCK) 
               WHERE OrderKey = @cOrderKey 
                  AND SKU = @cSKU
               ORDER BY OrderLineNumber
               
               -- Get PickDetail info
               DECLARE @nPickQTY INT
               SELECT @nPickQTY = ISNULL( SUM( QTY), 0)
               FROM dbo.PickDetail WITH (NOLOCK) 
               WHERE OrderKey = @cOrderKey 
                  AND DropID = @cFromDropID
               
               -- Get PickDetail info
               DECLARE @nPackQTY INT
               SELECT @nPackQTY = ISNULL( SUM( QTY), 0)
               FROM dbo.PackDetail WITH (NOLOCK) 
               WHERE PickSlipNo = @cPickSlipNo
                  AND DropID = @cFromDropID
               
               -- VAS label
               SET @cExtendedInfo = 
                  LEFT( 
                     CAST( @nPackQTY AS NVARCHAR( 5)) + '/' + 
                     CAST( @nPickQTY AS NVARCHAR( 5)) + ' ' + 
                     @cNotes, 
                  20)
            END
         END
      END
   END
END
GO

GRANT EXECUTE ON  [RDT].[rdt_838ExtInfo07] TO [NSQL]
GO
