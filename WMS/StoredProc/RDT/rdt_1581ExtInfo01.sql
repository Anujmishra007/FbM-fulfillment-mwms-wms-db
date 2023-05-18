
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1581ExtInfo01                                      */
/* Copyright      : LFLogistics                                            */
/*                                                                         */
/* Purpose: Display Count                                                  */
/*                                                                         */
/* Date       Rev  Author     Purposes                                     */
/* 2023-05-08 1.0  yeekung    WMS-22500 Created                            */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [rdt].[rdt_1581ExtInfo01] (
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nAfterStep      INT 
   ,@nInputKey       INT 
   ,@cFacility       NVARCHAR( 5)
   ,@cStorerKey      NVARCHAR( 15) 
   ,@cReceiptKey     NVARCHAR( 10) 
   ,@cPOKey          NVARCHAR( 10) 
   ,@cRefNo          NVARCHAR( 20) 
   ,@cToLOC          NVARCHAR( 10) 
   ,@cToID           NVARCHAR( 18) 
   ,@cLottable01     NVARCHAR( 18) 
   ,@cLottable02     NVARCHAR( 18) 
   ,@cLottable03     NVARCHAR( 18) 
   ,@dLottable04     DATETIME 
   ,@cSKU            NVARCHAR( 20) 
   ,@nQTY            INT 
   ,@tVar            VariableTable READONLY
   ,@cExtendedInfo   NVARCHAR( 20) OUTPUT 
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nCartonQTY INT

   IF @nFunc = 1581 -- Piece receiving
   BEGIN
      IF @nAfterStep = 5 -- SKU, QTY
      BEGIN
         SELECT @cExtendedInfo=@cReceiptKey+@cToID+@cLottable03
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [rdt].[rdt_1581ExtInfo01] TO [NSQL]
GO
