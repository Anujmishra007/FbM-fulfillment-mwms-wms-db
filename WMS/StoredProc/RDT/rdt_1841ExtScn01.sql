
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***********************************************************************************/
/* Store procedure: rdt_1841ExtScn01                                               */
/* Customer: UK COLUMBIA                                                           */
/* Copyright: Maersk WMS                                                           */
/*                                                                                 */
/*                                                                                 */
/* Modifications log:                                                              */
/*                                                                                 */
/* Date       Rev    Author     Purposes                                           */
/* 2025-11-25 1.0    NickT      FCR-9027. Created                                  */
/***********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1841ExtScn01] (
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
   @cErrMsg            NVARCHAR( 20)  OUTPUT,
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
      @nCurrentStep           INT,
      @nCurrentScn            INT,
      @cCartonID              NVARCHAR( 20),
      @cReceiptKey            NVARCHAR( 10),
      @cLane                  NVARCHAR( 10),
      @cUCC                   NVARCHAR( 20), 
      @cPosition              NVARCHAR( 20),
      @cToID                  NVARCHAR( 18),
      @cClosePallet           NVARCHAR( 1),
      @cSuggID                NVARCHAR( 18),
      @cDefaultToId           NVARCHAR( 1),
      @cExtendedInfo          NVARCHAR( 20),
      @cExtendedInfoSP        NVARCHAR( 20),
      @cSKU                   NVARCHAR( 20),
      @cSQL                   NVARCHAR( MAX),
      @cSQLParam              NVARCHAR( MAX),
      @nQty                   INT,
      @tExtInfoVar            VariableTable

   SELECT
      @nCurrentStep        = Step,
      @nCurrentScn         = Scn,
      @cReceiptKey         = V_ReceiptKey,
      @cLane               = V_LOC,
      @cUCC                = V_UCC,
      @cSKU                = V_SKU,
      @cPosition           = V_String20,
      @cExtendedInfoSP     = V_String23,
      @cSuggID             = V_String27,
      @cDefaultToId        = V_String37,
      @cToID               = V_ID
      
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1841
   BEGIN
      -- If current step is 2 and next step is 3, go to step 99 (Carton ID screen)
      IF @nCurrentStep = 2
      BEGIN
         IF @nInputKey = 1 -- Yes
         BEGIN
            IF @nStep = 3
            BEGIN
               -- UCC is not stored in RDTMOBREC.V_UCC yet
               SELECT
                  @cUCC          = @cInField03
               FROM rdt.RDTMOBREC WITH(NOLOCK)
               WHERE Mobile = @nMobile
               
               SET @cOutField01 = @cReceiptKey
               SET @cOutField02 = @cLane
               SET @cOutField03 = @cUCC

               SET @nAfterStep = 99
               SET @nAfterScn  = 6705
               GOTO Quit
            END
         END
      END
      -- If current step is 3 and go back to step 2 by ESC, go to step 99 (Carton ID screen)
      ELSE IF @nCurrentStep = 3
      BEGIN
         IF @nInputKey = 0 -- No
         BEGIN
            IF @nStep = 2
            BEGIN
               SET @cOutField01 = @cReceiptKey
               SET @cOutField02 = @cLane
               SET @cOutField03 = @cUCC

               SET @nAfterStep = 99
               SET @nAfterScn  = 6705
               GOTO Quit
            END
         END
      END
      ELSE IF @nCurrentStep = 99
      BEGIN
         /********************************************************************************
         Step 99. Screen = 6705. Scan CartonID
            ASN      (Field01, output)
            LANE     (Field02, output)
            UCC      (Field03, output)
            DROPID   (Field04, input)
            EXTINFO  (Field10)
         ********************************************************************************/
         IF @nCurrentScn = 6705 -- Carton ID screen
         BEGIN
            IF @nInputKey = 1 -- Yes
            BEGIN
               DECLARE @tRowRef TABLE (RowRef INT PRIMARY KEY)

               SET @cCartonID = LTRIM(RTRIM(@cInField04))
               IF @cCartonID = ''
               BEGIN
                  SET @nErrNo  = 252351
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Carton ID Needed
                  GOTO Quit
               END

               IF EXISTS(SELECT 1 
                        FROM dbo.UCC WITH(NOLOCK) 
                        WHERE StorerKey = @cStorerKey 
                           AND UCCNo = @cCartonID )
               BEGIN
                  SET @nErrNo  = 252352
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Carton ID Already Exists
                  GOTO Quit
               END

               DECLARE 
                  @nRowRef       INT

               INSERT INTO @tRowRef (RowRef)
               SELECT RowRef
               FROM rdt.rdtPreReceiveSort WITH (NOLOCK)
               WHERE ReceiptKey = @cReceiptKey
                  AND LOC = @cLane
                  AND Status = '1'
                  AND UCCNo = @cUCC
               ORDER BY 1

               SET @nRowRef = -1
               WHILE 1=1
               BEGIN
                  SELECT TOP 1
                     @nRowRef = RowRef
                  FROM @tRowRef
                  WHERE RowRef > @nRowRef
                  ORDER BY RowRef

                  IF @@ROWCOUNT = 0 
                     BREAK

                  -- Update UDF05 with CartonID
                  BEGIN TRY
                     UPDATE rdt.rdtPreReceiveSort WITH(ROWLOCK)
                     SET 
                        UDF05 = @cCartonID,
                        EditWho = SUSER_NAME(),
                        EditDate = GETDATE()
                     WHERE RowRef = @nRowRef
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo  = 252353
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Update Sort Data Failed
                     GOTO Quit
                  END CATCH
               END

               IF @cExtendedInfoSP <> '' AND
                  EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
               BEGIN
                  DELETE FROM @tExtInfoVar

                   INSERT INTO @tExtInfoVar (Variable, Value) VALUES
                        ('@cCartonID',       @cCartonID)

                  SET @cExtendedInfo = ''
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, ' +
                     ' @cReceiptKey, @cLane, @cUCC, @cToID, @cSKU, @nQty, @cOption, @cPosition, @tExtInfoVar, ' +
                     ' @cExtendedInfo OUTPUT '
                  SET @cSQLParam =
                     ' @nMobile        INT,           ' +
                     ' @nFunc          INT,           ' +
                     ' @cLangCode      NVARCHAR( 3),  ' +
                     ' @nStep          INT,           ' +
                     ' @nAfterStep     INT,           ' +
                     ' @nInputKey      INT,           ' +
                     ' @cFacility      NVARCHAR( 5),  ' +
                     ' @cStorerKey     NVARCHAR( 15), ' +
                     ' @cReceiptKey    NVARCHAR( 10), ' +
                     ' @cLane          NVARCHAR( 10), ' +
                     ' @cUCC           NVARCHAR( 20), ' +
                     ' @cToID          NVARCHAR( 18), ' +
                     ' @cSKU           NVARCHAR( 20), ' +
                     ' @nQty           INT,           ' +
                     ' @cOption        NVARCHAR( 1),  ' +
                     ' @cPosition      NVARCHAR( 20), ' +
                     ' @tExtInfoVar    VariableTable READONLY, ' +
                     ' @cExtendedInfo  NVARCHAR( 20) OUTPUT    '
            
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey,
                     @cReceiptKey, @cLane, @cUCC, @cSuggID, @cSKU, @nQty, '', @cPosition, @tExtInfoVar,
                     @cExtendedInfo OUTPUT
               END

               SET @cOutField01 = @cUCC
               SET @cOutField02 = @cPosition
               SET @cOutField03 = @cSuggID
               SET @cOutField04 = CASE WHEN @cDefaultToId = '1' THEN @cSuggID ELSE '' END
               SET @cOutField15 = @cExtendedInfo

               SET @nAfterStep = 3
               SET @nAfterScn  = 5662
            END
            ELSE IF @nInputKey = 0 -- No
            BEGIN
               EXEC [RDT].[rdt_PrePalletizeSort]
                  @nMobile       = @nMobile,
                  @nFunc         = @nFunc,
                  @cLangCode     = @cLangCode,
                  @nStep         = @nStep,
                  @nInputKey     = @nInputKey,
                  @cStorerKey    = @cStorerKey,
                  @cFacility     = @cFacility,
                  @cReceiptKey   = @cReceiptKey,
                  @cLane         = @cLane,
                  @cUCC          = @cUCC,
                  @cSKU          = @cSKU,
                  @cType         = 'DEL.UCC',
                  @cCreateUCC    = '0',
                  @cLottable01   = NULL,
                  @cLottable02   = NULL,
                  @cLottable03   = NULL,
                  @dLottable04   = NULL,
                  @dLottable05   = NULL,
                  @cLottable06   = NULL,
                  @cLottable07   = NULL,
                  @cLottable08   = NULL,
                  @cLottable09   = NULL,
                  @cLottable10   = NULL,
                  @cLottable11   = NULL,
                  @cLottable12   = NULL,
                  @dLottable13   = NULL,
                  @dLottable14   = NULL,
                  @dLottable15   = NULL,
                  @cPosition     = @cPosition      OUTPUT,
                  @cToID         = @cToID          OUTPUT,
                  @cClosePallet  = @cClosePallet   OUTPUT,
                  @nErrNo        = @nErrNo         OUTPUT,
                  @cErrMsg       = @cErrMsg        OUTPUT 
            
               IF @nErrNo <> 0
                  GOTO Quit

               SET @cOutField01 = @cReceiptKey
               SET @cOutField02 = @cLane
               SET @cOutField03 = ''
               SET @cOutField15 = ''
            
               SET @nAfterStep = 2
               SET @nAfterScn  = 5661
               GOTO Quit
            END
         END
      END
   END

   GOTO Quit

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1841ExtScn01 TO NSQL
GO


