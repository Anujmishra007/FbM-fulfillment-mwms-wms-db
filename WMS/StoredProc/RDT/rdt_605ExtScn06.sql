
/****** Object:  StoredProcedure [RDT].[rdt_605ExtScn06]    Script Date: 10/30/2024 9:12:06 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_605ExtScn06                                        */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Purpose:       For MICHELIN                                             */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2025-12-31 1.0  Jackc   FCR-9251 Copy from rdt_605ExtScn03              */
/* 2026-08-17 1.2  Jackc   FCR-14878 Add toID validation and lottable scn  */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_605ExtScn06] (
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
   @nAction          INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
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

   DECLARE @nDebugFlag  INT = 0

   DECLARE @nShelfLife FLOAT
   DECLARE @cResultCode NVARCHAR( 60)
   DECLARE
   @nRowCount            INT,
   @cexternReceiptKey    NVARCHAR( 30),
   @cexternLineNo        NVARCHAR( 30),
   @nLotNum              INT,
   @cListName            NVARCHAR( 30),
   @cLotValue            NVARCHAR( 30),
   @cStorerConfig        NVARCHAR( 50),
   @SQL                  NVARCHAR( MAX),
   @nSQLResult           INT,
   @nCheckDigit          INT,
   @cActLoc              NVARCHAR( 20),
   @cPalletTypeInUse     NVARCHAR( 5),
   @cPalletTypeSave      NVARCHAR( 10),
   @cLott10              NVARCHAR( 30),
   @cSKUReceived         NVARCHAR( 20),
   @cDamagedCode         NVARCHAR(30),
   @cExpiredCode         NVARCHAR(30)

   DECLARE 
      @cOption        NVARCHAR(1),
      @cUserName      NVARCHAR(18),
      @cUserDefine08  NVARCHAR(30),
      @cReceiptKey    NVARCHAR(10),
      @cSKU           NVARCHAR(20),
      @cID            NVARCHAR(18),
      @cToID          NVARCHAR(18),
      @cActReceiptKey NVARCHAR(10),
      @cDescr         NVARCHAR(60),
      @cRefNo         NVARCHAR(20),
      @cExtendedInfo  NVARCHAR(20),
      @cExtendedUpdateSP   NVARCHAR(20),
      @cExtendedInfoSP     NVARCHAR(20),
      @cPUOM_Desc     NCHAR(5),
      @cMUOM_Desc     NCHAR(5),
      @cPUOM          NVARCHAR(1),
      @cRDLineNo      NVARCHAR(5),
      @cSQL           NVARCHAR( MAX),
      @cSQLParam      NVARCHAR( MAX),
      @cDefaultOption NVARCHAR(1),
      @nCurrentScanned INT,
      @nCurrentLine   INT,
      @nTotalLine     INT,
      @nPUOM_Div      INT,
      @nQTY           INT,
      @nPQTY          INT,
      @nMQTY          INT

   --V1.2
   DECLARE
      @cLottableCode NVARCHAR( 30),
      @nMorePage     INT


   DECLARE  @nMobScn    INT,
            @nMobStep   INT

   SELECT
      @nMobScn             = Scn,
      @nMobStep            = Step,
      @nPQTY               = V_PQTY,
      @nMQTY               = V_MQTY,
      @nQTY                = V_Integer1,
      @cUserName           = UserName,
      @nCurrentLine        = V_Integer2,
      @nTotalLine          = V_Integer3,
      @nCurrentScanned     = V_Integer4,
      @cRDLineNo           = V_String9,
      @cReceiptKey         = V_ReceiptKey,
      @cActReceiptKey      = V_String22,
      @cRefNo              = V_String21,
      @cExtendedInfo       = V_String14,
      @cExtendedUpdateSP   = V_String12,
      @cExtendedInfoSP     = V_String13,
      @cID                 = V_ID,
      @cSKU                = V_SKU,
      @cDescr              = V_SKUDescr,
      @nPUOM_Div           = V_PUOM_Div,
      @cPUOM               = V_UOM,
      @cMUOM_Desc          = V_String1,
      @cPUOM_Desc          = V_String2,
      --V1.2 start
      @cLottable01   = V_Lottable01,
      @cLottable02   = V_Lottable02,
      @cLottable03   = V_Lottable03,
      @dLottable04   = V_Lottable04,
      @dLottable05   = V_Lottable05,
      @cLottable06   = V_Lottable06,
      @cLottable07   = V_Lottable07,
      @cLottable08   = V_Lottable08,
      @cLottable09   = V_Lottable09,
      @cLottable10   = V_Lottable10,
      @cLottable11   = V_Lottable11,
      @cLottable12   = V_Lottable12,
      @dLottable13   = V_Lottable13,
      @dLottable14   = V_Lottable14,
      @dLottable15   = V_Lottable15,
      @cToID         = C_String1,
      @cLottableCode = C_String2
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing 605ExtScn06', @nScn AS Scn, @nStep AS Step, @nMobScn AS MobScn, @nMobStep AS MobStep

   IF @nFunc = 605
   BEGIN
      IF @nMobStep = 2 AND @nStep = 3 AND @nScn = 4252 AND @nInputKey = 1 --From st2 to toID screen
      BEGIN
         IF @nDebugFlag = 1
            SELECT '605ExtScn06, Enter from St2'
         SET @cOutField01 = ''
         SET @cToID = ''
         SET @nAfterScn = 6772
         SET @nAfterStep = 99
         GOTO QUIT
      END -- from st2 to st3

      IF @nMobStep = 3 AND @nStep = 2 AND @nScn = 4251 AND @nInputKey = 0 --esc from st3 to toID
      BEGIN
         IF @nDebugFlag = 1
            SELECT '605ExtScn06, Esc from St3'
         
         SET @cUDF01 = 'NO UPD RDTMOBREC'
         --clear new toID and lottable value from mobrec
         SET @cToID = ''
         
         SELECT 
            @cLottable01 = '', @cLottable02 = '', @cLottable03 = '', @dLottable04 = NULL, @dLottable05 = NULL,
            @cLottable06 = '', @cLottable07 = '', @cLottable08 = '', @cLottable09 = '',   @cLottable10 = '',
            @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL, @dLottable14 = NULL, @dLottable15 = NULL

         SET @cOutField01 = ''
         SET @cToID = ''
         SET @nAfterScn = 6772
         SET @nAfterStep = 99

         GOTO Quit
      END

      IF @nStep = 99
      BEGIN
         IF @nScn = 6772
         /********************************************************************************
         Step 99. Screen = 6772. To ID screen
            TO ID            (Field01)
         ********************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT '605ExtScn06, Esc from Scn6772'

               -- Prep next screen var
               SET @cOutField01 = @cReceiptKey
               SET @cOutField02 = @cRefNo
               SET @cOutField03 = '' -- ID

               -- Go to ID screen
               SET @nAfterScn = 4251
               SET @nAfterStep = 2

               GOTO Quit
            END -- ESC

            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT '605ExtScn06, Enter from Scn6772'

               SET @cToID = LEFT(@cInField01, 18) --To ID

               IF @cToID = ''
               BEGIN
                  SET @nErrNo = 255151
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToID required
                  GOTO Scn_6772_Fail
               END

               --V1.2
               IF LEFT(@cToID, 1) NOT IN ('A', 'B', 'C', 'M', 'D')
               BEGIN
                  SET @nErrNo = 255155
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToID must start with A,B,C,M or D
                  GOTO Scn_6772_Fail
               END

               -- Validate pallet id received. If config turn on then not allow reuse
               IF EXISTS( SELECT [ID]
                  FROM dbo.LOTxLOCxID LOTxLOCxID WITH (NOLOCK)
                  INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC)
                  WHERE [ID] = RTRIM(@cToID)
                  AND   QTY > 0
                  AND   StorerKey = @cStorerKey
                  AND   LOC.Facility = @cFacility)
               BEGIN
                  SET @nErrNo = 255152
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Duplicate ID
                  GOTO Scn_6772_Fail
               END

               -- Check pallet received
               IF EXISTS (SELECT 1 FROM  dbo.ReceiptDetail RD WITH (NOLOCK)
                           WHERE RD.ReceiptKey = @cActReceiptKey
                           AND RD.StorerKey = @cStorerKey
                           AND RD.ToID = RTRIM(@cToID)
                           AND RD.BeforeReceivedQty > 0)
               BEGIN
                  SET @nErrNo = 255153
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID received
                  GOTO Scn_6772_Fail
               END

               --V1.2
               SELECT TOP 1 @cLottableCode = LottableCode
               FROM dbo.ReceiptDetail RD WITH (NOLOCK)
               JOIN dbo.SKU WITH (NOLOCK) ON RD.SKU = SKU.SKU AND RD.StorerKey = SKU.StorerKey
               WHERE RD.ReceiptKey = @cActReceiptKey
                  AND ToID = @cID -- original toID
               ORDER BY RD.ReceiptLineNumber

               SELECT 
                  @cLottable01 = '', @cLottable02 = '', @cLottable03 = '', @dLottable04 = NULL, @dLottable05 = NULL,
                  @cLottable06 = '', @cLottable07 = '', @cLottable08 = '', @cLottable09 = '',   @cLottable10 = '',
                  @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL, @dLottable14 = NULL, @dLottable15 = NULL


               --V1.2 start
               -- Dynamic lottable
               EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,
                  @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,
                  @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,
                  @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,
                  @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,
                  @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,
                  @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,
                  @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,
                  @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,
                  @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,
                  @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,
                  @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,
                  @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,
                  @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,
                  @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,
                  @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,
                  @nMorePage   OUTPUT,
                  @nErrNo      OUTPUT,
                  @cErrMsg     OUTPUT,
                  @cReceiptKey,
                  @nFunc

               IF @nErrNo <> 0
                  GOTO Quit

               IF @nMorePage = 1 -- Yes
               BEGIN
                  -- Go to dynamic lottable screen
                  SET @nAfterScn = 3990
                  SET @nAfterStep = 99
               END --V1.2 end
               ELSE
               BEGIN
                  -- Prepare next screen var
                  -- Convert to prefer UOM QTY
                  IF @cPUOM = '6' OR -- When preferred UOM = master unit
                     @nPUOM_Div = 0  -- UOM not setup
                  BEGIN
                     SET @cPUOM_Desc = ''
                     SET @nPQTY = 0
                     SET @nMQTY = @nQTY
                  END
                  ELSE
                  BEGIN
                     SET @nPQTY = @nQTY / @nPUOM_Div  -- Calc QTY in preferred UOM
                     SET @nMQTY = @nQTY % @nPUOM_Div  -- Calc the remaining in master unit
                  END

                  SET @cOutField01 = @cToID
                  SET @cOutField02 = @cSKU
                  SET @cOutField03 = SUBSTRING( @cDescr, 1, 20)
                  SET @cOutField04 = SUBSTRING( @cDescr, 21, 20)
                  SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END +  -- 12345678901234567890
                                    rdt.rdtRightAlign( @cPUOM_Desc, 5) + SPACE( 3) +                                        -- 1:99999XXXXX   XXXXX
                                    rdt.rdtRightAlign( @cMUOM_Desc, 5)                                                      -- QTY: 9999999 9999999
                  SET @cOutField06 = rdt.rdtRightAlign( CAST( @nPQTY AS NCHAR( 7)), 7) -- PQTY
                  SET @cOutField07 = rdt.rdtRightAlign( CAST( @nMQTY AS NCHAR( 7)), 7) -- MQTY
                  SET @cOutField13 = CAST( @nCurrentLine AS NVARCHAR( 2)) + '/' + CAST( @nTotalLine AS NVARCHAR( 2))
                  SET @cOutField14 = @cDefaultOption

                  -- Go to SKU QTY screen
                  SET @nAfterScn = 4252
                  SET @nAfterStep = 3
               END -- No lottable page

               GOTO Quit

               Scn_6772_Fail:
                  SET @cOutField01 = ''
                  SET @cToID = ''

               GOTO Quit
            END --enter
         END --Scn 6772

         IF @nScn = 3990
         /********************************************************************************
         Step 99. Screen = 3990. Dynamic lottable screen
         ********************************************************************************/
         BEGIN
            SET @cUDF01 = 'NO UPD RDTMOBREC'
            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT '605ExtScn06, Enter from lottable screen'

               -- Dynamic lottable
               EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'CHECK', 5, 1,
                  @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,
                  @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,
                  @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,
                  @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,
                  @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,
                  @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,
                  @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,
                  @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,
                  @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,
                  @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,
                  @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,
                  @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,
                  @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,
                  @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,
                  @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,
                  @nMorePage   OUTPUT,
                  @nErrNo      OUTPUT,
                  @cErrMsg     OUTPUT,
                  @cReceiptKey,
                  @nFunc

               IF @nErrNo <> 0
                  GOTO SCN_3990_Quit

               IF @nMorePage = 1 -- Yes
                  GOTO SCN_3990_Quit

               -- Enable field
               SET @cFieldAttr02 = '' -- Dynamic lottable 1..5
               SET @cFieldAttr04 = ''
               SET @cFieldAttr06 = ''
               SET @cFieldAttr08 = ''
               SET @cFieldAttr10 = ''

               -- Get first line
               SET @cSKU = ''
               SET @nQTY = 0
               SET @cRDLineNo = ''
               EXEC rdt.rdt_PalletReceive_GetDetail @nFunc, @nMobile, @cLangCode, @nScn, @nInputKey, @cFacility, @cStorerKey,
                  @cActReceiptKey,
                  @cID,
                  @cSKU        OUTPUT,
                  @nQTY        OUTPUT,
                  @cRDLineNo   OUTPUT,
                  @cOutField01 OUTPUT,
                  @cOutField02 OUTPUT,
                  @cOutField03 OUTPUT,
                  @cOutField04 OUTPUT,
                  @cOutField05 OUTPUT,
                  @cOutField06 OUTPUT,
                  @cOutField07 OUTPUT,
                  @cOutField08 OUTPUT,
                  @cOutField09 OUTPUT,
                  @cOutField10 OUTPUT,
                  @cOutField11 OUTPUT,
                  @cOutField12 OUTPUT,
                  @cOutField13 OUTPUT,
                  @cOutField14 OUTPUT,
                  @cOutField15 OUTPUT,
                  @nErrNo      OUTPUT,
                  @cErrMsg     OUTPUT
               IF @nErrNo <> 0
                  GOTO Quit

               SET @nCurrentLine = 1

               -- Get Pack info
               SELECT
                  @cDescr = SKU.Descr,
                  @cMUOM_Desc = Pack.PackUOM3,
                  @cPUOM_Desc =
                     CASE @cPUOM
                        WHEN '2' THEN Pack.PackUOM1 -- Case
                        WHEN '3' THEN Pack.PackUOM2 -- Inner pack
                        WHEN '6' THEN Pack.PackUOM3 -- Master unit
                        WHEN '1' THEN Pack.PackUOM4 -- Pallet
                        WHEN '4' THEN Pack.PackUOM8 -- Other unit 1
                        WHEN '5' THEN Pack.PackUOM9 -- Other unit 2
                     END,
                  @nPUOM_Div = CAST( IsNULL(
                     CASE @cPUOM
                        WHEN '2' THEN Pack.CaseCNT
                        WHEN '3' THEN Pack.InnerPack
                        WHEN '6' THEN Pack.QTY
                        WHEN '1' THEN Pack.Pallet
                        WHEN '4' THEN Pack.OtherUnit1
                        WHEN '5' THEN Pack.OtherUnit2
                     END, 1) AS INT)
               FROM dbo.SKU SKU WITH (NOLOCK)
                  INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
               WHERE SKU.StorerKey = @cStorerKey
                  AND SKU.SKU = @cSKU

               -- Prepare next screen var
               -- Convert to prefer UOM QTY
               IF @cPUOM = '6' OR -- When preferred UOM = master unit
                  @nPUOM_Div = 0  -- UOM not setup
               BEGIN
                  SET @cPUOM_Desc = ''
                  SET @nPQTY = 0
                  SET @nMQTY = @nQTY
               END
               ELSE
               BEGIN
                  SET @nPQTY = @nQTY / @nPUOM_Div  -- Calc QTY in preferred UOM
                  SET @nMQTY = @nQTY % @nPUOM_Div  -- Calc the remaining in master unit
               END

               SET @cOutField01 = @cToID
               SET @cOutField02 = @cSKU
               SET @cOutField03 = SUBSTRING( @cDescr, 1, 20)
               SET @cOutField04 = SUBSTRING( @cDescr, 21, 20)
               SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END +  -- 12345678901234567890
                                 rdt.rdtRightAlign( @cPUOM_Desc, 5) + SPACE( 3) +                                        -- 1:99999XXXXX   XXXXX
                                 rdt.rdtRightAlign( @cMUOM_Desc, 5)                                                      -- QTY: 9999999 9999999
               SET @cOutField06 = rdt.rdtRightAlign( CAST( @nPQTY AS NCHAR( 7)), 7) -- PQTY
               SET @cOutField07 = rdt.rdtRightAlign( CAST( @nMQTY AS NCHAR( 7)), 7) -- MQTY
               -- SET @cOutField08 = dynamic lottable
               -- SET @cOutField09 = dynamic lottable
               -- SET @cOutField10 = dynamic lottable
               -- SET @cOutField11 = dynamic lottable
               -- SET @cOutField12 = dynamic lottable
               SET @cOutField13 = CAST( @nCurrentLine AS NVARCHAR( 2)) + '/' + CAST( @nTotalLine AS NVARCHAR( 2))
               SET @cOutField14 = @cDefaultOption

               -- Go to SKU QTY screen
               SET @nAfterScn = 4252
               SET @nAfterStep = 3
            END -- Enter

            IF @nInputkey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT '605ExtScn06, Esc from lottable scn'

               -- Dynamic lottable
               EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,
                  @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,
                  @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,
                  @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,
                  @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,
                  @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,
                  @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,
                  @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,
                  @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,
                  @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,
                  @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,
                  @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,
                  @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,
                  @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,
                  @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,
                  @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,
                  @nMorePage   OUTPUT,
                  @nErrNo      OUTPUT,
                  @cErrMsg     OUTPUT,
                  @cReceiptKey,
                  @nFunc

               IF @nMorePage = 1 -- Yes
                  GOTO SCN_3990_Quit

               SET @cOutField01 = ''
               SET @cToID = ''
               SET @nAfterScn = 6772
               SET @nAfterStep = 99 
            END --ESC

            SCN_3990_Quit:
               GOTO Quit
         END --3990

         GOTO Quit
      END --st99
   END


Quit:
   BEGIN TRY
      UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
      SET 
         C_String1 = @cToID,
         C_String2 = @cLottableCode
      WHERE Mobile = @nMobile
   END TRY
   BEGIN CATCH
      SET @nErrNo = 255154
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd MOBREC fail
   END CATCH

   IF @cUDF01 = 'NO UPD RDTMOBREC'
   BEGIN
      BEGIN TRY
         UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
         SET 
            EditDate     = GETDATE(),
            ErrMsg       = @cErrMsg,
            Func         = @nFunc,
            Step         = @nAfterStep,
            Scn          = @nAfterScn,

            V_Lottable01 = @cLottable01,
            V_Lottable02 = @cLottable02,
            V_Lottable03 = @cLottable03,
            V_Lottable04 = @dLottable04,
            V_Lottable05 = @dLottable05,
            V_Lottable06 = @cLottable06,
            V_Lottable07 = @cLottable07,
            V_Lottable08 = @cLottable08,
            V_Lottable09 = @cLottable09,
            V_Lottable10 = @cLottable10,
            V_Lottable11 = @cLottable11,
            V_Lottable12 = @cLottable12,
            V_Lottable13 = @dLottable13,
            V_Lottable14 = @dLottable14,
            V_Lottable15 = @dLottable15,

            I_Field01 = @cInField01,  O_Field01 = @cOutField01,
            I_Field02 = @cInField02,  O_Field02 = @cOutField02,
            I_Field03 = @cInField03,  O_Field03 = @cOutField03,
            I_Field04 = @cInField04,  O_Field04 = @cOutField04,
            I_Field05 = @cInField05,  O_Field05 = @cOutField05,
            I_Field06 = @cInField06,  O_Field06 = @cOutField06,
            I_Field07 = @cInField07,  O_Field07 = @cOutField07,
            I_Field08 = @cInField08,  O_Field08 = @cOutField08,
            I_Field09 = @cInField09,  O_Field09 = @cOutField09,
            I_Field10 = @cInField10,  O_Field10 = @cOutField10,
            I_Field11 = @cInField11,  O_Field11 = @cOutField11,
            I_Field12 = @cInField12,  O_Field12 = @cOutField12,
            I_Field13 = @cInField13,  O_Field13 = @cOutField13,
            I_Field14 = @cInField14,  O_Field14 = @cOutField14,
            I_Field15 = @cInField15,  O_Field15 = @cOutField15,

            FieldAttr01  = @cFieldAttr01,   FieldAttr02  = @cFieldAttr02,
            FieldAttr03  = @cFieldAttr03,   FieldAttr04  = @cFieldAttr04,
            FieldAttr05  = @cFieldAttr05,   FieldAttr06  = @cFieldAttr06,
            FieldAttr07  = @cFieldAttr07,   FieldAttr08  = @cFieldAttr08,
            FieldAttr09  = @cFieldAttr09,   FieldAttr10  = @cFieldAttr10,
            FieldAttr11  = @cFieldAttr11,   FieldAttr12  = @cFieldAttr12,
            FieldAttr13  = @cFieldAttr13,   FieldAttr14  = @cFieldAttr14,
            FieldAttr15  = @cFieldAttr15
         WHERE Mobile = @nMobile
      END TRY
      BEGIN CATCH
         SET @nErrNo = 255156
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd MOBREC fail
      END CATCH
   END

   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @nAfterScn AS AfterScn, @nAfterStep AS AfterStep
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


GRANT EXECUTE ON rdt.rdt_605ExtScn06 TO NSQL
GO
