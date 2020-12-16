IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[fnc_GetPicklsipNo]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[fnc_GetPicklsipNo]
GO

/****** Object:  StoredProcedure [API].[fnc_GetPicklsipNo]    Script Date: 6/3/2020 4:49:42 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/  
/* Store procedure: fnc_GetPicklsipNo                                         */  
/* Copyright      : LFLogistics                                               */  
/*                                                                            */  
/* Date         Rev  Author     Purposes                                      */  
/* 2020-04-20   1.0  Chermaine  Created                                       */  
/******************************************************************************/  
  
CREATE PROC [API].[fnc_GetPicklsipNo] (  
   @cStorerKey    NVARCHAR( 15),
   @cFacility     NVARCHAR( 5),
   @nFunc         INT,  
   @cLangCode     NVARCHAR( 3),  
   @cScanNo       NVARCHAR( 30), 
   @cType         NVARCHAR( 30),
   @cUserName      NVARCHAR( 30),
   @jResult       NVARCHAR( MAX) OUTPUT,  
   @b_Success     INT = 1  OUTPUT,  
   @n_Err         INT = 0  OUTPUT,  
   @c_ErrMsg      NVARCHAR( 255) = ''  OUTPUT,
   @cSelectAll    NVARCHAR( 1) = '0'
   
)  
AS  
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  

DECLARE   
	--@cStorerKey    NVARCHAR( 15),
 --  @cFacility     NVARCHAR( 5),
 --  @nFunc         INT,  
 --  @cLangCode     NVARCHAR( 3),  
 --  @cScanNo       NVARCHAR( 30), 
 --  @cType         NVARCHAR( 30),
 --  @userName      NVARCHAR( 30),
   
   @cScanNoType   NVARCHAR( 30),
   @cPickSlipNo   NVARCHAR( 30),
   @cDropID       NVARCHAR( 30),    
   @cOrderKey     NVARCHAR( 10),  
   @cLoadKey      NVARCHAR( 10),  
   @cZone         NVARCHAR( 18),  
   @cLot          NVARCHAR( 30),
   @EcomSingle    NVARCHAR( 1),
   @CalOrderSKU   NVARCHAR( 1),
   @cDynamicRightName1  NVARCHAR( 30),
   @cDynamicRightValue1 NVARCHAR( 30),
   @b2bProcess    NVARCHAR( 1),
   @cEcomPickslipSP     NVARCHAR( 30),
   @pickSkuDetailJson   NVARCHAR( MAX),
   @cSQL          NVARCHAR( MAX)
   
   
SET @EcomSingle = '0' 
SET @CalOrderSKU = 'N'
SET @b2bProcess = '1'
   
