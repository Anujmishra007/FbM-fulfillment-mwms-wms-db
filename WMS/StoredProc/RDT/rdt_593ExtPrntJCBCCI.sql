SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_593ExtPrntJCBCCI                                */
/* Copyright      : Maersk                                              */
/* Purpose: Re Print  JCB Picking Labels                                */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date           Rev  Author     Purposes                              */
/* 15-Jan-2026    1.0  AGM046     Created                               */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_593ExtPrntJCBCCI] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR(3),
   @cStorerKey NVARCHAR(15),
   @cOption    NVARCHAR(1),
   @cParam1    NVARCHAR(20), --Case ID
   @cParam2    NVARCHAR(20),
   @cParam3    NVARCHAR(20),
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR(20) OUTPUT
)
AS
BEGIN 
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   --
   DECLARE @cPaperPrinter     NVARCHAR( 10),
           @cLabelPrinter     NVARCHAR( 10),
           @cUserName         NVARCHAR( 18),
           @cFacility         NVARCHAR( 5),                 
           @nInputKey         INT = 1, -- Temp Fix		
		   @cCaseID           NVARCHAR(20),
		   @cLabelType        NVARCHAR(20),
		   @tCabsCaseIDLbl    AS VariableTable		   
  		   
   --
   SELECT @cLabelPrinter = Printer,
          @cPaperPrinter = Printer_Paper,
          @cFacility = Facility,
          @cStorerkey = StorerKey,
          @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   --
   SET @cCaseID = @cParam1
   IF (@cCaseID IS NOT NULL AND LTRIM(RTRIM(@cCaseID)) <> '')
   BEGIN	
   --
   IF @nInputKey = 1
   BEGIN
      INSERT INTO @tCabsCaseIDLbl (Variable, Value)
      VALUES ('@cCaseID', @cCaseID)

      -- Header label
      SET @cLabelType = 'RMlpnCaseH'

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
         @cLabelType,
         @tCabsCaseIDLbl,
         'RDT_CabsCaseID',
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT

      IF @nErrNo <> 0
         GOTO Quit

      -- Line label
      SET @cLabelType = 'RMlpnCaseL'

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
         @cLabelType,
         @tCabsCaseIDLbl,
         'rdt_CabsCaseID',
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT

      IF @nErrNo <> 0
         GOTO Quit
   END -- @nInputKey = 1 
   END -- Empty caseid	
Quit:
END
GO
GRANT EXECUTE ON rdt_593ExtPrntJCBCCI TO NSQL
GO
