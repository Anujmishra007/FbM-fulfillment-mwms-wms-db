
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/  
/* Store procedure: rdt_523ExtScn01                                     */  
/*                                                                      */
/* Customer: DAIMLER TRUCK AG                                           */
/*                                                                      */
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2026-01-27 1.0  JACKC      FCR-9756. Created                         */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_523ExtScn01] (
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

   DECLARE @nDebugFlag       INT = 0

   DECLARE 
      --rdtmobrec
      @cUserName              NVARCHAR( 18),
      @nMenu                  INT,
      @nMOBRECStep            INT,
      @nMOBRECScn             INT,
      
      --config variable
      @nRowCount              INT,
      @cExtendedUpdateSP      NVARCHAR( 20),
      @cExtendedValidateSP    NVARCHAR( 20),
      @cExtendedInfoSP        NVARCHAR( 20),
      @cPABySKUAndLOT         NVARCHAR( 1),
      @cPASuggestSKU          NVARCHAR( 1)

   DECLARE -- business
      @cSKU                NVARCHAR( 20),
      @cSuggestSKU         NVARCHAR( 20),
      @cSKUDesc            NVARCHAR( 60),
      @cID                 NVARCHAR( 18),
      @cLot                NVARCHAR( 10),
      @cNextLOT            NVARCHAR( 10),
      @cLOC                NVARCHAR( 10),
      @cSuggestedLOC       NVARCHAR( 10),
      @cFinalLOC           NVARCHAR( 10),
      @cUCC                NVARCHAR( 20),
      @cToLOC              NVARCHAR( 18),
      @cToLocPAZone        NVARCHAR( 10),
      @cToID               NVARCHAR( 18),
      @cPQTY               NVARCHAR( 5),
      @cMQTY               NVARCHAR( 5),
      @cPUOM               NVARCHAR( 1),
      @cPUOM_Desc          NVARCHAR( 5),  -- Pref UOM 
      @cMUOM_Desc          NVARCHAR( 5),
      @cChkFacility        NVARCHAR( 5),
      @cChkToLoc           NVARCHAR( 18),
      @cOption             NVARCHAR( 1),
      @cQTY_Avail          NVARCHAR( 5),
      @cQTY_Alloc          NVARCHAR( 5),
      @cQTY_PMoveIn        NVARCHAR( 5),

      @cPAMatchSuggestLOC  NVARCHAR( 1),
      @cPAMatchQTY         NVARCHAR( 1),
      @cDefaultQTY         NVARCHAR( 1),
      @cDefaultSuggestSKU  NVARCHAR( 1),

      @nPUOM_Div           INT,
      @nPQTY_PWY           INT,
      @nMQTY_PWY           INT,
      @nQTY_PWY            INT,
      @nPQTY               INT,
      @nMQTY               INT,
      @nQTY                INT,
      @nTotalPreAlloQty    INT = 0,
      @nMovedQty           INT = 0,
      @nPreAlloQty         INT = 0,
      @nPABookingKey       INT,
      @nRec                INT,
      @nTotalRec           INT,
      @nTranCount          INT
   
   SET @nErrNo = 0
   SET @cErrMsg = ''


   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerkey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerkey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''
   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerkey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''
   

   SELECT 
      @nMOBRECStep         = Step,
      @nMOBRECScn          = Scn,
      @nMenu               = Menu,
      @cUserName           = UserName,

      @cID                 = V_ID,
      @cLOC                = V_LOC,
      @cSKU                = V_SKU,
      @cSKUDesc            = V_SKUDescr,
      @cPUOM               = V_UOM,
      @cLOT                = V_LOT,
      --@cLottable01         = V_Lottable01,
      --@cLottable02         = V_Lottable02,
      --@cLottable03         = V_Lottable03,
      --@dLottable04         = V_Lottable04,
      @cUCC                = V_UCC,
      @cSuggestSKU         = V_String1,
      @cSuggestedLOC       = V_String2,
      @cFinalLOC           = V_String3,
      @cMUOM_Desc          = V_String4,
      @cPUOM_Desc          = V_String5,
      @cQTY_Avail          = V_String7,
      @cQTY_Alloc          = V_String8,
      @cQTY_PMoveIn        = V_String9,
      @cPASuggestSKU       = V_String20,
      @cPABySKUAndLOT      = V_String21,
      @cPAMatchSuggestLOC  = V_String27,
      @cPAMatchQTY         = V_String28,
      @cDefaultQTY         = V_String29,
      @cDefaultSuggestSKU  = V_String30,
      @nPUOM_Div           = V_PUOM_Div,
      @nPQTY               = V_PQTY,
      @nMQTY               = V_MQTY,
      @nPQTY_PWY           = V_Integer1,
      @nMQTY_PWY           = V_Integer2,
      @nQTY_PWY            = V_Integer3,
      @nQTY                = V_Integer4,
      @nRec                = V_Integer5,
      @nTotalRec           = V_Integer6,
      @nPABookingKey       = V_Integer7,
      @nPreAlloQty         = C_Integer1
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_523ExtScn01'

   IF @nFunc = 523
   BEGIN
      IF @nStep = 3 AND @nScn = 2882 --redirect to New Qty screen
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'redirect to new Qty screen'

         IF @nMOBRECStep = 2 AND @nMOBRECScn = 2881 AND @nInputKey = 1 -- From St2
         BEGIN
            IF @cPABySKUAndLOT <> '1'
            BEGIN
               SET @nErrNo = 257201
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               
               -- Enable field
               SET @cFieldAttr13 = '' -- @nPQTY_PWY

               -- Prepare SKU screen variable
               SET @cSKU = ''
               IF @cPASuggestSKU <> '1' SET @cSKUDesc = ''

               SET @cOutField01 = @cID
               SET @cOutField02 = @cUCC
               SET @cOutField03 = @cLOC
               SET @cOutField04 = @cSuggestSKU
               SET @cOutField05 = '' -- SKU
               SET @cOutField06 = SUBSTRING( @cSKUDesc, 1, 20)
               SET @cOutField07 = SUBSTRING( @cSKUDesc, 21, 20)
               SET @cOutField08 = '' -- Piece scan QTY
               SET @cOutField15 = ''

               -- Go to SKU screen
               SET @nAfterScn = 2881
               SET @nAfterStep = 2
               GOTO Quit  
            END

            SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'
            SELECT @cLot = Value FROM @tExtScnData WHERE Variable = '@cLot'
         END

         IF ISNULL(@cLot, '') <> ''
         BEGIN
            SELECT 
               @nMovedQty = ISNULL(SUM(Qty+PendingMoveIn-(QtyAllocated + QtyPicked)), 0)
            FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) 
               ON LOC.LOC = LLI.LOC
            JOIN dbo.CodeLKUP CL WITH (NOLOCK)
               ON CL.code=LOC.PUTAWAYZONE 
               AND CL.code2=LOC.Facility
            WHERE LLI.StorerKey = @cStorerKey 
               AND LLI.LOT = @cLot
               AND LLI.SKU = @cSKU
               AND CL.LISTNAME ='523ZONE'

            SELECT 
               @nTotalPreAlloQty = ISNULL(QtyPreAllocated, 0) 
            FROM dbo.LOT WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Lot = @cLot
         END
         ELSE
         BEGIN
            SET @nTotalPreAlloQty = 0
            SET @nMovedQty = 0
         END

         IF @nDebugFlag = 1
            SELECT 'PreAlloQty Calucation', @nTotalPreAlloQty AS TatalPrAlloQty, @nMovedQty AS MovedQty, 
                     @cLOT AS LOt, @cSKU AS SKU

         IF @nTotalPreAlloQty - @nMovedQty > 0
         BEGIN
            SET @nPreAlloQty = @nTotalPreAlloQty - @nMovedQty
            SET @cOutField15 = 'PR QTY: ' + CAST(@nPreAlloQty AS NVARCHAR(6))
         END
         ELSE
         BEGIN
            SET @nPreAlloQty = 0
            SET @cOutField15 = ''
         END          

         SET @nAfterScn = 6820
         SET @nAfterStep = 99
         
         GOTO Quit
      END--Go to new QTY screen

      IF @nMOBRECStep = 99
      BEGIN
         IF @nMOBRECScn = 6820
         /********************************************************************************
         Scn = 6820  New Qty scn
            SKU        (field01)
            DESC1      (field02)
            DESC2      (field03)
            Rec/Total  (field09)
            Lottable01 (field04)
            Lottable02 (field05)
            Lottable03 (field06)
            Lottable04 (field07)
            QTY PREALLO(field15)
            UOM ratio  (field08)
            PUOM       (field09)
            MUOM       (field10)
            PQTY_PWY   (field11)
            MQTY_PWY   (field12)
            PQTY       (field13, input)
            MQTY       (field14, input)
            
         ********************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn 6820, ESC'

               -- Enable field
               SET @cFieldAttr13 = '' -- @nPQTY_PWY

               -- Prepare SKU screen variable
               SET @cSKU = ''
               IF @cPASuggestSKU <> '1' SET @cSKUDesc = ''

               SET @cOutField01 = @cID
               SET @cOutField02 = @cUCC
               SET @cOutField03 = @cLOC
               SET @cOutField04 = @cSuggestSKU
               SET @cOutField05 = '' -- SKU
               SET @cOutField06 = SUBSTRING( @cSKUDesc, 1, 20)
               SET @cOutField07 = SUBSTRING( @cSKUDesc, 21, 20)
               SET @cOutField08 = '' -- Piece scan QTY
               SET @cOutField15 = ''

               -- Go to SKU screen
               SET @nAfterScn = 2881
               SET @nAfterStep = 2
            END --ESC

            IF @nInputKey = 1 -- Yes or Send
            BEGIN
               -- screen mapping
               SET @cPQTY = CASE WHEN @cFieldAttr13 = 'O' THEN @cOutField13 ELSE @cInField13 END
               SET @cMQTY = @cInField14

               -- Loop lottable only (QTY no change)
               IF @cPQTY = '' AND @cMQTY = ''
               BEGIN
                  -- Check reach last rec
                  IF @nRec = @nTotalRec
                  BEGIN
                     SET @nErrNo = 257202
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No more rec
                     GOTO Scn_6820_Fail
                  END

                  -- Get next LOT
                  SET @cNextLOT = ''
                  SELECT TOP 1
                     @cNextLOT = LOT
                  FROM dbo.LOTxLOCxID WITH (NOLOCK)
                  WHERE ID = @cID
                     AND LOC = @cLOC
                     AND StorerKey = @cStorerKey
                     AND SKU = @cSKU
                     AND (QTY - QTYAllocated - QTYPicked - ABS( QTYReplen)) > 0
                     AND LOT > @cLOT
                  ORDER BY LOT

                  -- Recheck in case changed by other
                  IF @cNextLOT = ''
                  BEGIN
                     SET @nErrNo = 257203
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No more rec
                     GOTO Scn_6820_Fail
                  END
                  ELSE
                     SET @cLOT = @cNextLOT

                  -- Get lottable
                  SELECT
                     @cLottable01 = LA.Lottable01,
                     @cLottable02 = LA.Lottable02,
                     @cLottable03 = LA.Lottable03,
                     @dLottable04 = LA.Lottable04
                  FROM dbo.LOTAttribute LA WITH (NOLOCK)
                  WHERE LOT = @cLOT

                  -- Prepare current screen var
                  SET @nRec = @nRec + 1
                  SET @cOutField04 = @cLottable01
                  SET @cOutField05 = @cLottable02
                  SET @cOutField06 = @cLottable03
                  SET @cOutField07 = rdt.rdtFormatDate( @dLottable04)
                  SET @cOutField11 = CASE WHEN @cFieldAttr13 = 'O' THEN '' ELSE CAST( @nPQTY_PWY AS NVARCHAR( 5)) END
                  SET @cOutField12 = CAST( @nMQTY_PWY AS NVARCHAR( 5))
                  SET @cOutField15 = CAST( @nRec AS NVARCHAR( 5)) + '/' + CAST( @nTotalRec AS NVARCHAR( 5))

                  -- Remain in current screen
                  GOTO Quit
               END

               -- Validate PQTY
               IF @cPQTY = '' SET @cPQTY = '0' -- Blank taken as zero
               IF RDT.rdtIsValidQTY( @cPQTY, 0) = 0
               BEGIN
                  SET @nErrNo = 257204
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
                  EXEC rdt.rdtSetFocusField @nMobile, 13 -- PQTY
                  GOTO Scn_6820_Fail
               END

               -- Validate MQTY
               IF @cMQTY  = '' SET @cMQTY  = '0' -- Blank taken as zero
               IF RDT.rdtIsValidQTY( @cMQTY, 0) = 0
               BEGIN
                  SET @nErrNo = 257205
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
                  EXEC rdt.rdtSetFocusField @nMobile, 14 -- MQTY
                  GOTO Scn_6820_Fail
               END

               -- Calc total QTY in master UOM
               SET @nPQTY = CAST( @cPQTY AS INT)
               SET @nMQTY = CAST( @cMQTY AS INT)
               SET @nQTY = rdt.rdtConvUOMQTY( @cStorerKey, @cSKU, @cPQTY, @cPUOM, 6) -- Convert to QTY in master UOM
               SET @nQTY = @nQTY + @nMQTY

               -- Validate QTY
               IF @nQTY = 0
               BEGIN
                  SET @nErrNo = 257206
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- QTY needed
                  GOTO Scn_6820_Fail
               END

               IF @cPAMatchQTY = '1'
               BEGIN
                  IF @nQTY_PWY <> @nQTY
                  BEGIN
                     SET @nErrNo = 257207
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- QTY NOT MATCH
                     GOTO Scn_6820_Fail
                  END
               END

               -- Validate QTY to move more than QTY avail
               IF @nQTY > @nQTY_PWY
               BEGIN
                  SET @nErrNo = 257208
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- QTYPWY NotEnuf
                  GOTO Scn_6820_Fail
               END

               -- Get suggest LOC
               DECLARE @nPAErrNo INT
               SET @nPAErrNo = 0
               SET @nPABookingKey = 0
               EXEC rdt.rdt_PutawayBySKU_GetSuggestLOC @nMobile, @nFunc, @cLangCode, @cUserName, @cStorerKey, @cFacility
                  ,@cLOC
                  ,@cID
                  ,@cLOT
                  ,@cUCC
                  ,@cSKU
                  ,@nQTY
                  ,@cSuggestedLOC   OUTPUT
                  ,@nPABookingKey   OUTPUT
                  ,@nPAErrNo        OUTPUT
                  ,@cErrMsg         OUTPUT
               IF @nPAErrNo <> 0 AND
                  @nPAErrNo <> -1 -- No suggested LOC
               BEGIN
                  SET @nErrNo = @nPAErrNo
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Scn_6820_Fail
               END

               SET @cQTY_Avail = '0'
               SET @cQTY_Alloc = '0'
               SET @cQTY_PMoveIn = '0'

               -- Check any suggested LOC
               IF @cSuggestedLOC = ''
               BEGIN
                  SET @nErrNo = 257209
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoSuitableLOC
               END
               ELSE IF @cSuggestedLOC = 'SEE_SUPV'
               BEGIN
                  SET @nErrNo = 257210
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoSuggestedLOC
               END
               ELSE
                  -- Get suggested LOC info
                  SELECT
                     @cQTY_Avail = ISNULL( TRY_CAST( SUM( LLI.QTY - LLI.QtyPicked) AS NVARCHAR(5)), '0'),
                     @cQTY_Alloc = ISNULL( TRY_CAST( SUM( LLI.QTYAllocated) AS NVARCHAR(5)), '0'),
                     @cQTY_PMoveIn = ISNULL( TRY_CAST( SUM( LLI.PendingMoveIn) AS NVARCHAR(5)), '0')
                  FROM dbo.LotxLocxID LLI WITH (NOLOCK)
                     JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
                  WHERE LOC.Facility = @cFacility
                     AND LLI.StorerKey = @cStorerKey
                     AND LLI.SKU = @cSKU
                     AND LLI.LOC = @cSuggestedLOC
         
               IF @nQty > @nPreAlloQty AND @nPreAlloQty <> 0
               BEGIN
                  SET @cOutField01 = ''
                  SET @cOutField15 = ''
                  --Go to confirm qty screen
                  SET @nAfterStep = 99
                  SET @nAfterScn = 6821
               END
               ELSE
               BEGIN
                  -- Prepare next screen var
                  SET @cOutField01 = @cSuggestedLOC
                  SET @cOutField02 = CASE WHEN @cDefaultSuggestSKU = '1' THEN @cSuggestedLOC ELSE '' END -- FinalLOC
                  SET @cOutField03 = @cQTY_Avail
                  SET @cOutField04 = @cQTY_Alloc
                  SET @cOutField05 = @cQTY_PMoveIn
                  SET @cOutfield15 = '' -- ExtInfo

                  -- Go to Loc screen
                  SET @nAfterScn = 2883
                  SET @nAfterStep = 4
               END

               IF @nDebugFlag = 1
                  SELECT 'After Scn6820 Enter', @nQty AS Qty, @cSuggestedLOC AS SuggestedLoc

               --Export values to main SP
               SET @cUDF01 = CAST(ISNULL(@nPQTY_PWY, 0) AS NVARCHAR(6))
               SET @cUDF02 = CAST(ISNULL(@nMQTY_PWY, 0) AS NVARCHAR(6)) 
               SET @cUDF03 = CAST(ISNULL(@nQTY_PWY, 0) AS NVARCHAR(6)) 
               SET @cUDF04 = CAST(ISNULL(@nQTY, 0) AS NVARCHAR(6)) 
               SET @cUDF05 = CAST(ISNULL(@nPABookingKey, 0) AS NVARCHAR(20)) 
               SET @cUDF06 = @cSuggestedLOC
               SET @cUDF07 = @cQTY_Avail  
               SET @cUDF08 = @cQTY_Alloc  
               SET @cUDF09 = @cQTY_PMoveIn
            END--Enter

            GOTO Quit

            Scn_6820_Fail:
               GOTO Quit
         END--6820

         
         IF @nMOBRECScn = 6821 -- Qty confirm 
         /************************************************************************************
         Scn = 6821. Qty confirm 
            OPTION    (field01, input)
         ************************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6821, ESC'

               -- Unlock current session suggested LOC
               IF @nPABookingKey <> 0
               BEGIN
                  EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                     ,'' --FromLOC
                     ,'' --FromID
                     ,'' --SuggLOC
                     ,'' --Storer
                     ,@nErrNo  OUTPUT
                     ,@cErrMsg OUTPUT
                     ,@nPABookingKey = @nPABookingKey OUTPUT

                  SET @nPABookingKey = 0
               END 

               -- Go to new qty screen
               SET @nAfterScn = 6820
               SET @nAfterStep = 99
               
               -- Prepare next screen variable
               SET @cOutField01 = @cSKU
               SET @cOutField02 = SUBSTRING( @cSKUDesc, 1, 20)
               SET @cOutField03 = SUBSTRING( @cSKUDesc, 21, 20)
               SET @cOutField04 = @cLottable01
               SET @cOutField05 = @cLottable02
               SET @cOutField06 = @cLottable03
               SET @cOutField07 = rdt.rdtFormatDate( @dLottable04)
               SET @cOutField08 = LEFT( '1:' + CAST( @nPUOM_Div AS NVARCHAR( 6)) + SPACE( 7), 7) +
                                 RIGHT( SPACE( 5) + rdt.rdtRightAlign( @cPUOM_Desc, 5), 5) +
                                 RIGHT( SPACE( 5) + rdt.rdtRightAlign( @cMUOM_Desc, 5), 5)
               SET @cOutField09 = CAST( @nRec AS NVARCHAR( 5)) + '/' + CAST( @nTotalRec AS NVARCHAR( 5))
               SET @cOutField11 = CASE WHEN @cFieldAttr13 = 'O' THEN '' ELSE CAST( @nPQTY_PWY AS NVARCHAR( 5)) END
               SET @cOutField12 = CAST( @nMQTY_PWY AS NVARCHAR( 5))
               SET @cOutField13 = ''
               SET @cOutField14 = CASE WHEN @cDefaultQTY = '1' THEN '1' ELSE '' END
               SET @cOutField15 = 'PR QTY: ' + CAST(@nPreAlloQty AS NVARCHAR(6))
            END-- ESC

            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6821, Enter'
               
               SET @cOption = @cInField01

               IF @cOption NOT IN ('1', '2')
               BEGIN
                  SET @nErrNo = 257211
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               IF @cOption = '1'
               BEGIN
                  -- Prepare next screen var
                  SET @cOutField01 = @cSuggestedLOC
                  SET @cOutField02 = CASE WHEN @cDefaultSuggestSKU = '1' THEN @cSuggestedLOC ELSE '' END -- FinalLOC
                  SET @cOutField03 = @cQTY_Avail
                  SET @cOutField04 = @cQTY_Alloc
                  SET @cOutField05 = @cQTY_PMoveIn
                  SET @cOutfield15 = '' -- ExtInfo

                  -- Go to Loc screen
                  SET @nAfterScn = 2883
                  SET @nAfterStep = 4
               END --opt1

               IF @cOption = '2'
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Scn6821, Enter, Option2'

                  -- Unlock current session suggested LOC
                  IF @nPABookingKey <> 0
                  BEGIN
                     EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                        ,'' --FromLOC
                        ,'' --FromID
                        ,'' --SuggLOC
                        ,'' --Storer
                        ,@nErrNo  OUTPUT
                        ,@cErrMsg OUTPUT
                        ,@nPABookingKey = @nPABookingKey OUTPUT

                     SET @nPABookingKey = 0
                  END 

                  -- Go to new qty screen
                  SET @nAfterScn = 6820
                  SET @nAfterStep = 99
                  
                  -- Prepare next screen variable
                  SET @cOutField01 = @cSKU
                  SET @cOutField02 = SUBSTRING( @cSKUDesc, 1, 20)
                  SET @cOutField03 = SUBSTRING( @cSKUDesc, 21, 20)
                  SET @cOutField04 = @cLottable01
                  SET @cOutField05 = @cLottable02
                  SET @cOutField06 = @cLottable03
                  SET @cOutField07 = rdt.rdtFormatDate( @dLottable04)
                  SET @cOutField08 = LEFT( '1:' + CAST( @nPUOM_Div AS NVARCHAR( 6)) + SPACE( 7), 7) +
                                    RIGHT( SPACE( 5) + rdt.rdtRightAlign( @cPUOM_Desc, 5), 5) +
                                    RIGHT( SPACE( 5) + rdt.rdtRightAlign( @cMUOM_Desc, 5), 5)
                  SET @cOutField09 = CAST( @nRec AS NVARCHAR( 5)) + '/' + CAST( @nTotalRec AS NVARCHAR( 5))
                  SET @cOutField11 = CASE WHEN @cFieldAttr13 = 'O' THEN '' ELSE CAST( @nPQTY_PWY AS NVARCHAR( 5)) END
                  SET @cOutField12 = CAST( @nMQTY_PWY AS NVARCHAR( 5))
                  SET @cOutField13 = ''
                  SET @cOutField14 = CASE WHEN @cDefaultQTY = '1' THEN '1' ELSE '' END
                  SET @cOutField15 = 'PR QTY: ' + CAST(@nPreAlloQty AS NVARCHAR(6))
               END--opt2
               
            END -- enter

            GOTO Quit
         END --6821
      END--Step99
   END -- 523

   GOTO Quit

   Quit:
      --update fields used in extscn but not in base
      BEGIN TRY
         UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
            C_Integer1 = @nPreAlloQty
         WHERE Mobile = @nMobile
      END TRY
      BEGIN CATCH
         SET @nErrNo = 256804
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      END CATCH
   
END--SP
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_523ExtScn01 TO NSQL
GO


