SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: isp_CtnLabel01                                         */
/* Copyright      : LF Logistics                                           */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2023-04-26 1.0  yeekung  WMS-22237 Created                              */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_CtnLabel01] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cStorerKey       NVARCHAR( 15),
   @cByRef1          NVARCHAR( 20),
   @cByRef2          NVARCHAR( 20),
   @cByRef3          NVARCHAR( 20),
   @cByRef4          NVARCHAR( 20),
   @cByRef5          NVARCHAR( 20),
   @cByRef6          NVARCHAR( 20),
   @cByRef7          NVARCHAR( 20),
   @cByRef8          NVARCHAR( 20),
   @cByRef9          NVARCHAR( 20),
   @cByRef10         NVARCHAR( 20),
   @cPrintTemplate   NVARCHAR( MAX),
   @cPrintData       NVARCHAR( MAX) OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cCodePage        NVARCHAR( 50)  OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cParams1    NVARCHAR( 60)
          ,@cParams2    NVARCHAR( 60)
          ,@cParams3    NVARCHAR( 60)
          ,@cParams4    NVARCHAR( 60)
          ,@cParams5    NVARCHAR( 60)
          ,@cParams6    NVARCHAR( 60)
          ,@cParams7    NVARCHAR( 60)
          ,@cParams8    NVARCHAR( 60)
          ,@cParams9    NVARCHAR( 60)
          ,@cParams10    NVARCHAR( MAX)
          ,@cParams11   NVARCHAR( 60)
          ,@cParams12   NVARCHAR( 4000)
          ,@cParams13   NVARCHAR( 4000)
          ,@cParams14   NVARCHAR( 4000)
          ,@cParams15   NVARCHAR( 4000)
          ,@cCounter    NVARCHAR(2) ='1'
          ,@nMaxCount   INT
          ,@cExtraStorer   NVARCHAR(20)

   SET @cPrintData = @cPrintTemplate

   SELECT @cParams1 = UserDefine09,
          @cParams2 = ExternOrderKey,
          @cParams3 = C_Company,
          @cExtraStorer = billtokey,
          @cParams12 = buyerPo
   FROM ORDERS (NOLOCK)
   WHERE ORDERKEY = @cByRef2
      AND Storerkey = @cStorerKey

   
   SELECT @cParams4 = SUSR2,
          @cParams5 = CustomerGroupCode,
          @cParams6 = SUSR5,
          @cParams8 = Secondary,
          @cParams9 = SalesChannel
   FROM Storer (NOLOCK)
   WHERE  Storerkey = @cExtraStorer

   DECLARE @nPickQTY int
   DECLARE @nPackQTY INT

   SELECT @nPackQTY = SUM(qty)
   FROM PACKHEADER PH (NOLOCK)
      JOIN PACKDETAIL PD (NOLOCK) ON PH.pickslipno = PD.pickslipno AND PH.storerkey = PD.storerkey
   Where PH.Orderkey = @cByRef2
      AND PD.Storerkey = @cStorerkey

   SELECT @nMaxCount = MAX(cartonno)
   FROM PACKHEADER PH (NOLOCK)
      JOIN PACKDETAIL PD (NOLOCK) ON PH.pickslipno = PD.pickslipno AND PH.storerkey = PD.storerkey
   Where PH.Orderkey = @cByRef2
      AND PD.Storerkey = @cStorerkey


   SELECT @nPickQTY = SUM(qty)
   FROM PICKDetail (NOLOCK)
   Where orderkey = @cByRef2
      AND Storerkey = @cStorerkey

   IF @nPickQTY = @nPackQTY AND @nMaxCount = @cByRef3
      SET @cParams7 = 'Y'
   ELSE
      SET @cParams7 = 'N'

   DECLARE @cSKU NVARCHAR(20)
   DECLARE @cSKUDescr NVARCHAR(20)
   DECLARE @cQTY NVARCHAR(20)

   DECLARE @curPD CURSOR  
   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT TOP 10 SKU,SUM(qty)
   FROM PACKDETAIL (NOLOCK)
   WHERE Pickslipno = @cByRef1
      AND Storerkey = @cStorerKey
      AND Labelno = @cByRef4
   GROUP BY SKU

     
   OPEN @curPD  
   FETCH NEXT FROM @curPD INTO @cSKU, @cQTY
   WHILE @@FETCH_STATUS = 0  
   BEGIN
      
      SET @cParams10 = @cParams10 + 'SKU' + @cCounter +':' + @cSKU + ' QTY' +':' + @cQTY +  '\& '
      SET @cParams13 = @cParams13 +  @cSKU  +  '\& '

      SELECT @cSKUDescr =  SUBSTRING(descr,1,20) 
      FROM SKU (NOLOCK)
      WHERE SKU = @cSKU
         AND Storerkey = @cStorerkey 

      SET @cParams14 = @cParams14  +  @cSKUDescr  +  '\& '
      SET @cParams15 = @cParams15  +  @cQTY  +  '\& '

      SET @cCounter = CAST (@cCounter AS INT) + 1

      FETCH NEXT FROM @curPD INTO @cSKU, @cQTY
   END

   SET @cParams11 = @cByRef4

   SET @cPrintData = REPLACE (@cPrintData,'<Field01>',@cParams1)
   SET @cPrintData = REPLACE (@cPrintData,'<Field02>',@cParams2)
   SET @cPrintData = REPLACE (@cPrintData,'<Field03>',@cParams3)
   SET @cPrintData = REPLACE (@cPrintData,'<Field04>',@cParams4)
   SET @cPrintData = REPLACE (@cPrintData,'<Field05>',@cParams5)
   SET @cPrintData = REPLACE (@cPrintData,'<Field06>',@cParams6)
   SET @cPrintData = REPLACE (@cPrintData,'<Field07>',@cParams7)
   SET @cPrintData = REPLACE (@cPrintData,'<Field08>',@cParams8)
   SET @cPrintData = REPLACE (@cPrintData,'<Field09>',@cParams9)
   SET @cPrintData = REPLACE (@cPrintData,'<Field10>',@cParams10)
   SET @cPrintData = REPLACE (@cPrintData,'<Field11>',@cParams11)
   SET @cPrintData = REPLACE (@cPrintData,'<Field12>',@cParams12)
   SET @cPrintData = REPLACE (@cPrintData,'<Field13>',@cParams13)
   SET @cPrintData = REPLACE (@cPrintData,'<Field14>',@cParams14)
   SET @cPrintData = REPLACE (@cPrintData,'<Field15>',@cParams15)

   SET @cCodePage = '850'

   GOTO Quit

Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON dbo.isp_CtnLabel01 TO NSQL
GO


