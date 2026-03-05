SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_610DecodeSP06                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Configurable QR/Barcode decode for Cycle Count (Fn 610)     */
/*          Configuration via CODELKUP (ListName = RDTDECODE)           */
/*                                                                      */
/*          Supports: Step 14 - Add SKU (UPC/SKU CC)                    */
/*                    Step 18 - Scan SKU (SINGLE SCAN CC)               */
/*                    Step 20 - Scan SKU INCR QTY (SINGLE SCAN CC)      */
/*                    Step 29 - Validate SKU (UPC/SKU CC)               */
/*                                                                      */
/* QR Format: SKU_Code&Batch_No&Mfg_Date&Expiry_Date&Dept_Code          */
/*            SKU      LOTTABLE01 LOTTABLE13 LOTTABLE04  LOTTABLE02     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev    Author      Purposes                              */
/* 2026-03-02  1.0.0  NYE018      FCR-9688  Created                     */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_610DecodeSP06] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cBarcode       NVARCHAR( MAX),
   @cCCRefNo       NVARCHAR( 10),
   @cCCSheetNo     NVARCHAR( 10),
   @cLOC           NVARCHAR( 10)  OUTPUT,
   @cID            NVARCHAR( 18)  OUTPUT,
   @cUCC           NVARCHAR( 20)  OUTPUT,
   @cUPC           NVARCHAR( 20)  OUTPUT,
   @nQTY           INT            OUTPUT,
   @cLottable01    NVARCHAR( 18)  OUTPUT,
   @cLottable02    NVARCHAR( 18)  OUTPUT,
   @cLottable03    NVARCHAR( 18)  OUTPUT,
   @dLottable04    DATETIME       OUTPUT,
   @dLottable05    DATETIME       OUTPUT,
   @cLottable06    NVARCHAR( 30)  OUTPUT,
   @cLottable07    NVARCHAR( 30)  OUTPUT,
   @cLottable08    NVARCHAR( 30)  OUTPUT,
   @cLottable09    NVARCHAR( 30)  OUTPUT,
   @cLottable10    NVARCHAR( 30)  OUTPUT,
   @cLottable11    NVARCHAR( 30)  OUTPUT,
   @cLottable12    NVARCHAR( 30)  OUTPUT,
   @dLottable13    DATETIME       OUTPUT,
   @dLottable14    DATETIME       OUTPUT,
   @dLottable15    DATETIME       OUTPUT,
   @cUserDefine01  NVARCHAR( 60)  OUTPUT,
   @cUserDefine02  NVARCHAR( 60)  OUTPUT,
   @cUserDefine03  NVARCHAR( 60)  OUTPUT,
   @cUserDefine04  NVARCHAR( 60)  OUTPUT,
   @cUserDefine05  NVARCHAR( 60)  OUTPUT,
   @nErrNo         INT            OUTPUT,
   @cErrMsg        NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Debug flag (set to 1 for troubleshooting)
   DECLARE @nDebugFlag INT = 0

   -- Local variables
   DECLARE @cCodeKey         NVARCHAR(30)
   DECLARE @cDelimiter       NVARCHAR(10)
   DECLARE @nFixedLength     INT
   DECLARE @cTargetField     NVARCHAR(30)
   DECLARE @cDecodedValue    NVARCHAR(100)
   DECLARE @nSeqCount        INT
   DECLARE @nIndex           INT
   DECLARE @cTempDate        NVARCHAR(20)
   DECLARE @cRemainingBarcode NVARCHAR(2000)
   DECLARE @nDelimiterPos    INT

   -- Decode configuration table (from CODELKUP)
   DECLARE @tDecodeConfig TABLE (
      SeqNo        INT,
      Delimiter    NVARCHAR(10),
      FixedLength  INT,
      TargetField  NVARCHAR(30)
   )

   -- Decoded values table
   DECLARE @tDecodedValues TABLE (
      SeqNo       INT,
      FieldName   NVARCHAR(30),
      FieldValue  NVARCHAR(100)
   )

   IF @nFunc = 610  -- Cycle Count
   BEGIN
      IF @nStep IN (14, 18, 20, 29)  -- SKU scan steps
      BEGIN
         IF @nInputKey = 1  -- ENTER
         BEGIN

            IF @cBarcode <> ''  -- SKU/QR Decode
            BEGIN
               SET @cBarcode = LTRIM(RTRIM(@cBarcode))

               -- Build code key: <FnCode>-SKU
               SET @cCodeKey = CAST(@nFunc AS NVARCHAR(10)) + '-SKU'

               IF @nDebugFlag = 1
                  SELECT 'Input' AS Debug, @cBarcode AS Barcode, @cCodeKey AS CodeKey, @nStep AS Step, @cStorerKey AS StorerKey

               -- Load decode configuration from CODELKUP
               INSERT INTO @tDecodeConfig (SeqNo, Delimiter, FixedLength, TargetField)
               SELECT 
                  CAST(Code2 AS INT) AS SeqNo,
                  RTRIM(LTRIM(ISNULL([Short], ''))) AS Delimiter,
                  CASE WHEN ISNULL([Long], '') = '' THEN 0 ELSE CAST([Long] AS INT) END AS FixedLength,
                  UPPER(RTRIM(LTRIM(ISNULL(UDF01, '')))) AS TargetField
               FROM dbo.CODELKUP WITH (NOLOCK)
               WHERE ListName = 'RDTDECODE'
                 AND Code = @cCodeKey
                 AND (StorerKey = @cStorerKey OR ISNULL(StorerKey, '') = '')
               ORDER BY 
                  CASE WHEN StorerKey = @cStorerKey THEN 0 ELSE 1 END,
                  CAST(Code2 AS INT)

               -- Get sequence count
               SELECT @nSeqCount = COUNT(*) FROM @tDecodeConfig

               -- If no config found, treat barcode as plain SKU
               IF @nSeqCount = 0
               BEGIN
                  SET @cUPC = @cBarcode

                  -- Validate SKU exists
                  IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUPC)
                  BEGIN
                     SET @nErrNo = 260353 -- Invalid SKU
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  GOTO Quit
               END

               IF @nDebugFlag = 1
                  SELECT 'Config' AS Debug, * FROM @tDecodeConfig ORDER BY SeqNo

               -- Initialize decode
               SET @cRemainingBarcode = @cBarcode
               SET @nIndex = 1

               -- Process each sequence from configuration
               WHILE @nIndex <= @nSeqCount
               BEGIN
                  -- Get current sequence config
                  SELECT 
                     @cDelimiter = Delimiter,
                     @nFixedLength = FixedLength,
                     @cTargetField = TargetField
                  FROM @tDecodeConfig
                  WHERE SeqNo = @nIndex

                  SET @cDecodedValue = ''

                  -- Decode based on delimiter or fixed length
                  -- Priority: Delimiter (Short) > Fixed Length (Long)
                  IF ISNULL(@cDelimiter, '') <> ''
                  BEGIN
                     SET @nDelimiterPos = CHARINDEX(@cDelimiter, @cRemainingBarcode)

                     IF @nDelimiterPos > 0
                     BEGIN
                        SET @cDecodedValue = LEFT(@cRemainingBarcode, @nDelimiterPos - 1)
                        SET @cRemainingBarcode = SUBSTRING(@cRemainingBarcode, @nDelimiterPos + LEN(@cDelimiter), LEN(@cRemainingBarcode))
                     END
                     ELSE
                     BEGIN
                        SET @cDecodedValue = @cRemainingBarcode
                        SET @cRemainingBarcode = ''
                     END
                  END
                  ELSE IF @nFixedLength > 0
                  BEGIN
                     IF LEN(@cRemainingBarcode) >= @nFixedLength
                     BEGIN
                        SET @cDecodedValue = LEFT(@cRemainingBarcode, @nFixedLength)
                        SET @cRemainingBarcode = SUBSTRING(@cRemainingBarcode, @nFixedLength + 1, LEN(@cRemainingBarcode))
                     END
                     ELSE
                     BEGIN
                        SET @cDecodedValue = @cRemainingBarcode
                        SET @cRemainingBarcode = ''
                     END
                  END
                  ELSE
                  BEGIN
                     SET @cDecodedValue = @cRemainingBarcode
                     SET @cRemainingBarcode = ''
                  END

                  -- Store decoded value if target field is specified
                  IF ISNULL(@cTargetField, '') <> ''
                  BEGIN
                     INSERT INTO @tDecodedValues (SeqNo, FieldName, FieldValue)
                     VALUES (@nIndex, @cTargetField, @cDecodedValue)
                  END

                  SET @nIndex = @nIndex + 1
               END -- WHILE

               IF @nDebugFlag = 1
                  SELECT 'Decoded' AS Debug, * FROM @tDecodedValues ORDER BY SeqNo

               -- Map decoded values to output parameters
               -- Only lottables from QR: SKU, LOTTABLE01, LOTTABLE02, LOTTABLE04, LOTTABLE13

               -- SKU / UPC
               SELECT @cUPC = FieldValue FROM @tDecodedValues WHERE FieldName = 'SKU'
               IF ISNULL(@cUPC, '') = ''
                  SELECT @cUPC = FieldValue FROM @tDecodedValues WHERE FieldName = 'UPC'

               -- LOTTABLE01 (Batch_No)
               SELECT @cLottable01 = FieldValue FROM @tDecodedValues WHERE FieldName = 'LOTTABLE01'

               -- LOTTABLE02 (Dept_Code)
               SELECT @cLottable02 = FieldValue FROM @tDecodedValues WHERE FieldName = 'LOTTABLE02'

               -- LOTTABLE04 (Expiry_Date) - Convert to DATETIME
               SELECT @cTempDate = FieldValue FROM @tDecodedValues WHERE FieldName = 'LOTTABLE04'
               IF ISNULL(@cTempDate, '') <> ''
               BEGIN
                  BEGIN TRY
                     IF CHARINDEX('/', @cTempDate) > 0
                        SET @dLottable04 = CONVERT(DATETIME, @cTempDate, 103) -- DD/MM/YYYY
                     ELSE IF LEN(@cTempDate) = 8 AND ISNUMERIC(@cTempDate) = 1
                        SET @dLottable04 = CONVERT(DATETIME, @cTempDate, 112) -- YYYYMMDD
                     ELSE
                        SET @dLottable04 = CAST(@cTempDate AS DATETIME)
                  END TRY
                  BEGIN CATCH
                     SET @dLottable04 = NULL
                  END CATCH
               END

               -- LOTTABLE13 (Mfg_Date) - Convert to DATETIME
               SELECT @cTempDate = FieldValue FROM @tDecodedValues WHERE FieldName = 'LOTTABLE13'
               IF ISNULL(@cTempDate, '') <> ''
               BEGIN
                  BEGIN TRY
                     IF CHARINDEX('/', @cTempDate) > 0
                        SET @dLottable13 = CONVERT(DATETIME, @cTempDate, 103) -- DD/MM/YYYY
                     ELSE IF LEN(@cTempDate) = 8 AND ISNUMERIC(@cTempDate) = 1
                        SET @dLottable13 = CONVERT(DATETIME, @cTempDate, 112) -- YYYYMMDD
                     ELSE
                        SET @dLottable13 = CAST(@cTempDate AS DATETIME)
                  END TRY
                  BEGIN CATCH
                     SET @dLottable13 = NULL
                  END CATCH
               END

               IF ISNULL(@cUPC, '') = ''
               BEGIN
                  SET @nErrNo = 260352  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  -- 260352^DecodeFailure
                  GOTO Quit
               END


               -- Validate SKU exists
               IF ISNULL(@cUPC, '') <> ''
               BEGIN
                  IF NOT EXISTS (SELECT 1 FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUPC)
                  BEGIN
                     SET @nErrNo = 260356 -- Invalid SKU
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END

            END -- IF @cBarcode <> ''
         END -- IF @nInputKey = 1
      END -- IF @nStep IN (14, 18, 20, 29)
   END -- IF @nFunc = 610

Quit:
   IF @nDebugFlag = 1
      SELECT 'Output' AS Debug, 
         @nErrNo AS ErrNo, @cUPC AS SKU, 
         @cLottable01 AS Lot01_BatchNo, 
         @cLottable02 AS Lot02_DeptCode,
         @dLottable04 AS Lot04_ExpiryDate, 
         @dLottable13 AS Lot13_MfgDate

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_610DecodeSP06] TO [NSQL]
GO
