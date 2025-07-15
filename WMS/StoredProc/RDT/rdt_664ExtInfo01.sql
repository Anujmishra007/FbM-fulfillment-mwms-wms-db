
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_664ExtInfo01                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author  Purposes                                     */
/* 2025-05-28 1.0  Dennis  FCR-3803 Created                             */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_664ExtInfo01]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cID             NVARCHAR( 18),              
   @cFromLOC        NVARCHAR( 10),              
   @cToLOC          NVARCHAR( 10),              
   @cSKU            NVARCHAR( 20),              
   @cReceiptKey     NVARCHAR( 10),              
   @cReceiptLineNumber NVARCHAR( 10),        
   @cOutText1       NVARCHAR( 20) OUTPUT,     
   @cOutText2       NVARCHAR( 20) OUTPUT,     
   @cOutText3       NVARCHAR( 20) OUTPUT,
   @nErrNo          INT OUTPUT,              
   @cErrMsg         NVARCHAR( 20) OUTPUT      
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cExtendedField01  NVARCHAR( 30) = ''

   IF @nFunc = 664 -- Putaway by SKU
   BEGIN
      IF @nStep = 3 --Toloc
      BEGIN
         DECLARE @cSuggLoc NVARCHAR( 10) = ''

         SELECT TOP 1 @cSuggLoc = ISNULL(placeofloading,'')
         FROM  dbo.RECEIPTDETAIL rd  (nolock) 
         LEFT JOIN dbo.Orders Orders (nolock) ON  rd.ExternReceiptKey = Orders.ExternOrderKey AND RD.UserDefine02= Orders.ConsigneeKey AND RD.StorerKey=ORDERS.StorerKey
         LEFT JOIN dbo.MBOL MBOL (nolock) ON  Orders.MBOLKey = MBOL.MbolKey
         WHERE rd.StorerKey = @cStorerKey
            AND rd.ToID = @cID
            AND rd.ToLoc = @cFromLoc
            AND BeforeReceivedQty > 0

         SET @cOutText1 = CASE WHEN ISNULL(@cSuggLoc,'') = '' THEN '' ELSE CONCAT('SuggLoc:',@cSuggLoc) END 
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_664ExtInfo01 TO NSQL
GO
