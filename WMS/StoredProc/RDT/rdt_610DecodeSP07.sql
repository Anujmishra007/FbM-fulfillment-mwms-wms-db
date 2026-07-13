SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_610DecodeSP07                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Decode QR barcode (& delimited) scanned on CycleCount (Func 610)  */
/*          Reads full barcode from RDTMOBREC.V_Barcode                       */
/*          Seg2+Seg3->SKU, Seg6+Seg8->Lottable01, Seg6->Lottable02,          */
/*          Seg8->Lottable03, Seg4+Seg5+Seg7->UserDefine01(SerialNo)          */
/*                                                                            */
/* Date         Author    Ver.   Purposes                                     */
/* 2026-06-30   Dennis    1.0.0  UWP-60176 Created                            */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_610DecodeSP07] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR(  3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cBarcode        NVARCHAR( MAX),
   @cCCRefNo        NVARCHAR( 10),
   @cCCSheetNo      NVARCHAR( 10),
   @cLOC            NVARCHAR( 10)  OUTPUT,
   @cID             NVARCHAR( 18)  OUTPUT,
   @cUCC            NVARCHAR( 20)  OUTPUT,
   @cUPC            NVARCHAR( 20)  OUTPUT,
   @nQTY            INT            OUTPUT,
   @cLottable01     NVARCHAR( 18)  OUTPUT,
   @cLottable02     NVARCHAR( 18)  OUTPUT,
   @cLottable03     NVARCHAR( 18)  OUTPUT,
   @dLottable04     DATETIME       OUTPUT,
   @dLottable05     DATETIME       OUTPUT,
   @cLottable06     NVARCHAR( 30)  OUTPUT,
   @cLottable07     NVARCHAR( 30)  OUTPUT,
   @cLottable08     NVARCHAR( 30)  OUTPUT,
   @cLottable09     NVARCHAR( 30)  OUTPUT,
   @cLottable10     NVARCHAR( 30)  OUTPUT,
   @cLottable11     NVARCHAR( 30)  OUTPUT,
   @cLottable12     NVARCHAR( 30)  OUTPUT,
   @dLottable13     DATETIME       OUTPUT,
   @dLottable14     DATETIME       OUTPUT,
   @dLottable15     DATETIME       OUTPUT,
   @cUserDefine01   NVARCHAR( 60)  OUTPUT,
   @cUserDefine02   NVARCHAR( 60)  OUTPUT,
   @cUserDefine03   NVARCHAR( 60)  OUTPUT,
   @cUserDefine04   NVARCHAR( 60)  OUTPUT,
   @cUserDefine05   NVARCHAR( 60)  OUTPUT,
   @nErrNo          INT            OUTPUT,
   @cErrMsg         NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cFullBarcode NVARCHAR(200)
   DECLARE @cUserName    NVARCHAR( 50)
   DECLARE @cFacility    NVARCHAR(  5)
   DECLARE @cSerialNo30  NVARCHAR( 30)

   DECLARE @seg1 NVARCHAR(50), @seg2 NVARCHAR(50), @seg3 NVARCHAR(50),
           @seg4 NVARCHAR(50), @seg5 NVARCHAR(50), @seg6 NVARCHAR(50),
           @seg7 NVARCHAR(50), @seg8 NVARCHAR(50), @seg9 NVARCHAR(50)

   DECLARE @p1 INT, @p2 INT, @p3 INT, @p4 INT,
           @p5 INT, @p6 INT, @p7 INT, @p8 INT
   SELECT @cUPC = ''
   IF @nStep IN (9, 18, 20)
   BEGIN
      -- Read full barcode, username and facility from RDTMOBREC (@cBarcode param may be truncated)
      SELECT @cFullBarcode = V_Barcode,
             @cUserName    = UserName,
             @cFacility    = Facility
      FROM   rdt.RDTMOBREC WITH (NOLOCK)
      WHERE  Mobile = @nMobile

      IF ISNULL(@cFullBarcode, '') = ''
         GOTO Quit

      -- Parse & -delimited segments (up to 9)
      SET @p1 = CHARINDEX('&', @cFullBarcode, 1)
      SET @p2 = CHARINDEX('&', @cFullBarcode, @p1 + 1)
      SET @p3 = CHARINDEX('&', @cFullBarcode, @p2 + 1)
      SET @p4 = CHARINDEX('&', @cFullBarcode, @p3 + 1)
      SET @p5 = CHARINDEX('&', @cFullBarcode, @p4 + 1)
      SET @p6 = CHARINDEX('&', @cFullBarcode, @p5 + 1)
      SET @p7 = CHARINDEX('&', @cFullBarcode, @p6 + 1)
      SET @p8 = CHARINDEX('&', @cFullBarcode, @p7 + 1)

      SET @seg1 = CASE WHEN @p1 > 0 THEN LEFT(@cFullBarcode, @p1 - 1)                                ELSE @cFullBarcode END
      SET @seg2 = CASE WHEN @p2 > 0 THEN SUBSTRING(@cFullBarcode, @p1 + 1, @p2 - @p1 - 1)           ELSE '' END
      SET @seg3 = CASE WHEN @p3 > 0 THEN SUBSTRING(@cFullBarcode, @p2 + 1, @p3 - @p2 - 1)           ELSE '' END
      SET @seg4 = CASE WHEN @p4 > 0 THEN SUBSTRING(@cFullBarcode, @p3 + 1, @p4 - @p3 - 1)           ELSE '' END
      SET @seg5 = CASE WHEN @p5 > 0 THEN SUBSTRING(@cFullBarcode, @p4 + 1, @p5 - @p4 - 1)           ELSE '' END
      SET @seg6 = CASE WHEN @p6 > 0 THEN SUBSTRING(@cFullBarcode, @p5 + 1, @p6 - @p5 - 1)           ELSE '' END
      SET @seg7 = CASE WHEN @p7 > 0 THEN SUBSTRING(@cFullBarcode, @p6 + 1, @p7 - @p6 - 1)           ELSE '' END
      SET @seg8 = CASE WHEN @p8 > 0 THEN SUBSTRING(@cFullBarcode, @p7 + 1, @p8 - @p7 - 1)
                       WHEN @p7 > 0 THEN SUBSTRING(@cFullBarcode, @p7 + 1, LEN(@cFullBarcode) - @p7) ELSE '' END
      SET @seg9 = CASE WHEN @p8 > 0 THEN SUBSTRING(@cFullBarcode, @p8 + 1, LEN(@cFullBarcode) - @p8) ELSE '' END

      -- Step 9: UCC scan
      -- Sample: 8901326038215&1406-0310-DKPTD&L&4525003831&NB&0725&021712&4&5490
      IF @nStep = 9
      BEGIN
         -- SKU = SKU.SKU where BUSR5 = Seg2 and BUSR6 = Seg3
         SELECT @cUPC = SKU
         FROM dbo.SKU WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND   BUSR5     = @seg2
         AND   BUSR6     = @seg3

         IF ISNULL(@cUPC, '') = ''
         BEGIN
            SET @nErrNo = 62158
            SET @cErrMsg = rdt.rdtgetmessage( 62158, @cLangCode, 'DSP') -- SKU Not Found
            GOTO Quit
         END

         -- UCC = Seg4 + Seg5 + Seg7                -> CCDETAIL.REFNO
         SET @cUCC = LEFT(@seg4 + @seg5 + @seg7, 20)
      END

      -- Step 18/20: lottable + serial scan
      -- Sample: 8901326038215&1406-0310-DKPTD&L&4525003831&NB&0725&000328&5490
      IF @nStep IN (18, 20)
      BEGIN
         -- SKU = SKU.SKU where BUSR5 = Seg2 and BUSR6 = Seg3
         SELECT @cUPC = SKU
         FROM dbo.SKU WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND   BUSR5     = @seg2
         AND   BUSR6     = @seg3

         -- Batch = Seg6 + Seg8                     -> CCDETAIL.LOTTABLE01
         SET @cLottable01 = LEFT(@seg6 + @seg8, 18)

         -- MFG date = Seg6                         -> CCDETAIL.LOTTABLE02
         SET @cLottable02 = LEFT(@seg6, 18)

         -- MRP = Seg8                              -> CCDETAIL.LOTTABLE03
         SET @cLottable03 = LEFT(@seg8, 18)

         -- Serial No = Seg4 + Seg5 + Seg7          -> CCSERIALNOLOG.SERIALNO
         SET @cUserDefine01 = LEFT(@seg4 + @seg5 + @seg7, 60)

         -- Validate decoded SKU exists
         IF NOT EXISTS (
            SELECT 1 FROM dbo.SKU  WITH (NOLOCK)
            INNER JOIN dbo.PACK WITH (NOLOCK) ON SKU.PackKey = PACK.PackKey
            WHERE SKU.StorerKey = @cStorerKey
            AND   SKU.SKU       = @cUPC
         )
         BEGIN
            SET @nErrNo = 62158
            SET @cErrMsg = rdt.rdtgetmessage( 62158, @cLangCode, 'DSP') -- SKU Not Found
            GOTO Quit
         END

         -- Check if SKU+LOC+ID used by other users
         IF EXISTS (
            SELECT 1 FROM RDT.RDTCCLock WITH (NOLOCK)
            WHERE CCKey   = @cCCRefNo
            AND   SheetNo = CASE WHEN ISNULL(@cCCSheetNo, '') = '' THEN SheetNo ELSE @cCCSheetNo END
            AND   AddWho  <> @cUserName
            AND   SKU     = @cUPC
            AND   Loc     = @cLOC
            AND   Id      = @cID
            AND   Status  < '9'
         )
         BEGIN
            SET @nErrNo = 62160
            SET @cErrMsg = rdt.rdtgetmessage( 62160, @cLangCode, 'DSP') -- SKU In Use
            GOTO Quit
         END

         -- Insert serial no into CCSerialNoLog
         IF ISNULL(@cUserDefine01, '') <> ''
         BEGIN
            SET @cSerialNo30 = LEFT(@cUserDefine01, 30)
            EXECUTE RDT.rdt_TM_CycleCount_SerialNo
               @nFunc        = @nFunc,
               @nMobile      = @nMobile,
               @cLangCode    = @cLangCode,
               @cStorerKey   = @cStorerKey,
               @cFacility    = @cFacility,
               @cCCKey       = @cCCRefNo,
               @cCCDetailKey = '',
               @cCCSheetNo   = @cCCSheetNo,
               @cLot         = '',
               @cLoc         = @cLOC,
               @cID          = @cID,
               @cSKU         = @cUPC,
               @cSerialNo    = @cSerialNo30,
               @nSerialQTY   = 1,
               @nErrNo       = @nErrNo  OUTPUT,
               @cErrMsg      = @cErrMsg OUTPUT
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

GRANT EXECUTE ON [RDT].[rdt_610DecodeSP07] TO [NSQL]
GO
