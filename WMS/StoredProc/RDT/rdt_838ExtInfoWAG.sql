
/************************************************************************/
/* Store procedure: rdt_838ExtInfoWAG                                    */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev Author      Purposes                                  */
/* 21-05-2026 1.0 JRA432      Created                                   */
/************************************************************************/
CREATE OR ALTER   PROC [RDT].[rdt_838ExtInfoWAG] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR(3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR(5),
   @cStorerKey     NVARCHAR(15),
   @tVar           VariableTable READONLY,
   @cExtendedInfo  NVARCHAR(20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR(20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON

   DECLARE @cPackDtlDropID  NVARCHAR(20),
           @cLabelNo        NVARCHAR(20),
           @nCurrentQty     INT = 0,
           @nCurrentWeight  DECIMAL(18,3) = 0,
		   @nMaxWeight      DECIMAL(18,3),
      @cDeliveryService                NVARCHAR(30),
      @cDeliveryServiceList                NVARCHAR(10) = 'DELSERVICE',
      @cOrderKey                       NVARCHAR(10),
      @cPickSlipNo     NVARCHAR(10)

SELECT @cPackDtlDropID = Value FROM @tVar WHERE Variable = '@cPackDtlDropID'
SELECT @cLabelNo       = Value FROM @tVar WHERE Variable = '@cLabelNo'
SELECT @cPickSlipNo    = Value FROM @tVar WHERE Variable = '@cPickSlipNo'


   IF @nFunc = 838
   BEGIN
      -- Display on screens 1, 2, and 3
      IF @nStep IN (2, 3) OR @nAfterStep IN (1,3)/*@nStep IN (/*1,*/ 2, 3) --OR @nAfterStep IN (1, 2, 3)*/
      BEGIN
         IF @nInputKey = 1  -- ENTER
         BEGIN
      SELECT 
	     @cOrderKey = O.OrderKey,
	     @cDeliveryService = O.UserDefine02
      FROM dbo.PickHeader PH (NOLOCK)
	  JOIN dbo.Orders O (NOLOCK) ON O.StorerKey = PH.StorerKey AND O.OrderKey = PH.OrderKey
      WHERE PH.StorerKey = @cStorerKey 
      AND PH.PickHeaderKey = @cPickSlipNo
	  
	  SELECT 
			   --@cCarrier = UDF01,
			   --@cMaxWeight = UDF03, --Used for VARCHAR RDT MEssage
			   @nMaxWeight = ISNULL(SUM(TRY_CONVERT(DECIMAL(18,3), NULLIF(LTRIM(RTRIM(UDF03)), ''))), 0)
			FROM dbo.Codelkup (NOLOCK) 
			WHERE Storerkey = @cStorerKey
			AND ListName = @cDeliveryServiceList 
			AND Code = @cDeliveryService

            -- Calculate current carton weight
            IF @nMaxWeight <> 0 
            BEGIN
               WITH CurrentPack AS (
                  SELECT 
				     PD.sku AS sku,
                     SUM(PD.Qty) AS Qty,
                     S.[WEIGHT] AS SkuWeight,
                     CAST(S.[WEIGHT] AS DECIMAL(18,3)) * sum(pd.qty)  as CalcWgt 
                  FROM dbo.PackDetail PD (NOLOCK)
                  JOIN dbo.Sku S (NOLOCK) ON S.Storerkey = PD.Storerkey AND S.Sku = PD.SKU 
                  WHERE  pd.Storerkey = @cStorerKey  
                     AND DropId = @cPackDtlDropID
                  GROUP BY PD.Sku ,S.[WEIGHT]
                  ) 
                  SELECT 
                     @nCurrentWeight = SUM(CalcWgt)
                  FROM CurrentPack	

			   SET @nCurrentWeight = ISNULL(@nCurrentWeight, 0)
            -- Format the display string (max 20 chars)
               SET @cExtendedInfo = 'CUR:' + CAST(@nCurrentWeight AS VARCHAR(8))+'/MAX:'+ CAST(@nMaxWeight AS VARCHAR(8))

            END
         END
      END
   END
END

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON RDT.rdt_838ExtInfoWAG TO NSQL
GO
