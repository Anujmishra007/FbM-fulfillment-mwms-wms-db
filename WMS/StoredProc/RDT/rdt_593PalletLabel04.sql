SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_593PalletLabel04                                   */
/* Copyright: Maersk                                                       */
/* Customer: USA Levis                                                     */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2025-12-16 1.0  NickT    FCR-8865  Created                              */
/***************************************************************************/

CREATE OR ALTER PROC rdt.rdt_593PalletLabel04 (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 1),
   @cParam1    NVARCHAR(20),  -- Qty
   @cParam2    NVARCHAR(20),  -- Prefix
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

   DECLARE 
      @cLabelPrinter NVARCHAR( 10),
      @cPaperPrinter NVARCHAR( 10),
      @cID           NVARCHAR( 20),
      @cFacility     NVARCHAR( 5),
      @cSKU          NVARCHAR( 20),
      @cPalletLabel  NVARCHAR( 10),
      @nRowCount     INT,
      @nQty          INT,
      @cReceiptKey   NVARCHAR( 20),
      @cPrefix       NVARCHAR( 20),
      @cMaxPalletQty NVARCHAR( 20),
      @nMaxPalletQty  INT,
      @cMaxCount     NVARCHAR( 20),
      @nMaxCount     INT,
      @cPrefixCode   NVARCHAR( 20),
      @cDoor         NVARCHAR( 20),
      @cTrailerID    NVARCHAR( 50),
      @cOBLPNLabel   NVARCHAR( 20),
      @cDelimiter     CHAR(1) = ','

   -- Get login info
   SELECT
      @cFacility = Facility,
      @cLabelPrinter = Printer,
      @cPaperPrinter = Printer_Paper
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF (@cParam1 IS NULL OR TRIM(@cParam1) = '')
      OR (@cParam2 IS NULL OR TRIM(@cParam2) = '')
   BEGIN
      SET @nErrNo = 254101
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --QTY/Prefix cannot be blank
      GOTO Quit
   END

   SET @nQty = ISNULL(TRY_CAST(@cParam1 AS INT), -1)
   IF @nQty < 1
   BEGIN
      SET @nErrNo = 254102
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Invalid Qty
      GOTO Quit
   END

   SET @cPrefix = TRIM(ISNULL(@cParam2, ''))
   IF @cPrefix = ''
   BEGIN
      SET @nErrNo = 254106
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Invalid Prefix
      GOTO Quit
   END

   SET @cOBLPNLabel = rdt.RDTGetConfig( @nFunc, 'OBLPNLabel', @cStorerKey)
   IF @cOBLPNLabel <> '0'
   BEGIN
      IF CHARINDEX(@cDelimiter, @cOBLPNLabel) = 0
      BEGIN 
         SET @nErrNo = 254103
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Invalid OBLPNLabel Config
         GOTO Quit
      END

      SELECT @cMaxPalletQty = LEFT(@cOBLPNLabel, CHARINDEX(@cDelimiter, @cOBLPNLabel) - 1), 
         @cPrefixCode = RIGHT (@cOBLPNLabel, (LEN(@cOBLPNLabel) - CHARINDEX(@cDelimiter, @cOBLPNLabel) ) )

      SET @nMaxPalletQty = ISNULL(TRY_CAST(@cMaxPalletQty AS INT), 0)

      IF @nMaxPalletQty < 1
      BEGIN
         SET @nErrNo = 254104
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Invalid OBLPNLabel Qty
         GOTO Quit
      END

      SET @cPrefixCode = TRIM(ISNULL(@cPrefixCode, ''))
      IF @cPrefixCode = ''
      BEGIN
         SET @nErrNo = 254105
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Invalid OBLPNLabel Prefix
         GOTO Quit
      END

      IF @nQty > @nMaxPalletQty
      BEGIN
         SET @nErrNo = 254107
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Exceeded Max Qty
         GOTO Quit
      END

      IF @cPrefix <> @cPrefixCode
      BEGIN
         SET @nErrNo = 254108
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Wrong Prefix
         GOTO Quit
      END
   END

   /*-------------------------------------------------------------------------------

                                      Print pallet label

   -------------------------------------------------------------------------------*/
   SELECT
      @cPalletLabel   = ISNULL(Code2,'')
   FROM dbo.CodeLkup WITH (NOLOCK)
   WHERE Listname = 'RDTLBLRPT'
      AND Code = @cOption 
      AND Storerkey = @cStorerKey
   ORDER BY Code2

   -- Check report setup
   IF @cPalletLabel = ''
   BEGIN
      SET @nErrNo = 119104
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --RPTypeNotSetup
      GOTO Quit
   END

   DECLARE @counter INT = 1,@b_success INT = 1
   DECLARE @cDate   NVARCHAR(10)
   SET @cDate = FORMAT(GETDATE(), 'd')

   DECLARE @tPalletLabel VariableTable

   WHILE @counter <= @nQty
   BEGIN
      SET @cID = ''
      EXECUTE dbo.nspg_GetKey
                  'ID',
                  7 ,
                  @cID               OUTPUT,
                  @b_success         OUTPUT,
                  @nErrNo            OUTPUT,
                  @cErrMsg           OUTPUT
      IF @b_success <> 1
      BEGIN
         SET @nErrNo = 59418
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --AutoGenID Fail
         GOTO Quit
      END

      SET @cID = CONCAT(@cPrefix , @cID)

      DELETE FROM  @tPalletLabel
      INSERT INTO @tPalletLabel (Variable, Value) VALUES
      ( '@cID',        @cID)
   
      -- Print label
      EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, 1, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
      @cPalletLabel, -- Report type
      @tPalletLabel, -- Report params
      'rdt_593PalletLabel04',
      @nErrNo  OUTPUT,
      @cErrMsg OUTPUT

      IF @nErrNo <> 0
         GOTO Quit
      
      SET @counter = @counter + 1
   END

Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_593PalletLabel04 TO NSQL
GO