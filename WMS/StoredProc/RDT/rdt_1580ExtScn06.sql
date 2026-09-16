
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1580ExtScn06                                    */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Date         Rev   Author   Purposes                                 */
/* 2026-09-03   1.0   Dennis   FCR-15406 Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1580ExtScn06] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nScn             INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @tExtScnData      VariableTable READONLY,
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT,
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nMobStep           INT
   DECLARE @nMobScn            INT
   DECLARE @cVDATA             NVARCHAR( MAX)
   DECLARE @cReceiptKey        NVARCHAR( 10)
   DECLARE @cPOKey             NVARCHAR( 18)
   DECLARE @cLOC               NVARCHAR( 10)
   DECLARE @cTOID              NVARCHAR( 18)
   DECLARE @cUserName          NVARCHAR( 18)
   DECLARE @cPrinter           NVARCHAR( 10)
   DECLARE @cBarcode           NVARCHAR( 50)
   DECLARE @cSKU               NVARCHAR( 20)
   DECLARE @cUOM               NVARCHAR( 10)
   DECLARE @cReceiptLineNumber NVARCHAR(  5)
   DECLARE @nSerialQTY         INT
   DECLARE @nBulkSNOQTY        INT

   SELECT
      @nMobStep    = Step,
      @nMobScn     = Scn,
      @cVDATA      = V_DATA,
      @cReceiptKey = V_ReceiptKey,
      @cPOKey      = V_POKey,
      @cLOC        = V_LOC,
      @cTOID       = V_ID,
      @cUserName   = UserName,
      @cPrinter    = Printer,
      @cLottable01 = V_String1,
      @cLottable02 = V_String2,
      @cLottable03 = V_String3,
      @dLottable04 = V_String4
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1580
   BEGIN
      IF @nScn = 1754 AND @nMobStep <> 98
      BEGIN
         UPDATE rdt.rdtMobRec SET V_DATA = '' WHERE Mobile = @nMobile
         SET @nAfterStep = 98
         GOTO QUIT
      END
      IF @nMobStep = 98
      BEGIN
         IF @nMobScn = 1754
         BEGIN
            IF @nInputKey = 0
            BEGIN
               INSERT INTO dbo.TraceInfo ( TraceName,          TimeIn,     Step1,                          Step2,                        Col1,                          Col2)
               VALUES                   ('1580ExtScn06', GETDATE(), CAST( @nMobile AS NVARCHAR(20)), CAST( @nFunc AS NVARCHAR(20)), LEFT( @cVDATA, 50), CAST( LEN( @cVDATA) AS NVARCHAR(20)))

               -- Clear previous log entries for this mobile
               DELETE rdt.rdtReceiveSerialNoLog
               WHERE Mobile = @nMobile
                 AND Func   = @nFunc

               -- Bulk insert all barcodes into log, grouped by SKU
               INSERT INTO rdt.rdtReceiveSerialNoLog (Mobile, Func, StorerKey, SKU, SerialNo, QTY)
               SELECT
                  @nMobile,
                  @nFunc,
                  @cStorerKey,
                  MS.SKU,
                  RTRIM( LTRIM( SS.value)),
                  ISNULL( MS.ChildQty, 1)
               FROM STRING_SPLIT( @cVDATA, ',') SS
               JOIN dbo.MASTERSERIALNO MS WITH (NOLOCK)
                  ON MS.SerialNo  = RTRIM( LTRIM( SS.value))
                 AND MS.Storerkey = @cStorerKey
               JOIN dbo.RECEIPTDETAIL RD WITH (NOLOCK)
                  ON RD.ReceiptKey  = @cReceiptKey
                 AND RD.StorerKey   = @cStorerKey
                 AND RD.SKU         = MS.SKU
                 AND RD.QtyExpected > RD.QtyReceived

               -- Call once per distinct SKU using BulkSNO
               DECLARE curSKU CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT SKU, SUM( QTY)
                  FROM rdt.rdtReceiveSerialNoLog WITH (NOLOCK)
                  WHERE Mobile = @nMobile
                    AND Func   = @nFunc
                  GROUP BY SKU

               OPEN curSKU
               FETCH NEXT FROM curSKU INTO @cSKU, @nBulkSNOQTY
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  -- Get UOM from ReceiptDetail (set at receipt creation, e.g. '6' = EA)
                  SELECT TOP 1 @cUOM = UOM
                  FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
                  WHERE ReceiptKey  = @cReceiptKey
                    AND StorerKey   = @cStorerKey
                    AND SKU         = @cSKU

                  EXEC rdt.rdt_PieceReceiving_Confirm
                     @nFunc              = @nFunc,
                     @nMobile            = @nMobile,
                     @cLangCode          = @cLangCode,
                     @nErrNo             = @nErrNo  OUTPUT,
                     @cErrMsg            = @cErrMsg OUTPUT,
                     @cStorerKey         = @cStorerKey,
                     @cFacility          = @cFacility,
                     @cReceiptKey        = @cReceiptKey,
                     @cPOKey             = @cPOKey,
                     @cToLOC             = @cLOC,
                     @cToID              = @cTOID,
                     @cSKUCode           = @cSKU,
                     @cSKUUOM            = @cUOM,
                     @nSKUQTY            = @nBulkSNOQTY,
                     @cUCC               = '',
                     @cUCCSKU            = '',
                     @nUCCQTY            = 0,
                     @cCreateUCC         = '',
                     @cLottable01        = @cLottable01,
                     @cLottable02        = @cLottable02,
                     @cLottable03        = @cLottable03,
                     @dLottable04        = @dLottable04,
                     @dLottable05        = NULL,
                     @nNOPOFlag          = 0,
                     @cConditionCode     = 'OK',
                     @cSubreasonCode     = '',
                     @cReceiptLineNumber = @cReceiptLineNumber OUTPUT,
                     @cSerialNo          = '',
                     @nSerialQTY         = 0,
                     @nBulkSNO           = 1,
                     @nBulkSNOQTY        = @nBulkSNOQTY

                  IF @nErrNo <> 0
                  BEGIN
                     CLOSE curSKU
                     DEALLOCATE curSKU
                     GOTO Quit
                  END

                  FETCH NEXT FROM curSKU INTO @cSKU, @nBulkSNOQTY
               END
               CLOSE curSKU
               DEALLOCATE curSKU

               SET @nAfterScn  = 1750
               SET @nAfterStep = 1
               SET @cOutField01 = ''
               SET @cOutField02 = ''
            END
         END
      END
   END

Quit:
END
GO
GRANT EXECUTE ON [RDT].[rdt_1580ExtScn06] TO [NSQL]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
