
/****** Object:  StoredProcedure [RDT].[rdt_605ExtScn07]    Script Date: 10/30/2024 9:12:06 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_605ExtScn07                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose:       For SCHNEIDER ELECTRIC Belgium                        */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-02-26 1.0.0  Jackc    FCR-9673                                  */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_605ExtScn07] (
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

   DECLARE @cOption        NVARCHAR(1),
           @cUserName      NVARCHAR(18),
           @cUserDefine08  NVARCHAR(30),
           @cReceiptKey    NVARCHAR(10),
           @cSKU           NVARCHAR(20),
           @cID            NVARCHAR(18),
           @cToID          NVARCHAR(18),
           @cToLOC         NVARCHAR(10),
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


   DECLARE  @nMobScn    INT,
            @nMobStep   INT

   SELECT
      --@cLott10 = C_String1,
      --@cPalletTypeSave = C_String2,
      --@cSKUReceived = C_String3
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
      @cPUOM_Desc          = V_String2
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing 605ExtScn06', @nScn AS Scn, @nStep AS Step, @nMobScn AS MobScn, @nMobStep AS MobStep

   IF @nFunc = 605
   BEGIN
      IF @nMobStep = 2 AND @nStep = 3 AND @nScn = 4252 AND @nInputKey = 1 --From st2 to new st3
      BEGIN
         IF @nDebugFlag = 1
            SELECT '605ExtScn07, Enter from St2'

         SET @nAfterScn = 6842
         SET @nAfterStep = 99
         GOTO QUIT
      END -- from st2 to new t3

      IF @nStep = 99
      BEGIN
         IF @nScn = 6842
         /********************************************************************************
         Step 99. Screen = 6842. ID detail screen
            TO ID            (Field01)
            SKU              (Field02)
            SKU Desc1        (Field03)
            SKU Desc2        (Field04)
            DIV PUOM MUOM    (Field05)
            PQTY MQTY        (Field06, Field07)
            Dynamic lottable (Field08)
            Dynamic lottable (Field09)
            Dynamic lottable (Field10)
            Dynamic lottable (Field11)
            Dynamic lottable (Field12)
            Curr/Total line  (field13)
            OPTION           (Field14， Input)
         ********************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT '605ExtScn07, Esc from Scn6872'

               -- Prep next screen var
               SET @cOutField01 = @cReceiptKey
               SET @cOutField02 = @cRefNo
               SET @cOutField03 = '' -- ID

               -- Go to ID screen
               SET @nAfterScn = 4251
               SET @nAfterStep = 2

               GOTO Quit
            END -- ESC

            IF @nInputKey = 1 -- ENTER
            BEGIN
               -- Screen mapping
               SET @cOption = @cInField14

               -- Check option valid
               IF @cOption NOT IN ('1', '2', '3')
               BEGIN
                  SET @nErrNo = 259801
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                  GOTO Quit
               END

               -- Blank to get next line
               IF @cOption = '2'
               BEGIN
                  -- Get next line
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
                  BEGIN
                     -- No more record
                     IF @nErrNo = -1
                     BEGIN
                        SET @nErrNo = 259802
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more record
                     END
                     GOTO Quit
                  END

                  SET @nCurrentLine = @nCurrentLine + 1

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

                  -- Prepare next screen var
                  SET @cOutField01 = @cID
                  SET @cOutField02 = @cSKU
                  SET @cOutField03 = SUBSTRING( @cDescr, 1, 20)
                  SET @cOutField04 = SUBSTRING( @cDescr, 21, 20)
                  SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END +  -- 12345678901234567890
                                    rdt.rdtRightAlign( @cPUOM_Desc, 5) + SPACE( 3) +                                        -- 1:99999XXXXX   XXXXX
                                    rdt.rdtRightAlign( @cMUOM_Desc, 5)                     -- QTY: 9999999 9999999
                  SET @cOutField06 = rdt.rdtRightAlign( CAST( @nPQTY AS NCHAR( 7)), 7) -- PQTY
                  SET @cOutField07 = rdt.rdtRightAlign( CAST( @nMQTY AS NCHAR( 7)), 7) -- MQTY
                  -- SET @cOutField08 = dynamic lottable
                  -- SET @cOutField09 = dynamic lottable
                  -- SET @cOutField10 = dynamic lottable
                  -- SET @cOutField11 = dynamic lottable
                  -- SET @cOutField12 = dynamic lottable
                  SET @cOutField13 = CAST( @nCurrentLine AS NVARCHAR( 2)) + '/' + CAST( @nTotalLine AS NVARCHAR( 2))
                  SET @cOutField14 = @cOption

                  GOTO Quit
               END

               -- Handling transaction
               DECLARE @nTranCount INT
               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN  -- Begin our own transaction
               SAVE TRAN rdt_605ExtScn07_6842 -- For rollback or commit only our own transaction

               -- Receive
               EXEC rdt.rdt_PalletReceive_Confirm @nFunc, @nMobile, @cLangCode, @cStorerKey, @cFacility,
                  @cActReceiptKey,
                  @cID,
                  @cToLOC,
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT
               IF @nErrNo <> 0
               BEGIN
                  ROLLBACK TRAN rdt_605ExtScn07_6842
                  WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                     COMMIT TRAN
                  GOTO Quit
               END

               -- Extended update
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cRefNo, @cID, ' +
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile      INT,           ' +
                        '@nFunc        INT,           ' +
                        '@cLangCode    NVARCHAR( 3),  ' +
                        '@nStep        INT,           ' +
                        '@nInputKey    INT,           ' +
                        '@cFacility    NVARCHAR( 5),  ' +
                        '@cStorerKey   NVARCHAR( 15), ' +
                        '@cReceiptKey  NVARCHAR( 10), ' +
                        '@cRefNo       NVARCHAR( 20), ' +
                        '@cID          NVARCHAR( 18), ' +
                        '@nErrNo       INT            OUTPUT, ' +
                        '@cErrMsg      NVARCHAR( 1024)  OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cRefNo, @cID,
                        @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                     BEGIN
                        ROLLBACK TRAN rdt_605ExtScn07_6842
                        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                           COMMIT TRAN
                        GOTO Quit
                     END
                  END
               END

               COMMIT TRAN rdt_605ExtScn07_6842
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                  COMMIT TRAN

               SET @nCurrentScanned=@nCurrentScanned+1

               -- Extended validate
               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cRefNo, @cID,@nCurrentScanned, ' +
                        '@cExtendedInfo OUTPUT'
                     SET @cSQLParam =
                        '@nMobile      INT,           ' +
                        '@nFunc       INT,           ' +
                        '@cLangCode    NVARCHAR( 3),  ' +
                        '@nStep        INT,           ' +
                        '@nInputKey    INT,           ' +
                        '@cFacility    NVARCHAR( 5),  ' +
                        '@cStorerKey   NVARCHAR( 15), ' +
                        '@cReceiptKey  NVARCHAR( 10), ' +
                        '@cRefNo       NVARCHAR( 20), ' +
                        '@cID          NVARCHAR( 18), ' +
                        '@nCurrentScanned INT,           ' +
                        '@cExtendedInfo NVARCHAR(20) OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cRefNo, @cID,@nCurrentScanned,
                        @cExtendedInfo OUTPUT
                  END
               END

               -- EventLog
               EXEC RDT.rdt_STD_EventLog
                  @cActionType   = '2', -- Receiving
                  @cUserID       = @cUserName,
                  @nMobileNo     = @nMobile,
                  @nFunctionID   = @nFunc,
                  @cFacility     = @cFacility,
                  @cStorerKey    = @cStorerKey,
                  @cReceiptKey   = @cReceiptKey,
                  @cID           = @cID,
                  @cRefNo1       = @cRefNo,
                  @nStep         = @nStep

               -- Prep next screen var
               SET @cOutField01 = @cReceiptKey
               SET @cOutField02 = @cRefNo
               SET @cOutField03 = '' -- ID
               SET @cOutField04 = @cExtendedInfo

               -- Go to ID screen
               SET @nAfterScn = 4251
               SET @nAfterStep = 2
            END
         END --Scn 6872
         GOTO Quit
      END --st99
   END


Quit:
   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


GRANT EXECUTE ON rdt.rdt_605ExtScn07 TO NSQL
GO
