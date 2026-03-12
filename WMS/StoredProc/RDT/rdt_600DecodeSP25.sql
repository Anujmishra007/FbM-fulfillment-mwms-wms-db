
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_600DecodeSP25                                         */
/* Copyright:                                                                 */
/*                                                                            */
/* Purpose: For PurePlay                                                        */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-11-11  Cuize     1.0   FCR-7822 created                               */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600DecodeSP25] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cLOC         NVARCHAR( 10),
   @cBarcode     NVARCHAR( 2000)  OUTPUT,
   @cFieldName   NVARCHAR( 10),
   @cID          NVARCHAR( 18)  OUTPUT,
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
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE 
      @cTempSKU            NVARCHAR( 20)
      ,@cTempLottable01    NVARCHAR( 18)
      ,@cTempLottable02    NVARCHAR( 18)
      ,@cTempLottable04    NVARCHAR(100)
      ,@cTempLottable13    NVARCHAR(100)
      ,@nRowCount    INT

    DECLARE @tDecodeList TABLE
   (
      ItemIndex   INT NOT NULL,
      Item        NVARCHAR (100)      
   )

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nStep = 4 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN

            --Sample QR Code
            --Sprivil Healthcare Pvt Ltd., Plum Rice Water And 10% Niacinamide serum 10ml,SA_SKU01,8904430202831,24N7, 12/2024,11/2026,48 Nos,2.5 KG.

            ;WITH SplitData AS (
               SELECT
                  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS SegmentNo,
                  LTRIM(RTRIM(value)) AS SegmentValue
               FROM STRING_SPLIT(@cBarcode, ',')
            )
             SELECT
                @cSKU         = MAX(CASE WHEN SegmentNo = 3 THEN SegmentValue END),
                --@AlternateEAN = MAX(CASE WHEN SegmentNo = 4 THEN SegmentValue END),
                @cLottable02        = MAX(CASE WHEN SegmentNo = 5 THEN SegmentValue END),
                @cLottable06          = MAX(CASE WHEN SegmentNo = 6 THEN SegmentValue END),
                @cLottable03          = MAX(CASE WHEN SegmentNo = 7 THEN SegmentValue END)
                --@Weight       = MAX(CASE WHEN SegmentNo = 9 THEN SegmentValue END)
             FROM SplitData;

				IF ISNULL(@cSKU,'') = ''
				BEGIN
					SET @cSKU=@cBarcode
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

GRANT EXECUTE ON rdt.rdt_600DecodeSP25 TO NSQL
GO
