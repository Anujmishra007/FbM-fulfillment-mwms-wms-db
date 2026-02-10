SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_627ExtInfo02                                    */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: Page Industries - Get additional details (FCR-9890)         */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-01-30 1.0  NYE018     FCR-9890 Created to fetch remaining fields*/
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_627ExtInfo02] (
   @nMobile       INT,
   @nFunc         INT, 
   @cLangCode     NVARCHAR( 3), 
   @nStep         INT, 
   @nInputKey     INT, 
   @cStorerkey    NVARCHAR( 15), 
   @cSKU          NVARCHAR( 20),
   @cID           NVARCHAR( 20),
   @cSerialNo     NVARCHAR( 20),
   @cExtendedInfo1 NVARCHAR( 20) OUTPUT,
   @cExtendedInfo2 NVARCHAR( 20) OUTPUT,
   @cExtendedInfo3 NVARCHAR( 20) OUTPUT,
   @cExtendedInfo4 NVARCHAR( 20) OUTPUT,
   @cExtendedInfo5 NVARCHAR( 20) OUTPUT,
   @cExtendedInfo6 NVARCHAR( 20) OUTPUT,
   @nErrNo        INT           OUTPUT, 
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLot           NVARCHAR(10),
           @cOrderKey      NVARCHAR(10),
           @cSusr3         NVARCHAR(20),
           @cExternReceiptKey NVARCHAR(50),
           @cExternOrderKey   NVARCHAR(50),
           @cLottable01    NVARCHAR(20),
           @cPickSlipNo    NVARCHAR(10),
           @bInPackSerial  BIT,
           @cLabelNo       NVARCHAR(18)

   SELECT @cExtendedInfo1 = '', @cExtendedInfo2 = '', @cExtendedInfo3 = '', 
          @cExtendedInfo4 = '', @cExtendedInfo5 = '', @cExtendedInfo6 = ''

   SET @bInPackSerial = 0

   IF @nFunc = 627 -- Serial No
   BEGIN
      IF @nStep = 1 -- SERIALNO
      BEGIN
         -- 0. Get Basic SerialNo Info
         SELECT TOP 1 
            @cLot = Lot,
            @cOrderKey = OrderKey
         FROM dbo.SERIALNO WITH (NOLOCK)
         WHERE SerialNo = @cSerialNo 
         AND   SKU = @cSKU
         ORDER BY SerialNoKey DESC  

         -- 1. Check if in PACKSERIALNO (Requirement: Determine logic path)
         SELECT TOP 1 
             @bInPackSerial = 1,
             @cPickSlipNo = PickSlipNo,
             @cLabelNo = LabelNo
         FROM dbo.PACKSERIALNO WITH (NOLOCK)
         WHERE SerialNo = @cSerialNo
           AND SKU = @cSKU
         ORDER BY PackSerialNoKey DESC

         -- If in PACKSERIALNO, ID should be derived from LabelNo
         IF @bInPackSerial = 1 AND ISNULL(@cLabelNo, '') <> ''
         BEGIN
             SET @cID = @cLabelNo
             UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET
                V_ID = @cID
             WHERE Mobile = @nMobile
         END
         ELSE
         BEGIN
             -- Else, ID remains as passed in parameter
             UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET
                V_ID = @cID
             WHERE Mobile = @nMobile
         END

         -- 2. FETCH DATA

         -- SKU.SUSR3
         SELECT @cSusr3 = SUSR3
         FROM dbo.SKU WITH (NOLOCK) 
         WHERE StorerKey = @cStorerKey
         AND   SKU = @cSKU

         -- LOTATTRIBUTE.Lottable01
         -- Requirement: LOTATTRIBUTE.LOT = SERIALNO.LOT AND LOTATTRIBUTE.StorerKey = @StorerKey
         IF ISNULL(@cLot, '') <> ''
         BEGIN
             SELECT @cLottable01 = Lottable01
             FROM dbo.LOTATTRIBUTE WITH (NOLOCK)
             WHERE Lot = @cLot
             AND   StorerKey = @cStorerKey
             AND   SKU = @cSKU 
         END
         ELSE
         BEGIN
             SET @cLottable01 = ''
         END

         -- ASN: RECEIPT.ExternReceiptKey
         -- Requirement: RECEIPT.ReceiptKey = RECEIPTSERIALNO.ReceiptKey AND RECEIPTSERIALNO.SerialNo = SERIALNO.SerialNo
         SELECT TOP 1 
             @cExternReceiptKey = R.ExternReceiptKey
         FROM dbo.RECEIPT R WITH (NOLOCK)
         JOIN dbo.RECEIPTSERIALNO RSN WITH (NOLOCK) ON R.ReceiptKey = RSN.ReceiptKey
         WHERE RSN.SerialNo = @cSerialNo
           AND RSN.SKU = @cSKU
         ORDER BY RSN.ReceiptSerialNoKey DESC

         -- ORD: ORDERS.ExternOrderKey
         SELECT TOP 1
             @cExternOrderKey = O.ExternOrderKey
            FROM dbo.ORDERS O WITH (NOLOCK)
            JOIN dbo.PACKHEADER PH WITH (NOLOCK) ON O.OrderKey = PH.OrderKey
            JOIN dbo.PACKSERIALNO PSN WITH (NOLOCK) ON PH.PickSlipNo = PSN.PickSlipNo
            WHERE PSN.SerialNo = @cSerialNo
           AND PSN.SKU = @cSKU

         -- 3. FORMAT OUTPUT (Truncated to 20 chars to fit screen field)
         
         -- ASN:<ExternReceiptKey>
         SET @cExtendedInfo1 = 'ASN:' + ISNULL(@cExternReceiptKey, '')
         SET @cExtendedInfo1 = LEFT(@cExtendedInfo1, 20)

         -- ORD:<ExternOrderKey>
         SET @cExtendedInfo2 = 'ORD:' + ISNULL(@cExternOrderKey, '')
         SET @cExtendedInfo2 = LEFT(@cExtendedInfo2, 20)

         -- L1:<Lottable01> - <SUSR3>
         SET @cExtendedInfo3 = 'L1:' + ISNULL(@cLottable01, '')
         IF ISNULL(@cSusr3, '') <> ''
         BEGIN
             SET @cExtendedInfo3 = @cExtendedInfo3 + '-' + @cSusr3
         END
         SET @cExtendedInfo3 = LEFT(@cExtendedInfo3, 20)

      END
   END

GO

GRANT EXECUTE ON [RDT].[rdt_627ExtInfo02] TO NSQL
GO