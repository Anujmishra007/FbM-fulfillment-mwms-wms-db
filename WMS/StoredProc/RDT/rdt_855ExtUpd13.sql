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
/* Date       Rev    Author   Purposes                                             */
/* 2024-06-18 1.0    NLT013   FCR-386. Created                                     */
/* 2024-08-06 1.1    Dennis   FCR-386. Remove order group condition                */
/* 2024-09-26 1.2    NLT013   UWP-24932 Error message UI issue                     */
/* 2024-09-30 1.3    NLT013   Fix printing special order labels issue              */
/* 2024-10-12 1.3.0  NLT013   FCR-955 PPA by LabelNo, instead of PickSLipNo        */
/* 2024-10-28 1.4.0  NLT013   FCR-1085 Automate print Order Level labels           */
/* 2024-11-27 1.4.1  NLT013   FCR-1085 Fix bug - print duplicate reports           */
/* 2024-12-03 1.5.0  NLT013   FCR-1659 Be able to print label for MPOC             */
/* 2024-12-03 1.6.0  NLT013   UWP-28680 Remove the transaction                     */
/* 2024-12-31 1.7.0  NLT013   UWP-28680 fix rollback transaction issue. The error  */
/*                            code should be visible if any error happens          */
/* 2024-11-15 1.8.0  LJQ006   FCR-1109. Insert transmitlog2 after PPA              */
/* 2025-01-08 1.9.0  NLT013   UWP-28888 The PackHeader's status is wrong           */
/* 2025-01-15 1.10.0 NLT013   UWP-29176 Performance Tune version 1                 */
/* 2025-01-15 1.10.1 NLT013   UWP-29176 Performance Tune version 2                 */
/* 2025-02-05 1.11.0 CYU027   FCR-2630 Add Option=5 in step 5                      */
/* 2025-02-11 1.12.0 Dennis   FCR-2630 Clear the dropid info to reuse              */
/* 2025-02-20 1.13.0 NLT013   UWP-30312 Performance Tune                           */
/* 2025-03-05 1.14.0 JCH507   FCR-3356 Change WSSortTotRel Transmitlog2 data       */
/* 2025-03-13 1.15.0 NLT013   Misupdate PickDetail as 5, because not check all     */
/*                            PickDetails are picked, some Packinfo was missing    */
/* 2025-03-22 1.15.1 NLT013   UWP-31481 Need check if all packdetail are generated */
/* 2025-04-08 1.15.2 Dennis   UWP-32495 FixBugs                                    */
/* 2025-04-29 1.16.0 NickT    UWP-33521 Carton weight is not corret for MPOC       */
/* 2025-04-29 1.16.2 NickT    UWP-33521 Carton weight is not corret for MPOC       */
/* 2025-07-22 1.17.0 Jackc    FCR-6705 Generate BOL sequence number                */
/* 2025-08-19 1.18.0 NickT    UWP-39586 Performance tuning                         */
/* 2025-09-16 1.19.0 NickT    UWP-41279 No need fire trigger when archive dropdid  */
/* 2025-08-27 1.19.0 Jackc    FCR-4159 if single unit order, archive dropid when   */
/*                              all sku packed (FCR-7348)                          */
/* 2025-09-17 1.20.0 NickT    FCR-7730 Add parameter @cSourceName                  */
/*                            for rdt_LevisPrintCartonLabel                        */
/* 2025-09-18 1.21.0 Jackc    FCR-7348 New dropid archiving logic (FBRv1.4)        */
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

      DECLARE @cSingleUnitOrdFlag NVARCHAR(1) --V1.19.0

   DECLARE @bDebugFlag   BINARY = 0 --1, print log; 2, insert traceinfo
   DECLARE @cToteID      NVARCHAR(20)
   DECLARE @cWaveKey     NVARCHAR(20),
   @cDropIDFlag          NVARCHAR(1)
   DECLARE @tWaveKeys    TABLE (
      WaveKey NVARCHAR(50)
   )
   DECLARE @nWaveKeyCount INT
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

   --V1.17.0 start
   DECLARE @tOrderNoRefID TABLE
   (
      RowNumber      INT IDENTITY(1,1),
      OrderKey       NVARCHAR(10),
      ConsigneeKey   NVARCHAR(15),
      WaveKey        NVARCHAR(10)
   )

   DECLARE @tRDTPPA TABLE
   (
      RowRef INT NOT NULL PRIMARY KEY
   )

   DECLARE @cONRIOrderKey     NVARCHAR(10)
   DECLARE @cONRIConsigneeKey NVARCHAR(15)
   DECLARE @cONRIWaveKey      NVARCHAR(10)
   DECLARE @cReferenceID      NVARCHAR(20)
   DECLARE @cOtherParams      NVARCHAR(MAX) = ''
   --V1.17.0 end

   SET @nErrNo = 0
   SET @cErrMsg = ''

   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   IF @cPickConfirmStatus NOT IN ( '3', '5')
      SET @cPickConfirmStatus = '5'

   SELECT @nScn = Scn,
      @cLabelPrinterGroup = Printer,
      @cPaperPrinter = Printer_Paper,
      @cDropIDFlag   = C_STRING1,
      @cSingleUnitOrdFlag = C_String2 --v1.19.0
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile
   
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
            UPDATE RP
            SET Status = '0',
               CQty = 0
            FROM RDT.RDTPPA RP WITH(ROWLOCK)
            INNER JOIN @tRDTPPA TRP ON RP.RowRef = TRP.RowRef
         END
      END
      ELSE IF @nStep = 3 -- SKU/UPC
      BEGIN
         IF @nInputKey = 1 -- Enter
         BEGIN
            DECLARE @tMsgQueue TABLE
            (
               id INT IDENTITY(1,1),
               Line01    NVARCHAR(125),
               Line02    NVARCHAR(125),
               Line03    NVARCHAR(125),
               Line04    NVARCHAR(125),
               Line05    NVARCHAR(125),
               Line06    NVARCHAR(125),
               Line07    NVARCHAR(125),
               Line08    NVARCHAR(125),
               Line09    NVARCHAR(125),
               Line10    NVARCHAR(125),
               Line11    NVARCHAR(125),
               Line12    NVARCHAR(125),
               Line13    NVARCHAR(125),
               Line14    NVARCHAR(125),
               Line15    NVARCHAR(125)
            )

            SELECT @nTotalPQty = SUM(PQty), @nTotalCQty = SUM(CQty)
            FROM RDT.RDTPPA WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND DropID = @cDropID
               AND Sku = @cSKU

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
                     AND PKD.CaseID = @cDropID
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
                           INSERT INTO @tMsgQueue
                           (
                              Line01,
                              Line02,
                              Line03,
                              Line04,
                              Line05,
                              Line06,
                              Line07,
                              Line08,
                              Line09,
                              Line10,
                              Line11,
                              Line12,
                              Line13,
                              Line14,
                              Line15)
                           VALUES(
                              @cMsg01,
                              @cMsg02,
                              @cMsg03,
                              @cMsg04,
                              @cMsg05,
                              @cMsg06,
                              @cMsg07,
                              @cMsg08,
                              @cMsg09,
                              '',
                              '',
                              '',
                              '',
                              '',
                              '')

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
                        INSERT INTO @tMsgQueue
                        (
                           Line01,
                           Line02,
                           Line03,
                           Line04,
                           Line05,
                           Line06,
                           Line07,
                           Line08,
                           Line09,
                           Line10,
                           Line11,
                           Line12,
                           Line13,
                           Line14,
                           Line15)
                        VALUES(
                           @cMsg01,
                           @cMsg02,
                           @cMsg03,
                           @cMsg04,
                           @cMsg05,
                           @cMsg06,
                           @cMsg07,
                           @cMsg08,
                           @cMsg09,
                           '',
                           '',
                           '',
                           '',
                           '',
                           '')

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
               INNER JOIN dbo.PackHeader ph WITH(NOLOCK) ON wo.StorerKey = ph.StorerKey AND wo.ExternWorkOrderKey = ph.OrderKey
               INNER JOIN dbo.PackDetail pd WITH(NOLOCK) ON ph.StorerKey = pd.StorerKey AND ph.PickSlipNo = pd.PickSlipNo
               INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON pd.StorerKey = pkd.StorerKey AND pd.labelno = pkd.CaseID AND wod.ExternWorkOrderKey = pkd.OrderKey AND wod.ExternLineNo = pkd.OrderLinenumber
               INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND lk.LISTNAME = 'WKORDTYPE'
               WHERE pkd.StorerKey = @cStorerKey
                  AND wo.ExternWorkOrderKey IS NOT NULL
                  AND wo.ExternWorkOrderKey <> ''
                  AND pkd.CaseID <> ''
                  AND pkd.CaseID = @cDropID
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
                     INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wo.StorerKey = pkd.StorerKey AND wod.ExternWorkOrderKey = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo
                     WHERE wo.StorerKey = @cStorerKey
                        AND pkd.Sku = @cSKU
                        AND wod.ExternWorkOrderKey IS NOT NULL
                        AND wod.ExternWorkOrderKey <> ''
                        AND pkd.CaseID <> ''
                        AND pkd.CaseID = @cDropID
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
                        INSERT INTO @tMsgQueue
                        (
                           Line01,
                           Line02,
                           Line03,
                           Line04,
                           Line05,
                           Line06,
                           Line07,
                           Line08,
                           Line09,
                           Line10,
                           Line11,
                           Line12,
                           Line13,
                           Line14,
                           Line15)
                        VALUES(
                           @cMsg01,
                           @cMsg02,
                           @cMsg03,
                           @cMsg04,
                           @cMsg05,
                           @cMsg06,
                           @cMsg07,
                           @cMsg08,
                           @cMsg09,
                           '',
                           '',
                           '',
                           '',
                           '',
                           '')

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
                     INSERT INTO @tMsgQueue
                     (
                        Line01,
                        Line02,
                        Line03,
                        Line04,
                        Line05,
                        Line06,
                        Line07,
                        Line08,
                        Line09,
                        Line10,
                        Line11,
                        Line12,
                        Line13,
                        Line14,
                        Line15)
                     VALUES(
                        @cMsg01,
                        @cMsg02,
                        @cMsg03,
                        @cMsg04,
                        @cMsg05,
                        @cMsg06,
                        @cMsg07,
                        @cMsg08,
                        @cMsg09,
                        '',
                        '',
                        '',
                        '',
                        '',
                        '')

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
                  DECLARE @tCODELKUP TABLE
                  (
                     LISTNAME             NVARCHAR(10),
                     StorerKey            NVARCHAR(15),
                     Code                 NVARCHAR(30),
                     Code2                NVARCHAR(30),
                     UDF01                NVARCHAR(60),
                     INDEX IDX_tCODELKUP CLUSTERED(StorerKey, Code)
                  )

                  INSERT INTO @tCODELKUP (LISTNAME, StorerKey, Code, Code2, UDF01)
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

                  INSERT INTO @tLabels(LabelListName, VASCode, LabelName, Qty, PrintSequence)
                  SELECT DISTINCT IIF(wodEX.LISTNAME IS NULL, lk.LISTNAME, wodEX.LISTNAME), wod.type, IIF(wodEX.UDF01 IS NULL, lk.UDF01, wodEX.UDF01), pkd.Qty, '00001'
                  FROM dbo.WorkOrderDetail wod  WITH(NOLOCK)
                  INNER JOIN dbo.WorkOrder wo WITH(NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
                  INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND lk.LISTNAME = 'WKORDTYPE' AND lk.UDF04 = 'LVSPRICELB'
                  INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wo.StorerKey = pkd.StorerKey AND wod.ExternWorkOrderKey = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo AND pkd.Status = @cPickConfirmStatus
                  LEFT JOIN @tCODELKUP AS wodEX
                     ON wod.StorerKey = wodEX.StorerKey AND lk.Code = wodEX.Code
                  WHERE wo.StorerKey = @cStorerKey
                     AND pkd.Sku = @cSKU
                     AND wod.ExternWorkOrderKey IS NOT NULL
                     AND wod.ExternWorkOrderKey <> ''
                     AND pkd.CaseID <> ''
                     AND pkd.CaseID = @cDropID
                     AND wod.ExternLineNo <> ''

                  DECLARE @tOrders TABLE
                  (
                     StorerKey      NVARCHAR(15),
                     OrderKey       NVARCHAR(10),
                     INDEX IDX_tOrders CLUSTERED(StorerKey, OrderKey)
                  )

                  INSERT INTO @tOrders (StorerKey, OrderKey)
                  SELECT DISTINCT StorerKey, OrderKey
                  FROM dbo.PickDetail WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND CaseID <> ''
                     AND CaseID = @cDropID

                  DECLARE @tWorkOrderDetails TABLE
                  (
                     StorerKey            NVARCHAR(15),
                     WorkOrderKey         NVARCHAR(10),
                     ExternWorkOrderKey   NVARCHAR(20),
                     ExternLineNo         NVARCHAR(5),
                     WorkOrderLineNumber  NVARCHAR(5),
                     Type                 NVARCHAR(12)
                  )

                  INSERT INTO @tWorkOrderDetails (StorerKey, WorkOrderKey, ExternWorkOrderKey, ExternLineNo, WorkOrderLineNumber, Type)
                  SELECT StorerKey, WorkOrderKey, ExternWorkOrderKey, ExternLineNo, WorkOrderLineNumber, Type
                  FROM
                     (SELECT 
                        wod1.StorerKey, wod1.WorkOrderKey, wod1.ExternWorkOrderKey, wod1.ExternLineNo, wod1.WorkOrderLineNumber, wod1.Type, 
                        ROW_NUMBER()OVER(PARTITION BY WorkOrderKey, ExternWorkOrderKey, ExternLineNo ORDER BY ExternWorkOrderKey, ExternLineNo) AS ROW#
                        FROM dbo.WorkOrderDetail wod1 WITH(NOLOCK)
                        INNER JOIN @tOrders AS pkd1
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
                     FROM @tWorkOrderDetails AS wod
                     INNER JOIN dbo.WorkOrder wo WITH(NOLOCK) ON wo.WorkOrderKey = wod.WorkOrderKey
                     INNER JOIN dbo.ORDERS orm WITH(NOLOCK) ON wod.StorerKey = orm.StorerKey AND wod.ExternWorkOrderKey = orm.OrderKey
                     INNER JOIN dbo.CODELKUP lk WITH(NOLOCK) ON wo.StorerKey = lk.StorerKey AND wod.Type = lk.Code AND lk.LISTNAME = 'WKORDTYPE' AND lk.UDF04 = 'LVSCatalog' 
                     INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wo.StorerKey = pkd.StorerKey AND wod.ExternWorkOrderKey = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo AND pkd.Status = @cPickConfirmStatus
                     INNER JOIN dbo.PackDetail pakd WITH(NOLOCK) ON pkd.StorerKey = pakd.StorerKey AND pkd.CaseID = pakd.LabelNo AND pakd.SKU = pkd.SKU
                     LEFT JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON lk.StorerKey = lk1.StorerKey AND lk.Code = lk1.Code AND lk.UDF04 = lk1.LISTNAME AND lk1.Code2 <> ''
                        AND (orm.ConsigneeKey = lk1.Code2 OR  MarkforKey = lk1.Code2 OR BillToKey = lk1.Code2)
                     WHERE wo.StorerKey = @cStorerKey
                        AND pkd.Sku = @cSKU
                        AND wod.ExternWorkOrderKey IS NOT NULL
                        AND wod.ExternWorkOrderKey <> ''
                        AND pkd.CaseID <> ''
                        AND pkd.CaseID = @cDropID
                     ORDER BY lk.Code ASC
                  END
               END

               SELECT @nTotalCQty = SUM(CQty)
               FROM RDT.RDTPPA WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cDropID

               SELECT @nTotalPQty = SUM(Qty)
               FROM dbo.PickDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND CaseID <> ''
                  AND CaseID = @cDropID
                  AND Status NOT IN ('4', '9')

               DECLARE @cOrderGroup NVARCHAR(20) = ''

               SELECT TOP 1 @cOrderGroup = orm.OrderGroup,
                  @cShipperKey = ISNULL(ShipperKey, '')
               FROM dbo.PICKDETAIL pkd WITH(NOLOCK)
               INNER JOIN dbo.ORDERS orm WITH(NOLOCK) ON pkd.StorerKey = orm.StorerKey AND pkd.OrderKey = orm.OrderKey
               WHERE pkd.StorerKey = @cStorerKey
                  AND pkd.CaseID <> ''
                  AND pkd.CaseID = @cDropID
               ORDER BY orm.OrderKey

               BEGIN TRY
                  --Mark PPA as 5 (audit finished)
                  DELETE FROM @tRDTPPA

                  INSERT INTO @tRDTPPA (RowRef)
                  SELECT DISTINCT RowRef
                  FROM RDT.RDTPPA WITH(NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cDropID
                     AND Sku = @cSKU
                  SELECT @nRowCount = @@ROWCOUNT

                  IF @nRowCount > 0
                  BEGIN
                     UPDATE RP
                     SET Status = '5'
                     FROM RDT.RDTPPA RP WITH(ROWLOCK)
                     INNER JOIN @tRDTPPA TRP ON RP.RowRef = TRP.RowRef
                  END

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
                     WHERE
                        RefNo IS NOT NULL
                        AND RefNo = @cDropID

                     --Calculate carton weight
                     DECLARE @tCartonWeight TABLE
                     (
                        CaseID            NVARCHAR(30),
                        PickSlipNo        NVARCHAR(10),
                        CartonNo          INT,
                        Weight            FLOAT
                     )

                     DECLARE @nPickSlipNoQty    INT = 1
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

                     --Print PackSlipNo report once an order is finished
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

                           INSERT INTO @tMPOCLabels (LabelName, OrderKey)
                           VALUES('LVSPSORD', @cOrderKey)
                        END
                     END

                     --Mark PackHeader as 9
                     DECLARE @tPickSlipNoList TABLE
                     (
                        id INT IDENTITY(1,1),
                        PickSlipNo        NVARCHAR(10)
                     )

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

                        --Meet below conditions, mark PackHeader as 9
                        --1. all packinfo marked as 'PACKED'
                        --2. all PickDetails are finished
                        --3. Count(PickDetail.CaseID) = Count(PackDetail.LabelNo)
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

                     IF TRIM(@cShipperKey) <> ''
                        AND EXISTS(SELECT 1 FROM CODELKUP WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND LISTNAME = 'WSCourier' AND @cShipperKey = ISNULL(notes,'-1'))
                     BEGIN
                        --V1.17 start
                        -- Get all order key without orderinfo.ReferenceNo value in the paperboard box
                        INSERT INTO @tOrderNoRefID (OrderKey, ConsigneeKey, WaveKey)
                           SELECT DISTINCT ORM.OrderKey, ORM.ConsigneeKey, ORM.UserDefine09 
                           FROM dbo.PICKDETAIL PD WITH(NOLOCK)
                           JOIN dbo.ORDERS ORM WITH(NOLOCK) ON PD.OrderKey = orm.OrderKey
                           JOIN dbo.OrderInfo OI WITH(NOLOCK) ON ORM.OrderKey = oi.OrderKey
                           WHERE PD.CaseID = @cDropID
                              AND PD.CaseID <> ''
                              AND PD.StorerKey = @cStorerKey
                              AND PD.Status NOT IN ('4', '9')
                              AND (OI.ReferenceId IS NULL OR OI.ReferenceId = '')
                        
                        IF @bDebugFlag = 1
                        BEGIN
                           SELECT 'Order without ReferenceID', @cDropID AS DropID
                           SELECT * FROM @tOrderNoRefID
                        END

                        IF EXISTS (SELECT 1 FROM @tOrderNoRefID)
                        BEGIN
                           SET @nLoopIndex = -1
                           WHILE 1 = 1
                           BEGIN
                              SELECT TOP 1
                                 @cONRIOrderKey = OrderKey,
                                 @cONRIConsigneeKey = ConsigneeKey,
                                 @cONRIWaveKey = WaveKey,
                                 @nLoopIndex = RowNumber
                              FROM @tOrderNoRefID
                              WHERE RowNumber > @nLoopIndex
                              ORDER BY RowNumber

                              SET @nRowCount = @@ROWCOUNT

                              IF @nRowCount = 0
                                 BREAK

                              SET @cReferenceID = ''

                              --Call BOL running number generator
                              
                              EXEC	[dbo].[msp_GetBOLbyConsigneeKey]
                                 @c_Wavekey  = @cONRIWaveKey,
                                 @c_Orderkey = @cONRIOrderKey,
                                 @c_Consigneekey = @cONRIConsigneeKey,
                                 @c_BOLByConsigneekey = @cReferenceID OUTPUT,
                                 @c_OtherParams = @cOtherParams OUTPUT,
                                 @b_Success = @bSuccess OUTPUT,
                                 @n_Err = @nErrNo OUTPUT,
                                 @c_ErrMsg = @cErrMsg OUTPUT

                              IF @bSuccess <> 1 OR @nErrNo <> 0
                              BEGIN
                                 SET @nErrNo = 217807
                                 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenReferenceIDFail
                                 GOTO Quit
                              END

                              IF @bDebugFlag = 1
                                 SELECT 'Generating ReferenceID for OrderKey', @nLoopIndex AS RowNumber, 
                                          @cONRIOrderKey AS Orderkey, @cONRIConsigneeKey AS Consigneekey, 
                                          @cONRIWaveKey AS WaveKey, @cReferenceID AS ReferenceID 

                              BEGIN TRY
                                 UPDATE dbo.OrderInfo WITH(ROWLOCK)
                                 SET ReferenceId = @cReferenceID
                                 WHERE OrderKey = @cONRIOrderKey
                              END TRY
                              BEGIN CATCH
                                 SET @nErrNo = 217808
                                 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update OrderInfo fail
                                 GOTO Quit
                              END CATCH
                           END-- loop generating reference id end
                        END -- OrderNoRefID exists end
                        --V1.17 end

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

               END TRY
               BEGIN CATCH
                  IF @nErrNo = 0
                  BEGIN
                     SET @nErrNo = 217803
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --HandlePPAFail
                  END

                  GOTO Quit
               END CATCH

               --Display VAS code
               SET @nLoopIndex = -1
               WHILE 1=1
               BEGIN
                  SELECT TOP 1
                     @cMsg01 = Line01,
                     @cMsg02 = Line02,
                     @cMsg03 = Line03,
                     @cMsg04 = Line04,
                     @cMsg05 = Line05,
                     @cMsg06 = Line06,
                     @cMsg07 = Line07,
                     @cMsg08 = Line08,
                     @cMsg09 = Line09,
                     @nLoopIndex = id
                  FROM @tMsgQueue
                  WHERE id > @nLoopIndex
                  ORDER BY id

                  IF @@ROWCOUNT = 0
                     BREAK

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
               END

               --Print VAS Labels
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

               --Print MPOC label
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
                  DELETE FROM @tRDTPPA

                  INSERT INTO @tRDTPPA (RowRef)
                  SELECT DISTINCT RowRef
                  FROM RDT.RDTPPA WITH(NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cDropID
                     AND Sku = @cSKU
                  SELECT @nRowCount = @@ROWCOUNT

                  IF @nRowCount > 0
                  BEGIN
                     UPDATE RP
                     SET Status = '2' --Short
                     FROM RDT.RDTPPA RP WITH(ROWLOCK)
                     INNER JOIN @tRDTPPA TRP ON RP.RowRef = TRP.RowRef
                  END

                  --Print QC label
                  SELECT @cLabelName = RDT.RDTGetConfig(@nFunc, 'LVSQALABEL', @cStorerkey)
                  IF @cLabelName = '0'
                     SET @cLabelName = ''

                  IF @cLabelName <> ''
                  BEGIN
                     DECLARE @tCQCLabelList VariableTable
                     -- Common params
                     INSERT INTO @tCQCLabelList (Variable, Value) 
                     VALUES 
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
         IF @nScn = 6464 --Print Pack List
         BEGIN
            IF @nInputKey = 1
            BEGIN
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
                     ,'rdt_855ExtUpd13'

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
                  AND NOT EXISTS(
                     SELECT 1 FROM dbo.codelkup cl WITH(NOLOCK)
                        INNER JOIN dbo.ORDERS ord WITH(NOLOCK) ON ord.ShipperKey = cl.short
                        INNER JOIN dbo.PickDetail pd WITH(NOLOCK) ON ord.OrderKey = pd.OrderKey
                     WHERE ord.StorerKey = @cStorerKey
                       AND pd.StorerKey = @cStorerKey
                       AND pd.CaseID = @cDropID
                       AND cl.listname = 'WSCourier'
                       and cl.code = 'ECL-1' )
                  BEGIN
                     --print 4X2 label
                     DECLARE @t4x2ParamList VariableTable
                     INSERT INTO @t4x2ParamList (Variable, Value)
                     VALUES
                        ( '@cSSCC', @cDropID)

                     EXEC rdt.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinterGroup, @cPaperPrinter,
                          'GNSSCCLBL', -- Report type
                          @t4x2ParamList, -- Report params
                          'rdt_855ExtUpd13',
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
                     ,'rdt_855ExtUpd13'

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
                    AND pd.CaseID = @cDropID;

                  SELECT @nWaveKeyCount = COUNT(*) FROM @tWaveKeys;

                  -- add record into transmitlog2
                  --BEGIN TRAN  --1.21.0
                  --SAVE TRAN rdt_855TransLog2 --1.21.0

                  WHILE @nWaveKeyCount > 0
                  BEGIN
                     SELECT TOP 1 @cWaveKey = WaveKey FROM @tWaveKeys
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

                     UPDATE PD
                        SET DropID = CONCAT('ARC',DropID)
                     FROM dbo.PackDetail PD WITH(ROWLOCK)
                     INNER JOIN @tPackDetail TPD 
                     ON PD.PickSlipNo = TPD.PickSlipNo
                        AND PD.CartonNo = TPD.CartonNo
                        AND PD.LabelNo = TPD.LabelNo
                        AND PD.LabelLine = TPD.LabelLine

                     DELETE FROM @tPickDetail

                     INSERT INTO @tPickDetail (PickDetailKey)
                     SELECT PickDetailKey
                     FROM dbo.PICKDETAIL WITH(NOLOCK) 
                     WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID

                     UPDATE PD
                        SET DropID = CONCAT('ARC',DropID),
                        TrafficCop = NULL
                     FROM dbo.PICKDETAIL PD WITH(ROWLOCK)
                     INNER JOIN @tPickDetail TPD 
                     ON PD.PickDetailKey = TPD.PickDetailKey

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

                  UPDATE PD
                     SET DropID = CONCAT('ARC',DropID)
                  FROM dbo.PackDetail PD WITH(ROWLOCK)
                  INNER JOIN @tPackDetail TPD 
                  ON PD.PickSlipNo = TPD.PickSlipNo
                     AND PD.CartonNo = TPD.CartonNo
                     AND PD.LabelNo = TPD.LabelNo
                     AND PD.LabelLine = TPD.LabelLine

                  DELETE FROM @tPickDetail

                  INSERT INTO @tPickDetail (PickDetailKey)
                  SELECT PickDetailKey
                  FROM dbo.PICKDETAIL WITH(NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                     AND DropID = @cToteID

                  UPDATE PD
                     SET DropID = CONCAT('ARC',DropID),
                     TrafficCop = NULL
                  FROM dbo.PICKDETAIL PD WITH(ROWLOCK)
                  INNER JOIN @tPickDetail TPD 
                  ON PD.PickDetailKey = TPD.PickDetailKey

                  --UPDATE dbo.PackDetail WITH(ROWLOCK) SET DropID = CONCAT('ARC',DropID) WHERE DropID=@cToteID
                  --UPDATE dbo.PICKDETAIL WITH(ROWLOCK) SET DropID = CONCAT('ARC',DropID) WHERE DropID=@cToteID
                  UPDATE RDT.RDTMOBREC WITH(ROWLOCK) SET C_STRING1 = '' WHERE Mobile = @nMobile
               END

               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
               --V1.21.0 end
            END --scn6464, enter
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