--DECLARE @pickSKUDetail TABLE (  
Declare @pickSKUDetail TABLE( 
    SKU              NVARCHAR( 30),  
    QtyToPack        INT,
    OrderKey         NVARCHAR( 30),
    PickslipNo       NVARCHAR( 30),
    LoadKey          NVARCHAR( 30),--externalOrderKey
    PickDetailStatus NVARCHAR ( 3)
)
  

IF @cType = 'pickslip'
BEGIN
	SET @cPickSlipNo = @cScanNo	
	
   -- Get PickHeader info  
   SELECT TOP 1  
   @cOrderKey = OrderKey,  
   @cLoadKey = ExternOrderKey,  
   @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)  
   WHERE PickHeaderKey = @cPickSlipNo 
   
   IF @@ROWCOUNT = 0
   BEGIN
      SET @b_Success = 0  
      SET @n_Err = 100800  
      SET @c_ErrMsg = 'Invalid Pickslip No. Please use other Pickslip No.'
      GOTO EXIT_SP
   END
      
   --Discrete
   IF @cOrderKey <> '' 
   BEGIN  
	   SET @cScanNoType = 'Discrete'   
	   
	   IF (SELECT TOP 1 storerKey FROM ORDERS (NOLOCK) WHERE OrderKey =  @cOrderKey ) <> @cStorerKey
      BEGIN
   	   SET @b_Success = 0  
         SET @n_Err = 100801  
         SET @c_ErrMsg = 'Pickslip No is from a different Storrer. Please use valid Pickslip No.'
         GOTO EXIT_SP
      END
	   
	   INSERT INTO @pickSKUDetail
	   SELECT PD.SKU,SUM(PD.QTY) AS QtyToPick,PD.OrderKey,@cPickslipNo,@cLoadKey,PD.Status
	   FROM pickDetail PD WITH (NOLOCK)
	   WHERE PD.OrderKey = @cOrderKey  
	      AND PD.Status <= '5'  
         AND PD.Status NOT IN  ('4')   
	   GROUP BY PD.SKU,PD.OrderKey,PD.Status
	   
	   SET @cDynamicRightName1 = 'OrderKey'
	   SET @cDynamicRightValue1 = @cOrderKey         
   END
   --conso
   ELSE IF @cLoadKey <> ''  
   BEGIN  
	   SET @cScanNoType = 'Conso'
	   
	   IF (SELECT TOP 1 storerKey FROM ORDERS (NOLOCK) WHERE loadKey = @cLoadKey ) <> @cStorerKey
      BEGIN
   	   SET @b_Success = 0  
         SET @n_Err = 100801  
         SET @c_ErrMsg = 'Pickslip No is from a different Storrer. Please use valid Pickslip No.'
         GOTO EXIT_SP
      END
	   
	   INSERT INTO @pickSKUDetail
	   SELECT PD.SKU,SUM(PD.QTY) AS QtyToPick,'',@cPickslipNo,@cLoadKey,PD.Status
	   FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)  
         JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)      
      WHERE LPD.LoadKey = @cLoadKey  
         AND PD.Status <= '5'  
         AND PD.Status NOT IN  ('4')  
	   GROUP BY PD.SKU,PD.Status--,PD.OrderKey
	   
	   SET @cDynamicRightName1 = 'LoadKey'
	   SET @cDynamicRightValue1 = @cLoadKey
   END
   ELSE  
   BEGIN  
	   SET @cScanNoType = 'Custom'
	   
	   INSERT INTO @pickSKUDetail
	   SELECT PD.SKU,SUM(PD.QTY) AS QtyToPick,PD.OrderKey,@cPickslipNo,@cLoadKey,PD.Status
	   FROM dbo.PickDetail PD WITH (NOLOCK)  
      WHERE PD.PickSlipNo = @cPickSlipNo  
         AND PD.Status <= '5'  
         AND PD.Status NOT IN  ('4')  
	   GROUP BY PD.SKU,PD.OrderKey,PD.Status
	   
	   SET @cDynamicRightName1 = 'OrderKey'
	   SET @cDynamicRightValue1 = @cOrderKey
   END
   
   --SET @cPickSlipNo = @cScanNo
   
   IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')
	BEGIN
		SET @b_Success = 0  
      SET @n_Err = 100807  
      SET @c_ErrMsg = 'Packing Document No has completed packing. Please enter valid Packing Document No.'
      GOTO EXIT_SP
	END
 END 
 
