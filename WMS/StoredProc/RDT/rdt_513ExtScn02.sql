SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_513ExtScn02                                        */
/* Copyright      : Maersk                                                 */
/* Customer       : NLTR2                                                  */
/*                                                                         */
/*                                                                         */
/* Date        Rev    Author     Purposes                                  */
/* 2026-06-02  1.0.0  Jackc      FCR-12576 Pallet Type screen              */
/***************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_513ExtScn02] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nScn         INT,
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
   @nAction      INT,
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

   DECLARE @nDebugFlag  INT = 0

   DECLARE
      @nMobRecScn    INT,
      @nMobRecStep   INT,
      @cUserName     NVARCHAR( 18)

   DECLARE
      @cCapturePalletType  NVARCHAR(1),
      @cDropListSP         NVARCHAR(20),
      @cPalletType         NVARCHAR(10),
      @cTempToID           NVARCHAR(18),

      -- Variables from rdtMobRec
      @cFromLOC            NVARCHAR(10),
      @cFromID             NVARCHAR(18),
      @cSKU                NVARCHAR(30),
      @cPUOM_Desc          NVARCHAR(5),
      @cMUOM_Desc          NVARCHAR(5),
      @cPrePackIndicator   NVARCHAR(30),
      @cSKUDescr           NVARCHAR(60),
      @cSuggestLocSP       NVARCHAR(20),

      -- Qty variables
      @nQTY                INT,
      @nQTY_Avail          INT,
      @nPQTY_Avail         INT,
      @nMQTY_Avail         INT,
      @nPQTY               INT,
      @nMQTY               INT,
      @nPUOM_Div           INT,
      @nPackQtyIndicator   INT,
      @nPABookingKey       INT,

      -- To location variables
      @cToID               NVARCHAR(18),
      @cToLOC              NVARCHAR(10),

      -- Misc variables
      @cSQL                NVARCHAR(MAX),
      @cSQLParam           NVARCHAR(MAX)

   SELECT
      @nFunc            = Func,
      @nInputKey        = InputKey,
      @nMobRecScn       = Scn,
      @nMobRecStep      = Step,
      @cLangCode        = Lang_code,
      @cFacility        = Facility,
      @cStorerKey       = StorerKey,
      @cUserName        = UserName,

      @cFromLOC         = V_String1,
      @cFromID          = V_String2,
      @cSKU             = V_String3,
      @cPUOM_Desc       = V_String4,  -- Pref UOM desc
      @cMUOM_Desc       = V_String5,  -- Master UOM desc
      @cSuggestLocSP    = V_String18,
      @cPrePackIndicator   = V_String41,

      @cSKUDescr        = V_SKUDescr,
      @nPUOM_Div        = V_PUOM_Div,
      @nPQTY            = V_PQTY,
      @cToLOC           = V_String13,
      @cToID            = V_String14,
      @nMQTY            = V_MQTY,

      @nQTY_Avail          = V_Integer1,
      @nPQTY_Avail         = V_Integer2,
      @nMQTY_Avail         = V_Integer3,
      @nQTY                = V_Integer4,
      @nPABookingKey       = V_Integer6,
      @nPackQtyIndicator   = V_Integer7
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 513
   BEGIN
      IF @nMobRecScn = 1034 AND @nMobRecStep = 5 AND @nScn = 1035 AND @nStep = 6 -- ToID to toLoc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ST99, ToID Scn to ToLoc Scn'

            SET @cCapturePalletType = rdt.RDTGetConfig( @nFunc, 'CapturePalletType', @cStorerKey)
            SET @cDropListSP = rdt.RDTGetConfig( @nFunc, 'DropListSP', @cStorerKey)
            IF @cDropListSP = '0'
               SET @cDropListSP = ''

            SELECT @cTempToID = Value FROM @tExtScnData WHERE Variable = '@cToID'

            IF @cCapturePalletType = '1' AND ISNULL(@cTempToID, '') <> ''
            BEGIN
               SET @cPalletType = '' --clear historical pallet type value
               BEGIN TRY
                  UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
                     SET C_String1 = @cPalletType
                  WHERE Mobile = @nMobile
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 268654
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Mobile Failed
                  GOTO Scn_6895_Fail
               END CATCH

               SET @cOutField01 = @cDropListSP

               SET @nAfterStep = 99
               SET @nAfterScn = 6895
            END
         END

         GOTO Quit
      END

      IF @nMobRecStep = 99
      BEGIN
         IF @nMobRecScn = 6895 -- Pallet Type
         /************************************************************************************
         Scn = 6895. Pallet Type
            Enter/Scan Pallet Type 
            (field01, input, dropdown list)
         ************************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn6895, ESC'

               -- Unlock suggest loc
               IF @cSuggestLocSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSuggestLocSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cSuggestLocSP) +
                        ' @nMobile, @nFunc, @cLangCode, @cStorerKey, @cFacility, @cFromLOC, @cFromID, @cSKU, @nQTY, @cToID, @cToLOC, @cType, @nPABookingKey OUTPUT, ' +
                        ' @cOutField01 OUTPUT, @cOutField02 OUTPUT, @cOutField03 OUTPUT, @cOutField04 OUTPUT, @cOutField05 OUTPUT, ' +
                        ' @cOutField06 OUTPUT, @cOutField07 OUTPUT, @cOutField08 OUTPUT, @cOutField09 OUTPUT, @cOutField10 OUTPUT, ' +
                        ' @cOutField11 OUTPUT, @cOutField12 OUTPUT, @cOutField13 OUTPUT, @cOutField14 OUTPUT, @cOutField15 OUTPUT, ' +
                        ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'
                     SET @cSQLParam =
                        ' @nMobile         INT,                  ' +
                        ' @nFunc           INT,                  ' +
                        ' @cLangCode       NVARCHAR( 3),         ' +
                        ' @cStorerKey      NVARCHAR( 15),        ' +
                        ' @cFacility       NVARCHAR(  5),        ' +
                        ' @cFromLOC        NVARCHAR( 10),        ' +
                        ' @cFromID         NVARCHAR( 18),        ' +
                        ' @cSKU            NVARCHAR( 20),        ' +
                        ' @nQTY            INT,                  ' +
                        ' @cToID           NVARCHAR( 18),        ' +
                        ' @cToLOC          NVARCHAR( 10),        ' +
                        ' @cType           NVARCHAR( 10),        ' +
                        ' @nPABookingKey   INT           OUTPUT, ' +
                        ' @cOutField01     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField02     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField03     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField04     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField05     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField06     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField07     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField08     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField09     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField10     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField11     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField12     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField13     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField14     NVARCHAR( 20) OUTPUT, ' +
                        ' @cOutField15     NVARCHAR( 20) OUTPUT, ' +
                        ' @nErrNo          INT           OUTPUT, ' +
                        ' @cErrMsg         NVARCHAR( 20) OUTPUT  '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @cStorerKey, @cFacility, @cFromLOC, @cFromID, @cSKU, @nQTY, @cToID, @cToLOC, 'UNLOCK', @nPABookingKey OUTPUT,
                        @cOutField01 OUTPUT, @cOutField02 OUTPUT, @cOutField03 OUTPUT, @cOutField04 OUTPUT, @cOutField05 OUTPUT,
                        @cOutField06 OUTPUT, @cOutField07 OUTPUT, @cOutField08 OUTPUT, @cOutField09 OUTPUT, @cOutField10 OUTPUT,
                        @cOutField11 OUTPUT, @cOutField12 OUTPUT, @cOutField13 OUTPUT, @cOutField14 OUTPUT, @cOutField15 OUTPUT,
                        @nErrNo      OUTPUT, @cErrMsg     OUTPUT

                     IF @nErrNo <> 0
                        GOTO QUIT
                  END
               END

               -- Prepare ToID screen var
               SET @cToID = ''
               SET @cOutField01 = @cFromLOC
               SET @cOutField02 = @cFromID
               SET @cOutField03 = @cSKU
               SET @cOutField04 = SUBSTRING( @cSKUDescr, 1, 20)   -- SKU desc 1
               SET @cOutField05 = SUBSTRING( @cSKUDescr, 21, 20)  -- SKU desc 2
               IF @cPUOM_Desc = ''
               BEGIN
                  SET @cOutField06 = '' -- @cPUOM_Desc
                  SET @cOutField07 = '' -- @nPQTY_Avail
                  SET @cOutField08 = '' -- @nPQTY
                  SET @nMQTY_Avail = @nQTY_Avail -- Bug fix by Vicky on 09-Aug-2007
               END
               ELSE
               BEGIN
                  SET @cOutField06 = @cPUOM_Desc
                  SET @cOutField07 = CAST( @nPQTY_Avail AS NVARCHAR( 7))
                  SET @cOutField08 = CAST( @nPQTY AS NVARCHAR( 7))
               END
               SET @cOutField09 = @cMUOM_Desc
               SET @cOutField11 = CAST( @nMQTY AS NVARCHAR( 7))
               SET @cOutField12 = '' -- @cToID
               SET @cOutField13 = CASE WHEN @cPrePackIndicator = '2' THEN CAST( @nPackQtyIndicator AS NVARCHAR( 3)) ELSE '' END

               -- Go to ToID screen
               SET @nAfterScn  = 1034
               SET @nAfterStep = 5
            END-- ESC

            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'St99, Scn6895, Enter'

               SET @cPalletType = LEFT(@cInField01, 10)

               IF ISNULL(@cPalletType, '') = ''
               BEGIN
                  SET @nErrNo = 268651
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet Type required
                  GOTO Scn_6895_Fail
               END

               IF NOT EXISTS (SELECT 1
                              FROM dbo.PalletTypeMaster WITH (NOLOCK)
                              WHERE Storerkey = @cStorerKey
                                 AND Facility = @cFacility
                                 AND PalletType = @cPalletType
                                 AND PalletTypeInUse = 'Y')
               BEGIN
                  SET @nErrNo = 268652
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Invalid pallet type
                  GOTO Scn_6895_Fail
               END

               BEGIN TRY
                  UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
                     SET C_String1 = @cPalletType
                  WHERE Mobile = @nMobile
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 268653
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Mobile Failed
                  GOTO Scn_6895_Fail
               END CATCH

               SET @cOutField01 = @cFromLOC
               --The other OutFields values inherit from step5, no need to change

               SET @nAfterScn = 1035
               SET @nAfterStep = 6
            END -- enter
            GOTO Quit

            Scn_6895_Fail:
               SET @cOutField01 = ''

            GOTO Quit
         END --6895
      END--Step99

   END --513

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_513ExtScn02] TO NSQL
GO