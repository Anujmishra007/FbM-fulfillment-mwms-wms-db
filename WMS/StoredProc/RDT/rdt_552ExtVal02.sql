SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_552ExtVal02                                     */
/* Copyright      : Maersk                                              */
/* Customer       : Levis UAE                                           */
/*                                                                      */
/* Purpose: Verify Condition code                                       */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-12-17 1.0  NickT    FCR-9545 Created                            */
/************************************************************************/

CREATE OR ALTER PROCEDURE [rdt].[rdt_552ExtVal02]
   @nMobile         INT, 
   @nFunc           INT, 
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT, 
   @nInputKey       INT, 
   @cFacility       NVARCHAR( 5),
   @cStorerKey      NVARCHAR( 15),
   @cZone           NVARCHAR( 10),
   @cReceiptKey     NVARCHAR( 10),
   @cPOKey          NVARCHAR( 10),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cLottable01     NVARCHAR( 18),
   @cLottable02     NVARCHAR( 18),
   @cLottable03     NVARCHAR( 18),
   @dLottable04     DATETIME,
   @cConditionCode  NVARCHAR( 10),
   @cSubReason      NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @cToID           NVARCHAR( 18),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
       
   IF @nFunc = 552 -- Return
   BEGIN
      IF @nStep = 3 -- QTY screen
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF ISNULL(@cConditionCode, '') = ''
            BEGIN
               SET @nErrNo = 254151
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Condition Code is needed
               EXEC rdt.rdtSetFocusField @nMobile, 10 -- CondCode
               GOTO Quit
            END

            IF NOT EXISTS(SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                  WHERE Listname = 'ASNREASON'
                     AND Code = @cConditionCode
                     AND StorerKey = @cStorerKey)
            BEGIN
               SET @nErrNo = 254152
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Bad Condition Code
               EXEC rdt.rdtSetFocusField @nMobile, 10 -- CondCode
               GOTO Quit
            END
         END
      END
   END

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_552ExtVal02] TO NSQL
GO
