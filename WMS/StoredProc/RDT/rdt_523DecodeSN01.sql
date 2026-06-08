
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_523DecodeSN01                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Decode / delimited serial no                                */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 2024-01-25  1.0  Ung          WMS-24683 Created                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_523DecodeSN01]
   @nMobile     INT,           
   @nFunc       INT,           
   @cLangCode   NVARCHAR( 3),  
   @nStep       INT,           
   @nInputKey   INT,           
   @cStorerKey  NVARCHAR( 15), 
   @cFacility   NVARCHAR( 5),  
   @cSKU        NVARCHAR( 20),  
   @cBarcode    NVARCHAR( MAX),
   @cSerialNo   NVARCHAR( 30)  OUTPUT,
   @nSerialQTY  INT            OUTPUT,
   @nBulkSNO    INT            OUTPUT,
   @nErrNo      INT            OUTPUT,
   @cErrMsg     NVARCHAR( 20)  OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Composite barcode
   IF CHARINDEX( '&', @cBarcode) > 0
   BEGIN
      DECLARE @cTempSNO NVARCHAR( 50)
      DECLARE @cTempSKU NVARCHAR( 20)
      DECLARE @nTempQTY INT

      DECLARE @nRowCount INT
      DECLARE @cStyle NVARCHAR( 30)
      DECLARE @cSize  NVARCHAR( 30)
      DECLARE @cL01P1 NVARCHAR( 18)
      DECLARE @cL01P2 NVARCHAR( 18)
      DECLARE @cSNOP1 NVARCHAR( 10)
      DECLARE @cSNOP2 NVARCHAR( 10)
      DECLARE @cSNOP3 NVARCHAR( 10)
      
      DECLARE @tValue TABLE
      (
         value       NVARCHAR( 100), 
         RowNumber   INT
      )
      
      INSERT INTO @tValue (value, RowNumber)
      SELECT value, ROW_NUMBER() OVER ( ORDER BY (SELECT 1)) RowNumber 
      FROM STRING_SPLIT( @cBarcode, '&')
      
      SELECT 
         @cStyle = CASE WHEN RowNumber = 2 THEN value ELSE @cStyle END, 
         @cSize  = CASE WHEN RowNumber = 3 THEN value ELSE @cSize  END, 
         @cSNOP1 = CASE WHEN RowNumber = 4 THEN value ELSE @cSNOP1 END, 
         @cSNOP2 = CASE WHEN RowNumber = 5 THEN value ELSE @cSNOP2 END, 
         @cL01P1 = CASE WHEN RowNumber = 6 THEN value ELSE @cL01P1 END, 
         @cSNOP3 = CASE WHEN RowNumber = 7 THEN value ELSE @cSNOP3 END, 
         @cL01P2 = CASE WHEN RowNumber = 8 THEN value ELSE @cL01P2 END
      FROM @tValue
      
      -- Invalid barcode
      IF @@ROWCOUNT <> 8
      BEGIN
         SET @nErrNo = 266301
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidBarcode
         GOTO Quit
      END

      -- Get SKU
      SELECT @cTempSKU = SKU
      FROM dbo.SKU WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND BUSR5 = @cStyle
         AND BUSR6 = @cSize
         
      SET @nRowCount = @@ROWCOUNT
      
      -- Invalid SKU
      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 266302
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
         GOTO Quit
      END
      
      -- Multi SKU barcode
      ELSE IF @nRowCount > 1
      BEGIN
         SET @nErrNo = 266303
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Multi SKU
         GOTO Quit
      END
      
      -- Check SKU match
      ELSE IF @cTempSKU <> @cSKU
      BEGIN
         SET @nErrNo = 266305
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Different SKU
         GOTO Quit
      END
      
      -- Get session info
      DECLARE @cFromLOC NVARCHAR( 10)
      DECLARE @cFromID  NVARCHAR( 18)
      SELECT 
         @cFromLOC = V_LOC, 
         @cFromID = V_ID
      FROM rdt.rdtMobRec WITH (NOLOCK)
      WHERE Mobile = @nMobile
      
      SET @cTempSNO = @cSNOP1 + @cSNOP2 + @cSNOP3
      SET @nTempQTY = 1
      
      -- Validate serial no
      EXEC RDT.rdtIsValidSerialNo @cLangCode, @nErrNo OUTPUT, @cErrMsg OUTPUT,
         @cTempSNO,
         @cStorerKey,
         @cStatus = '1', -- 1=Received
         @cChkSKU = @cTempSKU,
         @nChkQTY = @nTempQTY, 
         @cChkLOC = @cFromLOC,
         @cChkID  = @cFromID
      IF @nErrNo <> 0
         GOTO Quit

      SET @cSerialNo = @cTempSNO
      SET @nSerialQTY = @nTempQTY
      SET @nBulkSNO = 0 -- No
   END
   ELSE
   BEGIN
      SET @nErrNo = 266304
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidBarcode
   END
   
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON rdt.rdt_523DecodeSN01 TO NSQL 
GO   