
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************************************/
/* Stored Procedure: rdt_593ShipLabelARLA                                    */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : 593 Function for Printing for Shipping Labels  UWP-59479        */
/*                                                                           */
/* Called By: Report rdt_593ShipLabelARLA                                    */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 01-04-2026   KMS043   1.0  Initial version created                        */
/*****************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_593ShipLabelARLA] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 1),
   @cParam1    NVARCHAR(20),  --SSCC
   @cParam2    NVARCHAR(20),  
   @cParam3    NVARCHAR(20),  
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLabelPrinter NVARCHAR( 10)
   DECLARE @cPaperPrinter NVARCHAR( 10)
   DECLARE @cFacility     NVARCHAR( 5)
   DECLARE @cShipLabel  NVARCHAR( 10)
   DECLARE @nRowCount     INT
   DECLARE @cSSCC         NVARCHAR( 20)

   -- Get login info
   SELECT
      @cFacility = Facility,
      @cLabelPrinter = Printer,
      @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Check Receipt Key
   SELECT TOP 1 @cSSCC = PD.DROPID
   FROM dbo.PICKDETAIL PD WITH (NOLOCK)
   WHERE PD.StorerKey = @cStorerKey
     AND PD.DropID = @cParam1
  
   SET @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 271101
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')  -- Invalid Pallet ID
      GOTO Quit
   END
   

   /*-------------------------------------------------------------------------------

                                      Print shipping label

   -------------------------------------------------------------------------------*/
   -- Get storer config
   SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'ShipLabel', @cStorerKey)
   IF @cShipLabel = '0'
      SET @cShipLabel = ''

   -- Check report setup
   IF @cShipLabel = ''
   BEGIN
      SET @nErrNo = 271102
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --RPTypeNotSetup
      GOTO Quit
   END
   
   BEGIN
      DECLARE @tShipLabel VariableTable
     
      INSERT INTO @tShipLabel (Variable, Value) VALUES
      ( '@cSSCC',        @cSSCC)
   
      -- Print label
      EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, 1, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
      @cShipLabel, -- Report type
      @tShipLabel, -- Report params
      'rdt_593ShipLabelARLA',
      @nErrNo  OUTPUT,
      @cErrMsg OUTPUT

      IF @nErrNo <> 0
         GOTO Quit      
   END

Quit:
END    
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_593ShipLabelARLA] TO NSQL
GO

