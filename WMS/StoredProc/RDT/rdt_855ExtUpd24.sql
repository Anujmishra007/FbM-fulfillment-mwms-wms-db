SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***********************************************************************************/
/* Store procedure: rdt_855ExtUpd24                                                */
/* Copyright      : Maersk                                                         */
/* Customer: Granite                                                               */
/*                                                                                 */
/* Purpose: Print the VAS label                                                    */
/*                                                                                 */
/* Modifications log:                                                              */
/* Date       Rev    Author   Purposes                                             */
/* 2026-06-17 1.0    Cuize    FCR-13167. Created                                     */
/***********************************************************************************/
CREATE OR ALTER PROC rdt.rdt_855ExtUpd24 (
   @nMobile      INT,   
   @nFunc        INT,   
   @cLangCode    NVARCHAR( 3),   
   @nStep        INT,   
   @nInputKey    INT,   
   @cStorerKey   NVARCHAR( 15),    
   @cRefNo       NVARCHAR( 10),   
   @cPickslipNo  NVARCHAR( 10),   
   @cLoadKey     NVARCHAR( 10),   
   @cOrderKey    NVARCHAR( 10),   
   @cDropID      NVARCHAR( 20),   
   @cSKU         NVARCHAR( 20),    
   @nQty         INT,    
   @cOption      NVARCHAR( 1),    
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT,
   @cID          NVARCHAR( 18) = '',
   @cTaskDetailKey   NVARCHAR( 10) = '',
   @cReasonCode  NVARCHAR(20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nLoopIndex                INT,
      @nRowCount                 INT,
      @nTranCount                INT,
      @nScn                      INT,
      @bSuccess                  INT,
      @cFacility                 NVARCHAR(5),
      @cLabelPrinterGroup        NVARCHAR(10),
      @cPaperPrinter             NVARCHAR(10)

   DECLARE @cSingleUnitOrdFlag NVARCHAR(1) --V1.19.0

   DECLARE @bDebugFlag   BINARY = 0 --1, print log; 2, insert traceinfo
   DECLARE @cToteID      NVARCHAR(20)
   DECLARE @cWaveKey     NVARCHAR(20),
   @cDropIDFlag          NVARCHAR(1)
   DECLARE @tWaveKeys    TABLE (
      WaveKey NVARCHAR(50)
   )
   DECLARE @nWaveKeyCount INT
   --v1.13.0 start
   DECLARE @tDropID TABLE
   (
      RowNumber INT IDENTITY,
      DropID NVARCHAR(20)
   )
   DECLARE @nDropIDMax       INT
   DECLARE @nDropIDCounter   INT
   DECLARE @cPackDropID      NVARCHAR(20)
   --v1.13.0 end

   DECLARE @tRDTPPA TABLE
   (
      RowRef INT NOT NULL PRIMARY KEY
   )

   -- FCR-13167: Variables for step 3 logic (from ExtUpd13)
   DECLARE
      @nTotalPQty                INT,
      @nTotalCQty                INT,
      @c_QCmdClass               NVARCHAR(10)   = '',
      @cTransmitLogKey           NVARCHAR(10),
      @b_Debug                   INT = 0,
      @cShipperKey               NVARCHAR(15),
      @cConsigneeKey             NVARCHAR(15),
      @cBillToKey                NVARCHAR(15),
      @cMPOCFlag                 NVARCHAR(10),
      @cOLPSCode                 NVARCHAR(10),
      @cOLPSDescription          NVARCHAR(15) = 'OlpsPlacement'

   DECLARE @tMPOCLabels TABLE
   (
      ID    INT IDENTITY(1,1),
      LabelName   NVARCHAR( 30),
      OrderKey    NVARCHAR( 10)
   )

   DECLARE @tOrder TABLE
   (
      ID                      INT IDENTITY(1,1),
      OrderKey                NVARCHAR(10)
   )

   -- V1.17.0 from ExtUpd13 - for ReferenceID generation
   DECLARE @tOrderNoRefID TABLE
   (
      RowNumber      INT IDENTITY(1,1),
      OrderKey       NVARCHAR(10),
      ConsigneeKey   NVARCHAR(15),
      WaveKey        NVARCHAR(10)
   )

   DECLARE @cONRIOrderKey     NVARCHAR(10)
   DECLARE @cONRIConsigneeKey NVARCHAR(15)
   DECLARE @cONRIWaveKey      NVARCHAR(10)
   DECLARE @cReferenceID      NVARCHAR(20)
   DECLARE @cOtherParams      NVARCHAR(MAX) = ''

   DECLARE @tPickSlipNoList TABLE
   (
      id INT IDENTITY(1,1),
      PickSlipNo        NVARCHAR(10)
   )

   DECLARE @tCartonWeight TABLE
   (
      CaseID            NVARCHAR(30),
      PickSlipNo        NVARCHAR(10),
      CartonNo          INT,
      Weight            FLOAT
   )
   DECLARE @nPickSlipNoQty    INT = 1
   DECLARE @tPackSlipList     VariableTable
   DECLARE @cLabelName        NVARCHAR(30)

   -- FCR-13167: Additional variables for step 3 logic
   DECLARE @cTempOrderKey     NVARCHAR(10) = ''
   DECLARE @cOrderGroup       NVARCHAR(20) = ''

   -- FCR-13167: VAS label printing variables (from ExtUpd13)
   DECLARE @nWorkOrderDetailQty  INT
   DECLARE @cLabelListName       NVARCHAR(10)
   DECLARE @cPickConfirmStatus   NVARCHAR(1)

   DECLARE @tLabels TABLE
   (
      ID                   INT IDENTITY(1,1),
      WorkOrderKey         NVARCHAR(10),
      WorkOrderLineNumber  NVARCHAR(5),
      LabelListName        NVARCHAR(10),
      VASCode              NVARCHAR(12),
      LabelName            NVARCHAR(30),
      Qty                  INT,
      PrintSequence        NVARCHAR(5)
   )

   SET @nErrNo = 0
   SET @cErrMsg = ''

   SELECT @nScn = Scn,
      @cLabelPrinterGroup = Printer,
      @cPaperPrinter = Printer_Paper,
      @cDropIDFlag   = C_STRING1,
      @cSingleUnitOrdFlag = C_String2 --v1.19.0
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- FCR-13167: Initialize PickConfirmStatus for VAS label queries
   SET @cPickConfirmStatus = rdt.RDTGetConfig(@nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   IF @cPickConfirmStatus NOT IN ('3', '5')
      SET @cPickConfirmStatus = '5'

   IF @nFunc = 855 -- Post Pick Audit
   BEGIN
      IF @nStep = 1 OR (@nStep = 99 AND @nScn = 814)-- CartonID
      BEGIN
         DELETE FROM @tRDTPPA

         INSERT INTO @tRDTPPA (RowRef)
         SELECT DISTINCT RowRef
         FROM RDT.RDTPPA WITH(NOLOCK) 
         WHERE StorerKey = @cStorerKey 
            AND DropID = @cDropID 
            AND Status = '2'
         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount > 0
         BEGIN
            BEGIN TRY
               UPDATE RP
               SET Status = '0',
                  CQty = 0
               FROM RDT.RDTPPA RP WITH(ROWLOCK)
               INNER JOIN @tRDTPPA TRP ON RP.RowRef = TRP.RowRef
            END TRY
            BEGIN CATCH
               SET @nErrNo = 268664
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- RDTPPA Update Failed
               GOTO Quit
            END CATCH
         END
      END
      -- FCR-13167: SKU scan completion on Scn 6911, print VAS labels (like ExtUpd13 Step 3)
      -- Called from ExtScn05 Scn 6911 after RDTPPA update (not M/A print)
      ELSE IF @nScn = 6911 AND ISNULL(@cOption, '') = '' -- After scan SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER key
         BEGIN
            -- FCR-13167: Print VAS label for each SKU scan (1 copy per scan)
            -- Previously waited until @nTotalPQty = @nTotalCQty to print all at once
            -- FCR-13167: Build VAS label list (from ExtUpd13)
               -- 1. Price Labels from LVSPRICELB
               DECLARE @tCODELKUP_Step3 TABLE
               (
                  LISTNAME             NVARCHAR(10),
                  StorerKey            NVARCHAR(15),
                  Code                 NVARCHAR(30),
                  Code2                NVARCHAR(30),
                  UDF01                NVARCHAR(60),
                  INDEX IDX_tCODELKUP CLUSTERED(StorerKey, Code)
               )

               INSERT INTO @tCODELKUP_Step3 (LISTNAME, StorerKey, Code, Code2, UDF01)
               SELECT DISTINCT lk1.LISTNAME, lk1.StorerKey, lk1.Code, Lk1.code2, lk1.UDF01
               FROM dbo.WorkOrderDetail wod1 WITH(NOLOCK)
               INNER JOIN dbo.PickDetail pkd1 WITH(NOLOCK) ON wod1.StorerKey = pkd1.StorerKey AND wod1.ExternWorkOrderKey = pkd1.OrderKey
               INNER JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON wod1.StorerKey = lk1.StorerKey AND lk1.LISTNAME = 'LVSPRICELB' AND wod1.Type = lk1.code2
               WHERE wod1.StorerKey = @cStorerKey
                  AND wod1.ExternLineNo = ''
                  AND wod1.Remarks = 'PriceTicketFormat'
                  AND wod1.ExternWorkOrderKey IS NOT NULL
                  AND wod1.ExternWorkOrderKey <> ''
                  AND pkd1.CaseID <> ''
                  AND pkd1.CaseID = @cDropID

               -- 2. VAS Labels from WKORDTYPE where UDF04 = 'LVSPRICELB'
               INSERT INTO @tLabels(LabelListName, VASCode, LabelName, Qty, PrintSequence)
               SELECT DISTINCT IIF(wodEX.LISTNAME IS NULL, lk.LISTNAME, wodEX.LISTNAME), wod.type, IIF(wodEX.UDF01 IS NULL, lk.UDF01, wodEX.UDF01), pkd.Qty, '00001'
               FROM dbo.WorkOrderDetail wod WITH(NOLOCK)
               INNER JOIN dbo.WorkOrder wo WITH(NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
               INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND lk.LISTNAME = 'WKORDTYPE' AND lk.UDF04 = 'LVSPRICELB'
               INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wo.StorerKey = pkd.StorerKey AND wod.ExternWorkOrderKey = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo AND pkd.Status = @cPickConfirmStatus
               LEFT JOIN @tCODELKUP_Step3 AS wodEX
                  ON wod.StorerKey = wodEX.StorerKey AND lk.Code = wodEX.Code
               WHERE wo.StorerKey = @cStorerKey
                  AND pkd.Sku = @cSKU
                  AND wod.ExternWorkOrderKey IS NOT NULL
                  AND wod.ExternWorkOrderKey <> ''
                  AND pkd.CaseID <> ''
                  AND pkd.CaseID = @cDropID
                  AND wod.ExternLineNo <> ''

               -- 3. Catalog Labels from WKORDTYPE where UDF04 = 'LVSCatalog'
               DECLARE @tOrders_Step3 TABLE
               (
                  StorerKey      NVARCHAR(15),
                  OrderKey       NVARCHAR(10),
                  INDEX IDX_tOrders CLUSTERED(StorerKey, OrderKey)
               )

               INSERT INTO @tOrders_Step3 (StorerKey, OrderKey)
               SELECT DISTINCT StorerKey, OrderKey
               FROM dbo.PickDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND CaseID <> ''
                  AND CaseID = @cDropID

               DECLARE @tWorkOrderDetails_Step3 TABLE
               (
                  StorerKey            NVARCHAR(15),
                  WorkOrderKey         NVARCHAR(10),
                  ExternWorkOrderKey   NVARCHAR(20),
                  ExternLineNo         NVARCHAR(5),
                  WorkOrderLineNumber  NVARCHAR(5),
                  Type                 NVARCHAR(12)
               )

               INSERT INTO @tWorkOrderDetails_Step3 (StorerKey, WorkOrderKey, ExternWorkOrderKey, ExternLineNo, WorkOrderLineNumber, Type)
               SELECT StorerKey, WorkOrderKey, ExternWorkOrderKey, ExternLineNo, WorkOrderLineNumber, Type
               FROM
                  (SELECT
                     wod1.StorerKey, wod1.WorkOrderKey, wod1.ExternWorkOrderKey, wod1.ExternLineNo, wod1.WorkOrderLineNumber, wod1.Type,
                     ROW_NUMBER()OVER(PARTITION BY WorkOrderKey, ExternWorkOrderKey, ExternLineNo ORDER BY ExternWorkOrderKey, ExternLineNo) AS ROW#
                     FROM dbo.WorkOrderDetail wod1 WITH(NOLOCK)
                     INNER JOIN @tOrders_Step3 AS pkd1
                        ON wod1.StorerKey = pkd1.StorerKey AND wod1.ExternWorkOrderKey = pkd1.OrderKey
                     INNER JOIN dbo.CODELKUP lk2 WITH(NOLOCK) ON wod1.StorerKey = lk2.StorerKey AND lk2.LISTNAME = 'WKORDTYPE' AND lk2.UDF04 = 'LVSCatalog' AND wod1.Type = lk2.Code
                     WHERE wod1.StorerKey = @cStorerKey
                        AND wod1.Type <> ''
                        AND wod1.ExternLineNo <> ''
                        AND wod1.ExternWorkOrderKey IS NOT NULL
                        AND wod1.ExternWorkOrderKey <> '') AS t
               WHERE ROW# = 1

               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount > 0
               BEGIN
                  INSERT INTO @tLabels(LabelListName, VASCode, LabelName, Qty, PrintSequence)
                  SELECT DISTINCT IIF(lk1.LISTNAME IS NULL, lk.LISTNAME, lk1.LISTNAME), wod.Type, IIF(lk1.LISTNAME IS NULL, lk.UDF01, lk1.UDF01), pakd.Qty, lk.Code
                  FROM @tWorkOrderDetails_Step3 AS wod
                  INNER JOIN dbo.WorkOrder wo WITH(NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
                  INNER JOIN dbo.ORDERS orm WITH(NOLOCK) ON wod.StorerKey = orm.StorerKey AND wod.ExternWorkOrderKey = orm.OrderKey
                  INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND lk.LISTNAME = 'WKORDTYPE' AND lk.UDF04 = 'LVSCatalog'
                  INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wo.StorerKey = pkd.StorerKey AND wod.ExternWorkOrderKey = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo AND pkd.Status = @cPickConfirmStatus
                  INNER JOIN dbo.PackDetail pakd WITH(NOLOCK) ON pkd.StorerKey = pakd.StorerKey AND pkd.CaseID = pakd.LabelNo AND pakd.SKU = pkd.SKU
                  LEFT JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON lk.StorerKey = lk1.StorerKey AND lk.Code = lk1.Code AND lk.UDF04 = lk1.LISTNAME AND lk1.Code2 <> ''
                     AND (orm.ConsigneeKey = lk1.Code2 OR orm.MarkforKey = lk1.Code2 OR orm.BillToKey = lk1.Code2)
                  WHERE wo.StorerKey = @cStorerKey
                     AND pkd.Sku = @cSKU
                     AND wod.ExternWorkOrderKey IS NOT NULL
                     AND wod.ExternWorkOrderKey <> ''
                     AND pkd.CaseID <> ''
                     AND pkd.CaseID = @cDropID
                  ORDER BY lk.Code ASC
               END

               -- Print VAS Labels
               DECLARE @tPriceLabelList_Step3   VariableTable
               DECLARE @tcatelogLabelList_Step3 VariableTable
               DECLARE @tNormalLabelList_Step3  VariableTable

               SET @nLoopIndex = -1
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1
                     @cLabelName = LabelName,
                     @nWorkOrderDetailQty = Qty,
                     @cLabelListName = LabelListName,
                     @nLoopIndex = ID
                  FROM @tLabels
                  WHERE ID > @nLoopIndex
                  ORDER BY ID

                  SELECT @nRowCount = @@ROWCOUNT

                  IF @nRowCount = 0
                     BREAK

                  -- FCR-13167: Print 1 copy per scan instead of @nWorkOrderDetailQty copies at completion
                  IF @cLabelListName = 'LVSPRICELB'
                  BEGIN
                     DELETE FROM @tPriceLabelList_Step3

                     INSERT INTO @tPriceLabelList_Step3 (Variable, Value)
                     VALUES
                        ('@cLabelNo', @cDropID),
                        ('@cSKU', @cSKU)

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                        @cLabelName,
                        @tPriceLabelList_Step3,
                        'rdt_855ExtUpd24',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT,
                        @nNoOfCopy = 1

                     IF @nErrNo <> 0
                     BEGIN
                        GOTO Quit
                     END
                  END
                  ELSE IF @cLabelListName = 'LVSCatalog'
                  BEGIN
                     DELETE FROM @tcatelogLabelList_Step3

                     INSERT INTO @tcatelogLabelList_Step3 (Variable, Value)
                     VALUES
                        ('@cLabelNo', @cDropID),
                        ('@cSKU', @cSKU)

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                        @cLabelName,
                        @tcatelogLabelList_Step3,
                        'rdt_855ExtUpd24',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT,
                        @nNoOfCopy = 1

                     IF @nErrNo <> 0
                     BEGIN
                        GOTO Quit
                     END
                  END
                  ELSE IF @cLabelListName = 'WKORDTYPE'
                  BEGIN
                     DELETE FROM @tNormalLabelList_Step3

                     INSERT INTO @tNormalLabelList_Step3 (Variable, Value)
                     VALUES
                        ('@cLabelNo', @cDropID),
                        ('@cSKU', @cSKU)

                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                        @cLabelName,
                        @tNormalLabelList_Step3,
                        'rdt_855ExtUpd24',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT,
                        @nNoOfCopy = 1

                     IF @nErrNo <> 0
                     BEGIN
                        GOTO Quit
                     END
                  END
               END
            -- Clear @tLabels for potential reuse in print screen
            DELETE FROM @tLabels
         END
         -- End of @nInputKey = 1
      END
      -- End of Scn 6911 SKU scan

      -- FCR-13167: Handle auto-print from scn 6911 (GOTO PRINT_LABEL) or manual from scn 6464
      -- This handles Carton Label printing (VAS labels already printed in SKU scan above)
      IF @nScn = 6464 OR (@nScn = 6911 AND @cOption IN ('M', 'A'))
      BEGIN
         -- FCR-13167: For SUO, convert DropID (ToteID) to LabelNo for unified downstream processing
         -- PackInfo.RefNo = LabelNo (not DropID/ToteID), so we need this conversion
         IF @cSingleUnitOrdFlag = 'Y'
         BEGIN
            DECLARE @cToteID_SUO NVARCHAR(20) = @cDropID -- Save original ToteID
            DECLARE @cLabelNo_SUO NVARCHAR(20)

            SELECT TOP 1
               @cOrderKey = PH.OrderKey,
               @cPickSlipNo = PD.PickSlipNo,
               @cLabelNo_SUO = PD.LabelNo
            FROM PackInfo PI WITH (NOLOCK)
            INNER JOIN PackDetail PD WITH (NOLOCK)
               ON PI.PickSlipNo = PD.PickSlipNo
               AND PI.CartonNo = PD.CartonNo
            INNER JOIN PickHeader PH WITH (NOLOCK)
               ON PD.PickSlipNo = PH.PickHeaderKey
               AND PD.StorerKey = PH.StorerKey
            WHERE
               PD.StorerKey = @cStorerKey
               AND PD.DropID = @cToteID_SUO
               AND PD.SKU = @cSKU
               AND ISNULL(PI.CartonStatus,'') <> 'PACKED'

            -- Convert DropID to LabelNo for downstream processing
            IF ISNULL(@cLabelNo_SUO, '') <> ''
               SET @cDropID = @cLabelNo_SUO
         END

         IF @nInputKey = 1
         BEGIN
            -- FCR-13167: Step 3 completion logic from ExtUpd13 (excluding VAS code display)
            -- Get total counts for entire carton (RDTPPA.DropID is already LabelNo after SUO conversion)
               SELECT @nTotalCQty = SUM(CQty)
               FROM RDT.RDTPPA WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cDropID

               -- Now @cDropID = LabelNo for both SUO and Normal, use CaseID for PickDetail
               SELECT @nTotalPQty = SUM(Qty)
               FROM dbo.PickDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND CaseID <> ''
                  AND CaseID = @cDropID
                  AND Status NOT IN ('4', '9')

               SET @cTempOrderKey = ''
               SET @cOrderGroup = ''

               -- Now @cDropID = LabelNo for both SUO and Normal, use CaseID for PickDetail
               SELECT TOP 1 @cTempOrderKey = OrderKey
               FROM dbo.PICKDETAIL WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND CaseID <> ''
                  AND CaseID = @cDropID

               SELECT @cOrderGroup = OrderGroup,
                  @cShipperKey = ISNULL(ShipperKey, '')
               FROM dbo.ORDERS WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND OrderKey = @cTempOrderKey

               -- FCR-13167: VAS labels are now printed during SKU scan (above)
               -- This section only handles carton completion (mark PACKED, calc weight, etc.)

               BEGIN TRY
                  -- Mark PPA as 5 (audit finished)
                  DELETE FROM @tRDTPPA

                  INSERT INTO @tRDTPPA (RowRef)
                  SELECT DISTINCT RowRef
                  FROM RDT.RDTPPA WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cDropID
                  SELECT @nRowCount = @@ROWCOUNT

                  IF @nRowCount > 0
                  BEGIN
                     UPDATE RP
                     SET Status = '5'
                     FROM RDT.RDTPPA RP WITH(ROWLOCK)
                     INNER JOIN @tRDTPPA TRP ON RP.RowRef = TRP.RowRef
                  END

                  -- Carton audit finished
                  -- 1. Mark PackInfo as PACKED
                  -- 2. Calculate carton weight
                  -- 3. Print PackSlipNo report once an order is finished
                  -- 4. If all Packedinfo are marked as PACKED, mark PackHeader as 9
                  -- 5. Insert transmitlog2
                  IF @nTotalPQty = @nTotalCQty
                  BEGIN
                     -- Mark PackInfo as PACKED
                     UPDATE dbo.PackInfo WITH(ROWLOCK)
                     SET CartonStatus = 'PACKED'
                     WHERE
                        RefNo IS NOT NULL
                        AND RefNo = @cDropID

                     -- Calculate carton weight
                     SELECT @nPickSlipNoQty = COUNT(DISTINCT PickSlipNo)
                     FROM dbo.PackInfo WITH(NOLOCK)
                     WHERE RefNo IS NOT NULL
                        AND RefNo = @cDropID
                        AND CartonStatus = 'PACKED'

                     INSERT INTO @tCartonWeight (CaseID, PickSlipNo, CartonNo, Weight)
                     SELECT LabelNo, PickSlipNo, CartonNo, InvWeight + CartonWeight
                     FROM
                        (SELECT PD.LabelNo, PH.PickSlipNo, PD.CartonNo, SUM(SKU.STDNETWGT * PD.qty) AS InvWeight, CART.CartonWeight / ISNULL(@nPickSlipNoQty, 1) AS CartonWeight
                        FROM PACKDETAIL PD (nolock)
                        INNER JOIN SKU (nolock) on  PD.storerkey = SKU.storerkey and PD.sku=SKU.sku
                        INNER JOIN packheader PH (nolock) on PH.pickslipno = PD.pickslipno
                        INNER JOIN dbo.PackInfo PKI WITH(NOLOCK) ON PD.PickSlipNo = PKI.PickSlipNo AND PD.CartonNo = PKI.CartonNo
                        INNER JOIN dbo.Storer STORER WITH (NOLOCK) ON PD.StorerKey = STORER.StorerKey
                        INNER JOIN dbo.CARTONIZATION CART WITH(NOLOCK) ON Storer.CartonGroup = CART.CartonizationGroup AND CART.CartonType = PKI.CartonType
                        WHERE PD.LabelNo = @cDropID
                           AND PKI.CartonStatus = 'PACKED'
                           AND PD.StorerKey = @cStorerKey
                           GROUP BY PD.StorerKey, PH.PickSlipNo, PD.CartonNo, PD.labelno, CART.CartonWeight) AS t

                     UPDATE PI
                     SET PI.Weight = CW.Weight
                     FROM dbo.PackInfo PI WITH(ROWLOCK)
                     INNER JOIN @tCartonWeight CW ON PI.RefNo = CW.CaseID AND PI.PickSlipNo = CW.PickSlipNo
                     WHERE
                        PI.RefNo IS NOT NULL
                        AND PI.RefNo = @cDropID

                     -- Print PackSlipNo report once an order is finished
                     DELETE FROM @tOrder

                     INSERT INTO @tOrder( OrderKey )
                     SELECT DISTINCT OrderKey
                     FROM dbo.PickDetail WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND CaseID <> ''
                        AND CaseID = @cDropID

                     DELETE FROM @tMPOCLabels
                     SET @nLoopIndex = -1

                     WHILE 1 = 1
                     BEGIN
                        SELECT TOP 1
                           @cOrderKey = OrderKey,
                           @nLoopIndex = id
                        FROM @tOrder
                        WHERE id > @nLoopIndex
                        ORDER BY id
                        SET @nRowCount = @@ROWCOUNT

                        IF @nRowCount = 0
                           BREAk

                        IF (SELECT COUNT( DISTINCT CaseID )
                           FROM dbo.PICKDETAIL WITH(NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND OrderKey = @cOrderKey
                              AND Status NOT IN ('4', '9')
                              AND CaseID <> '')
                           =
                           (SELECT COUNT( DISTINCT RefNo )
                           FROM dbo.PICKDETAIL PKD WITH(NOLOCK)
                           INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PKD.CaseID = PI.RefNo
                           WHERE PKD.StorerKey = @cStorerKey
                              AND PKD.OrderKey = @cOrderKey
                              AND PI.CartonStatus = 'PACKED'
                              AND PI.RefNo IS NOT NULL
                              AND PI.RefNo <> '')
                        BEGIN
                           -- Print Logi report
                           SELECT @cConsigneeKey = ISNULL(ConsigneeKey, ''),
                              @cBillToKey = ISNULL(BillToKey, '')
                           FROM dbo.ORDERS WITH(NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND OrderKey = @cOrderKey

                           -- If an order has consigneekey or billtokey associated with codelkup.code where codelkup.listname = MPOCPERMIT and short != 0, short not NULL, short not blank then exclude from auto-print logic
                           SELECT @cMPOCFlag = ISNULL(Short, '')
                           FROM dbo.CODELKUP WITH(NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND LISTNAME = 'MPOCPERMIT'
                              AND Code IN (@cConsigneeKey, @cBillToKey)
                           ORDER BY IIF(Code = @cConsigneeKey, 1, 2)

                           IF TRIM(ISNULL(@cMPOCFlag, '')) NOT IN ('', '0')
                              CONTINUE

                           SELECT @cOLPSCode = ISNULL(Long, '')
                           FROM dbo.CODELKUP WITH(NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND LISTNAME = 'LVSCUSPREF'
                              AND Description = @cOLPSDescription
                              AND ISNULL(code2, '') <> ''
                              AND code2 IN (@cConsigneeKey, @cBillToKey)
                           ORDER BY IIF(code2 = @cConsigneeKey, 1, 2)

                           SET @nRowCount = @@ROWCOUNT

                           -- If cOLPSCode is not one of ('1', '2', '3', '5'), no need to print logi report automatically
                           IF @nRowCount = 0 OR TRIM(ISNULL(@cOLPSCode, '')) NOT IN ('1', '2', '3', '5')
                              CONTINUE

                           -- codelkup.listname = 'LVSCUSPREF' not available for consigneekey/billtokey
                           IF NOT EXISTS (SELECT 1
                              FROM dbo.CODELKUP WITH(NOLOCK)
                              WHERE StorerKey = @cStorerKey
                                 AND LISTNAME = 'LVSCUSPREF'
                                 AND ISNULL(code2, '') <> ''
                                 AND code2 IN (@cConsigneeKey, @cBillToKey))
                           BEGIN
                              CONTINUE
                           END

                           INSERT INTO @tMPOCLabels (LabelName, OrderKey)
                           VALUES('LVSPSORD', @cOrderKey)
                        END
                     END

                     -- Mark PackHeader as 9
                     INSERT INTO @tPickSlipNoList (PickSlipNo)
                     SELECT DISTINCT PH.PickHeaderKey
                     FROM dbo.PickHeader PH WITH(NOLOCK)
                     INNER JOIN dbo.PickDetail PKD WITH(NOLOCK)
                        ON PH.StorerKey = PKD.StorerKey
                        AND PH.OrderKey = PKD.OrderKey
                     WHERE PKD.StorerKey = @cStorerKey
                        AND pkd.CaseID <> ''
                        AND pkd.CaseID = @cDropID

                     SET @nLoopIndex = -1
                     WHILE 1 = 1
                     BEGIN
                        SELECT TOP 1
                           @cPickSlipNo = PickSlipNo,
                           @nLoopIndex = id
                        FROM @tPickSlipNoList
                        WHERE id > @nLoopIndex
                        ORDER BY id

                        SET @nRowCount = @@ROWCOUNT

                        IF @nRowCount = 0
                           BREAk

                        -- Meet below conditions, mark PackHeader as 9
                        -- 1. all packinfo marked as 'PACKED'
                        -- 2. all PickDetails are finished
                        -- 3. Count(PickDetail.CaseID) = Count(PackDetail.LabelNo)
                        IF (SELECT COUNT(1) FROM dbo.PackInfo WITH(NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
                           =
                           (SELECT COUNT(1) FROM dbo.PackInfo WITH(NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND ISNULL(CartonStatus, '') = 'PACKED')
                           AND NOT EXISTS (SELECT 1
                                          FROM dbo.PickHeader PH WITH(NOLOCK)
                                          INNER JOIN dbo.PickDetail PD WITH(NOLOCK)
                                             ON PH.StorerKey = PD.StorerKey
                                             AND PH.OrderKey = PD.OrderKey
                                          WHERE PH.StorerKey = @cStorerkey
                                             AND PH.PickHeaderKey = @cPickSlipNo
                                             AND PD.Status < '4'
                                             AND PD.QTY > 0
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
                                    AND PD.qty > 0)
                        BEGIN
                           UPDATE dbo.PackHeader WITH(ROWLOCK)
                           SET Status = '9'
                           WHERE PickSlipNo = @cPickSlipNo
                        END
                     END

                     -- FCR-13167: ShipperKey/WSSOECL/ReferenceID logic moved to rdt_855ExtScn05.sql
                     -- Triggered on first SKU scan instead of completion
                  END

               END TRY
               BEGIN CATCH
                  IF @nErrNo = 0
                  BEGIN
                     SET @nErrNo = 217803
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --HandlePPAFail
                  END

                  GOTO Quit
               END CATCH

               -- Print MPOC label
               SET @nLoopIndex = -1
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1
                     @cLabelName = LabelName,
                     @cOrderKey = OrderKey,
                     @nLoopIndex = id
                  FROM @tMPOCLabels
                  WHERE id > @nLoopIndex
                  ORDER BY id

                  IF @@ROWCOUNT = 0
                     BREAK

                  DELETE FROM @tPackSlipList
                  INSERT INTO @tPackSlipList (Variable, Value)
                  VALUES
                     ( '@cStorerKey', @cStorerKey),
                     ( '@cOrderKey', @cOrderKey)

                  -- Print Order Level packing list label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                     @cLabelName, -- Report type
                     @tPackSlipList, -- Report params
                     'rdt_855ExtUpd24',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT,
                     @nNoOfCopy = 1

                  IF @nErrNo <> 0
                  BEGIN
                     GOTO Quit
                  END
               END
            -- FCR-13167: End of step 3 completion logic

            -- FCR-13167: Map option values from auto-print (M->1, A->5)
            IF @cOption = 'M'
               SET @cOption = '1'
            ELSE IF @cOption = 'A'
               SET @cOption = '5'

            DECLARE @tPackDetail TABLE
            (
               PickSlipNo NVARCHAR(10),
               CartonNo   INT,
               LabelNo    NVARCHAR(20),
               LabelLine  NVARCHAR(5),
               PRIMARY KEY (PickSlipNo, CartonNo, LabelNo, LabelLine)
            )

            DECLARE @tPickDetail TABLE
            (
               PickDetailKey  NVARCHAR(18) PRIMARY KEY CLUSTERED
            )

            IF @cOption = '1'
            BEGIN
               --print labels
               EXEC rdt.rdt_LevisPrintCartonLabel
                  @nMobile, @nFunc, @cLangCode, @cStorerKey, @nStep, @nInputKey
                  ,@cDropID
                  ,'BARTENDER'
                  ,@nErrNo    OUTPUT
                  ,@cErrMsg   OUTPUT
                  ,'rdt_855ExtUpd24'

               IF @nErrNo <> 0
               BEGIN
                  GOTO Quit
               END
            END
            ELSE IF @cOption = '5'
            BEGIN
               -- print 4x2 or PL
               IF EXISTS (
                  SELECT 1 FROM dbo.ORDERS ord WITH(NOLOCK)
                                   INNER JOIN dbo.PickDetail pd WITH(NOLOCK) ON ord.OrderKey = pd.OrderKey
                                   INNER JOIN dbo.Wave w WITH(NOLOCK) ON ord.UserDefine09 = w.WaveKey
                  WHERE ord.StorerKey = @cStorerKey
                    AND pd.StorerKey = @cStorerKey
                    AND pd.CaseID = @cDropID
                    AND w.UserDefine09 = 'Y')
               -- Commnted by NickT, FCR-7845 no need to chec if it is a parcel order, print 4X2 label for all orders
               -- AND NOT EXISTS(
               --    SELECT 1 FROM dbo.codelkup cl WITH(NOLOCK)
               --       INNER JOIN dbo.ORDERS ord WITH(NOLOCK) ON ord.ShipperKey = cl.short
               --       INNER JOIN dbo.PickDetail pd WITH(NOLOCK) ON ord.OrderKey = pd.OrderKey
               --    WHERE ord.StorerKey = @cStorerKey
               --      AND pd.StorerKey = @cStorerKey
               --      AND pd.CaseID = @cDropID
               --      AND cl.listname = 'WSCourier'
               --      and cl.code = 'ECL-1' )
               BEGIN
                  --print 4X2 label
                  DECLARE @t4x2ParamList VariableTable
                  INSERT INTO @t4x2ParamList (Variable, Value)
                  VALUES
                     ( '@cSSCC', @cDropID)

                  EXEC rdt.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                       'GNSSCCLBL', -- Report type
                       @t4x2ParamList, -- Report params
                       'rdt_855ExtUpd24',
                       @nErrNo  OUTPUT,
                       @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                  BEGIN
                     GOTO Quit
                  END
               END

               /** print ZPL */
               EXEC rdt.rdt_LevisPrintCartonLabel
                    @nMobile, @nFunc, @cLangCode, @cStorerKey, @nStep, @nInputKey
                  ,@cDropID
                  ,'ZPL'
                  ,@nErrNo    OUTPUT
                  ,@cErrMsg   OUTPUT
                  ,'rdt_855ExtUpd24'

               IF @nErrNo <> 0
               BEGIN
                  GOTO Quit
               END
            END

            --v1.21.0 start
            -- archiving dropid logic move out of Opt=1 or opt=5
            SET @nTranCount = @@TRANCOUNT
            IF @nTranCount = 0
               BEGIN TRAN
            ELSE
               SAVE TRAN rdt_855TransLog2
            --V1.21.0 end

            IF @cOption = '1' OR @cOption = '5'
            BEGIN
               --SET @nTranCount = @@TRANCOUNT --1.21.0

               SELECT TOP 1 @cToteID = DropID
               FROM dbo.PickDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                 AND CaseID = @cDropID
                 AND ShipFlag <> 'Y'

               INSERT INTO @tWaveKeys (WaveKey)
               SELECT DISTINCT UserDefine09
               FROM dbo.ORDERS ord WITH(NOLOCK)
               INNER JOIN dbo.PickDetail pd WITH(NOLOCK) ON ord.OrderKey = pd.OrderKey
               WHERE ord.StorerKey = @cStorerKey
                 AND pd.StorerKey = @cStorerKey
                 AND pd.CaseID = @cDropID

               SELECT @nWaveKeyCount = COUNT(*) FROM @tWaveKeys;

               -- add record into transmitlog2
               --BEGIN TRAN  --1.20.0
               --SAVE TRAN rdt_855TransLog2 --1.20.0

               WHILE @nWaveKeyCount > 0
               BEGIN
                  SELECT TOP 1 @cWaveKey = WaveKey FROM @tWaveKeys

                  IF EXISTS(SELECT 1 FROM dbo.Wave WITH(NOLOCK) WHERE WaveKey = @cWaveKey AND ISNULL(UserDefine09, '') = 'Y')
                  BEGIN
                     EXECUTE ispGenTransmitLog2
                              @c_TableName      = 'WSCTNAdd',
                              @c_Key1           = @cWaveKey,
                              @c_Key2           = @cDropID, -- LabelNo/CaseID
                              @c_Key3           = @cStorerkey,
                              @c_TransmitBatch  = '',
                              @b_Success        = @bSuccess   OUTPUT,
                              @n_err            = @nErrNo     OUTPUT,
                              @c_errmsg         = @cErrMsg    OUTPUT
                     IF @nErrNo <> 0 OR @bSuccess <> 1
                     BEGIN
                        IF @nTranCount > 0
                           ROLLBACK TRAN rdt_855TransLog2
                        ELSE
                           ROLLBACK TRAN
                        GOTO Quit
                     END
                  END

                  --V1.13.0 start
                  /*
                  IF @cDropIDFlag = 'Y' AND LEN(@cToteID) = 10
                  BEGIN
                     EXECUTE ispGenTransmitLog2
                              @c_TableName      = 'WSSortTotRel',
                              @c_Key1           = @cWaveKey,
                              @c_Key2           = @cToteID, -- Tote ID, dropid from pickdetail
                              @c_Key3           = @cStorerkey,
                              @c_TransmitBatch  = '',
                              @b_Success        = @bSuccess   OUTPUT,
                              @n_err            = @nErrNo     OUTPUT,
                              @c_errmsg         = @cErrMsg    OUTPUT
                     IF @nErrNo <> 0 OR @bSuccess <> 1
                     BEGIN
                        ROLLBACK TRAN rdt_855TransLog2
                        GOTO Quit
                     END
                  END*/ --v1.13.0 end

                  -- renew loop controll
                  DELETE FROM @tWaveKeys WHERE WaveKey = @cWaveKey;
                  SELECT @nWaveKeyCount = COUNT(*) FROM @tWaveKeys;
               END --WSCTNAdd

               --V1.13.0 start
               IF @cDropIDFlag = 'Y'
               BEGIN
                  INSERT INTO @tDropID (DropID)
                  SELECT DISTINCT DropID
                  FROM dbo.PackDetail WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND LabelNo = @cDropID --The scanned dropid is the label no in packdetail

                  SET @nDropIDMax = @@ROWCOUNT
                  SET @nDropIDCounter = 1

                  IF @bDebugFlag = 1
                  BEGIN
                     SELECT 'Temp Drop ID list'
                     SELECT * FROM @tDropID
                  END

                  IF @nDropIDCounter <= @nDropIDMax
                  BEGIN
                     SELECT @cPackDropID = ISNULL(DropID, '')
                     FROM @tDropID
                     WHERE RowNumber = @nDropIDCounter

                     IF @cPackDropID <> '' AND LEN(@cPackDropID) = 10
                     BEGIN
                        IF @bDebugFlag = 1
                           SELECT 'Send TransmitLog2', @cPackDropID AS PackDropID, @cDropID AS PackLabelNo
                        EXECUTE ispGenTransmitLog2
                           @c_TableName      = 'WSSortTotRel',
                           @c_Key1           = @cPackDropID, --PackDetail DropID
                           @c_Key2           = @cDropID, -- PackDetail LabelNo
                           @c_Key3           = @cStorerkey,
                           @c_TransmitBatch  = '',
                           @b_Success        = @bSuccess   OUTPUT,
                           @n_err            = @nErrNo     OUTPUT,
                           @c_errmsg         = @cErrMsg    OUTPUT
                        IF @nErrNo <> 0 OR @bSuccess <> 1
                        BEGIN
                           IF @nTranCount > 0
                              ROLLBACK TRAN rdt_855TransLog2
                           ELSE
                              ROLLBACK TRAN
                           GOTO Quit
                        END
                     END --create transmitlog2
                     ELSE
                     BEGIN
                        IF @bDebugFlag = 1
                           SELECT 'Fail to Send TransmitLog2',  @cPackDropID AS PackDropID, @cDropID AS PackLabelNo
                     END
                     SET @nDropIDCounter = @nDropIDCounter + 1
                  END --end while
               END --WSSortTotRel
               --V1.13.0 end

               --V1.21.0 Move dropid archiving logic out

               --WHILE @@TRANCOUNT > @nTranCount --V1.21.0
                  --COMMIT TRAN
            END --option in 1 or 5

            --archive dropid to reuse
            --V1.21.0 start
            IF @cOption = '9' -- get toteid when option = 9
               SELECT TOP 1 @cToteID = DropID
                  FROM dbo.PickDetail WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND CaseID = @cDropID
                  AND ShipFlag <> 'Y'

            --V1.23.0 start only archive tote when tote id not empty
            IF ISNULL(@cToteID,'') <> ''
            BEGIN
               IF @cSingleUnitOrdFlag = 'Y'
               BEGIN
                  IF NOT EXISTS (SELECT  1
                           FROM PackInfo PI WITH (NOLOCK)
                           INNER JOIN PackDetail PD WITH (NOLOCK)
                              ON PI.PickSlipNo = PD.PickSlipNo
                              AND PI.CartonNo = PD.CartonNo
                           INNER JOIN PickHeader PH WITH (NOLOCK)
                              ON PD.PickSlipNo = PH.PickHeaderKey
                              AND PD.StorerKey = PH.StorerKey
                           WHERE
                              PD.StorerKey = @cStorerKey
                              AND PD.DropID = @cToteID --ToteID
                              AND ISNULL(PI.CartonStatus,'') <> 'PACKED') -- All skus are packed in single unit order tote
                  BEGIN
                     DELETE FROM @tPackDetail

                     INSERT INTO @tPackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine)
                     SELECT DISTINCT PickSlipNo, CartonNo, LabelNo, LabelLine
                     FROM dbo.PackDetail WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID


                     BEGIN TRY
                        UPDATE PD
                           SET DropID = CONCAT('ARC',DropID)
                        FROM dbo.PackDetail PD WITH(ROWLOCK)
                        INNER JOIN @tPackDetail TPD
                        ON PD.PickSlipNo = TPD.PickSlipNo
                           AND PD.CartonNo = TPD.CartonNo
                           AND PD.LabelNo = TPD.LabelNo
                           AND PD.LabelLine = TPD.LabelLine
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 268666
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- PackDetail Archive Failed
                        IF @nTranCount > 0 ROLLBACK TRAN rdt_855TransLog2 ELSE ROLLBACK TRAN
                        GOTO Quit
                     END CATCH

                     DELETE FROM @tPickDetail

                     INSERT INTO @tPickDetail (PickDetailKey)
                     SELECT PickDetailKey
                     FROM dbo.PICKDETAIL WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID

                     BEGIN TRY
                        UPDATE PD
                           SET DropID = CONCAT('ARC',DropID),
                           TrafficCop = NULL
                        FROM dbo.PICKDETAIL PD WITH(ROWLOCK)
                        INNER JOIN @tPickDetail TPD
                        ON PD.PickDetailKey = TPD.PickDetailKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 268667
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- PickDetail Archive Failed
                        IF @nTranCount > 0 ROLLBACK TRAN rdt_855TransLog2 ELSE ROLLBACK TRAN
                        GOTO Quit
                     END CATCH

                     --UPDATE dbo.PackDetail WITH(ROWLOCK) SET DropID = CONCAT('ARC',DropID) WHERE DropID=@cToteID
                     --UPDATE dbo.PICKDETAIL WITH(ROWLOCK) SET DropID = CONCAT('ARC',DropID) WHERE DropID=@cToteID
                     UPDATE RDT.RDTMOBREC WITH(ROWLOCK) SET C_STRING1 = '' WHERE Mobile = @nMobile
                  END
               END
               ELSE IF @cDropIDFlag = 'Y'
               BEGIN
                  DELETE FROM @tPackDetail

                  INSERT INTO @tPackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine)
                  SELECT DISTINCT PickSlipNo, CartonNo, LabelNo, LabelLine
                  FROM dbo.PackDetail WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID

                  BEGIN TRY
                     UPDATE PD
                        SET DropID = CONCAT('ARC',DropID)
                     FROM dbo.PackDetail PD WITH(ROWLOCK)
                     INNER JOIN @tPackDetail TPD
                     ON PD.PickSlipNo = TPD.PickSlipNo
                        AND PD.CartonNo = TPD.CartonNo
                        AND PD.LabelNo = TPD.LabelNo
                        AND PD.LabelLine = TPD.LabelLine
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 268666
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- PackDetail Archive Failed
                     IF @nTranCount > 0 ROLLBACK TRAN rdt_855TransLog2 ELSE ROLLBACK TRAN
                     GOTO Quit
                  END CATCH

                  DELETE FROM @tPickDetail

                  INSERT INTO @tPickDetail (PickDetailKey)
                  SELECT PickDetailKey
                  FROM dbo.PICKDETAIL WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID

                  BEGIN TRY
                     UPDATE PD
                        SET DropID = CONCAT('ARC',DropID),
                        TrafficCop = NULL
                     FROM dbo.PICKDETAIL PD WITH(ROWLOCK)
                     INNER JOIN @tPickDetail TPD
                     ON PD.PickDetailKey = TPD.PickDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 268667
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- PickDetail Archive Failed
                     IF @nTranCount > 0 ROLLBACK TRAN rdt_855TransLog2 ELSE ROLLBACK TRAN
                     GOTO Quit
                  END CATCH

                  --UPDATE dbo.PackDetail WITH(ROWLOCK) SET DropID = CONCAT('ARC',DropID) WHERE DropID=@cToteID
                  --UPDATE dbo.PICKDETAIL WITH(ROWLOCK) SET DropID = CONCAT('ARC',DropID) WHERE DropID=@cToteID
                  UPDATE RDT.RDTMOBREC WITH(ROWLOCK) SET C_STRING1 = '' WHERE Mobile = @nMobile
               END
            END -- Tote ID <> ''
            ELSE
            BEGIN
               IF @bDebugFlag = 2
                  INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Col1, Col2, Col3, Col4, Col5)
                  VALUES ('855ToteArchive',GETDATE(), CAST(@nMobile AS NVARCHAR(10)), @cDropID, @cToteID, @cOption, '', '')
            END
            --V1.23.0

               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
            --V1.21.0 end
         END --scn6464, enter

      END
   END

   GOTO Quit
Quit:  

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_855ExtUpd24 TO NSQL
GO
