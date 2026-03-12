SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_898ExtVal13                                        */
/* Copyright      : Maersk WMS                                             */
/* Customer       : Granite                                                */
/*                                                                         */
/* Date       Rev    Author     Purposes                                   */
/* 2025-11-21 1.0.0  Dennis     FCR-8723 Sku validation                    */
/* 2026-02-25 1.1.0  NickT      FCR-10628 Add validation on step 2, 3      */
/***************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_898ExtVal13]
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@nStep       INT
   ,@nInputKey   INT
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cLOC        NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@cLottable01 NVARCHAR( 18)
   ,@cLottable02 NVARCHAR( 18)
   ,@cLottable03 NVARCHAR( 18)
   ,@dLottable04 DATETIME
   ,@cUCC        NVARCHAR( 20)
   ,@cSKU        NVARCHAR( 20)
   ,@nQTY        INT
   ,@cParam1     NVARCHAR( 20) OUTPUT
   ,@cParam2     NVARCHAR( 20) OUTPUT
   ,@cParam3     NVARCHAR( 20) OUTPUT
   ,@cParam4     NVARCHAR( 20) OUTPUT
   ,@cParam5     NVARCHAR( 20) OUTPUT
   ,@cOption     NVARCHAR( 1)
   ,@nErrNo      INT       OUTPUT
   ,@cErrMsg     NVARCHAR( 20) OUTPUT 
AS
BEGIN
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE
      @cFacility           NVARCHAR( 5),  
      @cStorerKey          NVARCHAR( 15),
      @cDocType            NVARCHAR( 1),
      @cRDLottable03       NVARCHAR( 18),
      @cLocGroup           NVARCHAR( 20),
      @cExpectedLocGroup   NVARCHAR( 20),
      @cDropIDStatus       NVARCHAR( 10)

   SELECT @cStorerKey = StorerKey,
      @cFacility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK) 
   WHERE Mobile = @nMobile 

   -- Get DOCTYPE from Receipt
   SELECT @cDocType = TRIM(ISNULL(DOCTYPE, ''))
   FROM dbo.Receipt WITH (NOLOCK)
   WHERE ReceiptKey = @cReceiptKey
      AND StorerKey = @cStorerKey
      AND Facility = @cFacility

   IF @nFunc = 898
   BEGIN
      IF @nStep = 1  -- ASN 
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS(SELECT 1
               FROM dbo.RECEIPT WITH(NOLOCK) 
               WHERE ReceiptKey = @cReceiptKey 
                  AND Facility = @cFacility
                  AND StorerKey = @cStorerKey 
                  AND ISNULL(UserDefine06, '') = '')
            BEGIN
               SET @nErrNo = 259704 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- OnLOT not triggered
               GOTO Quit
            END
         END
      END
      ELSE IF @nStep = 2  -- TO LOC
      BEGIN
         IF @nInputKey = 1
         BEGIN
            -- Only apply validations when DOCTYPE = 'A'
            IF @cDocType <> 'A'
               GOTO Quit

            -- Get the first line item's Lottable03 from RECEIPTDETAIL
            SELECT TOP 1 @cRDLottable03 = TRIM(Lottable03)
            FROM dbo.ReceiptDetail WITH (NOLOCK)
            WHERE ReceiptKey = @cReceiptKey
               AND StorerKey = @cStorerKey
            ORDER BY ReceiptLineNumber

            -- Get the LocationGroup of the scanned LOC
            SELECT @cLocGroup = TRIM(ISNULL(LocationGroup, ''))
            FROM dbo.LOC WITH (NOLOCK)
            WHERE Loc = @cLOC

            -- Determine expected LocationGroup based on Lottable03
            IF @cRDLottable03 <> ''
               SET @cExpectedLocGroup = 'B2B_STAGE'
            ELSE
               SET @cExpectedLocGroup = 'B2C_STAGE'

            -- Validate LocationGroup
            IF @cLocGroup <> @cExpectedLocGroup
            BEGIN
               SET @nErrNo = 259701
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Wrong Loc Group
               GOTO Quit
            END
         END
      END
      ELSE IF @nStep = 3  -- TO ID
      BEGIN
         IF @nInputKey = 1
         BEGIN
            -- Only apply validations when DOCTYPE = 'A'
            IF @cDocType <> 'A'
               GOTO Quit

            -- Check if DROPID exists and is closed (Status = 9)
            SELECT @cDropIDStatus = Status
            FROM dbo.DROPID WITH (NOLOCK)
            WHERE DropID = @cToID

            IF @cDropIDStatus = '9'
            BEGIN
               SET @nErrNo = 259702
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pallet Closed. Use different pallet
               GOTO Quit
            END
         END
      END
      ELSE IF @nStep = 8 -- SKU
      BEGIN 
         IF @nInputKey = 1
         BEGIN
            IF EXISTS(SELECT 1 FROM RECEIPT WHERE ReceiptKey = @cReceiptKey AND StorerKey = @cStorerKey AND DocType ='R')
            BEGIN
               DECLARE @cStyle NVARCHAR(20)

               SELECT @cStyle = STYLE
               FROM dbo.SKU SKU WITH(NOLOCK) 
               WHERE SKU.SKU = @cSKU 
                  AND SKU.StorerKey = @cStorerKey

               IF EXISTS(
                  SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
                  WHERE RD.ReceiptKey = @cReceiptKey 
                     AND RD.StorerKey = @cStorerKey
               ) AND NOT EXISTS(
                  SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
                  WHERE RD.ReceiptKey = @cReceiptKey 
                     AND RD.StorerKey = @cStorerKey
                     AND RD.UserDefine10 = @cStyle
               )
               BEGIN
                  SET @nErrNo = 225305 
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- SKUStyleDoesNotMatch
                  GOTO Quit
               END
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

GRANT EXECUTE ON rdt.rdt_898ExtVal13 TO NSQL
GO