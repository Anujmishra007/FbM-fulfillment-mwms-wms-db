SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838DecodeSP17                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: QR decode for the SKU in the function 838                   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev    Author      Purposes                              */
/* 2025-12-26  1.0.0  NYE018      FCR-9571 Created                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_838DecodeSP17](
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cPickSlipNo         NVARCHAR( 10),
   @cFromDropID         NVARCHAR( 20),
   @cBarcode            NVARCHAR( 2000),
   @cBarcode2           NVARCHAR( 60),
   @cSKU                NVARCHAR( 30)  OUTPUT,
   @nQTY                INT            OUTPUT,
   @cPackDtlRefNo       NVARCHAR( 20)  OUTPUT,
   @cPackDtlRefNo2      NVARCHAR( 20)  OUTPUT,
   @cPackDtlUPC         NVARCHAR( 30)  OUTPUT,
   @cPackDtlDropID      NVARCHAR( 20)  OUTPUT,
   @cSerialNo           NVARCHAR( 30)  OUTPUT,
   @cFromDropIDDecode   NVARCHAR( 20)  OUTPUT,
   @cToDropIDDecode     NVARCHAR( 20)  OUTPUT,
   @cUCCNo              NVARCHAR( 20)  OUTPUT,
   @nErrNo              INT            OUTPUT,
   @cErrMsg             NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0
   
   DECLARE @tDecodeList TABLE
   (
      ItemIndex   INT NOT NULL,
      Item        NVARCHAR (100)      
   )
   
   DECLARE @cTempSKU NVARCHAR(30)

   IF @nFunc = 838  -- Pack 
   BEGIN
      IF @nStep = 3  -- SKU & QTY
      BEGIN
         IF @nInputKey = 1
         BEGIN
            -- Check if it is a QR code (contains &)
            IF CHARINDEX('&', @cBarcode) > 0
            BEGIN
                -- check for '&'
                IF (LEN(@cBarcode) - LEN(REPLACE(@cBarcode, '&',''))) <> 4
                BEGIN
                    SET @nErrNo = 254751 -- Error InvFormat
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
                    GOTO Quit 
                END

                BEGIN TRY
                    INSERT INTO @tDecodeList
                    SELECT [key]+1 AS ItemIndex, value AS Item
                    FROM OPENJSON('["' + REPLACE(@cBarcode, '&', '","') + '"]')
                END TRY
                BEGIN CATCH
                    SET @nErrNo = 254752 -- Error DecodeFailure
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
                    GOTO Quit 
                END CATCH

                -- Extract values based on index mapping:
                -- 1: SKU
                SELECT @cTempSKU = Item FROM @tDecodeList WHERE ItemIndex = 1

                IF @nDebugFlag = 1
                    SELECT 'DecodValues', @cTempSKU AS SKU 

                SET @cSKU = @cTempSKU
            END
            ELSE
            BEGIN
                -- Barcode Logic (SKU only)
                SET @cSKU = @cBarcode
            END

            IF NOT EXISTS (SELECT 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU)
            BEGIN
               SET @nErrNo = 254753 -- Error InvalidSKU
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
               GOTO Quit
            END
         END
      END -- st3

   END

Quit:
    IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cSKU AS SKU

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON  [RDT].[rdt_838DecodeSP17] TO [NSQL]
GO