--type: toteID: (dropID)
IF @cType = 'toteID' 
BEGIN
	SET @cDropID = @cScanNo	
   SET @cOrderKey = ''
   SET @cPickSlipNo = ''
   
   SELECT @cEcomPickslipSP = svalue FROM storerConfig (NOLOCK) WHERE storerKey = @cStorerKey AND configKey ='TPS-GetEcomPickslip'
   
   --1. check config
   IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cEcomPickslipSP AND type = 'P') 
   BEGIN
   	--SELECT '1. config'
   	SET @cSQL = 'EXEC [API].' +@cEcomPickslipSP+ ' @cStorerKey=@cStorerKey, @cFacility=@cFacility, @nFunc=@nFunc, @cLangCode=@cLangCode, @cScanNo=@cDropID, @cType = @cType, @cUserName = @cUserName, @jResult = @jResult OUTPUT, @b_Success = @b_Success OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT, @cSelectAll = @cSelectAll'
   	
   	EXEC sp_executesql @cSQL     
         ,N'@cStorerKey NVARCHAR(15), @cFacility NVARCHAR(5), @nFunc NVARCHAR(5), @cLangCode NVARCHAR(3), @cDropID NVARCHAR( 50), @cType NVARCHAR(30), @cUserName NVARCHAR(128), @jResult NVARCHAR(MAX) OUTPUT, @b_Success INT OUTPUT, @n_Err INT OUTPUT, @c_ErrMsg NVARCHAR(255) OUTPUT, @cSelectAll NVARCHAR( 1)'     
         ,@cStorerKey         
         ,@cFacility  
         ,@nFunc  
         ,@cLangCode
         ,@cDropID
         ,@cType
         ,@cUserName
         ,@jResult        OUTPUT
         ,@b_Success      OUTPUT    
         ,@n_Err          OUTPUT    
         ,@c_ErrMsg       OUTPUT
         ,@cSelectAll
      
      IF @n_Err > 0  
         BEGIN
         	SET @b_Success = 0  
            SET @n_Err = @n_Err  
            SET @c_ErrMsg = @c_ErrMsg
            GOTO EXIT_SP
         END
         
         SET @b2bProcess = '0'
         
         --Decode Json Format
         SELECT @cScanNoType = ScanNoType, @EcomSingle = EcomSingle,@pickSkuDetailJson = PickSkuDetail
         FROM OPENJSON(@jResult)  
         WITH (  
	            ScanNoType        NVARCHAR( 30),
               EcomSingle        NVARCHAR( 1),
               PickSkuDetail     NVARCHAR( MAX) as json
         )  
         --SELECT @cScanNoType as ScanNoType,  @EcomSingle as EcomSingle

         INSERT INTO @pickSKUDetail
         SELECT *
         FROM OPENJSON(@pickSkuDetailJson)
         WITH (
               SKU               NVARCHAR( 20)  '$.SKU',
               QtyToPack         INT            '$.QtyToPack',
               OrderKey          NVARCHAR( 10)  '$.OrderKey',
               PickslipNo        NVARCHAR( 30)  '$.PickslipNo',
               LoadKey           NVARCHAR( 10)  '$.LoadKey',
               PickDetailStatus  NVARCHAR( 1)   '$.PickDetailStatus'
         )   
        
        SELECT TOP 1 @cPickSlipNo = PickslipNo, @cOrderKey = orderKey, @cLoadKey = loadKey FROM @pickSKUDetail
   END
   --2. check ecom_single_flag need to be hav 'S','M'
   ELSE IF NOT EXISTS (SELECT TOP 1 1 FROM pickDetail PD WITH (NOLOCK)
            JOIN ORDERS O WITH (NOLOCK)
            ON PD.orderkey = O.orderKey
            AND PD.storerKey = O.StorerKey
            WHERE PD.dropID = @cDropID
            AND PD.StorerKey = @cStorerKey
            AND ecom_single_flag NOT IN ('S','M'))
   BEGIN
   	--SELECT '2. ecom_flag'
   	--Mix 'S' n 'M'
      IF (SELECT COUNT(DISTINCT O.ecom_single_flag) 
                 FROM pickDetail PD WITH (NOLOCK)
                 JOIN ORDERS O WITH (NOLOCK)
                 ON PD.orderkey = O.orderKey
                 AND PD.storerKey = O.StorerKey
                 WHERE PD.dropID = @cDropID
                 AND PD.StorerKey = @cStorerKey) > 1
      BEGIN
      	--SELECT 'mixed S n M'
   	   SET @EcomSingle = '0'
      END
      ELSE
      BEGIN
   	   -- all 'M'
   	   IF (SELECT DISTINCT O.ecom_single_flag 
            FROM pickDetail PD WITH (NOLOCK)
            JOIN ORDERS O WITH (NOLOCK)
            ON PD.orderkey = O.orderKey
            AND PD.storerKey = O.StorerKey
            WHERE PD.dropID = @cDropID
            AND PD.StorerKey = @cStorerKey) = 'M'
         BEGIN
         	--SELECT 'All M'
      	   SET @EcomSingle = '0'
         END
      
         -- all 'M'
   	   IF (SELECT DISTINCT O.ecom_single_flag 
            FROM pickDetail PD WITH (NOLOCK)
            JOIN ORDERS O WITH (NOLOCK)
            ON PD.orderkey = O.orderKey
            AND PD.storerKey = O.StorerKey
            WHERE PD.dropID = @cDropID
            AND PD.StorerKey = @cStorerKey) = 'S'
         BEGIN
         	--SELECT 'All S'
      	   SET @EcomSingle = '1'
         END
      END

      IF @EcomSingle = '1'
      BEGIN
	      -- double check the qty to make sure is Ecom_single
	      IF (SELECT COUNT(DISTINCT O.Orderkey)
            FROM ORDERS O (NOLOCK)
            JOIN PICKDETAIL PD (NOLOCK) ON O.Orderkey = PD.Orderkey
            LEFT JOIN PACKHEADER PH (NOLOCK) ON O.Orderkey = PH.Orderkey  --AND PH.Status = '9' 
            LEFT JOIN PACKDETAIL PKD (NOLOCK) ON PH.PickSlipNo = PKD.PickSlipNo   
                  WHERE PD.DropID = @cDropID
                  AND ISNULL(PD.Dropid,'') <> ''
                  AND PD.Storerkey = @cStorerKey
            AND PKD.Pickslipno IS NULL            
            GROUP BY O.Orderkey 
            HAVING COUNT(DISTINCT PD.Sku) > 1 OR SUM(PD.Qty) > 1) > 0                          
	      BEGIN
	      	--SELECT 'set to M'
	         SET @EcomSingle = '0'
	      END
	      ELSE
	      BEGIN    
	      	--SELECT 'set to S'           
	         SET @EcomSingle = '1'
	      END
      END

      IF @cSelectAll = '1'
      BEGIN
      	--SELECT 'select ALL'
	      -- all order in tote (packed/unpacked)
	      INSERT INTO @pickSKUDetail
         SELECT PD.SKU,SUM(PD.QTY) AS QtyToPick,PD.OrderKey,PH.PickHeaderKey,PH.ExternOrderKey,PD.status
         FROM dbo.PickDetail PD WITH (NOLOCK)  
         JOIN ORDERS O (NOLOCK) ON PD.Orderkey = O.Orderkey
         JOIN dbo.PickHeader PH WITH (NOLOCK) ON PH.Orderkey = O.Orderkey
         WHERE PD.dropID = @cDropID
            AND ISNULL(PD.Dropid,'') <> ''
            AND PD.Storerkey = @cStorerKey
            AND PD.Status NOT IN  ('0','4','9')   
            AND O.sostatus NOT IN ('CANC','PENCANC')
         GROUP BY PD.SKU,PD.Orderkey, PH.PickHeaderKey,PH.ExternOrderKey,PD.status,O.Priority
         --HAVING SUM(PD.QTY) = 1   
         ORDER BY O.Priority, PD.Orderkey
         
         SELECT TOP 1 @cPickSlipNo = PickslipNo, @cOrderKey = orderKey, @cLoadKey = loadKey FROM @pickSKUDetail
	
      END
      ELSE
      BEGIN
	      IF @EcomSingle = '1'
	      BEGIN
	      	--SELECT 'ecom_single insert'
		      -- havent pack (not in packDetail/packHeader) ecomSingle - 1 pickslip 1 order 1 sku
	         INSERT INTO @pickSKUDetail
            SELECT PD.SKU,SUM(PD.QTY) AS QtyToPick,PD.OrderKey,PH.PickHeaderKey,PH.ExternOrderKey,PD.status
            FROM dbo.PickDetail PD WITH (NOLOCK)  
            JOIN ORDERS O (NOLOCK) ON PD.Orderkey = O.Orderkey
            JOIN dbo.PickHeader PH WITH (NOLOCK) ON PH.Orderkey = O.Orderkey
            LEFT JOIN PACKHEADER PKH (NOLOCK) ON O.Orderkey = PKH.Orderkey   
            LEFT JOIN PACKDETAIL PKD (NOLOCK) ON PKH.PickSlipNo = PKD.PickSlipNo 
            WHERE PD.dropID = @cDropID
               AND ISNULL(PD.Dropid,'') <> ''
               AND PD.Storerkey = @cStorerKey
               AND PD.Status NOT IN  ('0','4','9')   
               AND O.sostatus NOT IN ('CANC','PENCANC')
               AND PKD.Pickslipno IS NULL
            GROUP BY PD.SKU,PD.Orderkey, PH.PickHeaderKey,PH.ExternOrderKey,PD.status,O.Priority
            HAVING SUM(PD.QTY) = 1   
            ORDER BY O.Priority, PD.Orderkey
            
	      END
	      ELSE
	      BEGIN
		      -- ecomMulti - discrete - 1 pickslip 1 order multi sku
		      --SELECT 'ecom_multi insert'
		      INSERT INTO @pickSKUDetail
            SELECT PickD.SKU, PickD.QtyToPick, PickD.OrderKey, PickD.PickHeaderKey, PickD.ExternOrderKey, PickD.status
            FROM (
                SELECT PD.SKU, SUM(PD.QTY) AS QtyToPick, PD.OrderKey, PH.PickHeaderKey, PH.ExternOrderKey, PD.status 
                FROM dbo.PickDetail PD WITH (NOLOCK)   
                JOIN ORDERS O (NOLOCK) ON PD.Orderkey = O.Orderkey
                JOIN dbo.PickHeader PH WITH (NOLOCK) ON PH.Orderkey = O.Orderkey
                WHERE PD.dropID = @cDropID
                      AND ISNULL(PD.Dropid,'') <> ''
                      AND PD.Storerkey = @cStorerKey
                      AND PD.Status NOT IN  ('0','4', '9')    
                      AND O.sostatus NOT IN ('CANC','PENCANC')
                GROUP BY PD.SKU,PD.Orderkey, PH.PickHeaderKey,PH.ExternOrderKey,PD.status
                ) PickD
            LEFT JOIN (
                     SELECT PKD.PickSlipNo, PKD.StorerKey, PKD.SKU, SUM(PKD.Qty) AS QtyPacked
                     FROM dbo.PackDetail PKD WITH (NOLOCK)
                     JOIN dbo.PackHeader PKH WITH (NOLOCK) ON (PKD.pickslipNo = PKH.PickSlipNo)
                     WHERE PKD.Storerkey = @cStorerKey
                     AND PKH.status <> 9
                     GROUP BY PKD.PickSlipNo, PKD.StorerKey, PKD.SKU
                ) PackD ON PickD.Pickheaderkey = PackD.PickSlipNo AND PickD.SKU = PackD.SKU
            --WHERE QtyToPick <> ISNULL(QtyPacked, 0)
            ORDER BY PickD.Orderkey
            
            --SELECT PD.SKU,SUM(PD.QTY) AS QtyToPick,PD.OrderKey,PH.PickHeaderKey,PH.ExternOrderKey,PD.status
            --FROM dbo.PickDetail PD WITH (NOLOCK)  
            --JOIN ORDERS O (NOLOCK) ON PD.Orderkey = O.Orderkey
            --JOIN dbo.PickHeader PH WITH (NOLOCK) ON PH.Orderkey = O.Orderkey
            --LEFT JOIN PACKHEADER PKH (NOLOCK) ON O.Orderkey = PKH.Orderkey   AND PKH.status <> 9
            --LEFT JOIN PACKDETAIL PKD (NOLOCK) ON PKH.PickSlipNo = PKD.PickSlipNo AND PKD.SKU=PD.SKU
            --WHERE PD.dropID = @cDropID
            --   AND ISNULL(PD.Dropid,'') <> ''
            --   AND PD.Storerkey = @cStorerKey
            --   AND PD.Status NOT IN  ('0','4','9')   
            --   AND O.sostatus NOT IN ('CANC','PENCANC')
            --   --AND PKH.status <> 9
            --GROUP BY PD.SKU,PD.Orderkey, PH.PickHeaderKey,PH.ExternOrderKey,PD.status,O.Priority
            ----HAVING SUM(PD.QTY) = 1   
            --ORDER BY O.Priority, PD.Orderkey
            
            SELECT TOP 1 @cPickSlipNo = PickslipNo, @cOrderKey = orderKey, @cLoadKey = loadKey FROM @pickSKUDetail
            
            IF (SELECT COUNT(DISTINCT pickslipNo) FROM @pickSKUDetail) >1
            BEGIN
	            SET @b_Success = 0  
               SET @n_Err = 100901  
               SET @c_ErrMsg = 'Scanned ToteID is not valid to be reuse.'
               GOTO EXIT_SP
            END
            
            SELECT TOP 1 @cPickSlipNo= pickslipno FROM @pickSKUDetail
   
            --IF EXISTS (SELECT TOP 1 * FROM packHeader WITH (NOLOCK) WHERE pickslipNo = @cPickSlipNo AND STATUS = 9)
            --BEGIN
   	        -- SET @b_Success = 0  
            --   SET @n_Err = 100902  
            --   SET @c_ErrMsg = 'Packing Document No has completed packing.Please enter valid Packing Document No.'
            --   GOTO EXIT_SP
            --END
   
	      END
      END
   END   
   ELSE 
   -- 3. normal toteID pack process
   BEGIN
   	SELECT '2. toteID normal'
   	--order not yet packed
      SELECT TOP 1 
         @cOrderKey = OrderKey
      FROM PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND DropID = @cDropID
         AND Status < '5'
   
      -- Check DropID valid
      IF @@ROWCOUNT = 0
      BEGIN
         SET @b_Success = 0  
         SET @n_Err = 100802  
         SET @c_ErrMsg = 'Invalid ToteID. Please use other ToteID.'
         GOTO EXIT_SP
      END
     
      -- Auto retrieve PickSlipNo
      IF @cPickSlipNo = ''
      BEGIN
         -- Get discrete pick slip
         SET @cScanNoType = 'Discrete'
      
         IF (SELECT TOP 1 storerKey FROM ORDERS (NOLOCK) WHERE OrderKey =  @cOrderKey ) <> @cStorerKey
         BEGIN
   	      SET @b_Success = 0  
            SET @n_Err = 100803  
            SET @c_ErrMsg = 'ToteID is from a different Storrer. Please use valid ToteID.'
            GOTO EXIT_SP
         END
           
         SELECT @cPickSlipNo = PickHeaderKey
         FROM PickHeader WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey
         --AND storerKey = @cStorerKey
      
         INSERT INTO @pickSKUDetail
	      SELECT PD.SKU,SUM(PD.QTY) AS QtyToPick,PD.OrderKey,PH.PickHeaderKey,PH.ExternOrderKey,PD.status
	      FROM dbo.PickDetail PD WITH (NOLOCK)  
	      JOIN dbo.PickHeader PH WITH (NOLOCK)
	      ON PD.orderKey = PH.OrderKey
         WHERE PD.dropID = @cDropID 
            AND PD.Status < '5'  
            AND PD.Status NOT IN  ('4')   
	      GROUP BY PD.SKU,PD.OrderKey,PH.PickHeaderKey,PH.ExternOrderKey,PD.status
	   
	      SET @cDynamicRightName1 = 'OrderKey'
	      SET @cDynamicRightValue1 = @cOrderKey
	         
         -- Get conso pick slip
         IF @cPickSlipNo = ''
         BEGIN
            SET @cLoadKey = ''
            SELECT @cLoadKey = LoadKey FROM LoadPlanDetail WITH (NOLOCK) WHERE OrderKey = @cOrderKey
         
            IF @cLoadKey <> ''
               SET @cScanNoType = 'Conso'
            
               IF (SELECT TOP 1 storerKey FROM ORDERS (NOLOCK) WHERE loadKey =  @cLoadKey ) <> @cStorerKey
               BEGIN
   	            SET @b_Success = 0  
                  SET @n_Err = 100803 
                  SET @c_ErrMsg = 'ToteID is from a different Storrer. Please use valid Pickslip No.'
                  GOTO EXIT_SP
               END
            
               SELECT @cPickSlipNo = PickHeaderKey
               FROM PickHeader WITH (NOLOCK)
               WHERE ExternOrderKey = @cLoadKey
                  AND OrderKey = ''
            
               INSERT INTO @pickSKUDetail
	            SELECT PD.SKU,SUM(PD.QTY) AS QtyToPick,'',PH.PickHeaderKey,PH.ExternOrderKey,PD.Status
	            FROM  dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)  
                  JOIN dbo.PICKHEADER PH WITH (NOLOCK) ON (LPD.loadkey = PH.ExternOrderKey)
               WHERE PD.dropID = @cDropID  
                  AND PD.Status < '5'  
                  AND PD.Status NOT IN  ('4')  
	            GROUP BY PD.SKU,PH.PickHeaderKey,PH.ExternOrderKey,PD.Status--,PD.OrderKey
	   
	            SET @cDynamicRightName1 = 'LoadKey'
	            SET @cDynamicRightValue1 = @cLoadKey
         END

         -- Check PickHeader
         IF @cPickSlipNo = ''
         BEGIN
            SET @n_Err = 100804
            SET @c_ErrMsg = 'Unable to retrieve PickHeader detail. Function : fnc_GetPickslipNo'
            GOTO EXIT_SP
         END
      END
   
      -- Check blank
      IF @cPickSlipNo = ''
      BEGIN
         SET @n_Err = 100805
         SET @c_ErrMsg = 'Packing Document No required. Please enter valid Packing Document No.'
         GOTO EXIT_SP
      END
   
      SELECT * FROM @pickSKUDetail
      --SELECT @cPickSlipNo AS pickslipNo

      IF (SELECT COUNT(DISTINCT pickslipNo)  FROM @pickSKUDetail WHERE pickDetailStatus < 5 )>1
      BEGIN
	      SET @b_Success = 0  
         SET @n_Err = 100806  
         SET @c_ErrMsg = 'Scanned ToteID is not valid to be reuse.'
         GOTO EXIT_SP
      END
      
      IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')
	   BEGIN
		   SET @b_Success = 0  
         SET @n_Err = 100807  
         SET @c_ErrMsg = 'Packing Document No has completed packing. Please enter valid Packing Document No.'
         GOTO EXIT_SP
	   END
	
   END   
   --SELECT * FROM @pickSKUDetail
