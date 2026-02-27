
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

     
   IF OBJECT_ID('tempdb..#ExternReceiptKey') IS NOT NULL  
         DROP TABLE #ExternReceiptKey  
    CREATE TABLE #ExternReceiptKey  (  
        ExternReceiptKey     NVARCHAR( 10))  

   IF @nFunc = 598 -- Piece receiving
   BEGIN
      -- Get Receipt info
     INSERT INTO #ExternReceiptKey (ExternReceiptKey)
      SELECT  R.ExternReceiptKey 
      FROM Receipt R WITH (NOLOCK) 
      JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (R.ReceiptKey = RD.ReceiptKey)
      JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON (R.ReceiptKey = CRL.ReceiptKey)
      WHERE  R.StorerKey = @cStorerKey
      AND RD.SKU = @cSKU
      AND Mobile = @nMobile
         
      -- Check SNO received
      IF NOT EXISTS(  SELECT TOP 1 1
                  FROM SerialNo WITH (NOLOCK)
              JOIN #ExternReceiptKey ON (USERDEFINE01 = ExternReceiptKey)
                  WHERE StorerKey = @cStorerKey
                     AND SKU = @cSKU
                     AND SerialNo = @cSerialNo)
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
