SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO




/*********************************************************************************/
/* Store procedure: rdt_593ExtPrBXLblHP                                        */
/* Copyright      : Maersk                                                       */
/* Purpose: Print HP Box  Label                                                  */
/*                                                                               */
/* Modifications log:                                                            */
/*                                                                               */
/* Date        Rev  Author       Purposes                                        */
/* 09-Oct-2025 1.0  A,Betteridge Created                                         */
/*********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_593ExtPrBXLblHP] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR(3),
   @cStorerKey NVARCHAR(15),
   @cOption    NVARCHAR(1),
   @cParam1    NVARCHAR(20), --SSCC
   @cParam2    NVARCHAR(20),
   @cParam3    NVARCHAR(20),
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cPaperPrinter     NVARCHAR( 10),
           @cLabelPrinter     NVARCHAR( 10),
           @cUserName         NVARCHAR( 18),
           @cFacility         NVARCHAR( 5),
           @cShippLabel       NVARCHAR( 10),
           @cReportType      NVARCHAR( 20),
           @cOrd_TrackNo      NVARCHAR( 40),
           @cExternOrderKey   NVARCHAR( 50),
           @cFileName         NVARCHAR( 50),
           @dOrderDate        DATETIME,
           @nExpectedQty      INT = 0,
           @nPackedQty        INT = 0,
           @nTempCartonNo     INT
         , @nInputKey         INT = 1 -- Temp Fix

   DECLARE @tSSCCList VariableTable

   SELECT @cLabelPrinter = Printer,
          @cPaperPrinter = Printer_Paper,
          @cFacility = Facility,
          @cStorerkey = StorerKey,
          @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Insert test
INSERT INTO [dbo].[TraceInfo]
           ([TraceName]
           ,[TimeIn]
           ,[TimeOut]
           ,[TotalTime]
           ,[Step1]
           ,[Step2]
           ,[Step3]
           ,[Step4]
           ,[Step5]
           ,[Col1]
           ,[Col2]
           ,[Col3]
           ,[Col4]
           ,[Col5])
     Select N'rdt_593ExtPrBXLblHP'
           ,NULL
           ,NULL
           ,NULL
           ,@nStep
           ,@nMobile
           ,@nFunc
           ,@cLabelPrinter
           ,@cPaperPrinter
           ,@cFacility
           ,@cStorerkey
           ,'TEST123JBI'
           ,NULL
           ,NULL

   IF @nInputKey = 1
   BEGIN
      IF @nStep IN (1, 2) --Temp Fix
      BEGIN

		 IF @cOption = '2'   -- added for 1nd label   
         SET @cReportType = rdt.RDTGetConfig( @nFunc, 'BOXLABEL', @cStorerKey)
		 
	

         IF @cReportType = '0'
            SET @cReportType = ''

         -- TH use this to print outbound label by sscc
         IF @cReportType <> ''
         BEGIN
            INSERT INTO @tSSCCList (Variable, Value) VALUES
            -- ( '@cStorerKey',  @cStorerKey),
            -- ( '@cExternOrderkey',       @cParam1)

						( '@cExternOrderKey', @cParam1),  --WS 20251013
                        ( '@cSerialNo'      , @cParam2)   --WS 20251013

            -- Print label
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cLabelPrinter, @cPaperPrinter,
               @cReportType, -- Report type
               @tSSCCList, -- Report params
               N'rdt_593ExtPrBXLblHP',
               @nErrNo  OUTPUT,
               @cErrMsg OUTPUT

		
         END
      END   -- IF @nStep = 1
  END
Quit:
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_593ExtPrBXLblHP] TO NSQL
GO
