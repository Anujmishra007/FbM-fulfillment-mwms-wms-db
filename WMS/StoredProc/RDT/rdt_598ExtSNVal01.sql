
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_598ExtSNVal01                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date        Rev  Author       Purposes                                     */
/* 09-07-2025  1.0  YeeKung      FCR-5719 Created                             */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_598ExtSNVal01
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
   DECLARE @cExternReceiptKey  NVARCHAR( 10)

   IF @nFunc = 598 -- Piece receiving
   BEGIN
      -- Get Receipt info
      SET @cReceiptKey = @cDocNo
      SELECT @cExternReceiptKey = ExternReceiptKey 
      FROM Receipt WITH (NOLOCK) 
      WHERE ReceiptKey = @cReceiptKey
         AND StorerKey = @cStorerKey
         
      -- Check SNO received
      IF EXISTS(  SELECT TOP 1 1
                  FROM SerialNo WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND SKU = @cSKU
                     AND SerialNo = @cSerialNo
                     AND USERDEFINE01 <> @cExternReceiptKey)
      BEGIN
         SET @nErrNo = 241651
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvSerialNo
         GOTO Quit
      END
  
   END

Quit:

END

GO

GRANT EXECUTE ON rdt.rdt_598ExtSNVal01 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
