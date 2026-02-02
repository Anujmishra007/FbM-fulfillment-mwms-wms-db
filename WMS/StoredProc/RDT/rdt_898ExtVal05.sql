SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_898ExtVal05                                        */
/* Copyright      : Maersk WMS                                             */
/* Customer       : Granite                                                */
/*                                                                         */
/* Date       Rev    Author     Purposes                                   */
/* 2024-10-01 1.0    NLT013     FCR-926 Created                            */
/* 2025-02-13 1.1.0  ASK138     FCR-2724                                   */
/* 2025-05-19 1.2.0  Dennis     FCR-4531                                   */
/* 2025-05-31 1.3.0  NickT      UWP-35355 Add additional validation        */
/* 2025-07-23 1.4.0  Dennis     FCR-6157                                   */
/* 2025-08-14 1.5.0  Dennis     FCR-6157 Multi PO only when Return         */
/***************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_898ExtVal05]
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
      @cFacility        NVARCHAR( 5),  
      @cStorerKey       NVARCHAR( 15)

   SELECT @cStorerKey = StorerKey,
      @cFacility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK) 
   WHERE Mobile = @nMobile 

   IF @nFunc = 898
   BEGIN
      -- FCR-2724 - OnLOT Validation  
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
               SET @nErrNo = 225302 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- OnLOT not triggered
               GOTO Quit
            END

            IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL RD (NOLOCK)
                     JOIN dbo.RECEIPT R (NOLOCK) ON RD.ReceiptKey = R.ReceiptKey AND R.StorerKey = RD.StorerKey
                     WHERE RD.StorerKey = @cStorerKey
                     AND RD.ReceiptKey = @cReceiptKey
                     AND R.DOCTYPE = 'R'
                     GROUP BY RD.ReceiptKey
                     HAVING COUNT(DISTINCT RD.POKey) > 1 )
            BEGIN
               SET @nErrNo = 225306
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- MultiPOInReceipt
               GOTO Quit
            END

            IF EXISTS (SELECT 1
               FROM dbo.Receipt R WITH (NOLOCK)
               JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON R.ReceiptKey = RD.ReceiptKey
               JOIN dbo.PO PO WITH (NOLOCK) ON RD.POKey = PO.POKey
               WHERE R.ReceiptKey = @cReceiptkey
                  AND R.Facility = @cFacility
                  AND R.StorerKey = @cStorerKey 
                  AND R.DOCTYPE = 'R'
                  AND PO.POType <> 'RETURN' 
                  )
            BEGIN
               SET @nErrNo = 225307
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- POTypeNotReturn
               GOTO Quit
            END

            IF EXISTS(SELECT 1
               FROM dbo.RECEIPT RT WITH(NOLOCK) 
               INNER JOIN dbo.RECEIPTDETAIL RTD WITH(NOLOCK) 
                  ON RT.StorerKey = RTD.StorerKey AND RT.ReceiptKey = RTD.ReceiptKey
               INNER JOIN dbo.PO WITH(NOLOCK)
                  ON RTD.StorerKey = PO.StorerKey AND RTD.ExternPoKey = PO.ExternPoKey
               WHERE RT.ReceiptKey = @cReceiptKey 
                  AND RT.Facility = @cFacility
                  AND RT.StorerKey = @cStorerKey 
                  AND po.externstatus = '9')
            BEGIN
               SET @nErrNo = 225304 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- POClosed
               GOTO Quit
            END

            IF EXISTS(SELECT 1
               FROM dbo.Receipt R WITH (NOLOCK)
               WHERE R.ReceiptKey = @cReceiptkey
                  AND R.Facility = @cFacility
                  AND R.StorerKey = @cStorerKey 
                  AND R.DOCTYPE = 'R'
                  AND R.UserDefine06 < GETDATE())
            BEGIN
               SET @nErrNo = 225305 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Cancel Date Past
               GOTO Quit
            END
         END
      END
      ELSE IF @nStep = 2  -- To loc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF NOT EXISTS(SELECT 1
               FROM dbo.LOC WITH(NOLOCK) 
               WHERE Loc = @cLOC 
                  AND PutAwayZone = 'IBDOOR'
                  AND HOSTWHCODE = 'QI')
            BEGIN
               SET @nErrNo = 225303 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Loc
               GOTO Quit
            END
         END
      END
      ELSE IF @nStep = 3  -- To ID
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS(SELECT 1
               FROM RDT.RDTSTDEVENTLOG WITH(NOLOCK) 
               WHERE FunctionID = @nFunc 
                  AND Facility = @cFacility
                  AND StorerKey = @cStorerKey 
                  AND ID = @cToID
                  AND ISNULL(Refno1, '') = 'CLOSE')
            BEGIN
               SET @nErrNo = 225301 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToIDClosed
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

GRANT EXECUTE ON rdt.rdt_898ExtVal05 TO NSQL
GO