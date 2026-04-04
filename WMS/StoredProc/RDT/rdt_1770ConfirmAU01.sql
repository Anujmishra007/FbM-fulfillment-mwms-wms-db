SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************************************/
/* Store procedure: rdt_1770ConfirmAU01                                    */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Date        Rev   Author    Purposes                                    */
/* 2025-05-26  1.0   SYC067    Created                                     */
/***************************************************************************/

CREATE OR ALTER PROC RDT.rdt_1770ConfirmAU01 (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @cUserName      NVARCHAR( 18),
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cTaskDetailKey NVARCHAR( 10),
   @cDropID        NVARCHAR( 20),
   @nQTY           INT,
   @cFinalLOC      NVARCHAR( 10),
   @cReasonKey     NVARCHAR( 10),
   @cListKey       NVARCHAR( 10),
   @nErrNo         INT          OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT,
   @cDebug         NVARCHAR( 1) = NULL
) AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @bSuccess       INT
    DECLARE @cTaskType      NVARCHAR( 10)
    DECLARE @cPickDetailKey NVARCHAR( 10)
    DECLARE @cMoveRefKey    NVARCHAR( 10)
    DECLARE @cStatus        NVARCHAR( 10)
    DECLARE @nTaskQTY       INT
    DECLARE @nQTY_Bal       INT
    DECLARE @nQTY_PD        INT
    DECLARE @nQTY_Move      INT
    DECLARE @cMoveQTYAlloc  NVARCHAR( 1)
    DECLARE @cMoveQTYPick   NVARCHAR( 1)
    DECLARE @nQTYAlloc      INT
    DECLARE @nQTYPick       INT
    DECLARE @cFromLOC       NVARCHAR( 10)
    DECLARE @cFromID        NVARCHAR( 18)
    DECLARE @cSKU           NVARCHAR( 15)
    DECLARE @cLOT           NVARCHAR( 10)
    DECLARE @cPickMethod    NVARCHAR( 10)
    DECLARE @cPickConfirmStatus NVARCHAR( 1)
    DECLARE @cClosePalletFlag  NVARCHAR( 1)
    DECLARE @cPalletLineNumber NVARCHAR( 5)  --INC7331096
    DECLARE @cOrderKey   NVARCHAR( 10)         /* (JH01)*/
    DECLARE @cPLTUDF05   NVARCHAR( 30)

    DECLARE @nPalletLength FLOAT = 116.0
    DECLARE @nPalletWidth  FLOAT = 116.0
    DECLARE @nPalletHeight FLOAT = 116.0
    DECLARE @nPalletWeight FLOAT = 45.0
    DECLARE @nSumPackInfoWgt FLOAT = 0.0
    --DECLARE @cPalletType   NVARCHAR(10) = ''
    -- Init var
    SET @nQTY_Move = 0
    SET @nErrNo = 0
    SET @cErrMsg = ''

    -- Get task info
    SELECT
        @cTaskType = TaskType,
        @nTaskQTY = QTY,
        @cStatus = Status,
        @cFromLOC = FromLOC,
        @cLOT = LOT,
        @cPickMethod = PickMethod
    FROM dbo.TaskDetail WITH (NOLOCK)
    WHERE TaskDetailKey = @cTaskDetailKey

    -- Check task already SKIP/CANCEL
    IF @cStatus IN ('0', 'X')
        RETURN

    -- Get storer config
    SET @cMoveQTYAlloc = rdt.rdtGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
    SET @cMoveQTYPick = rdt.rdtGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)
    SET @cClosePalletFlag = rdt.RDTGetConfig( @nFunc, 'ClosePalletFlag', @cStorerKey)
    IF @cClosePalletFlag = '0'
        SET @cClosePalletFlag = ''

    SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
    IF @cPickConfirmStatus = '0'
        SET @cPickConfirmStatus = '5'
    IF @cPickConfirmStatus NOT IN ( '3', '5')
        SET @cPickConfirmStatus = '5'

    -- Check move alloc, but picked
    IF @cMoveQTYAlloc = '1' AND @cPickConfirmStatus = '5'
    BEGIN
        SET @nErrNo = 262601
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
        GOTO Quit
    END

    -- Check move picked, but not pick confirm
    IF @cMoveQTYPick = '1' AND @cPickConfirmStatus < '5'
    BEGIN
        SET @nErrNo = 262602
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
        GOTO Quit
    END

    -- Handling transaction
    DECLARE @nTranCount INT
    SET @nTranCount = @@TRANCOUNT
    BEGIN TRAN  -- Begin our own transaction
    SAVE TRAN rdt_1770ConfirmAU01 -- For rollback or commit only our own transaction

    IF @cTaskType = 'FPK' -- need to update PickDetail
    BEGIN
        -- For calculation
        SET @nQTY_Bal = @nQTY

        -- Get PickDetail candidate
        DECLARE @curPD CURSOR
        SET @curPD = CURSOR FOR
            SELECT PickDetailKey, QTY, LOC, ID, SKU
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey

        OPEN @curPD
        FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD, @cFromLOC, @cFromID, @cSKU
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Exact match
            IF @nQTY_PD = @nQTY_Bal
            BEGIN
                -- Confirm PickDetail
                UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                    Status = @cPickConfirmStatus,
                    DropID = CASE WHEN @cFromID = '' THEN DropID ELSE @cFromID END,
                    EditDate = GETDATE(),
                    EditWho  = SUSER_SNAME()
                WHERE PickDetailKey = @cPickDetailKey
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262603
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPickDtlFail
                    GOTO RollBackTran
                END

                SET @nQTY_Move = @nQTY_Move + @nQTY_PD
                SET @nQTY_Bal = 0 -- Reduce balance
            END

            -- PickDetail have less
            ELSE IF @nQTY_PD < @nQTY_Bal
            BEGIN
                -- Confirm PickDetail
                UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                    Status = @cPickConfirmStatus,
                    DropID = CASE WHEN @cFromID = '' THEN DropID ELSE @cFromID END,
                    -- TrafficCop = NULL,
                    EditDate = GETDATE(),
                    EditWho  = SUSER_SNAME()
                WHERE PickDetailKey = @cPickDetailKey
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262604
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPickDtlFail
                    GOTO RollBackTran
                END

                SET @nQTY_Move = @nQTY_Move + @nQTY_PD
                SET @nQTY_Bal = @nQTY_Bal - @nQTY_PD -- Reduce balance
            END

            -- PickDetail have more
            ELSE IF @nQTY_PD > @nQTY_Bal
            BEGIN
                -- Short pick
                IF @nQTY_Bal = 0 -- Don't need to split
                BEGIN
                    -- Confirm PickDetail
                    UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                        Status = '4',
                        TaskDetailKey = '',
                        TrafficCop = NULL,
                        EditDate = GETDATE(),
                        EditWho  = SUSER_SNAME()
                    WHERE PickDetailKey = @cPickDetailKey
                    IF @@ERROR <> 0
                    BEGIN
                        SET @nErrNo = 262605
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPickDtlFail
                        GOTO RollBackTran
                    END
                END
                ELSE
                BEGIN -- Have balance, need to split

                -- Get new PickDetailkey
                DECLARE @cNewPickDetailKey NVARCHAR( 10)
                EXECUTE dbo.nspg_GetKey
                    'PICKDETAILKEY',
                    10 ,
                    @cNewPickDetailKey OUTPUT,
                    @bSuccess          OUTPUT,
                    @nErrNo            OUTPUT,
                    @cErrMsg           OUTPUT
                IF @bSuccess <> 1
                BEGIN
                    SET @nErrNo = 262606
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetDetKey Fail
                    GOTO RollBackTran
                END

                -- Create new a PickDetail to hold the balance
                INSERT INTO dbo.PICKDETAIL (
                    CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
                    UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                    ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                    EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo,
                    PickDetailKey,
                    QTY,
                    Status,
                    TrafficCop,
                    OptimizeCop)
                SELECT
                    CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,
                    UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup,
                    CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
                    EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo,
                    @cNewPickDetailKey,
                    @nQTY_PD - @nQTY_Bal, -- QTY
                    -- CASE WHEN @cShort = 'Y' THEN '4' ELSE '0' END, -- Status
                    '4', -- Short
                    NULL, --TrafficCop,
                    '1'  --OptimizeCop
                FROM dbo.PickDetail WITH (NOLOCK)
                WHERE PickDetailKey = @cPickDetailKey
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262607
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins PDtl Fail
                    GOTO RollBackTran
                END

                -- Split RefKeyLookup
                IF EXISTS( SELECT 1 FROM RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cPickDetailKey)
                BEGIN
                    -- Insert RefKeyLookup
                    INSERT INTO dbo.RefKeyLookup (PickDetailkey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey)
                    SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey
                    FROM RefKeyLookup WITH (NOLOCK)
                    WHERE PickDetailKey = @cPickDetailKey
                    IF @@ERROR <> 0
                    BEGIN
                        SET @nErrNo = 262608
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsRefKeyFail
                        GOTO RollBackTran
                    END
                END

                -- Change orginal PickDetail with exact QTY (with TrafficCop)
                UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                    QTY = @nQTY_Bal,
                    DropID = CASE WHEN @cFromID = '' THEN DropID ELSE @cFromID END,
                    Trafficcop = NULL,
                    EditDate = GETDATE(),
                    EditWho  = SUSER_SNAME()
                WHERE PickDetailKey = @cPickDetailKey
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262609
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPickDtlFail
                    GOTO RollBackTran
                END

                -- Confirm orginal PickDetail with exact QTY
                UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                    Status = @cPickConfirmStatus,
                    EditDate = GETDATE(),
                    EditWho  = SUSER_SNAME()
                WHERE PickDetailKey = @cPickDetailKey
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262610
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPickDtlFail
                    GOTO RollBackTran
                END

                -- Short pick
                UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                    Status = '4',
                    TaskDetailKey = '',
                    TrafficCop = NULL,
                    EditDate = GETDATE(),
                    EditWho  = SUSER_SNAME()
                WHERE PickDetailKey = @cNewPickDetailKey
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262611
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPickDtlFail
                    GOTO RollBackTran
                END

                SET @nQTY_Move = @nQTY_Move + @nQTY_Bal
                SET @nQTY_Bal = 0 -- Reduce balance
                END
            END

            FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD, @cFromLOC, @cFromID, @cSKU
        END

        -- Check offset
        IF @nQTY_Bal <> 0
        BEGIN
            SET @nErrNo = 262612
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Offset error
            GOTO RollBackTran
        END

        -- Move PickDetail
        IF (@cMoveQTYAlloc = '1' OR @cMoveQTYPick = '1') AND @nQTY_Move > 0
        BEGIN
            -- Calc alloc or pick
            IF @cPickConfirmStatus = '5'
            BEGIN
                SET @nQTYAlloc = 0
                SET @nQTYPick = @nQTY_Move
            END
            ELSE
            BEGIN
                SET @nQTYAlloc = @nQTY_Move
                SET @nQTYPick = 0
            END

            IF @cLOT = ''
                SET @cLOT = NULL

            IF @nTaskQTY = @nQTY AND @cPickMethod = 'FP'
            BEGIN
                IF EXISTS( SELECT 1 FROM dbo.UCC WITH (NOLOCK)         /*JH01 Start*/
                        WHERE StorerKey = @cStorerKey
                        AND OrderKey IN (SELECT Orderkey FROM dbo.PickDetail WITH (NOLOCK)
                            WHERE PickDetailKey = @cPickDetailKey)
                        AND LOC = @cFromLOC
                        AND ID = @cFromID)
                BEGIN
                UPDATE dbo.UCC SET STATUS = '5'
                WHERE StorerKey = @cStorerKey
                AND OrderKey IN (SELECT Orderkey FROM dbo.PickDetail WITH (NOLOCK)
                    WHERE PickDetailKey = @cPickDetailKey)
                AND LOC = @cFromLOC
                AND ID = @cFromID
                END                                                   /*JH01 End*/

                -- Move by ID
                EXECUTE rdt.rdt_Move
                @nMobile        = @nMobile,
                @cLangCode      = @cLangCode,
                @nErrNo         = @nErrNo  OUTPUT,
                @cErrMsg        = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max
                @cSourceType    = 'rdt_1770ConfirmAU01',
                @cStorerKey     = @cStorerKey,
                @cFacility      = @cFacility,
                @cFromLOC       = @cFromLOC,
                @cToLOC         = @cFinalLOC,
                @cFromID        = @cFromID,     -- NULL means not filter by ID. Blank is a valid ID
                @cToID          = @cFromID,     -- NULL means not changing ID. Blank consider a valid ID
                @nQTYAlloc      = @nQTYAlloc,
                @nQTYPick       = @nQTYPick,
                @cTaskDetailKey = @cTaskDetailKey,
                @nFunc          = @nFunc
            END
            ELSE
                -- Move by SKU
                EXECUTE rdt.rdt_Move
                @nMobile        = @nMobile,
                @cLangCode      = @cLangCode,
                @nErrNo         = @nErrNo  OUTPUT,
                @cErrMsg        = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max
                @cSourceType    = 'rdt_1770ConfirmAU01',
                @cStorerKey     = @cStorerKey,
                @cFacility      = @cFacility,
                @cFromLOC       = @cFromLOC,
                @cToLOC         = @cFinalLOC,
                @cFromID        = @cFromID,     -- NULL means not filter by ID. Blank is a valid ID
                @cToID          = @cFromID,     -- NULL means not changing ID. Blank consider a valid ID
                @cSKU           = @cSKU,
                @nQTY           = @nQTY,
                @cFromLOT       = @cLOT,
                @nQTYAlloc      = @nQTYAlloc,
                @nQTYPick       = @nQTYPick,
                @cTaskDetailKey = @cTaskDetailKey,
                @nFunc          = @nFunc
            IF @nErrNo <> 0
                GOTO RollBackTran
        END

        -- Update Task
        UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
            Status = '9', -- Closed
            DropID = @cDropID,
            QTY = @nQTY,
            ToLOC = @cFinalLOC,
            ReasonKey = @cReasonKey,
            EndTime = GETDATE(),
            EditDate = GETDATE(),
            EditWho  = @cUserName,
            Trafficcop = NULL
        WHERE TaskDetailKey = @cTaskDetailKey
        IF @@ERROR <> 0
        BEGIN
            SET @nErrNo = 262613
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskdetFail
            GOTO RollBackTran
        END
    END

    -- TaskType = FPK1 (don't need to update PickDetail)
    ELSE
    BEGIN
        IF (@cMoveQTYAlloc = '1' OR @cMoveQTYPick = '1')
        BEGIN
            -- Move PickDetail
            EXECUTE rdt.rdt_Move
                @nMobile        = @nMobile,
                @cLangCode      = @cLangCode,
                @nErrNo         = @nErrNo  OUTPUT,
                @cErrMsg        = @cErrMsg OUTPUT, -- screen limitation, 20 NVARCHAR max
                @cSourceType    = 'rdt_1770ConfirmAU01',
                @cStorerKey     = @cStorerKey,
                @cFacility      = @cFacility,
                @cFromLOC       = @cFromLOC,
                @cToLOC         = @cFinalLOC,
                @cFromID        = @cFromID,     -- NULL means not filter by ID. Blank is a valid ID
                @cToID          = @cFromID,     -- NULL means not changing ID. Blank consider a valid ID
                @nFunc          = @nFunc
            IF @nErrNo <> 0
                GOTO RollBackTran
        END

        -- Update Task
        UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
            Status = '9', -- Closed
            ToLOC = @cFinalLOC,
            ReasonKey = @cReasonKey,
            EndTime = GETDATE(),
            EditDate = GETDATE(),
            EditWho  = @cUserName,
            Trafficcop = NULL
        WHERE TaskDetailKey = @cTaskDetailKey
        IF @@ERROR <> 0
        BEGIN
            SET @nErrNo = 262614
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskdetFail
            GOTO RollBackTran
        END
    END

    /***********************************************************************************************
                                                Customization
    ***********************************************************************************************/
    IF @cTaskType = 'FPK'
    BEGIN
        --INITIALIZE PALLETHEADER
        DECLARE @cPickSlipNo NVARCHAR( 10)
        DECLARE @nCartonNo   INT
        DECLARE @cLabelNo    NVARCHAR( 20)
        /*DECLARE @cOrderKey   NVARCHAR( 10)          (JH01) move to top*/
        DECLARE @nPackQTY INT
        DECLARE @cPalletType NVARCHAR( 30)
        DECLARE @nLength FLOAT
        DECLARE @nWidth FLOAT
        DECLARE @nHeight FLOAT


        DECLARE @cLabelLine  NVARCHAR(5) = ''
        DECLARE @cNewLine    NVARCHAR(1) = 'N'

        DECLARE @cConsigneeKey NVARCHAR( 15) = ''
        DECLARE @cBillToKey    NVARCHAR( 20) = ''
        DECLARE @cOrderType    NVARCHAR( 20) = ''

        DECLARE @cCustomerType1     NVARCHAR( 20) = '' --PALLET / CASE
        DECLARE @cCustomerType2     NVARCHAR( 20) = '' --SANDWICH / RAINBOW
        DECLARE @cCustomerType3     NVARCHAR( 20) = '' --MAX SKU PER PALLET
        DECLARE @cCustomerType4     NVARCHAR( 20) = '' --PALLET TYPE: CHEP / LOSCAM / PLAIN
        DECLARE @cCustomerType5     NVARCHAR( 20) = '' --CASE CONVERT QTY
        DECLARE @cPrintCopy         NVARCHAR(  1) = '' --Print Copy
        DECLARE @cPlanningType     NVARCHAR( 20) = '' --WAVE / LOAD
        DECLARE @cPWaveKey         NVARCHAR( 20) = ''
        DECLARE @cPLoadkey         NVARCHAR( 20) = ''
        DECLARE @cPickPalletType   NVARCHAR( 20) = ''
        DECLARE @cPickCaseType     NVARCHAR( 20) = ''
        DECLARE @cPickPieceType    NVARCHAR( 20) = ''
        DECLARE @nLLIQty           INT = 0
        DECLARE @nTOLLIQty         INT = 0
        DECLARE @nNoOfCopy         INT = 1
        DECLARE @fPDCaseCnt        FLOAT
        DECLARE @cPDUOM            NVARCHAR( 10) = ''

        DECLARE @cPackMethod       NVARCHAR( 20) = '' --PALLET / CASE / PIECE
        DECLARE @cPackCaseType     NVARCHAR( 20) = '' --SANDWICH / RAINBOW
        DECLARE @nPackMaxSku       INT = 0 --MAX SKU PER PALLET
        DECLARE @nCheckMaxSKU      INT = 0
        DECLARE @nSKUExists         INT = 0

        DECLARE @fCube               FLOAT = 0
        DECLARE @fLength             FLOAT = 0
        DECLARE @fWidth              FLOAT = 0
        DECLARE @fHeight             FLOAT = 0
        DECLARE @fWeight             FLOAT = 0
        DECLARE @fCartonWeight       FLOAT = 0
        DECLARE @fSKUWeight          FLOAT = 0
        DECLARE @cLength             NVARCHAR( 10)
        DECLARE @cWidth              NVARCHAR( 10)
        DECLARE @cHeight             NVARCHAR( 10)
        DECLARE @cCartonType         NVARCHAR( 10)
        DECLARE @cCube               NVARCHAR( 10)
        DECLARE @cWeight             NVARCHAR( 10)
        DECLARE @cDefaultcartontype  NVARCHAR( 10)
        DECLARE @cDefaultpallettype  NVARCHAR( 10)
        DECLARE @cUpdatePackDetailInfo  NVARCHAR(  1)
        DECLARE @nPackDetailInfoKey BIGINT
        DECLARE @cPackData1      NVARCHAR( 30)
        DECLARE @cPackData2      NVARCHAR( 30)
        DECLARE @cPackData3      NVARCHAR( 30)
        DECLARE @cLottable01     NVARCHAR( 18)

        DECLARE @cShipLabel          NVARCHAR( 10),
                @cCartonManifest     NVARCHAR( 10),
                @cCstLabelSP         NVARCHAR( 30) ,
                @cLabelPrinter       NVARCHAR( 10),
                @cPaperPrinter       NVARCHAR( 10),
                @cUCCNo              NVARCHAR( 20)

        DECLARE @cManiLaneLBL   NVARCHAR( 10)
        DECLARE @tManiLaneLBL AS VariableTable
        DECLARE @cManiLanePrinted   NVARCHAR( 10)  ='N'
        DECLARE @cExternOrderkey   NVARCHAR( 30)  ='N'
        DECLARE @tShipLabel AS VariableTable
        DECLARE @tCartonManifest AS VariableTable

        DECLARE @cDefaultWeight    NVARCHAR( 1)
        DECLARE @cGenPackLabelNoSP NVARCHAR( 20)
        --DECLARE @cLabelNo          NVARCHAR(20)
        DECLARE @cSQL              NVARCHAR( MAX)
        DECLARE @cSQLParam         NVARCHAR( MAX)
        DECLARE @nStep             INT
        DECLARE @nInputKey         INT = 1
        DECLARE @cCarrierFlag  NVARCHAR(  1) = ''
        DECLARE @nCaseCntOrd       INT = 0 --Case Qty for Orders

        SET @cPalletType   = '' --CHEP / LOSCAM / PLAIN,

        SELECT @cPaperPrinter    = Printer_Paper,
                @cLabelPrinter    = Printer,
                @nStep            = Step
        FROM RDT.RDTMOBREC WITH (NOLOCK)
        WHERE MOBILE = @nMobile

        SELECT @cSKU = TD.SKU,
                @cLottable01 = LA.Lottable01,
                @cOrderKey = TD.OrderKey
        FROM TASKDETAIL TD (NOLOCK)
        JOIN LOTATTRIBUTE LA (NOLOCK) ON TD.LOT = LA.LOT AND TD.STORERKEY = LA.STORERKEY
        WHERE TD.TASKDETAILKEY = @cTaskDetailKey

        SET @cPackData1 = ''
        SET @cPackData2 = ''
        SET @cPackData3 = ''

        SET @cUpdatePackDetailInfo = rdt.RDTGetConfig( @nFunc, 'UpdatePackDetailInfo', @cStorerKey)

        SET @cGenPackLabelNoSP = rdt.RDTGetConfig( @nFunc, 'GenPackLabelNoSP', @cStorerKey)
        IF @cGenPackLabelNoSP = '0'
            SET @cGenPackLabelNoSP = ''

        SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'ShipLabel', @cStorerKey)
        IF @cShipLabel = '0'
            SET @cShipLabel = ''

        SET @cCartonManifest = rdt.RDTGetConfig( @nFunc, 'CartonManifest', @cStorerKey)
        IF @cCartonManifest = '0'
            SET @cCartonManifest = ''

        SET @cManiLaneLBL = rdt.RDTGetConfig( @nFunc, 'ManiLaneLBL', @cStorerKey)
        IF @cManiLaneLBL = '0'
            SET @cManiLaneLBL = ''

        SET @cDefaultcartontype=rdt.RDTGetConfig( @nFunc, 'DefaultCartonType', @cStorerKey)  --(cc01)
        IF @cDefaultcartontype = '0'
            SET @cDefaultcartontype = ''

        SET @cDefaultpallettype=rdt.RDTGetConfig( @nFunc, 'DefaultPalletType', @cStorerKey)  --(cc01)
        IF @cDefaultpallettype = '0'
            SET @cDefaultpallettype = ''

        SET @cDefaultWeight = rdt.RDTGetConfig( @nFunc, 'DefaultWeight', @cStorerKey)

        SET @cLottable01 = ''
        SELECT @cLottable01 = LA.LOTTABLE01
        FROM LOTATTRIBUTE LA (NOLOCK)
        WHERE LA.LOT = @cLot
        AND LA.STORERKEY = @cStorerkey
        AND LA.SKU = @cSKU

        IF @cOrderKey <> ''
            SELECT @cConsigneeKey = ConsigneeKey, @cBillToKey = BillToKey, @cOrderType = [Type]
                , @cPWaveKey = UserDefine09, @cPLoadkey = LoadKey
            FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey

        --Get Pack config
        SELECT @fPDCaseCnt = ISNULL(CASECNT,0)
        FROM PACK WITH (NOLOCK)
        JOIN SKU WITH (NOLOCK) ON PACK.PACKKEY = SKU.PackKey
        WHERE SKU.STORERKEY = @cStorerKey
        AND SKU = @cSKU

        -- Get PackHeader
        SET @cPickSlipNo = ''

        SELECT @cPickSlipNo = PickSlipNo
        FROM dbo.PackHeader WITH (NOLOCK)
        WHERE OrderKey = @cOrderKey
        /***********************************************************************************************
                                                PackHeader
        ***********************************************************************************************/
        IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE Pickslipno = @cPickSlipNo)
        BEGIN
            -- Get PickSlipNo
            IF @cPickSlipNo = ''
            BEGIN
                SELECT TOP 1 @cPickSlipNo = PickHeaderKey
                FROM PICKHEADER WITH (NOLOCK)
                WHERE OrderKey = @cOrderKey
            END

            IF @cPickSlipNo = ''
            BEGIN
                EXECUTE dbo.nspg_GetKey
                    'PICKSLIP',
                    9,
                    @cPickSlipNo   OUTPUT,
                    @bSuccess      OUTPUT,
                    @nErrNo        OUTPUT,
                    @cErrMsg       OUTPUT
                IF @nErrNo <> 0
                    GOTO RollBackTran

                SET @cPickSlipNo = 'P' + @cPickSlipNo
            END

            DECLARE @cLoadKey NVARCHAR( 10) = ''
            SELECT @cLoadKey = LoadKey FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey

            INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, ConsigneeKey, LoadKey)
            VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, '', @cLoadKey)
            IF @@ERROR <> 0
            BEGIN
                SET @nErrNo = 262615
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPHdrFail
                GOTO RollBackTran
            END
        END


        --Else Check Pack Type by Customer
        --1. Check if configured by order type (UDF01 = PALLET / CASE, UDF02 = SANDWICH / RAINBOW, UDF03 = MAX SKU PER PALLET)
        --2. If no point 1 then Check if configured by storer (storerkey = consigneekey 1st, not exist then billtokey)
        --                                     (SUSR1 = PALLET / CASE, SUSR2 = SANDWICH / RAINBOW, SUSR3 = MAX SKU PER PALLET)
        --3. If no point 1/2 then Check if configured by wave/load release (get from:
        --            DispatchPalletPickMethod = 'PALLET' / 'CASE'
        --            DispatchCasePickMethod   = 'SWPALLET' (SANDWICH PALLET)
        --                                      /'SWCASE'   (SANDWICH CASE)
        --                                      /'RBPALLET' (RAINBOW PALLET)
        --                                      /'RBCASE'   (RAINBOW CASE)
        --                                      /'PALLET'   (PALLET)
        --                                      /'CASE'     (CASE)
        --            DispatchPiecePickMethod  = 'PIECE')

        --1. check if configured by order type
        IF ISNULL(@cPackMethod,'') = ''
        BEGIN
            SET @cCustomerType1 = ''
            SET @cCustomerType2 = ''
            SET @cCustomerType3 = ''
            SET @cCustomerType4 = ''
            SET @cCustomerType5 = ''
            SET @cPackMethod = ''

            SELECT TOP 1 @cCustomerType1 = UDF01
                        , @cCustomerType2 = UDF02
                        , @cCustomerType3 = UDF03
                        , @cCustomerType4 = UDF04
                        , @cCustomerType5 = UDF05
            FROM CODELKUP (NOLOCK)
            WHERE LISTNAME = 'ORDERTYPE'
            AND STORERKEY = @cStorerKey
            AND CODE = @cOrderType
            AND ISNULL(UDF01,'') IN ('PALLET', 'CASE')

            IF ISNULL(@cCustomerType1,'') <> ''
                SET @cPackMethod = @cCustomerType1
        END

        --2. Check if storer configured
        IF ISNULL(@cPackMethod,'') = ''
        BEGIN
            SET @cCustomerType1 = ''
            SET @cCustomerType2 = ''
            SET @cCustomerType3 = ''
            SET @cCustomerType4 = ''
            SET @cCustomerType5 = ''
            SET @cPackMethod = ''

            IF ISNULL(@cConsigneeKey,'') <> ''
            BEGIN
                SELECT TOP 1 @cCustomerType1 = SUSR1
                        , @cCustomerType2 = SUSR2
                        , @cCustomerType3 = SUSR3
                        , @cCustomerType4 = PALLET
                        , @cCustomerType5 = SUSR4
                        , @cPrintCopy     = SUSR5
                FROM STORER WITH (NOLOCK)
                WHERE CONSIGNEEFOR = @cStorerKey
                AND STORERKEY = @cConsigneeKey
                AND ISNULL(SUSR1,'') IN ('PALLET', 'CASE')
            END

            IF ISNULL(@cCustomerType1,'') = '' AND ISNULL(@cBillToKey,'') <> ''
            BEGIN
                SELECT TOP 1 @cCustomerType1 = SUSR1
                        , @cCustomerType2 = SUSR2
                        , @cCustomerType3 = SUSR3
                        , @cCustomerType4 = PALLET
                        , @cCustomerType5 = SUSR4
                        , @cPrintCopy     = SUSR5
                FROM STORER WITH (NOLOCK)
                WHERE CONSIGNEEFOR = @cStorerKey
                AND STORERKEY = @cBillToKey
                AND ISNULL(SUSR1,'') IN ('PALLET', 'CASE')
            END

            IF ISNULL(@cCustomerType1,'') <> ''
                SET @cPackMethod = @cCustomerType1

        END

        --3. Check if configured by wave/load release
        IF ISNULL(@cPackMethod,'') = ''
        BEGIN
            SET @cPlanningType = ''
            SET @cPackMethod = ''
            SET @cCustomerType2 = ''
            SET @cCustomerType3 = ''
            SET @cCustomerType4 = ''
            SET @cCustomerType5 = ''

            SELECT TOP 1 @cPlanningType = CODE
            FROM CODELKUP (NOLOCK)
            WHERE LISTNAME = 'AU830PLAN'
            AND STORERKEY = @cStorerKey

            IF ISNULL(@cPlanningType,'') <> ''
            BEGIN
                IF ISNULL(@cPlanningType,'') = 'WAVE' AND ISNULL(@cPWaveKey,'') <> ''
                BEGIN
                    SELECT @cPickPalletType  = DispatchPalletPickMethod
                            , @cPickCaseType    = DispatchCasePickMethod
                            , @cPickPieceType   = DispatchPiecePickMethod
                            , @cCustomerType3   = UserDefine01
                            , @cCustomerType4   = UserDefine02
                            , @cCustomerType5   = UserDefine03
                    FROM WAVE WITH (NOLOCK)
                    WHERE WAVEKEY = @cPWaveKey
                END
                ELSE IF ISNULL(@cPlanningType,'') = 'LOAD' AND ISNULL(@cPLoadkey,'') <> ''
                BEGIN
                    SELECT @cPickPalletType  = DispatchPalletPickMethod
                            , @cPickCaseType    = DispatchCasePickMethod
                            , @cPickPieceType   = DispatchPiecePickMethod
                            , @cCustomerType3   = UserDefine01
                            , @cCustomerType4   = UserDefine02
                            , @cCustomerType5   = UserDefine03
                    FROM LOADPLAN WITH (NOLOCK)
                    WHERE LOADKEY = @cPLoadkey
                END

                IF @cPickPalletType IN ('PALLET','CASE')
                    SET @cPackMethod = @cPickPalletType

            END
        END

        IF ISNULL(@cCustomerType2,'') IN ('SANDWICH','RAINBOW')
            SET @cPackCaseType = @cCustomerType2
        ELSE
            SET @cPackCaseType = 'RAINBOW' --DEFAULT TO RAINBOW

        IF EXISTS (SELECT TOP 1 1 FROM
                    CARTONIZATION C WITH (NOLOCK)
                    JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
                    WHERE S.Storerkey = @cStorerKey
                    AND C.CARTONTYPE = ISNULL(@cCustomerType4,''))
            SET @cPalletType = @cCustomerType4
        ELSE IF EXISTS (SELECT TOP 1 1 FROM
                CARTONIZATION C WITH (NOLOCK)
                JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
                WHERE S.Storerkey = @cStorerKey
                AND C.CARTONTYPE = CASE WHEN ISNULL(@cCustomerType4,'') LIKE '%CHEP%' THEN 'CHEP'
                                        WHEN ISNULL(@cCustomerType4,'') LIKE '%LOSC%' THEN 'LOSCAM'
                                        ELSE 'PALLET' END)
            SELECT TOP 1 @cPalletType = CARTONTYPE
            FROM CARTONIZATION C WITH (NOLOCK)
            JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
            WHERE S.Storerkey = @cStorerKey
            AND C.CARTONTYPE = CASE WHEN ISNULL(@cCustomerType4,'') LIKE '%CHEP%' THEN 'CHEP'
                                WHEN ISNULL(@cCustomerType4,'') LIKE '%LOSC%' THEN 'LOSCAM'
                                ELSE 'PALLET' END
        ELSE
            SELECT @cPalletType = C.CartonType  --DEFAULT AS PLAIN PALLET
            FROM CARTONIZATION C WITH (NOLOCK)
            JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
            WHERE S.Storerkey = @cStorerKey
            AND C.CARTONTYPE = CASE WHEN ISNULL(@cDefaultpallettype,'') <> '' THEN ISNULL(@cDefaultpallettype,'') ELSE 'PALLET' END

        IF ISNULL(@cPackMethod,'') NOT IN ('PALLET','CASE','PIECE')
            SET @cPackMethod = 'PALLET' --DEFAULT TO PALLET

        --DEFAULT IF NOT CONFIGURED THEN 8
        IF ISNUMERIC(@cCustomerType5)<>1
            SET @cCustomerType5 = '8'

        IF ISNULL(@cPackMethod,'') = 'PALLET' AND ISNUMERIC(@cCustomerType5)=1
        BEGIN
            SET @nCaseCntOrd = 0

            SELECT @nCaseCntOrd = ISNULL(SUM(CEILING(PD.QTY/CAST(ISNULL(PACK.CASECNT,1) AS INT))),0)
            FROM PICKDETAIL PD (NOLOCK)
            JOIN SKU (NOLOCK) ON PD.SKU = SKU.SKU AND PD.STORERKEY = SKU.STORERKEY
            LEFT JOIN PACK (NOLOCK) ON SKU.PACKKEY = PACK.PACKKEY AND PACK.CASECNT > 0
            WHERE PD.STORERKEY = @cStorerkey
            AND PD.ORDERKEY = @cOrderKey

            SET @nCaseCntOrd = ISNULL(@nCaseCntOrd,0)

            IF @nCaseCntOrd <= CAST(@cCustomerType5 AS INT)
            BEGIN
                SET @cPackMethod = 'CASE'
                SET @cCarrierFlag = 'Y'
            END

        END

        --PACKDETAIL
        --DECLARE @nCartonNo   INT = 0

        -- Get CartonNo, LabelLine
        IF @cPackMethod IN ('PALLET')
        BEGIN

            SET @nCartonNo = 0
            SET @cLabelLine = ''
            SET @cLabelNo = ''

            SELECT
                @nCartonNo = CartonNo,
                @cLabelLine = LabelLine,
                @cLabelNo   = LabelNo
            FROM dbo.PackDetail WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
                AND DropID = @cFromID
                AND SKU = @cSKU

            IF @cLabelLine = ''
            BEGIN
                SELECT @nCartonNo = CartonNo,
                    @cLabelNo   = LabelNo
                FROM dbo.PackDetail WITH (NOLOCK)
                WHERE PickSlipNo = @cPickSlipNo
                AND DropID = @cFromID

                IF @nCartonNo = 0
                    SET @cLabelLine = '00001'
                ELSE
                SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
                FROM dbo.PackDetail (NOLOCK)
                WHERE Pickslipno = @cPickSlipNo
                    AND DropID = @cFromID

                SET @cNewLine = 'Y'
            END

            -- PackDetail
            IF @cNewLine = 'Y'
            BEGIN
                -- Insert PackDetail
                IF @nCartonNo = 0
                BEGIN
                    SET @cLabelNo = ''
                    IF @cGenPackLabelNoSP <> ''
                    BEGIN
                        IF @cGenPackLabelNoSP = '1'
                        BEGIN
                            EXEC isp_GenUCCLabelNo
                                @cStorerKey,
                                @cLabelNo      OUTPUT,
                                @bSuccess      OUTPUT,
                                @nErrNo        OUTPUT,
                                @cErrMsg       OUTPUT
                            IF @nErrNo <> 0
                            BEGIN
                                SET @nErrNo = 262616
                                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
                                GOTO RollBackTran
                            END
                        END
                        ELSE IF @cGenPackLabelNoSP = 'DropIDWithZero'
                        BEGIN
                            SET @cLabelNo = '00'+@cFromID

                            IF EXISTS (SELECT TOP 1 1 FROM PACKDETAIL (NOLOCK) WHERE
                                        STORERKEY = @cStorerkey AND LABELNO = @cLabelNo)
                            BEGIN
                                SET @cLabelNo = ''
                                EXEC isp_GenUCCLabelNo
                                    @cStorerKey,
                                    @cLabelNo      OUTPUT,
                                    @bSuccess      OUTPUT,
                                    @nErrNo        OUTPUT,
                                    @cErrMsg       OUTPUT
                                IF @nErrNo <> 0
                                BEGIN
                                    SET @nErrNo = 262616
                                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
                                    GOTO RollBackTran
                                END
                            END
                        END
                        ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGenPackLabelNoSP AND type = 'P')
                        BEGIN
                            SET @cSQL = 'EXEC dbo.' + RTRIM( @cGenPackLabelNoSP) +
                                ' @cPickslipNo, ' +
                                ' @nCartonNo,   ' +
                                ' @cLabelNo OUTPUT '
                            SET @cSQLParam =
                                ' @cPickslipNo  NVARCHAR(10),       ' +
                                ' @nCartonNo    INT,                ' +
                                ' @cLabelNo     NVARCHAR(20) OUTPUT '
                            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                                @cPickslipNo,
                                @nCartonNo,
                                @cLabelNo OUTPUT
                        END

                        IF ISNULL(@cLabelNo,'') = ''
                        BEGIN
                            SET @cLabelNo = @cFromID

                            IF EXISTS (SELECT TOP 1 1 FROM PACKDETAIL (NOLOCK) WHERE
                                        STORERKEY = @cStorerkey AND LABELNO = @cLabelNo)
                                GOTO Quit
                        END
                    END
                    ELSE
                        GOTO Quit
                END

                INSERT INTO dbo.PackDetail
                (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,
                AddWho, AddDate, EditWho, EditDate)
                VALUES
                (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY, @cFromID,
                'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262617
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackDtlFail
                    GOTO RollBackTran
                END

                SELECT TOP 1
                    @nCartonNo = CartonNo
                    ,@cLabelLine = LabelLine
                FROM PackDetail WITH (NOLOCK)
                WHERE PickSlipNo = @cPickSlipNo
                    AND SKU = @cSKU
                    AND LabelNo = @cLabelNo
                    AND AddWho = 'rdt.' + SUSER_SNAME()
                ORDER BY CartonNo DESC -- max cartonno
            END
            ELSE
            BEGIN
                -- Update Packdetail
                UPDATE dbo.PackDetail WITH (ROWLOCK) SET
                    SKU = @cSKU,
                    QTY = QTY + @nQTY,
                    EditWho = 'rdt.' + SUSER_SNAME(),
                    EditDate = GETDATE(),
                    ArchiveCop = NULL
                WHERE PickSlipNo = @cPickSlipNo
                    AND CartonNo = @nCartonNo
                    AND LabelNo = @cLabelNo
                    AND LabelLine = @cLabelLine
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262618
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackDtlFail
                    GOTO RollBackTran
                END
            END

            --PackDetailInfo
            IF @cUpdatePackDetailInfo = '1'
            BEGIN
                SET @cPackData1 = @cLottable01
                SET @cPackData2 = ''
                SET @cPackData3 = ''

            -- Pack data
                IF @cPackData1 <> '' OR
                @cPackData2 <> '' OR
                @cPackData3 <> ''
                BEGIN

                -- Get PackDetailInfo
                SET @nPackDetailInfoKey = 0
                SELECT @nPackDetailInfoKey = PackDetailInfoKey
                FROM dbo.PackDetailInfo WITH (NOLOCK)
                WHERE PickSlipNo = @cPickSlipNo
                    AND CartonNo = @nCartonNo
                    AND LabelNo = @cLabelNo
                    AND SKU = @cSKU
                    AND UserDefine01 = @cPackData1
                    AND UserDefine02 = @cPackData2
                    AND UserDefine03 = @cPackData3

                IF @nPackDetailInfoKey = 0
                BEGIN
                    -- Insert PackDetailInfo
                    INSERT INTO dbo.PackDetailInfo (
                        PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, UserDefine01, UserDefine02, UserDefine03,
                        AddWho, AddDate, EditWho, EditDate)
                    VALUES (
                        @cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY, @cPackData1, @cPackData2, @cPackData3,
                        'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
                    IF @@ERROR <> 0
                    BEGIN
                        SET @nErrNo = 262619
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PDInfoFail
                        GOTO RollBackTran
                    END
                END
                ELSE
                BEGIN
                    -- Update PackDetailInfo
                    UPDATE dbo.PackDetailInfo WITH(ROWLOCK)
                    SET
                        QTY = QTY + @nQTY,
                        EditWho = 'rdt.' + SUSER_SNAME(),
                        EditDate = GETDATE(),
                        ArchiveCop = NULL
                    WHERE PackDetailInfoKey = @nPackDetailInfoKey

                    IF @@ERROR <> 0
                    BEGIN
                        SET @nErrNo = 262620
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PDInfoFail
                        GOTO RollBackTran
                    END
                END
                END
            END

            -- PackInfo
            SET @cCartonType = ''

            SELECT @cCartonType   = C.CartonType
                , @fLength       = CartonLength
                , @fWidth        = CartonWidth
                , @fHeight       = CartonHeight
                , @fCube         = CartonLength * CartonWidth * CartonHeight
                , @fCartonWeight = CartonWeight
            FROM Cartonization C WITH (NOLOCK)
            JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
            WHERE S.StorerKey = @cStorerKey
            AND C.CartonType = @cPalletType

            SET @fSKUWeight = 0

            IF @cDefaultWeight IN ('2', '3')
            BEGIN
                -- Weight (SKU only)
                SELECT @fSKUWeight = ISNULL( SKU.STDGrossWGT * @nQty, 0)
                FROM dbo.SKU SKU WITH (NOLOCK)
                WHERE SKU.STORERKEY = @cStorerKey
                AND SKU.SKU = @cSKU

                -- Weight (SKU + carton)
                --IF @cDefaultWeight = '3'
                --BEGIN
                --   -- Get carton type info
                --   SELECT @nCartonWeight = CartonWeight
                --   FROM Cartonization C WITH (NOLOCK)
                --      JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
                --   WHERE S.StorerKey = @cStorerKey
                --      AND C.CartonType = @cCartonType
                --
                --   SET @nWeight = @nWeight + @nCartonWeight
                --END
            END

            --SET @cWeight = rdt.rdtFormatFloat( @fSKUWeight)

            SET @fWeight = 0

            IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
            BEGIN

                IF @cDefaultWeight = '2'
                BEGIN
                    SET @fWeight = @fSKUWeight --SKU weight only
                END

                ELSE IF @cDefaultWeight = '3'
                BEGIN
                    SET @fWeight = @fSKUWeight + @fCartonWeight  -- SKU + carton weight
                END

                SET @cWeight = rdt.rdtFormatFloat( @fWeight)
                SET @fWeight = CAST(@cWeight AS FLOAT)

                INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, Qty, Weight, Cube, CartonType, Length, Width, Height)
                VALUES (@cPickSlipNo, @nCartonNo, @nQTY, @fWeight, @fCube, @cCartonType, @fLength, @fWidth, @fHeight)
                --INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY)
                --VALUES (@cPickSlipNo, @nCartonNo, @nQTY)
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262621
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail
                    GOTO RollBackTran
                END
            END
            ELSE
            BEGIN
                SET @cWeight = rdt.rdtFormatFloat( @fSKUWeight)
                SET @fSKUWeight = CAST(@cWeight AS FLOAT)

                UPDATE dbo.PackInfo SET
                    QTY = QTY + @nQTY,
                    EditDate = GETDATE(),
                    EditWho = SUSER_SNAME(),
                    Weight = Weight + @fWeight,
                    TrafficCop = NULL
                WHERE PickSlipNo = @cPickSlipNo
                    AND CartonNo = @nCartonNo
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262622
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
                    GOTO RollBackTran
                END
            END

            --SUBMIT PRINT JOB
            IF ISNULL(@cLabelPrinter,'') <> ''
            BEGIN
                IF @cShipLabel <> ''
                BEGIN
                IF @cShipLabel = 'CstLabelSP'
                BEGIN
                    SET @cCstLabelSP = rdt.RDTGetConfig( @nFunc, 'CstLabelSP', @cStorerKey)
                    IF @cCstLabelSP = '0'
                        SET @cCstLabelSP = ''
                    IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cCstLabelSP AND type = 'P')  --Customize Print Label
                    BEGIN
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cCstLabelSP) +
                            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +
                            ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +
                            ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +
                            ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                        SET @cSQLParam =
                            '@nMobile         INT,           ' +
                            '@nFunc           INT,           ' +
                            '@cLangCode       NVARCHAR( 3),  ' +
                            '@nStep           INT,           ' +
                            '@nInputKey       INT,           ' +
                            '@cFacility       NVARCHAR( 5),  ' +
                            '@cStorerKey      NVARCHAR( 15), ' +
                            '@cPickSlipNo     NVARCHAR( 10), ' +
                            '@cFromDropID     NVARCHAR( 20), ' +
                            '@nCartonNo       INT,           ' +
                            '@cLabelNo        NVARCHAR( 20), ' +
                            '@cSKU            NVARCHAR( 20), ' +
                            '@nQTY            INT,           ' +
                            '@cUCCNo          NVARCHAR( 20), ' +
                            '@cCartonType     NVARCHAR( 10), ' +
                            '@cCube           NVARCHAR( 10), ' +
                            '@cWeight         NVARCHAR( 10), ' +
                            '@cRefNo          NVARCHAR( 20), ' +
                            '@cSerialNo       NVARCHAR( 30), ' +
                            '@nSerialQTY      INT,           ' +
                            '@cOption         NVARCHAR( 1),  ' +
                            '@cPackDtlRefNo   NVARCHAR( 20), ' +
                            '@cPackDtlRefNo2  NVARCHAR( 20), ' +
                            '@cPackDtlUPC     NVARCHAR( 30), ' +
                            '@cPackDtlDropID  NVARCHAR( 20), ' +
                            '@cPackData1      NVARCHAR( 30), ' +
                            '@cPackData2      NVARCHAR( 30), ' +
                            '@cPackData3      NVARCHAR( 30), ' +
                            '@nErrNo          INT            OUTPUT, ' +
                            '@cErrMsg         NVARCHAR( 20)  OUTPUT'

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromID,
                            @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, '', '', '', '1',
                            '', '', '', @cFromID, @cPackData1, @cPackData2, @cPackData3,
                            @nErrNo OUTPUT, @cErrMsg OUTPUT

                        --IF @nErrNo <> 0
                        --   GOTO Quit
                    END
                END
                ELSE
                BEGIN  --Standard Print
                    -- Common params
                    DELETE FROM @tShipLabel

                    IF ISNULL(@cPrintCopy,'') <> '' AND ISNUMERIC(@cPrintCopy) = 1
                        SET @nNoOfCopy = CAST(@cPrintCopy AS INT)
                    ELSE
                        SET @nNoOfCopy = 1

                    INSERT INTO @tShipLabel (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cPickSlipNo',    @cPickSlipNo),
                        ( '@cFromDropID',    @cFromID),
                        ( '@cPackDtlDropID', @cFromID),
                        ( '@cLabelNo',       @cLabelNo),
                        ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

                    -- Print label
                    EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        @cShipLabel, -- Report type
                        @tShipLabel, -- Report params
                        'rdt_1770ConfirmAU01',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT,
                        @nNoOfCopy
                    --IF @nErrNo <> 0
                    --   GOTO Quit
                END
                END

                -- Carton manifest
                IF @cCartonManifest <> ''
                BEGIN
                    -- Common params
                    DELETE FROM @tCartonManifest

                    INSERT INTO @tCartonManifest (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cPickSlipNo',    @cPickSlipNo),
                        ( '@cFromDropID',    @cFromID),
                        ( '@cPackDtlDropID', @cFromID),
                        ( '@cLabelNo',       @cLabelNo),
                        ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

                    -- Print label
                    EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        @cCartonManifest, -- Report type
                        @tCartonManifest, -- Report params
                        'rdt_1770ConfirmAU01',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                    --IF @nErrNo <> 0
                    --   GOTO Quit
                END
            END

            IF ISNULL(@cDropID,'') <> ''
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM dbo.Pallet WITH (NOLOCK) WHERE Palletkey = @cFromID)
                BEGIN
                IF ISNULL(@cPalletType,'') = ''
                    SET @cPalletType = 'PALLET'

                --Calculate Height based on Ti Hi
                SET @nSumPackInfoWgt = 0.0

                SELECT @nSumPackInfoWgt = ISNULL(SUM(ISNULL(PIF.WEIGHT,0)),0)
                        , @nPalletHeight   = 12 + ISNULL(MAX(ISNULL(PACKD.ESTHEIGHT,0)),0)
                FROM PackInfo PIF (NOLOCK)
                CROSS APPLY (
                    SELECT PICKSLIPNO,CARTONNO,
                    SUM(CEILING(PD.QTY / IIF(PACK.CASECNT>0,PACK.CASECNT,1)/ IIF(PACK.PALLETTI>0,PACK.PALLETTI,1))
                        *PACK.HEIGHTUOM1) AS ESTHEIGHT
                    FROM PACKDETAIL PD (NOLOCK)
                    JOIN SKU (NOLOCK) ON PD.SKU = SKU.SKU AND PD.STORERKEY = SKU.StorerKey
                    JOIN PACK (NOLOCK) ON SKU.PACKKEY = PACK.PACKKEY
                    WHERE PD.STORERKEY = @cStorerKey
                        AND   PD.DropID = @cFromID
                        AND   PD.PICKSLIPNO = @cPickSlipNo
                    AND   ISNULL(@cFromID,'') <> ''
                    GROUP BY PICKSLIPNO,CARTONNO
                ) as PACKD
                WHERE PIF.PICKSLIPNO = PACKD.PICKSLIPNO AND PIF.CARTONNO = PACKD.CARTONNO

                SET @nPalletWeight = ISNULL(@nPalletWeight,45) + ISNULL(@nSumPackInfoWgt,0)
                SET @nPalletHeight = CASE WHEN ISNULL(@nPalletHeight,116) > 160 THEN 160
                                            WHEN ISNULL(@nPalletHeight,116) <= 13 THEN 120
                                            ELSE ISNULL(@nPalletHeight,116) END

                INSERT dbo.Pallet (PalletKey, StorerKey, PalletType, Status, Length, Width, Height, GrossWgt)
                SELECT @cFromID, @cStorerkey, @cPalletType, '0', '116','116',@nPalletHeight,@nPalletWeight
                END

                IF NOT EXISTS( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE PalletKey = @cFromID)
                BEGIN
                /*INC7331096 (START)*/
                SELECT @cPalletLineNumber = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( PalletLineNumber), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
                FROM dbo.PalletDetail WITH (NOLOCK)
                WHERE PalletKey = @cFromID

                INSERT INTO dbo.PalletDetail (PalletKey, PalletLineNumber, CaseID, StorerKey, SKU, LOC, Qty, Status, UserDefine01, UserDefine03, ArchiveCop, UserDefine02)
                VALUES (@cFromID, @cPalletLineNumber, @cLabelNo, @cStorerKey, @cSKU, @cFinalLOC, @nQty, '0', @cOrderKey, @cDropID, NULL, @cLabelNo)
                /*INC7331096 (END)*/

                /*
                INSERT INTO dbo.PalletDetail (PalletKey, PalletLineNumber, CaseID, StorerKey, SKU, LOC, QTY, Status, UserDefine01, UserDefine03, ArchiveCop)
                VALUES (@cFromID, '00001', @cLabelNo, @cStorerKey, @cSKU, @cFinalLOC, @nPackQTY, '9', @cOrderKey, @cDropID, '9')
                */
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262623
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPLTDtlFail
                    GOTO RollBackTran
                END
                END
            END
        END --IF PACKMETHOD = 'PALLET'
        ELSE IF @cPackMethod IN ('CASE') AND @fPDCaseCnt > 0 --CASE METHOD
        BEGIN

            DECLARE @nCaseLoop    INT = 0
            DECLARE @nCasePackQty INT = 0
            DECLARE @nCheckSumQty INT = 0

            SET @nCasePackQty = CAST(@fPDCaseCnt AS INT)

            SELECT @nCaseLoop = CAST(FLOOR(@nQty/CAST(@nCasePackQty AS FLOAT)) AS INT)


            WHILE @nCaseLoop > 0 AND @nCasePackQty > 0 AND @nCheckSumQty < @nQty
            BEGIN

                SET @cNewLine = 'Y'
                SET @nCartonNo = 0
                SET @cLabelLine = '00001'

                -- Insert PackDetail
                IF @nCartonNo = 0
                BEGIN
                    SET @cLabelNo = ''
                    IF @cGenPackLabelNoSP <> ''
                    BEGIN
                        IF @cGenPackLabelNoSP = '1'
                        BEGIN
                            EXEC isp_GenUCCLabelNo
                                @cStorerKey,
                                @cLabelNo      OUTPUT,
                                @bSuccess      OUTPUT,
                                @nErrNo        OUTPUT,
                                @cErrMsg       OUTPUT
                            IF @nErrNo <> 0
                            BEGIN
                                SET @nErrNo = 262616
                                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
                                GOTO RollBackTran
                            END
                        END
                        ELSE IF @cGenPackLabelNoSP = 'DropIDWithZero'
                        BEGIN
                            --still generate each carton
                            EXEC isp_GenUCCLabelNo
                                @cStorerKey,
                                @cLabelNo      OUTPUT,
                                @bSuccess      OUTPUT,
                                @nErrNo        OUTPUT,
                                @cErrMsg       OUTPUT
                            IF @nErrNo <> 0
                            BEGIN
                                SET @nErrNo = 262616
                                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
                                GOTO RollBackTran
                            END
                        END
                        ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGenPackLabelNoSP AND type = 'P')
                        BEGIN
                            SET @cSQL = 'EXEC dbo.' + RTRIM( @cGenPackLabelNoSP) +
                                ' @cPickslipNo, ' +
                                ' @nCartonNo,   ' +
                                ' @cLabelNo     OUTPUT '
                            SET @cSQLParam =
                                ' @cPickslipNo  NVARCHAR(10),       ' +
                                ' @nCartonNo    INT,                ' +
                                ' @cLabelNo     NVARCHAR(20) OUTPUT '
                            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                                @cPickslipNo,
                                @nCartonNo,
                                @cLabelNo OUTPUT
                        END

                        IF ISNULL(@cLabelNo,'') = ''
                        BEGIN
                            SET @nCaseLoop = -1
                            GOTO Quit
                        END
                    END
                    ELSE
                        GOTO Quit
                END

                INSERT INTO dbo.PackDetail
                (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,
                AddWho, AddDate, EditWho, EditDate)
                VALUES
                (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nCasePackQty, @cFromID,
                'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262617
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackDtlFail
                    GOTO RollBackTran
                END

                SELECT TOP 1
                    @nCartonNo = CartonNo
                    ,@cLabelLine = LabelLine
                FROM PackDetail WITH (NOLOCK)
                WHERE PickSlipNo = @cPickSlipNo
                    AND SKU = @cSKU
                    AND LabelNo = @cLabelNo
                    AND AddWho = 'rdt.' + SUSER_SNAME()
                ORDER BY CartonNo DESC -- max cartonno


            --PackDetailInfo
            IF @cUpdatePackDetailInfo = '1'
            BEGIN
                SET @cPackData1 = @cLottable01
                SET @cPackData2 = ''
                SET @cPackData3 = ''

                -- Pack data
                IF @cPackData1 <> '' OR
                    @cPackData2 <> '' OR
                    @cPackData3 <> ''
                BEGIN
                    SET @nPackDetailInfoKey = 0
                -- Insert PackDetailInfo
                INSERT INTO dbo.PackDetailInfo (
                    PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, UserDefine01, UserDefine02, UserDefine03,
                    AddWho, AddDate, EditWho, EditDate)
                VALUES (
                    @cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nCasePackQty, @cPackData1, @cPackData2, @cPackData3,
                    'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262619
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PDInfoFail
                    GOTO RollBackTran
                END
                END
            END

                SET @cCartonType = ''

                SELECT @cCartonType   = C.CartonType
                    , @fLength       = CartonLength
                    , @fWidth        = CartonWidth
                    , @fHeight       = CartonHeight
                    , @fCube         = CartonLength * CartonWidth * CartonHeight
                    , @fCartonWeight = CartonWeight
                FROM Cartonization C WITH (NOLOCK)
                JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
                WHERE S.StorerKey = @cStorerKey
                AND C.CartonType = CASE WHEN ISNULL(@cDefaultcartontype,'') <> '' THEN @cDefaultcartontype ELSE 'MFCARTON' END

                SET @cCartonType = ISNULL(@cCartonType,'')

                SET @fSKUWeight = 0
                SET @fWeight = 0

                IF @cDefaultWeight IN ('2', '3')
                BEGIN
                    -- Weight (SKU only)
                    SELECT @fSKUWeight = ISNULL(SKU.STDGrossWGT*@nCasePackQty,0)
                    FROM dbo.SKU SKU WITH (NOLOCK)
                    WHERE SKU.STORERKEY = @cStorerKey
                    AND SKU.SKU = @cSKU

                    -- Weight (SKU + carton)
                    IF @cDefaultWeight = '3'
                    BEGIN
                        SET @fSKUWeight = @fSKUWeight + @fCartonWeight
                    END
                END

                IF @cCartonType = 'MFCARTON' --MANUFACTURER CARTON GET FROM PACKUOM1 DIMENSIONS INSTEAD
                BEGIN
                    SELECT
                        @fLength = Pack.LengthUOM1,
                        @fWidth = Pack.WidthUOM1,
                        @fHeight = Pack.HeightUOM1,
                        @fCube = Pack.LengthUOM1 * Pack.WidthUOM1 * Pack.HeightUOM1
                    FROM dbo.Pack WITH (NOLOCK)
                    JOIN dbo.SKU WITH (NOLOCK) ON SKU.PackKey = Pack.PackKey
                    WHERE SKU.StorerKey = @cStorerKey
                    AND SKU.SKU = @cSKU
                END

                SET @cWeight = rdt.rdtFormatFloat( @fSKUWeight)

                SET @fWeight = CAST(@cWeight AS FLOAT)

                INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, Qty, Weight, Cube, CartonType, Length, Width, Height)
                VALUES (@cPickSlipNo, @nCartonNo, @nCasePackQty, @fWeight, @fCube, @cCartonType, @fLength, @fWidth, @fHeight)
                --INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY)
                --VALUES (@cPickSlipNo, @nCartonNo, @nQTY)
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262621
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPackInfFail
                    GOTO RollBackTran
                END


                SET @nCaseLoop = @nCaseLoop - 1
                SET @nCheckSumQty = @nCheckSumQty + @nCasePackQty

                SET @cLength  = CAST(@fLength AS NVARCHAR(10))
                SET @cWidth   = CAST(@fWidth  AS NVARCHAR(10))
                SET @cHeight  = CAST(@fHeight AS NVARCHAR(10))
                SET @cCube    = CAST(@fCube   AS NVARCHAR(10))
                SET @cWeight  = CAST(@fWeight AS NVARCHAR(10))


                --Submit Print Job for each cases
                IF ISNULL(@cLabelPrinter,'') <> ''
                BEGIN
                    IF @cShipLabel <> ''
                    BEGIN
                        IF @cShipLabel = 'CstLabelSP'
                    BEGIN
                        SET @cCstLabelSP = rdt.RDTGetConfig( @nFunc, 'CstLabelSP', @cStorerKey)
                        IF @cCstLabelSP = '0'
                            SET @cCstLabelSP = ''
                        IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cCstLabelSP AND type = 'P')  --Customize Print Label
                        BEGIN
                            SET @cSQL = 'EXEC rdt.' + RTRIM( @cCstLabelSP) +
                            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, ' +
                            ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, @cRefNo, @cSerialNo, @nSerialQTY, @cOption, ' +
                            ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlUPC, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +
                            ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                            SET @cSQLParam =
                            '@nMobile         INT,           ' +
                            '@nFunc           INT,           ' +
                            '@cLangCode       NVARCHAR( 3),  ' +
                            '@nStep           INT,           ' +
                            '@nInputKey       INT,           ' +
                            '@cFacility       NVARCHAR( 5),  ' +
                            '@cStorerKey      NVARCHAR( 15), ' +
                            '@cPickSlipNo     NVARCHAR( 10), ' +
                            '@cFromDropID     NVARCHAR( 20), ' +
                            '@nCartonNo       INT,           ' +
                            '@cLabelNo        NVARCHAR( 20), ' +
                            '@cSKU            NVARCHAR( 20), ' +
                            '@nQTY            INT,           ' +
                            '@cUCCNo          NVARCHAR( 20), ' +
                            '@cCartonType     NVARCHAR( 10), ' +
                            '@cCube           NVARCHAR( 10), ' +
                            '@cWeight         NVARCHAR( 10), ' +
                            '@cRefNo          NVARCHAR( 20), ' +
                            '@cSerialNo       NVARCHAR( 30), ' +
                            '@nSerialQTY      INT,           ' +
                            '@cOption         NVARCHAR( 1),  ' +
                            '@cPackDtlRefNo   NVARCHAR( 20), ' +
                            '@cPackDtlRefNo2  NVARCHAR( 20), ' +
                            '@cPackDtlUPC     NVARCHAR( 30), ' +
                            '@cPackDtlDropID  NVARCHAR( 20), ' +
                            '@cPackData1      NVARCHAR( 30), ' +
                            '@cPackData2      NVARCHAR( 30), ' +
                            '@cPackData3      NVARCHAR( 30), ' +
                            '@nErrNo          INT            OUTPUT, ' +
                            '@cErrMsg         NVARCHAR( 20)  OUTPUT'

                            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                                @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromID,
                                @nCartonNo, @cLabelNo, @cSKU, @nCasePackQty, @cUCCNo, @cCartonType, @cCube, @cWeight, '', '', '', '1',
                                '', '', '', @cFromID, @cPackData1, @cPackData2, @cPackData3,
                                @nErrNo OUTPUT, @cErrMsg OUTPUT

                            --IF @nErrNo <> 0
                            --   GOTO Quit
                        END
                    END
                    ELSE
                    BEGIN  --Standard Print
                        -- Common params
                        DELETE FROM @tShipLabel

                        IF ISNULL(@cPrintCopy,'') <> '' AND ISNUMERIC(@cPrintCopy) = 1
                            SET @nNoOfCopy = CAST(@cPrintCopy AS INT)
                        ELSE
                            SET @nNoOfCopy = 1

                        INSERT INTO @tShipLabel (Variable, Value) VALUES
                            ( '@cStorerKey',     @cStorerKey),
                            ( '@cPickSlipNo',    @cPickSlipNo),
                            ( '@cFromDropID',    @cFromID),
                            ( '@cPackDtlDropID', @cFromID),
                            ( '@cLabelNo',       @cLabelNo),
                            ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

                        -- Print label
                        EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                            @cShipLabel, -- Report type
                            @tShipLabel, -- Report params
                            'rdt_1770ConfirmAU01',
                            @nErrNo  OUTPUT,
                            @cErrMsg OUTPUT,
                            @nNoOfCopy
                        --IF @nErrNo <> 0
                        --   GOTO Quit
                    END
                END

                -- Carton manifest
                IF @cCartonManifest <> ''
                BEGIN
                    -- Common params
                    DELETE FROM @tCartonManifest
                    INSERT INTO @tCartonManifest (Variable, Value) VALUES
                        ( '@cStorerKey',     @cStorerKey),
                        ( '@cPickSlipNo',    @cPickSlipNo),
                        ( '@cFromDropID',    @cFromID),
                        ( '@cPackDtlDropID', @cFromID),
                        ( '@cLabelNo',       @cLabelNo),
                        ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

                    -- Print label
                    EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        @cCartonManifest, -- Report type
                        @tCartonManifest, -- Report params
                        'rdt_1770ConfirmAU01',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
                    --IF @nErrNo <> 0
                    --   GOTO Quit
                END
                END

                IF ISNULL(@cDropID,'') <> ''
                BEGIN

                    IF NOT EXISTS (SELECT 1 FROM dbo.Pallet WITH (NOLOCK) WHERE Palletkey = @cFromID)
                BEGIN
                    IF ISNULL(@cPalletType,'') = ''
                        SET @cPalletType = 'PALLET'

                    --Calculate Height based on Ti Hi
                    SET @nSumPackInfoWgt = 0.0

                    SELECT @nSumPackInfoWgt = ISNULL(SUM(ISNULL(PIF.WEIGHT,0)),0)
                        , @nPalletHeight   = 12 + ISNULL(MAX(ISNULL(PACKD.ESTHEIGHT,0)),0)
                    FROM PackInfo PIF (NOLOCK)
                    CROSS APPLY (
                        SELECT PICKSLIPNO,CARTONNO,
                        SUM(CEILING(PD.QTY / IIF(PACK.CASECNT>0,PACK.CASECNT,1)/ IIF(PACK.PALLETTI>0,PACK.PALLETTI,1))
                            *PACK.HEIGHTUOM1) AS ESTHEIGHT
                        FROM PACKDETAIL PD (NOLOCK)
                        JOIN SKU (NOLOCK) ON PD.SKU = SKU.SKU AND PD.STORERKEY = SKU.StorerKey
                        JOIN PACK (NOLOCK) ON SKU.PACKKEY = PACK.PACKKEY
                        WHERE PD.STORERKEY = @cStorerKey
                        AND   PD.DropID = @cFromID
                        AND   PD.PICKSLIPNO = @cPickSlipNo
                        AND   ISNULL(@cFromID,'') <> ''
                        GROUP BY PICKSLIPNO,CARTONNO
                    ) as PACKD
                    WHERE PIF.PICKSLIPNO = PACKD.PICKSLIPNO AND PIF.CARTONNO = PACKD.CARTONNO

                    SET @nPalletWeight = ISNULL(@nPalletWeight,45) + ISNULL(@nSumPackInfoWgt,0)
                    SET @nPalletHeight = CASE WHEN ISNULL(@nPalletHeight,116) > 160 THEN 160
                                                WHEN ISNULL(@nPalletHeight,116) <= 13 THEN 120
                                                ELSE ISNULL(@nPalletHeight,116) END
                    INSERT dbo.Pallet (PalletKey, StorerKey, PalletType, Status, Length, Width, Height, GrossWgt)
                    SELECT @cFromID, @cStorerkey, @cPalletType, '0', '116','116',@nPalletHeight,@nPalletWeight
                    END

                IF NOT EXISTS( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE PalletKey = @cFromID AND CASEID = @cLabelNo)
                BEGIN
                /*INC7331096 (START)*/
                    SELECT @cPalletLineNumber = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( PalletLineNumber), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
                    FROM dbo.PalletDetail WITH (NOLOCK)
                    WHERE PalletKey = @cFromID

                    INSERT INTO dbo.PalletDetail (PalletKey, PalletLineNumber, CaseID, StorerKey, SKU, LOC, Qty, Status, UserDefine01, UserDefine03, ArchiveCop, UserDefine02)
                    VALUES (@cFromID, @cPalletLineNumber, @cLabelNo, @cStorerKey, @cSKU, @cFinalLOC, @nQty, '0', @cOrderKey, @cDropID, NULL, @cLabelNo)
                    /*INC7331096 (END)*/

                    /*
                    INSERT INTO dbo.PalletDetail (PalletKey, PalletLineNumber, CaseID, StorerKey, SKU, LOC, QTY, Status, UserDefine01, UserDefine03, ArchiveCop)
                    VALUES (@cFromID, '00001', @cLabelNo, @cStorerKey, @cSKU, @cFinalLOC, @nPackQTY, '9', @cOrderKey, @cDropID, '9')
                    */
                    IF @@ERROR <> 0
                    BEGIN
                        SET @nErrNo = 262623
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPLTDtlFail
                        GOTO RollBackTran
                    END
                END
                END
            END --case loop

            IF EXISTS (SELECT 1 FROM dbo.Pallet WITH (NOLOCK) WHERE Palletkey = @cFromID AND STORERKEY = @cStorerKey AND STATUS = '0')
            BEGIN
                --Calculate Height based on Ti Hi
                SET @nSumPackInfoWgt = 0.0

                SELECT @nSumPackInfoWgt = ISNULL(SUM(ISNULL(PIF.WEIGHT,0)),0)
                    , @nPalletHeight   = 12 + ISNULL(MAX(ISNULL(PACKD.ESTHEIGHT,0)),0)
                FROM PackInfo PIF (NOLOCK)
                CROSS APPLY (
                    SELECT PICKSLIPNO,CARTONNO,
                    SUM(CEILING(PD.QTY / IIF(PACK.CASECNT>0,PACK.CASECNT,1)/ IIF(PACK.PALLETTI>0,PACK.PALLETTI,1))
                        *PACK.HEIGHTUOM1) AS ESTHEIGHT
                    FROM PACKDETAIL PD (NOLOCK)
                    JOIN SKU (NOLOCK) ON PD.SKU = SKU.SKU AND PD.STORERKEY = SKU.StorerKey
                    JOIN PACK (NOLOCK) ON SKU.PACKKEY = PACK.PACKKEY
                    WHERE PD.STORERKEY = @cStorerKey
                    AND   PD.DropID = @cFromID
                    AND   PD.PICKSLIPNO = @cPickSlipNo
                    AND   ISNULL(@cFromID,'') <> ''
                    GROUP BY PICKSLIPNO,CARTONNO
                ) as PACKD
                WHERE PIF.PICKSLIPNO = PACKD.PICKSLIPNO AND PIF.CARTONNO = PACKD.CARTONNO

                SET @nPalletWeight = ISNULL(@nPalletWeight,45) + ISNULL(@nSumPackInfoWgt,0)
                SET @nPalletHeight = CASE WHEN ISNULL(@nPalletHeight,116) > 160 THEN 160
                                        WHEN ISNULL(@nPalletHeight,116) <= 13 THEN 120
                                        ELSE ISNULL(@nPalletHeight,116) END

                UPDATE dbo.Pallet WITH (ROWLOCK)
                    SET Height = @nPalletHeight
                    , GrossWgt = @nPalletWeight
                WHERE Palletkey = @cFromID
                    AND STORERKEY = @cStorerKey
                    AND STATUS = '0'
            END
        END

        -- Get MBOL info
        IF ISNULL(@cDropID,'') <> ''
        BEGIN
            DECLARE @cMBOLKey NVARCHAR( 10) = ''
            SELECT @cMBOLKey = MBOLKey
            FROM dbo.MBOL WITH (NOLOCK)
            WHERE Facility = @cFacility
                AND Status < '9'
                AND ExternMBOLKey = @cDropID

            -- MBOL
            IF @cMBOLKey = ''
            BEGIN
                DECLARE @nSuccess INT = 1
                EXECUTE dbo.nspg_getkey
                    'MBOL'                 , 10
                    , @cMBOLKey    OUTPUT
                    , @nSuccess    OUTPUT
                    , @nErrNo      OUTPUT
                    , @cErrMsg     OUTPUT

                INSERT INTO dbo.MBOL (
                    MBOLKey, ExternMBOLKey, Facility, Status, AddWho, AddDate, EditWho, EditDate)
                VALUES
                    (@cMBOLKey, @cDropID, @cFacility, '0', 'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262624
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS MBOL Fail
                    GOTO RollBackTran
                END
            END

            IF NOT EXISTS( SELECT 1 FROM dbo.MBOLDetail WITH (NOLOCK) WHERE MBOLKey = @cMBOLKey AND OrderKey = @cOrderKey)
            BEGIN
                INSERT INTO dbo.MBOLDetail
                (MBOLKey, MBOLLineNumber, OrderKey, LoadKey, AddWho, AddDate, EditWho, EditDate)
                VALUES
                (@cMBOLKey, '00000', @cOrderKey, '', 'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
                IF @@ERROR <> 0
                BEGIN
                    SET @nErrNo = 262625
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS MBDtl Fail
                    GOTO RollbackTran
                END
            END

            IF ISNULL(@cManiLaneLBL,'') <> '' AND ISNULL(@cLabelPrinter,'') <> ''
            BEGIN

                SELECT @cExternOrderkey = EXTERNORDERKEY
                FROM ORDERS (NOLOCK)
                WHERE ORDERKEY = @cOrderKey

                INSERT INTO @tManiLaneLBL (Variable, Value) VALUES
                    ( '@cStorerKey', @cStorerKey),
                    ( '@cManifestLane',    @cDropID),
                    ( '@cExternOrderkey',  @cExternOrderkey),
                    ( '@cDropID',    @cFromID)

                -- Print label
                EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, '1', @cFacility, @cStorerKey, @cLabelPrinter, '',
                    @cManiLaneLBL, -- Report type
                    @tManiLaneLBL, -- Report params
                    'rdt_1770ConfirmAU01',
                    @nErrNo  OUTPUT,
                    @cErrMsg OUTPUT
            END
        END

    END

    /***********************************************************************************************
                                                Pack confirm
    ***********************************************************************************************/

    IF ISNULL(@cFromID,'') <> ''
    BEGIN
        -- Update PickDetail, base on PackDetail.DropID
        EXEC isp_AssignPackLabelToPickByDropIDAU
            @cPickSlipNo
            ,@cFromID
            ,@bSuccess OUTPUT
            ,@nErrNo   OUTPUT
            ,@cErrMsg  OUTPUT
        IF @nErrNo <> 0
            GOTO RollBackTran
    END

    -- PickHeader (needed by the rdt_Pack_PackConfirm in below)
    IF NOT EXISTS( SELECT 1 FROM dbo.PickHeader WITH (NOLOCK) WHERE PickHeaderKey = @cPickSlipNo)
    BEGIN
        INSERT INTO dbo.PickHeader (PickHeaderKey, OrderKey)
        VALUES (@cPickSlipNo, @cOrderKey)
        IF @@ERROR <> 0
        BEGIN
            SET @nErrNo = 262626
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSPKHdrFail
            GOTO RollBackTran
        END
    END

    -- Pack confirm
    EXEC rdt.rdt_Pack_PackConfirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
        ,@cPickSlipNo
        ,'' -- @cFromDropID
        ,'' -- @cPackDtlDropID
        ,'' -- @cPrintPackList
        ,@nErrNo  OUTPUT
        ,@cErrMsg OUTPUT
    IF @nErrNo <> 0
        GOTO RollBackTran

    IF EXISTS (SELECT TOP 1 1 FROM PACKHEADER (NOLOCK) WHERE PICKSLIPNO = @cPickSlipNo AND STATUS = '9')
    BEGIN
        DECLARE @cPackList NVARCHAR( 10)

        SET @cPackList = rdt.RDTGetConfig( @nFunc, 'PackList', @cStorerKey)
        IF @cPackList = '0'
            SET @cPackList = ''

        IF @cPackList <> ''
        BEGIN
            DECLARE @tPackList AS VariableTable
            INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)
            INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)
            INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)
        END

        IF @cPackList <> '' AND ISNULL(@cLabelPrinter,'') <> ''
        BEGIN
            IF EXISTS (SELECT TOP 1 1 FROM RDT.RDTREPORTTOPRINTER (NOLOCK)
                        WHERE PRINTERGROUP = ISNULL(@cLabelPrinter,'')
                        AND FUNCTION_ID = @nFunc
                        AND REPORTTYPE = @cPackList)
            BEGIN
                --DECLARE @tPackList AS VariableTable
                --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)
                --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)
                --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)

                -- Print label
                EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,
                    @cPackList, -- Report type
                    @tPackList, -- Report params
                    'rdt_1770ConfirmAU01',
                    @nErrNo  OUTPUT,
                    @cErrMsg OUTPUT
            END
            ELSE IF @cPackList <> '' AND ISNULL(@cPaperPrinter,'') <> ''
            BEGIN
                --DECLARE @tPackList AS VariableTable
                --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)
                --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)
                --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)

                -- Print label
                EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,
                    @cPackList, -- Report type
                    @tPackList, -- Report params
                    'rdt_1770ConfirmAU01',
                    @nErrNo  OUTPUT,
                    @cErrMsg OUTPUT
            END -- Packlist <> ''
        END -- Packlist <> ''
        ELSE IF @cPackList <> '' AND ISNULL(@cPaperPrinter,'') <> ''
        BEGIN
            --DECLARE @tPackList AS VariableTable
            --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)
            --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)
            --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo)

            -- Print label
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,
                @cPackList, -- Report type
                @tPackList, -- Report params
                'rdt_1770ConfirmAU01',
                @nErrNo  OUTPUT,
                @cErrMsg OUTPUT
        END -- Packlist <> ''
    END

    IF ISNULL(@cClosePalletFlag,'') = '1'
    BEGIN

        SET @cPLTUDF05 = ''

        SELECT TOP 1 @cPLTUDF05 = P.PALLETKEY
        FROM PALLET P WITH (NOLOCK)
        JOIN PALLETDETAIL PLD WITH (NOLOCK) ON P.PALLETKEY = PLD.Palletkey
        WHERE PLD.USERDEFINE01 = @cOrderKey
        AND P.STATUS = '9'
        AND ISNULL(USERDEFINE05,'') = ''

        IF ISNULL(@cPLTUDF05,'') = ''
            SELECT TOP 1 @cPLTUDF05 = PLD.USERDEFINE05
            FROM PALLET P WITH (NOLOCK)
            JOIN PALLETDETAIL PLD WITH (NOLOCK) ON P.PALLETKEY = PLD.Palletkey
            WHERE PLD.USERDEFINE01 = @cOrderKey
            AND P.STATUS = '9'
            AND ISNULL(USERDEFINE05,'') <> ''

        UPDATE dbo.PALLETDETAIL SET
            UserDefine05 = @cPLTUDF05,
            TrafficCop = NULL,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
        WHERE PalletKey = @cFromID

        IF @@ERROR <> 0
        BEGIN
            SET @nErrNo = 262627
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PLTDL Err
            GOTO RollBackTran
        END

        UPDATE dbo.PALLET WITH (ROWLOCK)
        SET STATUS = '9'
        WHERE PALLETKEY = @cFromID

        IF @@ERROR <> 0
        BEGIN
            SET @nErrNo = 262628
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPLTHdrFail
            GOTO RollBackTran
        END
    END

    DECLARE @cPalletLabel        NVARCHAR( 10)

    DECLARE @tPalletLabel  AS VariableTable

    SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'PalletLabel', @cStorerKey)
    IF @cPalletLabel = '0'
        SET @cPalletLabel = ''

    IF EXISTS (SELECT TOP 1 1 FROM PALLET WITH (NOLOCK) WHERE PALLETKEY = @cFromID)
    BEGIN

        IF ISNULL(@cPalletLabel,'') <> '' AND ISNULL(@cLabelPrinter,'') <> ''
        BEGIN

            INSERT INTO @tPalletLabel (Variable, Value) VALUES
            ( '@cStorerKey',     @cStorerKey),
            ( '@cPalletKey',    @cFromID)

            -- Print label
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
            @cPalletLabel, -- Report type
            @tPalletLabel, -- Report params
            'rdt_1770ConfirmAU01',
            @nErrNo  OUTPUT,
            @cErrMsg OUTPUT

            SET @nErrNo = 0
            SET @cErrMsg = ''

        END
    END

    IF ISNULL(@cCarrierFlag,'') = 'Y'
    BEGIN
        EXEC [dbo].[isp_Carrier_Middleware_Interface]
            @c_OrderKey    = @cOrderKey
        , @c_Mbolkey     = ''
        , @c_FunctionID  = @nFunc
        , @n_CartonNo    = @nCartonNo
        , @n_Step        = @nStep
        , @b_Success     = @bSuccess  OUTPUT
        , @n_Err         = @nErrNo    OUTPUT
        , @c_ErrMsg      = @cErrMsg   OUTPUT
    END

    EXEC RDT.rdt_STD_EventLog
        @cActionType    = '3', -- Picking
        @cUserID        = @cUserName,
        @nMobileNo      = @nMobile,
        @nFunctionID    = @nFunc,
        @cFacility      = @cFacility,
        @cStorerKey     = @cStorerKey,
        @cLocation      = @cFromLOC,
        @cToLocation    = @cFinalLOC,
        @cID            = @cFromID,
        @cToID          = @cFromID,
        @cDropID        = @cDropID,
        @cTaskDetailKey = @cTaskDetailKey,
        @cSKU           = @cSKU,
        @nQTY           = @nQTY

    -- Create next task
    EXEC rdt.rdt_TM_PalletPick_CreateNextTask @nMobile, @nFunc, @cLangCode,
        @cUserName,
        @cListKey,
        @nErrNo  OUTPUT,
        @cErrMsg OUTPUT
    IF @nErrNo <> 0
        GOTO RollBackTran

    COMMIT TRAN rdt_1770ConfirmAU01 -- Only commit change made here
    GOTO Quit

RollBackTran:
    ROLLBACK TRAN rdt_1770ConfirmAU01 -- Only rollback change made here
Fail:
Quit:
    WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
        COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1770ConfirmAU01] TO NSQL
GO
