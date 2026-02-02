SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1841ExtInfo06                                   */
/* Copyright: Maersk                                                    */
/* Customer: COLUMBIA SPORTSWEAR CO                                     */
/* Purpose: Display CartonID                                            */
/*                                                                      */
/* Called from: rdt_fncPrePalletizeSort                                 */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2025-11-28  1.0  NickT      FCR-9027. Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1841ExtInfo06] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5), 
   @cStorerKey     NVARCHAR( 15),
   @cReceiptKey    NVARCHAR( 10),
   @cLane          NVARCHAR( 10),
   @cUCC           NVARCHAR( 20),
   @cToID          NVARCHAR( 18),
   @cSKU           NVARCHAR( 20),
   @nQty           INT,
   @cOption        NVARCHAR( 1),               
   @cPosition      NVARCHAR( 20),
   @tExtInfoVar    VariableTable READONLY, 
   @cExtendedInfo        NVARCHAR( 20) OUTPUT

)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nCurrentScn            INT,
      @nCurrentStep           INT,
      @cCartonID              NVARCHAR( 20)

   SELECT 
      @nCurrentStep        = Step,
      @nCurrentScn         = Scn
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile     = @nMobile
   
   IF @nCurrentStep = 99
   BEGIN
      IF @nCurrentScn = 6705  -- Carton DI screen
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SELECT @cCartonID = Value FROM @tExtInfoVar WHERE Variable = '@cCartonID'

            SET @cExtendedInfo = 'CartonID: ' + @cCartonID
         END
      END
   END

   Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1841ExtInfo06 TO NSQL
GO