
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_600ExtSNVal02                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date        Rev  Author       Purposes                                     */
/* 10-03-2025  1.0  yeekung      UWP-31293 Created                            */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_600ExtSNVal02
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 3),
   @cStorerKey       NVARCHAR( 15),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT, 
   @cSerialNo        NVARCHAR( 30),
   @cType            NVARCHAR( 15), --CHECK/INSERT
   @cDocType         NVARCHAR( 10), 
   @cDocNo           NVARCHAR( 20), 
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cReceiptKey NVARCHAR( 10)
   DECLARE @cChkStatus  NVARCHAR( 10)
   DECLARE @cASNType    NVARCHAR( 1)

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      -- Get Receipt info
      SET @cReceiptKey = @cDocNo
      SELECT @cASNType = DocType FROM Receipt WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey
      
      -- Normal ASN
      IF @cASNType = 'A'
      BEGIN
         -- Check SNO received
         IF EXISTS( SELECT TOP 1 1
            FROM ReceiptSerialNo WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND SerialNo = @cSerialNo)
         BEGIN
            SET @nErrNo = 234651
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO received
            GOTO Quit
         END
         
         -- Check SNO received
         IF EXISTS( SELECT TOP 1 1
            FROM SerialNo WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND SerialNo = @cSerialNo)
         BEGIN
            SET @nErrNo = 234652
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO received
            GOTO Quit
         END
      END
   END

Quit:

END

GO

GRANT EXECUTE ON rdt.rdt_600ExtSNVal02 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
