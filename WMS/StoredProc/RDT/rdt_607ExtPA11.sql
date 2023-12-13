
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_607ExtPA11                                            */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Extended putaway                                                  */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2023-07-26   James     1.0   WMS-23005. Created                            */
/* 2023-10-18   Ung       1.1   WMS-23840 Add multi ASN (RD.UserDefine05)     */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_607ExtPA11]
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cStorerKey   NVARCHAR( 15), 
   @cReceiptKey  NVARCHAR( 10), 
   @cPOKey       NVARCHAR( 10), 
   @cRefNo       NVARCHAR( 20), 
   @cSKU         NVARCHAR( 20), 
   @nQTY         INT,           
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
   @cReasonCode  NVARCHAR( 10), 
   @cID          NVARCHAR( 18), 
   @cLOC         NVARCHAR( 10), 
   @cReceiptLineNumber NVARCHAR( 10), 
   @cSuggID      NVARCHAR( 18)  OUTPUT, 
   @cSuggLOC     NVARCHAR( 10)  OUTPUT, 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUDF05      NVARCHAR( 30)
   DECLARE @cUDF10      NVARCHAR( 30)
   DECLARE @cStyle      NVARCHAR( 20)
   DECLARE @cFacility   NVARCHAR( 5)
   
   IF @nFunc = 607 -- Return v7
   BEGIN
   	SET @cSuggID = ''
   	SET @cSuggLOC = ''

      SELECT 
         @cUDF05 = ISNULL( UserDefine05, ''), 
         @cUDF10 = ISNULL( UserDefine10, '')
      FROM dbo.RECEIPT WITH (NOLOCK)
      WHERE ReceiptKey = @cReceiptKey

      -- Find latest LOC by SKU
      IF @cUDF10 = 'SKU'
      BEGIN
      	SELECT TOP 1 
      	   @cSuggLOC = RD.ToLoc
      	FROM dbo.Receipt R WITH (NOLOCK)
      	   JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (R.ReceiptKey = RD.ReceiptKey)
      	WHERE R.StorerKey = @cStorerKey
      	   AND R.UserDefine05 = @cUDF05
         	AND RD.SKU = @cSKU
         	-- AND RD.BeforeReceivedQTY > 0
         	AND RD.UserDefine10 <> 'closed'
      	ORDER BY RD.EditDate DESC
      END
      
      -- Find latest LOC by style
      ELSE IF @cUDF10 = 'ARTICLE'
      BEGIN
      	SELECT @cStyle = Style
      	FROM dbo.SKU WITH (NOLOCK)
      	WHERE StorerKey = @cStorerKey
      	   AND SKU = @cSKU
      	
      	SELECT TOP 1 
      	   @cSuggLOC = RD.ToLoc
      	FROM dbo.Receipt R WITH (NOLOCK)
      	   JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (R.ReceiptKey = RD.ReceiptKey)
      	   JOIN dbo.SKU WITH (NOLOCK) ON (RD.StorerKey = SKU.StorerKey AND RD.SKU = SKU.SKU)
      	WHERE R.StorerKey = @cStorerKey
      	   AND R.UserDefine05 = @cUDF05
         	AND SKU.Style = @cStyle
         	-- AND RD.BeforeReceivedQTY > 0
         	AND RD.UserDefine10 <> 'closed'
      	ORDER BY RD.EditDate DESC
      END  	
      
      -- Find pre-uploaded LOC not yet used
      IF @cSuggLOC = ''
      BEGIN
      	SELECT @cFacility = Facility
      	FROM dbo.Receipt WITH (NOLOCK)
      	WHERE ReceiptKey = @cReceiptKey
      	
      	SELECT TOP 1 
      	   @cSuggLOC = LOC.LOC
      	FROM dbo.LOC WITH (NOLOCK)
      	WHERE LOC.Putawayzone = @cUDF05
         	AND LOC.Facility = @cFacility
         	AND LOC.Status = 'HOLD'
         	AND NOT EXISTS( 
         	   SELECT TOP 1 1
            	FROM dbo.Receipt R WITH (NOLOCK)
            	   JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (R.ReceiptKey = RD.ReceiptKey)
            	WHERE R.StorerKey = @cStorerKey
            	   AND R.UserDefine05 = @cUDF05
         	      AND LOC.LOC = RD.ToLOC)
      	ORDER BY LOC.LogicalLocation
      END
      
      IF @cSuggLOC = ''
         SET @cSuggLOC = 'NO LOC'
   END
   
Quit:

END

SET QUOTED_IDENTIFIER OFF

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON rdt.rdt_607ExtPA11 TO NSQL
GO