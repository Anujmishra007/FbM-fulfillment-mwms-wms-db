SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_1628ExtScn01                                      */
/* Purpose: TOLOC screen for lane assignment after Close Case             */
/*                                                                        */
/* Called from: rdtfnc_Cluster_Pick via Step_99                           */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2026-05-26 1.0    NYE018     FCR-12622. Created                        */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1628ExtScn01] (
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

   DECLARE
      @nCurrentStep        INT,
      @nCurrentScn         INT,
      @nTranCount          INT,
      @cUserName           NVARCHAR( 18),
      @cDropID             NVARCHAR( 20),
      @cOption             NVARCHAR( 1),
      @cWaveKey            NVARCHAR( 10),
      @cLoadKey            NVARCHAR( 10),
      @cOrderKey           NVARCHAR( 10),
      @cSuggestedTOLOC     NVARCHAR( 10),
      @cScannedTOLOC       NVARCHAR( 10),
      @cFromLOC            NVARCHAR( 10),
      @cSKU                NVARCHAR( 20),
      @cLOT                NVARCHAR( 10),
      @nQty                INT,
      @cID                 NVARCHAR( 20),
      @cPickDetailKey      NVARCHAR( 18)

   SELECT
      @nCurrentStep  = Step,
      @nCurrentScn   = Scn,
      @cUserName     = UserName,
      @cWaveKey      = V_String1,
      @cLoadKey      = V_LoadKey,
      @cDropID       = V_DropID
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SET @nErrNo = 0

   -- Get data from tExtScnData
   SELECT @cOption = Value FROM @tExtScnData WHERE Variable = '@cOption'
   SELECT @cDropID = ISNULL(Value, @cDropID) FROM @tExtScnData WHERE Variable = '@cDropID'

   IF @nFunc = 1628
   BEGIN
      -- When coming from Close Case screen (1886, Step 15) with Option 1, redirect to TOLOC screen
      IF @nStep = 10 AND @nInputKey = 1 AND @cOption = '1'
      BEGIN
         -- Fetch suggested TOLOC from LOADPLANLANEDETAIL
         SELECT TOP 1 @cOrderKey = WD.OrderKey
         FROM dbo.WAVEDETAIL WD WITH (NOLOCK)
         WHERE WD.WaveKey = @cWaveKey

         IF @cOrderKey IS NOT NULL
         BEGIN
            SELECT @cLoadKey = O.LoadKey
            FROM dbo.ORDERS O WITH (NOLOCK)
            WHERE O.OrderKey = @cOrderKey

            IF @cLoadKey IS NOT NULL AND ISNULL(@cLoadKey, '') <> ''
            BEGIN
               SELECT TOP 1 @cSuggestedTOLOC = LPLD.Loc
               FROM dbo.LOADPLANLANEDETAIL LPLD WITH (NOLOCK)
               WHERE LPLD.LoadKey = @cLoadKey
            END
         END

         IF ISNULL(@cSuggestedTOLOC, '') <> ''
         BEGIN
            -- Redirect to TOLOC screen
            SET @nAfterScn = 6894
            SET @nAfterStep = 99

            -- Set output fields for TOLOC screen
            SET @cOutField01 = @cSuggestedTOLOC  -- Suggested TOLOC (display)
            SET @cOutField02 = ''                 -- Input field for scanning

            -- Store suggested TOLOC in UDF for later validation
            SET @cUDF01 = @cSuggestedTOLOC

            GOTO Quit
         END
      END

      -- TOLOC Screen (6894) Logic
      IF @nCurrentStep = 99 AND @nCurrentScn = 6894
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cScannedTOLOC = @cInField02
            SET @cSuggestedTOLOC = @cOutField01

            -- If inventory already moved (user ESC from Print Label), skip move and go to Print Label
            IF @cUDF02 = 'MOVED'
            BEGIN
               SET @nAfterScn = 1885
               SET @nAfterStep = 13
               SET @cOutField01 = ''
               GOTO Quit
            END

            -- Validate scanned location matches suggested location
            IF ISNULL(@cScannedTOLOC, '') = ''
            BEGIN
               SET @nErrNo = 268001
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- TOLOC Required
               GOTO Quit
            END

            -- No override allowed - must match suggested location
            IF @cScannedTOLOC <> @cSuggestedTOLOC
            BEGIN
               SET @nErrNo = 268002
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- LOC Mismatch
               GOTO Quit
            END

            -- Validate TOLOC exists
            IF NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cScannedTOLOC)
            BEGIN
               SET @nErrNo = 268003
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid LOC
               GOTO Quit
            END

            -- Begin transaction for inventory movement
            SET @nTranCount = @@TRANCOUNT
            IF @@TRANCOUNT = 0
               BEGIN TRAN
            ELSE
               SAVE TRAN rdt_1628ExtScn01_TOLOC

            BEGIN TRY
               -- Cursor through picked inventory for this DropID
               DECLARE @curPickDetail CURSOR
               SET @curPickDetail = CURSOR LOCAL FAST_FORWARD FOR
                  SELECT PD.PickDetailKey, PD.SKU, PD.LOT, PD.LOC, PD.Qty, PD.ID
                  FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.DropID = @cDropID
                     AND PD.[Status] = '5'  -- Picked status
                     AND PD.Qty > 0

               OPEN @curPickDetail
               FETCH NEXT FROM @curPickDetail INTO @cPickDetailKey, @cSKU, @cLOT, @cFromLOC, @nQty, @cID

               WHILE @@FETCH_STATUS = 0
               BEGIN
                  -- Use rdt_Move SP to perform the inventory movement
                  EXEC RDT.rdt_Move
                     @nMobile     = @nMobile,
                     @cLangCode   = @cLangCode,
                     @nErrNo      = @nErrNo OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT,
                     @cSourceType = 'rdt_1628ExtScn01',
                     @cStorerKey  = @cStorerKey,
                     @cFacility   = @cFacility,
                     @cFromLOC    = @cFromLOC,
                     @cToLOC      = @cScannedTOLOC,
                     @cFromID     = @cID,
                     @cToID       = @cDropID,
                     @cSKU        = @cSKU,
                     @nQTY        = @nQty,
                     @nQTYPick    = @nQty,
                     @cFromLOT    = @cLOT,
                     @nFunc       = @nFunc,
                     @cDropID     = @cDropID

                  IF @nErrNo <> 0
                  BEGIN
                     CLOSE @curPickDetail
                     DEALLOCATE @curPickDetail
                     GOTO ROLLBACK_TOLOC
                  END

                  -- Update PICKDETAIL with new location (use PickDetailKey for exact row)
                  BEGIN TRY
                     UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
                     SET LOC = @cScannedTOLOC,
                         EditDate = GETDATE(),
                         EditWho = @cUserName
                     WHERE PickDetailKey = @cPickDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 268005
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PD Update Fail
                     CLOSE @curPickDetail
                     DEALLOCATE @curPickDetail
                     GOTO ROLLBACK_TOLOC
                  END CATCH

                  FETCH NEXT FROM @curPickDetail INTO @cPickDetailKey, @cSKU, @cLOT, @cFromLOC, @nQty, @cID
               END

               CLOSE @curPickDetail
               DEALLOCATE @curPickDetail

            END TRY
            BEGIN CATCH
               SET @nErrNo = 268004
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Move Failed
               CLOSE @curPickDetail
               DEALLOCATE @curPickDetail

               GOTO ROLLBACK_TOLOC
            END CATCH

            -- Commit transaction
            IF @nTranCount = 0
               COMMIT TRANSACTION

            -- Mark inventory as moved (prevent re-move on ESC/ENTER)
            SET @cUDF02 = 'MOVED'

            -- Go to Print Label screen
            SET @nAfterScn = 1885
            SET @nAfterStep = 13
            SET @cOutField01 = ''

            GOTO Quit

            ROLLBACK_TOLOC:
               IF @nTranCount = 0
                  ROLLBACK TRANSACTION
               ELSE
                  ROLLBACK TRANSACTION rdt_1628ExtScn01_TOLOC
         END
         ELSE IF @nInputKey = 0 -- ESC - Go back to Close Case screen
         BEGIN
            SET @nAfterScn = 1886
            SET @nAfterStep = 15
            SET @cOutField01 = ''
            GOTO Quit
         END
      END

      -- Print Label Screen (1885, Step 13) - ESC should go to TOLOC screen
      IF @nCurrentStep = 13 AND @nCurrentScn = 1885
      BEGIN
         IF @nInputKey = 0 -- ESC
         BEGIN
            -- Fetch suggested TOLOC again for the screen
            SELECT TOP 1 @cOrderKey = WD.OrderKey
            FROM dbo.WAVEDETAIL WD WITH (NOLOCK)
            WHERE WD.WaveKey = @cWaveKey

            IF @cOrderKey IS NOT NULL
            BEGIN
               SELECT @cLoadKey = O.LoadKey
               FROM dbo.ORDERS O WITH (NOLOCK)
               WHERE O.OrderKey = @cOrderKey

               IF @cLoadKey IS NOT NULL
               BEGIN
                  SELECT TOP 1 @cSuggestedTOLOC = LPLD.Loc
                  FROM dbo.LOADPLANLANEDETAIL LPLD WITH (NOLOCK)
                  WHERE LPLD.LoadKey = @cLoadKey
               END
            END

            IF ISNULL(@cSuggestedTOLOC, '') <> ''
            BEGIN
               SET @nAfterScn = 6894
               SET @nAfterStep = 99
               SET @cOutField01 = @cSuggestedTOLOC
               SET @cOutField02 = ''
               SET @cUDF01 = @cSuggestedTOLOC
               GOTO Quit
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

GRANT EXECUTE ON RDT.rdt_1628ExtScn01 TO NSQL
GO
