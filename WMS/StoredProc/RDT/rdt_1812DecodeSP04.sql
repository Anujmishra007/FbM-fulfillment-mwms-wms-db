
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812DecodeSP04                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Decode UCC No                                               */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 2025-06-16  1.0  NickT       FCR-5753 Created                        */
/* 2025-06-26  1.1  Dennis      FCR-5753 Fix Bug                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1812DecodeSP04
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cTaskdetailKey NVARCHAR( 10),
   @cBarcode       NVARCHAR( MAX),
   @cFromID        NVARCHAR( 18)  OUTPUT,
   @cSKU           NVARCHAR( 20)  OUTPUT,
   @nQTY           INT            OUTPUT,
   @cUCC           NVARCHAR( 20)  OUTPUT,
   @cDropID        NVARCHAR( 20)  OUTPUT,
   @nErrNo         INT            OUTPUT,
   @cErrMsg        NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cSKUTemp         NVARCHAR(20),
      @cItemClass       NVARCHAR(10),
      @cBUSR10          NVARCHAR(30),
      @nSKURangeStart   INT,
      @nSKULength       INT,
      @cQtyRangeStart   INT,
      @cQtyLength       INT,
      @nSKUQty          INT = 0,
      @nRowCnt          INT = 0,
      @nLoopIndex       INT = -1

   DECLARE @tSKULabelInfo TABLE
   (
      id             INT IDENTITY(1,1),
      ItemClass      NVARCHAR(10),
      BUSR10         NVARCHAR(30),
      SKURangeStart  INT,
      SKULength      INT,
      QtyRangeStart  INT,
      QtyLength      INT
   )

   SET @nErrNo = 0
   SET @cErrMsg = 0

   IF @nFunc = 1812
   BEGIN
      IF @nStep = 4 --SKU Qty Screen
      BEGIN
         IF ISNULL(@cBarcode, '') = ''
         BEGIN
            SET @nErrNo = 223651
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Barcode
            GOTO Quit
         END

         SET @cSKUTemp = SUBSTRING(@cBarcode, 5, 14 )

         IF ISNULL(@cSKUTemp, '') = ''
            RETURN

         SELECT @cSKUTemp = SKU FROM dbo.SKU WITH(NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND ALTSKU = @cSKUTemp

         SELECT @cItemClass = ItemClass,
                @cBUSR10 = BUSR10
         FROM dbo.SKU WITH(NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND SKU = @cSKUTemp

         IF @cItemClass <> 'PVAR' OR @cBUSR10 NOT IN ('Brazil', 'NewZealand')
            RETURN

         INSERT INTO @tSKULabelInfo (ItemClass, BUSR10, SKURangeStart, SKULength, QtyRangeStart, QtyLength)
         VALUES('PVAR', 'Brazil', 5, 14, 25, 6), ('PVAR', 'NewZealand', 5, 14, 35, 6)

         SET @nLoopIndex = -1
         WHILE 1 = 1
         BEGIN
            SELECT TOP 1
               @nLoopIndex = id,
               @cItemClass = ItemClass,
               @cBUSR10 = BUSR10,
               @nSKURangeStart = SKURangeStart,
               @nSKULength = SKULength,
               @cQtyRangeStart = QtyRangeStart,
               @cQtyLength = QtyLength
            FROM @tSKULabelInfo
            WHERE id > @nLoopIndex

            IF @@ROWCOUNT = 0
               BREAK

            SELECT @nRowCnt = COUNT(1)
            FROM dbo.SKU WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND SKU = @cSKUTemp
               AND ISNULL(ItemClass, '') = @cItemClass
               AND ISNULL(BUSR10, '') = @cBUSR10

            IF @nRowCnt = 0
            BEGIN
               SET @cBUSR10 = ''
               CONTINUE
            END

            BEGIN TRY
               SET @nSKUQty = TRY_CAST(SUBSTRING(@cBarcode, @cQtyRangeStart, @cQtyLength) AS INT)
            END TRY
            BEGIN CATCH
               SET @nErrNo = 240253
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Fetch Weight Fail
               GOTO Quit
            END CATCH

            IF ISNULL(@nSKUQty, 0) < 1
            BEGIN
               CONTINUE
            END
         END

         IF ISNULL(@cSKUTemp, '') = '' OR ISNULL(@nSKUQty, 0) < 1
         BEGIN
            SET @nErrNo = 240255
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Decode Fail
            RETURN
         END

         SET @cSKU = @cSKUTemp
         SET @nQTY = @nSKUQty

         IF @cBUSR10 = 'NewZealand'
            SET @nQTY = @nQTY * 10
      END
   END
END

Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1812DecodeSP04 TO NSQL
GO
