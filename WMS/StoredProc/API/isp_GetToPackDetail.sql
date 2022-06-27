IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[isp_GetToPackDetail]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[isp_GetToPackDetail]
GO

/****** Object:  StoredProcedure [API].[isp_GetToPackDetail]    Script Date: 6/3/2020 4:54:52 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/  
/* Store procedure: isp_GetToPackDetail                                       */  
/* Copyright      : LFLogistics                                               */  
/*                                                                            */  
/* Date         Rev  Author     Purposes                                      */  
/* 2019-11-08   1.0  Chermaine  Created                                       */  
/******************************************************************************/  
  
Create PROC [API].[isp_GetToPackDetail] (  
   @json       NVARCHAR( MAX),  
   @jResult    NVARCHAR( MAX) OUTPUT,  
   @b_Success  INT = 1  OUTPUT,  
   @n_Err      INT = 0  OUTPUT,  
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT   
)  
AS  
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  
  
DECLARE   
   @cLangCode     NVARCHAR( 3),  
   @cUserName      NVARCHAR( 30),
   @cStorerKey    NVARCHAR( 15),  
   @cFacility     NVARCHAR( 5),  
   @nFunc         INT,  
   @cScanNo       NVARCHAR( 30),
   @cType         NVARCHAR( 30),
   @cScanNoType   NVARCHAR( 30),
   @cPickSlipNo   NVARCHAR( 30),
   @cDropID       NVARCHAR( 30),    
     
   @cOrderKey     NVARCHAR( 10),  
   @cLoadKey      NVARCHAR( 10),  
   @cZone         NVARCHAR( 18),  
   @cLot          NVARCHAR( 30),
   @cStatus       NVARCHAR( 2),
     
   @nTotalPick    INT,   
   @nTotalShort   INT,  
   @EcomSingle    NVARCHAR( 1),
   @CalOrderSKU    NVARCHAR( 1),
     
  
   @cDynamicTb1   NVARCHAR( 30),
   @cDynamicTb2   NVARCHAR( 30),
   @cDynamicCol1  NVARCHAR( 30),
   @cDynamicCol2  NVARCHAR( 30),
   
   @cDynamicRightName1  NVARCHAR( 30),
   @cDynamicRightValue1 NVARCHAR( 30),
   @cDymEcomCtnWgtTb    NVARCHAR( 20),
   @cDymEcomCtnWgtCol   NVARCHAR( 20),
   @cDymEcomCtnCubeTb   NVARCHAR( 20),
   @cDymEcomCtnCubeCol  NVARCHAR( 20),
   @cDymCtnWgtTb        NVARCHAR( 20),
   @cDymCtnWgtCol       NVARCHAR( 20),
   @cDymCtnCubeTb       NVARCHAR( 20),
   @cDymCtnCubeCol      NVARCHAR( 20),
   @pickSkuDetailJson   NVARCHAR( MAX)
      
 SET @EcomSingle = '0' 
 SET @CalOrderSKU = 'N'

--LEFT Panel: SKU + Image
DECLARE @packSKUDetail TABLE (         
    SKU              NVARCHAR( 30),  
    Descr            NVARCHAR( 150),
    RetailSKU        NVARCHAR( 30),
    ManufacturerSKU  NVARCHAR( 30),
    AltSKU           NVARCHAR( 30),
    QtyToPack        INT,
    PackedQty        INT,    
    Img              NVARCHAR( 1024),
    Ecom_CartonType  NVARCHAR( 10),
    WEIGHT           FLOAT,
    CUBE             FLOAT,
    Ecom_Weight      FLOAT,
    Ecom_Cube        FLOAT,
    DynamicColName1  NVARCHAR( 50),
    DynamicColName2  NVARCHAR( 50),
    DynamicColValue1 NVARCHAR( 150),
    DynamicColValue2 NVARCHAR( 150)
) 

--DECLARE @pickSKUDetail TABLE (  
CREATE TABLE #pickSKUDetail ( 
    SKU              NVARCHAR( 30),  
    QtyToPack        INT,
    OrderKey         NVARCHAR( 30),
    PickslipNo       NVARCHAR( 30),
    LoadKey          NVARCHAR( 30),--externalOrderKey
    PickDetailStatus NVARCHAR ( 3)
)
 
