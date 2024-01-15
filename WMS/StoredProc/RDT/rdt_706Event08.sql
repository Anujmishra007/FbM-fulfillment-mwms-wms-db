
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Store procedure: rdt_706Event08                                         */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2023-09-21 1.0  yeekung   WMS-24257    Created                          */
/***************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_706Event08] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cOption       NVARCHAR( 1),
   @cRetainValue  NVARCHAR( 10),
   @cTotalCaptr   INT           OUTPUT,
   @nStep         INT           OUTPUT,
   @nScn          INT           OUTPUT,
   @cLabel1       NVARCHAR( 20) OUTPUT,
   @cLabel2       NVARCHAR( 20) OUTPUT,
   @cLabel3       NVARCHAR( 20) OUTPUT,
   @cLabel4       NVARCHAR( 20) OUTPUT,
   @cLabel5       NVARCHAR( 20) OUTPUT,
   @cValue1       NVARCHAR( 60) OUTPUT,
   @cValue2       NVARCHAR( 60) OUTPUT,
   @cValue3       NVARCHAR( 60) OUTPUT,
   @cValue4       NVARCHAR( 60) OUTPUT,
   @cValue5       NVARCHAR( 60) OUTPUT,
   @cFieldAttr02  NVARCHAR( 1)  OUTPUT,
   @cFieldAttr04  NVARCHAR( 1)  OUTPUT,
   @cFieldAttr06  NVARCHAR( 1)  OUTPUT,
   @cFieldAttr08  NVARCHAR( 1)  OUTPUT,
   @cFieldAttr10  NVARCHAR( 1)  OUTPUT,
   @cExtendedinfo NVARCHAR( 20) OUTPUT,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cReceiptkey NVARCHAR(20)
   DECLARE @cSKU NVARCHAR(20)
   DECLARE @cSerialNo NVarchar(60)
   DECLARE @cExtendedOrderkey NVARCHAR(20)
   DECLARE @userdefine01 NVARCHAR(20)
   DECLARE @nCounter INT
   DECLARE @nTotalReceipt INT
   DECLARE @nTotalDataCapture INT
   DECLARE @nTotalSKUQty INT
   DECLARE @nTotalSKUDataCapture INT
   DECLARE @cErrmsg1 NVARCHAR(20)
   DECLARE @cErrmsg2 NVARCHAR(20)

   -- Parameter mapping
   SET @cReceiptkey = @cValue1
   SET @cSKU = @cValue2
   SET @cSerialNo = @cValue3

   SET @cFieldAttr08 = 'O'
   SET @cFieldAttr10 = 'O'

   IF  @nStep =2    --(yeekung04)
   BEGIN

      IF  @nInputKey='1' 
      BEGIN
         IF ISNULL(@cReceiptkey,'') =''
         BEGIN
            SET @nErrNo = 209801
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidReceipt
            GOTO Quit
         END


        IF NOT EXISTS (SELECT 1  FROM Receipt (NOLOCK)
                        WHERE Receiptkey = @cReceiptkey
                           AND Storerkey = @cStorerkey
                           AND DocType ='R')
         BEGIN
            SET @nErrNo = 209802
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidReceipt
            GOTO Quit
         END

		   SELECT @nCounter= COUNT(*)
         FROM rdt.rdtDataCapture (NOLOCK)
         WHERE V_string1 =@cReceiptkey
            AND Storerkey = @cStorerkey

         SET @nCounter = case when ISNULL(@nCounter,'') ='' THEN 0 ELSE @nCounter END

         SELECT @nTotalReceipt= SUM(RD.QtyExpected)
         FROM Receipt (NOLOCK) R
         JOIN ReceiptDetail (NOLOCK) RD ON R.Receiptkey = RD.Receiptkey
         JOIN SKU (NOLOCK) SKU ON RD.SKU = SKU.SKU AND SKU.Storerkey = SKU.Storerkey
         WHERE R.Receiptkey = @cReceiptkey
            AND R.Storerkey = @cStorerkey
            AND DocType ='R'
            AND SKUgroup <> N'礼品'

         IF @nTotalReceipt=@nCounter   --已扫描完成
         BEGIN
            SET @nErrNo = 209810
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ScanCompleted
            EXEC rdt.rdtSetFocusField @nMobile, 4
            GOTO Quit
         END

         IF ISNULL(@cValue4,'')=''
            SET @cValue4 = CAST(@nCounter AS NVARCHAR(5)) + '/' + CAST(@nTotalReceipt AS NVARCHAR(5))

		   IF  EXISTS (SELECT 1  FROM Receipt (NOLOCK)
                        WHERE Receiptkey = @cReceiptkey
                           AND Storerkey = @cStorerkey
                           AND ASNStatus ='CANC')
         BEGIN
            SET @nErrNo = 209811
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidReceipt
            GOTO Quit
         END                                                              --订单已取消

         IF ISNULL(@cSKU ,'')=''
         BEGIN
            SET @nErrNo = 209803
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKUISNULL
            EXEC rdt.rdtSetFocusField @nMobile, 4
            GOTO Quit
         END

         IF NOT EXISTS (SELECT 1  FROM Receipt (NOLOCK) R 
                  JOIN ReceiptDetail (NOLOCK) RD ON R.Receiptkey = RD.Receiptkey
                  WHERE R.Receiptkey = @cReceiptkey
                     AND R.Storerkey = @cStorerkey
                     AND DocType ='R'
                     AND SKU = @cSKU)
         BEGIN
            SET @nErrNo = 209812
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKUNOTExists ->无效SKU
            EXEC rdt.rdtSetFocusField @nMobile, 4
            GOTO Quit
         END

         IF  EXISTS (SELECT 1  FROM SKU (NOLOCK) 
                        WHERE  Storerkey = @cStorerkey
                          AND SKU = @cSKU
                          AND SKUgroup = N'礼品')
         BEGIN
            SET @nErrNo = 209808
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKUNOTREQSCN
            EXEC rdt.rdtSetFocusField @nMobile, 4
            GOTO Quit
         END

         SELECT @cExtendedOrderkey = RD.Userdefine01 
         FROM Receipt (NOLOCK) R
         JOIN ReceiptDetail (NOLOCK) RD ON R.Receiptkey = RD.Receiptkey
         WHERE R.Receiptkey = @cReceiptkey
            AND R.Storerkey = @cStorerkey
            AND DocType ='R'
            AND SKU = @cSKU

         SELECT @nTotalSKUQty = SUM(RD.QtyExpected)
         FROM Receipt (NOLOCK) R 
         JOIN ReceiptDetail (NOLOCK) RD ON R.Receiptkey = RD.Receiptkey
         WHERE R.Receiptkey = @cReceiptkey
            AND R.Storerkey = @cStorerkey
            AND DocType ='R'
            AND SKU = @cSKU

         SELECT @nTotalSKUDataCapture= SUM(CAST (V_String3 AS INT))
         FROM rdt.rdtDataCapture (NOLOCK)
         WHERE V_string1 =@cReceiptkey
            AND V_String2 = @cSKU
            AND Storerkey = @cStorerkey


         IF (@nTotalSKUDataCapture+1>@nTotalSKUQty)
         BEGIN
            SET @nErrNo = 209809
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ExceedQTY
            EXEC rdt.rdtSetFocusField @nMobile, 4
            GOTO Quit
         END

         IF ISNULL(@cSerialNo ,'')=''
         BEGIN
            SET @nErrNo = 209805
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNOISNULL
            EXEC rdt.rdtSetFocusField @nMobile, 6
            GOTO Quit
         END


         IF NOT EXISTS (SELECT 1
                    FROM SerialNo (nolock)
                    WHERE SKU = @cSKU 
                     AND Serialno = @cSerialno
                     AND Storerkey = @cStorerkey)
         BEGIN
            SET @nErrNo = 209806
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNONOTEXISTS
            SET @cValue2=@cSKU
            EXEC rdt.rdtSetFocusField @nMobile, 6
            GOTO Quit
         END


		  SELECT @userdefine01= UserDefine01
           FROM receipt (NOLOCK)
         WHERE ReceiptKey =@cReceiptkey
          AND Storerkey = @cStorerkey
		 
         IF EXISTS (SELECT 1
                     FROM rdt.rdtDataCapture (nolock)
                     WHERE V_String1 in (select ReceiptKey 
					                         from RECEIPT(nolock)
					                         where UserDefine01=@userdefine01
					                         and Storerkey = @cStorerkey )
                        AND V_String2 = @cSKU 
                        AND Serialno = @cSerialno
                        AND Storerkey = @cStorerkey)  --一张出库单退两次
         BEGIN
            SET @nErrNo = 209813
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNOScanned
            SET @cValue2=@cSKU
            EXEC rdt.rdtSetFocusField @nMobile, 6
            GOTO Quit
         END
      
         IF ISNULL(@nCounter,'')=0
            SET @nCounter =0

         SET @nCounter = @nCounter + 1
          INSERT INTO rdt.rdtDataCapture( StorerKey, Facility, V_String1,V_String2,serialno,V_String3,V_String4,V_String5) VALUES
            (@cStorerKey, @cFacility, @cReceiptkey,@cSKU,@cSerialno ,1,left(@cSerialno,20),substring(@cSerialno,21,20))   
            -- 增加 INSERT  V_String4/V_String5

         SET @cValue2=''
         SET @cValue3 =''
         SET @cValue4 = CAST(@nCounter AS NVARCHAR(5)) + '/' + CAST(@nTotalReceipt AS NVARCHAR(5))
         SET @cTotalCaptr   =@nCounter
         EXEC rdt.rdtSetFocusField @nMobile, 4

         
         SELECT @nTotalDataCapture = SUM (CAST(V_String3 AS INT))  
         FROM rdt.rdtDataCapture (NOLOCK) 
         WHERE V_String1 = @cReceiptkey
            AND StorerKey =@cStorerKey

         IF ( @nTotalReceipt = @nTotalDataCapture)
         BEGIN
            SET @cErrmsg1 = rdt.rdtgetmessage( 209813, @cLangCode, 'DSP') --SNOScanned N'序列号采集'
            SET @cErrmsg2 = rdt.rdtgetmessage( 209814, @cLangCode, 'DSP') --N'完成'
            EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @cErrmsg1,@cErrmsg2
            SET @nErrNo=0
            SET @cValue1=''
            EXEC rdt.rdtSetFocusField @nMobile, 2
         END

      END
      IF  @nInputKey='0'
      BEGIN
         SELECT @nTotalDataCapture = SUM (CAST(V_String3 AS INT))  
         FROM rdt.rdtDataCapture (NOLOCK) 
         WHERE V_String1 = @cReceiptkey
            AND StorerKey =@cStorerKey

         SELECT @nTotalReceipt = SUM(QtyExpected)  
         FROM Receipt (NOLOCK) R 
         JOIN ReceiptDetail (NOLOCK) RD ON R.Receiptkey = RD.Receiptkey
         WHERE R.Receiptkey = @cReceiptkey
            AND R.Storerkey = @cStorerkey
            AND DocType ='R'

         IF ( @nTotalReceipt <> @nTotalDataCapture)
         BEGIN
            SET @cErrmsg1 = rdt.rdtgetmessage( 209815, @cLangCode, 'DSP') --N'序列号采集'
            SET @cErrmsg2 = rdt.rdtgetmessage( 209816, @cLangCode, 'DSP')--N'未完成'
            EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @cErrmsg1,@cErrmsg2
            SET @nErrNo=0
         END
      END

   QUIT:
      
END


