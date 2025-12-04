SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_840CapturePack04                                */
/* Purpose: Default carton type based on codelkup                       */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2021-02-04  1.0  James      WMS-16306. Created                       */
/* 2024-12-17  1.1  James      FCR-1625 Add new params (james01)        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_840CapturePack04] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cStorerkey       NVARCHAR( 15),
   @cOrderKey        NVARCHAR( 10),
   @cPickSlipNo      NVARCHAR( 10),
   @cTrackNo         NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nCartonNo        INT,
   @cCartonType      NVARCHAR( 10) OUTPUT,
   @fCartonWeight    FLOAT         OUTPUT,
   @fCartonCube      FLOAT         OUTPUT, 
   @fCartonLength    FLOAT         OUTPUT, 
   @fCartonWidth     FLOAT         OUTPUT, 
   @fCartonHeight    FLOAT         OUTPUT, 
   @cCapturePackInfo NVARCHAR( 10) OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cCtnType       NVARCHAR( 10)

   IF @nStep = 3
   BEGIN
      IF @nInputKey IN (0, 1)
      BEGIN
         SELECT @cCartonType = Short
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = 'PDACARTON'
         AND   StorerKey = @cStorerkey
         AND   Code = @nFunc

         SET @cCapturePackInfo = '1'   -- Enable capture pack info screen
      END
   END

   GOTO Quit

   Quit:
GO
GRANT EXECUTE ON  [RDT].[rdt_840CapturePack04] TO [NSQL]
GO
