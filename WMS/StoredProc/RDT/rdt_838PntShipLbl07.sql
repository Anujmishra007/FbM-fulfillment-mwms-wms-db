
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_838PntShipLbl07                                   */
/* Copyright      : Maersk                                                 */
/* Customer       : AEOMX                                                  */
/*                                                                         */
/*                                                                         */
/* Date        Rev    Author     Purposes                                  */
/* 2026-07-07  1.0.0  JackC      FCR-12984 Created                          */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838PntShipLbl07] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR(  3),
   @nStep           INT,
   @nInputKey       INT,
   @cFacility       NVARCHAR(  5),
   @cStorerKey      NVARCHAR( 15),
   @cPickSlipNo     NVARCHAR( 10),
   @cFromDropID     NVARCHAR( 20),
   @nCartonNo       INT,
   @cLabelNo        NVARCHAR( 20),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cUCCNo          NVARCHAR( 20),
   @cCartonType     NVARCHAR( 10),
   @cCube           NVARCHAR( 10),
   @cWeight         NVARCHAR( 10),
   @cRefNo          NVARCHAR( 20),
   @cSerialNo       NVARCHAR( 30),
   @nSerialQTY      INT,
   @cOption         NVARCHAR(  1),
   @cPackDtlRefNo   NVARCHAR( 20),
   @cPackDtlRefNo2  NVARCHAR( 20),
   @cPackDtlUPC     NVARCHAR( 30),
   @cPackDtlDropID  NVARCHAR( 20),
   @cPackData1      NVARCHAR( 30),
   @cPackData2      NVARCHAR( 30),
   @cPackData3      NVARCHAR( 30),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE
      @cWaveType     NVARCHAR( 20),
      @cLabelPrinter NVARCHAR( 20),
      @cPaperPrinter NVARCHAR( 20),
      @cReportType   NVARCHAR( 20),
      @nCounter      INT

   DECLARE @tReportList TABLE (
      RowNumber  INT IDENTITY(1,1) PRIMARY KEY,
      ReportType NVARCHAR( 20) NOT NULL
   )

   DECLARE @tReportParams AS VariableTable

   SET @nErrNo  = 0
   SET @cErrMsg = ''

   IF @nDebugFlag = 1
      SELECT 'rdt_838PntShipLbl07: Start',
         @cPickSlipNo AS PickSlipNo, @cFromDropID AS FromDropID,
         @nCartonNo AS CartonNo, @cLabelNo AS LabelNo,
         @cUCCNo AS UCCNo, @cCartonType AS CartonType, @cRefNo AS RefNo

   -- Get printer and WaveType from device session record
   SELECT
      @cWaveType     = C_String2,
      @cLabelPrinter = Printer,
      @cPaperPrinter = Printer_Paper
   FROM rdt.RDTMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Build report params (key-value pairs passed to rdt_Print)
   INSERT INTO @tReportParams (Variable, Value) VALUES
      ('@cStorerKey',     @cStorerKey),
      ('@cPickSlipNo',    @cPickSlipNo),
      ('@cFromDropID',    @cFromDropID),
      ('@cPackDtlDropID', @cFromDropID),
      ('@cLabelNo',       @cLabelNo),
      ('@nCartonNo',      ISNULL(TRY_CAST(@nCartonNo AS NVARCHAR(10)), '0'))

   -- Load all report types for this WaveType
   INSERT INTO @tReportList (ReportType)
   SELECT Code2
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE LISTNAME  = 'MULTILBL'
     AND Code      = @cWaveType
     AND StorerKey = @cStorerKey
   
   IF @nDebugFlag = 1
      SELECT 'Report List', * FROM @tReportList

   -- Print each report type; on failure queue and continue
   SET @nCounter = 0
   WHILE 1 = 1
   BEGIN
      SELECT TOP 1
         @nCounter    = RowNumber, 
         @cReportType = ReportType
      FROM @tReportList
      WHERE RowNumber > @nCounter
      ORDER BY RowNumber

      IF @@ROWCOUNT = 0
         BREAK

      IF @nDebugFlag = 1
         SELECT 'Print Report', @cReportType

      EXEC RDT.rdt_Print
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey,
         @cFacility, @cStorerKey,
         @cLabelPrinter, @cPaperPrinter,
         @cReportType,
         @tReportParams,
         'rdt_838PntShipLbl07',
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT

      IF @nErrNo <> 0
         EXEC rdt.rdtInsertMsgQueue @nMobile, 0, 'Print Label Failed', @cReportType, @cErrMsg, ''
   END

QUIT:
   IF @nDebugFlag = 1
      SELECT 'rdt_838PntShipLbl07 END', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

   --Clear ErrNo, ErrMsg to not stop processing
   SET @nErrNo  = 0
   SET @cErrMsg = ''

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838PntShipLbl07 TO nSQL
GO
