SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_839DecodeSP09                                         */
/* Copyright      : Maersk                                                    */
/* Customer       : PAGEIND                                                   */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2026-01-04  1.0   NickT      FCR-9040. Created                             */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_839DecodeSP09] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5),  
   @cStorerKey   NVARCHAR( 15), 
   @cBarcode     NVARCHAR( 2000), 
   @cPickSlipNo  NVARCHAR( 10), 
   @cPickZone    NVARCHAR( 10), 
   @cDropID      NVARCHAR( 20), 
   @cLOC         NVARCHAR( 10), 
   @cUPC         NVARCHAR( 30)  OUTPUT, 
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
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nRowCount              INT = 0,
      @cPickDetailUOM         NVARCHAR( 10),
      @cSuggLOC               NVARCHAR( 10),
      @cSuggSKU               NVARCHAR( 20),
      @cSuggUCC               NVARCHAR( 20),
      @cSuggLot               NVARCHAR( 10),
      @nSuggQty               INT,
      @cPickDetailKey         NVARCHAR( 18),
      @cSuggUCCLottable01     NVARCHAR( 18),
      @cOrderKey              NVARCHAR( 10),
      @cLoadKey               NVARCHAR( 10),
      @cZone                  NVARCHAR( 18),
      @cPickConfirmStatus     NVARCHAR( 1)

   SET @cOrderKey = ''
   SET @cLoadKey = ''
   SET @cZone = ''

   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   
   IF @nFunc = 839
   BEGIN
      UPDATE RDT.RDTMOBREC WITH(ROWLOCK)
      SET
         C_String3 = '',
         C_String4 = '',
         C_String7 = ''
      WHERE Mobile = @nMobile
      
      IF @cBarcode <> '' 
      BEGIN
         IF CHARINDEX( '&', @cBarcode) > 0
         BEGIN
            IF LEN(@cBarcode) - LEN(REPLACE(@cBarcode, '&', '')) < 7
            BEGIN
               SET @nErrNo = 255451
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid barcode format
               GOTO Quit
            END

            SELECT 
               @cSuggSKU = V_SKU,
               @nSuggQTY = V_QTY,
               @cSuggLOC = V_LOC,
               @cSuggUCC = C_String1,
               @cSuggLot = C_String2
            FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile

            IF ISNULL(@cSuggUCC, '') <> '' 
               AND EXISTS(SELECT 1 FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC AND SKU = @cSuggSKU)
            BEGIN
               SET @cPickDetailUOM = '2'
               SELECT
                  @cSuggLOT = Lot
               FROM dbo.UCC WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND UCCNo = @cSuggUCC
            END
            ELSE
            BEGIN
               SET @cPickDetailUOM = '6'
            END
            
            DECLARE
               @cSegment1     NVARCHAR(30),
               @cSegment2     NVARCHAR(30),
               @cSegment3     NVARCHAR(30),
               @cSegment4     NVARCHAR(30),
               @cSegment5     NVARCHAR(30),
               @cSegment6     NVARCHAR(30),
               @cSegment7     NVARCHAR(30),
               @cSegment8     NVARCHAR(30),
               @cSegment      NVARCHAR(30),
               @cScannedUCC   NVARCHAR(20),
               @cTempBarcode  NVARCHAR(MAX),
               @nLoopIndex    INT = 0,

               @cScannedUCCLoc         NVARCHAR( 10),
               @cScannedUCCLot         NVARCHAR( 10),
               @cScannedUCCSKU         NVARCHAR( 30),
               @nScannedUCCQty         INT,
               @cScannedID             NVARCHAR( 18),
               @cScannedUCCStatus      NVARCHAR( 1),
               @cScannedUCCLottable01  NVARCHAR(18)

            SET @cTempBarcode = @cBarcode

            WHILE 1 = 1
            BEGIN
               SET @nLoopIndex = @nLoopIndex + 1
               IF @nLoopIndex > 8 BREAK

               IF CHARINDEX('&', @cTempBarcode) > 0
               BEGIN
                  SELECT @cSegment = LEFT(@cTempBarcode, CHARINDEX('&', @cTempBarcode) - 1)
                  SET @cTempBarcode = RIGHT(@cTempBarcode, LEN(@cTempBarcode) - CHARINDEX('&', @cTempBarcode) )
               END
               ELSE
               BEGIN
                  SELECT @cSegment = @cTempBarcode
                  SET @cTempBarcode = ''
               END

               IF @nLoopIndex = 1 SET @cSegment1 = @cSegment
               IF @nLoopIndex = 2 SET @cSegment2 = @cSegment
               IF @nLoopIndex = 3 SET @cSegment3 = @cSegment
               IF @nLoopIndex = 4 SET @cSegment4 = @cSegment
               IF @nLoopIndex = 5 SET @cSegment5 = @cSegment
               IF @nLoopIndex = 6 SET @cSegment6 = @cSegment
               IF @nLoopIndex = 7 SET @cSegment7 = @cSegment
               IF @nLoopIndex = 8 SET @cSegment8 = @cSegment
            END

            -- UCC
            IF @cPickDetailUOM = '2'
            BEGIN
               SET @cScannedUCC = @cSegment4 + @cSegment5 + @cSegment7

               SELECT 
                  @cScannedUCCLoc = Loc,
                  @cScannedUCCLot = Lot,
                  @cScannedUCCSKU = SK.SKU,
                  @nScannedUCCQty = Qty,
                  @cScannedUCCStatus = Status
               FROM dbo.UCC WITH(NOLOCK)
               INNER JOIN dbo.SKU SK WITH(NOLOCK) ON UCC.StorerKey = SK.StorerKey AND UCC.SKU = SK.SKU
               WHERE UCC.UCCNo = @cScannedUCC
                  AND UCC.StorerKey = @cStorerKey

               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 255452
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC
                  GOTO Quit
               END

               -- Check multi SKU UCC
               IF @nRowCount > 1
               BEGIN
                  SET @nErrNo = 255466
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi SKU UCC
                  GOTO Quit
               END

               IF EXISTS(SELECT 1 FROM rdt.rdtPickLog WITH(NOLOCK) WHERE Mobile = @nMobile AND PickSlipNo = @cPickSlipNo AND Remarks = @cScannedUCC AND PickMethod = 'GetTask-U')
               BEGIN
                  SET @nErrNo = 255473
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC is scanned
                  GOTO Quit
               END

               -- Compare with suggested UCC
               IF @cSuggUCC = @cScannedUCC
               BEGIN
                  SET @cUPC = @cScannedUCCSKU
                  SET @nQTY = @nScannedUCCQty

                  UPDATE RDT.RDTMOBREC WITH(ROWLOCK)
                  SET
                     C_String3 = @cScannedUCC
                  WHERE Mobile = @nMobile
                  RETURN
               END
               ELSE --if scanned UCC not match, check if UCC exists, also need check if loc/sku/lot/qty match
               BEGIN
                  IF @cScannedUCCStatus <> '1'
                  BEGIN
                     SET @nErrNo = 255457
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Scanned UCC is not available
                     GOTO Quit
                  END

                  IF @cScannedUCCLoc <> @cLOC
                  BEGIN
                     SET @nErrNo = 255453
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Loc does not match
                     GOTO Quit
                  END

                  IF @cScannedUCCSKU <> @cSuggSKU
                  BEGIN
                     SET @nErrNo = 255454
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- SKU does not match
                     GOTO Quit
                  END

                  IF @cScannedUCCLot <> @cSuggLOT
                  BEGIN
                     SET @nErrNo = 255455
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- LOT does not match
                     GOTO Quit
                  END

                  IF @nScannedUCCQty <> @nSuggQty
                  BEGIN
                     SET @nErrNo = 255456
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Qty does not match
                     GOTO Quit
                  END

                  SET @cUPC = @cScannedUCCSKU
                  SET @nQTY = @nScannedUCCQty

                  UPDATE RDT.RDTMOBREC WITH(ROWLOCK)
                  SET
                     C_String3 = @cScannedUCC
                  WHERE Mobile = @nMobile
               END
            END
            -- Piece
            ELSE IF @cPickDetailUOM = '6'
            BEGIN
               DECLARE 
                  @cSerialNo           NVARCHAR(50),
                  @cSKUBUSR5           NVARCHAR(30),
                  @cSKUBUSR6           NVARCHAR(30)
               
               SELECT @cSKUBUSR5 = @cSegment2, @cSKUBUSR6 = @cSegment3

               IF NOT EXISTS(SELECT 1 
                              FROM dbo.SKU WITH(NOLOCK)
                              WHERE StorerKey = @cStorerKey
                                 AND SKU = @cSuggSKU
                                 AND ISNULL(BUSR6, '') = @cSKUBUSR6
                                 AND ISNULL(BUSR5, '') = @cSKUBUSR5)
               BEGIN
                  SET @nErrNo = 255458
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- BUSR5 or BUSR6 does not match
                  GOTO Quit
               END

               SET @cSerialNo = @cSegment4 + @cSegment5 + @cSegment7

               SELECT
                  @cScannedUCCLot = Lot
               FROM dbo.SerialNo WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND SerialNo = @cSerialNo

               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 255459
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Serial Number
                  GOTO Quit
               END

               SELECT @cScannedUCC = ParentSerialNo
               FROM dbo.MasterSerialNo MSN WITH(NOLOCK)
               WHERE UnitType = 'BB'
                  AND StorerKey = @cStorerKey
                  AND SerialNo = @cSerialNo

               IF @@ROWCOUNT > 0
               BEGIN
                  SELECT @nRowCount = COUNT(1)
                     FROM dbo.MasterSerialNo MSN WITH(NOLOCK)
                  WHERE UnitType = 'UCC'
                     AND StorerKey = @cStorerKey
                     AND SerialNo = @cScannedUCC

                  IF @nRowCount > 0
                  BEGIN
                     SELECT 
                        @cScannedUCCLoc = Loc,
                        @cScannedUCCLot = Lot,
                        @cScannedUCCSKU = SK.SKU,
                        @nScannedUCCQty = Qty,
                        @cScannedID     = ID,
                        @cScannedUCCStatus = Status
                     FROM dbo.UCC WITH(NOLOCK)
                     INNER JOIN dbo.SKU SK WITH(NOLOCK) ON UCC.StorerKey = SK.StorerKey AND UCC.SKU = SK.SKU
                     WHERE UCC.UCCNo = @cScannedUCC
                        AND UCC.StorerKey = @cStorerKey

                     SET @nRowCount = @@ROWCOUNT

                     IF @nRowCount = 0
                     BEGIN
                        SET @nErrNo = 255460
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC
                        GOTO Quit
                     END

                     -- Check multi SKU UCC
                     IF @nRowCount > 1
                     BEGIN
                        SET @nErrNo = 255467
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi SKU UCC
                        GOTO Quit
                     END

                     IF @cScannedUCCLoc <> @cLOC
                     BEGIN
                        SET @nErrNo = 255462
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Loc does not match
                        GOTO Quit
                     END

                     IF @cScannedUCCSKU <> @cSuggSKU
                     BEGIN
                        SET @nErrNo = 255463
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- SKU does not match
                        GOTO Quit
                     END
                  END
                  ELSE
                  BEGIN
                     SET @nErrNo = 255470
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC does not exist in MasterSerialNo
                     GOTO Quit
                  END
               END
               ELSE
               BEGIN
                  SET @nErrNo = 255468
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SerialNo does not exist in MasterSerialNo
                  GOTO Quit
               END

               IF EXISTS(SELECT 1 FROM rdt.rdtPickLog WITH(NOLOCK) WHERE Mobile = @nMobile AND PickSlipNo = @cPickSlipNo AND Remarks = @cSerialNo AND PickMethod = 'Pick-P')
               BEGIN
                  SET @nErrNo = 255474
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SerialNo is scanned
                  GOTO Quit
               END

               -- If serial number match, validation passed
               IF @cScannedUCCLot = @cSuggLOT
               BEGIN
                  SET @cUPC = @cSuggSKU
                  SET @nQTY = @nSuggQTY

                  UPDATE RDT.RDTMOBREC WITH(ROWLOCK)
                  SET
                     C_String3 = @cScannedUCC,
                     C_String4 = @cScannedUCCLottable01,
                     C_String7 = @cSerialNo,
                     C_String8 = @cScannedUCCLot
                  WHERE Mobile = @nMobile

                  RETURN
               END
               -- If LOT does not match, need to check lLottable01
               ELSE
               BEGIN
                  IF @cScannedUCCLot <> @cSuggLOT
                  BEGIN
                     SELECT @cScannedUCCLottable01 = Lottable01
                     FROM dbo.LotAttribute WITH(NOLOCK)
                     WHERE Lot = @cScannedUCCLot
                        AND StorerKey = @cStorerKey

                     SELECT @cSuggUCCLottable01 = Lottable01
                     FROM dbo.LotAttribute WITH(NOLOCK)
                     WHERE Lot = @cSuggLOT
                        AND StorerKey = @cStorerKey

                     IF @cScannedUCCLottable01 <> @cSuggUCCLottable01
                     BEGIN
                        SET @nErrNo = 255465
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Lottable01 does not match
                        GOTO Quit
                     END

                     DECLARE @nAvailableQty INT = 0

                     SELECT @nAvailableQty = SUM(Qty - QtyAllocated - QtyPicked )
                     FROM LOTXLOCXID WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND Loc = @cLOC
                        AND LOT = @cScannedUCCLot

                     IF ISNULL(@nAvailableQty, 0) < 1
                     BEGIN
                        SET @nErrNo = 255471
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Stock is allocated
                        GOTO Quit
                     END

                     SELECT @nAvailableQty = SUM(Qty - QtyAllocated - QtyPicked )
                     FROM LOTXLOCXID WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND Loc = @cLOC
                        AND LOT = @cScannedUCCLot
                        AND ID = @cScannedID

                     IF ISNULL(@nAvailableQty, 0) < 1
                     BEGIN
                        SET @nErrNo = 255472
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Stock is allocated
                        GOTO Quit
                     END
                  END

                  UPDATE RDT.RDTMOBREC WITH(ROWLOCK)
                  SET
                     C_String3 = @cScannedUCC,
                     C_String4 = @cScannedUCCLottable01,
                     C_String7 = @cSerialNo,
                     C_String8 = @cScannedUCCLot
                  WHERE Mobile = @nMobile

                  SET @cUPC = @cScannedUCCSKU
                  SET @nQTY = 1
               END
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

GRANT EXECUTE ON RDT.rdt_839DecodeSP09 TO NSQL
GO