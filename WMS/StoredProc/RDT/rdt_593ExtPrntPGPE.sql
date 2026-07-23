SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_593ExtPrntPGPE                                        */
/* Copyright      : LF Logistics                                              */
/* Customer       : PGPE                                                      */
/*                                                                            */
/* Purpose: Print PGPE Pallet/Box Label                                       */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-04-16   MLR024    1.0   RITM9015567/UWP-62221 Created                 */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_593ExtPrntPGPE]
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 1),
   @cParam1    NVARCHAR( 20), -- OrderKey
   @cParam2    NVARCHAR( 20), -- DropID
   @cParam3    NVARCHAR( 20),
   @cParam4    NVARCHAR( 20),
   @cParam5    NVARCHAR( 20),
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cPaperPrinter NVARCHAR( 10),
      @cLabelPrinter NVARCHAR( 10),
      @cUserName     NVARCHAR( 18),
      @cFacility     NVARCHAR( 5),
      @cReportType   NVARCHAR( 20) = '',
      @nInputKey     INT           = 1,
      @cSQL          NVARCHAR( MAX),
      @cSQLVal       NVARCHAR( MAX),
      @cSQLParam     NVARCHAR( MAX),
      @nNoOfCopy     INT           = 1,
      @nTemp         INT,
      @cUDF01        NVARCHAR( 60),
      @cUDF02        NVARCHAR( 60),
      @cUDF03        NVARCHAR( 60),
      @cUDF04        NVARCHAR( 60),
      @cUDF05           NVARCHAR( 60),
      @dTraceStartTime  DATETIME = GETDATE(),
      @dTraceEndTime    DATETIME

   DECLARE @tDropId   TABLE (DropId NVARCHAR( 20))
   DECLARE @tDataList dbo.VariableTable

   SELECT
      @cLabelPrinter = Printer,
      @cPaperPrinter = Printer_Paper,
      @cFacility     = Facility,
      @cStorerKey    = StorerKey,
      @cUserName     = UserName
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @cLabelPrinter = ''
   BEGIN
      SET @nErrNo = 81554
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- LabelPrnterReq
      GOTO Quit
   END

   -- Get Codelkup RDTLBLRPT values
   SELECT
      @cUDF01 = ISNULL(UDF01, ''),
      @cUDF02 = ISNULL(UDF02, ''),
      @cUDF03 = ISNULL(UDF03, ''),
      @cUDF04 = ISNULL(UDF04, ''),
      @cUDF05 = ISNULL(UDF05, '')
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND Listname = 'RDTLBLRPT'
      AND Code = @cOption
   ORDER BY Code2

   -- Check at least one parameter input
   IF NOT (
      (@cUDF01 <> '' AND ISNULL(@cParam1, '') <> '') OR
      (@cUDF02 <> '' AND ISNULL(@cParam2, '') <> '') OR
      (@cUDF03 <> '' AND ISNULL(@cParam3, '') <> '') OR
      (@cUDF04 <> '' AND ISNULL(@cParam4, '') <> '') OR
      (@cUDF05 <> '' AND ISNULL(@cParam5, '') <> '')
   )
   BEGIN
      SET @nErrNo = 119901
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Input Required
      GOTO Quit
   END

   -- Check mandatory parameter input
   -- (Parameter Text Label start with * means mandatory)
   SET @nTemp = CASE
      WHEN (LEFT(@cUDF01, 1) = '*' AND ISNULL(@cParam1, '') = '') THEN 2
      WHEN (LEFT(@cUDF02, 1) = '*' AND ISNULL(@cParam2, '') = '') THEN 4
      WHEN (LEFT(@cUDF03, 1) = '*' AND ISNULL(@cParam3, '') = '') THEN 6
      WHEN (LEFT(@cUDF04, 1) = '*' AND ISNULL(@cParam4, '') = '') THEN 8
      WHEN (LEFT(@cUDF05, 1) = '*' AND ISNULL(@cParam5, '') = '') THEN 10
      ELSE 0
   END

   IF @nTemp > 0
   BEGIN
      SET @nErrNo = 119902
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Input Required
      EXEC rdt.rdtSetFocusField @nMobile, @nTemp
      GOTO Quit
   END

   IF @nInputKey = 1
   BEGIN
      IF @nStep IN (1, 2)
      BEGIN
         SELECT
            @cSQL    = Notes,  -- Logic to obtain ReportType and NoOfCopy
            @cSQLVal = Notes2  -- Logic for validations
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND Listname = 'RDTLBLRPT'
            AND Code = @cOption

         -- Get list of Drop/ID to print
         INSERT INTO @tDropId
         SELECT DISTINCT IIF(DropID = '', ID, DropID)
         FROM dbo.PICKDETAIL WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND OrderKey = @cParam1
            AND Status IN ('5', '9')
            AND (DropID = @cParam2 OR ID = @cParam2 OR @cParam2 = '')

         IF (SELECT COUNT(1) FROM @tDropId) = 0
         BEGIN
            SET @nErrNo = 111852
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not Records
            EXEC rdt.rdtSetFocusField @nMobile, @nTemp
            GOTO Quit
         END

         WHILE (SELECT COUNT(1) FROM @tDropId) > 0
         BEGIN
            SELECT TOP 1 @cParam2 = DropId FROM @tDropId

            SET @cSQLParam =
               '@cReportType NVARCHAR(20) OUTPUT' +
               ',@nNoOfCopy  INT          OUTPUT' +
               ',@cStorerKey NVARCHAR(15)'        +
               ',@cParam1    NVARCHAR(60)'        +
               ',@cParam2    NVARCHAR(60)'        +
               ',@cParam3    NVARCHAR(60)'        +
               ',@cParam4    NVARCHAR(60)'        +
               ',@cParam5    NVARCHAR(60)'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam
               ,@cReportType OUTPUT
               ,@nNoOfCopy   OUTPUT
               ,@cStorerKey
               ,@cParam1
               ,@cParam2
               ,@cParam3
               ,@cParam4
               ,@cParam5

            IF @cReportType <> ''
            BEGIN
               INSERT INTO @tDataList (Variable, Value) VALUES
                  ('@cOrderKey', @cParam1),
                  ('@cDropID',   @cParam2)

               -- Print label
               EXEC RDT.rdt_Print
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey,
                  @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                  @cReportType,  -- Report type
                  @tDataList,    -- Report params
                  'rdt_593ExtPrntPGPE',
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT,
                  @nNoOfCopy

               DELETE @tDataList

               SET @dTraceEndTime = GETDATE()
               EXEC isp_InsertTraceInfo
                  @c_TraceCode = 'BARTENDER',
                  @c_TraceName = 'rdt_593ExtPrntPGPE',
                  @c_starttime = @dTraceStartTime,
                  @c_endtime   = @dTraceEndTime,
                  @c_step1     = @cUserName,
                  @c_step2     = @nStep,
                  @c_step3     = @nMobile,
                  @c_step4     = @cOption,
                  @c_step5     = @cReportType,
                  @c_col1      = @cParam1,
                  @c_col2      = @cParam2,
                  @c_col3      = @cStorerKey,
                  @c_col4      = @cLabelPrinter,
                  @c_col5      = @nNoOfCopy,
                  @b_Success   = 1,
                  @n_Err       = @nErrNo,
                  @c_ErrMsg    = @cErrMsg
            END
            ELSE
            BEGIN
               SET @nErrNo = 110051
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Label Required
               EXEC rdt.rdtSetFocusField @nMobile, @nTemp
               GOTO Quit
            END

            DELETE @tDropId WHERE DropId = @cParam2
         END
      END
   END

Quit:
END
GO

GRANT EXECUTE ON [RDT].[rdt_593ExtPrntPGPE] TO [NSQL]
GO
