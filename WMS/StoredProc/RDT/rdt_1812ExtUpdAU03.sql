SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812ExtUpdAU03                                  */
/* Purpose: Extended Update - Create PACKDETAIL based on order type     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-04-03   NYE018    1.0   FCR-11492 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtUpdAU03]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cTaskdetailKey  NVARCHAR( 10),
   @cDropID         NVARCHAR( 20),
   @nQTY            INT,
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT,
   @nAfterStep      INT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess    INT
   DECLARE @nExists     INT
   DECLARE @nTranCount  INT
   DECLARE @cShort      NVARCHAR(20)
   DECLARE @cWCS        NVARCHAR(1)
   DECLARE @cCaseID     NVARCHAR(20)
   DECLARE @cListKey    NVARCHAR(10)
   DECLARE @cUserName   NVARCHAR(18)
   DECLARE @cStorerKey  NVARCHAR(15)
   DECLARE @cFacility   NVARCHAR(5)
   DECLARE @cLabelPrinter    NVARCHAR( 10)
   DECLARE @cPaperPrinter    NVARCHAR( 10)
   DECLARE @cOrderKey   NVARCHAR(10)
   DECLARE @cFromLOC    NVARCHAR(10)
   DECLARE @cSKU        NVARCHAR(20)
   DECLARE @cLot        NVARCHAR(10)

   SELECT
      @cUserName = userName,
      @cStorerKey = StorerKey,
      @cFacility = Facility,
      @cPaperPrinter    = Printer_Paper,
      @cLabelPrinter    = Printer
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE mobile = @nMobile

   -- Get task info
   SELECT
      @cStorerKey = StorerKey,
      @cFromLOC = FromLOC,
      @cOrderKey = OrderKey,
      @cSKU = SKU,
      @cLot = Lot
   FROM TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskdetailKey

   SET @nTranCount = @@TRANCOUNT

   -- TM Case Pick
   IF @nFunc = 1812
   BEGIN
      -- Step 4: SKU/QTY confirmed - Create PACKDETAIL based on conditions
      IF @nAfterStep = 4
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @cOrderUserDefine01  NVARCHAR(30) = ''
            DECLARE @cPickCode           NVARCHAR(10) = ''
            DECLARE @nCaseCnt            INT = 0
            DECLARE @fSKULength          FLOAT = 0
            DECLARE @fSKUWidth           FLOAT = 0
            DECLARE @fSKUHeight          FLOAT = 0
            DECLARE @fPackLength         FLOAT = 0
            DECLARE @fPackWidth          FLOAT = 0
            DECLARE @fPackHeight         FLOAT = 0
            DECLARE @cPackKey            NVARCHAR(50) = ''

            DECLARE @cPickSlipNo         NVARCHAR(10) = ''
            DECLARE @nCartonNo           INT = 0
            DECLARE @nMaxCartonNo        INT = 0
            DECLARE @cLabelNo            NVARCHAR(20) = ''
            DECLARE @nLoopCnt            INT = 0
            DECLARE @nNumRecords         INT = 0
            DECLARE @cCartonType         NVARCHAR(10) = ''
            DECLARE @cReportType         NVARCHAR(10) = ''
            DECLARE @cTransmitLogKey     NVARCHAR(10) = ''

            -- Get Orders.UserDefine01
            IF @cOrderKey <> ''
               SELECT @cOrderUserDefine01 = ISNULL(UserDefine01, '')
               FROM dbo.Orders WITH (NOLOCK)
               WHERE OrderKey = @cOrderKey

            -- Get SKU.PickCode, SKU dimensions, and PackKey
            IF @cSKU <> '' AND @cStorerKey <> ''
               SELECT @cPickCode = ISNULL(Pickcode, ''),
                      @fSKULength = ISNULL([Length], 0),
                      @fSKUWidth = ISNULL(Width, 0),
                      @fSKUHeight = ISNULL(Height, 0),
                      @cPackKey = ISNULL(PackKey, '')
               FROM dbo.SKU WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey AND SKU = @cSKU

            -- Get Pack.CaseCnt and Pack dimensions
            IF @cPackKey <> ''
               SELECT @nCaseCnt = ISNULL(CaseCnt, 0),
                      @fPackLength = ISNULL(LengthUOM1, 0),
                      @fPackWidth = ISNULL(WidthUOM1, 0),
                      @fPackHeight = ISNULL(HeightUOM1, 0)
               FROM dbo.PACK WITH (NOLOCK)
               WHERE PackKey = @cPackKey

            -- Get PickSlipNo from PackHeader
            SELECT @cPickSlipNo = PH.PICKSLIPNO
            FROM PACKHEADER PH WITH (NOLOCK)
            WHERE PH.ORDERKEY = @cOrderKey

            -- Get max CartonNo for the PickSlipNo
            SELECT @nMaxCartonNo = ISNULL(MAX(CartonNo), 0)
            FROM PACKDETAIL WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo

            -- Get report type from CODELKUP
            SELECT @cReportType = ISNULL(Code2, '')
            FROM CODELKUP WITH (NOLOCK)
            WHERE ListName = 'RDTLBLRPT'
              AND Code = '3'
              AND StorerKey = @cStorerKey

            -- Scenario 1: Specialised + CS or EA - Split each unit
            IF @cOrderUserDefine01 = 'Specialised' AND @cPickCode = 'CS or EA'
            BEGIN
               SET @nNumRecords = @nQTY -- Create one record per unit
               SET @cCartonType = 'EACH'

               SET @nLoopCnt = 1
               WHILE @nLoopCnt <= @nNumRecords
               BEGIN
                  BEGIN TRAN
                  SAVE TRAN rdt_1812ExtUpdAU03

                  SET @nCartonNo = @nMaxCartonNo + @nLoopCnt

                  -- Generate new LabelNo
                  EXEC isp_GenUCCLabelNo
                     @cStorerKey,
                     @cLabelNo      OUTPUT,
                     @bSuccess      OUTPUT,
                     @nErrNo        OUTPUT,
                     @cErrMsg       OUTPUT
                  IF @nErrNo <> 0
                     GOTO RollBackTran

                  -- Insert PACKDETAIL with Qty = 1
                  BEGIN TRY
                     INSERT INTO PACKDETAIL (
                        PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, Qty,
                        DropID, AddWho, AddDate, EditWho, EditDate
                     )
                     VALUES (
                        @cPickSlipNo, @nCartonNo, @cLabelNo, '00001', @cStorerKey, @cSKU, 1,
                        @cDropID, @cUserName, GETDATE(), @cUserName, GETDATE()
                     )
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 263251
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Insert PackDetail Failed
                     GOTO RollBackTran
                  END CATCH

                  -- Update PACKINFO with SKU dimensions
                  BEGIN TRY
                     UPDATE PACKINFO
                     SET [Length] = @fSKULength,
                         Width = @fSKUWidth,
                         Height = @fSKUHeight,
                         CartonType = @cCartonType,
                         EditWho = @cUserName,
                         EditDate = GETDATE()
                     WHERE PickSlipNo = @cPickSlipNo
                       AND CartonNo = @nCartonNo

                     -- If PACKINFO doesn't exist, insert it
                     IF @@ROWCOUNT = 0
                     BEGIN
                        INSERT INTO PACKINFO (
                           PickSlipNo, CartonNo, [Length], Width, Height, CartonType,
                           AddWho, AddDate, EditWho, EditDate
                        )
                        VALUES (
                           @cPickSlipNo, @nCartonNo, @fSKULength, @fSKUWidth, @fSKUHeight, @cCartonType,
                           @cUserName, GETDATE(), @cUserName, GETDATE()
                        )
                     END
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 263252
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Update PackInfo Failed
                     GOTO RollBackTran
                  END CATCH

                  -- Insert Transmitlog2 for Specialised orders
                  EXEC nspg_GetKey 'TRANSMITLOGKEY2', 10, @cTransmitLogKey OUTPUT, @bSuccess OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
                  IF @bSuccess <> 1 OR @nErrNo <> 0
                  BEGIN
                     SET @nErrNo = 263257
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Get TransmitKey Failed
                     GOTO RollBackTran
                  END

                  BEGIN TRY
                     INSERT INTO Transmitlog2 (
                        TransmitLogKey, Key1, Key2, Key3, TableName, AddWho, AddDate
                     )
                     VALUES (
                        @cTransmitLogKey, @cPickSlipNo, CAST(@nCartonNo AS NVARCHAR(10)), @cStorerKey, 'WSCRCTNMW', @cUserName, GETDATE()
                     )
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 263253
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Insert TransmitLog Failed
                     GOTO RollBackTran
                  END CATCH

                  -- Print SSCC Label for each PACKDETAIL.LabelNo
                  IF @cReportType <> '' AND ISNULL(@cLabelPrinter, '') <> ''
                  BEGIN
                     DECLARE @tSSCCLabel AS VariableTable
                     DELETE FROM @tSSCCLabel

                     INSERT INTO @tSSCCLabel (Variable, Value) VALUES
                        ('@cStorerKey', @cStorerKey),
                        ('@cLabelNo', @cLabelNo)

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        @cReportType,
                        @tSSCCLabel,
                        'rdt_1812ExtUpdAU03',
                        @nErrNo OUTPUT,
                        @cErrMsg OUTPUT
                  END

                  COMMIT TRAN rdt_1812ExtUpdAU03

                  SET @nLoopCnt = @nLoopCnt + 1
               END
            END
            -- Scenario 2: Specialised + CS only - Split by case count
            ELSE IF @cOrderUserDefine01 = 'Specialised' AND @cPickCode = 'CS Only'
            BEGIN
               -- Calculate number of cases (round up if partial case)
               IF @nCaseCnt > 0
                  SET @nNumRecords = CEILING(CAST(@nQTY AS FLOAT) / CAST(@nCaseCnt AS FLOAT))
               ELSE
                  SET @nNumRecords = 1

               SET @cCartonType = 'MFCARTON'

               SET @nLoopCnt = 1
               DECLARE @nRemainingQty INT = @nQTY
               DECLARE @nCaseQty INT = 0

               WHILE @nLoopCnt <= @nNumRecords AND @nRemainingQty > 0
               BEGIN
                  BEGIN TRAN
                  SAVE TRAN rdt_1812ExtUpdAU03

                  SET @nCartonNo = @nMaxCartonNo + @nLoopCnt

                  -- Calculate qty for this case
                  IF @nRemainingQty >= @nCaseCnt
                     SET @nCaseQty = @nCaseCnt
                  ELSE
                     SET @nCaseQty = @nRemainingQty

                  SET @nRemainingQty = @nRemainingQty - @nCaseQty

                  -- Generate new LabelNo
                  EXEC isp_GenUCCLabelNo
                     @cStorerKey,
                     @cLabelNo      OUTPUT,
                     @bSuccess      OUTPUT,
                     @nErrNo        OUTPUT,
                     @cErrMsg       OUTPUT
                  IF @nErrNo <> 0
                     GOTO RollBackTran

                  -- Insert PACKDETAIL with case qty
                  BEGIN TRY
                     INSERT INTO PACKDETAIL (
                        PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, Qty,
                        DropID, AddWho, AddDate, EditWho, EditDate
                     )
                     VALUES (
                        @cPickSlipNo, @nCartonNo, @cLabelNo, '00001', @cStorerKey, @cSKU, @nCaseQty,
                        @cDropID, @cUserName, GETDATE(), @cUserName, GETDATE()
                     )
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 263254
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Insert PackDetail Failed (CS Only)
                     GOTO RollBackTran
                  END CATCH

                  -- Update PACKINFO with PACK dimensions
                  BEGIN TRY
                     UPDATE PACKINFO
                     SET [Length] = @fPackLength,
                         Width = @fPackWidth,
                         Height = @fPackHeight,
                         CartonType = @cCartonType,
                         EditWho = @cUserName,
                         EditDate = GETDATE()
                     WHERE PickSlipNo = @cPickSlipNo
                       AND CartonNo = @nCartonNo

                     -- If PACKINFO doesn't exist, insert it
                     IF @@ROWCOUNT = 0
                     BEGIN
                        INSERT INTO PACKINFO (
                           PickSlipNo, CartonNo, [Length], Width, Height, CartonType,
                           AddWho, AddDate, EditWho, EditDate
                        )
                        VALUES (
                           @cPickSlipNo, @nCartonNo, @fPackLength, @fPackWidth, @fPackHeight, @cCartonType,
                           @cUserName, GETDATE(), @cUserName, GETDATE()
                        )
                     END
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 263255
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Update PackInfo Failed (CS Only)
                     GOTO RollBackTran
                  END CATCH

                  -- Insert Transmitlog2 for Specialised orders
                  EXEC nspg_GetKey 'TRANSMITLOGKEY2', 10, @cTransmitLogKey OUTPUT, @bSuccess OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
                  IF @bSuccess <> 1 OR @nErrNo <> 0
                  BEGIN
                     SET @nErrNo = 263258
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Get TransmitKey Failed (CS Only)
                     GOTO RollBackTran
                  END

                  BEGIN TRY
                     INSERT INTO Transmitlog2 (
                        TransmitLogKey, Key1, Key2, Key3, TableName, AddWho, AddDate
                     )
                     VALUES (
                        @cTransmitLogKey, @cPickSlipNo, CAST(@nCartonNo AS NVARCHAR(10)), @cStorerKey, 'WSCRCTNMW', @cUserName, GETDATE()
                     )
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 263256
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Insert TransmitLog Failed (CS Only)
                     GOTO RollBackTran
                  END CATCH

                  -- Print SSCC Label for each PACKDETAIL.LabelNo
                  IF @cReportType <> '' AND ISNULL(@cLabelPrinter, '') <> ''
                  BEGIN
                     DECLARE @tSSCCLabel2 AS VariableTable
                     DELETE FROM @tSSCCLabel2

                     INSERT INTO @tSSCCLabel2 (Variable, Value) VALUES
                        ('@cStorerKey', @cStorerKey),
                        ('@cLabelNo', @cLabelNo)

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                        @cReportType,
                        @tSSCCLabel2,
                        'rdt_1812ExtUpdAU03',
                        @nErrNo OUTPUT,
                        @cErrMsg OUTPUT
                  END

                  COMMIT TRAN rdt_1812ExtUpdAU03

                  SET @nLoopCnt = @nLoopCnt + 1
               END
            END
            -- Scenario 3: NOT Specialised - Do NOT insert anything into PACKDETAIL
            -- (No action needed)

         END
      END

      IF @nStep = 6 -- ToLOC
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DECLARE @cLabelNo01          NVARCHAR(20) = ''
            DECLARE @cPickSlipNo01       NVARCHAR(10) = ''
            DECLARE @cLoadKey          NVARCHAR(10) = ''

            DECLARE @cPalletLabel        NVARCHAR( 10)

            DECLARE @tPalletLabel  AS VariableTable

            SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'PalletLabel', @cStorerKey)
            IF @cPalletLabel = '0'
               SET @cPalletLabel = ''

         /* PRINTING SSCC AT PICK CONFIRM SECTION INSTEAD
            DECLARE @cConsigneeKey NVARCHAR( 15) = ''
            DECLARE @cBillToKey    NVARCHAR( 20) = ''
            DECLARE @cOrderType    NVARCHAR( 20) = ''

            DECLARE @cCustomerType1     NVARCHAR( 20) = '' --PALLET / CASE
            DECLARE @cCustomerType2     NVARCHAR( 20) = '' --SANDWICH / RAINBOW
            DECLARE @cCustomerType3     NVARCHAR( 20) = '' --MAX SKU PER PALLET
            DECLARE @cCustomerType4     NVARCHAR( 20) = '' --PALLET TYPE: CHEP / LOSCAM / PLAIN
            DECLARE @cPlanningType     NVARCHAR( 20) = '' --WAVE / LOAD
            DECLARE @cPWaveKey         NVARCHAR( 20) = ''
            DECLARE @cPLoadkey         NVARCHAR( 20) = ''
            DECLARE @cPickPalletType   NVARCHAR( 20) = ''
            DECLARE @cPickCaseType     NVARCHAR( 20) = ''
            DECLARE @cPickPieceType    NVARCHAR( 20) = ''
            DECLARE @nLLIQty           INT = 0
            DECLARE @nTOLLIQty         INT = 0
            DECLARE @fPDCaseCnt        FLOAT
            DECLARE @cPDUOM            NVARCHAR( 10) = ''

            DECLARE @cPackMethod       NVARCHAR( 20) = '' --PALLET / CASE / PIECE
            DECLARE @cPackCaseType     NVARCHAR( 20) = '' --SANDWICH / RAINBOW
            DECLARE @nPackMaxSku       INT = 0 --MAX SKU PER PALLET
            DECLARE @cPalletType       NVARCHAR( 20) = '' --CHEP / LOSCAM / PLAIN

            DECLARE @cShipLabel          NVARCHAR( 10),
                    @cCartonManifest     NVARCHAR( 10),
                    @cCstLabelSP         NVARCHAR(30)

            DECLARE @nCartonNo6         INT

            DECLARE @tShipLabel  AS VariableTable

            SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'ShipLabel', @cStorerKey)
            IF @cShipLabel = '0'
               SET @cShipLabel = ''

            IF @cOrderKey <> ''
               SELECT @cConsigneeKey = ConsigneeKey, @cBillToKey = BillToKey, @cOrderType = [Type]
                    , @cPWaveKey = UserDefine09, @cPLoadkey = LoadKey
               FROM dbo.Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey

            --Get Pack config

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
               SET @cPackMethod = ''

               SELECT TOP 1 @cCustomerType1 = UDF01
                          , @cCustomerType2 = UDF02
                          , @cCustomerType3 = UDF03
                 , @cCustomerType4 = UDF04
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
               SET @cPackMethod = ''

               IF ISNULL(@cConsigneeKey,'') <> ''
               BEGIN
                  SELECT TOP 1 @cCustomerType1 = SUSR1
                             , @cCustomerType2 = SUSR2
                             , @cCustomerType3 = SUSR3
                             , @cCustomerType4 = PALLET
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
                     FROM LOADPLAN WITH (NOLOCK)
                     WHERE LOADKEY = @cPLoadkey
                  END

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
            END

            IF ISNULL(@cCustomerType2,'') IN ('SANDWICH','RAINBOW')
               SET @cPackCaseType = @cCustomerType2
            ELSE
               SET @cPackCaseType = 'RAINBOW' --DEFAULT TO RAINBOW

            IF ISNULL(@cPackCaseType,'') = 'RAINBOW' AND ISNULL(@cPackMethod,'') IN ('PALLET','CASE')
               AND ISNULL(@cLabelPrinter,'') <> ''
            BEGIN

               SELECT TOP 1 @cLabelNo01 = PD.LABELNO, @cPickSlipNo01 =  PD.PICKSLIPNO, @nCartonNo6 = PD.CARTONNO
               FROM PACKDETAIL PD (NOLOCK)
               JOIN PACKHEADER PH (NOLOCK) ON PD.PICKSLIPNO = PH.PICKSLIPNO
               WHERE PH.ORDERKEY = @cOrderKey
               AND PD.DROPID = @cDropID
               ORDER BY PD.CARTONNO DESC

               INSERT INTO @tShipLabel (Variable, Value) VALUES
                  ( '@cStorerKey',     @cStorerKey),
                  ( '@cPickSlipNo',    @cPickSlipNo01),
                  ( '@cFromDropID',    @cDropID),
                  ( '@cPackDtlDropID', @cDropID),
                  ( '@cLabelNo',       @cLabelNo01),
                  ( '@nCartonNo',      CAST( @nCartonNo6 AS NVARCHAR(10)))

         -- Print label
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                  @cShipLabel, -- Report type
                  @tShipLabel, -- Report params
             'rdt_1812ExtUpdAU03',
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT
               --IF @nErrNo <> 0
               --   GOTO Quit
            END
            */
            /* PALLET CONTENT LABEL PRINTING ON EXTSCN
            IF EXISTS (SELECT TOP 1 1 FROM PALLET WITH (NOLOCK) WHERE PALLETKEY = @cDropID)
            BEGIN

               IF ISNULL(@cPalletLabel,'') <> '' AND ISNULL(@cLabelPrinter,'') <> ''
               BEGIN

                 INSERT INTO @tPalletLabel (Variable, Value) VALUES
                    ( '@cStorerKey',     @cStorerKey),
                    ( '@cPalletKey',    @cDropID)

                 -- Print label
                 EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                    @cPalletLabel, -- Report type
                    @tPalletLabel, -- Report params
                    'rdt_1812ExtUpdAU03',
                    @nErrNo  OUTPUT,
                    @cErrMsg OUTPUT

               END
            END
            */

            SELECT @cPickSlipNo01 = PH.PICKSLIPNO,
                   @cOrderKey   = ISNULL(PH.ORDERKEY,''),
                   @cLoadKey    = ISNULL(O.LOADKEY,'')
            FROM PACKHEADER PH (NOLOCK)
            JOIN ORDERS O (NOLOCK) ON PH.ORDERKEY = O.ORDERKEY
            WHERE O.ORDERKEY = @cOrderKey

            IF EXISTS (
               SELECT TOP 1 1 FROM PACKHEADER (NOLOCK) WHERE PICKSLIPNO = @cPickSlipNo01 AND STATUS = '9')
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
                  INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo01)
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
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo01)

                     -- Print label
                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,
                         @cPackList, -- Report type
                         @tPackList, -- Report params
                         'rdt_1812ExtUpdAU03',
                         @nErrNo  OUTPUT,
                         @cErrMsg OUTPUT
                  END
                  ELSE IF @cPackList <> '' AND ISNULL(@cPaperPrinter,'') <> ''
                  BEGIN
                     --DECLARE @tPackList AS VariableTable
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)
                     --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo01)

                    -- Print label
                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,
                         @cPackList, -- Report type
                         @tPackList, -- Report params
                         'rdt_1812ExtUpdAU03',
                         @nErrNo  OUTPUT,
                         @cErrMsg OUTPUT
                  END -- Packlist <> ''
               END -- Packlist <> ''
               ELSE IF @cPackList <> '' AND ISNULL(@cPaperPrinter,'') <> ''
               BEGIN
                  --DECLARE @tPackList AS VariableTable
                  --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cLoadKey',     @cLoadKey)
                  --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)
                  --INSERT INTO @tPackList (Variable, Value) VALUES ( '@cPickSlipNo',  @cPickSlipNo01)

                 -- Print label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,
                      @cPackList, -- Report type
                      @tPackList, -- Report params
                      'rdt_1812ExtUpdAU03',
                      @nErrNo  OUTPUT,
                      @cErrMsg OUTPUT
               END -- Packlist <> ''
            END
         END
      END
   END

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1812ExtUpdAU03
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1812ExtUpdAU03] TO [NSQL]
GO
