
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1864ConfirmSP03                                       */
/* Copyright      : Maersk                                                    */
/* Customer       : HillsSAU                                                  */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author   Purposes                                          */
/* 2023-08-05 1.0  NickT    FCR-6483 Initial version, based on                */
/*                          rdt_PickPallet_Confirm.sql                        */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1864ConfirmSP03] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 18),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPickSlipNo   NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cID           NVARCHAR( 18),
   @cSKU          NVARCHAR( 20),
   @nQTY          INT,
   @cToLOC        NVARCHAR( 10),
   @cLottableCode NVARCHAR( 30),
   @cLottable01   NVARCHAR( 18),
   @cLottable02   NVARCHAR( 18),
   @cLottable03   NVARCHAR( 18),
   @dLottable04   DATETIME,
   @dLottable05   DATETIME,
   @cLottable06   NVARCHAR( 30),
   @cLottable07   NVARCHAR( 30),
   @cLottable08   NVARCHAR( 30),
   @cLottable09   NVARCHAR( 30),
   @cLottable10   NVARCHAR( 30),
   @cLottable11   NVARCHAR( 30),
   @cLottable12   NVARCHAR( 30),
   @dLottable13   DATETIME,
   @dLottable14   DATETIME,
   @dLottable15   DATETIME,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL      NVARCHAR( MAX)
   DECLARE @cSQLParam NVARCHAR( MAX)

   /***********************************************************************************************
                                             Standard confirm
   ***********************************************************************************************/
   DECLARE @cOrderKey            NVARCHAR( 10)
   DECLARE @cLoadKey             NVARCHAR( 10)
   DECLARE @cZone                NVARCHAR( 18)
   DECLARE @cPickFilter          NVARCHAR( MAX) = ''
   DECLARE @cPickDetailKey       NVARCHAR( 10)
   DECLARE @cSerialNoKey         NVARCHAR( 10)
   DECLARE @curPD                CURSOR
   DECLARE @nQTY_Move            INT = 0
   DECLARE @nQTY_Bal             INT
   DECLARE @nQTY_PD              INT
   DECLARE @nQTYAlloc            INT
   DECLARE @nQTYPick             INT
   DECLARE @cMoveQTYAlloc        NVARCHAR( 1)
   DECLARE @cMoveQTYPick         NVARCHAR( 1)
   DECLARE @cPickConfirmStatus   NVARCHAR( 1)
   DECLARE @cSerialNoCapture     NVARCHAR( 1)
   DECLARE @cSerialNo            NVARCHAR( 30)
   DECLARE @cCheckPalletStatus   NVARCHAR( 1)
   DECLARE @cUpdatePickDetailCaseID NVARCHAR( 1)
   DECLARE @cUpdatePickDetailDropID NVARCHAR( 1)
   DECLARE @nSerialQTY           INT

   DECLARE @tPickDetail TABLE (
      RowIndex INT IDENTITY( 1, 1) PRIMARY KEY,
      PickDetailKey  NVARCHAR( 18) NOT NULL,
      DropID         NVARCHAR( 20) NOT NULL,
      Sku            NVARCHAR( 20) NOT NULL,
      Qty            INT NOT NULL,
      Lottable01     NVARCHAR( 18) NOT NULL DEFAULT (' '),
      Lottable02     NVARCHAR( 18) NOT NULL DEFAULT (' '),
      Lottable03     NVARCHAR( 18) NOT NULL DEFAULT (' ')
   )
   
   -- Get storer config
   SET @cMoveQTYAlloc = rdt.rdtGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
   SET @cMoveQTYPick = rdt.rdtGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)
   SET @cSerialNoCapture = rdt.RDTGetConfig( @nFunc, 'SerialNoCapture', @cStorerKey) 
   SET @cUpdatePickDetailCaseID = rdt.RDTGetConfig( @nFunc, 'UpdatePickDetailCaseID', @cStorerKey) 
   SET @cUpdatePickDetailDropID = rdt.RDTGetConfig( @nFunc, 'UpdatePickDetailDropID', @cStorerKey) 
   SET @cCheckPalletStatus = rdt.RDTGetConfig( @nFunc, 'CheckPalletStatus', @cStorerKey) 

   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   IF @cPickConfirmStatus NOT IN ( '3', '5')
      SET @cPickConfirmStatus = '5'

   -- Check move alloc, but picked
   IF @cMoveQTYAlloc = '1' AND @cPickConfirmStatus = '5'
   BEGIN
      SET @nErrNo = 243551
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   -- Check move picked, but not pick confirm
   IF @cMoveQTYPick = '1' AND @cPickConfirmStatus < '5'
   BEGIN
      SET @nErrNo = 243552
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   -- Check pallet status, like HOLD
   IF @cCheckPalletStatus = '1'
   BEGIN
      DECLARE @cIDStatus NVARCHAR( 10)
      SELECT @cIDStatus = Status FROM dbo.ID WITH (NOLOCK) WHERE ID = @cID 

      IF @cIDStatus <> 'OK'
      BEGIN
         SET @nErrNo = 243558
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID:
         SET @cErrMsg = RTRIM( @cErrMsg) + ' ' + @cIDStatus
         GOTO Quit
      END
   END

   -- Get pick filter
   SELECT @cPickFilter = ISNULL( Long, '')
   FROM CodeLKUP WITH (NOLOCK) 
   WHERE ListName = 'PickFilter'
      AND Code = @nFunc 
      AND StorerKey = @cStorerKey
      AND Code2 = @cFacility

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   -- PickDetail cursor
   BEGIN      
      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
         SET @cSQL =
            ' SELECT PD.PickDetailKey, PD.QTY, PD.SKU ' +
            ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK)' +
               ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) ' +
               ' JOIN dbo.Loc LOC WITH (NOLOCK) ON (PD.LOC = PD.LOC) ' +
            ' WHERE RKL.PickSlipNo = @cPickSlipNo ' +
               ' AND PD.LOC = @cLOC ' +
               ' AND PD.ID = @cID ' +
               ' AND PD.QTY > 0 ' +
               ' AND PD.Status <> ''4'' ' +
               ' AND PD.Status < @cPickConfirmStatus ' + 
               CASE WHEN @cPickFilter = '' THEN '' ELSE @cPickFilter END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
         SET @cSQL =
            ' SELECT PD.PickDetailKey, PD.QTY, PD.SKU ' +
            ' FROM dbo.PickDetail PD WITH (NOLOCK) ' +
               ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
            ' WHERE PD.OrderKey = @cOrderKey ' +
               ' AND PD.LOC = @cLOC ' +
               ' AND PD.ID = @cID ' +
               ' AND PD.QTY > 0' +
               ' AND PD.Status <> ''4'' ' +
               ' AND PD.Status < @cPickConfirmStatus ' + 
               CASE WHEN @cPickFilter = '' THEN '' ELSE @cPickFilter END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
         SET @cSQL =
            ' SELECT PD.PickDetailKey, PD.QTY, PD.SKU ' +
            ' FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' +
               ' JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' +
               ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
            ' WHERE LPD.LoadKey = @cLoadKey ' +
               ' AND PD.LOC = @cLOC ' +
               ' AND PD.ID = @cID ' +
               ' AND PD.QTY > 0' +
               ' AND PD.Status <> ''4'' ' +
               ' AND PD.Status < @cPickConfirmStatus ' + 
               CASE WHEN @cPickFilter = '' THEN '' ELSE @cPickFilter END

      -- Custom PickSlip
      ELSE
         SET @cSQL =
            ' SELECT PD.PickDetailKey, PD.QTY, PD.SKU ' +
            ' FROM dbo.PickDetail PD WITH (NOLOCK) ' +
               ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
            ' WHERE PD.PickSlipNo = @cPickSlipNo ' +
               ' AND PD.LOC = @cLOC ' +
               ' AND PD.ID = @cID ' +
               ' AND PD.QTY > 0' +
               ' AND PD.Status <> ''4'' ' +
               ' AND PD.Status < @cPickConfirmStatus ' + 
               CASE WHEN @cPickFilter = '' THEN '' ELSE @cPickFilter END

      -- Open cursor
      SET @cSQL =
         ' SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' +
            @cSQL +
         ' OPEN @curPD '

      SET @cSQLParam =
         ' @curPD       CURSOR OUTPUT, ' +
         ' @cPickSlipNo NVARCHAR( 10), ' +
         ' @cOrderKey   NVARCHAR( 10), ' +
         ' @cLoadKey    NVARCHAR( 10), ' +
         ' @cLOC        NVARCHAR( 10), ' +
         ' @cID         NVARCHAR( 18), ' +
         ' @cSKU        NVARCHAR( 20), ' +
         ' @cPickConfirmStatus NVARCHAR( 1) '

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @curPD OUTPUT,
         @cPickSlipNo,
         @cOrderKey,
         @cLoadKey,
         @cLOC,
         @cID,
         @cSKU,
         @cPickConfirmStatus
   END

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1864ConfirmSP03 -- For rollback or commit only our own transaction

   -- Loop PickDetail
   FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD, @cSKU
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Confirm PickDetail
      UPDATE dbo.PickDetail SET
         Status = @cPickConfirmStatus,
         CaseID = CASE WHEN @cUpdatePickDetailCaseID = '1' THEN ID ELSE CaseID END,
         DropID = CASE WHEN @cUpdatePickDetailDropID = '1' THEN ID ELSE DropID END, 
         EditDate = GETDATE(),
         EditWho  = SUSER_SNAME()
      WHERE PickDetailKey = @cPickDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 243553
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
         GOTO RollBackTran
      END

      INSERT INTO @tPickDetail (PickDetailKey, DropID, Sku, Qty, Lottable01, Lottable02, Lottable03)
      SELECT PD.PickDetailKey, PD.DropID, PD.Sku, PD.Qty, LA.Lottable01, LA.Lottable02, LA.Lottable03
      FROM dbo.PickDetail PD WITH(NOLOCK)
      INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON PD.LOT = LA.LOT
      WHERE PD.PickDetailKey = @cPickDetailKey
         AND PD.Status = @cPickConfirmStatus

      -- Serial no
      IF @cSerialNoCapture IN ('1', '3') -- 1=inboud and outbound, 2=inbound only, 3=outbound only
      BEGIN   
         -- Serial no SKU
         IF (SELECT SerialNoCapture FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU) IN ('1', '3')
         BEGIN
            SET @nQTY_Bal = @nQTY_PD
            WHILE @nQTY_Bal > 0
            BEGIN
               -- Find a serial no on the pallet
               SELECT TOP 1 
                  @cSerialNoKey = SerialNoKey,
                  @cSerialNo = SerialNo, 
                  @nSerialQTY = QTY
               FROM dbo.SerialNo WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU
                  AND ID = @cID
                  AND Status = '1'
               
               IF @@ROWCOUNT = 0
                  BREAK
               
               -- Insert PickSerilNo
               IF @cSerialNo <> ''
               BEGIN
                  INSERT INTO PickSerialNo (PickDetailKey, StorerKey, SKU, SerialNo, QTY)
                  VALUES (@cPickDetailKey, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY)
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 243554
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PKSNO Fail
                     GOTO RollBackTran
                  END
               END
               
               -- Update serial no
               UPDATE dbo.SerialNo SET
                  Status = '5', -- Pick
                  EditWho = SUSER_SNAME(), 
                  EditDate = GETDATE(), 
                  TrafficCop = NULL -- Awaiting trigger to make the changes
               WHERE SerialNoKey = @cSerialNoKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 243555
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD SNO Fail
                  GOTO RollBackTran
               END
               
               -- Reduce balance
               SET @nQTY_Bal -= @nSerialQTY
            END
         
            -- Check balance
            IF @nQTY_Bal > 0
            BEGIN
               SET @nErrNo = 243556
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO NOT TALLY
               GOTO RollBackTran
            END
         END
      END

      SET @nQTY_Move += @nQTY_PD

      FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD, @cSKU
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

      -- Move by ID
      EXECUTE rdt.rdt_Move
         @nMobile        = @nMobile,
         @cLangCode      = @cLangCode,
         @nErrNo         = @nErrNo  OUTPUT,
         @cErrMsg        = @cErrMsg OUTPUT,
         @cSourceType    = 'rdt_1864ConfirmSP03',
         @cStorerKey     = @cStorerKey,
         @cFacility      = @cFacility,
         @cFromLOC       = @cLOC,
         @cToLOC         = @cToLOC,
         @cFromID        = @cID,
         @cToID          = @cID,
         @nQTYAlloc      = @nQTYAlloc,
         @nQTYPick       = @nQTYPick,
         @nFunc          = @nFunc
      IF @nErrNo <> 0
         GOTO RollBackTran
   END

   -- Update UCC (rdt_Move does not update UCC if PickDetail.Status = 5)
   IF @cToLOC <> '' AND @cMoveQTYPick = '1'
   BEGIN
      DECLARE @cUCCNo NVARCHAR( 20)
      DECLARE @curUCC CURSOR
      SET @curUCC = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT DISTINCT UCCNo
         FROM dbo.UCC WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND LOC = @cLOC
            AND ID = @cID
      OPEN @curUCC
      FETCH NEXT FROM @curUCC INTO @cUCCNo
      WHILE @@FETCH_STATUS = 0
      BEGIN
         UPDATE dbo.UCC SET
            Status = '5', -- Pick
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE StorerKey = @cStorerKey
            AND UCCNo = @cUCCNo
         IF @nErrNo <> 0
         BEGIN
            SET @nErrNo = 243557
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD UCC fail
            GOTO RollBackTran
         END

         FETCH NEXT FROM @curUCC INTO @cUCCNo
      END
   END

   -- Customize Logic
   IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo)
   BEGIN
      -- Insert PackHeader
      BEGIN TRY
         INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey)
         VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey)
      END TRY
      BEGIN CATCH
         SET @nErrNo = 243559
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert Packheader Fail
         GOTO RollBackTran
      END CATCH
   END

   DECLARE 
      @nLoopIndex                   INT = -1,
      @nRowCount                    INT = 1,
      @nCartonNo                    INT,
      @bSuccess                     INT,
      @cPalletID                    NVARCHAR( 20),
      @cLabelNo                     NVARCHAR( 20),
      @cLabelLine                   NVARCHAR( 20),
      @cGenLabelNo_SP               NVARCHAR( 20),
      @tGenLabelNo                  VARIABLETABLE,
      @tShipLabel                   VARIABLETABLE,
      @nPackDetailInfoKey           BIGINT,
      @cShipLabel                   NVARCHAR( 10),
      @cLabelPrinter                NVARCHAR( 10),
      @cPaperPrinter                NVARCHAR( 10),
      @cCstLabelSP                  NVARCHAR( 30)

   SET @cGenLabelNo_SP = rdt.RDTGetConfig( @nFunc, 'GenLabelNo_SP', @cStorerkey)
   IF @cGenLabelNo_SP = '0'
      SET @cGenLabelNo_SP = ''

   SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'ShipLabel', @cStorerKey)
   IF @cShipLabel = '0'
      SET @cShipLabel = ''

   SELECT 
      @cLabelPrinter = Printer, 
      @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @nLoopIndex = -1

   WHILE 1 = 1
   BEGIN
      SELECT TOP 1
         @nLoopIndex = RowIndex,
         @cPickDetailKey = PickDetailKey,
         @cPalletID = DropID,
         @cSKU = Sku,
         @nQTY_PD = Qty,
         @cLottable01 = Lottable01,
         @cLottable02 = Lottable02,
         @cLottable03 = Lottable03
      FROM @tPickDetail 
      WHERE RowIndex > @nLoopIndex
      ORDER BY RowIndex

      SELECT @nRowCount = @@ROWCOUNT
      IF @nRowCount = 0
         BREAK

      IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND DropID = @cPalletID
                        AND SKU = @cSKU)
      BEGIN
         SET @nCartonNo = 0
         SET @cLabelNo = ''
         SET @cLabelLine = '00000'

         IF @cGenLabelNo_SP <> '' 
            AND EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGenLabelNo_SP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC dbo.' + RTRIM( @cGenLabelNo_SP) +
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

            IF @nErrNo <> 0
               GOTO RollBackTran
         END
         ELSE
         BEGIN
            EXECUTE dbo.nsp_GenLabelNo
               '',
               @cStorerKey,
               @c_labelno     = @cLabelNo  OUTPUT,
               @n_cartonno    = @nCartonNo OUTPUT,
               @c_button      = '',
               @b_success     = @bSuccess  OUTPUT,
               @n_err         = @nErrNo    OUTPUT,
               @c_errmsg      = @cErrMsg   OUTPUT

            IF @nErrNo <> 0
               GOTO RollBackTran

            IF @bSuccess <> 1
            BEGIN
               SET @nErrNo = 138053
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Generate Label Fail
               GOTO RollBackTran
            END
         END

         BEGIN TRY
            INSERT INTO dbo.PackDetail
               (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, Refno, AddWho, AddDate, EditWho, EditDate, DropID)
            VALUES
               (@cPickSlipNo, 0, @cLabelNo, @cLabelLine, @cStorerKey, @cSku, @nQTY_PD,
               '', SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE(), @cPalletID)
         END TRY
         BEGIN CATCH
            SET @nErrNo = 243561
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert PackDetail Fail
            GOTO RollBackTran
         END CATCH

         BEGIN TRY
            UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
            SET 
               CaseID = @cLabelNo,
               EditWho = SUSER_SNAME(),
               EditDate = GETDATE(),
               TrafficCop = NULL
            WHERE Pickdetailkey = @cPickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 243562
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update PickDetail Fail
            GOTO RollBackTran
         END CATCH
      END -- DropID not exists
      ELSE
      BEGIN
         SELECT TOP 1
            @nCartonNo = CartonNo,
            @cLabelNo = LabelNo,
            @cLabelLine = @cLabelLine
         FROM dbo.PackDetail WITH (NOLOCK) 
         WHERE PickSlipNo = @cPickSlipNo
            AND DropID = @cPalletID
            AND SKU = @cSKU
         ORDER BY 1

         BEGIN TRY
            UPDATE dbo.PackDetail WITH (ROWLOCK) SET
               QTY = QTY + @nQTY_PD,
               EditWho = SUSER_SNAME(),
               EditDate = GETDATE()
            WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
               AND LabelNo = @cLabelNo
               AND LabelLine = @cLabelLine
         END TRY
         BEGIN CATCH
            SET @nErrNo = 243563
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update PackDetail Fail
            GOTO RollBackTran
         END CATCH
      END   -- DropID exists and SKU exists (update qty only)

      SET @nCartonNo = @nCartonNo + 1

      -- Get PackDetailInfo
      SET @nPackDetailInfoKey = 0

      SELECT @nPackDetailInfoKey = PackDetailInfoKey
      FROM dbo.PackDetailInfo WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND UserDefine01 = @cLottable01
         AND UserDefine02 = @cLottable02
         AND UserDefine03 = @cLottable03

      IF ISNULL(@nPackDetailInfoKey, 0) = 0
      BEGIN
         -- Insert PackDetailInfo
         BEGIN TRY
            INSERT INTO dbo.PackDetailInfo (
               PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, UserDefine01, UserDefine02, UserDefine03,
               AddWho, AddDate, EditWho, EditDate)
            VALUES (
               @cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY_PD, @cLottable01, @cLottable02, @cLottable03,
               SUSER_SNAME(), GETDATE(), SUSER_SNAME(), GETDATE())
         END TRY
         BEGIN CATCH
            SET @nErrNo = 243564
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PDInfoFail
            GOTO RollBackTran
         END CATCH
      END
      ELSE
      BEGIN
         -- Update PackDetailInfo
         BEGIN TRY
            UPDATE dbo.PackDetailInfo WITH(ROWLOCK) 
            SET
               QTY = QTY + @nQTY,
               EditWho = SUSER_SNAME(),
               EditDate = GETDATE(),
               ArchiveCop = NULL
            WHERE PackDetailInfoKey = @nPackDetailInfoKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 243565
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PDInfoFail
            GOTO RollBackTran
         END CATCH
      END

      -- Print Label
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
                           ' @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cCartonType, @cCube, @cWeight, @cRefNo, ' +
                           ' @cPackDtlRefNo, @cPackDtlRefNo2, @cPackDtlDropID, @cPackData1, @cPackData2, @cPackData3, ' +
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
                        '@cCartonType     NVARCHAR( 10), ' +
                        '@cCube           NVARCHAR( 10), ' +
                        '@cWeight         NVARCHAR( 10), ' +
                        '@cRefNo          NVARCHAR( 20), ' +
                        '@cPackDtlRefNo   NVARCHAR( 20), ' +
                        '@cPackDtlRefNo2  NVARCHAR( 20), ' +
                        '@cPackDtlDropID  NVARCHAR( 20), ' +
                        '@cPackData1      NVARCHAR( 30), ' +
                        '@cPackData2      NVARCHAR( 30), ' +
                        '@cPackData3      NVARCHAR( 30), ' +
                        '@nErrNo          INT            OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20)  OUTPUT'

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cPalletID,
                     @nCartonNo, @cLabelNo, @cSKU, @nQTY_PD, '', '', '', '',
                     '', '', @cPalletID, '', '', '',
                     @nErrNo OUTPUT, @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO RollBackTran
            END
         END
         ELSE
         BEGIN  --Standard Print
            DELETE FROM @tShipLabel
            INSERT INTO @tShipLabel (Variable, Value) VALUES
                  ( '@cStorerKey',     @cStorerKey),
                  ( '@cPickSlipNo',    @cPickSlipNo),
                  ( '@cFromDropID',    @cPalletID),
                  ( '@cPackDtlDropID', @cPalletID),
                  ( '@cLabelNo',       @cLabelNo),
                  ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

            -- Print label
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                  @cShipLabel, -- Report type
                  @tShipLabel, -- Report params
                  'rdt_1864ConfirmSP03',
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO RollBackTran
         END
      END --PRINT END
   END

   

   -- Event log
   EXEC RDT.rdt_STD_EventLog
      @cActionType   = '3', -- Picking
      @nMobileNo     = @nMobile,
      @nFunctionID   = @nFunc,
      @cFacility     = @cFacility,
      @cStorerKey    = @cStorerKey,
      @cPickSlipNo   = @cPickSlipNo, 
      @cLocation     = @cLOC,
      @cID           = @cID,
      @cSKU          = @cSKU,
      @nQTY          = @nQTY_Move,
      @cLottable01   = @cLottable01,
      @cLottable02   = @cLottable02,
      @cLottable03   = @cLottable03,
      @dLottable04   = @dLottable04,
      @dLottable05   = @dLottable05,
      @cLottable06   = @cLottable06,
      @cLottable07   = @cLottable07,
      @cLottable08   = @cLottable08,
      @cLottable09   = @cLottable09,
      @cLottable10   = @cLottable10,
      @cLottable11   = @cLottable11,
      @cLottable12   = @cLottable12,
      @dLottable13   = @dLottable13,
      @dLottable14   = @dLottable14,
      @dLottable15   = @dLottable15,
      @cToLocation   = @cToLOC

   COMMIT TRAN rdt_1864ConfirmSP03
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1864ConfirmSP03
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1864ConfirmSP03 TO NSQL
GO