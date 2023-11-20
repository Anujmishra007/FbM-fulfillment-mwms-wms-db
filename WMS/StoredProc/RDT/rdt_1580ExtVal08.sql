
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_1580ExtVal08                                    */
/* Copyright      : LF logistics                                        */
/*                                                                      */
/* Purpose: Return must key-in carton ID (L01)                          */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 25-07-2017  1.0  Ung         WMS-5723 Created                        */
/* 04-03-2020  1.1  James       WMS-12231 Add pallet qty check (james01)*/
/* 24-10-2023  1.2  Ung         WMS-23798 Add L03 check                 */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1580ExtVal08
    @nMobile      INT
   ,@nFunc        INT
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cLangCode    NVARCHAR( 3)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cReceiptKey  NVARCHAR( 10) 
   ,@cPOKey       NVARCHAR( 10) 
   ,@cExtASN      NVARCHAR( 20)
   ,@cToLOC       NVARCHAR( 10) 
   ,@cToID        NVARCHAR( 18) 
   ,@cLottable01  NVARCHAR( 18) 
   ,@cLottable02  NVARCHAR( 18) 
   ,@cLottable03  NVARCHAR( 18) 
   ,@dLottable04  DATETIME  
   ,@cSKU         NVARCHAR( 20) 
   ,@nQTY         INT
   ,@nErrNo       INT           OUTPUT 
   ,@cErrMsg      NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nPallet            INT           -- (james01)
   DECLARE @nID_Qty            INT           -- (james01)
   
   IF @nStep = 4 -- Lottables
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         -- Get receipt info
         DECLARE @cDocType NVARCHAR(1)
         SELECT @cDocType = DocType FROM Receipt WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey
         
         IF @cDocType = 'R' AND @cLottable01 = ''
         BEGIN
            SET @nErrNo = 127001
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need L01
            GOTO Quit
         END
      END
   END
   
   IF @nStep = 5  -- Qty
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         -- (james01)
         SELECT @nPallet = Pallet
         FROM dbo.SKU SKU WITH (NOLOCK)
         JOIN dbo.PACK PACK WITH (NOLOCK) ON ( SKU.PACKKey = PACK.PackKey)
         WHERE SKU.StorerKey = @cStorerKey
         AND   SKU.SKU = @cSKU
         
         SELECT @nID_Qty = ISNULL( SUM( BeforeReceivedQty), 0)
         FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
         WHERE ReceiptKey = @cReceiptKey
         AND   ToId = @cToID
         
         IF ( @nID_Qty + @nQTY) > @nPallet
         BEGIN
            SET @nErrNo = 127002
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --RCV>PALLET Qty
            GOTO Quit
         END

         -- Check L03
         IF rdt.RDTGetConfig( @nFunc, 'SkipLottable03', @cStorerKey) = '0'
         BEGIN
            DECLARE @cSKUGroup NVARCHAR( 10)
            SELECT @cSKUGroup = SKUGroup FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
            
            -- Only X708 need value, the rest don't need
            
            -- X708 with blank value
            IF @cSKUGroup = 'X708'  AND @cLottable03 = ''
            BEGIN
               SET @nErrNo = 127003
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need L03
               GOTO Quit
            END

            -- non X708 with value
            IF @cSKUGroup <> 'X708' AND @cLottable03 <> ''
            BEGIN
               SET @nErrNo = 127004
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Dont need L03
               GOTO Quit
            END
         END
      END
   END
   

Quit:
END
GO

GRANT EXECUTE ON rdt.rdt_1580ExtVal08 TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