--Decode Json Format
SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc=Func,@cScanNo=ScanNo, @cType = cType, @cUserName = UserName, @cLangCode = LangCode
FROM OPENJSON(@json)  
WITH (  
	   StorerKey   NVARCHAR ( 15),
	   Facility    NVARCHAR ( 5),
      Func        INT,  
      ScanNo      NVARCHAR( 30),
      cType       NVARCHAR( 30),
      UserName    NVARCHAR( 30),
      LangCode    NVARCHAR( 3)
)  
--SELECT @cStorerKey AS StorerKey, @cFacility AS Facility,@nFunc AS Func, @cScanNo AS ScanNo, @cType AS TYPE, @cUserName AS userName, @cLangCode AS LangCode


--Data Validate  - Check ScanNo blank 
IF @cScanNo = ''  
BEGIN  
   SET @b_Success = 0  
   SET @n_Err = 101200  
   SET @c_ErrMsg = 'Please scan or enter Packing Document No to proceed. Function : isp_GetToPackDetail'  
                                                                  --      
   --SET @jsonErrMsg=(SELECT * FROM @errMsg FOR json AUTO)  
   GOTO EXIT_SP  
END  

--check pickslipNo
EXEC [API].[isp_GetPicklsipNo] @cStorerKey,@cFacility,@nFunc,@cLangCode,@cScanNo,@cType,@cUserName, @jResult OUTPUT,@b_Success OUTPUT,@n_Err OUTPUT,@c_ErrMsg OUTPUT

IF @n_Err <>0
BEGIN
	SET @jResult = ''
	SET @b_Success = 0  
   SET @n_Err = @n_Err  
   SET @c_ErrMsg = @c_ErrMsg
   
   GOTO EXIT_SP
END


--Decode Json Format
SELECT @cScanNoType = ScanNoType, @cpickslipNo = PickslipNo, @cDropID = DropID,  @cOrderKey=OrderKey, @cLoadKey = LoadKey, @cZone = Zone, @EcomSingle = EcomSingle
, @cDynamicRightName1 = DynamicRightName1, @cDynamicRightValue1 = DynamicRightValue1,@pickSkuDetailJson = PickSkuDetail
FROM OPENJSON(@jResult)  
WITH (  
	   ScanNoType        NVARCHAR( 30),
	   PickslipNo        NVARCHAR( 30),
      DropID            NVARCHAR( 30),
      OrderKey          NVARCHAR( 10),  
      LoadKey           NVARCHAR( 10),
      Zone              NVARCHAR( 18),
      EcomSingle        NVARCHAR( 1),
      DynamicRightName1    NVARCHAR( 30),
      DynamicRightValue1   NVARCHAR( 30),
      PickSkuDetail     NVARCHAR( MAX) as json
)  
--SELECT @cScanNoType as ScanNoType, @cpickslipNo as PickslipNo, @cDropID as DropID,  @cOrderKey as OrderKey, @cLoadKey as LoadKey, @cZone as Zone, @EcomSingle as EcomSingle
--, @cDynamicRightName1 as DynamicRightName1, @cDynamicRightValue1 as DynamicRightValue1

INSERT INTO #pickSKUDetail
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


