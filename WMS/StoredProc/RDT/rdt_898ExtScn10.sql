SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_898ExtScn10                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: 1. Copy AutoGenID from function 600 when going to scn 1302  */
/*          2. Print pallet label on close pallet (option 2 or 3)       */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-06-03 1.0  Dennis   FCR-13584 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_898ExtScn10] (
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
   @nAction          INT, --0 Jump Screen, 1 Validation, 2 Update, 3 Prepare output fields
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

   DECLARE
      @cAutoGenID    NVARCHAR( 20),
      @cAutoID       NVARCHAR( 18),
      @tExtData      VariableTable,
      @cReceiptKey   NVARCHAR( 10),
      @cToID         NVARCHAR( 18),
      @cLabelPrinter NVARCHAR( 10),
      @cPaperPrinter NVARCHAR( 10),
      @tPrintParam   VariableTable,
      @nMobRecStep   INT,
      @cOption       NVARCHAR( 1)

   -- Get current step and other info from rdtMobRec
   SELECT   @nMobRecStep   = Step,
            @cReceiptKey   = V_ReceiptKey,
            @cToID         = V_ID,
            @cLabelPrinter = Printer,
            @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get Option from ExtScnData
   SELECT @cOption = Value FROM @tExtScnData WHERE Variable = '@cOption'

   IF @nFunc = 898
   BEGIN
      -- When going to TO ID screen (scn 1302, step 3)
      IF @nScn = 1302
      BEGIN
         -- Check if returning from step 4 (ESC from Estimate UCC screen)
         IF @nMobRecStep = 4 AND @nInputKey = 0
         BEGIN
            -- Set existing ID to outfield
            SET @cOutField04 = @cToID

            -- Check if Receipt.ProcessType = 'C' or 'N' and has received qty on this pallet
            IF EXISTS (
               SELECT 1
               FROM dbo.Receipt R WITH (NOLOCK)
               JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON R.ReceiptKey = RD.ReceiptKey AND R.StorerKey = RD.StorerKey
               WHERE R.ReceiptKey = @cReceiptKey
                  AND R.StorerKey = @cStorerKey
                  AND R.ProcessType IN ('C', 'N')
                  AND RD.ToID = @cToID
                  AND RD.BeforeReceivedQTY > 0
            )
            BEGIN
               -- Print pallet label
               DELETE FROM @tPrintParam
               INSERT INTO @tPrintParam (Variable, Value)
               VALUES
                  ('@cStorerKey', @cStorerKey),
                  ('@cID', @cToID),
                  ('@cReceiptKey', @cReceiptKey)

               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, 1, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                  'PALLETLBL',      -- Report type
                  @tPrintParam,     -- Report params
                  'rdt_898ExtScn10',
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Quit
            END
         END

         -- Only generate new ID when entering from step 2 (not returning from other steps)
         IF @nMobRecStep = 2 AND @nInputKey = 1
         BEGIN
            -- Get AutoGenID config from function 600
            SET @cAutoGenID = rdt.RDTGetConfig(600, 'AutoGenID', @cStorerKey)
            IF @cAutoGenID = '0'
               SET @cAutoGenID = ''

            IF @cAutoGenID <> ''
            BEGIN
               EXEC rdt.rdt_AutoGenID @nMobile, @nFunc, @nStep, @cLangCode
                  ,@cAutoGenID
                  ,@tExtData
                  ,@cAutoID  OUTPUT
                  ,@nErrNo   OUTPUT
                  ,@cErrMsg  OUTPUT

               IF @nErrNo <> 0
                  GOTO Quit

               SET @cOutField04 = @cAutoID
            END
         END
      END

      -- Step 12: Close pallet screen - print pallet label on option 2 or 3
      IF @nMobRecStep = 12 AND @nInputKey = 1
      BEGIN
         IF @cOption IN ('2', '3')
         BEGIN
            -- Prepare print parameters
            DELETE FROM @tPrintParam
            INSERT INTO @tPrintParam (Variable, Value)
            VALUES
               ('@cStorerKey', @cStorerKey),
               ('@cID', @cToID),
               ('@cReceiptKey', @cReceiptKey)

            -- Print pallet label
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, 1, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
               'PALLETLBL',      -- Report type
               @tPrintParam,     -- Report params
               'rdt_898ExtScn10',
               @nErrNo  OUTPUT,
               @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
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

GRANT EXECUTE ON RDT.rdt_898ExtScn10 TO NSQL
GO
