if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_593Print34]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_593Print34]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_593Print34                                      */
/* Copyright      : LF                                                  */
/*                                                                      */
/* Purpose: Print PDF                                                   */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2021-08-11  1.0  James    WMS-17661. Created                         */
/* 2021-11-03  1.1  LZG      JSM-30383 - Order by descending (ZG01)     */
/* 2022-01-25  1.2  AwYoung  JSM-48088 - Get Latest Label only (AAY001) */
/************************************************************************/

CREATE PROC [RDT].[rdt_593Print34] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 2),
   @cParam1    NVARCHAR(20),  -- StorerKey
   @cParam2    NVARCHAR(20),  -- OrderKey
   @cParam3    NVARCHAR(20),
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLabelPrinter     NVARCHAR( 10)
   DECLARE @cPaperPrinter     NVARCHAR( 10)
   DECLARE @cLabelNo          NVARCHAR( 20)
   DECLARE @cPickSlipNo       NVARCHAR( 10)
   DECLARE @cFacility         NVARCHAR( 5)
   DECLARE @cShipLabel        NVARCHAR( 10)
   DECLARE @nInputKey         INT
   DECLARE @cWinPrinter       NVARCHAR(128)
   DECLARE @cPrinterName      NVARCHAR(100)
   DECLARE @cWinPrinterName   NVARCHAR(100)
   DECLARE @cLabelNo2Print    NVARCHAR(100)
   DECLARE @cFileName         NVARCHAR( 50)
   DECLARE @cFilePath         NVARCHAR(100)
   DECLARE @cOrderKey         NVARCHAR( 10)
   DECLARE @cPrintFilePath    NVARCHAR(100)
   DECLARE @cPrintCommand     NVARCHAR(MAX)
   DECLARE @cReportType       NVARCHAR( 10)
   DECLARE @cFilePrefix       NVARCHAR( 30)

   -- Check orderkey
   IF ISNULL( @cParam1, '') = ''
   BEGIN
      SET @nErrNo = 173201
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need CartonID
      GOTO Quit
   END

   SELECT TOP 1 @cLabelNo = LabelNo
   FROM dbo.PackDetail WITH (NOLOCK)
   WHERE DropID = @cParam1
   ORDER BY 1 DESC   -- ZG01

   IF ISNULL( @cLabelNo, '') = ''
   BEGIN
      SET @nErrNo = 173202
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inv cartonID
      GOTO Quit
   END

   SELECT @cLabelPrinter = Printer,
          @cPaperPrinter = Printer_Paper,
          @cFacility = Facility,
          @nInputKey = InputKey
   FROM rdt.rdtMobrec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @cOption = '1'
   BEGIN
      DECLARE @tShipLabel AS VariableTable
      INSERT INTO @tShipLabel (Variable, Value) VALUES ( '@cLabelNo',     @cLabelNo)

      -- Print label
      EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, '',
         'SHIPZPLLBL', -- Report type
         @tShipLabel, -- Report params
         'rdt_593Print34',
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT

      IF @nErrNo <> 0
         GOTO Quit
   END

   IF @cOption = '2'
   BEGIN
      SELECT @cFilePath = Long,
      @cPrintFilePath = Notes,
      @cReportType = Code2,
      @cFilePrefix = UDF01
      FROM dbo.CODELKUP WITH (NOLOCK)
      WHERE LISTNAME = 'PrtbyShipK'
      AND   Code = 'SHIPLBLPDF'
      AND   StorerKey = @cStorerKey

      SELECT @cWinPrinter = WinPrinter
      FROM rdt.rdtPrinter WITH (NOLOCK)
      WHERE PrinterID = @cLabelPrinter

      IF CHARINDEX(',' , @cWinPrinter) > 0
      BEGIN
         SET @cPrinterName = LEFT( @cWinPrinter , (CHARINDEX(',' , @cWinPrinter) - 1) )
         SET @cWinPrinterName = @cPrinterName
      END
      ELSE
      BEGIN
         SET @cWinPrinterName = @cWinPrinter
      END

      IF ISNULL( @cFilePath, '') = ''
      BEGIN
         SET @nErrNo = 158955
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Setup FilePath
         GOTO Quit
      END

      DECLARE @tRDTPrintJob AS VariableTable
      DECLARE @curPrint   CURSOR
      SET @curPrint = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      --SELECT DISTINCT PD.LabelNo, PH.OrderKey  --AAY001
   SELECT DISTINCT TOP 1 PD.LabelNo, PH.OrderKey
      FROM dbo.PackDetail PD WITH (NOLOCK)
      JOIN dbo.PackHeader PH WITH (NOLOCK) ON ( PD.PickSlipNo = PH.PickSlipNo)
      WHERE ( @cParam1 = '') OR ( PD.DropID = @cParam1)
      AND   ( @cParam2 = '') OR ( PH.OrderKey = @cParam2)
      AND   PH.StorerKey = @cStorerKey
      --ORDER BY 1 --AAY001
   ORDER BY PD.LABELNO DESC
      OPEN @curPrint
      FETCH NEXT FROM @curPrint INTO @cLabelNo, @cOrderKey
      WHILE @@FETCH_STATUS = 0
      BEGIN
         DELETE FROM @tRDTPrintJob
         SET @cFilePrefix = @cFilePrefix + CASE WHEN ISNULL( @cFilePrefix, '') <> '' THEN '_' ELSE '' END
         SET @cFileName = LTRIM( RTRIM( @cFilePrefix)) + LTRIM( RTRIM( @cLabelNo)) + '_' + @cOrderKey + '.pdf'
         SET @cPrintCommand = '"' + @cPrintFilePath + '" "' + @cFilePath + '\' + @cFileName + '" "19" "2" "' + @cWinPrinterName + '"'

         EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 0, 1, '', @cStorerKey, @cLabelPrinter, '',
            @cReportType,     -- Report type
            @tRDTPrintJob,    -- Report params
            'rdt_593Print34',
            @nErrNo  OUTPUT,
            @cErrMsg OUTPUT,
            1,
            @cPrintCommand

         FETCH NEXT FROM @curPrint INTO @cLabelNo, @cOrderKey
      END
   END

   Quit:
END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_593Print34 TO NSQL
GO