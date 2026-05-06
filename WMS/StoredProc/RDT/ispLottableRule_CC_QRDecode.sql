SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: ispLottableRule_CC_QRDecode                         */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Custom Lottable Rule for Cycle Count QR Code decoding       */
/*          Decodes using CODELKUP (ListName = RDTDECODE)               */
/*                                                                      */
/* Called from: ispLottableRule_Wrapper                                 */
/*              (via rdt_CycleCount_GetLottables with 'PRE' mode)       */
/*                                                                      */
/* QR Format: SKU&Batch_No&Mfg_Date&Expiry_Date&Dept_Code               */
/*            SKU  LOTTABLE01 LOTTABLE13 LOTTABLE04  LOTTABLE02         */
/*                                                                      */
/* Configuration Required:                                              */
/* 1. CODELKUP for LOTTABLE01 (or any lottable to trigger this SP):    */
/*    ListName='LOTTABLE01', Code=<LotLabel>, Short='PRE',              */
/*    Long='ispLottableRule_CC_QRDecode'                                */
/*                                                                      */
/* 2. CODELKUP for RDTDECODE (decode configuration):                    */
/*    ListName='RDTDECODE', Code='610-SKU', Code2=<SeqNo>,              */
/*    Short=<Delimiter>, Long=<FixedLength>, UDF01=<TargetField>        */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev    Author      Purposes                              */
/* 2026-03-05  1.0.0  NYE018      FCR-9688  Created                     */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[ispLottableRule_CC_QRDecode] (
   @c_Storerkey        NVARCHAR(15),
   @c_Sku              NVARCHAR(20),
   @c_Lottable01Value  NVARCHAR(60),
   @c_Lottable02Value  NVARCHAR(60),
   @c_Lottable03Value  NVARCHAR(60),
   @dt_Lottable04Value DATETIME,
   @dt_Lottable05Value DATETIME,
   @c_Lottable06Value  NVARCHAR(60) = '',
   @c_Lottable07Value  NVARCHAR(60) = '',
   @c_Lottable08Value  NVARCHAR(60) = '',
   @c_Lottable09Value  NVARCHAR(60) = '',
   @c_Lottable10Value  NVARCHAR(60) = '',
   @c_Lottable11Value  NVARCHAR(60) = '',
   @c_Lottable12Value  NVARCHAR(60) = '',
   @dt_Lottable13Value DATETIME     = NULL,
   @dt_Lottable14Value DATETIME     = NULL,
   @dt_Lottable15Value DATETIME     = NULL,
   @c_Lottable01       NVARCHAR(18) OUTPUT,
   @c_Lottable02       NVARCHAR(18) OUTPUT,
   @c_Lottable03       NVARCHAR(18) OUTPUT,
   @dt_Lottable04      DATETIME     OUTPUT,
   @dt_Lottable05      DATETIME     OUTPUT,
   @c_Lottable06       NVARCHAR(30) = '' OUTPUT,
   @c_Lottable07       NVARCHAR(30) = '' OUTPUT,
   @c_Lottable08       NVARCHAR(30) = '' OUTPUT,
   @c_Lottable09       NVARCHAR(30) = '' OUTPUT,
   @c_Lottable10       NVARCHAR(30) = '' OUTPUT,
   @c_Lottable11       NVARCHAR(30) = '' OUTPUT,
   @c_Lottable12       NVARCHAR(30) = '' OUTPUT,
   @dt_Lottable13      DATETIME     = NULL OUTPUT,
   @dt_Lottable14      DATETIME     = NULL OUTPUT,
   @dt_Lottable15      DATETIME     = NULL OUTPUT,
   @b_Success          INT          = 1 OUTPUT,
   @n_Err              INT          = 0 OUTPUT,
   @c_Errmsg           NVARCHAR(250) = '' OUTPUT,
   @c_Sourcekey        NVARCHAR(15) = '',   -- CCRefNo
   @c_Sourcetype       NVARCHAR(20) = '',   -- 'RDTCCOUNT'
   @c_LottableLabel    NVARCHAR(20) = ''
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Local variables
   DECLARE @nMobile          INT
   DECLARE @cBarcode         NVARCHAR(MAX)
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
   DECLARE @nFunc            INT = 610  -- Cycle Count function

   -- Decode configuration table
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

   -- Initialize outputs
   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_Errmsg = ''

   -- Only process for Cycle Count
   IF @c_Sourcetype <> 'RDTCCOUNT'
      GOTO Quit

   -- Get Mobile number from RDTMOBREC using CCKey (CCRefNo)
   SELECT TOP 1 @nMobile = Mobile
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE V_String1 = @c_Sourcekey  -- CCRefNo stored in V_String1
       AND StorerKey = @c_Storerkey
      --  AND V_String24 = @c_Sku
       AND Func = '610'
       AND Scn = '677'
   ORDER BY Mobile DESC

   -- Get barcode from V_Barcode first, fallback to InField03 if null
   SELECT @cBarcode = ISNULL(NULLIF(V_Barcode, ''), I_Field03)
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile


   -- If still no barcode, exit
   IF ISNULL(@cBarcode, '') = ''
      GOTO Quit

   SET @cBarcode = LTRIM(RTRIM(@cBarcode))

   SET @cCodeKey = CAST(@nFunc AS NVARCHAR(10)) + '-SKU'

   INSERT INTO @tDecodeConfig (SeqNo, Delimiter, FixedLength, TargetField)
   SELECT
      CAST(Code2 AS INT) AS SeqNo,
      RTRIM(LTRIM(ISNULL([Short], ''))) AS Delimiter,
      CASE WHEN ISNULL([Long], '') = '' THEN 0 ELSE CAST([Long] AS INT) END AS FixedLength,
      UPPER(RTRIM(LTRIM(ISNULL(UDF01, '')))) AS TargetField
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE ListName = 'RDTDECODE'
     AND Code = @cCodeKey
     AND (StorerKey = @c_Storerkey OR ISNULL(StorerKey, '') = '')
   ORDER BY
      CASE WHEN StorerKey = @c_Storerkey THEN 0 ELSE 1 END,
      CAST(Code2 AS INT)

   -- Get sequence count
   SELECT @nSeqCount = COUNT(*) FROM @tDecodeConfig

   -- If no config found, exit without error (let normal flow continue)
   IF @nSeqCount = 0
      GOTO Quit

   SET @cRemainingBarcode = @cBarcode
   SET @nIndex = 1

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

      -- Decode based on delimiter > fixed length
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

   -- =====================================================================
   -- Map decoded values to output parameters
   -- ONLY decode lottables present in QR: LOTTABLE01, LOTTABLE02, LOTTABLE04, LOTTABLE13
   -- DO NOT touch other lottables (LOTTABLE03, 05-12, 14-15)
   -- =====================================================================

   -- LOTTABLE01 (Batch_No)
   IF EXISTS (SELECT 1 FROM @tDecodedValues WHERE FieldName = 'LOTTABLE01')
      SELECT @c_Lottable01 = FieldValue FROM @tDecodedValues WHERE FieldName = 'LOTTABLE01'

   -- LOTTABLE02 (Dept_Code)
   IF EXISTS (SELECT 1 FROM @tDecodedValues WHERE FieldName = 'LOTTABLE02')
      SELECT @c_Lottable02 = FieldValue FROM @tDecodedValues WHERE FieldName = 'LOTTABLE02'

   -- LOTTABLE04 (Expiry_Date) - Convert to DATETIME
   IF EXISTS (SELECT 1 FROM @tDecodedValues WHERE FieldName = 'LOTTABLE04')
   BEGIN
      SELECT @cTempDate = FieldValue FROM @tDecodedValues WHERE FieldName = 'LOTTABLE04'
      IF ISNULL(@cTempDate, '') <> ''
      BEGIN
         BEGIN TRY
            IF CHARINDEX('/', @cTempDate) > 0
               SET @dt_Lottable04 = CONVERT(DATETIME, @cTempDate, 103) -- DD/MM/YYYY
            ELSE IF LEN(@cTempDate) = 8 AND ISNUMERIC(@cTempDate) = 1
               SET @dt_Lottable04 = CONVERT(DATETIME, @cTempDate, 112) -- YYYYMMDD
            ELSE
               SET @dt_Lottable04 = CAST(@cTempDate AS DATETIME)
         END TRY
         BEGIN CATCH
            SET @dt_Lottable04 = NULL
         END CATCH
      END
   END

   -- LOTTABLE13 (Mfg_Date) - Convert to DATETIME
   IF EXISTS (SELECT 1 FROM @tDecodedValues WHERE FieldName = 'LOTTABLE13')
   BEGIN
      SELECT @cTempDate = FieldValue FROM @tDecodedValues WHERE FieldName = 'LOTTABLE13'
      IF ISNULL(@cTempDate, '') <> ''
      BEGIN
         BEGIN TRY
            IF CHARINDEX('/', @cTempDate) > 0
               SET @dt_Lottable13 = CONVERT(DATETIME, @cTempDate, 103) -- DD/MM/YYYY
            ELSE IF LEN(@cTempDate) = 8 AND ISNUMERIC(@cTempDate) = 1
               SET @dt_Lottable13 = CONVERT(DATETIME, @cTempDate, 112) -- YYYYMMDD
            ELSE
               SET @dt_Lottable13 = CAST(@cTempDate AS DATETIME)
         END TRY
         BEGIN CATCH
            SET @dt_Lottable13 = NULL
         END CATCH
      END
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [dbo].[ispLottableRule_CC_QRDecode] TO [NSQL]
GO
