SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Store procedure: rdt_957ExtScn04                                          */
/* Copyright: Maersk WMS                                                     */
/* Customer: Levis UAE                                                       */
/*                                                                           */
/* Purpose:                                                                  */
/*                                                                           */
/* Date       Rev  Author   Purposes                                         */
/* 2025-10-15 1.0  Cuize    FCR-7737 Copy From rdt_957ExtScn02 For UAE       */
/* 2026-03-09 1.1  NYE018   FCR-10631 make ToLoc mandatory                   */
/*****************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_957ExtScn04] (
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
   @nAction          INT, --0 Jump Screen, 1 Prepare output fields .....
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

   DECLARE
      @nCurrentStep        INT,
      @nCurrentScn         INT,
      @nRowCount           INT,
      @nTranCount          INT,

      @cExtendedValidateSP NVARCHAR( 20),
      @cExtendedUpdateSP   NVARCHAR( 20),
      @cExtendedInfoSP     NVARCHAR( 20),

      @cID                 NVARCHAR( 20),
      @cUCCNo              NVARCHAR( 18),
      @cUCCAllocated       NVARCHAR( 18),
      @cPickSlipNo         NVARCHAR( 10),
      @cSKU                NVARCHAR( 20),
      @cDropID             NVARCHAR( 20),
      @cSwapUCCID          NVARCHAR( 20),
      @cSwapUCCLot         NVARCHAR( 10),
      @cOption             NVARCHAR( 1),
      @cUCCStatus          NVARCHAR( 1),
      @cSuggestUCC         NVARCHAR( 1),
      @cSuggestLoc         NVARCHAR( 10),
      @cToLoc              NVARCHAR( 10),
      @cToLocLoseUCC       NVARCHAR( 1), --V1.2
      @cUCCLoc             NVARCHAR( 10),
      @cUCCID              NVARCHAR( 18),
      @cLOT                NVARCHAR( 10),
      @cPickDetailKey      NVARCHAR( 18),
      @cUCCPicked          NVARCHAR( 10),
      @cToID               NVARCHAR( 20),
      @cPickZone           NVARCHAR( 10),
      @cOrderKey           NVARCHAR( 10),
      @cOrderLineNumber    NVARCHAR( 5),

      @nUCCQTY             INT,
      @nDropIdQty          INT,
      @nQty                INT,
      @nQty1               INT,
      @nDropIDScannedQty   INT,
      @cMoveQTYAlloc       NVARCHAR( 1),
      @cMoveQTYPick        NVARCHAR( 1),
      @cPickConfirmStatus  NVARCHAR( 1),
      @cPacKKey            NVARCHAR( 10),
      @nCaseCnt            INT,

      @cOrderType          NVARCHAR( 10),
      @cOrderConsigneeKey  NVARCHAR( 15),
      @cPickDetailUOM      NVARCHAR( 10),
      @nPackFlag           INT

   SELECT 
      @nCurrentStep       = Step,
      @nCurrentScn         = Scn,
      @cPickSlipNo         = V_PickSlipNo,
      @cPickZone           = V_Zone,
      @cDropID             = V_String4,
      @cExtendedValidateSP = V_String21,
      @cExtendedUpdateSP   = V_String22,
      @cExtendedInfoSP     = V_String23,

      @cSuggestUCC         = C_String2
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Get storer config
   SET @cMoveQTYAlloc = rdt.rdtGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
   SET @cMoveQTYPick = rdt.rdtGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   IF @cPickConfirmStatus NOT IN ( '3', '5')
      SET @cPickConfirmStatus = '5'

   -- Check move alloc, but picked
   IF @cMoveQTYAlloc = '1' AND @cPickConfirmStatus = '5'
   BEGIN
      SET @nErrNo = 249213
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   -- Check move picked, but not pick confirm
   IF @cMoveQTYPick = '1' AND @cPickConfirmStatus < '5'
   BEGIN
      SET @nErrNo = 249214
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   SET @nTranCount = @@TRANCOUNT

   IF @nFunc = 957  --Pick Case
   BEGIN
      IF @nCurrentStep = 2 -- DropID
      BEGIN
         IF @nAction = 0
         BEGIN
            IF @nInputKey = 1 --Jump to UCC 6714
            BEGIN
               SET @cDropID = @cInField03

               IF ISNULL(@cDropID,'') = ''
               BEGIN
                  SET @nErrNo = 249225
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NeedDropID
                  GOTO STEP_2_Failed
               END

               SELECT TOP 1
                  @cUCCNo     = ucc.UCCNo,
                  @cSKU       = pkd.Sku,
                  @cSuggestLoc  = ucc.Loc
               FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
                  INNER JOIN dbo.PICKHEADER pkh WITH(NOLOCK) ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                  INNER JOIN dbo.UCC ucc WITH(NOLOCK) ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
                  INNER JOIN dbo.SKU sku WITH(NOLOCK) ON pkd.StorerKey = sku.StorerKey AND pkd.Sku = sku.Sku
               WHERE pkh.StorerKey = @cStorerKey
                 AND pkh.PickHeaderKey = @cPickSlipNo
                 AND pkd.ID = @cDropID
                 AND ucc.Status = '3'
                 AND pkd.UOM = '2' --Only accept UOM = 2

               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 249222
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC NOT FOUND
                  GOTO STEP_2_Failed
               END

               SELECT @nDropIdQty = SUM(pkd.Qty)
               FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
                  INNER JOIN dbo.PICKHEADER pkh WITH(NOLOCK) ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                  INNER JOIN dbo.UCC ucc WITH(NOLOCK) ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
                  INNER JOIN dbo.SKU sku WITH(NOLOCK) ON pkd.StorerKey = sku.StorerKey AND pkd.Sku = sku.Sku
               WHERE pkh.StorerKey = @cStorerKey
                 AND pkh.PickHeaderKey = @cPickSlipNo
                 AND pkd.ID = @cDropID
                 AND ucc.Status = '3'
                 AND pkd.UOM = '2' --Only accept UOM = 2

               SELECT @nDropIDScannedQty = SUM(pkd.Qty)
               FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
                  INNER JOIN dbo.PICKHEADER pkh WITH(NOLOCK) ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                  INNER JOIN dbo.UCC ucc WITH(NOLOCK) ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
                  INNER JOIN dbo.SKU sku WITH(NOLOCK) ON pkd.StorerKey = sku.StorerKey AND pkd.Sku = sku.Sku
               WHERE pkh.StorerKey = @cStorerKey
                 AND pkh.PickHeaderKey = @cPickSlipNo
                 AND pkd.ID = @cDropID
                 AND ((ucc.Status = '3' AND ISNULL(ucc.Userdefined08, '') = '1')
                  OR ucc.Status = '5')


               SELECT @cPacKKey = PackKey
               FROM dbo.SKU WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                 AND SKU = @cSKU

               SELECT @nCaseCnt = CaseCnt
               FROM dbo.Pack WITH (NOLOCK)
               WHERE PackKey = @cPackKey

               IF @nCaseCnt > 0
               BEGIN
                  SET @nQTY = @nDropIdQty / @nCaseCnt
                  SET @nQty1 = ISNULL(@nDropIDScannedQty, 0) / @nCaseCnt
               END
               ELSE
               BEGIN
                  SET @nQty = @nDropIdQty
                  SET @nQty1 = ISNULL(@nDropIDScannedQty, 0)
               END

               SET @cSuggestUCC = rdt.RDTGetConfig( @nFunc, 'SuggestUCC', @cStorerKey)
               IF @cSuggestUCC = '0'
               BEGIN
                  SET @cSuggestUCC = ''
               END

               IF @cSuggestUCC = '1'
               BEGIN
                  SET @cOutField05 = @cUCCNo
               END
               ELSE
               SET @cOutField05 = ''

               SET @cOutField01 = @cSuggestLoc
               SET @cOutField02 = @cDropID

               SET @cOutField06 = CAST (@nQty AS NVARCHAR(5))
               SET @cOutField07 = CAST (@nQty1 AS NVARCHAR(5))

               SET @nAfterScn = 6714
               SET @nAfterStep = 99

               GOTO Quit

               STEP_2_Failed:
               SET @cOutField01 = @cPickSlipNo
               SET @cOutField03 = ''
               SET @cOutField13 = ''
               SET @nAfterStep = 2
               SET @nAfterScn = 5291
               GOTO Quit

            END
         END
      END
      ELSE IF @nCurrentStep = 99 -- Extended Screen
      BEGIN
         IF @nCurrentScn = 6717 -- Msg screen
         BEGIN
            SET @nAfterScn = 5290 --back to pickslip scn
            SET @nAfterStep = 1

            GOTO Quit
         END

         IF @nCurrentScn = 6714 -- UCCNo
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cUCCNo = TRIM(@cInField05)

               IF @cUCCNo = ''
               BEGIN
                  SET @nErrNo = 249203
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC Needed
                  GOTO Quit
               END

               EXEC RDT.rdtIsValidUCC @cLangCode, @nErrNo OUTPUT, @cErrMsg OUTPUT
                  ,@cUCCNo -- UCC
                  ,@cStorerKey
                  ,'13'    -- 1=Received, 3=Alloc, 4=Replen

               IF @nErrNo <> 0
               BEGIN
                  SET @nErrNo = 249204
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC
                  GOTO Quit
               END

               SET @nRowCount = 0

               SELECT 
                  @cUCCStatus    = ucc.Status,
                  @cUCCPicked    = ISNULL(ucc.Userdefined08, ''),
                  @cUCCLoc       = ucc.Loc,
                  @cUCCID        = pkd.ID,
                  @cSKU          = ucc.Sku,
                  @nUCCQTY       = ucc.Qty,
                  @cPickDetailKey = pkd.PickDetailKey,
                  @cPickDetailUOM = pkd.UOM
               FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
               INNER JOIN dbo.PICKHEADER pkh WITH(NOLOCK) ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
               INNER JOIN dbo.UCC ucc WITH(NOLOCK) ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
               WHERE pkh.StorerKey = @cStorerKey
                  AND pkh.PickHeaderKey = @cPickSlipNo
                  --AND pkd.ID = @cDropID
                  AND pkd.DropID = @cUCCNo

               SELECT @nRowCount = @@ROWCOUNT
               IF @nRowCount < 0 --UCC Not Found in this pickslip
               BEGIN
                  SET @nErrNo = 249224
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC Not Valid
                  GOTO Quit
               END

               IF @cUCCID <> @cDropID
               BEGIN--249227
                  SET @nErrNo = 249227
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCCIDNOTValid
                  GOTO Quit
               END

               IF ISNULL(@cPickDetailUOM, '') = '6'
               BEGIN--249223
                  SET @nErrNo = 249223
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCCUOMNotValid
                  GOTO Quit
               END


               SET @cSuggestLoc = @cOutField01

               IF @cUCCLoc <> @cSuggestLoc
               BEGIN
                  SET @nErrNo = 249226
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCCLOCNotValid
                  GOTO Quit
               END

               IF @cUCCStatus = '3' AND @cUCCPicked = '1'
               BEGIN
                  SET @nErrNo = 249218
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC Picked
                  GOTO Quit
               END

               IF @cUCCStatus <> '3'
               BEGIN
                  SET @nErrNo = 249205
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UCC
                  GOTO Quit
               END

               IF @nTranCount = 0
                  BEGIN TRANSACTION
               ELSE 
                  BEGIN TRANSACTION rdt_957ExtScn04_01

               BEGIN TRY

                  ---update UCC
                  UPDATE dbo.UCC WITH(ROWLOCK)
                  SET Userdefined08 = '1',
                     EditDate = GETDATE(),
                     EditWho  = SUSER_SNAME()
                  WHERE StorerKey = @cStorerKey
                     AND UCCNo = @cUCCNo
                     AND Status = '3'

                  UPDATE ord WITH(ROWLOCK)
                  SET ord.Status = '3'
                  FROM ORDERDETAIL ord
                  INNER JOIN dbo.PICKDETAIL pkd WITH(NOLOCK) ON ord.StorerKey = pkd.StorerKey AND ord.OrderKey = pkd.OrderKey AND ord.OrderLineNumber = pkd.OrderLineNumber
                  INNER JOIN dbo.PICKHEADER pkh WITH(NOLOCK) ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                  INNER JOIN dbo.UCC ucc WITH(NOLOCK) ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
                  WHERE pkh.StorerKey = @cStorerKey
                     AND pkh.PickHeaderKey = @cPickSlipNo
                     AND pkd.ID = @cDropID
                     AND pkd.Status < '5'
                     AND ucc.Status = '5'

                  UPDATE orm WITH(ROWLOCK)
                  SET orm.Status = '3',
                     EditDate = GETDATE(),
                     EditWho  = SUSER_SNAME()
                  FROM ORDERS orm
                  INNER JOIN 
                     (SELECT orm1.StorerKey, orm1.OrderKey, COUNT(1) AS totalOrderQty
                     FROM ORDERDETAIL ord1 WITH(NOLOCK)
                     INNER JOIN ORDERS orm1 WITH(NOLOCK) ON ord1.StorerKey = orm1.StorerKey AND ord1.OrderKey = orm1.OrderKey AND orm1.Status = '2'
                     INNER JOIN dbo.PICKDETAIL pkd1 WITH(NOLOCK) ON pkd1.StorerKey = ord1.StorerKey AND pkd1.OrderKey = ord1.OrderKey AND pkd1.OrderLineNumber = ord1.OrderLineNumber
                     INNER JOIN dbo.PICKHEADER pkh1 WITH(NOLOCK) ON pkd1.StorerKey = pkh1.StorerKey AND pkd1.OrderKey = pkh1.OrderKey
                     WHERE pkh1.StorerKey = @cStorerKey
                        AND pkh1.PickHeaderKey = @cPickSlipNo
                     GROUP BY orm1.StorerKey, orm1.OrderKey) AS orders
                     ON orm.StorerKey = orders.StorerKey AND orm.OrderKey = orders.OrderKey
                  LEFT JOIN 
                     (SELECT orm2.StorerKey, orm2.OrderKey, COUNT(1) AS pickedOrderQty
                     FROM ORDERDETAIL ord2 WITH(NOLOCK)
                     INNER JOIN ORDERS orm2 WITH(NOLOCK) ON ord2.StorerKey = orm2.StorerKey AND ord2.OrderKey = orm2.OrderKey AND orm2.Status = '2'
                     INNER JOIN dbo.PICKDETAIL pkd2 WITH(NOLOCK) ON pkd2.StorerKey = ord2.StorerKey AND pkd2.OrderKey = ord2.OrderKey AND pkd2.OrderLineNumber = ord2.OrderLineNumber
                     INNER JOIN dbo.PICKHEADER pkh2 WITH(NOLOCK) ON pkd2.StorerKey = pkh2.StorerKey AND pkd2.OrderKey = pkh2.OrderKey
                     WHERE pkh2.StorerKey = @cStorerKey
                        AND pkh2.PickHeaderKey = @cPickSlipNo
                        AND ord2.Status = '3'
                     GROUP BY orm2.StorerKey, orm2.OrderKey) AS pickedOrders
                     ON orm.StorerKey = pickedOrders.StorerKey AND orm.OrderKey = pickedOrders.OrderKey
                  WHERE orders.totalOrderQty = ISNULL(pickedOrders.pickedOrderQty, -1)
                     AND orm.Status = '2'

                  UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
                  SET Status = @cPickConfirmStatus,
                     EditDate = GETDATE(),
                     EditWho  = SUSER_SNAME()
                  WHERE StorerKey = @cStorerKey
                     AND PickDetailKey = @cPickDetailKey
               END TRY
               BEGIN CATCH
                  IF @nTranCount > 0
                     ROLLBACK TRAN rdt_957ExtScn04_01
                  ELSE
                     ROLLBACK TRAN

                  SET @nErrNo = 249209
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdDataFail
                  GOTO Quit
               END CATCH

               DECLARE @cUserName NVARCHAR( 18)
               SET @cUserName = SUSER_SNAME()

               EXEC RDT.rdt_STD_EventLog
                  @cActionType   = '3', -- Picking
                  @cUserID       = @cUserName,
                  @nMobileNo     = @nMobile,
                  @nFunctionID   = @nFunc,
                  @cFacility     = @cFacility,
                  @cStorerKey    = @cStorerKey,
                  @cLocation     = @cUCCLoc,
                  @cSKU          = @cSKU,
                  @nQTY          = @nUCCQTY,
                  @cRefNo1       = 'CONFIRM',
                  @cPickSlipNo   = @cPickSlipNo,
                  @cPickZone     = @cPickZone, 
                  @cDropID       = @cDropID

               SELECT TOP 1 
                  @cUCCNo     = ucc.UCCNo,
                  @cSKU       = pkd.Sku,
                  @cSuggestLoc  = ucc.Loc
               FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
               INNER JOIN dbo.PICKHEADER pkh WITH(NOLOCK) ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
               INNER JOIN dbo.UCC ucc WITH(NOLOCK) ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
               INNER JOIN dbo.SKU sku WITH(NOLOCK) ON pkd.StorerKey = sku.StorerKey AND pkd.Sku = sku.Sku
               WHERE pkh.StorerKey = @cStorerKey
                  AND pkh.PickHeaderKey = @cPickSlipNo
                  AND pkd.ID = @cDropID
                  AND ucc.Status = '3'
                  AND pkd.UOM = '2'
                  AND ISNULL(ucc.Userdefined08, '') = ''

               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0 --No UCC belongs to DropID
               BEGIN
                  --go close pallet
                  SET @cOutField01 = ''
                  SET @nAfterScn = 6716 --Close Pallet?
                  SET @nAfterStep = 99
                  GOTO Quit
               END
               ELSE
               BEGIN --DropID is not finished
                  IF @cSuggestUCC = '1'
                  BEGIN
                     SET @cOutField05 = @cUCCNo
                  END
                  ELSE
                  BEGIN
                     SET @cOutField05 = ''
                  END

                  --Refrsh Ucc Qtys

                  SELECT @nDropIdQty = SUM(pkd.Qty)
                  FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
                          INNER JOIN dbo.PICKHEADER pkh WITH(NOLOCK) ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                          INNER JOIN dbo.UCC ucc WITH(NOLOCK) ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
                          INNER JOIN dbo.SKU sku WITH(NOLOCK) ON pkd.StorerKey = sku.StorerKey AND pkd.Sku = sku.Sku
                  WHERE pkh.StorerKey = @cStorerKey
                    AND pkh.PickHeaderKey = @cPickSlipNo
                    AND pkd.ID = @cDropID
                    AND ucc.Status = '3'
                    AND pkd.UOM = '2' --Only accept UOM = 2

                  SELECT @nDropIDScannedQty = SUM(pkd.Qty)
                  FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
                          INNER JOIN dbo.PICKHEADER pkh WITH(NOLOCK) ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                          INNER JOIN dbo.UCC ucc WITH(NOLOCK) ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
                          INNER JOIN dbo.SKU sku WITH(NOLOCK) ON pkd.StorerKey = sku.StorerKey AND pkd.Sku = sku.Sku
                  WHERE pkh.StorerKey = @cStorerKey
                    AND pkh.PickHeaderKey = @cPickSlipNo
                    AND pkd.ID = @cDropID
                    AND ((ucc.Status = '3' AND ISNULL(ucc.Userdefined08, '') = '1')
                     OR ucc.Status = '5')


                  SELECT @cPacKKey = PackKey
                  FROM dbo.SKU WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                    AND SKU = @cSKU

                  SELECT @nCaseCnt = CaseCnt
                  FROM dbo.Pack WITH (NOLOCK)
                  WHERE PackKey = @cPackKey

                  IF @nCaseCnt > 0
                  BEGIN
                     SET @nQTY = @nDropIdQty / @nCaseCnt
                     SET @nQty1 = ISNULL(@nDropIDScannedQty, 0) / @nCaseCnt
                  END
                  ELSE
                  BEGIN
                     SET @nQty = @nDropIdQty
                     SET @nQty1 = ISNULL(@nDropIDScannedQty, 0)
                  END


                  SET @cOutField06 = CAST (@nQty AS NVARCHAR(5))
                  SET @cOutField07 = CAST (@nQty1 AS NVARCHAR(5))


                  SET @cOutField01 = @cSuggestLoc
                  SET @cOutField02 = @cDropID
                  
                  SET @nAfterScn = 6714
                  SET @nAfterStep = 99
                  GOTO Quit
               END
            END
            ELSE IF @nInputKey = 0
            BEGIN
               SET @cOutField01 = ''
               SET @nAfterScn = 6716 --Close Pallet?
               SET @nAfterStep = 99

               GOTO Quit
            END
         END
         ELSE IF @nCurrentScn = 6715 --TOLOC
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cToLoc = @cInField01
               IF @cToLoc = ''
               BEGIN
                  SET @nErrNo = 249211
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLocNeeded
                  GOTO Quit
               END

               SELECT @cToLocLoseUCC = loseucc FROM LOC WITH (NOLOCK) WHERE LOC = @cToLOC AND Facility = @cFacility

               IF @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 249219
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidLOC
                  GOTO Quit
               END
               ELSE
               BEGIN
                  IF @cToLocLoseUCC <> '1'
                     SET @cToLocLoseUCC = '0'
               END
               --V1.2 end

               IF @nTranCount = 0
                  BEGIN TRANSACTION
               ELSE 
                  BEGIN TRANSACTION rdt_957ExtScn04_02

               BEGIN TRY
                  --Create Cursor to loop PickDetail 1 by 1
                  DECLARE C_UCC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT 
                     ucc.UCCNo, ucc.Loc, ucc.Qty, ucc.Sku, ucc.LOT, pkd.PickDetailKey, pkd.ID, pkd.OrderKey
                  FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
                  INNER JOIN dbo.PICKHEADER pkh WITH(NOLOCK) ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                  INNER JOIN dbo.UCC ucc WITH(NOLOCK) ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID AND ucc.Sku = pkd.Sku
                  WHERE pkh.StorerKey = @cStorerKey
                     AND pkh.PickHeaderKey = @cPickSlipNo
                     AND pkd.Status = @cPickConfirmStatus
                     AND ucc.Status <'5'
                     AND pkd.uom = '2'
                     AND pkd.ID = @cDropID

                  OPEN C_UCC
                  FETCH NEXT FROM C_UCC INTO @cUCCNo, @cUCCLoc, @nUCCQTY, @cSKU, @cLOT, @cPickDetailKey, @cToID, @cOrderKey

                  WHILE (@@FETCH_STATUS <> -1)
                  BEGIN
                     -- Move UCC
                     EXEC RDT.rdt_Move
                        @nMobile     = @nMobile,
                        @cLangCode   = @cLangCode, 
                        @nErrNo      = @nErrNo  OUTPUT,
                        @cErrMsg     = @cErrMsg OUTPUT, 
                        @cSourceType = 'rdt_957ExtScn04',
                        @cStorerKey  = @cStorerKey,
                        @cFacility   = @cFacility, 
                        @cFromLOC    = @cUCCLOC, 
                        @cToLOC      = @cToLOC, 
                        @cFromID     = @cToID,
                        @cToID       = @cDropID,
                        @cSKU        = @cSKU, 
                        @nQTY        = @nUCCQTY,
                        @nFunc       = @nFunc, 
                        @nQTYAlloc   = 0,
                        @nQTYPick    = @nUCCQTY,
                        @cDropID     = @cUCCNo, 
                        @cFromLOT    = @cLOT 

                     UPDATE dbo.UCC WITH(ROWLOCK)
                     SET 
                        Status = CASE WHEN @cToLocLoseUCC = '1' 
                                    THEN '6' --lost
                                    ELSE '5' END, --Picked V1.2
                        Userdefined08 = '',
                        Loc = @cToLoc,
                        ID = @cDropID,
                        EditDate = GETDATE(),
                        EditWho  = SUSER_SNAME()
                     WHERE StorerKey = @cStorerKey
                        AND UCCNo = @cUCCNo

                     -- Insert blank LOTxLOCxID (to overcome FK_PICKDETAIL_LOTLOCID_01)
                     IF NOT EXISTS( SELECT 1 FROM LOTxLOCxID WITH (NOLOCK)
                                    WHERE LOT = @cLOT
                                      AND LOC = @cToLoc
                                      AND ID = @cDropID)
                     BEGIN
                        INSERT INTO LOTxLOCxID (LOT, LOC, ID, StorerKey, SKU)
                        VALUES (@cLOT, @cToLoc, @cDropID, @cStorerKey, @cSKU)
                        IF @@ERROR <> 0 --OR @@ROWCOUNT <> 1
                        BEGIN

                           IF @nTranCount > 0
                              ROLLBACK TRAN rdt_957ExtScn04_02
                           ELSE
                              ROLLBACK TRAN

                           SET @nErrNo = 112874
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS LLI Fail
                           GOTO Quit

                        END
                     END

                     UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
                     SET Loc = @cToLoc,
                        ID = @cDropID,
                        EditDate = GETDATE(),
                        EditWho  = SUSER_SNAME()
                     WHERE PickDetailKey = @cPickDetailKey

                     SELECT 
                        @cOrderType = ord.Type,
                        @cOrderConsigneeKey = ord.ConsigneeKey
                     FROM dbo.ORDERS ord WITH(NOLOCK)
                     WHERE ord.StorerKey = @cStorerKey
                        AND ord.OrderKey = @cOrderKey

                     SELECT @nRowCount = COUNT(1)
                     FROM dbo.CODELKUP WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND ListName = 'LVSSTO'
                        AND Code = @cOrderConsigneeKey
                        AND Short IS NOT NULL
                        AND Short = @cOrderType

                     IF @nRowCount > 0
                     BEGIN
                        UPDATE dbo.PackInfo WITH(ROWLOCK)
                        SET CartonStatus = 'PACKED',
                           EditDate = GETDATE(),
                           EditWho  = SUSER_SNAME()
                        WHERE PickSlipNo = @cPickSlipNo
                           AND RefNo IS NOT NULL
                           AND RefNo = @cUCCNo

                        SELECT @nRowCount = COUNT(1)
                        FROM dbo.PackInfo WITH(NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                           AND ISNULL(CartonStatus, '') <> 'PACKED'

                        IF @nRowCount = 0
                        AND NOT EXISTS (SELECT 1
                           FROM dbo.PickHeader PH WITH(NOLOCK)
                           INNER JOIN dbo.PickDetail PD WITH(NOLOCK)
                              ON PH.StorerKey = PD.StorerKey
                              AND PH.OrderKey = PD.OrderKey
                           WHERE PH.StorerKey = @cStorerkey
                              AND PH.PickHeaderKey = @cPickSlipNo
                              AND PD.Status < '4'
                              AND PD.Qty > 0
                                        )
                        AND (SELECT COUNT(DISTINCT LabelNo) FROM dbo.PackDetail WITH(NOLOCK) WHERE StorerKey = @cStorerkey AND PickSlipNo = @cPickSlipNo)
                            =
                            (SELECT COUNT(DISTINCT CaseID)
                              FROM dbo.PickHeader PH WITH(NOLOCK)
                              INNER JOIN dbo.PickDetail PD WITH(NOLOCK)
                                 ON PH.StorerKey = PD.StorerKey
                                 AND PH.OrderKey = PD.OrderKey
                              WHERE PH.StorerKey = @cStorerkey
                                 AND PH.PickHeaderKey = @cPickSlipNo
                                 AND PD.Qty > 0)
                        BEGIN
                           UPDATE dbo.PackHeader WITH(ROWLOCK)
                           SET Status = '9', --Packed
                              EditDate = GETDATE(),
                              EditWho  = SUSER_SNAME()
                           WHERE PickSlipNo = @cPickSlipNo
                        END
                     END

                     IF @nErrNo <> 0
                     BEGIN
                        CLOSE C_UCC
                        DEALLOCATE C_UCC

                        SET @nErrNo = 249212
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MoveUCCFail

                        IF @nTranCount > 0
                           ROLLBACK TRAN rdt_957ExtScn04_02
                        ELSE
                           ROLLBACK TRAN

                        GOTO Quit
                     END

                     -- Fetch Next From Cursor
                     FETCH NEXT FROM C_UCC INTO @cUCCNo, @cUCCLoc, @nUCCQTY, @cSKU, @cLOT, @cPickDetailKey, @cToID, @cOrderKey
                  END -- WHILE 1=1
                  CLOSE C_UCC
                  DEALLOCATE C_UCC
               END TRY
               BEGIN CATCH

                  SET @nErrNo = 249215
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropPalletFail

                  IF @nTranCount > 0
                     ROLLBACK TRAN rdt_957ExtScn04_02
                  ELSE
                     ROLLBACK TRAN


--                   insert into traceinfo (tracename,timein, step1, step2, Col1,Col2,Col3)
--                   values ('rdt_957ExtScn04',getdate(), @cUCCID, @cDropID,  SUBSTRING(ERROR_MESSAGE(), 0, 50), SUBSTRING(ERROR_MESSAGE(), 51, 50), SUBSTRING(ERROR_MESSAGE(), 101, 50))

                  GOTO Quit
               END CATCH

               SET @cOutField01 = @cPickSlipNo
               SET @cOutField02 = '' --PickZone
               SET @cOutField03 = '' --DropID

               IF NOT EXISTS(
                  SELECT 1
                  FROM dbo.PICKDETAIL pkd WITH (NOLOCK)
                          INNER JOIN dbo.PICKHEADER pkh WITH (NOLOCK)
                                     ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                          INNER JOIN dbo.UCC ucc WITH (NOLOCK)
                                     ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
                          INNER JOIN dbo.SKU sku WITH (NOLOCK)
                                     ON pkd.StorerKey = sku.StorerKey AND pkd.Sku = sku.Sku
                  WHERE pkh.StorerKey = @cStorerKey
                    AND pkh.PickHeaderKey = @cPickSlipNo
                    AND ucc.Status <= '3'
                    AND ISNULL(ucc.Userdefined08, '') = ''
               )
                  BEGIN -- finished, goto msg screen
                     SET @nAfterScn = 6717
                     SET @nAfterStep = 99
                  END
               ELSE
                  BEGIN -- Not finished, continue picking
                     SET @cOutField01 = @cPickSlipNo
                     SET @cOutField02 = ''
                     SET @cOutField03 = ''
                     SET @nAfterScn = 5291 --DropID scn
                     SET @nAfterStep = 2
                  END
            END
            ELSE IF @nInputKey = 0
            BEGIN
               SET @nErrNo = 249228  -- FCR-10631
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLocNeeded
               GOTO Quit  -- FCR-10631
               -- SET @cOutField01 = @cPickSlipNo
               -- SET @cOutField02 = ''
               -- SET @cOutField03 = ''
               -- SET @nAfterScn = 5291 --DropID scn
               -- SET @nAfterStep = 2
            END
            GOTO Quit
         END
         ELSE IF @nCurrentScn = 6716 --Close Pallet?
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cOption = TRIM(@cInField01)

               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 249216
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OptionNeeded
                  GOTO Quit
               END

               IF @cOption NOT IN ('1', '9')
               BEGIN
                  SET @nErrNo = 249217
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidOption
                  GOTO Quit
               END 

               IF @cOption = '1'
               BEGIN
                  SET @nAfterScn = 6715
                  SET @nAfterStep = 99
               END
               ELSE
               BEGIN

                  IF NOT EXISTS(
                     SELECT 1
                     FROM dbo.PICKDETAIL pkd WITH (NOLOCK)
                             INNER JOIN dbo.PICKHEADER pkh WITH (NOLOCK)
                                        ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                             INNER JOIN dbo.UCC ucc WITH (NOLOCK)
                                        ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
                             INNER JOIN dbo.SKU sku WITH (NOLOCK)
                                        ON pkd.StorerKey = sku.StorerKey AND pkd.Sku = sku.Sku
                     WHERE pkh.StorerKey = @cStorerKey
                       AND pkh.PickHeaderKey = @cPickSlipNo
                       AND ucc.Status <= '3'
                       AND ISNULL(ucc.Userdefined08, '') = ''
                  )
                  BEGIN -- finished, goto msg screen
                     SET @nAfterScn = 6717  --Msg screen
                     SET @nAfterStep = 99
                  END
                  ELSE
                  BEGIN -- Not finished, continue picking
                     SET @cOutField01 = @cPickSlipNo
                     SET @cOutField02 = ''
                     SET @cOutField03 = ''
                     SET @nAfterScn = 5291 --DropID scn
                     SET @nAfterStep = 2
                  END

               END
            END
            ELSE IF @nInputKey = 0
            BEGIN
               IF NOT EXISTS(
                  SELECT 1
                  FROM dbo.PICKDETAIL pkd WITH (NOLOCK)
                  INNER JOIN dbo.PICKHEADER pkh WITH (NOLOCK)
                     ON pkd.StorerKey = pkh.StorerKey AND pkd.OrderKey = pkh.OrderKey
                  INNER JOIN dbo.UCC ucc WITH (NOLOCK)
                     ON ucc.StorerKey = pkd.StorerKey AND ucc.UCCNo = pkd.DropID
                  INNER JOIN dbo.SKU sku WITH (NOLOCK)
                     ON pkd.StorerKey = sku.StorerKey AND pkd.Sku = sku.Sku
                  WHERE pkh.StorerKey = @cStorerKey
                     AND pkh.PickHeaderKey = @cPickSlipNo
                     AND ucc.Status <= '3'
                     AND ISNULL(ucc.Userdefined08, '') = ''
               )
               BEGIN -- finished, goto msg screen
                  SET @nAfterScn = 6717  --Msg screen
                  SET @nAfterStep = 99
               END
               ELSE
               BEGIN -- Not finished, continue picking

                  SET @cOutField01 = @cPickSlipNo
                  SET @cOutField02 = ''
                  SET @cOutField03 = ''
                  SET @nAfterScn = 5291 --DropID scn
                  SET @nAfterStep = 2
               END
            END
            GOTO Quit
         END
      END
   END
Fail:
   
Quit:
   UPDATE rdt.rdtMobRec WITH (ROWLOCK) SET
      C_String2 = @cSuggestUCC
   WHERE Mobile = @nMobile

   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRANSACTION
END; 

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_957ExtScn04 TO NSQL
GO
