
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1764ExtScn06                                       */
/* Copyright      : Maersk WMS                                             */
/* Customer       : JCB US                                                 */
/*                                                                         */
/* Purpose: Extended Screen SP for TM Replenishment (Func 1764) Step 3    */
/*          (FromID screen). Intercepts the FromID step to support:        */
/*           - "99" input -> navigate to Reason Code screen (St99)         */
/*           - ESC on FromID -> navigate to Reason Code screen (St99)      */
/*           - Valid FromID -> validate, SwapID if needed, to ToLOC step   */
/*                                                                         */
/* Registered as: RDTConfig ExtScnSP for Func 1764, JCB US StorerKey      */
/*                                                                         */
/* Modifications log:                                                      */
/* Date         Author    Ver.    Purposes                                 */
/* 2026-08-13   NYE018    1.0.0   FCR-14962 Created                        */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764ExtScn06] (
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
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT,
   @cUDF30  NVARCHAR( MAX)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nCurrentStep        INT,
      @nCurrentScn         INT,
      @nTranCount          INT,
      @cUserName           NVARCHAR( 18),
      -- Task fields
      @cTaskDetailKey      NVARCHAR( 10),
      @cNewTaskDetailKey   NVARCHAR( 10),
      @cDropID             NVARCHAR( 20),
      @cFromID             NVARCHAR( 18),
      @cSuggID             NVARCHAR( 18),
      @cSuggFromLOC        NVARCHAR( 10),
      @cSuggToLOC          NVARCHAR( 10),
      @cPickMethod         NVARCHAR( 10),
      @cListKey            NVARCHAR( 10),
      @cLocDescr           NVARCHAR( 20),
      @cNewSuggToLOC       NVARCHAR( 10),
      -- Config
      @cSwapTaskSP         NVARCHAR( 20),
      @cDecodeSP           NVARCHAR( 20),
      @cExtendedUpdateSP   NVARCHAR( 20),
      @cSuggToLOCSP        NVARCHAR( 20),
      @cLocShowDescr       NVARCHAR(  1),
      @cDefaultToLOC       NVARCHAR( 10),
      @cDefaultSuggToLOC   NVARCHAR( 10),
      @cMoveQTYAlloc       NVARCHAR(  1),
      -- Barcode / dynamic SQL
      @cBarcode            NVARCHAR( 60),
      @cSQL                NVARCHAR( MAX),
      @cSQLParam           NVARCHAR( MAX),
      -- Screen/step constants
      @nStep_FromLOC       INT,
      @nScn_FromLOC        INT,
      @nStep_FromID        INT,
      @nScn_FromID         INT,
      @nStep_ToLOC         INT,
      @nScn_ToLOC          INT,
      @nStep_Reason        INT,
      @nScn_Reason         INT,
      @nStep_99            INT

   SELECT
      @nStep_FromLOC = 2,  @nScn_FromLOC = 2681,
      @nStep_FromID  = 3,  @nScn_FromID  = 2682,
      @nStep_ToLOC   = 6,  @nScn_ToLOC   = 2685,
      @nStep_Reason  = 9,  @nScn_Reason  = 2109,
      @nStep_99      = 99

   SET @nTranCount = @@TRANCOUNT

   SELECT
      @nCurrentStep = Step,
      @nCurrentScn  = Scn,
      @cUserName    = UserName,
      @cSuggID      = V_ID
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1764 -- TM Replenishment
   BEGIN

      /******************************************************************************
         Call 1: End of Step_FromLOC -> main SP about to show FromID screen.
         Redirect to step 99 so user input on FromID bypasses main SP's Step_FromID
         and routes directly here (call 2) for full control.
         Main SP already set outfields 01-05 for the FromID screen.
      ******************************************************************************/
      IF @nCurrentStep = @nStep_FromLOC AND @nInputKey = 1 -- ENTER on Step_FromLOC
      BEGIN
         SET @nAfterStep = @nStep_99
         -- @nAfterScn stays as @nScn_FromID (2682), already set by main SP
      END

      /******************************************************************************
         Call 2: User input on the FromID screen (via step 99).
         Handle the full FromID step logic:
           - ESC              -> Reason Code screen
           - ENTER "99"       -> Reason Code screen
           - ENTER valid ID   -> validate, SwapID if needed, -> ToLOC screen
      ******************************************************************************/
      ELSE IF @nCurrentStep = @nStep_99 AND @nCurrentScn = @nScn_FromID -- User input on FromID screen (via step 99)
      BEGIN
         SELECT @cTaskDetailKey = Value FROM @tExtScnData WHERE Variable = '@cTaskDetailKey'
         SELECT @cDropID        = Value FROM @tExtScnData WHERE Variable = '@cDropID'
         SET @cTaskDetailKey = ISNULL(@cTaskDetailKey, '')
         SET @cDropID        = ISNULL(@cDropID, '')

         -- Load task detail (@cSuggID already restored from RDTMOBREC.V_ID above)
         SELECT
            @cPickMethod  = PickMethod,
            @cSuggFromLOC = FromLOC,
            @cSuggToLOC   = ToLOC,
            @cDropID      = ISNULL(DropID, @cDropID),
            @cListKey     = ListKey
         FROM dbo.TaskDetail WITH(NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey

         -- Read config
         SET @cSwapTaskSP       = rdt.RDTGetConfig(@nFunc, 'SwapTaskSP',        @cStorerKey)
         SET @cDecodeSP         = rdt.RDTGetConfig(@nFunc, 'DecodeSP',          @cStorerKey)
         SET @cExtendedUpdateSP = rdt.RDTGetConfig(@nFunc, 'ExtendedUpdateSP',  @cStorerKey)
         SET @cSuggToLOCSP      = rdt.RDTGetConfig(@nFunc, 'SuggToLOCSP',       @cStorerKey)
         SET @cLocShowDescr     = rdt.RDTGetConfig(@nFunc, 'LocShowDescr',       @cStorerKey)
         SET @cDefaultToLOC     = rdt.RDTGetConfig(@nFunc, 'DefaultToLOC',       @cStorerKey)
         SET @cDefaultSuggToLOC = rdt.RDTGetConfig(@nFunc, 'DefaultSuggToLOC',   @cStorerKey)
         SET @cMoveQTYAlloc     = rdt.RDTGetConfig(@nFunc, 'MoveQTYAlloc',       @cStorerKey)

         IF @cSwapTaskSP       = '0' SET @cSwapTaskSP       = ''
         IF @cDecodeSP         = '0' SET @cDecodeSP         = ''
         IF @cExtendedUpdateSP = '0' SET @cExtendedUpdateSP = ''
         IF @cSuggToLOCSP      = '0' SET @cSuggToLOCSP      = ''
         IF @cLocShowDescr     = '0' SET @cLocShowDescr     = ''
         IF @cDefaultToLOC     = '0' SET @cDefaultToLOC     = ''
         IF @cDefaultSuggToLOC = '0' SET @cDefaultSuggToLOC = ''
         IF @cMoveQTYAlloc     = '0' SET @cMoveQTYAlloc     = ''

         IF @nInputKey = 0 -- ESC: go to Reason Code screen
         BEGIN
            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField04 = ''
            SET @cOutField05 = ''
            SET @cOutField09 = ''
            SET @nAfterScn  = @nScn_Reason
            SET @nAfterStep = @nStep_Reason
         END
         ELSE IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cBarcode = ISNULL(@cInField05, '')  -- raw scan, up to 60 chars
            SET @cFromID  = @cBarcode               -- truncates to 18; decode will overwrite if configured

            -- "99" shortcut: go to Reason Code screen
            IF @cBarcode = '99'
            BEGIN
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''
               SET @cOutField05 = ''
               SET @cOutField09 = ''
               SET @nAfterScn  = @nScn_Reason
               SET @nAfterStep = @nStep_Reason
               GOTO Quit
            END

            -- Barcode decode
            IF @cDecodeSP <> ''
            BEGIN
               IF @cDecodeSP = '1' -- Standard decode
               BEGIN
                  EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep_99, @nInputKey,
                     @cStorerKey, @cFacility, @cBarcode,
                     @cID     = @cFromID OUTPUT,
                     @nErrNo  = @nErrNo  OUTPUT,
                     @cErrMsg = @cErrMsg OUTPUT,
                     @cType   = 'ID'
               END
               ELSE IF EXISTS(SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM(@cDecodeSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cBarcode,' +
                     ' @cFromID OUTPUT, @cSKU OUTPUT, @nQTY OUTPUT, @cDropID OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                  SET @cSQLParam =
                     '@nMobile        INT,           ' +
                     '@nFunc          INT,           ' +
                     '@cLangCode      NVARCHAR( 3),  ' +
                     '@nStep          INT,           ' +
                     '@nInputKey      INT,           ' +
                     '@cTaskdetailKey NVARCHAR( 10), ' +
                     '@cBarcode       NVARCHAR( 60), ' +
                     '@cFromID        NVARCHAR( 18)  OUTPUT, ' +
                     '@cSKU           NVARCHAR( 20)  OUTPUT, ' +
                     '@nQTY           INT            OUTPUT, ' +
                     '@cDropID        NVARCHAR( 20)  OUTPUT, ' +
                     '@nErrNo         INT            OUTPUT, ' +
                     '@cErrMsg        NVARCHAR( 20)  OUTPUT'
                  DECLARE
                     @cDecodeSKU  NVARCHAR( 20),
                     @nDecodeQTY  INT
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep_99, @nInputKey,
                     @cTaskDetailKey, @cBarcode,
                     @cFromID OUTPUT, @cDecodeSKU OUTPUT, @nDecodeQTY OUTPUT,
                     @cDropID OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
               END

               IF @nErrNo <> 0
               BEGIN
                  SET @cFromID = ''
                  SET @cOutField05 = ''
                  GOTO Quit
               END
            END

            -- SwapID if scanned ID differs from suggested ID
            IF @cFromID <> @cSuggID
            BEGIN
               IF @cSwapTaskSP = ''
               BEGIN
                  SET @nErrNo = 278001
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- IDNotMatch
                  SET @cOutField05 = ''
                  GOTO Quit
               END

               IF EXISTS(SELECT 1 FROM sys.objects WHERE name = @cSwapTaskSP AND type = 'P')
               BEGIN
                  SET @cNewTaskDetailKey = ''
                  SET @cSQL = 'EXEC rdt.' + RTRIM(@cSwapTaskSP) +
                     ' @nMobile, @nFunc, @cLangCode, @cTaskDetailKey, @cFromID,' +
                     ' @cNewTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                  SET @cSQLParam =
                     '@nMobile           INT,           ' +
                     '@nFunc             INT,           ' +
                     '@cLangCode         NVARCHAR( 3),  ' +
                     '@cTaskDetailKey    NVARCHAR( 10), ' +
                     '@cFromID           NVARCHAR( 18), ' +
                     '@cNewTaskDetailKey NVARCHAR( 10)  OUTPUT, ' +
                     '@nErrNo            INT            OUTPUT, ' +
                     '@cErrMsg           NVARCHAR( 20)  OUTPUT'

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @cTaskDetailKey, @cFromID,
                     @cNewTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                  BEGIN
                     SET @cOutField05 = ''
                     GOTO Quit
                  END

                  IF ISNULL(@cNewTaskDetailKey, '') <> ''
                     SET @cTaskDetailKey = @cNewTaskDetailKey

                  -- Reload task after swap
                  SELECT
                     @cPickMethod  = PickMethod,
                     @cSuggID      = FromID,
                     @cSuggFromLOC = FromLOC,
                     @cSuggToLOC   = ToLOC,
                     @cDropID      = ISNULL(DropID, @cDropID),
                     @cListKey     = ListKey
                  FROM dbo.TaskDetail WITH(NOLOCK)
                  WHERE TaskDetailKey = @cTaskDetailKey
               END
            END

            -- Check QTYReplen / QTYAllocated for Full Pallet
            IF @cPickMethod = 'FP'
            BEGIN
               IF EXISTS( SELECT 1
                  FROM dbo.LOTxLOCxID WITH(NOLOCK)
                  WHERE LOC = @cSuggFromLOC
                     AND ID  = @cFromID
                     AND (QTYReplen > 0 OR
                          QTYAllocated > (CASE WHEN @cMoveQTYAlloc = '1' THEN QTYAllocated ELSE 0 END)))
               BEGIN
                  SET @nErrNo = 278002
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- QTYAllocReplen
                  SET @cOutField05 = ''
                  GOTO Quit
               END
            END

            -- Extended update (same as main SP Step_FromID)
            IF @cExtendedUpdateSP <> ''
            BEGIN
               IF EXISTS(SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskDetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                  SET @cSQLParam =
                     '@nMobile         INT,           ' +
                     '@nFunc           INT,           ' +
                     '@cLangCode       NVARCHAR( 3),  ' +
                     '@nStep           INT,           ' +
                     '@cTaskDetailKey  NVARCHAR( 10), ' +
                     '@nErrNo          INT            OUTPUT, ' +
                     '@cErrMsg         NVARCHAR( 20)  OUTPUT'

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep_99, @cTaskDetailKey,
                     @nErrNo OUTPUT, @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                  BEGIN
                     SET @cOutField05 = ''
                     GOTO Quit
                  END
               END
            END

            -- Get custom suggested ToLOC if configured
            IF @cSuggToLOCSP <> ''
            BEGIN
               IF EXISTS(SELECT 1 FROM sys.objects WHERE name = @cSuggToLOCSP AND type = 'P')
               BEGIN
                  SET @cNewSuggToLOC = ''
                  SET @cSQL = 'EXEC rdt.' + RTRIM(@cSuggToLOCSP) +
                     ' @nMobile, @nFunc, @cLangCode, @cUserName, @cTaskDetailKey,' +
                     ' @cSuggToLOC, @cNewSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                  SET @cSQLParam =
                     '@nMobile        INT,           ' +
                     '@nFunc          INT,           ' +
                     '@cLangCode      NVARCHAR( 3),  ' +
                     '@cUserName      NVARCHAR( 18), ' +
                     '@cTaskDetailKey NVARCHAR( 10), ' +
                     '@cSuggToLOC     NVARCHAR( 10), ' +
                     '@cNewSuggToLOC  NVARCHAR( 10)  OUTPUT, ' +
                     '@nErrNo         INT            OUTPUT, ' +
                     '@cErrMsg        NVARCHAR( 20)  OUTPUT'

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @cUserName, @cTaskDetailKey,
                     @cSuggToLOC, @cNewSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                  BEGIN
                     SET @cOutField05 = ''
                     GOTO Quit
                  END

                  IF ISNULL(@cNewSuggToLOC, '') <> ''
                     SET @cSuggToLOC = @cNewSuggToLOC
               END
            END

            -- Prepare ToLOC screen outfields
            SELECT @cLocDescr = SUBSTRING(Descr, 1, 20)
            FROM dbo.LOC WITH(NOLOCK)
            WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
            IF ISNULL(@cLocDescr, '') = ''
               SET @cLocDescr = @cSuggFromLOC

            SET @cOutField01 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END

            SELECT @cLocDescr = SUBSTRING(Descr, 1, 20)
            FROM dbo.LOC WITH(NOLOCK)
            WHERE Facility = @cFacility
               AND ((@cDefaultSuggToLOC <> '' AND LOC = @cDefaultSuggToLOC) OR (LOC = @cSuggToLOC))
            IF ISNULL(@cLocDescr, '') = ''
               SET @cLocDescr = CASE WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC ELSE @cSuggToLOC END

            SET @cOutField02 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr
                                    WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC
                                    ELSE @cSuggToLOC END
            SET @cOutField03 = CASE WHEN @cDefaultToLOC = '1' THEN @cSuggToLOC
                                    WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC
                                    ELSE '' END
            SET @cOutField10 = ''

            SET @nAfterScn  = @nScn_ToLOC
            SET @nAfterStep = @nStep_ToLOC
         END
      END

      /******************************************************************************
         Call 3: User pressed ESC on the Reason Code screen -> return to FromID.
         On ENTER (reason code submitted), let main SP handle navigation.
      ******************************************************************************/
      ELSE IF @nCurrentStep = @nStep_Reason
      BEGIN
         IF @nInputKey = 0 -- ESC from reason code: back to FromID screen
         BEGIN
            -- Load task to restore FromID screen outfields
            SELECT @cTaskDetailKey = Value FROM @tExtScnData WHERE Variable = '@cTaskDetailKey'
            SELECT @cDropID        = Value FROM @tExtScnData WHERE Variable = '@cDropID'
            SET @cTaskDetailKey = ISNULL(@cTaskDetailKey, '')

            -- @cSuggID already restored from RDTMOBREC.V_ID above
            SELECT
               @cPickMethod  = PickMethod,
               @cSuggFromLOC = FromLOC,
               @cDropID      = ISNULL(DropID, ISNULL(@cDropID, ''))
            FROM dbo.TaskDetail WITH(NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey

            SET @cLocShowDescr = rdt.RDTGetConfig(@nFunc, 'LocShowDescr', @cStorerKey)
            IF @cLocShowDescr = '0' SET @cLocShowDescr = ''

            SELECT @cLocDescr = SUBSTRING(Descr, 1, 20)
            FROM dbo.LOC WITH(NOLOCK)
            WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
            IF ISNULL(@cLocDescr, '') = ''
               SET @cLocDescr = @cSuggFromLOC

            SET @cOutField01 = @cPickMethod
            SET @cOutField02 = @cDropID
            SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
            SET @cOutField04 = @cSuggID
            SET @cOutField05 = '' -- clear FromID input
            SET @cOutField10 = ''

            SET @nAfterScn  = @nScn_FromID
            SET @nAfterStep = @nStep_99
         END
         -- ENTER: reason code was submitted; let main SP control navigation
      END

   END -- IF @nFunc = 1764

   GOTO Quit

Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1764ExtScn06 TO NSQL
GO
