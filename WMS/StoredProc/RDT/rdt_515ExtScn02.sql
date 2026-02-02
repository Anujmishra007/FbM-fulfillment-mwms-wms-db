
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/  
/* Store procedure: rdt_515ExtScn02                                     */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2026-01-19 1.0  JACKC      FCR-9660. Created                         */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_515ExtScn02] (
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
      @cExtendedInfoSP        NVARCHAR( 20)

   DECLARE -- business
      @cSKU                NVARCHAR( 20),
      @cSKUDescr           NVARCHAR( 60),
      @cID                 NVARCHAR( 18),
      @cFromLOC            NVARCHAR( 10),
      @cFromID             NVARCHAR( 18),
      @cToLOC              NVARCHAR( 18),
      @cToLocPAZone        NVARCHAR( 10),
      @cToID               NVARCHAR( 18),
      @cPQTY               NVARCHAR( 5),
      @cMQTY               NVARCHAR( 5),
      @cPUOM               NVARCHAR( 1),
      @cPUOM_Desc          NVARCHAR( 5),  -- Pref UOM 
      @cMUOM_Desc          NVARCHAR( 5),
      @cLot                NVARCHAR( 10),
      @cLottableLabel01    NVARCHAR( 20),
      @cLottableLabel02    NVARCHAR( 20),
      @cLottableLabel03    NVARCHAR( 20),
      @cLottableLabel04    NVARCHAR( 20),
      @cSearchLottable01   NVARCHAR( 18),
      @cSearchLottable02   NVARCHAR( 18),
      @cSearchLottable03   NVARCHAR( 18),
      @cSearchLottable04   NVARCHAR( 16),
      @cCartonType         NVARCHAR( 20),
      @cCartonCount        NVARCHAR( 30),
      @cDefaultCartonCNT   NVARCHAR( 30),
      @cChkFacility        NVARCHAR( 5),
      @cChkToLoc           NVARCHAR( 18),
      @cOption             NVARCHAR( 1),
      @dSearchLottable04   DATETIME,
      @nQTY_Avail          INT,
      @nMQTY_Avail         INT,
      @nPQTY_Avail         INT,
      @nPQTY_Move          INT,
      @nMQTY_Move          INT,
      @nQTY_Move           INT,
      @nTotalPreAlloQty    INT,
      @nMovedQty           INT,
      @nPreAlloQty         INT,
      @nTranCount          INT

      --Movment
      DECLARE @nQTY_Bal    INT
      DECLARE @nQTY_LLI    INT
      DECLARE @nQTY        INT    
      DECLARE @curLLI      CURSOR
   
   SET @nErrNo = 0
   SET @cErrMsg = ''

   --SELECT @cDropID = Value FROM @tExtScnData WHERE Variable = '@cDropID'

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
      @cSKUDescr           = V_SKUDescr,
      @cPUOM               = V_UOM,     -- Pref UOM
      @cLottable01         = V_Lottable01,
      @cLottable02         = V_Lottable02,
      @cLottable03         = V_Lottable03,
      @dLottable04         = V_Lottable04,
      @cFromLOC            = V_String1,
      @cFromID             = V_String2,
      @cSKU                = V_String3,
      @cSearchLottable01   = V_String4,
      @cSearchLottable02   = V_String5,
      @cSearchLottable03   = V_String6,
      @cSearchLottable04   = V_String7,
      @cPUOM_Desc          = V_String8,
      @cMUOM_Desc          = V_String9,
      @cToLOC              = V_String17,
      @cToID               = V_String18,

      @nQTY_Avail          = V_Integer1,
      @nPQTY_Avail         = V_Integer2,
      @nMQTY_Avail         = V_Integer3,
      @nQTY_Move           = V_Integer4,
      @nPQTY_Move          = V_Integer5,
      @nMQTY_Move          = V_Integer6,

      @cCartonType         = C_String1,
      @cCartonCount        = C_String2,
      @nPreAlloQty         = C_Integer1
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_515ExtScn02'

   IF @nFunc = 515
   BEGIN
      IF @nMOBRECStep = 5 AND @nMOBRECScn = 1044 AND @nStep = 6 AND @nScn = 1045
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Running extended Step5 Enter logic'

            SET @cPQTY = ISNULL( @cInField10, '')
            SET @cMQTY = ISNULL( @cInField13, '')

            IF @cPQTY = '' SET @cPQTY = '0'

            -- Calc total QTY in master UOM
            SET @nPQTY_Move = CAST( @cPQTY AS INT)
            SET @nMQTY_Move = CAST( @cMQTY AS INT)
            SET @nQTY_Move = rdt.rdtConvUOMQTY( @cStorerKey, @cSKU, @cPQTY, @cPUOM, 6) -- Convert to QTY in master UOM
            SET @nQTY_Move = @nQTY_Move + @nMQTY_Move

            -- Get reallocated Qty
            SELECT TOP 1
               @cLot = Lot 
            FROM dbo.LotAttribute WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND Lottable02 = @cSearchLottable02
               --AND Lottable01 = @cSearchLottable01 --test
               --AND lottable03 = @cSearchLottable03 -- test
               --AND IsNULL( LA.Lottable04, 0) = CASE WHEN @dSearchLottable04 = 0 THEN IsNULL( LA.Lottable04, 0) ELSE @dSearchLottable04 END
            
            SELECT 
               @nMovedQty = ISNULL(SUM(Qty-(QtyAllocated + QtyPicked)), 0)
            FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) 
               ON LOC.LOC = LLI.LOC
            JOIN dbo.CodeLKUP CL WITH (NOLOCK)
               ON CL.code=LOC.PUTAWAYZONE 
               AND CL.code2=LOC.Facility
            WHERE LLI.StorerKey = @cStorerKey 
               AND LLI.LOT = @cLot
               AND LLI.SKU = @cSKU
               AND CL.LISTNAME ='VORZONE'

            SELECT 
               @nTotalPreAlloQty = ISNULL(QtyPreAllocated, 0) 
            FROM dbo.LOT WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Lot = @cLot

            IF @nTotalPreAlloQty - @nMovedQty > 0
               SET @nPreAlloQty = @nTotalPreAlloQty - @nMovedQty
            ELSE
               SET @nPreAlloQty = 0

            IF @nDebugFlag = 1
               SELECT 'Qty info', @nPQTY_Move AS PQty, @nMQTY_Move AS MQTY, @nMovedQty AS MovedQty, 
                      @nTotalPreAlloQty AS TotalPreAlloQty

            IF @nPreAlloQty > 0
            BEGIN
               IF @nQTY_Move > @nPreAlloQty
               BEGIN
                  SET @nAfterStep = 99
                  SET @nAfterScn  = 6814 -- Confirm Qty screen

                  SET @cOutField01 = ''
               END
               ELSE
               BEGIN
                  SET @nAfterStep = 6
                  SET @nAfterScn = 1045 -- drop id screen

                  SET @cOutField10 = ''
               END
            END
            ELSE -- follow base logic
            BEGIN
               GOTO Quit
            END
         END -- enter

         GOTO Quit
      END--Extend step5 Qty screen enter logic

      IF @nMOBRECStep = 6 AND @nMOBRECScn = 1045 AND @nStep = 7 AND @nScn = 1046
      BEGIN
         IF EXISTS (SELECT 1 FROM dbo.SKU WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND SKU = @cSKU
                        AND PrePackIndicator = '1')
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cDefaultCartonCNT = rdt.RDTGetConfig( @nFunc, 'DefaultCartonCNT', @cStorerKey)
               IF @cDefaultCartonCNT = '0'
                  SET @cDefaultCartonCNT = ''

               SET @cOutField01 = ''
               SET @cOutField02 = @cDefaultCartonCNT

               SET @nAfterStep = 99
               SET @nAfterScn  = 6815
            END
         END

         GOTO Quit
      END -- Extend step6 toID screen enter logic

      IF @nMOBRECStep = 99
      BEGIN
         IF @nMOBRECScn = 6814 -- Qty confirm 
         /************************************************************************************
         Scn = 6814. Qty confirm 
            OPTION    (field01, input)
         ************************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6814, ESC'

               SET @cFieldAttr01 = ''
               SET @cFieldAttr02 = ''
               SET @cFieldAttr03 = ''
               SET @cFieldAttr04 = ''
               SET @cFieldAttr05 = ''
               SET @cFieldAttr06 = ''
               SET @cFieldAttr07 = ''
               SET @cFieldAttr08 = ''
               SET @cFieldAttr09 = ''
               SET @cFieldAttr10 = ''
               SET @cFieldAttr11 = ''
               SET @cFieldAttr12 = ''
               SET @cFieldAttr13 = ''
               SET @cFieldAttr14 = ''
               SET @cFieldAttr15 = ''

               -- Prepare next screen var
               SET @cOutField01 = @cID
               SET @cOutField02 = @cLottable01
               SET @cOutField03 = @cLottable02
               SET @cOutField04 = @cLottable03
               SET @cOutField05 = rdt.rdtFormatDate( @dLottable04)
               IF @cPUOM_Desc = ''
               BEGIN
                  SET @cOutField08 = '' -- @cPUOM_Desc
                  SET @cOutField09 = '' -- @nPQTY_Avail
                  SET @cOutField10 = '' -- @nPQTY_Move
                  SET @nMQTY_Avail = @nQTY_Avail -- Bug fix by Vicky on 09-Aug-2007
                  SET @cFieldAttr10 = 'O'
               END
               ELSE
               BEGIN
                  SET @cOutField08 = @cPUOM_Desc
                  SET @cOutField09 = CAST( @nPQTY_Avail AS NVARCHAR( 5))
                  SET @cOutField10 = CAST( @nPQTY_Move AS NVARCHAR( 5))
               END
               SET @cOutField11 = @cMUOM_Desc
               SET @cOutField12 = CAST( @nMQTY_Avail AS NVARCHAR( 5))
               SET @cOutField13 = CAST( @nMQTY_Move AS NVARCHAR( 5))

               SET @nAfterScn = 1044
               SET @nAfterStep = 5
            END-- ESC

            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6814, Enter'
               
               SET @cOption = @cInField01

               IF @cOption NOT IN ('1', '2')
               BEGIN
                  SET @nErrNo = 256801
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               IF @cOption = '1'
               BEGIN
                  -- Prep ToID screen var
                  SET @cFromID = @cID
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
                     SET @cFieldAttr07 = 'O'
                  END
                  ELSE
                  BEGIN
                     SET @cOutField06 = @cPUOM_Desc
                     SET @cOutField07 = CAST( @nPQTY_Move AS NVARCHAR( 5))
                  END
                  SET @cOutField08 = @cMUOM_Desc
                  SET @cOutField09 = CAST( @nMQTY_Move AS NVARCHAR( 5))
                  SET @cOutField10 = '' -- @cToID

                  SET @nAfterStep = 6
                  SET @nAfterScn = 1045 -- drop id screen
               END --opt1

               IF @cOption = '2'
               BEGIN
                  SET @cFieldAttr01 = ''
                  SET @cFieldAttr02 = ''
                  SET @cFieldAttr03 = ''
                  SET @cFieldAttr04 = ''
                  SET @cFieldAttr05 = ''
                  SET @cFieldAttr06 = ''
                  SET @cFieldAttr07 = ''
                  SET @cFieldAttr08 = ''
                  SET @cFieldAttr09 = ''
                  SET @cFieldAttr10 = ''
                  SET @cFieldAttr11 = ''
                  SET @cFieldAttr12 = ''
                  SET @cFieldAttr13 = ''
                  SET @cFieldAttr14 = ''
                  SET @cFieldAttr15 = ''

                  -- Prepare next screen var
                  SET @cOutField01 = @cID
                  SET @cOutField02 = @cLottable01
                  SET @cOutField03 = @cLottable02
                  SET @cOutField04 = @cLottable03
                  SET @cOutField05 = rdt.rdtFormatDate( @dLottable04)
                  IF @cPUOM_Desc = ''
                  BEGIN
                     SET @cOutField08 = '' -- @cPUOM_Desc
                     SET @cOutField09 = '' -- @nPQTY_Avail
                     SET @cOutField10 = '' -- @nPQTY_Move
                     SET @nMQTY_Avail = @nQTY_Avail -- Bug fix by Vicky on 09-Aug-2007
                     SET @cFieldAttr10 = 'O'
                  END
                  ELSE
                  BEGIN
                     SET @cOutField08 = @cPUOM_Desc
                     SET @cOutField09 = CAST( @nPQTY_Avail AS NVARCHAR( 5))
                     SET @cOutField10 = CAST( @nPQTY_Move AS NVARCHAR( 5))
                  END
                  SET @cOutField11 = @cMUOM_Desc
                  SET @cOutField12 = CAST( @nMQTY_Avail AS NVARCHAR( 5))
                  SET @cOutField13 = CAST( @nMQTY_Move AS NVARCHAR( 5))

                  SET @nAfterScn = 1044
                  SET @nAfterStep = 5  
               END--opt2

            END -- enter

            GOTO Quit
         END --6814

         IF @nMOBRECScn = 6815 -- DropID screen
         /************************************************************************************
         Scn = 6815. DropID 
            CartonType    (field01, input)
            Count         (field02, input)
         ************************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6815, ESC'

               SET @cFieldAttr01 = ''
               SET @cFieldAttr02 = ''
               SET @cFieldAttr03 = ''
               SET @cFieldAttr04 = ''
               SET @cFieldAttr05 = ''
               SET @cFieldAttr06 = ''
               SET @cFieldAttr07 = ''
               SET @cFieldAttr08 = ''
               SET @cFieldAttr09 = ''
               SET @cFieldAttr10 = ''
               SET @cFieldAttr11 = ''
               SET @cFieldAttr12 = ''
               SET @cFieldAttr13 = ''
               SET @cFieldAttr14 = ''
               SET @cFieldAttr15 = ''

               -- Prepare ToID screen var
               SET @cToID = ''
               SET @cOutField01 = @cFromLOC
               SET @cOutField02 = @cID
               SET @cOutField03 = @cSKU
               SET @cOutField04 = SUBSTRING( @cSKUDescR, 1, 20)   -- SKU desc 1
               SET @cOutField05 = SUBSTRING( @cSKUDescR, 21, 20)  -- SKU desc 2
               IF @cPUOM_Desc = ''
               BEGIN
                  SET @cOutField06 = '' -- @cPUOM_Desc
                  SET @cOutField07 = '' -- @nPQTY_Avail
                  SET @cFieldAttr07 = 'O'
               END
               ELSE
               BEGIN
                  SET @cOutField06 = @cPUOM_Desc
                  SET @cOutField07 = CAST( @nPQTY_Move AS NVARCHAR( 5))
               END
               SET @cOutField08 = @cMUOM_Desc
               SET @cOutField09 = CAST( @nMQTY_Move AS NVARCHAR( 5))
               SET @cOutField10 = '' -- ToID

               SET @nAfterScn = 1045
               SET @nAfterStep = 6 
            END -- esc

            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6815, Enter'

               SET @cCartonType = @cInField01
               SET @cCartonCount = @cInField02

               IF @cToID = ''
               BEGIN
                  SET @nErrNo = 256817
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               IF @cCartonType = ''
               BEGIN
                  SET @nErrNo = 256802
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               IF @cCartonCount = ''
               BEGIN
                  SET @nErrNo = 256803
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               IF NOT EXISTS (SELECT 1 FROM dbo.Storer st WITH (NOLOCK)
                              JOIN dbo.CARTONIZATION cart WITH (NOLOCK)
                                 ON st.CartonGroup = cart.CartonizationGroup
                              WHERE Storerkey = @cStorerKey
                                 AND CartonType = @cCartonType)
               BEGIN
                  SET @nErrNo = 256820
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Dropid dtl exists
                  GOTO Quit
               END

               IF EXISTS (SELECT 1 FROM dbo.DropidDetail WITH (NOLOCK) WHERE DropID = @cToID AND ChildId = @cCartonType)
               BEGIN
                  SET @nErrNo = 256818
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Dropid dtl exists
                  GOTO Quit
               END

               SET @cFieldAttr01 = ''
               SET @cFieldAttr02 = ''
               SET @cFieldAttr03 = ''
               SET @cFieldAttr04 = ''
               SET @cFieldAttr05 = ''
               SET @cFieldAttr06 = ''
               SET @cFieldAttr07 = ''
               SET @cFieldAttr08 = ''
               SET @cFieldAttr09 = ''
               SET @cFieldAttr10 = ''
               SET @cFieldAttr11 = ''
               SET @cFieldAttr12 = ''
               SET @cFieldAttr13 = ''
               SET @cFieldAttr14 = ''
               SET @cFieldAttr15 = ''

               -- Prep ToLOC screen var
               --SET @cToLOC = ''
               SET @cOutField01 = @cFromLOC
               SET @cOutField02 = @cID
               SET @cOutField03 = @cSKU
               SET @cOutField04 = SUBSTRING( @cSKUDescr, 1, 20)   -- SKU desc 1
               SET @cOutField05 = SUBSTRING( @cSKUDescr, 21, 20)  -- SKU desc 2
               IF @cPUOM_Desc = ''
               BEGIN
                  SET @cOutField06 = '' -- @cPUOM_Desc
                  SET @cOutField07 = '' -- @nPQTY_Avail
                  SET @cFieldAttr07 = 'O'
               END
               ELSE
               BEGIN
                  SET @cOutField06 = @cPUOM_Desc
                  SET @cOutField07 = CAST( @nPQTY_Move AS NVARCHAR( 5))
               END
               SET @cOutField08 = @cMUOM_Desc
               SET @cOutField09 = CAST( @nMQTY_Move AS NVARCHAR( 5))
               SET @cOutField10 = @cToID
               SET @cOutField11 = ''

               SET @nAfterStep = 99 -- Go to new toLoc if RealloQty > 0
               SET @nAfterScn = 6817

            END --Enter

            GOTO Quit
         END --6815

         IF @nMOBRECScn = 6817 --ToLoc when Preallo > 0
         /********************************************************************************
         Scn = 6817. ToLOC
            FromLOC (field01)
            FromID  (field02)
            SKU     (field03)
            Desc1   (field04)
            Desc2   (field05)
            UOM     (field06, field08)
            QTY MV  (field07, field09)
            ToID    (field10)
            ToLOC   (field11, input)
         ********************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6817, ESC'

               SET @cDefaultCartonCNT = rdt.RDTGetConfig( @nFunc, 'DefaultCartonCNT', @cStorerKey)
               IF @cDefaultCartonCNT = '0'
                  SET @cDefaultCartonCNT = ''

               SET @cOutField01 = ''
               SET @cOutField02 = @cDefaultCartonCNT

               SET @nAfterStep = 99
               SET @nAfterScn  = 6815
            END --esc

            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6817, Enter'
               
               -- Screen mapping
               SET @cToLOC = @cInField11

               SET @cFieldAttr01 = ''
               SET @cFieldAttr02 = ''
               SET @cFieldAttr03 = ''
               SET @cFieldAttr04 = ''
               SET @cFieldAttr05 = ''
               SET @cFieldAttr06 = ''
               SET @cFieldAttr07 = ''
               SET @cFieldAttr08 = ''
               SET @cFieldAttr09 = ''
               SET @cFieldAttr10 = ''
               SET @cFieldAttr11 = ''
               SET @cFieldAttr12 = ''
               SET @cFieldAttr13 = ''
               SET @cFieldAttr14 = ''
               SET @cFieldAttr15 = ''

               -- Validate blank
               IF @cToLOC = '' OR @cToLOC IS NULL
               BEGIN
                  SET @nErrNo = 256805
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ToLOC needed'
                  GOTO Scn_6817_Fail
               END

               -- Get LOC info
               SELECT 
                  @cChkFacility = Facility,
                  @cToLocPAZone = PutawayZone
               FROM dbo.LOC (NOLOCK)
               WHERE LOC = @cToLOC

               -- Validate LOC
               IF @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 256806
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid LOC'
                  GOTO Scn_6817_Fail
               END

               -- Validate LOC's facility
               IF NOT (rdt.rdtGetConfig( 0, 'MoveToLOCNotCheckFacility', @cStorerKey) = '1')
               BEGIN
                  IF @cChkFacility <> @cFacility
                  BEGIN
                     SET @nErrNo = 256807
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Diff facility'
                     GOTO Scn_6817_Fail
                  END
               END

               --ToID not in the other location
               SELECT @cChkToLoc = Loc
               FROM dbo.LOTxLOCxID WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND ID = @cToID
                  AND ((Qty - QtyPicked) > 0 OR PendingMoveIn > 0) 

               IF @@ROWCOUNT = 0
                  SET @cChkToLoc = ''

               IF @cChkToLoc <> '' AND @cChkToLoc <> @cToLOC
               BEGIN
                  SET @nErrNo = 256819
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'toId in the other loc'
                  GOTO Scn_6817_Fail
               END

               IF NOT EXISTS ( SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK) 
                                 WHERE ListName = 'VORZONE'
                                    AND StorerKey = @cStorerKey
                                    AND Code = @cToLocPAZone)
               BEGIN
                  SET @cOutField01 = ''

                  SET @nAfterScn = 6816 -- goto toLoc confirm screen
                  SET @nAfterStep = 99

                  --return toloc to main
                  SET @cUDF01 = @cToLOC
                  GOTO Quit
               END

               --DECLARE @nQTY_Bal INT
               -- @nQTY_LLI INT
               --DECLARE @nQTY     INT
               --DECLARE @cLOT     NVARCHAR( 10) already declared
               SET @dSearchLottable04 = ISNULL(rdt.rdtConvertToDate(@cSearchLottable04), 0)             -- ZG01

               -- Prepare cursor
               --DECLARE @curLLI CURSOR
               SET @curLLI = CURSOR FAST_FORWARD READ_ONLY FOR
                  SELECT
                     LLI.LOT,
                     LLI.QTY - LLI.QTYAllocated - LLI.QTYPicked - (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)
                  FROM dbo.LOTxLOCxID LLI(NOLOCK)
                     INNER JOIN dbo.LotAttribute LA (NOLOCK) ON (LLI.LOT = LA.LOT)
                  WHERE LLI.StorerKey = @cStorerKey
                     AND LLI.SKU = @cSKU
                     AND LLI.LOC = @cFromLOC
                     AND (LLI.QTY - LLI.QTYAllocated - LLI.QTYPicked - (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)) > 0
                     AND LLI.ID = @cID
                     AND LA.Lottable01 = @cLottable01
                     AND LA.Lottable02 = @cLottable02
                     AND LA.Lottable03 = @cLottable03
                     -- NULL column cannot be compared, even if SET ANSI_NULLS OFF
                     --AND LA.Lottable04 = @dLottable04
                     AND IsNULL( LA.Lottable04, 0) = CASE WHEN @dSearchLottable04 = 0 THEN IsNULL( LA.Lottable04, 0) ELSE @dSearchLottable04 END
                  ORDER BY LLI.ID, LA.Lottable01, LA.Lottable02, LA.Lottable03, LA.Lottable04
               OPEN @curLLI

               -- Handling transaction
               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN  -- Begin our own transaction
               SAVE TRAN rdt_512ExtScn02_6817 -- For rollback or commit only our own 
               
               -- Create drop id 
               IF NOT EXISTS (SELECT 1 FROM dbo.DropID WITH (NOLOCK) WHERE DropID = @cToID) AND ISNULL(@cToID, '') <> ''
               BEGIN
                  BEGIN TRY
                     INSERT INTO dbo.DropID (Dropid, Status) VALUES (@cToID, '9')
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 256808
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Ins drop fail'
                     GOTO RollBackTran_6817
                  END CATCH
               END

               -- create drop id detail
               IF NOT EXISTS (SELECT 1 FROM dbo.DropidDetail WITH (NOLOCK) WHERE DropID = @cToID AND ChildId = @cCartonType)
               BEGIN
                  BEGIN TRY
                     INSERT INTO dbo.DropidDetail (Dropid, ChildId, UserDefine01, UserDefine02) 
                     VALUES (@cToID, ISNULL(@cCartonType,''), @cCartonCount, @cLottable02)
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 256809
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Ins dropdetail fail'
                     GOTO RollBackTran_6817
                  END CATCH
               END
               ELSE
               BEGIN
                  SET @nErrNo = 256810
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Carton Type already exists'
                  GOTO RollBackTran_6817
               END

               -- Loop LOTxLOTxID
               FETCH NEXT FROM @curLLI INTO @cLOT, @nQTY_LLI
               SET @nQTY_Bal = @nQTY_Move
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  -- Calc LLI.QTY to take
                  IF @nQTY_LLI > @nQTY_Bal
                     SET @nQTY = @nQTY_Bal -- LLI had enuf QTY, so charge all the balance into this LLI
                  ELSE
                     SET @nQTY = @nQTY_LLI -- LLI not enuf QTY, take all QTY avail of this LLI

                  EXECUTE rdt.rdt_Move
                     @nMobile     = @nMobile,
                     @cLangCode   = @cLangCode,
                     @nErrNo      = @nErrNo  OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
                     @cSourceType = 'rdt_515ExtScn02',
                     @cStorerKey  = @cStorerKey,
                     @cFacility   = @cFacility,
                     @cFromLOC    = @cFromLOC,
                     @cToLOC      = @cToLOC,
                     @cFromID     = @cID,         -- NULL means not filter by ID. Blank is a valid ID
                     @cToID       = @cToID,       -- NULL means not changing ID. Blank consider a valid ID
                     @cSKU        = @cSKU,
                     @nQTY        = @nQTY,
                     @cFromLOT    = @cLOT

                  IF @nErrNo <> 0
                  BEGIN
                     CLOSE @curLLI
                     DEALLOCATE @curLLI
                     GOTO RollBackTran_6817
                  END
                  ELSE
                  BEGIN
                     -- EventLog
                     EXEC RDT.rdt_STD_EventLog
                     @cActionType   = '4', -- Move
                     @cUserID       = @cUserName,
                     @nMobileNo     = @nMobile,
                     @nFunctionID   = @nFunc,
                     @cFacility     = @cFacility,
                     @cStorerKey    = @cStorerkey,
                     @cLocation     = @cFromLOC,
                     @cToLocation   = @cToLOC,
                     @cID           = @cFromID,
                     @cToID         = @cToID,
                     @cSKU          = @cSKU,
                     @cUOM          = @cMUOM_Desc,
                     @nQTY          = @nQTY,
                     @cLot          = @cLOT,
                     @nStep         = @nStep
                  END

                  SET @nQTY_Bal = @nQTY_Bal - @nQTY  -- Reduce balance
                  IF @nQTY_Bal <= 0
                     BREAK

                  FETCH NEXT FROM @curLLI INTO @cLOT, @nQTY_LLI
               END

               -- Still have balance, means no LLI changed
               IF @nQTY_Bal <> 0
               BEGIN
                  SET @nErrNo = 256815
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Inv changed'
                  CLOSE @curLLI
                  DEALLOCATE @curLLI
                  GOTO RollBackTran_6817
               END

               COMMIT TRAN rdt_512ExtScn02_6817 -- Only commit change made in here
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN

               SET @cOutField01 = @cToLOC

               -- Go to next screen
               SET @nAfterScn = 1047
               SET @nAfterStep = 8

               --return toloc to main
               SET @cUDF01 = @cToLOC
            END -- Enter

            GOTO Quit
            
            RollBackTran_6817:
            BEGIN
               ROLLBACK TRAN rdt_512ExtScn02_6817
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
            END

            Scn_6817_Fail:
            BEGIN
               SET @cToLOC = ''
               SET @cOutField11 = ''
            END

            GOTO Quit
         END -- 6817

         IF @nMOBRECScn = 6816 --ToLoc confirm
         /************************************************************************************
         Scn = 6816. ToLoc confirm 
            OPTION    (field01, input)
         ************************************************************************************/
         BEGIN
            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6816, Esc'

               SET @cFieldAttr01 = ''
               SET @cFieldAttr02 = ''
               SET @cFieldAttr03 = ''
               SET @cFieldAttr04 = ''
               SET @cFieldAttr05 = ''
               SET @cFieldAttr06 = ''
               SET @cFieldAttr07 = ''
               SET @cFieldAttr08 = ''
               SET @cFieldAttr09 = ''
               SET @cFieldAttr10 = ''
               SET @cFieldAttr11 = ''
               SET @cFieldAttr12 = ''
               SET @cFieldAttr13 = ''
               SET @cFieldAttr14 = ''
               SET @cFieldAttr15 = ''

               -- Prep ToLOC screen var
               --SET @cToLOC = ''
               SET @cOutField01 = @cFromLOC
               SET @cOutField02 = @cID
               SET @cOutField03 = @cSKU
               SET @cOutField04 = SUBSTRING( @cSKUDescr, 1, 20)   -- SKU desc 1
               SET @cOutField05 = SUBSTRING( @cSKUDescr, 21, 20)  -- SKU desc 2
               IF @cPUOM_Desc = ''
               BEGIN
                  SET @cOutField06 = '' -- @cPUOM_Desc
                  SET @cOutField07 = '' -- @nPQTY_Avail
                  SET @cFieldAttr07 = 'O'
               END
               ELSE
               BEGIN
                  SET @cOutField06 = @cPUOM_Desc
                  SET @cOutField07 = CAST( @nPQTY_Move AS NVARCHAR( 5))
               END
               SET @cOutField08 = @cMUOM_Desc
               SET @cOutField09 = CAST( @nMQTY_Move AS NVARCHAR( 5))
               SET @cOutField10 = @cToID
               SET @cOutField11 = ''
               
               SET @nAfterStep = 99 -- Go to new toLoc if RealloQty > 0
               SET @nAfterScn = 6817
            END --ESC
            
            IF @nInputKey = 1
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Scn6816, Enter'
               
               SET @cOption = @cInField01

               IF @cOption NOT IN ('1', '2')
               BEGIN
                  SET @nErrNo = 256811
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               IF @cOption = '1'
               BEGIN
                  --DECLARE @nQTY_Bal INT
                  --DECLARE @nQTY_LLI INT
                  --DECLARE @nQTY     INT
                  --DECLARE @cLOT     NVARCHAR( 10) already declared
                  SET @dSearchLottable04 = ISNULL(rdt.rdtConvertToDate(@cSearchLottable04), 0)             -- ZG01

                  -- Prepare cursor
                  --DECLARE @curLLI CURSOR
                  SET @curLLI = CURSOR FAST_FORWARD READ_ONLY FOR
                     SELECT
                        LLI.LOT,
                        LLI.QTY - LLI.QTYAllocated - LLI.QTYPicked - (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)
                     FROM dbo.LOTxLOCxID LLI(NOLOCK)
                        INNER JOIN dbo.LotAttribute LA (NOLOCK) ON (LLI.LOT = LA.LOT)
                     WHERE LLI.StorerKey = @cStorerKey
                        AND LLI.SKU = @cSKU
                        AND LLI.LOC = @cFromLOC
                        AND (LLI.QTY - LLI.QTYAllocated - LLI.QTYPicked - (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)) > 0
                        AND LLI.ID = @cID
                        AND LA.Lottable01 = @cLottable01
                        AND LA.Lottable02 = @cLottable02
                        AND LA.Lottable03 = @cLottable03
                        -- NULL column cannot be compared, even if SET ANSI_NULLS OFF
                        --AND LA.Lottable04 = @dLottable04
                        AND IsNULL( LA.Lottable04, 0) = CASE WHEN @dSearchLottable04 = 0 THEN IsNULL( LA.Lottable04, 0) ELSE @dSearchLottable04 END
                     ORDER BY LLI.ID, LA.Lottable01, LA.Lottable02, LA.Lottable03, LA.Lottable04
                  OPEN @curLLI

                  -- Handling transaction
                  SET @nTranCount = @@TRANCOUNT
                  BEGIN TRAN  -- Begin our own transaction
                  SAVE TRAN rdt_512ExtScn02_6816 -- For rollback or commit only our own 
                  
                  -- Create drop id 
                  IF NOT EXISTS (SELECT 1 FROM dbo.DropID WITH (NOLOCK) WHERE DropID = @cToID) AND ISNULL(@cToID,'') <> ''
                  BEGIN
                     BEGIN TRY
                        INSERT INTO dbo.DropID (Dropid, Status) VALUES (@cToID, '9')
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 256812
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Ins drop fail'
                        GOTO RollBackTran_6816
                     END CATCH
                  END

                  -- create drop id detail
                  IF NOT EXISTS (SELECT 1 FROM dbo.DropidDetail WITH (NOLOCK) WHERE DropID = @cToID AND ChildId = @cCartonType)
                  BEGIN
                     BEGIN TRY
                        INSERT INTO dbo.DropidDetail (Dropid, ChildId, UserDefine01, UserDefine02) 
                        VALUES (@cToID, ISNULL(@cCartonType,''), @cCartonCount, @cLottable02)
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 256813
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Ins dropdetail fail'
                        GOTO RollBackTran_6816
                     END CATCH
                  END
                  ELSE
                  BEGIN
                     SET @nErrNo = 256814
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Carton Type already exists'
                     GOTO RollBackTran_6816
                  END

                  -- Loop LOTxLOTxID
                  FETCH NEXT FROM @curLLI INTO @cLOT, @nQTY_LLI
                  SET @nQTY_Bal = @nQTY_Move
                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     -- Calc LLI.QTY to take
                     IF @nQTY_LLI > @nQTY_Bal
                        SET @nQTY = @nQTY_Bal -- LLI had enuf QTY, so charge all the balance into this LLI
                     ELSE
                        SET @nQTY = @nQTY_LLI -- LLI not enuf QTY, take all QTY avail of this LLI

                     EXECUTE rdt.rdt_Move
                        @nMobile     = @nMobile,
                        @cLangCode   = @cLangCode,
                        @nErrNo      = @nErrNo  OUTPUT,
                        @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
                        @cSourceType = 'rdt_515ExtScn02',
                        @cStorerKey  = @cStorerKey,
                        @cFacility   = @cFacility,
                        @cFromLOC    = @cFromLOC,
                        @cToLOC      = @cToLOC,
                        @cFromID     = @cID,         -- NULL means not filter by ID. Blank is a valid ID
                        @cToID       = @cToID,       -- NULL means not changing ID. Blank consider a valid ID
                        @cSKU        = @cSKU,
                        @nQTY        = @nQTY,
                        @cFromLOT    = @cLOT

                     IF @nErrNo <> 0
                     BEGIN
                        CLOSE @curLLI
                        DEALLOCATE @curLLI
                        GOTO RollBackTran_6816
                     END
                     ELSE
                     BEGIN
                        -- EventLog
                        EXEC RDT.rdt_STD_EventLog
                        @cActionType   = '4', -- Move
                        @cUserID       = @cUserName,
                        @nMobileNo     = @nMobile,
                        @nFunctionID   = @nFunc,
                        @cFacility     = @cFacility,
                        @cStorerKey    = @cStorerkey,
                        @cLocation     = @cFromLOC,
                        @cToLocation   = @cToLOC,
                        @cID           = @cFromID,
                        @cToID         = @cToID,
                        @cSKU          = @cSKU,
                        @cUOM          = @cMUOM_Desc,
                        @nQTY          = @nQTY,
                        @cLot          = @cLOT,
                        @nStep         = @nStep
                     END

                     SET @nQTY_Bal = @nQTY_Bal - @nQTY  -- Reduce balance
                     IF @nQTY_Bal <= 0
                        BREAK

                     FETCH NEXT FROM @curLLI INTO @cLOT, @nQTY_LLI
                  END

                  -- Still have balance, means no LLI changed
                  IF @nQTY_Bal <> 0
                  BEGIN
                     SET @nErrNo = 256816
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Inv changed'
                     CLOSE @curLLI
                     DEALLOCATE @curLLI
                     GOTO RollBackTran_6816
                  END

                  COMMIT TRAN rdt_512ExtScn02_6816 -- Only commit change made in here
                  WHILE @@TRANCOUNT > @nTranCount
                     COMMIT TRAN

                  SET @cOutField01 = @cToLOC

                  -- Go to next screen
                  SET @nAfterScn = 1047
                  SET @nAfterStep = 8
               END  -- Option1

               IF @cOption = '2'
               BEGIN
                  GOTO Scn_6816_Fail -- same logic, go back to new toLoc screen
               END -- Option2
            END --Enter

            GOTO Quit

            RollBackTran_6816:
            BEGIN
               ROLLBACK TRAN rdt_512ExtScn02_6817
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
            END

            Scn_6816_Fail:
            BEGIN
               SET @cFieldAttr01 = ''
               SET @cFieldAttr02 = ''
               SET @cFieldAttr03 = ''
               SET @cFieldAttr04 = ''
               SET @cFieldAttr05 = ''
               SET @cFieldAttr06 = ''
               SET @cFieldAttr07 = ''
               SET @cFieldAttr08 = ''
               SET @cFieldAttr09 = ''
               SET @cFieldAttr10 = ''
               SET @cFieldAttr11 = ''
               SET @cFieldAttr12 = ''
               SET @cFieldAttr13 = ''
               SET @cFieldAttr14 = ''
               SET @cFieldAttr15 = ''

               -- Prep ToLOC screen var
               --SET @cToLOC = ''
               SET @cOutField01 = @cFromLOC
               SET @cOutField02 = @cID
               SET @cOutField03 = @cSKU
               SET @cOutField04 = SUBSTRING( @cSKUDescr, 1, 20)   -- SKU desc 1
               SET @cOutField05 = SUBSTRING( @cSKUDescr, 21, 20)  -- SKU desc 2
               IF @cPUOM_Desc = ''
               BEGIN
                  SET @cOutField06 = '' -- @cPUOM_Desc
                  SET @cOutField07 = '' -- @nPQTY_Avail
                  SET @cFieldAttr07 = 'O'
               END
               ELSE
               BEGIN
                  SET @cOutField06 = @cPUOM_Desc
                  SET @cOutField07 = CAST( @nPQTY_Move AS NVARCHAR( 5))
               END
               SET @cOutField08 = @cMUOM_Desc
               SET @cOutField09 = CAST( @nMQTY_Move AS NVARCHAR( 5))
               SET @cOutField10 = @cToID
               SET @cOutField11 = ''
               
               SET @nAfterStep = 99 -- Go to new toLoc if RealloQty > 0
               SET @nAfterScn = 6817
            END

            GOTO Quit

            GOTO Quit
         END --6816

      END--Step99
   END -- 515

   GOTO Quit

   Quit:
      --update fields used in extscn but not in base
      BEGIN TRY
         UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET 
            C_String1   = @cCartonType,
            C_String2   = @cCartonCount,
            C_Integer1  = @nPreAlloQty
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

GRANT EXECUTE ON RDT.rdt_515ExtScn02 TO NSQL
GO


