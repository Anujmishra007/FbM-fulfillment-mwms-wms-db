
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_838PntShipLbl04                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2024-07-05 1.0  JACKC      FCR-392 Print Carton labels                     */
/* 2024-07-22 1.1  JACKC      FCR-392 Change printing logic per v1.4 FBR      */
/* 2024-07-25 1.2  JACKC      FCR-392 Fix the issue found in FCR-386           */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838PntShipLbl04 (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cFromDropID      NVARCHAR( 20),
   @nCartonNo        INT,
   @cLabelNo         NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cUCCNo           NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            NVARCHAR( 10),
   @cWeight          NVARCHAR( 10),
   @cRefNo           NVARCHAR( 20),
   @cSerialNo        NVARCHAR( 30),
   @nSerialQTY       INT,
   @cOption          NVARCHAR( 1),
   @cPackDtlRefNo    NVARCHAR( 20), 
   @cPackDtlRefNo2   NVARCHAR( 20), 
   @cPackDtlUPC      NVARCHAR( 30), 
   @cPackDtlDropID   NVARCHAR( 20), 
   @cPackData1       NVARCHAR( 30), 
   @cPackData2       NVARCHAR( 30), 
   @cPackData3       NVARCHAR( 30), 
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nStep = 5 -- Print label
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         IF @cOption = 1 -- Yes
         BEGIN
            DECLARE  
                     @cLabelName          NVARCHAR( 10),
                     @cOrderKey           NVARCHAR( 10),
                     @cConsigneeKey       NVARCHAR( 15),
                     @cBillToKey          NVARCHAR( 15),
                     @cPrintSequence      NVARCHAR( 10),
                     @cLabelStyle         NVARCHAR( 30),
                     @cListName           NVARCHAR( 10),
                     @cCustLabelName      NVARCHAR( 30),
                     @cDefaultLabelName   NVARCHAR( 30)

            DECLARE @cLabelPrinter     NVARCHAR( 10)
            DECLARE @cPaperPrinter     NVARCHAR( 10)
            DECLARE @cPrinterGroup     NVARCHAR( 10)
            DECLARE @bDebugFlag        BINARY = 0
            DECLARE @tMultiLbl AS VariableTable

            -- Get session info
            SELECT 
               @cLabelPrinter = Printer,
               @cPaperPrinter = Printer_Paper
            FROM rdt.rdtMobRec WITH (NOLOCK)
            WHERE Mobile = @nMobile

            -- Get Order key
            SELECT 
               @cOrderKey = pkd.OrderKey
            FROM PickDetail pkd WITH (NOLOCK) 
            WHERE pkd.Storerkey = @cStorerKey AND pkd.CaseID = @cLabelNo

            -- Common params
            INSERT INTO @tMultiLbl (Variable, Value) VALUES
            ( '@cStorerKey',     @cStorerKey),
            ( '@cPickSlipNo',    @cPickSlipNo),
            ( '@cOrderKey',      @cOrderKey),
            ( '@cLabelNo',       @cLabelNo)

            IF @bDebugFlag = 1
            BEGIN
               SELECT 'PrtinerGroup', @cPrinterGroup
               SELECT 'Params Table'
               SELECT * FROM @tMultiLbl
            END

            DECLARE @tCartonLabelInfo TABLE
               (
                  id    INT IDENTITY(1,1),
                  OrderKey          NVARCHAR(10),
                  ConsigneeKey      NVARCHAR(15),
                  BillToKey         NVARCHAR(15),
                  DefaultLabel      NVARCHAR(10),
                  PrintSequence     NVARCHAR(10)
               )

            DECLARE @tDefaultLabels TABLE
            (
               StorerKey   NVARCHAR(10),
               ListName	   NVARCHAR(10),
               Code        NVARCHAR(30),
               Short	      NVARCHAR(10),
               UDF01	      NVARCHAR(60),
               code2	      NVARCHAR(30)
            )  

            SELECT TOP 1 @cConsigneeKey = orm.ConsigneeKey,
                  @cBillToKey = orm.BillToKey
            FROM dbo.PickDetail pkd WITH(NOLOCK)
               INNER JOIN dbo.ORDERS orm WITH(NOLOCK) ON pkd.StorerKey = orm.StorerKey AND pkd.OrderKey = orm.OrderKey
            WHERE pkd.StorerKey = @cStorerKey
               AND ISNULL(pkd.CaseID, '') = @cLabelNo

            INSERT INTO @tDefaultLabels (StorerKey, ListName, Code, Short, UDF01, code2)
               SELECT DISTINCT StorerKey, ListName, Code, ISNULL(Short, '99999'), UDF01, code2 
               FROM dbo.CODELKUP lk WITH(NOLOCK) 
               WHERE StorerKey = @cStorerKey
                  AND lk.LISTNAME = 'LVSCARTLBL' 
                  AND ISNULL(lk.Long, '') = 'A'
               ORDER BY ISNULL(Short, '99999')
            
            IF @bDebugFlag = 1
            BEGIN
               SELECT 'Default Label List'
               SELECT * FROM @tDefaultLabels
            END

            --IF code2 equals to ConsigneeKey and BillToKey, only fetch data which code2 = @cConsigneeKey
            IF EXISTS (SELECT 1
                     FROM dbo.CODELKUP lk WITH(NOLOCK) 
                     INNER JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON lk.StorerKey = lk1.StorerKey AND lk.Code2 = ISNULL(lk1.Description, '') AND lk.Code = ISNULL(lk1.Long, '') 
                     WHERE lk.StorerKey = @cStorerKey
                        AND lk.LISTNAME = 'LVSCARTLBL' 
                        AND ISNULL(lk.Long, '') = ''
                        AND lk1.LISTNAME = 'LVSCUSPREF'
                        AND lk1.code2 = @cConsigneeKey)
                  AND EXISTS (SELECT 1
                     FROM dbo.CODELKUP lk WITH(NOLOCK) 
                     INNER JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON lk.StorerKey = lk1.StorerKey AND lk.Code2 = ISNULL(lk1.Description, '') AND lk.Code = ISNULL(lk1.Long, '') 
                     WHERE lk.StorerKey = @cStorerKey
                        AND lk.LISTNAME = 'LVSCARTLBL' 
                        AND ISNULL(lk.Long, '') = ''
                        AND lk1.LISTNAME = 'LVSCUSPREF'
                        AND lk1.code2 = @cBillToKey)
            BEGIN
               DECLARE CUR_CARTONLABEL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT DISTINCT dftLabels.code2, lk1.ListName, lk.UDF01, dftLabels.UDF01, ISNULL(dftLabels.Short, '99999')
                  FROM @tDefaultLabels dftLabels
                  LEFT JOIN dbo.CODELKUP lk WITH(NOLOCK) ON dftLabels.StorerKey = lk.StorerKey AND dftLabels.ListName = lk.ListName AND dftLabels.code2 = lk.code2 AND ISNULL(lk.Long, '') <> 'A'
                  LEFT JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON dftLabels.StorerKey = lk1.StorerKey AND dftLabels.code2 = ISNULL(lk1.Description, '')
                     AND ISNULL(lk1.Long, '') = lk.Code     
                     AND lk1.LISTNAME = 'LVSCUSPREF' 
                     AND lk1.code2 = @cConsigneeKey
                  WHERE dftLabels.StorerKey = @cStorerKey
                     AND dftLabels.LISTNAME = 'LVSCARTLBL' 
                  ORDER BY ISNULL(dftLabels.Short, '99999'), dftLabels.code2
            END
            ELSE -- end if
            BEGIN 
               DECLARE CUR_CARTONLABEL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
                  SELECT DISTINCT dftLabels.code2, lk1.ListName, lk.UDF01, dftLabels.UDF01, ISNULL(dftLabels.Short, '99999')
                  FROM @tDefaultLabels dftLabels
                  LEFT JOIN dbo.CODELKUP lk WITH(NOLOCK) ON dftLabels.StorerKey = lk.StorerKey AND dftLabels.ListName = lk.ListName AND dftLabels.code2 = lk.code2 AND ISNULL(lk.Long, '') <> 'A'
                  LEFT JOIN dbo.CODELKUP lk1 WITH(NOLOCK) ON dftLabels.StorerKey = lk1.StorerKey AND dftLabels.code2 = ISNULL(lk1.Description, '')
                     AND ISNULL(lk1.Long, '') = lk.Code     
                     AND lk1.LISTNAME = 'LVSCUSPREF' 
                     AND (lk1.code2 = @cConsigneeKey OR lk1.code2 = @cBillToKey)
                  WHERE dftLabels.StorerKey = @cStorerKey
                     AND dftLabels.LISTNAME = 'LVSCARTLBL' 
                  ORDER BY ISNULL(dftLabels.Short, '99999'), dftLabels.code2
            END -- end else
            
            --Print Customized Labels
            OPEN CUR_CARTONLABEL 
            FETCH NEXT FROM CUR_CARTONLABEL INTO @cLabelStyle, @cListName, @cCustLabelName, @cDefaultLabelName, @cPrintSequence

            WHILE @@FETCH_STATUS = 0
            BEGIN
               IF @bDebugFlag = 1
                  SELECT 'Label cursor record', @cLabelStyle AS LabelStyle, @cListName AS ListName, 
                           @cCustLabelName AS CustomizedLabelName, @cDefaultLabelName AS DefaultLabelName, @cPrintSequence AS PrintSequence

               SET @cLabelName = IIF( @cListName IS NULL OR TRIM(@cListName) = '', @cDefaultLabelName, @cCustLabelName)

               IF @bDebugFlag = 1
                  SELECT 'Print Label:', @cLabelName, @cPrintSequence

               -- Print label
               EXEC RDT.rdt_Print 
                  @nMobile, 
                  @nFunc, 
                  @cLangCode, 
                  @nStep, 
                  @nInputKey, 
                  @cFacility, 
                  @cStorerKey, 
                  @cLabelPrinter, 
                  @cPaperPrinter,
                  @cLabelName, -- Report type
                  @tMultiLbl, -- Report params
                  'rdt_838PntShipLbl04',
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT

               IF @nErrNo <> 0
               BEGIN
                  CLOSE CUR_CARTONLABEL 
                  DEALLOCATE CUR_CARTONLABEL
                  GOTO Quit
               END

               FETCH NEXT FROM CUR_CARTONLABEL INTO @cLabelStyle, @cListName, @cCustLabelName, @cDefaultLabelName, @cPrintSequence
            END -- End Cursor
            CLOSE CUR_CARTONLABEL 
            DEALLOCATE CUR_CARTONLABEL

         END -- option 1
      END -- input key 1
   END

   GOTO Quit 
 
   
   Quit:  
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838PntShipLbl04 TO NSQL
GO
