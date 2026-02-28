SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_513DecodeSP06                                         */
/* Copyright: Maersk                                                          */
/* Purpose: Decode SKU, QTY, serial no                                        */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-12-16  Ung       1.0   FCR-8307 Created                               */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_513DecodeSP06 (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),  
   @cStorerKey   NVARCHAR( 15), 
   @cBarcode     NVARCHAR( 2000), 
   @cFromLOC     NVARCHAR( 10)  OUTPUT, 
   @cFromID      NVARCHAR( 18)  OUTPUT, 
   @cSKU         NVARCHAR( 20)  OUTPUT, 
   @nQTY         INT            OUTPUT, 
   @cToLOC       NVARCHAR( 10)  OUTPUT, 
   @cToID        NVARCHAR( 18)  OUTPUT, 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 513 -- Move by SKU
   BEGIN
      IF @nStep = 3 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Composite barcode
            IF CHARINDEX( '&', @cBarcode) > 0
            BEGIN
               DECLARE @cTempSNO NVARCHAR( 50)
               DECLARE @cTempSKU NVARCHAR( 20)
               DECLARE @nTempQTY INT

               DECLARE @nRowCount INT
               DECLARE @cStyle NVARCHAR( 30)
               DECLARE @cSize  NVARCHAR( 30)
               DECLARE @cL01P1 NVARCHAR( 18)
               DECLARE @cL01P2 NVARCHAR( 18)
               DECLARE @cSNOP1 NVARCHAR( 10)
               DECLARE @cSNOP2 NVARCHAR( 10)
               DECLARE @cSNOP3 NVARCHAR( 10)
               
               DECLARE @tValue TABLE
               (
                  value       NVARCHAR( 100), 
                  RowNumber   INT
               )
               
               INSERT INTO @tValue (value, RowNumber)
               SELECT value, ROW_NUMBER() OVER ( ORDER BY (SELECT 1)) RowNumber 
               FROM STRING_SPLIT( @cBarcode, '&')
               
               SELECT 
                  @cStyle = CASE WHEN RowNumber = 2 THEN value ELSE @cStyle END, 
                  @cSize  = CASE WHEN RowNumber = 3 THEN value ELSE @cSize  END, 
                  @cSNOP1 = CASE WHEN RowNumber = 4 THEN value ELSE @cSNOP1 END, 
                  @cSNOP2 = CASE WHEN RowNumber = 5 THEN value ELSE @cSNOP2 END, 
                  @cL01P1 = CASE WHEN RowNumber = 6 THEN value ELSE @cL01P1 END, 
                  @cSNOP3 = CASE WHEN RowNumber = 7 THEN value ELSE @cSNOP3 END, 
                  @cL01P2 = CASE WHEN RowNumber = 8 THEN value ELSE @cL01P2 END
               FROM @tValue
               
               -- Invalid barcode
               IF @@ROWCOUNT <> 9
               BEGIN
                  SET @nErrNo = 254201
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidBarcode
                  GOTO Quit
               END

               -- Get SKU
               SELECT @cTempSKU = SKU
               FROM dbo.SKU WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND BUSR5 = @cStyle
                  AND BUSR6 = @cSize

               SET @nRowCount = @@ROWCOUNT

               -- Invalid SKU
               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 254202
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
                  GOTO Quit
               END
               
               -- Multi SKU barcode
               ELSE IF @nRowCount > 1
               BEGIN
                  SET @nErrNo = 254203
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi SKU
                  GOTO Quit
               END

               SET @cTempSNO = @cSNOP1 + @cSNOP2 + @cSNOP3
               SET @nTempQTY = 1               
               
               -- Validate serial no
               EXEC RDT.rdtIsValidSerialNo @cLangCode, @nErrNo OUTPUT, @cErrMsg OUTPUT,
                  @cTempSNO,
                  @cStorerKey,
                  @cStatus = '1', -- 1=Received
                  @cChkSKU = @cTempSKU,
                  @nChkQTY = @nTempQTY,
                  @cChkLOC = @cFromLOC,
                  @cChkID  = @cFromID
               IF @nErrNo <> 0
                  GOTO Quit

               -- Get serial no LOT
               DECLARE @cLOT NVARCHAR( 10)
               SELECT @cLOT = LOT
               FROM dbo.SerialNo WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND SerialNo = @cTempSNO
                  AND SKU = @cTempSKU

               -- Get QTY avail
               DECLARE @nQTY_Avail INT
               SELECT @nQTY_Avail = SUM( QTY - QTYAllocated - QTYPicked - (CASE WHEN QtyReplen < 0 THEN 0 ELSE QtyReplen END))
               FROM dbo.LOTxLOCxID WITH (NOLOCK)
               WHERE LOT = @cLOT
                  AND LOC = @cFromLOC
                  AND ID = @cFromID

               -- Validate no QTY
               IF @nQTY_Avail = 0 OR @nQTY_Avail IS NULL
               BEGIN
                  SET @nErrNo = 254204
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No QTY to move
                  GOTO Quit
               END
               
               -- Clear log
               EXEC rdt.rdt_Move_SerialNo @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CLEARLOG'
                  ,@cTempSKU
                  ,'' -- @cSerialNo
                  ,0  -- @nSerialQTY
                  ,'' -- @cToLOC
                  ,'' -- @cToID
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit
               
               -- Insert log
               EXEC rdt.rdt_Move_SerialNo @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'INSERTLOG'
                  ,@cTempSKU
                  ,@cTempSNO
                  ,@nTempQTY
                  ,'' -- @cToLOC
                  ,'' -- @cToID
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit
               
               SET @cSKU = @cTempSKU
               SET @nQTY = @nTempQTY
            END
            ELSE
            BEGIN
               SET @nErrNo = 254205
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidBarcode
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

GRANT EXECUTE ON rdt.rdt_513DecodeSP06 TO NSQL
GO
