USE [GLOWMS]
GO
/****** Object:  StoredProcedure [RDT].[rdt_593PalLabelARLA]    Script Date: 6/21/2026 3:40:30 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************************************/
/* Stored Procedure: rdt_593PalLabelARLA                   */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : 593 Function for Printing for PalletLabels  UWP-59479                           */
/*                                                                           */
/* Called By: Report rdt_593PalLabelARLA                 */
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

CREATE OR ALTER    PROC [RDT].[rdt_593PalLabelARLA] (
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
   DECLARE @cID           NVARCHAR( 20)
   DECLARE @cFacility     NVARCHAR( 5)
   DECLARE @cSKU          NVARCHAR( 20)
   DECLARE @cPalletLabel  NVARCHAR( 10)
   DECLARE @nRowCount     INT
   DECLARE 
 
   @cSSCC       NVARCHAR( 20)
  
   DECLARE @delimiter CHAR(1) = ','

   
   --SET @cPoKey= @cParam1
   SET @cSSCC= @cParam1
   

   -- Get login info
   SELECT
      @cFacility = Facility,
      @cLabelPrinter = Printer,
      @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Check Receipt Key
   
   SELECT TOP 1  @cSSCC =RD.ToId FROM RECEIPTDETAIL RD WHERE RD.ToId=@cParam1
  

   SET @nRowCount = @@ROWCOUNT

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 230220
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') 
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
      SET @nErrNo = 119104
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --RPTypeNotSetup
      GOTO Quit
   END

   
   BEGIN
      DECLARE @tPalletLabel VariableTable
     
      INSERT INTO @tPalletLabel (Variable, Value) VALUES
      ( '@cSSCC',        @cSSCC)
   
      -- Print label
      EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, 1, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
      @cPalletLabel, -- Report type
      @tPalletLabel, -- Report params
      'rdt_593PalLabelARLA',
      @nErrNo  OUTPUT,
      @cErrMsg OUTPUT

      --IF @nErrNo <> 0
         --GOTO Quit
      --DELETE FROM  @tPalletLabel
      
      
   END

Quit:
