SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_600ExtValHLAU                                   */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: CHARGEURS                                                   */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2025-03-23 1.0    YWA059     Created                                 */
/* 2025-04-14 1.1.0  BDH028     Adding validation for ID,SKU            */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_600ExtValHLAU] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5), 
   @cStorerKey   NVARCHAR( 15), 
   @cReceiptKey  NVARCHAR( 10), 
   @cPOKey       NVARCHAR( 10), 
   @cLOC         NVARCHAR( 10), 
   @cID          NVARCHAR( 18), 
   @cSKU         NVARCHAR( 20), 
   @cLottable01  NVARCHAR( 18), 
   @cLottable02  NVARCHAR( 18), 
   @cLottable03  NVARCHAR( 18), 
   @dLottable04  DATETIME,      
   @dLottable05  DATETIME,      
   @cLottable06  NVARCHAR( 30), 
   @cLottable07  NVARCHAR( 30), 
   @cLottable08  NVARCHAR( 30), 
   @cLottable09  NVARCHAR( 30), 
   @cLottable10  NVARCHAR( 30), 
   @cLottable11  NVARCHAR( 30), 
   @cLottable12  NVARCHAR( 30), 
   @dLottable13  DATETIME,      
   @dLottable14  DATETIME,      
   @dLottable15  DATETIME,      
   @nQTY         INT,           
   @cReasonCode  NVARCHAR( 10), 
   @cSuggToLOC   NVARCHAR( 10), 
   @cFinalLOC    NVARCHAR( 10), 
   @cReceiptLineNumber NVARCHAR( 10), 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE @cPackKey      NVARCHAR(10) 
          ,@nPallet       INT
          ,@received_qty  INT
   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         SELECT @cPackKey = PackKey
            FROM dbo.SKU WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey
            AND SKU = @cSKU
            SELECT @nPallet = Pallet 
            FROM dbo.Pack WITH (NOLOCK) 
            WHERE PackKey = @cPackKey

         IF @nStep = 4  -- SKU
         BEGIN
            IF EXISTS (SELECT 1  FROM
                     dbo.RECEIPTDETAIL (NOLOCK)
                     WHERE sku<>@csku
                       AND TOID = @cID
                       AND storerkey = @cStorerKey)
            BEGIN
               SET @nErrNo = 219957   
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Multiple SKU
               GOTO QUIT 
            END

            IF ISNULL(@nPallet, 0 )  =  0 
            BEGIN
               SET @nErrNo = 219955
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PalletQtyNotSetup
               GOTO Fail
            END
            
            IF NOT EXISTS (SELECT 1 FROM SKU(nolock) 
                     WHERE Sku = @csku COLLATE Latin1_General_BIN 
                      AND storerkey = @cStorerKey)
            BEGIN
               SET @nErrNo = 219964   
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid SKU, need to UPPER
               GOTO QUIT 
            END
         END
         
         IF @nStep = 3
         BEGIN
            IF (LEN(@cID) > 10 OR LEFT(@cID,3) <> 'HLS')
            BEGIN
               SET @nErrNo = 219965   
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid ID
               GOTO QUIT 
            END
            
            IF (UPPER(@cID) <> @cID COLLATE Latin1_General_BIN )
            BEGIN
               SET @nErrNo = 219966
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid ID Format, need to UPPER
               GOTO QUIT 
            END
         END 
         
         IF @nStep = 6  -- Qty
         BEGIN
            IF EXISTS (SELECT 1 FROM
                     RECEIPTDETAIL (NOLOCK)
                     WHERE Lottable01 <> @cLottable01
                      AND TOID = @cID
                      AND storerkey = @cStorerKey)
            BEGIN
               SET @nErrNo = 219958   
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Multiple Batch
               GOTO QUIT 
            END
            SELECT @received_qty = SUM(QtyReceived)
            FROM RECEIPTDETAIL WITH (NOLOCK)
            WHERE storerkey = @cStorerKey
              AND ToId = @cID
            IF @nQTY + ISNULL(@received_qty,0) > @nPallet
            BEGIN
               SET @nErrNo = 219956
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Qty>PalletQty
               GOTO Fail
            END
         END   
      END      
   END         
Fail:
Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_600ExtValHLAU] TO NSQL;
GO
