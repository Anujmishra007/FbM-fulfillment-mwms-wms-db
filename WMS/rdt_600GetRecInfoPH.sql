SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************************************/
/* Store procedure: rdt_600GetRecInfoPH                                                            */
/* Copyright      : Maersk WMS                                                                     */
/*                                                                                                 */
/* Date         Rev   Author   Purposes                                                            */
/***************************************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_600GetRecInfoPH]
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cStorerKey   NVARCHAR( 15), 
   @cReceiptKey  NVARCHAR( 10), 
   @cPOKey       NVARCHAR( 10), 
   @cLOC         NVARCHAR( 10), 
   @cID          NVARCHAR( 18)  OUTPUT, 
   @cSKU         NVARCHAR( 20)  OUTPUT, 
   @nQTY         INT         OUTPUT, 
   @cLottable01  NVARCHAR( 18)  OUTPUT, 
   @cLottable02  NVARCHAR( 18)  OUTPUT, 
   @cLottable03  NVARCHAR( 18)  OUTPUT, 
   @dLottable04  DATETIME       OUTPUT, 
   @dLottable05  DATETIME       OUTPUT, 
   @cLottable06  NVARCHAR( 30)  OUTPUT, 
   @cLottable07  NVARCHAR( 30)  OUTPUT, 
   @cLottable08  NVARCHAR( 30)  OUTPUT, 
   @cLottable09  NVARCHAR( 30)  OUTPUT, 
   @cLottable10  NVARCHAR( 30)  OUTPUT, 
   @cLottable11  NVARCHAR( 30)  OUTPUT, 
   @cLottable12  NVARCHAR( 30)  OUTPUT, 
   @dLottable13  DATETIME       OUTPUT, 
   @dLottable14  DATETIME       OUTPUT, 
   @dLottable15  DATETIME       OUTPUT, 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @dAddDate AS DATETIME,
      @cAddUser AS NVARCHAR(20),
      @cUDF01 AS NVARCHAR(50),
      @cUDF02 AS NVARCHAR(50),
      @cUDF03 AS NVARCHAR(50),
      @cUDF04 AS NVARCHAR(50),
      @cUDF05 AS NVARCHAR(50),
      @cUDF06 AS NVARCHAR(50),
      @cUDF07 AS NVARCHAR(50),
      @cUDF08 AS NVARCHAR(50),
      @cUDF09 AS NVARCHAR(50),
      @cUDF10 AS NVARCHAR(50),
      @cUDF11 AS NVARCHAR(50),
      @cUDF12 AS NVARCHAR(50),
      @cPalletType AS NVARCHAR(20),
      @cConditionCode NVARCHAR( 18)
      --@cOutField10 AS NVARCHAR(50)

   SELECT TOP 1
      @cReceiptKey = V_ReceiptKey,
      @cPOKey = V_POKey,
      @cLoc = V_Loc,
      @dAddDate = GETDATE(),
      @cAddUser = UserName,
      @cUDF01 = '',
      @cUDF02 = '',
      @cUDF03 = '',
      @cUDF04 = '',
      @cUDF05 = '',
      @cUDF06 = '',
      @cUDF07 = '',
      @cUDF08 = '',
      @cUDF09 = '',
      @cUDF10 = '',
      @cUDF11 = '',
      @cUDF12 = '',
      @cPalletType = C_String2
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile 


   IF @nFunc = 600
   BEGIN

 
        IF @nStep = 5
            BEGIN
                
                SELECT TOP 1
                @nQTY = QtyExpected
                --,@cReasonCode = ConditionCode
                FROM Receiptdetail WITH (NOLOCK)
                WHERE receiptkey = @cReceiptKey 
                AND Sku = @cSKU
                AND toID = @cID

            END       
        IF @nStep = 4
             BEGIN            
                SELECT TOP 1 
                @cLottable01 = ISNULL(RTRIM(receiptdetail.lottable01),'')
                ,@cLottable02 = ISNULL(RTRIM(receiptdetail.lottable02),'')
                ,@cLottable03 = ISNULL(RTRIM(receiptdetail.lottable03),'')
                ,@dLottable04 = ISNULL(RTRIM(receiptdetail.lottable04),'')
                ,@dLottable05 = ISNULL(RTRIM(receiptdetail.lottable05),'')
                ,@cLottable06 = ISNULL(RTRIM(receiptdetail.lottable06),'')
                ,@cLottable07 = ISNULL(RTRIM(receiptdetail.lottable07),'')
                ,@cLottable08 = ISNULL(RTRIM(receiptdetail.lottable08),'')
                ,@cLottable09 = ISNULL(RTRIM(receiptdetail.lottable09),'')
                ,@cLottable10 = ISNULL(RTRIM(receiptdetail.lottable10),'')
                ,@cLottable11 = ISNULL(RTRIM(receiptdetail.lottable11),'')
                ,@cLottable12 = ISNULL(RTRIM(receiptdetail.lottable12),'')
                ,@dLottable13 = ISNULL(RTRIM(receiptdetail.lottable13),'')
                ,@dLottable14 = ISNULL(RTRIM(receiptdetail.lottable14),'')
                ,@dLottable15 = ISNULL(RTRIM(receiptdetail.lottable15),'')
                ,@cConditionCode = ConditionCode
                FROM Receiptdetail WITH (NOLOCK)
                WHERE receiptkey = @cReceiptKey 
                AND Sku = @cSKU
                AND toID = @cID
                
            END
    END    
END -- End Procedure
GO
