SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/***********************************************************************************/
/* Store procedure: rdt_573ExtScn01                                               */
/*                                                                                 */
/* Purpose: For WOLVERINE                                                          */
/*                                                                                 */
/* Modifications log:                                                              */
/*                                                                                 */
/* Date       Rev    Author     Purposes                                           */
/* 2026-03-29 1.0.0  Cuize      FCR-11254. Created                                 */
/***********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_573ExtScn01] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep INT,
   @nScn  INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),

   @tExtScnData   VariableTable READONLY,

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
   @nAction      INT, --0 Jump Screen, 2. Prepare output fields, Step = 99 is a new screen
   @nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 1024)  OUTPUT,
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

   DECLARE  @nMOBRECStep            INT,
            @nMOBRECScn             INT,
            @cReasonCode            NVARCHAR( 10),
            @cUCC                   NVARCHAR( 20),
            @cReceiptLineNumber     NVARCHAR( 5),
            @cReceiptKey            NVARCHAR( 10),
            @cReceiptKey1           NVARCHAR( 10),
            @cReceiptKey2           NVARCHAR( 10),
            @cReceiptKey3           NVARCHAR( 10),
            @cReceiptKey4           NVARCHAR( 10),
            @cReceiptKey5           NVARCHAR( 10),
            @cExternReceiptKey      NVARCHAR( 20),
            @cLOC                   NVARCHAR( 10),
            @nTranCount             INT,
            @cPrinter_Paper         NVARCHAR( 10),
            @cPrinter               NVARCHAR( 10),
            @cOption                NVARCHAR(1),
            @cID                    NVARCHAR( 18),
            @cAutoGenID             NVARCHAR( 20),
            @cAutoID                NVARCHAR( 18),

            @tExtData               VariableTable,
            @tPalletLabel           VariableTable

      SELECT   @nMOBRECStep      = Step,
               @nMOBRECScn       = Scn,
               @cLOC             = V_LOC,
               @cReasonCode      = C_STRING1,
               @cPrinter         = Printer,
               @cPrinter_Paper   = Printer_Paper,
               @cReceiptKey1       = V_String1,
               @cReceiptKey2       = V_String2,
               @cReceiptKey3       = V_String3,
               @cReceiptKey4       = V_String4,
               @cReceiptKey5       = V_String5,
               @cExternReceiptKey  = V_String6,
               @cAutoGenID          = V_String22
      FROM rdt.RDTMOBREC WITH(NOLOCK)
      WHERE Mobile = @nMobile

   SELECT @cUCC = Value FROM @tExtScnData WHERE Variable = '@cUCC'
   SELECT @cID= Value FROM @tExtScnData WHERE Variable = '@cID'

   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
      SAVE TRAN rdt_573ExtScn01


   IF @nFunc = 573
   BEGIN
      IF @nScn = 692
      BEGIN
         --use original step = 3 logic, only change screen to 6863
         SET @nAfterScn = 6863 -- GOTO new Screen
      END

      /********************************************************************************
       Scn = 6863. ID screen + Cond Code
         ReceiptKey1    (field01)
         ReceiptKey2    (field02)
         ReceiptKey3    (field03)
         ReceiptKey4    (field04)
         ReceiptKey5    (field05)
         ExternOrderKey (field06)
         LOC            (field07)
         ID             (field08, input)
         CondCode       (field09, input)
      ********************************************************************************/

      IF @nMOBRECStep = 3 AND @nMOBRECScn = 6863
      BEGIN
         IF @nInputKey = 1
         BEGIN
            ---
            --original logic will be executed from main SP as well
            ---

            SET @cReasonCode = @cInField09

            IF ISNULL(@cReasonCode,'')<> ''
               AND NOT EXISTS( SELECT Code
               FROM dbo.CodeLKUP WITH (NOLOCK)
               WHERE ListName = 'ASNREASON'
                 AND Storerkey = @cStorerkey
                 AND Code = @cReasonCode)
            BEGIN
               SET @nErrNo = 262801
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad ReasonCode
               SET @cOutField09 = ''
               EXEC rdt.rdtSetFocusField @nMobile, 9
               GOTO Step_3_Fail
            END

         END

         IF @nInputKey = 0
         BEGIN
            SET @cReasonCode = ''
         END

         GOTO Quit

         Step_3_Fail:
         --keep current scn
         SET @nAfterScn = 6863
         Set @nAfterStep = 3

         GOTO Quit
      END

      IF @nMOBRECStep = 4
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN

            DECLARE @curRDExtUpd CURSOR
            SET @curRDExtUpd = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT ReceiptKey,ReceiptLineNumber
               FROM dbo.ReceiptDetail WITH (NOLOCK)
               WHERE StorerKey   = @cStorerKey
                 AND   Userdefine01  = @cUCC
                 AND   BeforeReceivedQty > 0
                 AND   FinalizeFlag <> 'Y'
            OPEN @curRDExtUpd
            FETCH NEXT FROM @curRDExtUpd INTO @cReceiptKey, @cReceiptLineNumber

            WHILE @@FETCH_STATUS = 0
            BEGIN

               If ISNULL(@cReasonCode,'' ) <> ''
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET
                        ConditionCode = @cReasonCode
                        ,TrafficCop = NULL
                     WHERE ReceiptKey = @cReceiptKey
                       AND ReceiptLineNumber = @cReceiptLineNumber
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 262802
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD RCDtl Fail
                     GOTO RollBackTran
                  END CATCH
               END

               FETCH NEXT FROM @curRDExtUpd INTO @cReceiptKey, @cReceiptLineNumber
            END
            CLOSE @curRDExtUpd
            DEALLOCATE @curRDExtUpd
            GOTO Quit

         END
         IF @nInputKey = 0
         BEGIN

            SELECT @cID = V_ID
            FROM rdt.RDTMOBREC WITH(NOLOCK)
            WHERE Mobile = @nMobile

            SET @cOutField01 = ''
            --GOTO Print
            SET @nAfterScn = 6864
            SET @nAfterStep = 99
         END
         GOTO Quit
      END

      IF @nMOBRECStep = 99
      BEGIN
         IF @nMOBRECScn = 6864
         BEGIN
            IF @nInputKey = 1
            BEGIN
               -- Screen mapping
               SET @cOption = @cInField01 -- Option

               -- Check option blank
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 60883
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- OptionRequired
                  GOTO Quit
               END

               -- Check option valid
               IF @cOption NOT IN ('1','2')
               BEGIN
                  SET @nErrNo = 60884
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid Option
                  GOTO Quit
               END

               IF @cOption = '1'
               BEGIN

                  DECLARE @i INT = 1
                  -- Loop ReceiptKey1..5
                  SET @cReceiptKey = ''
                  WHILE @i <= 5
                  BEGIN
                     IF @i = 1 SET @cReceiptKey = @cReceiptKey1
                     IF @i = 2 SET @cReceiptKey = @cReceiptKey2
                     IF @i = 3 SET @cReceiptKey = @cReceiptKey3
                     IF @i = 4 SET @cReceiptKey = @cReceiptKey4
                     IF @i = 5 SET @cReceiptKey = @cReceiptKey5

                     -- Validate each ReceiptKey
                     IF @cReceiptKey <> ''
                     BEGIN
                        DELETE FROM @tPalletLabel
                        INSERT INTO @tPalletLabel (Variable, Value) VALUES
                          ( '@cReceiptKey', @cReceiptKey),
                          ( '@cID', @cID)

                        EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPrinter, @cPrinter_Paper,
                             'PALLETLBL', -- Report type
                             @tPalletLabel, -- Report params
                             'rdt_573ExtScn01',
                             @nErrNo  OUTPUT,
                             @cErrMsg OUTPUT
                        --
                        IF @nErrNo <> 0
                           GOTO Quit
                     END
                     SET @i = @i + 1
                  END
               END

            END

            --GOTO ID screen

            SET @cID = ''
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

               SET @cID = @cAutoID
            END

            -- Prepare prev screen var
            SET @cOutField01 = @cReceiptKey1
            SET @cOutField02 = @cReceiptKey2
            SET @cOutField03 = @cReceiptKey3
            SET @cOutField04 = @cReceiptKey4
            SET @cOutField05 = @cReceiptKey5
            SET @cOutField06 = @cExternReceiptKey
            SET @cOutField07 = @cLOC
            SET @cOutField08 = @cID -- ID

            -- Go to prev screen
            SET @nAfterScn = 6863
            SET @nAfterStep = 3
            SET @cReasonCode = ''
            GOTO Quit

         END

      END


   END -- 573

   GOTO Quit

RollBackTran:
IF CURSOR_STATUS('variable', '@curRDExtUpd') >= -1
BEGIN
   CLOSE @curRDExtUpd;
   DEALLOCATE @curRDExtUpd;
END
ROLLBACK TRAN rdt_573ExtScn01 -- Only rollback change made here

Quit:

   SET @cUDF01 = @cID

   UPDATE rdt.RDTMOBREC SET
      C_String1 = @cReasonCode
   WHERE Mobile = @nMobile

   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN


END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_573ExtScn01 TO NSQL
GO


