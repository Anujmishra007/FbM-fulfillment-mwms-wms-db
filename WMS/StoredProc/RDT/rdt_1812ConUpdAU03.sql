SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812ConUpdAU03                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Add PackDetail (AU FMCG Pallet / Case Customer)             */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-04-09   NYE018    1.0   FCR-11492 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ConUpdAU03]
    @nMobile            INT
   ,@nFunc              INT
   ,@cLangCode          NVARCHAR( 3)
   ,@cTaskdetailKey     NVARCHAR( 10)
   ,@cNewTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo             INT           OUTPUT
   ,@cErrMsg            NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount     INT
   DECLARE @bSuccess       INT

   DECLARE @cStorerKey     NVARCHAR(15)
   DECLARE @cSKU           NVARCHAR(20)
   DECLARE @nQTY           INT
   DECLARE @cDropID        NVARCHAR(20)
   DECLARE @cFromLOC       NVARCHAR(10)
   DECLARE @cOrderKey      NVARCHAR(10)
   DECLARE @cPickSlipNo    NVARCHAR(10) = ''
   DECLARE @cLot           NVARCHAR(10)
   DECLARE @cID            NVARCHAR(18) = ''
   DECLARE @cGroupKey      NVARCHAR( 10)
   DECLARE @cTaskPickMethod NVARCHAR(10) = ''
   DECLARE @c_PickDetailKey NVARCHAR(10) = ''
   DECLARE @cTaskCaseID     NVARCHAR(20) = ''

   DECLARE @cFacility NVARCHAR( 5)
   DECLARE @nStep INT
   DECLARE @nInputKey INT

   -- Get session info
   SELECT
      @cFacility = Facility,
      @nStep = Step,
      @nInputKey = InputKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get task info
   SELECT
      @cStorerKey = StorerKey,
      @cSKU = SKU,
      @nQTY = QTY,
      @cDropID = DropID,
      @cFromLOC = FromLOC,
      @cOrderKey = OrderKey,
      @cLot = Lot,
      @cGroupKey = GroupKey,
      @cTaskPickMethod = PickMethod,
      @cTaskCaseID = CaseID,
      @cID  = FromID
   FROM TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskdetailKey

   IF ISNULL(@cTaskPickMethod,'') = 'FP'
      SET @cDropID = @cID

   IF ISNULL(@cTaskPickMethod,'') = 'FP'
   BEGIN
      UPDATE TASKDETAIL WITH (ROWLOCK)
      SET DROPID = @cDropID
      WHERE TASKDETAILKEY = @cTaskdetailKey

      DECLARE CUR_PICK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PICKDETAILKEY
      FROM PICKDETAIL WITH (NOLOCK)
      WHERE STORERKEY = @cStorerKey
      AND TASKDETAILKEY = @cTaskdetailKey
      --AND STATUS = '5'

      OPEN CUR_PICK

      FETCH NEXT FROM CUR_PICK INTO @c_PickDetailKey

      WHILE @@FETCH_STATUS <> -1
      BEGIN

         UPDATE PICKDETAIL WITH (ROWLOCK)
         SET DROPID = @cDropID
         WHERE PICKDETAILKEY = @c_PickDetailKey

         FETCH NEXT FROM CUR_PICK INTO @c_PickDetailKey
      END
      CLOSE CUR_PICK
      DEALLOCATE CUR_PICK
   END

   -- Get PackHeader
   SELECT @cPickSlipNo = PickSlipNo
   FROM dbo.PackHeader WITH (NOLOCK)
   WHERE OrderKey = @cOrderKey


   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1812ConUpdAU03

   /***********************************************************************************************
                                               PackHeader
   ***********************************************************************************************/
   IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE Pickslipno = @cPickSlipNo AND OrderKey = @cOrderKey )
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
         SET @nErrNo = 263601
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPkHdrFail
         GOTO RollBackTran
      END
   END

   /***********************************************************************************************
     Specialised Orders Handling (FCR-11492)
     - If ORDERS.UserDefine01 = 'Specialised' and SKU.PickCode = 'CS or EA': Create PACKDETAIL per unit
     - If ORDERS.UserDefine01 = 'Specialised' and SKU.PickCode = 'CS Only': Create PACKDETAIL per case
   ***********************************************************************************************/
   DECLARE @cOrderUserDefine01  NVARCHAR(30) = ''
   DECLARE @cPickCode           NVARCHAR(10) = ''
   DECLARE @nSpecCaseCnt        INT = 0
   DECLARE @fSKULength          FLOAT = 0
   DECLARE @fSKUWidth           FLOAT = 0
   DECLARE @fSKUHeight          FLOAT = 0
   DECLARE @fSKUStdGrossWgt     FLOAT = 0
   DECLARE @fPackLength         FLOAT = 0
   DECLARE @fPackWidth          FLOAT = 0
   DECLARE @fPackHeight         FLOAT = 0
   DECLARE @cSKUPackKey         NVARCHAR(50) = ''

   DECLARE @nSpecCartonNo       INT = 0
   DECLARE @nMaxCartonNo        INT = 0
   DECLARE @cSpecLabelNo        NVARCHAR(20) = ''
   DECLARE @nLoopCnt            INT = 0
   DECLARE @nNumRecords         INT = 0
   DECLARE @cSpecCartonType     NVARCHAR(10) = ''
   DECLARE @cSpecReportType     NVARCHAR(10) = ''
   DECLARE @cTransmitLogKey     NVARCHAR(10) = ''
   DECLARE @cUserName           NVARCHAR(18) = ''
   DECLARE @cLabelPrinter       NVARCHAR(20) = ''
   DECLARE @cPaperPrinter       NVARCHAR(20) = ''

   SELECT @cUserName = UserName,
          @cLabelPrinter = Printer,
          @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get Orders.UserDefine01
   IF @cOrderKey <> ''
      SELECT @cOrderUserDefine01 = ISNULL(UserDefine01, '')
      FROM dbo.Orders WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey

   -- Get SKU.PickCode, SKU dimensions, Weight, and PackKey
   IF @cSKU <> '' AND @cStorerKey <> ''
      SELECT @cPickCode = ISNULL(Pickcode, ''),
             @fSKULength = ISNULL([Length], 0),
             @fSKUWidth = ISNULL(Width, 0),
             @fSKUHeight = ISNULL(Height, 0),
             @fSKUStdGrossWgt = ISNULL(STDGROSSWGT, 0),
             @cSKUPackKey = ISNULL(PackKey, '')
      FROM dbo.SKU WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey AND SKU = @cSKU

   -- Get Pack.CaseCnt and Pack dimensions
   IF @cSKUPackKey <> ''
      SELECT @nSpecCaseCnt = ISNULL(CaseCnt, 0),
             @fPackLength = ISNULL(LengthUOM1, 0),
             @fPackWidth = ISNULL(WidthUOM1, 0),
             @fPackHeight = ISNULL(HeightUOM1, 0)
      FROM dbo.PACK WITH (NOLOCK)
      WHERE PackKey = @cSKUPackKey

   -- Process Specialised Orders
   IF @cOrderUserDefine01 IN (SELECT DISTINCT code FROM dbo.CODELKUP   
      (NOLOCK) WHERE LISTNAME = 'CASTAUPP' AND LONG = 'AUTO' AND STORERKEY = @cStorerkey
   )
   BEGIN
      -- Get max CartonNo for the PickSlipNo
      SELECT @nMaxCartonNo = ISNULL(MAX(CartonNo), 0)
      FROM PACKDETAIL WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo

      -- Get report type from CODELKUP
      SELECT @cSpecReportType = ISNULL(Code2, '')
      FROM CODELKUP WITH (NOLOCK)
      WHERE ListName = 'RDTLBLRPT'
        AND Code = '3'
        AND StorerKey = @cStorerKey

      -- Scenario 1: Specialised + CS or EA - Split each unit
      IF @cPickCode = 'CS or EA'
      BEGIN
         SET @nNumRecords = @nQTY -- Create one record per unit
         SET @cSpecCartonType = 'EACH'

         SET @nLoopCnt = 1
         WHILE @nLoopCnt <= @nNumRecords
         BEGIN
            SET @nSpecCartonNo = @nMaxCartonNo + @nLoopCnt

            -- Generate new LabelNo
            EXEC isp_GenUCCLabelNo
               @cStorerKey,
               @cSpecLabelNo   OUTPUT,
               @bSuccess       OUTPUT,
               @nErrNo         OUTPUT,
               @cErrMsg        OUTPUT
            IF @nErrNo <> 0
               GOTO RollBackTran

            -- Insert PACKDETAIL with Qty = 1
            BEGIN TRY
               INSERT INTO PACKDETAIL (
                  PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, Qty,
                  DropID, AddWho, AddDate, EditWho, EditDate
               )
               VALUES (
                  @cPickSlipNo, @nSpecCartonNo, @cSpecLabelNo, '00001', @cStorerKey, @cSKU, 1,
                  @cDropID, @cUserName, GETDATE(), @cUserName, GETDATE()
               )
            END TRY
            BEGIN CATCH
               SET @nErrNo = 263618
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Insert PackDetail Failed
               GOTO RollBackTran
            END CATCH

            -- Update or Insert PACKINFO with SKU dimensions (v1.2 - added Weight and QTY)
            BEGIN TRY
               UPDATE PACKINFO
               SET [Length] = @fSKULength,
                   Width = @fSKUWidth,
                   Height = @fSKUHeight,
                   CartonType = @cSpecCartonType,
                   Weight = @fSKUStdGrossWgt * 1,
                   QTY = 1,
                   EditWho = @cUserName,
                   EditDate = GETDATE()
               WHERE PickSlipNo = @cPickSlipNo
                 AND CartonNo = @nSpecCartonNo

               -- If PACKINFO doesn't exist, insert it
               IF @@ROWCOUNT = 0
               BEGIN
                  INSERT INTO PACKINFO (
                     PickSlipNo, CartonNo, [Length], Width, Height, CartonType, Weight, QTY,
                     AddWho, AddDate, EditWho, EditDate
                  )
                  VALUES (
                     @cPickSlipNo, @nSpecCartonNo, @fSKULength, @fSKUWidth, @fSKUHeight, @cSpecCartonType,
                     @fSKUStdGrossWgt * 1, 1,
                     @cUserName, GETDATE(), @cUserName, GETDATE()
                  )
               END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 263619
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Update PackInfo Failed
               GOTO RollBackTran
            END CATCH

            ---- Insert Transmitlog2 for Specialised orders
            --EXEC nspg_GetKey 'TRANSMITLOGKEY2', 10, @cTransmitLogKey OUTPUT, @bSuccess OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
            --IF @bSuccess <> 1 OR @nErrNo <> 0
            --BEGIN
            --   SET @nErrNo = 263621
            --   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Get TransmitKey Failed
            --   GOTO RollBackTran
            --END

            --BEGIN TRY
            --   INSERT INTO Transmitlog2 (
            --      TransmitLogKey, Key1, Key2, Key3, TableName, AddWho, AddDate
            --   )
            --   VALUES (
            --      @cTransmitLogKey, @cPickSlipNo, CAST(@nSpecCartonNo AS NVARCHAR(10)), @cStorerKey, 'WSCRCTNMW', @cUserName, GETDATE()
            --   )
            --END TRY
            --BEGIN CATCH
            --   SET @nErrNo = 263620
            --   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Insert TransmitLog Failed
            --   GOTO RollBackTran
            --END CATCH

            -- Print SSCC Label for each PACKDETAIL.LabelNo
            IF @cSpecReportType <> '' AND ISNULL(@cLabelPrinter, '') <> ''
            BEGIN
               DECLARE @tSSCCLabel AS VariableTable
               DELETE FROM @tSSCCLabel

               INSERT INTO @tSSCCLabel (Variable, Value) VALUES
                  ('@cStorerKey', @cStorerKey),
                  ('@cLabelNo', @cSpecLabelNo)

               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                  @cSpecReportType,
                  @tSSCCLabel,
                  'rdt_1812ConUpdAU03',
                  @nErrNo OUTPUT,
                  @cErrMsg OUTPUT
               IF @nErrNo <> 0
                  GOTO RollBackTran
            END

            SET @nLoopCnt = @nLoopCnt + 1
         END

         -- Skip to Pack Confirm for Specialised orders
         GOTO PACKCFM
      END
      -- Scenario 2: Specialised + CS Only - Split by case count
      ELSE IF @cPickCode = 'CS Only'
      BEGIN
         -- Calculate number of cases (round up if partial case)
         IF @nSpecCaseCnt > 0
            SET @nNumRecords = CEILING(CAST(@nQTY AS FLOAT) / CAST(@nSpecCaseCnt AS FLOAT))
         ELSE
            SET @nNumRecords = 1

         SET @cSpecCartonType = 'MFCARTON'

         SET @nLoopCnt = 1
         DECLARE @nRemainingQty INT = @nQTY
         DECLARE @nCaseQty INT = 0

         WHILE @nLoopCnt <= @nNumRecords AND @nRemainingQty > 0
         BEGIN
            SET @nSpecCartonNo = @nMaxCartonNo + @nLoopCnt

            -- Calculate qty for this case
            IF @nRemainingQty >= @nSpecCaseCnt
               SET @nCaseQty = @nSpecCaseCnt
            ELSE
               SET @nCaseQty = @nRemainingQty

            SET @nRemainingQty = @nRemainingQty - @nCaseQty

            -- Generate new LabelNo
            EXEC isp_GenUCCLabelNo
               @cStorerKey,
               @cSpecLabelNo   OUTPUT,
               @bSuccess       OUTPUT,
               @nErrNo         OUTPUT,
               @cErrMsg        OUTPUT
            IF @nErrNo <> 0
               GOTO RollBackTran

            -- Insert PACKDETAIL with case qty
            BEGIN TRY
               INSERT INTO PACKDETAIL (
                  PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, Qty,
                  DropID, AddWho, AddDate, EditWho, EditDate
               )
               VALUES (
                  @cPickSlipNo, @nSpecCartonNo, @cSpecLabelNo, '00001', @cStorerKey, @cSKU, @nCaseQty,
                  @cDropID, @cUserName, GETDATE(), @cUserName, GETDATE()
               )
            END TRY
            BEGIN CATCH
               SET @nErrNo = 263622
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Insert PackDetail Failed (CS Only)
               GOTO RollBackTran
            END CATCH

            -- Update or Insert PACKINFO with PACK dimensions (v1.2 - added Weight and QTY)
            BEGIN TRY
               UPDATE PACKINFO
               SET [Length] = @fPackLength,
                   Width = @fPackWidth,
                   Height = @fPackHeight,
                   CartonType = @cSpecCartonType,
                   Weight = @fSKUStdGrossWgt * @nCaseQty,
                   QTY = @nCaseQty,
                   EditWho = @cUserName,
                   EditDate = GETDATE()
               WHERE PickSlipNo = @cPickSlipNo
                 AND CartonNo = @nSpecCartonNo

               -- If PACKINFO doesn't exist, insert it
               IF @@ROWCOUNT = 0
               BEGIN
                  INSERT INTO PACKINFO (
                     PickSlipNo, CartonNo, [Length], Width, Height, CartonType, Weight, QTY,
                     AddWho, AddDate, EditWho, EditDate
                  )
                  VALUES (
                     @cPickSlipNo, @nSpecCartonNo, @fPackLength, @fPackWidth, @fPackHeight, @cSpecCartonType,
                     @fSKUStdGrossWgt * @nCaseQty, @nCaseQty,
                     @cUserName, GETDATE(), @cUserName, GETDATE()
                  )
               END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 263623
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Update PackInfo Failed (CS Only)
               GOTO RollBackTran
            END CATCH

            ---- Insert Transmitlog2 for Specialised orders
            --EXEC nspg_GetKey 'TRANSMITLOGKEY2', 10, @cTransmitLogKey OUTPUT, @bSuccess OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
            --IF @bSuccess <> 1 OR @nErrNo <> 0
            --BEGIN
            --   SET @nErrNo = 263624
            --   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Get TransmitKey Failed (CS Only)
            --   GOTO RollBackTran
            --END

            --BEGIN TRY
            --   INSERT INTO Transmitlog2 (
            --      TransmitLogKey, Key1, Key2, Key3, TableName, AddWho, AddDate
            --   )
            --   VALUES (
            --      @cTransmitLogKey, @cPickSlipNo, CAST(@nSpecCartonNo AS NVARCHAR(10)), @cStorerKey, 'WSCRCTNMW', @cUserName, GETDATE()
            --   )
            --END TRY
            --BEGIN CATCH
            --   SET @nErrNo = 263625
            --   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Insert TransmitLog Failed (CS Only)
            --   GOTO RollBackTran
            --END CATCH

            -- Print SSCC Label for each PACKDETAIL.LabelNo
            IF @cSpecReportType <> '' AND ISNULL(@cLabelPrinter, '') <> ''
            BEGIN
               DECLARE @tSSCCLabel2 AS VariableTable
               DELETE FROM @tSSCCLabel2

               INSERT INTO @tSSCCLabel2 (Variable, Value) VALUES
                  ('@cStorerKey', @cStorerKey),
                  ('@cLabelNo', @cSpecLabelNo)

               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                  @cSpecReportType,
                  @tSSCCLabel2,
                  'rdt_1812ConUpdAU03',
                  @nErrNo OUTPUT,
                  @cErrMsg OUTPUT
               IF @nErrNo <> 0
                  GOTO RollBackTran
            END

            SET @nLoopCnt = @nLoopCnt + 1
         END

         -- Skip to Pack Confirm for Specialised orders
         GOTO PACKCFM
      END
   END
   -- Scenario 3: NOT Specialised (NOAUTO) - Print label by TaskDetailKey only
   ELSE IF @cOrderUserDefine01 IN (SELECT DISTINCT code FROM
      dbo.CODELKUP (NOLOCK) WHERE LISTNAME = 'CASTAUPP' AND LONG = 'NOAUTO' AND
      STORERKEY = @cStorerkey
   )
   BEGIN
      -- Get report type from CODELKUP Code = 4 (for TaskDetailKey printing)
      DECLARE @cReportType4 NVARCHAR(10) = ''
      SELECT @cReportType4 = ISNULL(Code2, '')
      FROM CODELKUP WITH (NOLOCK)
      WHERE ListName = 'RDTLBLRPT'
        AND Code = '4'
        AND StorerKey = @cStorerKey

      -- Print label by TaskDetailKey
      IF @cReportType4 <> '' AND ISNULL(@cLabelPrinter, '') <> ''
      BEGIN
         DECLARE @tTaskLabel AS VariableTable
         DELETE FROM @tTaskLabel

         INSERT INTO @tTaskLabel (Variable, Value) VALUES
            ('@cStorerKey', @cStorerKey),
            ('@cTaskDetailKey', @cTaskdetailKey)

         EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
            @cReportType4,
            @tTaskLabel,
            'rdt_1812ConUpdAU03',
            @nErrNo OUTPUT,
            @cErrMsg OUTPUT
      END

      -- Skip to Pack Confirm for non-Specialised orders
      GOTO PACKCFM
   END
   -- End of Specialised Orders Handling

   DECLARE @nCartonNo   INT = 0
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
   DECLARE @cPalletType       NVARCHAR( 20) = '' --CHEP / LOSCAM / PLAIN,
   DECLARE @nCaseCntOrd       INT = 0 --Case Qty for Orders
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
   DECLARE @cCarrierFlag  NVARCHAR(  1) = ''
   DECLARE @nPackDetailInfoKey BIGINT
   DECLARE @cPackData1      NVARCHAR( 30)
   DECLARE @cPackData2      NVARCHAR( 30)
   DECLARE @cPackData3      NVARCHAR( 30)
   DECLARE @cLottable01     NVARCHAR( 18)
   DECLARE @nSKUTaskExists  INT

   DECLARE @cShipLabel          NVARCHAR( 10),
           @cCartonManifest     NVARCHAR( 10),
           @cCstLabelSP         NVARCHAR(30) ,
           @cUCCNo           NVARCHAR( 20)

   DECLARE @tShipLabel AS VariableTable
   DECLARE @tCartonManifest AS VariableTable
   DECLARE @cDefaultWeight    NVARCHAR( 1)
   DECLARE @cGenPackLabelNoSP NVARCHAR(20)
   DECLARE @cLabelNo          NVARCHAR(20)
   DECLARE @cSQL              NVARCHAR( MAX)
   DECLARE @cSQLParam         NVARCHAR( MAX)
   DECLARE @cCheckMaxByBatch  NVARCHAR(  1)
   DECLARE @nPackCNT          INT
   DECLARE @cPieceOpenCarton  NVARCHAR( 10)
   DECLARE @cPackRefNo        NVARCHAR( 10) = ''

   SELECT @cPaperPrinter    = Printer_Paper,
          @cLabelPrinter    = Printer
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE MOBILE = @nMobile

   SET @cPackData1 = ''
   SET @cPackData2 = ''
   SET @cPackData3 = ''

   SET @cUpdatePackDetailInfo = rdt.RDTGetConfig( @nFunc, 'UpdatePackDetailInfo', @cStorerKey)

   SET @cCheckMaxByBatch = rdt.RDTGetConfig( @nFunc, 'CheckMaxByBatch', @cStorerKey)
   IF @cCheckMaxByBatch = '0'
      SET @cCheckMaxByBatch = ''

   SET @cGenPackLabelNoSP = rdt.RDTGetConfig( @nFunc, 'GenPackLabelNoSP', @cStorerKey)
   IF @cGenPackLabelNoSP = '0'
      SET @cGenPackLabelNoSP = ''

   SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'ShipLabel', @cStorerKey)
   IF @cShipLabel = '0'
      SET @cShipLabel = ''

   SET @cCartonManifest = rdt.RDTGetConfig( @nFunc, 'CartonManifest', @cStorerKey)
   IF @cCartonManifest = '0'
      SET @cCartonManifest = ''

   SET @cDefaultcartontype=rdt.RDTGetConfig( @nFunc, 'DefaultCartonType', @cStorerKey)  --(cc01)
   IF @cDefaultcartontype = '0'
      SET @cDefaultcartontype = ''

   SET @cDefaultpallettype=rdt.RDTGetConfig( @nFunc, 'DefaultPalletType', @cStorerKey)  --(cc01)
   IF @cDefaultpallettype = '0'
      SET @cDefaultpallettype = ''

   SET @cDefaultWeight = rdt.RDTGetConfig( @nFunc, 'DefaultWeight', @cStorerKey)

   SET @cPieceOpenCarton = rdt.RDTGetConfig( @nFunc, 'PieceOpenCarton', @cStorerKey)
   IF @cPieceOpenCarton = '0'
      SET @cPieceOpenCarton = ''

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

   --If Picked Qty less than case, then set as Piece
   SET @cPackMethod = ''
   IF @nQTY < @fPDCaseCnt AND @nQTY > 0
      SET @cPackMethod = 'PIECE'

   --Else Check Pack Type by Customer
   --1. Check if configured by order type (UDF01 = PALLET / CASE, UDF02 = SANDWICH / RAINBOW, UDF03 = MAX SKU PER PALLET, UDF05 = CASE CONVERT LIMIT)
   --2. If no point 1 then Check if configured by storer (storerkey = consigneekey 1st, not exist then billtokey)
   --                                     (SUSR1 = PALLET / CASE, SUSR2 = SANDWICH / RAINBOW, SUSR3 = MAX SKU PER PALLET, SUSR4 = CASE CONVERT LIMIT)
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

         SET @nLLIQty = 0
         SET @nTOLLIQty = 0

         SELECT @nLLIQty = SUM(QTY)
         FROM LOTXLOCXID WITH (NOLOCK)
         WHERE STORERKEY = @cStorerKey
         AND LOC = @cFromLOC
         AND SKU = @cSKU
         AND ID  = @cID

         /*
         IF @cToLOC <> '' AND @nQTY_Move > 0
         BEGIN
            SELECT @nTOLLIQty = SUM(QTY)
            FROM LOTXLOCXID WITH (NOLOCK)
            WHERE STORERKEY = @cStorerKey
            AND LOC = @cToLOC
            AND SKU = @cSKU
            AND ID = @cToID
         END
         */

         SET @nLLIQty = ISNULL(@nLLIQty,0) + ISNULL(@nTOLLIQty,0)

         IF @nLLIQty > 0 AND @nLLIQty = @nQTY AND @nQTY > @fPDCaseCnt --PALLET / LAYER PICKS (LOCATION PICKED IN FULL, AND QTY > CASECNT)
         BEGIN

            IF @cPickPalletType IN ('PALLET','CASE')
               SET @cPackMethod = @cPickPalletType
            ELSE IF @cPickCaseType IN ('SWPALLET' ,'RBPALLET', 'PALLET')
               SET @cPackMethod = 'PALLET'
            ELSE IF @cPickCaseType IN ('SWCASE' ,'RBCASE', 'CASE')
               SET @cPackMethod = 'CASE'

            IF LEFT(@cPickCaseType,2) IN ('SW')
               SET @cCustomerType2 = 'SANDWICH'
            ELSE IF LEFT(@cPickCaseType,2) IN ('RB')
               SET @cCustomerType2 = 'RAINBOW'
            ELSE
               SET @cCustomerType2 = ''


         END
         ELSE IF @nQTY > 0 AND @nQTY >= @fPDCaseCnt --PICKED MORE THAN CASECNT BUT NOT PICKED IN FULL (NON FULL PALLET/LAYER PICKS)
         BEGIN
            SET @cPackMethod = ''

            IF @cPickCaseType IN ('SWPALLET' ,'RBPALLET', 'PALLET')
               SET @cPackMethod = 'PALLET'
            ELSE IF @cPickCaseType IN ('SWCASE' ,'RBCASE', 'CASE')
               SET @cPackMethod = 'CASE'
            IF LEFT(@cPickCaseType,2) IN ('SW')
               SET @cCustomerType2 = 'SANDWICH'
            ELSE IF LEFT(@cPickCaseType,2) IN ('RB')
               SET @cCustomerType2 = 'RAINBOW'
            ELSE
               SET @cCustomerType2 = ''
         END
         ELSE
            SET @cPackMethod = 'PIECE'        END
   END

   IF ISNULL(@cCustomerType2,'') IN ('SANDWICH','RAINBOW')
      SET @cPackCaseType = @cCustomerType2
   ELSE
      SET @cPackCaseType = 'RAINBOW' --DEFAULT TO RAINBOW

   IF ISNUMERIC(@cCustomerType3) = 1
      SET @nPackMaxSku = CAST (@cCustomerType3 AS INT)
   ELSE
      SET @nPackMaxSku = 0  --DEFAULT AS NO MAX SKU

   IF @nQTY <= 0
      GOTO QUIT


   IF ISNULL(@cPackMethod,'') NOT IN ('PALLET','CASE','PIECE')
      SET @cPackMethod = 'PALLET' --DEFAULT TO PALLET

   --DEFAULT IF NOT CONFIGURED THEN 8
   IF ISNUMERIC(@cCustomerType5)<>1
      SET @cCustomerType5 = '8'

   IF ISNUMERIC(@cCustomerType5)=1
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
         IF @cPackMethod <> 'PIECE'
            SET @cPackMethod = 'CASE'
         SET @cCarrierFlag = 'Y'
      END

   END

   --IF @nPackMaxSku > 0 AND ISNULL(@cPackMethod,'') = 'PALLET'
   --BEGIN
   --   SET @nCheckMaxSKU = 0
   --   IF @cCheckMaxByBatch = 1
   --      SELECT @nCheckMaxSKU = COUNT(DISTINCT LA.LOTTABLE01)
   --      FROM PICKDETAIL PD (NOLOCK)
   --      JOIN LOTATTRIBUTE LA (NOLOCK) ON PD.LOT = LA.LOT AND PD.STORERKEY = LA.STORERKEY
   --      WHERE ORDERKEY = @cOrderKey
   --      AND DROPID = @cDropID
   --   ELSE
   --      SELECT @nCheckMaxSKU = COUNT(DISTINCT SKU)
   --      FROM PICKDETAIL (NOLOCK)
   --      WHERE ORDERKEY = @cOrderKey
   --      AND DROPID = @cDropID
   --
   --   --SET @nSKUExists = 0
   --   --IF @cCheckMaxByBatch <> 1
   --   --   SELECT @nSKUExists = 1
   --   --   FROM PACKDETAIL (NOLOCK)
   --   --   WHERE PICKSLIPNO = @cPickSlipNo
   --   --   AND DROPID = @cDropID
   --   --   AND SKU = @cSKU
   --
   --   IF @nPackMaxSku <= ISNULL(@nCheckMaxSKU,0) --+ ISNULL(@nSKUExists,1)
   --      AND @nStep = 5 --IF THEY PUT CONTINUE TASK INSTEAD OF CLOSE PALLET
   --   BEGIN
   --      SET @nErrNo = 51101
   --      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTask.ClosePL
   --      GOTO RollBackTran
   --   END
   --END

   --IF @cPackCaseType = 'SANDWICH' AND @nStep = 5
   --BEGIN
   --   SET @nErrNo = 51101
   --   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTask.ClosePL
   --   GOTO RollBackTran
   --END

   IF @nPackMaxSku > 0 --AND ISNULL(@cPackMethod,'') <> 'CASE'
   BEGIN
      SET @nCheckMaxSKU = 0
      IF @cCheckMaxByBatch = 1
         SELECT @nCheckMaxSKU = COUNT(DISTINCT LA.LOTTABLE01)
         FROM PICKDETAIL PD (NOLOCK)
         JOIN LOTATTRIBUTE LA (NOLOCK) ON PD.LOT = LA.LOT AND PD.STORERKEY = LA.STORERKEY
         WHERE ORDERKEY = @cOrderKey
         AND DROPID = @cDropID
      ELSE
         SELECT @nCheckMaxSKU = COUNT(DISTINCT SKU)
         FROM PICKDETAIL (NOLOCK)
         WHERE ORDERKEY = @cOrderKey
         AND DROPID = @cDropID

      --SET @nSKUExists = 0
      --IF @cCheckMaxByBatch <> 1
      --   SELECT @nSKUExists = 1
      --   FROM PACKDETAIL (NOLOCK)
      --   WHERE PICKSLIPNO = @cPickSlipNo
      --   AND DROPID = @cDropID
      --   AND SKU = @cSKU

      --CHECK NEXT TASK GROUPKEY WHETHER CONTAINS THE SAME SKU
      SET @nSKUTaskExists = 0

      SELECT @nSKUTaskExists = 1
      FROM TASKDETAIL (NOLOCK)
      WHERE STORERKEY = @cStorerkey
      AND ORDERKEY = @cOrderKey
      AND TASKTYPE = 'FCP'        AND PICKMETHOD = 'PP'
      AND GROUPKEY = @cGroupKey
      AND STATUS = '0'

      IF @nSKUTaskExists = 0 AND @nPackMaxSku <= ISNULL(@nCheckMaxSKU,0) --+ ISNULL(@nSKUExists,1)
         AND @nStep = 5 --IF THEY PUT CONTINUE TASK INSTEAD OF CLOSE PALLET
      BEGIN
         SET @nErrNo = 263611
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTask.ClosePL
         GOTO RollBackTran
      END

      --DCH308 START 20250625
      IF @nSKUTaskExists = 1
         AND @nStep <> 5 --IF THEY DID NOT PUT CONTINUE TASK
      BEGIN
         SET @nErrNo = 263612
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OpenTaskExist
         GOTO RollBackTran
      END
      --DCH308 END 20250625
   END

   IF EXISTS (SELECT TOP 1 1 FROM
              CARTONIZATION C WITH (NOLOCK)
              JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
              WHERE S.Storerkey = @cStorerKey
              AND C.CARTONTYPE = ISNULL(@cCustomerType4,''))
      SET @cPalletType = @cCustomerType4
   ELSE IF LEFT(@cDropID,4) = 'PCHE'
           AND EXISTS (SELECT TOP 1 1 FROM
               CARTONIZATION C WITH (NOLOCK)
               JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
               WHERE S.Storerkey = @cStorerKey
               AND C.CARTONTYPE = 'CHEP')
      SET @cPalletType = 'CHEP'
   ELSE IF LEFT(@cDropID,4) = 'PLOS'
           AND EXISTS (SELECT TOP 1 1 FROM
               CARTONIZATION C WITH (NOLOCK)
               JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
               WHERE S.Storerkey = @cStorerKey
               AND C.CARTONTYPE = 'LOSCAM')
      SET @cPalletType = 'LOSCAM'
   ELSE
      SELECT @cPalletType = C.CartonType  --DEFAULT AS PLAIN PALLET
      FROM CARTONIZATION C WITH (NOLOCK)
      JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
      WHERE S.Storerkey = @cStorerKey
      AND C.CARTONTYPE = CASE WHEN ISNULL(@cDefaultpallettype,'') <> '' THEN ISNULL(@cDefaultpallettype,'') ELSE 'PALLET' END

   IF ISNULL(@cPieceOpenCarton,'') = '1' AND @cPackMethod = 'PIECE'
      GOTO PACKCFM
   -- Get CartonNo, LabelLine
   IF @cPackMethod IN ('PALLET','PIECE')
   BEGIN

      --DEFAULT EACH PICKS AS 1 SSCC
      IF ISNULL(@nPackMaxSku,0)<=0 OR @cPackMethod = 'PIECE'
      BEGIN
         SET @cNewLine = 'Y'
         SET @nCartonNo = 0
         SET @cLabelLine = '00001'
         SET @cLabelNo = ''

      END
      ELSE
      BEGIN
         SET @cLabelLine = ''
         SELECT
            @nCartonNo = CartonNo,
            @cLabelLine = LabelLine,
            @cLabelNo   = LabelNo
         FROM dbo.PackDetail WITH (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
            AND DropID = @cDropID
            AND SKU = @cSKU

         IF @cLabelLine = ''
         BEGIN
            SET @cNewLine = 'Y'
            SET @nCartonNo = 0
            SET @cLabelLine = '00001'
            SET @cLabelNo = ''
         END
      END

      IF ISNULL(@cPieceOpenCarton,'') = '2' AND @cPackMethod = 'PIECE'
      BEGIN
         SET @cPackRefNo = 'PIECEPICK'
         SET @cLabelLine = ''
         IF ISNULL(@cTaskCaseID,'') <> ''
         BEGIN
            SET @cNewLine = 'N'
            SELECT
               @nCartonNo = CartonNo,
               @cLabelLine = LabelLine,
               @cLabelNo   = LabelNo
            FROM dbo.PackDetail WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
               AND LabelNo = ISNULL(@cTaskCaseID,'')
               AND SKU = @cSKU
               AND DropID = @cDropID

            IF @cLabelLine = ''
            BEGIN
               SELECT @nCartonNo = CartonNo,
                      @cLabelNo   = LabelNo
               FROM dbo.PackDetail WITH (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               --AND DropID = @cDropID
               AND LabelNo = ISNULL(@cTaskCaseID,'')

               IF @nCartonNo = 0
                  SET @cLabelLine = '00001'
               ELSE
                  SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
                  FROM dbo.PackDetail (NOLOCK)
                  WHERE Pickslipno = @cPickSlipNo
                  AND LabelNo = ISNULL(@cTaskCaseID,'')

               SET @cNewLine = 'Y'
            END
         END
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
                     SET @nErrNo = 263610
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
                     GOTO RollBackTran
                  END
               END
               ELSE IF @cGenPackLabelNoSP = 'DropIDWithZero'
               BEGIN
                  SET @cLabelNo = '00'+@cDropID

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
                        SET @nErrNo = 263610
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
                  SET @cLabelNo = @cDropID

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
            AddWho, AddDate, EditWho, EditDate, RefNo)
         VALUES
            (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY, @cDropID,
            'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE(), @cPackRefNo)
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 263603
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPkDtlFail
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
         IF @@ERROR <> 0     BEGIN
            SET @nErrNo = 263604
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPkDtlFail
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

            IF @nPackDetailInfoKey = ''
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
                SET @nErrNo = 263605
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPDInfoFail
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
                  SET @nErrNo = 263606
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPDInfoFail
                  GOTO RollBackTran
               END
            END
         END
      END

      -- PackInfo
      SET @cCartonType = ''

      SELECT @cCartonType   = C.CartonType
           , @fLength  = CartonLength
           , @fWidth        = CartonWidth
           , @fHeight       = CartonHeight
           , @fCube         = CartonLength * CartonWidth * CartonHeight
           , @fCartonWeight = CartonWeight
      FROM Cartonization C WITH (NOLOCK)
      JOIN Storer S WITH (NOLOCK) ON (C.CartonizationGroup = S.CartonGroup)
      WHERE S.StorerKey = @cStorerKey
      AND C.CartonType = CASE WHEN ISNULL(@cPackMethod,'') = 'PALLET' THEN @cPalletType ELSE 'CARTON' END

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

         IF @cDefaultWeight = '3'
         BEGIN
            SET @fWeight = @fSKUWeight + @fCartonWeight
         END
         SET @cWeight = rdt.rdtFormatFloat( @fWeight)

         SET @fWeight = CAST(@cWeight AS FLOAT)

         INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, Qty, Weight, Cube, CartonType, Length, Width, Height)
         VALUES (@cPickSlipNo, @nCartonNo, @nQTY, @fWeight, @fCube, @cCartonType, @fLength, @fWidth, @fHeight)
         --INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY)
         --VALUES (@cPickSlipNo, @nCartonNo, @nQTY)
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 263607
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPkInfoFail
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
            SET @nErrNo = 263608
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPkInfoFail
            GOTO RollBackTran
         END
      END

      --SUBMIT PRINT JOB IF SANDWICH
      --IF @cPackCaseType = 'SANDWICH' AND ISNULL(@cLabelPrinter,'') <> ''
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
                     '@nSerialQTY      INT,       ' +
                     '@cOption         NVARCHAR( 1),  ' +
                     '@cPackDtlRefNo   NVARCHAR( 20), ' +
                     '@cPackDtlRefNo2  NVARCHAR( 20), ' +
                     '@cPackDtlUPC     NVARCHAR( 30), ' +
                     '@cPackDtlDropID  NVARCHAR( 20), ' +
                     '@cPackData1      NVARCHAR( 30), ' +
                     '@cPackData2      NVARCHAR( 30), ' +
                     '@cPackData3      NVARCHAR( 30), ' +
                     '@nErrNo          INT            OUTPUT, ' +
                     '@cErrMsg        NVARCHAR( 20)  OUTPUT'

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cDropID,
                     @nCartonNo, @cLabelNo, @cSKU, @nQTY, @cUCCNo, @cCartonType, @cCube, @cWeight, '', '', '', '1',
                     '', '', '', @cDropID, @cPackData1, @cPackData2, @cPackData3,
                     @nErrNo OUTPUT, @cErrMsg OUTPUT

                  --IF @nErrNo <> 0
                  --   GOTO Quit
               END
            END
            ELSE BEGIN  --Standard Print
               -- Common params
               DELETE FROM @tShipLabel

               IF ISNULL(@cPrintCopy,'') <> '' AND ISNUMERIC(@cPrintCopy) = 1
            SET @nNoOfCopy = CAST(@cPrintCopy AS INT)
               ELSE
                  SET @nNoOfCopy = 1

               INSERT INTO @tShipLabel (Variable, Value) VALUES
                  ( '@cStorerKey',     @cStorerKey),
                  ( '@cPickSlipNo',    @cPickSlipNo),
                  ( '@cFromDropID',    @cDropID),
                  ( '@cPackDtlDropID', @cDropID),
                  ( '@cLabelNo',       @cLabelNo),
                  ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

               -- Print label
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                  @cShipLabel, -- Report type
                  @tShipLabel, -- Report params
                  'rdt_1812ConUpdAU03',
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
               ( '@cFromDropID',    @cDropID),
               ( '@cPackDtlDropID', @cDropID),
               ( '@cLabelNo',       @cLabelNo),
               ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

            -- Print label
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
               @cCartonManifest, -- Report type
               @tCartonManifest, -- Report params
               'rdt_1812ConUpdAU03',
               @nErrNo  OUTPUT,
               @cErrMsg OUTPUT
            --IF @nErrNo <> 0
            --   GOTO Quit
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
                     SET @nErrNo = 263610
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
                     SET @nErrNo = 263610
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
            (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nCasePackQty, @cDropID,
            'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE())
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 263603
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPkDtlFail
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
                  SET @nErrNo = 263605
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPDInfoFail
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
         AND C.CartonType = CASE WHEN @nCasePackQty < @fPDCaseCnt THEN 'CARTON'
                                 WHEN ISNULL(@cDefaultcartontype,'') <> '' THEN @cDefaultcartontype
                                 ELSE 'MFCARTON' END

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
           SET @nErrNo = 263607
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPkInfoFail
            GOTO RollBackTran
         END


         SET @nCaseLoop = @nCaseLoop - 1
         SET @nCheckSumQty = @nCheckSumQty + @nCasePackQty


         SET @cLength  = CAST(@fLength AS NVARCHAR(10))
         SET @cWidth   = CAST(@fWidth  AS NVARCHAR(10))
         SET @cHeight  = CAST(@fWeight AS NVARCHAR(10))
         SET @cCube    = CAST(@fCube   AS NVARCHAR(10))
         SET @cWeight  = CAST(@fHeight AS NVARCHAR(10))


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
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cDropID,
                        @nCartonNo, @cLabelNo, @cSKU, @nCasePackQty, @cUCCNo, @cCartonType, @cCube, @cWeight, '', '', '', '1',
                        '', '', '', @cDropID, @cPackData1, @cPackData2, @cPackData3,
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
                     ( '@cFromDropID',    @cDropID),
                     ( '@cPackDtlDropID', @cDropID),
                     ( '@cLabelNo',       @cLabelNo),
                     ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

                  -- Print label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     @cShipLabel, -- Report type
                     @tShipLabel, -- Report params
                     'rdt_1812ConUpdAU03',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
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
                  ( '@cFromDropID',    @cDropID),
                  ( '@cPackDtlDropID', @cDropID),
                  ( '@cLabelNo',       @cLabelNo),
                  ( '@nCartonNo',      CAST( @nCartonNo AS NVARCHAR(10)))

               -- Print label
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                  @cCartonManifest, -- Report type
                  @tCartonManifest, -- Report params
                  'rdt_1812ConUpdAU03',
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT
               --IF @nErrNo <> 0
               --   GOTO Quit
            END
         END

         --IF @nCheckSumQty - @nQty > 0  --remaining loose units                 --SY01
         IF @nCaseLoop = 0 AND @nCheckSumQty <> @nQty    --remaining loose units --SY01
         BEGIN
            SET @nCaseLoop = 1
            --SET @nCasePackQty = @nCheckSumQty - @nQty --SY01
            --SET @nCheckSumQty = @nQty - @nCasePackQty --SY01
            SET @nCasePackQty = @nQty - @nCheckSumQty   --SY01
            SET @nCheckSumQty = @nQty - @nCasePackQty   --SY01
         END
      END --case loop
   END

   /***********************************************************************************************
     Pack confirm
   ***********************************************************************************************/
   PACKCFM:
   -- PickHeader (needed by the rdt_Pack_PackConfirm in below)
   IF NOT EXISTS( SELECT 1 FROM dbo.PickHeader WITH (NOLOCK) WHERE PickHeaderKey = @cPickSlipNo)
   BEGIN
      INSERT INTO dbo.PickHeader (PickHeaderKey, OrderKey)
      VALUES (@cPickSlipNo, @cOrderKey)
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 263609
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsPickHdrFail
         GOTO RollBackTran
      END
   END

   IF ISNULL(@cDropID,'') <> ''
   BEGIN
      -- Update PickDetail, base on PackDetail.DropID
      EXEC isp_AssignPackLabelToPickByDropIDAU
          @cPickSlipNo
         ,@cDropID
         ,@bSuccess OUTPUT
         ,@nErrNo   OUTPUT
         ,@cErrMsg  OUTPUT
      IF @nErrNo <> 0
         GOTO RollBackTran
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

   -- IF ISNULL(@cCarrierFlag,'') = 'Y'
   -- BEGIN
   -- SET @nPackCNT = 0

   -- SELECT @nPackCNT = COUNT(DISTINCT LABELNO)
   -- FROM PACKDETAIL WITH (NOLOCK)
   -- WHERE PICKSLIPNO = @cPickSlipNo

   -- IF ISNULL(@nPackCNT,0) <= CAST(@cCustomerType5 AS INT)
   -- BEGIN
   EXEC [dbo].[isp_Carrier_Middleware_Interface]
      @c_OrderKey    = @cOrderKey
      , @c_Mbolkey     = ''
      , @c_FunctionID  = @nFunc
      , @n_CartonNo    = @nCartonNo
      , @n_Step        = @nStep
      , @b_Success     = @bSuccess  OUTPUT
      , @n_Err         = @nErrNo    OUTPUT
      , @c_ErrMsg      = @cErrMsg   OUTPUT
   
   IF @nErrNo <> 0
   BEGIN
      SET @nErrNo = 263616
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- CarrierIntFail
      GOTO RollBackTran
   END
   -- END
   -- END

   COMMIT TRAN rdt_1812ConUpdAU03 -- Only commit change made here
   GOTO Quit

RollBackTran:
  ROLLBACK TRAN rdt_1812ConUpdAU03 -- Only rollback change made here
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

GRANT EXECUTE ON [RDT].[rdt_1812ConUpdAU03] TO [NSQL]
GO