--check packstatus is it close
--IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')
--BEGIN
--   SET @b_Success = 0  
--   SET @n_Err = 100351  
--   SET @c_ErrMsg = 'Scan Document already packed'
--   GOTO EXIT_SP
--END

 --check storerConfig to skip cartonize
 DECLARE @skipCartonize NVARCHAR( 1)
 DECLARE @hidePackedSku NVARCHAR( 1)
 DECLARE @navCtnScn NVARCHAR(1)
 
 SET @hidePackedSku = '0'
 
 SELECT @navCtnScn = sValue FROM dbo.StorerConfig WITH (NOLOCK) WHERE @cStorerKey = @cStorerKey AND configKey = 'TPS-NavCtnScn'
 
 IF EXISTS (SELECT TOP 1 1  FROM dbo.storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPS-captureWeight' AND (sValue LIKE '%w%' or sValue LIKE'%c%'))
 BEGIN
 	SET @skipCartonize = '0'
 END
 ELSE
 BEGIN
 	SELECT @skipCartonize = sValue FROM dbo.StorerConfig WITH (NOLOCK) WHERE @cStorerKey = @cStorerKey AND configKey = 'TPS-skipCartonize'
 END
 
 --check cartonType setup
 IF (@skipCartonize = '0' OR isNull(@skipCartonize,'') = '')
 BEGIN
 	IF NOT EXISTS (SELECT TOP 1 1 FROM STORER S WITH (NOLOCK)
               JOIN CARTONIZATION C WITH (NOLOCK) ON (S.cartonGroup=C.CartonizationGroup)  WHERE S.StorerKey = @cStorerKey)
   BEGIN
   	SET @n_Err = 101201
      SET @c_ErrMsg = 'Please setup Cartonization in SCE/WMS to proceed. Function : isp_GetToPackDetail'
      GOTO EXIT_SP
   END
 END
--check storerConfig to hide Packed sku
IF EXISTS (SELECT TOP 1 1  FROM dbo.storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPS-HidePackedSku' AND sValue ='1')
 BEGIN
 	SET @hidePackedSku = '1'
 END
 
--set Dynamic Column  
DECLARE @cSQLDynamicSelect NVARCHAR ( MAX)
DECLARE @cSQLGropBy        NVARCHAR ( MAX)

SELECT TOP 1 
   @cDynamicTb1 = rdt.rdtGetParsedString( OPTION1, 1, '.'),
   @cDynamicTb2 = rdt.rdtGetParsedString( OPTION2, 1, '.'), 
   @cDynamicCol1 = rdt.rdtGetParsedString( OPTION1, 2, '.'), 
   @cDynamicCol2 = rdt.rdtGetParsedString( OPTION2, 2, '.')
FROM StorerConfig (NOLOCK) 
WHERE storerKey = @cStorerKey 
AND configKey ='TPS-dynamicPackDetail'

--SELECT @cDynamicTb1 AS cDynamicTb1,@cDynamicTb2 AS cDynamicTb2

IF @@ROWCOUNT > 0 
BEGIN
	IF (ISNULL(@cDynamicTb1,'') <> '' AND @cDynamicTb1 NOT IN ('SKU')) OR (ISNULL(@cDynamicTb2,'') <> '' AND @cDynamicTb2 NOT IN ('SKU')) 
   BEGIN
      SET @n_Err = 101202
      SET @c_ErrMsg = 'Incorrect dynamic Weight and Cube columns setup. Function : isp_GetToPackDetail'
      GOTO EXIT_SP
   END
   
   IF ISNULL(@cDynamicTb1,'') = '' AND ISNULL(@cDynamicTb2,'') = '' 
   BEGIN
   	SET @cSQLDynamicSelect = ','''' AS DynamicColName1,'''' AS DynamicColValue1,'''' AS DynamicColName2,'''' AS DynamicColValue2 '
   	SET @cSQLGropBy = ''
   END
   
   IF ISNULL(@cDynamicTb1,'') = '' AND ISNULL(@cDynamicTb2,'') <> '' 
   BEGIN
   	SET @cSQLDynamicSelect = '
         ,'''' ,'''+@cDynamicCol2+''' AS DynamicColName2 
         ,''''
         ,'+'ISNULL(' +@cDynamicTb2+ '.' + @cDynamicCol2 + ','''')'+ ' AS DynamicColValue2 
         '
      SET @cSQLGropBy = '
      ,' +@cDynamicTb2+ '.' + @cDynamicCol2 + ' 
      '
   END
   
   IF ISNULL(@cDynamicTb1,'') <> '' AND ISNULL(@cDynamicTb2,'') = ''
   BEGIN
   	SET @cSQLDynamicSelect = '
      ,'''+@cDynamicCol1+''' AS DynamicColName1 ,''''
      ,'+'ISNULL('  +@cDynamicTb1+ '.' + @cDynamicCol1+ ','''')' + ' AS DynamicColValue1
      ,'''' 
      '
      
      SET @cSQLGropBy = '
      ,' +@cDynamicTb1+ '.' + @cDynamicCol1 + ' 
      '
   END
   
   IF ISNULL(@cDynamicTb1,'') <> '' AND ISNULL(@cDynamicTb2,'') <> ''
   BEGIN
   	SET @cSQLDynamicSelect = '
      ,'''+@cDynamicCol1+''' AS DynamicColName1 ,'''+@cDynamicCol2+''' AS DynamicColName2 
      ,'+'ISNULL(' +@cDynamicTb1+ '.' + @cDynamicCol1 + ','''')'+ ' AS DynamicColValue1
      ,'+'ISNULL(' +@cDynamicTb2+ '.' + @cDynamicCol2 + ','''')'+ ' AS DynamicColValue2 
      '
      
      SET @cSQLGropBy = '
      ,' +@cDynamicTb1+ '.' + @cDynamicCol1 + ' 
      ,' +@cDynamicTb2+ '.' + @cDynamicCol2 + ' 
      '
   END
END
ELSE
BEGIN
	IF ISNULL(@cDynamicTb1,'') = '' AND ISNULL(@cDynamicTb2,'') = '' 
   BEGIN
   	SET @cSQLDynamicSelect = ','''' AS DynamicColName1,'''' AS DynamicColValue1,'''' AS DynamicColName2,'''' AS DynamicColValue2 '
   	SET @cSQLGropBy = ''
   END
END

---- not in scope-- configure wan to display image not
--SELECT TOP 1
--@cDisplayImg = svalue
--FROM storerConfig (NOLOCK)
--WHERE storerKey = @cStorerKey
--AND configKey = 'TPS-DisplayImage'

DECLARE @cSQLDymWgtSelect NVARCHAR ( 150)

-- Dynamic SKU weight 
IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey =@cStorerKey AND configKey = 'TPS-SKUWgt' AND OPTION1 <>'')
BEGIN
   SELECT TOP 1 
      @cDymCtnWgtTb = rdt.rdtGetParsedString( OPTION1, 1, '.'),
      @cDymCtnWgtCol = rdt.rdtGetParsedString( OPTION1, 2, '.')
   FROM StorerConfig (NOLOCK) 
   WHERE storerKey = @cStorerKey 
   AND configKey ='TPS-SKUWgt'
   AND OPTION1 <>''
      
   IF (ISNULL(@cDymCtnWgtTb,'') NOT IN ('SKU')) OR (ISNULL(@cDymCtnWgtTb,'') = '')
   BEGIN
      SET @n_Err = 101202
      SET @c_ErrMsg = 'Incorrect dynamic SKU Weight column setup. Function : isp_GetToPackDetail'
      GOTO EXIT_SP
   END
   ELSE
   BEGIN
      SET @cSQLDymWgtSelect = @cSQLDymWgtSelect+' ,'+@cDymCtnWgtTb+'.'+@cDymCtnWgtCol
   END
END
ELSE
BEGIN
	   SET @cSQLDymWgtSelect = @cSQLDymWgtSelect + ', SKU.stdGrossWgt'
END

--Dynamic sku cube   
IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey =@cStorerKey AND configKey = 'TPS-SKUCube' AND OPTION1 <>'')
BEGIN
   SELECT TOP 1 
      @cDymCtnCubeTb = rdt.rdtGetParsedString( OPTION1, 1, '.'),
      @cDymCtnCubeCol = rdt.rdtGetParsedString( OPTION1, 2, '.')
   FROM StorerConfig (NOLOCK) 
   WHERE storerKey = @cStorerKey 
   AND configKey ='TPS-SKUCube'
   AND OPTION1 <>''
      
   IF (ISNULL(@cDymCtnCubeTb,'') NOT IN ('SKU')) OR (ISNULL(@cDymCtnCubeTb,'') = '')
   BEGIN
      SET @n_Err = 101203
      SET @c_ErrMsg = 'Incorrect dynamic SKU Cube column setup. Function : isp_GetToPackDetail'
      GOTO EXIT_SP
   END
   ELSE
   BEGIN
      SET @cSQLDymWgtSelect = @cSQLDymWgtSelect+' ,'+@cDymCtnCubeTb+'.'+@cDymCtnCubeCol
   END
END
ELSE 
BEGIN
	   SET @cSQLDymWgtSelect = @cSQLDymWgtSelect + ', SKU.stdCube'
END

-- Dynamic Ecom Carton weight 
IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey =@cStorerKey AND configKey = 'TPS-EcomCartonWgt' AND OPTION1 <>'')
BEGIN
   SELECT TOP 1 
      @cDymEcomCtnWgtTb = rdt.rdtGetParsedString( OPTION1, 1, '.'),
      @cDymEcomCtnWgtCol = rdt.rdtGetParsedString( OPTION1, 2, '.')
   FROM StorerConfig (NOLOCK) 
   WHERE storerKey = @cStorerKey 
   AND configKey ='TPS-EcomCartonWgt'
   AND OPTION1 <>''
      
   IF (ISNULL(@cDymEcomCtnWgtTb,'') NOT IN ('SKU')) OR (ISNULL(@cDymEcomCtnWgtTb,'') = '')
   BEGIN
      SET @n_Err = 101205
      SET @c_ErrMsg = 'Incorrect dynamic E-Comm Carton Weight column setup. Function : isp_GetToPackDetail'
      GOTO EXIT_SP
   END
   ELSE
   BEGIN
      SET @cSQLDymWgtSelect = @cSQLDymWgtSelect+' ,'+@cDymEcomCtnWgtTb+'.'+@cDymEcomCtnWgtCol
   END
END
ELSE
BEGIN
	   SET @cSQLDymWgtSelect = @cSQLDymWgtSelect + ', SKU.Weight'
END

--Dynamic Carton cube   
IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey =@cStorerKey AND configKey = 'TPS-EcomCartonCube' AND OPTION1 <>'')
BEGIN
   SELECT TOP 1 
      @cDymEcomCtnCubeTb = rdt.rdtGetParsedString( OPTION1, 1, '.'),
      @cDymEcomCtnCubeCol = rdt.rdtGetParsedString( OPTION1, 2, '.')
   FROM StorerConfig (NOLOCK) 
   WHERE storerKey = @cStorerKey 
   AND configKey ='TPS-EcomCartonCube'
   AND OPTION1 <>''
      
   IF (ISNULL(@cDymEcomCtnCubeTb,'') NOT IN ('SKU')) OR (ISNULL(@cDymEcomCtnCubeTb,'') = '')
   BEGIN
      SET @n_Err = 101206
      SET @c_ErrMsg = 'Incorrect dynamic E-Comm Cube column setup. Function : isp_GetToPackDetail'
      GOTO EXIT_SP
   END
   ELSE
   BEGIN
      SET @cSQLDymWgtSelect = @cSQLDymWgtSelect+' ,'+@cDymEcomCtnCubeTb+'.'+@cDymEcomCtnCubeCol
   END
END
ELSE
BEGIN
	   SET @cSQLDymWgtSelect = @cSQLDymWgtSelect + ', SKU.Cube'
END

--form packInfo output 
DECLARE @cSQLCobine     NVARCHAR( MAX)
DECLARE @cSQLMainSelect NVARCHAR( MAX)
DECLARE @cSQLFrom       NVARCHAR( MAX)

--(sum(pick.QtyToPack)-isnull((SUM(PD.qty)),0)) AS QtyToPack
IF @EcomSingle = '1'
BEGIN
	SET @cSQLMainSelect = '
   SELECT 
   RTRIM(sku.SKU), RTRIM(SKU.descr), RTRIM(ISNULL(SKU.RetailSKU,'''')),  RTRIM(ISNULL(SKU.ManufacturerSKU,'''')),RTRIM(ISNULL(SKU.ALTSKU,'''')),(sum(pick.QtyToPack)-isnull((SUM(PD.qty)),0)) AS QtyToPack, SUM(PD.qty) AS PackedQty,'''' AS Img,SKU.EcomCartonType
'
END
ELSE
BEGIN
	SET @cSQLMainSelect = '
   SELECT 
   RTRIM(sku.SKU), RTRIM(SKU.descr), RTRIM(ISNULL(SKU.RetailSKU,'''')),  RTRIM(ISNULL(SKU.ManufacturerSKU,'''')),RTRIM(ISNULL(SKU.ALTSKU,'''')),(pick.QtyToPack-isnull((SUM(PD.qty)),0)) AS QtyToPack, SUM(PD.qty) AS PackedQty,'''' AS Img,SKU.EcomCartonType
'
END


SET @cSQLFrom =
'
FROM #pickSKUDetail pick
LEFT JOIN dbo.SKU sku WITH (NOLOCK) ON (sku.sku = pick.sku)
LEFT JOIN dbo.packDetail PD WITH (NOLOCK) on (pick.pickslipNo = PD.pickslipNo and SKU.SKU = PD.SKU)
WHERE SKU.storerKey = ''' +@cStorerKey+ '''
GROUP BY sku.SKU,SKU.descr,SKU.RetailSKU, SKU.ManufacturerSKU,SKU.ALTSKU,sku.WEIGHT,sku.[CUBE],
SKU.EcomCartonType,sku.StdGrossWgt,sku.StdCube,pick.QtyToPack
'

SET @cSQLCobine = @cSQLMainSelect+@cSQLDymWgtSelect+@cSQLDynamicSelect+@cSQLFrom+@cSQLGropBy
--LEFT JOIN dbo.packDetail PD WITH (NOLOCK) on (pick.pickslipNo = PD.pickslipNo and PD.storerKey = PD.storerKey)

--SELECT @cSQLCobine

INSERT INTO @packSKUDetail
EXEC (@cSQLCobine)

--DROP TABLE #pickSKUDetail 
--SELECT * FROM #pickSKUDetail ORDER BY pickslipNo
--SELECT * FROM #pickSKUDetail 
--SELECT 'AA',* FROM @packSKUDetail

--get img
DECLARE @SkuImg TABLE (  
	storerKey   NVARCHAR( 20),
    SKU        NVARCHAR( 30),  
    ImageURL   NVARCHAR( 1024)    
) 

DECLARE @SkuImgURL NVARCHAR( 1024)

DECLARE @cSku NVARCHAR ( 30)

DECLARE curMsg CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
select sku FROM @packSKUDetail

OPEN curMsg;
FETCH NEXT FROM curMsg INTO @cSku
WHILE @@FETCH_STATUS = 0
   BEGIN
   	--default Img, cause sp still point to MYWMS
      INSERT INTO @SkuImg
      EXEC [API].[isp_Get_SKU_Image_UR] 
      --exec rdt.[Get_SKU_Image_URL_test]       
      --EXEC [MYWMS].[WM].[lsp_WM_Get_SKU_Image_URL]
        @cstorerkey     
      , @cSku            
      , @cUserName         
      , @b_Success        OUTPUT  
      , @n_err            OUTPUT                                                                                                             
      , @c_ErrMsg         OUTPUT

      --EXEC [MYWMS].[WM].[lsp_WM_Get_SKU_Image_URL] 
      -- @c_Storerkey = 'NIKEMY'
      --,@c_SKU = @cSku
      --, @c_UserName = @cUserName
      --,@c_ReturnType ='PARAM'
      --,@c_ReturnURL = @SkuImgURL OUTPUT
      
      --INSERT INTO @SkuImg
      --VALUES(@cSku,@SkuImgURL)
   
   FETCH NEXT FROM curMsg INTO @cSku
   END
CLOSE curMsg
DEALLOCATE curMsg

UPDATE @packSKUDetail
SET Img = ISNULL(s.ImageURL,'')
FROM @packSKUDetail p
JOIN  @SkuImg s ON p.sku = s.sku
     

--output Json format  
SET @b_Success = 1  
----SET @jResult = (SELECT * FROM @packSKUDetail FOR JSON AUTO, INCLUDE_NULL_VALUES)

SET @jResult = (SELECT MAX(PD.CartonNo) AS MaxCartonNo,(SELECT COUNT(CartonStatus)AS HoldStatus from packInfo WITH (NOLOCK) WHERE pickslipno=@cPickSlipNo AND cartonStatus = 'Hold') AS HoldStatus ,
@cDynamicRightName1 AS DynamicRightName1,@cDynamicRightValue1 AS DynamicRightValue1,@skipCartonize AS skipCartonize,@navCtnScn AS navCtnScn, @hidePackedSku AS hidePackedSku,@EcomSingle AS EcomSingle,
--COUNT(PKI.cartonStatus) AS HoldStatus,
   (SELECT p.*,case when UPC.upc IS NULL then '' else UPC.UPC end AS UPC
   FROM @packSKUDetail p 
   left JOIN (SELECT UPC,sku FROM UPC (NOLOCK) WHERE StorerKey = @cStorerKey) UPC
   ON UPC.sku = p.sku 
   FOR JSON AUTO, INCLUDE_NULL_VALUES ) AS Details
   
FROM #pickSKUDetail PSKU  WITH (NOLOCK) 
LEFT JOIN PackDetail PD WITH (NOLOCK) ON (PSKU.pickslipno = PD.pickslipNo)
--WHERE PD.PickSlipNo = @cPickSlipNo
AND StorerKey = @cStorerKey
FOR JSON AUTO, INCLUDE_NULL_VALUES)

select @jResult

DROP TABLE #pickSKUDetail 

EXIT_SP:
   REVERT  

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_GetToPackDetail TO NSQL
GO



