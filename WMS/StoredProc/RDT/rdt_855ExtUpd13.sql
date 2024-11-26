
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***********************************************************************************/
/* Store procedure: rdt_855ExtUpd13                                                */
/* Copyright      : Maersk                                                         */
/* Customer: Granite                                                               */
/*                                                                                 */
/* Purpose: Print the VAS label                                                    */
/*                                                                                 */
/* Modifications log:                                                              */
/* Date       Rev       Author   Purposes                                          */
/* 2024-06-18 1.0       NLT013   FCR-386. Created                                  */
/* 2024-08-06 1.1       Dennis   FCR-386. Remove order group condition             */
/* 2024-09-26 1.2       NLT013   UWP-24932 Error message UI issue                  */
/* 2024-09-30 1.3       NLT013   Fix printing special order labels issue           */
/* 2024-10-28 1.4.0     NLT013   FCR-1085 Automate print Order Level labels        */
/***********************************************************************************/

CREATE OR ALTER PROC rdt.rdt_855ExtUpd13 (
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
      @cMsg01                    NVARCHAR(20),
      @cMsg02                    NVARCHAR(20),
      @cMsg03                    NVARCHAR(20),
      @cMsg04                    NVARCHAR(20),
      @cMsg05                    NVARCHAR(20),
      @cMsg06                    NVARCHAR(20),
      @cMsg07                    NVARCHAR(20),
      @cMsg08                    NVARCHAR(20),
      @cMsg09                    NVARCHAR(20),
      @cMsg10                    NVARCHAR(20),
      @cVASCode                  NVARCHAR(20),
      @cVASCodeDesc              NVARCHAR(20),
      @c_QCmdClass               NVARCHAR(10)   = '',
      @cTransmitLogKey           NVARCHAR(10),
      @b_Debug                   INT = 0,
      @nRowCount                 INT,
      @nTotalPQty                INT,
      @nTotalCQty                INT,
      @nTranCount                INT,
      @nScn                      INT,
      @bSuccess                  INT,
      @cFacility                 NVARCHAR(5),
      @cLabelPrinterGroup        NVARCHAR(10),
      @cLabelPrinter             NVARCHAR(10),
      @cPaperPrinter             NVARCHAR(10),
      @cPackList                 NVARCHAR(20),
      @cExternWorkOrder          NVARCHAR(20),
      @cCode2                    NVARCHAR(30),

      @nError                    INT, 
      @cErrorMessage             NVARCHAR(4000),
      @xState                    INT,
      @cLabelName                NVARCHAR(30),
      @nWorkOrderDetailQty       INT,
      @cLabelListName            NVARCHAR(10),
      @cShipperKey               NVARCHAR(15),
      @cPickConfirmStatus        NVARCHAR( 1),
      @fCartonWeight             FLOAT,
      @fSKUWeight                FLOAT,
      @nVASQtyOverThan7          INT,
      @cConsigneeKey             NVARCHAR(15),
      @cBillToKey                NVARCHAR(15),
      @cMPOCFlag                 NVARCHAR(10),
      @cOLPSCode                 NVARCHAR(10),
      @cOLPSDescription          NVARCHAR(15) = 'OlpsPlacement'
      DECLARE @tPackSlipList     VariableTable

   DECLARE @tLabels TABLE
   (
      ID    INT IDENTITY(1,1),
      WorkOrderKey               NVARCHAR(10),
      WorkOrderLineNumber        NVARCHAR(5),
      LabelListName              NVARCHAR(10),
      VASCode                    NVARCHAR(12),
      LabelName                  NVARCHAR(30),
      Qty                        INT,
      PrintSequence              NVARCHAR(5)
   )

   DECLARE @tOrder TABLE
   (
      ID                      INT IDENTITY(1,1),
      OrderKey                NVARCHAR(10)
   )

   SET @nErrNo = 0
   SET @cErrMsg = ''

   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   IF @cPickConfirmStatus NOT IN ( '3', '5')
      SET @cPickConfirmStatus = '5'

   SELECT @nScn = Scn,
      @cLabelPrinterGroup = Printer,
      @cPaperPrinter = Printer_Paper
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile
   
   IF @nFunc = 855 -- Post Pick Audit
   BEGIN
      IF @nStep = 1 -- CartonID
      BEGIN
         IF EXISTS(SELECT 1 FROM RDT.RDTPPA WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cDropID AND Status = '2')
            UPDATE RDT.RDTPPA WITH(ROWLOCK)
            SET Status = '0',
               CQty = 0
            WHERE StorerKey = @cStorerKey
               AND DropID = @cDropID
               AND Status = '2'
      END
      ELSE IF @nStep = 3 -- SKU/UPC
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            SELECT @nTotalPQty = SUM(PQty), @nTotalCQty = SUM(CQty)
            FROM RDT.RDTPPA WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND DropID = @cDropID
               AND Sku = @cSKU

            SELECT @cPickSlipNo = PickSlipNo
            FROM dbo.PackDetail WITH(NOLOCK) 
            WHERE StorerKey = @cStorerKey 
            AND labelno = @cDropID

            --Audit finished
            --1. Display all VAS code and print labels
            --2. Mark PPA as 5 (Audit finished)
            --3. Update Packheader
            --4. Insert transmitlog2
            IF @nTotalPQty = @nTotalCQty -- Audit finished
            BEGIN
               DECLARE @nDisplayVASHeader          INT = 1

               SELECT @nRowCount = COUNT(1)
               FROM RDT.RDTPPA WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cDropID
                  AND Status = '5'

               IF @nRowCount > 0
                  SET @nDisplayVASHeader = 0

               --Display VAS Header
               IF @nDisplayVASHeader = 1
               BEGIN
                  DECLARE @tVASHeader TABLE
                  (
                     RowIndex                INT IDENTITY(1,1),
                     Code                    NVARCHAR(30),
                     Description             NVARCHAR(30)
                  )
                  
                  INSERT INTO @tVASHeader (Code, Description)
                  SELECT DISTINCT
                        CLK.Code,
                        CLK.Description
                  FROM dbo.WorkOrderDetail WOD WITH(NOLOCK)
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON WOD.StorerKey = PKD.StorerKey AND WOD.ExternWorkOrderKey = PKD.OrderKey
                  INNER JOIN dbo.CODELKUP CLK WITH(NOLOCK) ON PKD.StorerKey = CLK.StorerKey AND CLK.LISTNAME = 'VASORD' AND WOD.Type = CLK.Code
                  WHERE PKD.StorerKey = @cStorerKey
                     AND ISNULL(PKD.CaseID, '') = @cDropID
                     AND WOD.ExternLineNo = '0H'
                  ORDER BY CLK.Code ASC
                  
                  SELECT @nRowCount = @@ROWCOUNT

                  IF @nRowCount > 0
                  BEGIN
                     SET @nLoopIndex = -1
                     WHILE 1 = 1
                     BEGIN
                        SELECT TOP 1
                           @nLoopIndex = RowIndex,
                           @cVASCode = Code, 
                           @cVASCodeDesc = Description
                        FROM @tVASHeader
                        WHERE RowIndex > @nLoopIndex
                        ORDER BY RowIndex

                        SELECT @nRowCount = @@ROWCOUNT

                        IF @nRowCount = 0
                           BREAK

                        SET @cMsg01 = 'VAS Header'
                        IF @nLoopIndex % 7 = 1 SET @cMsg02 = @cVASCode + '-' + @cVASCodeDesc
                        ELSE IF @nLoopIndex % 7  = 2 SET @cMsg03 = @cVASCode + '-' + @cVASCodeDesc
                        ELSE IF @nLoopIndex % 7  = 3 SET @cMsg04 = @cVASCode + '-' + @cVASCodeDesc
                        ELSE IF @nLoopIndex % 7  = 4 SET @cMsg05 = @cVASCode + '-' + @cVASCodeDesc
                        ELSE IF @nLoopIndex % 7  = 5 SET @cMsg06 = @cVASCode + '-' + @cVASCodeDesc
                        ELSE IF @nLoopIndex % 7  = 6 SET @cMsg07 = @cVASCode + '-' + @cVASCodeDesc
                        ELSE IF @nLoopIndex % 7  = 0 SET @cMsg08 = @cVASCode + '-' + @cVASCodeDesc

                        IF @cMsg01 IS NOT NULL AND TRIM(@cMsg01) <> '' AND @nLoopIndex % 7 = 0
                        BEGIN
                           EXEC rdt.rdtInsertMsgQueue 
                              @nMobile = @nMobile, 
                              @nErrNo = @nErrNo, 
                              @cErrMsg = @cErrMsg, 
                              @cLine01 = @cMsg01, 
                              @cLine02 = @cMsg02, 
                              @cLine03 = @cMsg03, 
                              @cLine04 = @cMsg04, 
                              @cLine05 = @cMsg05, 
                              @cLine06 = @cMsg06, 
                              @cLine07 = @cMsg07, 
                              @cLine08 = @cMsg08, 
                              @cLine09 = @cMsg09, 
                              @nDisplayMsg = 0

                           SET @cMsg01 = ''
                           SET @cMsg02 = ''
                           SET @cMsg03 = ''
                           SET @cMsg04 = ''
                           SET @cMsg05 = ''
                           SET @cMsg06 = ''
                           SET @cMsg07 = ''
                           SET @cMsg08 = ''
                        END
                     END

                     IF @cMsg02 IS NOT NULL AND TRIM(@cMsg02) <> ''
                     BEGIN
                        SET @cMsg01 = 'VAS Header'
                        EXEC rdt.rdtInsertMsgQueue 
                           @nMobile = @nMobile, 
                           @nErrNo = @nErrNo, 
                           @cErrMsg = @cErrMsg, 
                           @cLine01 = @cMsg01, 
                           @cLine02 = @cMsg02, 
                           @cLine03 = @cMsg03, 
                           @cLine04 = @cMsg04, 
                           @cLine05 = @cMsg05, 
                           @cLine06 = @cMsg06, 
                           @cLine07 = @cMsg07, 
                           @cLine08 = @cMsg08, 
                           @cLine09 = @cMsg09, 
                           @nDisplayMsg = 0

                        SET @cMsg01 = ''
                        SET @cMsg02 = ''
                        SET @cMsg03 = ''
                        SET @cMsg04 = ''
                        SET @cMsg05 = ''
                        SET @cMsg06 = ''
                        SET @cMsg07 = ''
                        SET @cMsg08 = ''
                     END
                  END
               END

               SELECT @nRowCount = COUNT(1) 
               FROM dbo.WorkOrder wo WITH(NOLOCK)
               INNER JOIN dbo.WorkOrderDetail wod WITH(NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
               INNER JOIN dbo.PackHeader ph WITH(NOLOCK) ON wo.StorerKey = ph.StorerKey AND ISNULL(wo.ExternWorkOrderKey, '') = ph.OrderKey
               INNER JOIN dbo.PackDetail pd WITH(NOLOCK) ON ph.StorerKey = pd.StorerKey AND ph.PickSlipNo = pd.PickSlipNo
               INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON pd.StorerKey = pkd.StorerKey AND pd.labelno = ISNULL(pkd.CaseID, '') AND wod.ExternWorkOrderKey = pkd.OrderKey AND wod.ExternLineNo = pkd.OrderLinenumber
               INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND lk.LISTNAME = 'WKORDTYPE'
               WHERE pkd.StorerKey = @cStorerKey
                  AND ISNULL(pkd.CaseID, '') = @cDropID
                  AND (pd.SKU = ISNULL(wod.WkOrdUdef1, '') OR ISNULL(wod.WkOrdUdef1, '') = '')
               
               --1. VAS is needed, display VAS code and Print VAS label
               IF @nRowCount > 0
               BEGIN
                  SET @nLoopIndex = 1
                  SET @cMsg09 = ''

                  DECLARE CUR_PPA CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
                     SELECT DISTINCT
                        lk.Code,
                        lk.Description
                     FROM dbo.WorkOrderDetail wod WITH(NOLOCK)
                     INNER JOIN dbo.WorkOrder wo WITH(NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
                     INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND ISNULL(lk.Short, '') <> 'Y' AND lk.LISTNAME = 'WKORDTYPE'
                     INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wo.StorerKey = pkd.StorerKey AND ISNULL(wod.ExternWorkOrderKey, '') = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo
                     WHERE wo.StorerKey = @cStorerKey
                        AND pkd.Sku = @cSKU
                        AND ISNULL(pkd.CaseID, '') = @cDropID
                     ORDER BY lk.Code ASC
   
                  OPEN CUR_PPA 
                  FETCH NEXT FROM CUR_PPA INTO @cVASCode, @cVASCodeDesc

                  WHILE @@FETCH_STATUS = 0 
                  BEGIN
                     IF @nLoopIndex % 8 = 1 SET @cMsg01 = @cVASCode + '-' + @cVASCodeDesc
                     ELSE IF @nLoopIndex % 8  = 2 SET @cMsg02 = @cVASCode + '-' + @cVASCodeDesc
                     ELSE IF @nLoopIndex % 8  = 3 SET @cMsg03 = @cVASCode + '-' + @cVASCodeDesc
                     ELSE IF @nLoopIndex % 8  = 4 SET @cMsg04 = @cVASCode + '-' + @cVASCodeDesc
                     ELSE IF @nLoopIndex % 8  = 5 SET @cMsg05 = @cVASCode + '-' + @cVASCodeDesc
                     ELSE IF @nLoopIndex % 8  = 6 SET @cMsg06 = @cVASCode + '-' + @cVASCodeDesc
                     ELSE IF @nLoopIndex % 8  = 7 SET @cMsg07 = @cVASCode + '-' + @cVASCodeDesc
                     ELSE IF @nLoopIndex % 8  = 0 SET @cMsg08 = @cVASCode + '-' + @cVASCodeDesc

                     IF @cMsg01 IS NOT NULL AND TRIM(@cMsg01) <> '' AND @nLoopIndex % 8 = 0
                     BEGIN
                        EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile, 
                           @nErrNo = @nErrNo, 
                           @cErrMsg = @cErrMsg, 
                           @cLine01 = @cMsg01, 
                           @cLine02 = @cMsg02, 
                           @cLine03 = @cMsg03, 
                           @cLine04 = @cMsg04, 
                           @cLine05 = @cMsg05, 
                           @cLine06 = @cMsg06, 
                           @cLine07 = @cMsg07, 
                           @cLine08 = @cMsg08, 
                           @cLine09 = @cMsg09, 
                           @nDisplayMsg = 0

                        SET @cMsg01 = ''
                        SET @cMsg02 = ''
                        SET @cMsg03 = ''
                        SET @cMsg04 = ''
                        SET @cMsg05 = ''
                        SET @cMsg06 = ''
                        SET @cMsg07 = ''
                        SET @cMsg08 = ''
                     END

                     SET @nLoopIndex = @nLoopIndex + 1
                     FETCH NEXT FROM CUR_PPA INTO @cVASCode, @cVASCodeDesc
                  END
                  CLOSE CUR_PPA 
                  DEALLOCATE CUR_PPA 

                  IF @cMsg01 IS NOT NULL AND TRIM(@cMsg01) <> ''
                  BEGIN
                     EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile, 
                        @nErrNo = @nErrNo, 
                        @cErrMsg = @cErrMsg, 
                        @cLine01 = @cMsg01, 
                        @cLine02 = @cMsg02, 
                        @cLine03 = @cMsg03, 
                        @cLine04 = @cMsg04, 
                        @cLine05 = @cMsg05, 
                        @cLine06 = @cMsg06, 
                        @cLine07 = @cMsg07, 
                        @cLine08 = @cMsg08, 
                        @cLine09 = @cMsg09, 
                        @nDisplayMsg = 0

                     SET @cMsg01 = ''
                     SET @cMsg02 = ''
                     SET @cMsg03 = ''
                     SET @cMsg04 = ''
                     SET @cMsg05 = ''
                     SET @cMsg06 = ''
                     SET @cMsg07 = ''
                     SET @cMsg08 = ''
                  END

                  --1. Print price labels and catelogy labels
                  --Price Labels
                  INSERT INTO @tLabels(LabelListName, VASCode, LabelName, Qty, PrintSequence)
                  SELECT DISTINCT IIF(wodEX.LISTNAME IS NULL, lk.LISTNAME, wodEX.LISTNAME), wod.type, IIF(wodEX.UDF01 IS NULL, lk.UDF01, wodEX.UDF01), pkd.Qty, '00001'
                  FROM dbo.WorkOrderDetail wod  WITH(NOLOCK)
                  INNER JOIN dbo.WorkOrder wo WITH(NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
                  INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND lk.LISTNAME = 'WKORDTYPE' AND lk.UDF04 = 'LVSPRICELB'
                  INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wo.StorerKey = pkd.StorerKey AND ISNULL(wod.ExternWorkOrderKey, '') = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo AND pkd.Status = @cPickConfirmStatus
                  LEFT JOIN (SELECT DISTINCT lk1.LISTNAME, wod1.StorerKey, lk1.Code, Lk1.code2, lk1.UDF01 FROM dbo.WorkOrderDetail wod1 WITH(NOLOCK) 
                           INNER JOIN dbo.PickDetail pkd1 WITH(NOLOCK) ON wod1.StorerKey = pkd1.StorerKey AND ISNULL(wod1.ExternWorkOrderKey, '') = pkd1.OrderKey
                           INNER JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON wod1.StorerKey = lk1.StorerKey AND lk1.LISTNAME = 'LVSPRICELB' AND wod1.Type = lk1.code2
                           WHERE wod1.StorerKey = @cStorerKey
                              AND wod1.ExternLineNo = ''
                              AND wod1.Remarks = 'PriceTicketFormat'
                              AND ISNULL(pkd1.CaseID, '') = @cDropID) AS wodEX
                     ON wod.StorerKey = wodEX.StorerKey AND lk.Code = wodEX.Code
                  WHERE wo.StorerKey = @cStorerKey
                     AND pkd.Sku = @cSKU
                     AND ISNULL(pkd.CaseID, '') = @cDropID
                     AND wod.ExternLineNo <> ''

                  INSERT INTO @tLabels(WorkOrderKey, WorkOrderLineNumber, LabelListName, VASCode, LabelName, Qty, PrintSequence)
                  SELECT DISTINCT wod.WorkOrderKey, wod.WorkOrderLineNumber, IIF(lk1.LISTNAME IS NULL, lk.LISTNAME, lk1.LISTNAME), wod.Type, IIF(lk1.LISTNAME IS NULL, lk.UDF01, lk1.UDF01), pakd.Qty, lk.Code
                  FROM (SELECT StorerKey, WorkOrderKey, ExternWorkOrderKey, ExternLineNo, WorkOrderLineNumber, Type
                        FROM
                           (SELECT 
                              wod1.StorerKey, wod1.WorkOrderKey, wod1.ExternWorkOrderKey, wod1.ExternLineNo, wod1.WorkOrderLineNumber, wod1.Type, 
                              ROW_NUMBER()OVER(PARTITION BY WorkOrderKey, ExternWorkOrderKey, ExternLineNo ORDER BY WorkOrderKey, ExternWorkOrderKey, ExternLineNo) AS ROW# 
                              FROM dbo.WorkOrderDetail wod1 WITH(NOLOCK)
                              INNER JOIN dbo.CODELKUP lk2 WITH(NOLOCK) ON wod1.StorerKey = lk2.StorerKey AND lk2.LISTNAME = 'WKORDTYPE' AND lk2.UDF04 = 'LVSCatalog' AND wod1.Type = lk2.Code
                              WHERE wod1.StorerKey = @cStorerKey
                                 AND TRIM(wod1.Type) <> ''
                                 AND TRIM(wod1.ExternLineNo) <> '') AS t
                        WHERE ROW# = 1) AS wod
                  INNER JOIN dbo.WorkOrder wo WITH(NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
                  INNER JOIN dbo.ORDERS orm WITH(NOLOCK) ON wod.StorerKey = orm.StorerKey AND ISNULL(wod.ExternWorkOrderKey, '') = orm.OrderKey
                  INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND lk.LISTNAME = 'WKORDTYPE' AND lk.UDF04 = 'LVSCatalog' 
                  INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wo.StorerKey = pkd.StorerKey AND ISNULL(wod.ExternWorkOrderKey, '') = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo AND pkd.Status = @cPickConfirmStatus
                  INNER JOIN dbo.PackDetail pakd WITH(NOLOCK) ON pkd.StorerKey = pakd.StorerKey AND ISNULL(pkd.CaseID, '') = pakd.LabelNo AND pakd.SKU = pkd.SKU
                  LEFT JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON lk.StorerKey = lk1.StorerKey AND lk.Code = lk1.Code AND lk.UDF04 = lk1.LISTNAME AND lk1.Code2 <> ''
                     AND (orm.ConsigneeKey = lk1.Code2 OR  MarkforKey = lk1.Code2 OR BillToKey = lk1.Code2)
                  WHERE wo.StorerKey = @cStorerKey
                     AND pkd.Sku = @cSKU
                     AND ISNULL(pkd.CaseID, '') = @cDropID
                     AND wod.ExternLineNo <> ''
                  ORDER BY lk.Code ASC

                  DECLARE @tPriceLabelList   VariableTable
                  DECLARE @tcatelogLabelList   VariableTable
                  DECLARE @tNormalLabelList VariableTable

                  SET @nLoopIndex = -1
                  WHILE 1 = 1
                  BEGIN
                     SELECT TOP 1 
                        @cLabelName = LabelName,
                        @nWorkOrderDetailQty = Qty,
                        @cLabelListName = LabelListName,
                        @nLoopIndex = id
                     FROM @tLabels
                     WHERE id > @nLoopIndex
                     ORDER BY id

                     SELECT @nRowCount = @@ROWCOUNT

                     IF @nRowCount = 0
                        BREAK

                     IF @cLabelListName = 'LVSPRICELB'
                     BEGIN
                        DELETE FROM @tPriceLabelList

                        INSERT INTO @tPriceLabelList (Variable, Value) 
                        VALUES 
                           ( '@cPickSlipNo', @cPickSlipNo),
                           ( '@cLabelNo', @cDropID),
                           ( '@cSKU', @cSKU)

                        -- Print label
                        EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                           @cLabelName, -- Report type
                           @tPriceLabelList, -- Report params
                           'rdt_855ExtUpd13',
                           @nErrNo  OUTPUT,
                           @cErrMsg OUTPUT,
                           @nNoOfCopy = @nWorkOrderDetailQty
            
                        IF @nErrNo <> 0
                        BEGIN
                           GOTO Quit
                        END
                     END
                     ELSE IF @cLabelListName = 'LVSCatalog'
                     BEGIN
                        DELETE FROM @tcatelogLabelList
                        -- Common params
                        INSERT INTO @tcatelogLabelList (Variable, Value) 
                        VALUES 
                           ( '@cPickSlipNo', @cPickSlipNo),
                           ( '@cLabelNo', @cDropID),
                           ( '@cSKU', @cSKU)

                        -- Print label
                        EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                           @cLabelName, -- Report type
                           @tcatelogLabelList, -- Report params
                           'rdt_855ExtUpd13',
                           @nErrNo  OUTPUT,
                           @cErrMsg OUTPUT,
                           @nNoOfCopy = @nWorkOrderDetailQty
            
                        IF @nErrNo <> 0
                        BEGIN
                           GOTO Quit
                        END
                     END
                     ELSE IF @cLabelListName = 'WKORDTYPE'
                     BEGIN
                        DELETE FROM @tNormalLabelList
                        -- Common params
                        INSERT INTO @tNormalLabelList (Variable, Value)
                        VALUES 
                           ( '@cPickSlipNo', @cPickSlipNo),
                           ( '@cLabelNo', @cDropID),
                           ( '@cSKU', @cSKU)

                        -- Print label
                        EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                           @cLabelName, -- Report type
                           @tNormalLabelList, -- Report params
                           'rdt_855ExtUpd13',
                           @nErrNo  OUTPUT,
                           @cErrMsg OUTPUT,
                           @nNoOfCopy = @nWorkOrderDetailQty
            
                        IF @nErrNo <> 0
                        BEGIN
                           GOTO Quit
                        END
                     END
                  END
               END

               SELECT @nTotalPQty = SUM(PQty)
               FROM RDT.RDTPPA WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cDropID

               SELECT @nTotalCQty = SUM(Qty)
               FROM dbo.PickDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND ISNULL(CaseID, '') = @cDropID
                  AND Status NOT IN ('4', '9')

               DECLARE @cOrderGroup NVARCHAR(20) = ''

               SELECT TOP 1 @cOrderGroup = orm.OrderGroup,
                  @cShipperKey = ISNULL(ShipperKey, '')
               FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
               INNER JOIN dbo.ORDERS orm WITH(NOLOCK) ON pkd.StorerKey = orm.StorerKey AND pkd.OrderKey = orm.OrderKey
               WHERE pkd.StorerKey = @cStorerKey
                  AND ISNULL(pkd.CaseID, '') = @cDropID
               ORDER BY orm.OrderKey

               SET @nTranCount = @@TRANCOUNT  
               IF @nTranCount = 0
                  BEGIN TRANSACTION
               ELSE
                  SAVE TRANSACTION rdt_855ExtUpd13_01

               BEGIN TRY
                  --Mark PPA as 5 (audit finished)
                  UPDATE RDT.RDTPPA WITH(ROWLOCK)
                  SET Status = '5' --Aduit finished
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cDropID
                     AND Sku = @cSKU

                  --Carton audit finished
                  --1. Mark PackInfo as PACKED
                  --2. Calculate carton weight
                  --3. Print PackSlipNo report once an order is finished
                  --4. If all Packedinfo are marked as PACKED, mark PackHeader as 9
                  --5. Insert transmitlog2
                  IF @nTotalPQty = @nTotalCQty
                  BEGIN
                     --Mark PackInfo as PACKED
                     UPDATE dbo.PackInfo WITH(ROWLOCK)
                     SET CartonStatus = 'PACKED'
                     WHERE PickSlipNo = @cPickSlipNo
                        AND ISNULL(RefNo, '') = @cDropID

                     --Calculate carton weight
                     DECLARE @tCartonWeight TABLE
                     (
                        CaseID            NVARCHAR(30),
                        Weight            FLOAT
                     )

                     INSERT INTO @tCartonWeight (CaseID, Weight)
                     SELECT CaseID, InvWeight + CartonWeight
                     FROM
                        (SELECT PKD.CaseID, CART.CartonWeight, SUM(PKD.qty * SKU.StdGrossWgt) AS InvWeight
                        FROM dbo.CARTONIZATION CART WITH(NOLOCK)
                        INNER JOIN dbo.PackInfo PKI WITH(NOLOCK) ON CART.CartonType = ISNULL(PKI.CartonType, '')
                        INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON ISNULL(PKI.RefNo, '') = ISNULL(PKD.CaseID, '-1') 
                        INNER JOIN dbo.SKU SKU WITH(NOLOCK) ON PKD.StorerKey = SKU.StorerKey AND PKD.Sku = SKU.Sku
                        WHERE PKI.PickSlipNo = @cPickSlipNo
                           AND PKD.StorerKey = @cStorerKey
                           AND PKD.Status = @cPickConfirmStatus
                        GROUP BY PKD.CaseID, CART.CartonWeight) AS t

                     UPDATE PI WITH(ROWLOCK) 
                     SET PI.Weight = CW.Weight
                     FROM dbo.PackInfo PI
                     INNER JOIN @tCartonWeight CW ON ISNULL(PI.RefNo, '') = CW.CaseID
                     WHERE PI.PickSlipNo = @cPickSlipNo

                     --Print PackSlipNo report once an order is finished
                     DELETE FROM @tOrder

                     INSERT INTO @tOrder( OrderKey )
                     SELECT DISTINCT OrderKey
                     FROM dbo.PickDetail WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND ISNULL(CaseID, '-1') = @cDropID

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
                              AND TRIM(CaseID) <> '')
                           =
                           (SELECT COUNT( DISTINCT RefNo )
                           FROM dbo.PICKDETAIL PKD WITH(NOLOCK)
                           INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON ISNULL(PKD.CaseID, '-1') = ISNULL(PI.RefNo, '')
                           WHERE PKD.StorerKey = @cStorerKey
                              AND PKD.OrderKey = @cOrderKey 
                              AND PI.CartonStatus = 'PACKED'
                              AND TRIM(ISNULL(RefNo, '')) <> '')
                        BEGIN
                           -- Print Logi report
                           SELECT @cConsigneeKey = ISNULL(ConsigneeKey, ''),
                              @cBillToKey = ISNULL(BillToKey, '')
                           FROM dbo.ORDERS WITH(NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND OrderKey = @cOrderKey

                           --If an order has consigneekey or billtokey associated with codelkup.code where codelkup.listname = MPOCPERMIT  and short ! = 0, short not NULL, short not blank  then exclude from auto-print logic
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

                           -- codelkup.listname = ‘LVSCUSPREF’ not available for consigneekey/billtokey
                           IF NOT EXISTS (SELECT 1  
                              FROM dbo.CODELKUP WITH(NOLOCK)
                              WHERE StorerKey = @cStorerKey
                                 AND LISTNAME = 'LVSCUSPREF' 
                                 AND ISNULL(code2, '') <> ''
                                 AND code2 IN (@cConsigneeKey, @cBillToKey))
                           BEGIN
                              CONTINUE
                           END

                           SET @cLabelName = 'LVSPSORD'
                           DELETE FROM @tPackSlipList
                           INSERT INTO @tPackSlipList (Variable, Value) 
                           VALUES 
                              ( '@cStorerKey', @cStorerKey),
                              ( '@cOrderKey', @cOrderKey)

                           -- Print Order Level packing list label
                           EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                              @cLabelName, -- Report type
                              @tPackSlipList, -- Report params
                              'rdt_855ExtUpd13',
                              @nErrNo  OUTPUT,
                              @cErrMsg OUTPUT,
                              @nNoOfCopy = 1

                           IF @nErrNo <> 0
                           BEGIN
                              GOTO Quit
                           END
                        END
                     END

                     --If all Packedinfo are marked as PACKED, mark PackHeader as 9
                     IF (SELECT COUNT(1) FROM dbo.PackInfo WITH(NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
                        =
                        (SELECT COUNT(1) FROM dbo.PackInfo WITH(NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND ISNULL(CartonStatus, '') = 'PACKED')
                     BEGIN
                        UPDATE dbo.PackHeader WITH(ROWLOCK)
                        SET Status = '9'
                        WHERE PickSlipNo = @cPickSlipNo
                     END

                     IF TRIM(@cShipperKey) <> ''
                        AND EXISTS(SELECT 1 FROM CODELKUP WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND LISTNAME = 'WSCourier' AND @cShipperKey = ISNULL(notes,'-1'))
                     BEGIN
                        DECLARE @cTrauncatedDropID    NVARCHAR(10) = @cDropID
                        -- Insert transmitlog2 here
                        EXECUTE ispGenTransmitLog2
                           @c_TableName      = 'WSSOECL',
                           @c_Key1           = @cTrauncatedDropID,
                           @c_Key2           = @cDropID,
                           @c_Key3           = @cStorerkey,
                           @c_TransmitBatch  = '',
                           @b_Success        = @bSuccess   OUTPUT,
                           @n_err            = @nErrNo     OUTPUT,
                           @c_errmsg         = @cErrMsg    OUTPUT

                        IF @bSuccess <> 1
                        BEGIN
                           SET @nErrNo = 217801
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenTranLogFail
                           ;THROW @nErrNo, @cErrMsg, 1
                        END

                        SELECT @cTransmitLogKey = transmitlogkey
                        FROM dbo.TRANSMITLOG2 WITH (NOLOCK)
                        WHERE tablename = 'WSSOECL'
                        AND   key1 = @cTrauncatedDropID
                        AND   key2 = @cDropID
                        AND   key3 = @cStorerkey
                        
                        EXEC dbo.isp_QCmd_WSTransmitLogInsertAlert 
                           @c_QCmdClass         = @c_QCmdClass, 
                           @c_FrmTransmitlogKey = @cTransmitLogKey, 
                           @c_ToTransmitlogKey  = @cTransmitLogKey, 
                           @b_Debug             = @b_Debug, 
                           @b_Success           = @bSuccess    OUTPUT, 
                           @n_Err               = @nErrNo      OUTPUT, 
                           @c_ErrMsg            = @cErrMsg     OUTPUT 

                        IF @bSuccess <> 1
                        BEGIN
                           SET @nErrNo = 217802
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QCmdFail
                           ;THROW @nErrNo, @cErrMsg, 1
                        END
                     END
                  END

                  WHILE @@TRANCOUNT > @nTranCount
                     COMMIT TRANSACTION
               END TRY
               BEGIN CATCH
                  IF @nTranCount > 0
                  BEGIN
                     IF XACT_STATE() <> -1  
                        ROLLBACK TRANSACTION rdt_855ExtUpd13_01
                  END
                  ELSE
                  BEGIN
                     ROLLBACK TRANSACTION
                  END

                  IF @nErrNo = 0
                  BEGIN
                     SET @nErrNo = 217803
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --HandlePPAFail
                     GOTO Quit
                  END
               END CATCH
            END
         END
      END
      ELSE IF @nStep = 4  --Discrepency found
      BEGIN
         IF @nInputKey = 1 -- Press Enter
         BEGIN
            IF @cOption = '1' -- 1. Send to QC, print QC label
            BEGIN
               --TBD Print 
               Print 'QC label'
            END
         END
      END
      ELSE IF @nStep = 5  --Print Pack List
      BEGIN
         IF @nInputKey = 1 -- Press Enter
         BEGIN
            IF @cOption = '1' -- 1. Print Carton Label
            BEGIN
               DECLARE 
                  @cCustLblPrintSequence     NVARCHAR(10),
                  @cDefaultLblPrintSequence  NVARCHAR(10),
                  @cCustLabelName            NVARCHAR(30),
                  @cDefaultLabelName         NVARCHAR(30),
                  @cCustLabelDataDesc        NVARCHAR(30),
                  @cCustomCode               NVARCHAR(30),
                  @nSpecialCartonLabelPrinted       INT = 0,
                  @nSpecialVendorLabelPrinted       INT = 0
                  

               SELECT @cPickSlipNo = PickSlipNo
               FROM dbo.PackDetail WITH(NOLOCK) 
               WHERE StorerKey = @cStorerKey 
                  AND labelno = @cDropID

               DECLARE @tCartonLabelList VariableTable
               INSERT INTO @tCartonLabelList (Variable, Value) 
               VALUES 
                     ( '@cPickSlipNo', @cPickSlipNo),
                     ( '@cLabelNo', @cDropID)

               DECLARE @tDefaultLabels TABLE
               (
                  id             INT IDENTITY(1,1),
                  Code           NVARCHAR(30),
                  code2          NVARCHAR(30),
                  UDF01          NVARCHAR(30),
                  Short          NVARCHAR(10)
               )

               INSERT INTO @tDefaultLabels (code2, UDF01, Short, Code)
               SELECT code2, UDF01, Short, Code
               FROM dbo.CODELKUP WITH(NOLOCK) 
               WHERE StorerKey = @cStorerKey
                  AND LISTNAME = 'LVSCARTLBL'
                  AND ISNULL(Long, '') = 'A'
               ORDER BY ISNULL(Short, '99999')

               DECLARE @tCustWorkOrderLabels TABLE
               (
                  id             INT IDENTITY(1,1),
                  Type           NVARCHAR(12),
                  UDF01          NVARCHAR(30),
                  code2          NVARCHAR(30)
               )

               INSERT INTO @tCustWorkOrderLabels (Type, UDF01, code2)
               SELECT DISTINCT lk.Code, lk.UDF01, lk.code2
               FROM dbo.WorkOrder wo WITH(NOLOCK)
               INNER JOIN dbo.WorkOrderDetail wod WITH(NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
               INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wod.StorerKey = pkd.StorerKey AND wod.ExternWorkOrderKey = pkd.OrderKey 
               INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wod.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND lk.LISTNAME = 'LVSCARTLBL' AND ISNULL(wod.Remarks, '-1') = lk.code2
               WHERE wod.StorerKey = @cStorerKey
                  AND wod.Type <> ''
                  AND wod.ExternLineNo = ''
                  AND ISNULL(pkd.CaseID, '') = @cDropID
                  AND ISNULL(wod.Remarks, '') <> ''

               --Print Special Labels
               SET @nLoopIndex = -1
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1 
                     @cVASCode = Type,
                     @cLabelName = UDF01,
                     @cCode2 = code2,
                     @nLoopIndex = id
                  FROM @tCustWorkOrderLabels
                     WHERE id > @nLoopIndex
                  ORDER BY id

                  IF @@ROWCOUNT = 0
                     BREAK

                  IF LEFT(@cLabelName, 3) = 'CTN'
                  BEGIN
                     DELETE FROM @tDefaultLabels WHERE (Code = @cVASCode OR code2 = @cCode2) AND LEFT(UDF01, 3) = 'CTN'
                     SET @nSpecialCartonLabelPrinted = 1
                  END
                  ELSE
                  BEGIN
                     DELETE FROM @tDefaultLabels WHERE (Code = @cVASCode OR code2 = @cCode2) AND LEFT(UDF01, 3) <> 'CTN'
                     SET @nSpecialVendorLabelPrinted = 1
                  END

                  -- Print label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                     @cLabelName, -- Report type
                     @tCartonLabelList, -- Report params
                     'rdt_855ExtUpd13',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
                     
                  IF @nErrNo <> 0
                  BEGIN
                     GOTO Quit
                  END
               END

               SELECT TOP 1 @cConsigneeKey = orm.ConsigneeKey,
                  @cBillToKey = orm.BillToKey,
                  @cOrderGroup = orm.OrderGroup
               FROM dbo.PickDetail pkd WITH(NOLOCK)
               INNER JOIN dbo.ORDERS orm WITH(NOLOCK) ON pkd.StorerKey = orm.StorerKey AND pkd.OrderKey = orm.OrderKey
               WHERE pkd.StorerKey = @cStorerKey
                  AND ISNULL(pkd.CaseID, '') = @cDropID

               --IF code2 equals to ConsigneeKey and BillToKey, only fetch data which code2 = @cConsigneeKey
               IF EXISTS (SELECT 1
                     FROM dbo.CODELKUP lk WITH(NOLOCK) 
                     INNER JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON lk.StorerKey = lk1.StorerKey AND lk.Code2 = ISNULL(lk1.Description, '') AND lk.Code = ISNULL(lk1.Long, '') 
                     WHERE lk.StorerKey = @cStorerKey
                        AND lk.LISTNAME = 'LVSCARTLBL' 
                        AND ISNULL(lk.Long, '') = ''
                        AND lk1.LISTNAME = 'LVSCUSPREF'
                        AND ISNULL(lk1.Description, '') <> @cOLPSDescription
                        AND lk1.code2 = @cConsigneeKey)
                  AND EXISTS (SELECT 1
                     FROM dbo.CODELKUP lk WITH(NOLOCK) 
                     INNER JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON lk.StorerKey = lk1.StorerKey AND lk.Code2 = ISNULL(lk1.Description, '') AND lk.Code = ISNULL(lk1.Long, '') 
                     WHERE lk.StorerKey = @cStorerKey
                        AND lk.LISTNAME = 'LVSCARTLBL' 
                        AND ISNULL(lk.Long, '') = ''
                        AND lk1.LISTNAME = 'LVSCUSPREF'
                        AND ISNULL(lk1.Description, '') <> @cOLPSDescription
                        AND lk1.code2 = @cBillToKey)
               BEGIN
                  DECLARE CUR_CARTONLABEL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT CustLabelData.Description, CustLabels.UDF01 AS CustLabelType, ISNULL(CustLabels.Short, '99999') AS CustSequence, CustLabelData.Long
                     FROM (SELECT StorerKey, Description, ISNULL(Long, '') AS Long FROM dbo.CODELKUP AS LK WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND LISTNAME = 'LVSCUSPREF'  AND code2 = @cConsigneeKey AND ISNULL(Description, '') <> @cOLPSDescription
                           AND NOT EXISTS (SELECT 1 FROM @tCustWorkOrderLabels AS CWOL WHERE CWOL.Type = LK.Long OR CWOL.code2 = LK.Description)) AS CustLabelData
                     LEFT JOIN (SELECT StorerKey, code2, Code, UDF01, Short FROM dbo.CODELKUP WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND LISTNAME = 'LVSCARTLBL'  AND ISNULL(Long, '') <> 'A'
                           ) AS CustLabels 
                        ON CustLabelData.StorerKey = CustLabels.StorerKey AND CustLabelData.Description = CustLabels.code2 AND CustLabelData.Long = CustLabels.Code
                     ORDER BY ISNULL(CustLabels.Short, '99999')
               END
               ELSE 
                  DECLARE CUR_CARTONLABEL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT CustLabelData.Description, CustLabels.UDF01 AS CustLabelType, ISNULL(CustLabels.Short, '99999') AS CustSequence, CustLabelData.Long
                     FROM (SELECT StorerKey, Description, ISNULL(Long, '') AS Long FROM dbo.CODELKUP LK WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND LISTNAME = 'LVSCUSPREF' AND ISNULL(Description, '') <> @cOLPSDescription AND (code2 = @cConsigneeKey OR code2 = @cBillToKey)
                           AND NOT EXISTS (SELECT 1 FROM @tCustWorkOrderLabels AS CWOL WHERE CWOL.Type = LK.Long OR CWOL.code2 = LK.Description)) AS CustLabelData
                     LEFT JOIN (SELECT StorerKey, code2, Code, UDF01, Short FROM dbo.CODELKUP WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND LISTNAME = 'LVSCARTLBL'  AND ISNULL(Long, '') <> 'A'
                           ) AS CustLabels 
                        ON CustLabelData.StorerKey = CustLabels.StorerKey AND CustLabelData.Description = CustLabels.code2 AND CustLabelData.Long = CustLabels.Code
                     ORDER BY ISNULL(CustLabels.Short, '99999')

               OPEN CUR_CARTONLABEL 
               FETCH NEXT FROM CUR_CARTONLABEL INTO @cCustLabelDataDesc, @cCustLabelName, @cCustLblPrintSequence,@cCustomCode

               WHILE @@FETCH_STATUS = 0 
               BEGIN
                  IF @cCustLabelName IS NOT NULL AND TRIM(@cCustLabelName) <> ''
                     AND ( 
                           (@nSpecialCartonLabelPrinted = 0 AND LEFT(@cCustLabelName, 3) = 'CTN' )
                           OR 
                           (@nSpecialVendorLabelPrinted = 0 AND LEFT(@cCustLabelName, 3) <> 'CTN') 
                        )
                  BEGIN
                     DELETE FROM @tDefaultLabels WHERE code2 = @cCustLabelDataDesc
                     SET @cLabelName = @cCustLabelName
                     -- Print label
                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                        @cLabelName, -- Report type
                        @tCartonLabelList, -- Report params
                        'rdt_855ExtUpd13',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                     BEGIN
                        CLOSE CUR_CARTONLABEL 
                        DEALLOCATE CUR_CARTONLABEL 

                        GOTO Quit
                     END
                  END
                  ELSE IF @cCustomCode = 'UNO'
                  BEGIN
                     DELETE FROM @tDefaultLabels WHERE code2 = @cCustLabelDataDesc
                  END
                  FETCH NEXT FROM CUR_CARTONLABEL INTO @cCustLabelDataDesc, @cCustLabelName, @cCustLblPrintSequence,@cCustomCode
               END
               CLOSE CUR_CARTONLABEL 
               DEALLOCATE CUR_CARTONLABEL 

               --Print Default Labels
               SET @nLoopIndex = -1
               WHILE 1 = 1
               --AND @cOrderGroup = '10'
               BEGIN
                  SELECT TOP 1 
                     @cLabelName = UDF01,
                     @nLoopIndex = id
                  FROM @tDefaultLabels
                     WHERE id > @nLoopIndex
                  ORDER BY id

                  IF @@ROWCOUNT = 0
                     BREAK

                  -- Print label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                     @cLabelName, -- Report type
                     @tCartonLabelList, -- Report params
                     'rdt_855ExtUpd13',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
                     
                  IF @nErrNo <> 0
                  BEGIN
                     GOTO Quit
                  END
               END
            END
         END
      END
      ELSE IF @nStep = 99  --Extended Screen
      BEGIN
         IF @nScn = 6384
         BEGIN
            IF @nInputKey = 1 -- Press Enter
            BEGIN
               -- If short confirmed
               --1. Mark PPAR as 2 (Short)
               --2. Print QC label
               IF @cOption = '1' -- 1. Confirm Short,  9. No short, go bakc to Screen 3
               BEGIN
                  UPDATE RDT.RDTPPA WITH(ROWLOCK)
                  SET Status = '2' --Short
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cDropID
                     AND Sku = @cSKU

                  --Print QC label
                  SELECT @cLabelName = RDT.RDTGetConfig(@nFunc, 'LVSQALABEL', @cStorerkey)
                  IF @cLabelName = '0'
                     SET @cLabelName = ''

                  IF @cLabelName <> ''
                  BEGIN
                     SELECT @cPickSlipNo = PickSlipNo
                     FROM dbo.PackDetail WITH(NOLOCK) 
                     WHERE StorerKey = @cStorerKey 
                        AND labelno = @cDropID
                        
                     DECLARE @tCQCLabelList VariableTable
                     -- Common params
                     INSERT INTO @tCQCLabelList (Variable, Value) 
                     VALUES 
                        ( '@cPickSlipNo', @cPickSlipNo),
                        ( '@cLabelNo', @cDropID)

                     -- Print label
                     EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                        @cLabelName, -- Report type
                        @tCQCLabelList, -- Report params
                        'rdt_855ExtUpd13',
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT
         
                     IF @nErrNo <> 0
                     BEGIN
                        GOTO Quit
                     END
                  END
               END
            END
         END
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

GRANT EXECUTE ON rdt.rdt_855ExtUpd13 TO NSQL
GO
