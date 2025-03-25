SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_VFDecodeSN01                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Decode serial no                                            */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 2025-03-21  1.0  Dennis       FCR-3225  Created                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_VFDecodeSN01]
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

   DECLARE @nReceiveSerialNoLogKey INT
   DECLARE @nRowCount INT

   IF CHARINDEX(@cSKU,@cBarcode) <> 1
   BEGIN
      SET @nErrNo = 235501
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SN SKU Match failed   
      GOTO Quit 
   END
   SELECT @cSerialNo = SUBSTRING(@cBarcode, LEN(@cSKU)+1, LEN(@cBarcode))

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_VFDecodeSN01] TO [NSQL]
GO