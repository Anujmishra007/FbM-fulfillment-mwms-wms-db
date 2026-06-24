
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************************************/
/* Stored Procedure: rdt_593PalLabelARLA                                     */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : 593 Function for Printing for PalletLabels  UWP-59479           */
/*                                                                           */
/* Called By: Report rdt_593PalLabelARLA                                     */
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

CREATE OR ALTER PROC [RDT].[rdt_593PalLabelARLA] (
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
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLabelPrinter NVARCHAR( 10)
   DECLARE @cPaperPrinter NVARCHAR( 10)
   DECLARE @cFacility     NVARCHAR( 5)
   DECLARE @cPalletLabel  NVARCHAR( 10)
   DECLARE @nRowCount     INT
   DECLARE @cSSCC         NVARCHAR( 20)

   SET @nErrNo = 0
   SET @cErrMsg = ''
   
   -- Get login info
   SELECT
      @cFacility = Facility,
      @cLabelPrinter = Printer,
      @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Check pallet id
   SELECT TOP 1 @cSSCC = RD.ToId
   FROM dbo.PODETAIL RD WITH (NOLOCK)
   WHERE RD.StorerKey = @cStorerKey
     AND RD.ToId = @cParam1
  
   SET @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 271001
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')  -- Invalid Pallet ID
      GOTO Quit
   END
   

   /*-------------------------------------------------------------------------------

                                      Print pallet label

   -------------------------------------------------------------------------------*/
   -- Get storer config
   SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'PalletLabel', @cStorerKey)
   IF @cPalletLabel = '0'
      SET @cPalletLabel = ''

   -- Check report setup
   IF @cPalletLabel = ''
   BEGIN
      SET @nErrNo = 271002
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- RPTypeNotSetup
      GOTO Quit
   END


   DECLARE @tPalletLabel VariableTable

   INSERT INTO @tPalletLabel (Variable, Value) 
   VALUES ('@cSSCC', @cSSCC)

   -- Print label
   EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, 1, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
   @cPalletLabel, -- Report type
   @tPalletLabel, -- Report params
   'rdt_593PalLabelARLA',
   @nErrNo  OUTPUT,
   @cErrMsg OUTPUT

   IF @nErrNo <> 0
      GOTO Quit

Quit:
END    
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_593PalLabelARLA] TO NSQL
GO
