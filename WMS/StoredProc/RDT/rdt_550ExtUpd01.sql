if exists (select * from dbo.sysobjects where id = object_id(N'rdt.rdt_550ExtUpd01') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_550ExtUpd01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_550ExtUpd01                                     */
/* Copyright: LF Logistics                                              */
/*                                                                      */
/* Purpose:                                                             */
/* Due to supplier provide pallet not according to standard pallet size,*/
/* check Pack.Pallet against pallet received QTY, prompt for restack    */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2014-08-15 1.0  Ung        SOS318341 Created                         */
/************************************************************************/

CREATE PROC rdt.rdt_550ExtUpd01 (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @cStorerKey   NVARCHAR( 15), 
   @cReceiptKey  NVARCHAR( 10), 
   @cPOKey       NVARCHAR( 10), 
   @cLOC         NVARCHAR( 10), 
   @cID          NVARCHAR( 18), 
   @cSKU         NVARCHAR( 20), 
   @nQty         INT,           
   @nStep        INT,
   @nValid       INT            OUTPUT,   
   @nErrNo       INT            OUTPUT,  
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nQty_Received     INT, 
           @nQty_Expected     INT 

   -- Initialise var
   SET @nValid = 1
   
   IF @nStep = 5
   BEGIN
      -- Check whether it is a pallet
      IF ISNULL( @cID, '') = '' 
         GOTO Quit

      -- Get Pack info
      DECLARE @nPallet INT
      SELECT @nPallet = CAST( Pallet AS INT)
      FROM SKU WITH (NOLOCK)
         JOIN Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
      WHERE StorerKey = @cStorerKey
         AND SKU.SKU = @cSKU

      -- Check pallet count
      IF @nPallet = 0 
         GOTO Quit
         
      -- Check multi SKU pallet
      IF EXISTS( SELECT TOP 1 1
         FROM dbo.ReceiptDetail WITH (NOLOCK) 
         WHERE ReceiptKey = @cReceiptKey
            AND ToID = @cID
            AND SKU <> @cSKU
            AND BeforeReceivedQTY > 0)
         GOTO QUIT

      -- Get received QTY
      DECLARE @nBeforeReceivedQTY INT
      SELECT @nBeforeReceivedQTY = ISNULL( SUM( BeforeReceivedQTY), 0)
      FROM dbo.ReceiptDetail WITH (NOLOCK) 
      WHERE ReceiptKey = @cReceiptKey
         AND ToID = @cID
         AND StorerKey = @cStorerKey
         AND SKU = @cSKU
      
      -- Check standard pallet size vs actual
      IF (@nQTY + @nBeforeReceivedQTY) > @nPallet
      BEGIN
         SET @nErrNo = 91451
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PalletOverQTY  
         SET @nValid = 0
         GOTO Quit
      END
      SET @nValid = 1
   END
Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_550ExtUpd01 TO NSQL
GO
