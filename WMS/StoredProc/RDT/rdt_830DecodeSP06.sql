SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_830DecodeSP06                                         */
/* Copyright      : Maersk                                                    */
/* Customer       :                                                           */
/*                                                                            */
/* Purpose: Decode SKU                                                        */
/*                                                                            */
/* Date        Author    Ver.    Purposes                                     */
/* 2025-09-22  Deenis    1.0     FCR-5962 Created                             */
/******************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_830DecodeSP06] ( 
  @nMobile      INT,               
  @nFunc        INT,               
  @cLangCode    NVARCHAR( 3),      
  @nStep        INT,               
  @nInputKey    INT,               
  @cStorerKey   NVARCHAR( 15),        
  @cFacility    NVARCHAR( 20),   
  @cLOC         NVARCHAR( 10),   
  @cDropid      NVARCHAR( 20),
  @cpickslipno  NVARCHAR( 20), 
  @cBarcode     NVARCHAR( 60),
  @cFieldName   NVARCHAR( 10),     
  @cUPC         NVARCHAR( 20)  OUTPUT,
  @cSKU         NVARCHAR( 20)  OUTPUT,
  @nQTY         INT            OUTPUT,
  @cLottable01  NVARCHAR( 18)  OUTPUT,
  @cLottable02  NVARCHAR( 18)  OUTPUT,
  @cLottable03  NVARCHAR( 18)  OUTPUT,
  @dLottable04  DATETIME       OUTPUT,
  @dLottable05  DATETIME       OUTPUT,
  @cLottable06  NVARCHAR( 30)  OUTPUT,
  @cLottable07  NVARCHAR( 30)  OUTPUT,
  @cLottable08  NVARCHAR( 30)  OUTPUT,
  @cLottable09  NVARCHAR( 30)  OUTPUT,
  @cLottable10  NVARCHAR( 30)  OUTPUT,
  @cLottable11  NVARCHAR( 30)  OUTPUT,
  @cLottable12  NVARCHAR( 30)  OUTPUT,
  @dLottable13  DATETIME       OUTPUT,
  @dLottable14  DATETIME       OUTPUT,
  @dLottable15  DATETIME       OUTPUT,
  @cUserDefine01 NVARCHAR(30)  OUTPUT,
  @nErrNo       INT            OUTPUT,
  @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
    
   IF @nFunc = 830
   BEGIN
      IF @nStep = 2 -- dropid
      BEGIN
         IF @nInputKey = 1
         BEGIN
           IF EXISTS (SELECT 1 FROM PickDetail PD (NOLOCK) 
                        JOIN LoadPlanDetail LPD (NOLOCK) ON PD.OrderKey = LPD.OrderKey
                        JOIN PickHeader PH (NOLOCK) ON PH.ExternOrderKey = LPD.LoadKey
                        WHERE PD.StorerKey = @cStorerKey
                        AND PH.PickHeaderKey <> @cPickSlipNo
                        AND PD.DropID = @cDropID)
            BEGIN
               SET @nErrNo = 246201
               SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') 
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

GRANT EXECUTE ON [RDT].[rdt_830DecodeSP06] TO NSQL
GO
