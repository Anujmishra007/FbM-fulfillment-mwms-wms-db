
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_838PntShipLbl04                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2024-07-05 1.0  JACKC      FCR-392 Print Carton labels                        */
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
            DECLARE  @curLabel         CURSOR,
                     @cLabelName       NVARCHAR( 10),
                     @cLblSKU          NVARCHAR( 20),
                     @cLblVASCode      NVARCHAR( 12),
                     @bSuccess         INT,
                     @cTransmitLogKey  NVARCHAR( 10),
                     @c_QCmdClass      NVARCHAR( 10)   = '',
                     @b_Debug          INT = 0,
                     @cCartonLabel     NVARCHAR( 20),
                     @cOrderKey        NVARCHAR( 10)
            DECLARE @cLabelPrinter     NVARCHAR( 10)
            DECLARE @cPaperPrinter     NVARCHAR( 10)
            DECLARE @cPrinterGroup     NVARCHAR( 10)
            --DECLARE @nTranCount        INT
            DECLARE @tMultiLbl AS VariableTable

            -- Get session info
            SELECT 
               @cPrinterGroup = Printer
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

            SET @curLabel = Cursor LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT UDF01   
               FROM CODELKUP CL WITH (NOLOCK)  
               WHERE CL.ListName = 'LVSCARTLBL'
               AND   CL.Storerkey= @cStorerKey
               ORDER BY code

            OPEN @curLabel 
            FETCH NEXT FROM @curLabel INTO @cCartonLabel
            WHILE @@FETCH_STATUS = 0
            BEGIN
               SELECT @cLabelPrinter = PrinterID 
               FROM rdt.rdtReportToPrinter WITH (NOLOCK)
               WHERE Function_ID = @nFunc AND StorerKey = @cStorerKey
               AND PrinterGroup = @cPrinterGroup AND ReportType = @cCartonLabel

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
                  @cCartonLabel, -- Report type
                  @tMultiLbl, -- Report params
                  'rdt_838PntShipLbl04',
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Quit

               FETCH NEXT FROM @curLabel INTO @cCartonLabel
            END -- End Cursor
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
