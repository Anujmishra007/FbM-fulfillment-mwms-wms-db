SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_838DecodeSP15                                   */
/* Copyright      : Maersk                                              */
/* Customer       : SA BAT                                              */
/*                                                                      */
/*                                                                      */
/* Purpose: Get UPC SKU and Qty                                         */
/*                                                                      */
/* Date        Rev    Author      Purposes                              */
/* 2025-11-11  1.0.0  JackC       FCR-8675 Created                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_838DecodeSP15]
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
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @cBarcode = REPLACE(LTRIM(RTRIM(@cBarcode)), ' ', '')

   IF @nFunc = 838
   BEGIN
      IF @nStep = 3  -- SKU QTY
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cBarcode <> ''
            BEGIN
               IF LEN(@cBarcode) = 17 --label 2
               BEGIN
                  SELECT @cSKU = 
                  CASE 
                     WHEN CHARINDEX('(21)', @cBarcode) > 0 AND CHARINDEX('(241)', @cBarcode) > CHARINDEX('(21)', @cBarcode) THEN
                           SUBSTRING(
                              @cBarcode,
                              CHARINDEX('(21)', @cBarcode) + 4,
                              CHARINDEX('(241)', @cBarcode) - CHARINDEX('(21)', @cBarcode) - 4
                           )
                     ELSE @cBarcode
                  END

                  GOTO Quit
               END --label 2
               ELSE IF LEN(@cBarcode) = 67 --label 5
               BEGIN
                  SELECT  @cSKU = SUBSTRING(@cBarcode, 51, 8)
                  GOTO Quit
               END --label 5
               ELSE
               BEGIN
                  SET @cSKU = @cBarcode
                  GOTO Quit
               END
            END
         END
      END -- st3
      IF @nStep = 8 -- UCC
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cBarcode <> ''  -- UCC  Decode
            BEGIN
               IF LEN(@cBarcode) = 40 OR LEN(@cBarcode) = 44 --label2
               BEGIN
                  SELECT 
                  @cUCCNo = 
                  CASE 
                     WHEN CHARINDEX('(240)', @cBarcode) > 0 THEN
                           SUBSTRING(
                              @cBarcode,
                              CHARINDEX('(240)', @cBarcode) + 5,
                              LEN(@cBarcode)
                           )
                     ELSE @cBarcode
                  END
                  GOTO Quit
               END--label2 
               ELSE IF LEN(@cBarcode) = 34 --label4
               BEGIN
                  SELECT @cUCCNo = RIGHT(@cBarcode, 20)
                  GOTO Quit
               END
               ELSE IF LEN(@cBarcode) = 67 --label5
               BEGIN
                  SELECT @cUCCNo = SUBSTRING(@cBarcode, 19, 19)
                  GOTO Quit
               END
               ELSE
               BEGIN
                  SET @cUCCNo = @cBarcode
               END
            END      
         END
      END --st8
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON  [RDT].[rdt_838DecodeSP15] TO [NSQL]
GO