END

IF NOT EXISTS (SELECT TOP 1 1 FROM @pickSKUDetail)
BEGIN
	SET @b_Success = 0  
   SET @n_Err = 100808  
   SET @c_ErrMsg = 'Invalid Pickslip No. Please use other Pickslip No.'
   GOTO EXIT_SP
END

IF @EcomSingle <> 1
Begin
   IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')
   BEGIN
	   SET @b_Success = 0  
      SET @n_Err = 100807  
      SET @c_ErrMsg = 'Packing Document No has completed packing. Please enter valid Packing Document No.'
      GOTO EXIT_SP
   END
END

--SELECT @cScanNoType AS ScanNoType, @cPickSlipNo AS PickslipNo, @cDropID AS DropID, @cOrderKey AS OrderKey, @cLoadKey AS LoadKey, @cZone AS Zone, @EcomSingle AS EcomSingle
--SELECT * FROM @pickSKUDetail

SET @b_Success = 1
SET @n_Err = 0  
SET @c_ErrMsg = ''
SET @jResult =  

(SELECT @cScanNoType AS ScanNoType, @cPickSlipNo AS PickslipNo, @cDropID AS DropID, @cOrderKey AS OrderKey, @cLoadKey AS LoadKey, @cZone AS Zone, @EcomSingle AS EcomSingle
, @cDynamicRightName1 AS DynamicRightName1, @cDynamicRightValue1 AS DynamicRightValue1,
(SELECT * FROM @pickSKUDetail  
FOR JSON PATH , INCLUDE_NULL_VALUES) AS PickSkuDetail 
FOR JSON PATH , INCLUDE_NULL_VALUES)
EXIT_SP:

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.fnc_GetPicklsipNo TO NSQL
GO


