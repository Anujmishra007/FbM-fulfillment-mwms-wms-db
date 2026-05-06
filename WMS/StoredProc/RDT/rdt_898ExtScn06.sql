SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_898ExtScn06                                           */
/* Copyright      : Maersk WMS                                                */
/* Customer       : UAE Levis                                                 */
/*                                                                            */
/*                                                                            */
/* Date        Rev     Author   Purposes                                      */
/* 2026-02-25  1.0.0   NickT    FCR-10628 Create                              */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_898ExtScn06] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nScn         INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),

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
   @nAfterScn        INT            OUTPUT,
   @nAfterStep       INT            OUTPUT,
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
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( MAX) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Variables
   DECLARE
      @cReceiptKey       NVARCHAR( 10),
      @cDocType          NVARCHAR( 1),
      @cOption           NVARCHAR( 5),
      @nCurrentStep      INT,
      @nOpenQty          INT

   -- Get session data
   SELECT
      @cReceiptKey    = V_ReceiptKey,
      @nCurrentStep   = Step
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Get DOCTYPE from Receipt
   SELECT @cDocType = DOCTYPE,
      @nOpenQty = OpenQTY
   FROM dbo.Receipt WITH (NOLOCK)
   WHERE ReceiptKey = @cReceiptKey
      AND StorerKey = @cStorerKey
      AND Facility = @cFacility

   -- Only apply when DOCTYPE = 'A'
   IF @cDocType <> 'A'
      GOTO Quit

   IF @nFunc = 898
   BEGIN
      IF @nCurrentStep = 12  -- Close pallet?
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            SET @cOption = @cInField01

            IF @cOption IN ('2', '3') 
            BEGIN
               IF @nOpenQty = 0
               BEGIN
                  IF NOT EXISTS(SELECT 1 FROM RDT.rdtMsgQueue WITH(NOLOCK) WHERE Mobile = @nMobile AND Line03 = @cReceiptKey)
                  BEGIN
                     DECLARE
                        @cMsg01                 NVARCHAR(20) = '',
                        @cMsg02                 NVARCHAR(20) = '',
                        @cMsg03                 NVARCHAR(20) = '',
                        @cMsg04                 NVARCHAR(20) = '',
                        @cMsg05                 NVARCHAR(20) = '',
                        @cMsg06                 NVARCHAR(20) = '',
                        @cMsg07                 NVARCHAR(20) = '',
                        @cMsg08                 NVARCHAR(20) = '',
                        @cMsg09                 NVARCHAR(20) = ''

                     SET @cMsg01 = 'ASN completely '
                     SET @cMsg02 = 'received.'
                     SET @cMsg03 = @cReceiptKey
                     EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                           @nErrNo = @nErrNo,
                           @cErrMsg = @cErrMsg,
                           @cLine01 = @cMsg01,
                           @cLine02 = @cMsg02,
                           @cLine03 = @cMsg03,
                           @cLine04 = @cMsg04,
                           @cLine05 = @cMsg05,
                           @cLine06 = @cMsg06,
                           @cLine07 = @cMsg07,
                           @cLine08 = @cMsg08,
                           @cLine09 = @cMsg09,
                           @nDisplayMsg = 0
                  END

                  SET @nAfterScn = 1300
                  SET @nAfterStep = 1

                  SET @cOutField01 = ''
                  SET @cOutField01 = ''
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

GRANT EXECUTE ON rdt.rdt_898ExtScn06 TO NSQL
GO
