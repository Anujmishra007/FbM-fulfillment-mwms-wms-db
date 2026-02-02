
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1581DecodeSP02                                        */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Decode output @cSerialNoCapture                                   */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-07-22  Cuize     1.0   WMS-21975 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1581DecodeSP02 (
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cStorerKey          NVARCHAR( 15),
   @cReceiptKey         NVARCHAR( 10),
   @cPOKey              NVARCHAR( 10),
   @cLOC                NVARCHAR( 10),
   @cID                 NVARCHAR( 18),
   @cBarcode            NVARCHAR( 2000),
   @cSKU                NVARCHAR( 20)     OUTPUT,
   @nQTY                INT               OUTPUT,
   @cLottable01         NVARCHAR( 18)     OUTPUT,
   @cLottable02         NVARCHAR( 18)     OUTPUT,
   @cLottable03         NVARCHAR( 18)     OUTPUT,
   @dLottable04         DATETIME          OUTPUT,
   @cSerialNoCapture    NVARCHAR(1) = 0   OUTPUT,
   @nErrNo              INT               OUTPUT,
   @cErrMsg             NVARCHAR( 20)     OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE    @cFacility  NVARCHAR( 5)
   DECLARE    @cFacilityList  NVARCHAR( 120)

   IF @nStep = 5 -- SKU/QTY
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         IF @cBarcode <> ''
         BEGIN

--             SELECT @cFacility = Facility
--             FROM SKU WITH(NOLOCK)
--                WHERE SKU = @cBarcode
--                AND StorerKey = @cStorerKey

            SELECT @cFacility = Facility
            FROM rdt.rdtMobRec WITH (NOLOCK)
            WHERE Mobile = @nMobile

            SELECT TOP 1
               @cFacilityList = ConfigDesc
            FROM rdt.storerconfig WITH(NOLOCK)
            WHERE Function_ID = 1581
              AND StorerKey = @cStorerKey
              AND ConfigKey = 'DecodeSP'
              AND SValue = 'rdt_1581DecodeSP02'

            IF EXISTS(
               SELECT 1
               FROM STRING_SPLIT(@cFacilityList, ',')
               WHERE value = @cFacility
            )
            BEGIN
               SET @cSerialNoCapture = '3'
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

GRANT EXECUTE ON rdt.rdt_1581DecodeSP02 TO NSQL
GO
