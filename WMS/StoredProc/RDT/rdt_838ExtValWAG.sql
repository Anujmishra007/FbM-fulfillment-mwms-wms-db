
/************************************************************************/
/* Store procedure: rdt_838ExtValWAG                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-05-21 1.0  JRA432   Created Whiteaway implementation           */
/************************************************************************/

CREATE OR ALTER    PROCEDURE [RDT].[rdt_838ExtValWAG] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFacility       NVARCHAR( 5),
   @cStorerKey      NVARCHAR( 15),
   @cPickSlipNo     NVARCHAR( 10),
   @cFromDropID     NVARCHAR( 20),
   @nCartonNo       INT,
   @cLabelNo        NVARCHAR( 20),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cUCCNo          NVARCHAR( 20),
   @cCartonType     NVARCHAR( 10),
   @cCube           NVARCHAR( 10),
   @cWeight         NVARCHAR( 10),
   @cRefNo          NVARCHAR( 20),
   @cSerialNo       NVARCHAR( 30),
   @nSerialQTY      INT,
   @cOption         NVARCHAR( 1),
   @cPackDtlRefNo   NVARCHAR( 20),
   @cPackDtlRefNo2  NVARCHAR( 20),
   @cPackDtlUPC     NVARCHAR( 30),
   @cPackDtlDropID  NVARCHAR( 20),
   @cPackData1      NVARCHAR( 30),
   @cPackData2      NVARCHAR( 30),
   @cPackData3      NVARCHAR( 30),
   @nErrNo          INT            OUTPUT,
   @cErrMsg         NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cOrderKey                       NVARCHAR(10),
      @cDeliveryServiceList                NVARCHAR(10) = 'DELSERVICE',
      @cDeliveryService                NVARCHAR(30),
      @cCarrier                       NVARCHAR(30),
      @cMaxWeight                       NVARCHAR(30), -- Used For RDT Message
      @nMaxWeight                       FLOAT,
      @nCurrentWeight                       FLOAT,
      @nRepackWeight                       FLOAT,
	  @cLabelPrinter					NVARCHAR(10),
	  @cPaperPrinter					NVARCHAR(10)

      
   IF @nFunc = 838
   BEGIN
      SELECT 
	     @cOrderKey = O.OrderKey,
	     @cDeliveryService = O.UserDefine02
      FROM dbo.PickHeader PH (NOLOCK)
	   JOIN dbo.Orders O (NOLOCK) ON O.StorerKey = PH.StorerKey AND O.OrderKey = PH.OrderKey
      WHERE PH.StorerKey = @cStorerKey 
      AND PH.PickHeaderKey = @cPickSlipNo

      IF @nStep = 1 
	   BEGIN
	     IF @nInputKey = 1 
		  BEGIN
		    SELECT 
		        @cLabelPrinter = Printer
		       ,@cPaperPrinter = Printer_Paper 
		    FROM RDT.RdtMobRec 
		    WHERE Mobile = @nMobile

			 IF ISNULL(@cLabelPrinter,'') = '' or ISNULL(@cPaperPrinter,'') = '' 
            BEGIN --To Drop ID already used to pack a different Order
               SET @nErrNo = 60452
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, N'DSP') -- No Login Printer
               GOTO Quit
            END
		 END
         IF ISNULL(@cPackDtlDropID,'') = ''
         BEGIN --User must enter To Drop ID
            SET @nErrNo = 267001
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, N'DSP') -- Need ToDropID
            GOTO Quit
         END
         IF EXISTS (SELECT 1 FROM dbo.PackDetail PD (NOLOCK)
                   JOIN PackHeader PH (NOLOCK) ON PH.Storerkey = PD.Storerkey AND PH.PickSlipNo = PD.PickSlipNo
                   WHERE PD.Storerkey = @cStorerKey
                   AND PD.DropID = @cPackDtlDropID
                   AND PH.OrderKey <> @cOrderKey)
         BEGIN --To Drop ID already used to pack a different Order
            SET @nErrNo = 267002
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, N'DSP') -- Bad ToDropID
            GOTO Quit
         END
      END --Step1
	  IF @nStep = 3 --SKU/Qty Packing
	  BEGIN
	     IF @nInputKey = 1
		 BEGIN
			--Get Delivery Service Restictions from Codelkup
		    SELECT 
			   --@cCarrier = UDF01,
			   --@cMaxWeight = UDF03, --Used for VARCHAR RDT MEssage
			   @nMaxWeight = ISNULL(SUM(TRY_CONVERT(DECIMAL(18,4), NULLIF(LTRIM(RTRIM(UDF03)), ''))), 0)
			FROM dbo.Codelkup (NOLOCK) 
			WHERE Storerkey = @cStorerKey
			AND ListName = @cDeliveryServiceList 
			AND Code = @cDeliveryService

			IF @nMaxWeight > 0
			BEGIN
			   -- Get weight of packing already done for DropID
               WITH CurrentPack AS (
                  SELECT 
				     PD.sku AS sku,
                     SUM(PD.Qty) AS Qty,
                     S.[WEIGHT] AS SkuWeight,
                     CAST(S.[WEIGHT] * sum(pd.qty)AS DECIMAL(18,4))  as CalcWgt 
                  FROM dbo.PackDetail PD (NOLOCK)
                  JOIN dbo.Sku S (NOLOCK) ON S.Storerkey = PD.Storerkey AND S.Sku = PD.SKU 
                  WHERE  pd.Storerkey = @cStorerKey  
                     AND DropId = @cPackDtlDropID
                  GROUP BY PD.Sku ,S.[WEIGHT]
                  ) 
                  SELECT 
                     @nCurrentWeight = SUM(CalcWgt)
                  FROM CurrentPack	

			   --IF no weight then First pack to DropID so set 0
			   SET @nCurrentWeight = ISNULL(@nCurrentWeight, 0)

			   --Get weight of current packing into dropID
	           SELECT 
			      @nRepackWeight = CAST(S.[Weight] * @nQTY AS DECIMAL(18,4))
               FROM dbo.Sku S (NOLOCK)
               WHERE S.Storerkey = @cStorerKey
               AND S.Sku = @cSKU

              IF @nCurrentWeight + @nRepackWeight > @nMaxWeight
              BEGIN 
                 SET @nErrNo = 1
                 SET @cErrMsg = 'Wgt: '+CONVERT(NVARCHAR, NULLIF(LTRIM(RTRIM(@nCurrentWeight+@nRepackWeight)), ''))+'/'+CONVERT(NVARCHAR, NULLIF(LTRIM(RTRIM(@nMaxWeight)), '')) 
                 GOTO Quit
              END
		   END
       END
	  END
   END
   GOTO Quit
Quit:
END 

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON RDT.rdt_838ExtValWAG TO NSQL
GO
