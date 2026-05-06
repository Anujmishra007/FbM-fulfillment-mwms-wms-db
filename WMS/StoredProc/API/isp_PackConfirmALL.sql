SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  
    
/*********************************************************************************/  
/* Store procedure: isp_PackConfirmALL                                           */  
/* Copyright      : Maersk                                                       */  
/*                                                                               */  
/* Date         Rev  Author     Purposes                                         */  
/* 2023-05-19   1.0  yeekung    TPS-735 Created                                  */
/* 2024-02-27   1.1  Yeekung    TPS-888 Fix the labelline (yeekung04)            */
/* 2024-07-11   1.2  Yeekung    TPS-938 Fix the cartontype (yeekung02)           */
/* 2024-11-06   1.2  YeeKung    TPS-989 Add Facility (yeekung03)                 */
/* 2024-09-27   1.3  YeeKung    TPS-960 Add Qcommander PackConfirm (yeekung04)   */
/* 2025-01-21   1.4  YeeKung    TPS-970 Add New Param on Extendedupdate(yeekung05)*/
/* 2025-03-27   1.5  YeeKung    UWP-31731 Fix SKU replaced (yeekung06)           */
/* 2025-04-07   1.6  YeeKung    UWP-32172 Fix Distinct Order (yeekung07)         */
/* 2025-04-08   1.7  YeeKung    UWP-32466 Change Int -> BigInt (yeekung08)       */
/* 2025-01-23   1.8  YeeKung    FCR-2019  Add CartonWeight (yeekung09)           */
/* 2025-01-28   1.9  YeeKung    UWP-29489 Change API Username (yeekung10)        */
/* 2025-02-10   2.0  GhChan     TPS-985 Carton Type Limit Config (Gh01)          */
/* 2025-02-14   2.1  YeeKung    TPS-950 Change correct errorno   (yeekung11)     */
/* 2025-04-18   2.2  YeeKung    UWP-30700 standardize packconfirm (yeekung12)    */
/* 2025-04-22   2.3  YeeKung    UWP-33225 Fix SUM SKU Issue (yeekung13)          */
/* 2025-04-22   2.4  GhChan     UWP-33066 FCR-4039 Fix Group By (Gh02)           */
/* 2025-04-23   2.5  GhChan     FCR-4207 Fix DynamicPrinter (Gh03)               */
/* 2025-04-28   2.6  Yeekung    FCR-3819 Pack Merge with other app(yeekung14)    */
/* 2025-05-16   2.7  Yeekung    UWP-33699 Merge username (yeekung15)             */
/* 2025-05-27   3.8  GCH225     FCR-5305 Get CartonizationGroup (Gh04)           */
/* 2025-07-22   3.9  GCH225     UWP-38184 Enhanced the lsp_SetUser logic         */ 
/* 2025-09-02   4.0  GCH225     FCR-7712 New Post Extended Update SP Logic       */
/* 2025-09-25   5.0  GCH225     FCR-7753 Fix the Pack Sequence Issue             */
/* 2025-09-29   6.0  GCH225     FCR-8258 Add Config for the PackConfirm Logic.   */
/* 2026-04-07   6.1  GCH225     UWP-52943 Fix UPC Logic                          */
/*********************************************************************************/  
  
CREATE OR ALTER PROC [API].[isp_PackConfirmALL] (  
   @json       NVARCHAR( MAX),    
   @jResult    NVARCHAR( MAX) ='' OUTPUT,    
   @b_Success  INT = 1  OUTPUT,    
   @n_Err      INT = 0  OUTPUT,    
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT   
)  
AS  
BEGIN  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  
  
DECLARE   
   @nMobile          INT,  
   @nStep            INT,  
   @cLangCode        NVARCHAR( 3),  
   @nInputKey        INT,  
     
   @cStorerKey       NVARCHAR( 15),  
   @cFacility        NVARCHAR( 5),  
   @nFunc            NVARCHAR( 5),  
   @cUserName        NVARCHAR( 128),  
   @c_UserName       NVARCHAR( 128),  
   @cScanNo          NVARCHAR( 50),  
   @cScanNoType      NVARCHAR( 30),  
   @cDropID          NVARCHAR( 50),  
   @cPickSlipNo      NVARCHAR( 30),  
   @cZone            NVARCHAR( 18),  
   @nCartonNo        INT,  
   @cCartonID        NVARCHAR( 20),  
   @cType            NVARCHAR( 30),  
   @nQTY             INT,  
   @cSKU             NVARCHAR( 20),  
   @cCartonType      NVARCHAR( 10),  
   @cCube            FLOAT,  
   @cWeight          FLOAT,  
   @fCartonWeight    FLOAT,  
   @fCartonCube      FLOAT,  
   @cCloseCartonJson NVARCHAR( MAX),  
   @cUPCJSON         NVARCHAR( MAX),  
   @cLottableJSON    NVARCHAR( MAX),  
   @cLoadKey         NVARCHAR( 10),  
   @cOrderKey        NVARCHAR( 10),
   @nPackQtyCarton   INT,
   @nPackedQTY       INT,
   @cUPC             NVARCHAR( 30),  
   @cLabelLine       NVARCHAR(5),  
   @CalOrderSKU      NVARCHAR( 1),  
   @EcomSingle       NVARCHAR( 1),  
   @nProceedPrintFlag NVARCHAR( 1),  
     
   @cAssignPackLabelToOrdCfg     NVARCHAR(1), --(cc08)  
   @cAssignPackLabelToOrdCfgSP   NVARCHAR(30), --(cc08)  
     
   @cSKUBarcode         NVARCHAR( 60),   --(cc09)  
   @cExtendedUpdateSP   NVARCHAR( 20),   --(cc09)  
   @cPostExtUpdSP       NVARCHAR( 30),
   @cExtendedPrintSP    NVARCHAR( 20),   --(cc10)  
   @cDymEcomCtnWgtTb    NVARCHAR( 20),  
   @cDymEcomCtnWgtCol   NVARCHAR( 20),  
   @cDymEcomCtnCubeTb   NVARCHAR( 20),  
   @cDymEcomCtnCubeCol  NVARCHAR( 20),  
   @UpdDymEcomWeight    NVARCHAR( 1),  
   @UpdDymEcomCube      NVARCHAR( 1),  
   @cDymWgtSQL          NVARCHAR( MAX),  
   @cDymCubeSQL         NVARCHAR( MAX),  
   @cCartonWeight       NVARCHAR( 20),  
   @cCartonCube         NVARCHAR( 20),  
  
   @bSuccess            INT,  
   @nErrNo              INT,   
   @cErrMsg             NVARCHAR(250),  
   @nTranCount          INT,  
   @curPD               CURSOR,  
   @GetCartonID         NVARCHAR( MAX),  
   @cShipLabel          NVARCHAR( 10),  
   @nJobID              INT,  
   @cWorkstation        NVARCHAR( 30),  
   @cLabelNo            NVARCHAR( 20), --(cc01)  
   @pickSkuDetailJson   NVARCHAR( MAX),  
   @bToPrint            INT,  
   @cPrintAfterPacked   NVARCHAR( 1),  
   @cLottableValue      NVARCHAR( 30), --(cc05)  
   @cSQL                NVARCHAR(MAX), --(cc08)  
   @cSQLParam           NVARCHAR(MAX), --(cc08)  
   @cDisableLblPrint    NVARCHAR(1), --(yeekung01)  
   @cDisablePLPrint     NVARCHAR(1), --(yeekung01)  
   @cDefaultCartonType  NVARCHAR(20), --(yeekung06) 
   @nUPCQTY             INT,
   @cCurUPC             CURSOR,
   @cUCCCounter         INT,
   @nLimitCartonType    INT, --(Gh01)
   @cPrinterInGroup     NVARCHAR(10),
   @cShowCartonNo       NVARCHAR(20), --(yeekung14)
   @cCartonStatus       NVARCHAR(20),
   @cPackInfoAddWho     NVARCHAR(128),
   @bUpdateAllCartonStatus    BIT,
   @bIsAutoPack         BIT
  
DECLARE @cNewPaperPrinter NVARCHAR(20)
DECLARE @cNewLabelPrinter NVARCHAR(20)
DECLARE @nOutputCount INT
DECLARE @b_ExecuteAs BIT 

   SET @UpdDymEcomWeight = 'N'  
   SET @EcomSingle = '0'  
   SET @UpdDymEcomCube = 'N'  
   SET @nProceedPrintFlag = '0'  
   SET @cDisableLblPrint = '0'  
   SET @cDisablePLPrint = '0'  
   SET @nLimitCartonType = 0  --(Gh01)
   SET @cShowCartonNo = '0'
   SET @b_ExecuteAs = 0
   SET @bUpdateAllCartonStatus = 0
   SET @bIsAutoPack = 1
   
   DECLARE @CartonIDList TABLE (  
      CartonID        NVARCHAR( 20)  
   )  

   DECLARE @oUPCList TABLE (
      UPC NVARCHAR(30) PRIMARY KEY
   )

   DECLARE @oMappedUPC TABLE (
      UPC NVARCHAR(30) PRIMARY KEY
    , QTY INT
   )

   DECLARE @CloseCartonList TABLE (  
      RowRef          INT  PRIMARY KEY IDENTITY(1,1),
      SKU             NVARCHAR( 20),  
      QTY             INT,  
      Weight          FLOAT,  
      Cube            FLOAT,    
      lottableVal     NVARCHAR(60),  
      barcodeVal      NVARCHAR(60),  
      ADCode          NVARCHAR(60),
      UPC             NVARCHAR(MAX)
   )  
   
  
   DECLARE @pickSKUDetail TABLE (  
      SKU              NVARCHAR( 30),    
      QtyToPack        INT,  
      OrderKey         NVARCHAR( 30),  
      PickslipNo       NVARCHAR( 30),  
      LoadKey          NVARCHAR( 30),--externalOrderKey  
      PickDetailStatus NVARCHAR ( 3)  
   )  
  
   --decode json  
   SELECT   @cStorerKey = StorerKey, @cFacility = Facility, @nFunc = Func, @cUserName = UserName, @cLangCode = LangCode,  
            @cScanNo = ScanNo, @nCartonNo = CartonNo, @cCartonType = CartonType, @cType = ctype, @fCartonWeight = CartonWeight,   
            @fCartonCube = CartonCube, @cWorkstation = Workstation, @cLabelNo = LabelNo,   
            @cCloseCartonJson=CloseCarton  
   FROM OPENJSON(@json)    
   WITH (  
   StorerKey      NVARCHAR( 30),  
   Facility       NVARCHAR( 30),  
      Func           NVARCHAR( 5),  
      UserName       NVARCHAR( 128),  
      LangCode       NVARCHAR( 3),  
      ScanNo         NVARCHAR( 30),  
      CartonNo       INT,  
      CartonType     NVARCHAR( 30),  
      cType          NVARCHAR( 30),  
      CartonWEIGHT   FLOAT,  
      CartonCUBE     FLOAT,  
      Workstation    NVARCHAR( 30),  
      LabelNo        NVARCHAR( 20), --(cc01)  
      CloseCarton    NVARCHAR( max) as json  
   )   
   
   -- this condition is a temporary solution, 
   -- because currently frontend there is no passing back any indicator to differentiate CloseAllCarton vs ManualPackConfirm
   -- only ManualPackConfirm will always pass CartonNo is 0 with CloseCarton value []. CloseAllCarton will not pass like this
   IF @nCartonNo <> 0 AND @cCloseCartonJson <> '[]'
   BEGIN
      IF EXISTS ( SELECT 1 
                  FROM STORERCONFIG (NOLOCK) 
                  WHERE StorerKey = @cStorerKey 
                  AND ConfigKey = 'TPS-AutoPack' 
                  AND sValue = '0'
      )  
      BEGIN  
         SET @bIsAutoPack = 0
      END 
   END

   INSERT INTO @CloseCartonList  
   SELECT Hdr.SKU  
   , Hdr.Qty  
   , Hdr.Weight  
   , Hdr.Cube  
   , Hdr.lottableValue  
   , Det.barcodeVal   
   , Det.AntiDiversionCode  
   , Hdr.UPC 
   FROM OPENJSON(@cCloseCartonJson)  
   WITH (  
      SKU            NVARCHAR( 20)  '$.SKU',  
      Qty            INT            '$.PackedQty',  
      WEIGHT         FLOAT          '$.WEIGHT',  
      Cube           FLOAT          '$.CUBE',  
      lottableValue  NVARCHAR(MAX)   '$.Lottable'  AS JSON, --(cc05)  
      barcodeObj     NVARCHAR(MAX)  '$.barcodeObj' AS JSON, --(cc09)  
      UPC            NVARCHAR(MAX)  '$.UPC' AS JSON --(cc09)  
   ) AS Hdr  
   OUTER APPLY OPENJSON(barcodeObj)  
   WITH (  
      barcodeVal        NVARCHAR(60) '$.barcodeVal',  
      AntiDiversionCode NVARCHAR(60) '$.AntiDiversionCode'  
   ) AS Det  

   SELECT @cUPCJson=UPC  
   FROM OPENJSON(@cCloseCartonJson)  
   WITH (  
      UPC    NVARCHAR( max) as json  
   )

   --GOTO Quit  
   SET @cCartonWeight = CONVERT(NVARCHAR(20),@fCartonWeight)  
   SET @cCartonCube = CONVERT(NVARCHAR(20),@fCartonCube)  
   SET @c_UserName = @cUserName

   SET @n_Err = 0

   SET @cSQL = 'EXEC WM.lsp_SetUser @c_UserName OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT';

   SET @cSQLParam =  N'@c_UserName NVARCHAR(128) OUTPUT,' +
				    N'@n_Err INT OUTPUT, ' + 
				    N'@c_ErrMsg NVARCHAR(125) OUTPUT'
   --convert login
   SELECT @nOutputCount=COUNT(1) FROM sys.parameters p (NOLOCK)
		   JOIN sys.objects o (NOLOCK) 
		      ON p.object_id = o.object_id
		   WHERE o.name = 'lsp_SetUser'
		   AND p.is_output = 1
   IF @nOutputCount = 4 
   BEGIN
     SET @cSQL = @cSQL + ', @b_ExecuteAs OUTPUT '
     SET @cSQLParam = @cSQLParam + ', @b_ExecuteAs BIT OUTPUT'

     EXEC sp_executesql @cSQL, @cSQLParam, @c_UserName OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT, @b_ExecuteAs OUTPUT;
   END
   ELSE
   BEGIN
     EXEC sp_executesql @cSQL, @cSQLParam, @c_UserName OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT
   END

   IF @n_Err <> 0   
   BEGIN    
     SET @b_Success = 0    
     SET @n_Err = @n_Err    
     SET @c_ErrMsg = @c_ErrMsg   
     SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
     GOTO EXIT_SP    
   END  

   IF @nOutputCount = 4
   BEGIN
     IF @b_ExecuteAs = 1
	    GOTO ExecuteAs
     ELSE
     BEGIN
	    IF SESSION_CONTEXT(N'mwms_user_name') IS NULL
	    BEGIN
		   SET @b_Success = 0
		   SET @n_Err = 1001432
		   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No Session context found. Function : isp_PackConfirmALL'
		   GOTO EXIT_SP
	    END            
     END
   END
   ELSE
   BEGIN
     IF @c_UserName LIKE '%' + @cUserName + '%'
     BEGIN
   ExecuteAs:
	    EXECUTE AS LOGIN = @c_UserName
	    SET @cUserName = @c_UserName
     END
   END      

   --SET @cUserName = @cOriUserName
  
   --check pickslipNo  
   EXEC [API].[isp_GetPicklsipNo] @cStorerKey,@cFacility,@nFunc,@cLangCode,@cScanNo,@cType,@cUserName, @jResult OUTPUT,@b_Success OUTPUT,@n_Err OUTPUT,@c_ErrMsg OUTPUT  
   
   IF @n_Err <>0  
   BEGIN  
      SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
      SET @b_Success = 0    
      SET @n_Err = @n_Err    
      SET @c_ErrMsg = @c_ErrMsg  
      GOTO EXIT_SP  
   END  

  
   --Decode pickslipNo Json Format  
   SELECT @cScanNoType = ScanNoType, @cpickslipNo = PickslipNo, @cDropID = DropID,  @cOrderKey=ISNULL(OrderKey,''), @cLoadKey = LoadKey, @cZone = Zone, @EcomSingle = EcomSingle  
   --, @cDynamicRightName1 = DynamicRightName1, @cDynamicRightValue1 = DynamicRightValue1  
   ,@pickSkuDetailJson = PickSkuDetail  
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
   SELECT @cScanNoType as ScanNoType, @cpickslipNo as PickslipNo, @cDropID as DropID,  @cOrderKey as OrderKey, @cLoadKey as LoadKey, @cZone as Zone, @EcomSingle as EcomSingle  
   --, @cDynamicRightName1 as DynamicRightName1, @cDynamicRightValue1 as DynamicRightValue1  
   
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

   -- Check pack confirm already  
   IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')  
   BEGIN  
      SET @b_Success = 0    
      SET @n_Err = 1001404    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Pickslip No is already Closed/Packed. Function : isp_PackConfirmALL'  
      SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
      GOTO EXIT_SP  
   END  

   IF EXISTS (select 1 from @CloseCartonList  where QTY<0) OR 
      EXISTS  (select 1 from @pickSKUDetail  where QtyToPack<0 )
   BEGIN  
      SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
      SET @b_Success = 0    
      SET @n_Err = 1001401    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')  --Invalid SKU. Scanned SKU not found in SKU table. Function : isp_PackConfirmALL
      GOTO EXIT_SP  
   END  
  
   IF EXISTS (SELECT sku FROM @CloseCartonList EXCEPT SELECT sku FROM @pickSKUDetail)  
   BEGIN  
      SET @b_Success = 0    
      SET @n_Err = 1001402    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Invalid SKU. Scanned SKU not found in SKU table. Function : isp_PackConfirmALL'  
      SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
      GOTO EXIT_SP  
   END  
  
   -- Check SKU Blank or Null
   IF EXISTS (SELECT 1 FROM @CloseCartonList WHERE SKU IS NULL OR SKU = '')  
   BEGIN  
      SET @b_Success = 0    
      SET @n_Err = 1001409    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No SKU entered. Please enter or scan valid SKU. Function : isp_PackConfirmALL'  
      SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
      GOTO EXIT_SP  
   END  

   -- Check blank QTY  
   IF EXISTS (SELECT 1 FROM @CloseCartonList WHERE QTY IS NULL OR QTY = 0)  
   BEGIN       
      SET @b_Success = 0    
      SET @n_Err = 1001410    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No Quantity entered. Please enter valid Quantity. Function : isp_PackConfirmALL'       
      SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
      GOTO EXIT_SP  
   END 

   --(cc03)  
   IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPS-PrintAfterPacked' AND sValue = '1')  
   BEGIN  
      SET @bToPrint = 0  
      SET @cPrintAfterPacked = '1'  
   END  
   ELSE  
   BEGIN  
      SET @bToPrint = 1  
   END  

   IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE configkey ='TPS-OnHoldPrint' AND storerKey = @cStorerKey AND sValue = 1)  
   BEGIN  
      IF  EXISTS (SELECT 1 FROM PACKinfo (NOLoCK) where PickSlipNo = @cPickSlipNo and Cartonno=@nCartonNo)
      BEGIN
         SET @bToPrint = 0 
      END
   END 

  
   IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPS-DisableLblPrint' AND sValue = '1')  
   BEGIN  
      SET @cDisableLblPrint = 1  --(yeekung01)  
   END  
   
   IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPS-DisablePLPrint' AND sValue = '1')  
   BEGIN  
      SET @cDisablePLPrint = 1 --(yeekung01)  
   END  

   IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPS-UpdateAllCartonStatus' AND sValue = '1')  
   BEGIN  
      SET @bUpdateAllCartonStatus = 1  
   END 
   
   --Show CartonNo used for some carton is pack by other system or Automation and they used up the current carton no and required to take the new carton no and show to user when response back.
   EXEC nspGetRight  -- (yeekung14)  
         @c_Facility   = @cFacility   
      ,  @c_StorerKey  = @cStorerKey   
      ,  @c_sku        = ''    
      ,  @c_ConfigKey  = 'TPS-ShowCartonNo'    
      ,  @b_Success    = @b_Success       OUTPUT    
      ,  @c_authority  = @cShowCartonNo   OUTPUT    
      ,  @n_err        = @n_Err           OUTPUT    
      ,  @c_errmsg     = @c_ErrMsg        OUTPUT  
  
   IF @EcomSingle IN ('1','2')  
   BEGIN  
      DECLARE @cEcomSKU NVARCHAR( 30)  
               
      SELECT @cEcomSKU = SKU FROM @CloseCartonList  
               
      SELECT TOP 1 @cOrderKey = orderkey,@cPickSlipNo = PickslipNo, @cLoadKey = LoadKey  
      FROM @pickSKUDetail   
      WHERE pickslipNo NOT IN (SELECT DISTINCT pickslipNo FROM packDetail WITH (NOLOCK) WHERE storerKey = @cStorerKey AND SKU = @cEcomSKU)  
      AND sku = @cEcomSKU  
                        
      --SELECT @cOrderKey AS cOrderKeyEcom, @cPickSlipNo AS cPickSlipNoEcom  
   END  
   --SELECT @cOrderKey AS orderKeyAAAAA  
   
   --SELECT @cEcomSKU AS ecomSKU            
   --SELECT * FROM @pickSKUDetail  
   --SELECT @cPickSlipNo AS pickslipno  
   --GOTO EXIT_SP 

   IF ISNULL(@cCartonType,'') =''
   BEGIN
      SELECT @cDefaultCartonType = sValue FROM dbo.StorerConfig WITH (NOLOCK) WHERE @cStorerKey = @cStorerKey AND configKey = 'DefaultCartonType'  
      SET @cCartonType = @cDefaultCartonType
   END
  ELSE  --(Gh01) start  
   BEGIN
      --Carton Type Limit Checking  
      SELECT @nLimitCartonType= TRY_CAST(sValue AS INT) FROM dbo.StorerConfig WITH (NOLOCK) WHERE Storerkey = @cStorerKey AND configKey = 'TPS-LimitCartonType'
 
      IF @@ROWCOUNT = 1 AND @nLimitCartonType > 0
      BEGIN
         IF (SELECT COUNT(DISTINCT CartonType) 
               FROM 
               (SELECT CartonType FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo
               UNION
               SELECT @cCartonType) AS TtlCartonType 
            ) > @nLimitCartonType
         BEGIN
            SELECT @c_ErrMsg = STRING_AGG(CartonType, ', ') FROM (SELECT DISTINCT CartonType FROM dbo.PackInfo WHERE PickSlipNo = @cPickSlipNo) AS ExistingItems
            SET @b_Success = 0    
            SET @n_Err = 1001403    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--' - Cannot select more than these items:  Function : isp_PackConfirmALL'  
            SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )
            GOTO EXIT_SP  
         END
      END
   END 
   --(Gh01) end

   SELECT  @cCartonStatus = CartonStatus,
          @cPackInfoAddWho = AddWho
   FROM dbo.PackInfo WITH (NOLOCK) 
   WHERE PickSlipNo = @cPickSlipNo 
   AND CartonNo = @nCartonNo
   
   IF @@ROWCOUNT > 0
   BEGIN
      --check status   
      IF @cPackInfoAddWho = @cUserName
      BEGIN
         IF @cCartonStatus = 'Closed'
         BEGIN
            SET @b_Success = 0    
         SET @n_Err = 1001405    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Carton No is already Closed/Packed. Function : isp_PackConfirmALL'  
         SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
         GOTO EXIT_SP  
         END
      END
      ELSE
      BEGIN --current carton packed by automation therefore carton no need to set to 0
         SET @nCartonNo = 0
      END
   END

   -- check EcomWeight/Cube  
   IF @EcomSingle = '1'  
   BEGIN  
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
            SET @n_Err = 1001406  
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Incorrect dynamic E-Comm Carton Weight column setup. Function : isp_PackConfirmALL'  
            SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
            GOTO EXIT_SP  
         END  
         ELSE  
         BEGIN  
            SET @UpdDymEcomWeight = 'Y'  
         END  
      END  
      
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
            SET @n_Err = 1001407  
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Incorrect dynamic E-Comm Cube column setup. Function : isp_PackConfirmALL'  
            SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
            GOTO EXIT_SP  
         END  
         ELSE  
         BEGIN  
            SET @UpdDymEcomCube = 'Y'  
         END  
      END  
   END  
        
   --Get CartonID to insert/update packDetail   
   IF ISNULL (@cLabelNo,'') = ''  
   BEGIN  
      SELECT @cCartonID = LabelNo FROM PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND StorerKey = @cStorerKey  
      
      --(cc02) reset pre set lableNo during holdCrton  
      IF @cCartonID = 'PreLabelNo'  
      BEGIN  
         SET @cCartonID = ''  
      END  
   END  
   ELSE  
   BEGIN  
      SELECT @cCartonID = @cLabelNo  
   END   
   
   --SELECT @cCartonID AS cCartonID, @cLabelNo AS LabelNo  
   DECLARE @SQLParam NVARCHAR(MAX)   
   DECLARE @cCartonNo NVARCHAR(5)  
   SET @cCartonNo = CONVERT(NVARCHAR(5),@nCartonNo)  
   IF ISNULL(@cCartonID,'') =''   
   BEGIN   --(cc06)  
      SET @GetCartonID = '       
      EXEC [API].[isp_GetPackCartonID] ''[{"StorerKey":"' +@cStorerKey+ '","Facility":"' +@cFacility + '","Func":"' +@nFunc + '","PickSlipNo":"' +@cPickSlipNo+ '","CartonNo":"' +@cCartonNo+ '","LangCode":"' +@cLangCode+ '"}]'' ,@jResult OUTPUT,@b_Success OUTPUT,@n_Err OUTPUT,@c_ErrMsg OUTPUT'  
      --SELECT @GetCartonID  
      
      SET @SQLParam = '  
      @jResult NVARCHAR(MAX) OUTPUT,  
      @b_Success  INT OUTPUT,  
      @n_Err      INT OUTPUT,  
      @c_ErrMsg   NVARCHAR( 250) OUTPUT  
      '  
      EXEC sp_ExecuteSQL @GetCartonID,@SQLParam, @jResult OUTPUT , @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT  
         
      IF @b_Success <> 1  
      BEGIN  
         SET @b_Success = 0   
         SET @n_Err = @n_Err  
         SET @c_ErrMsg = @c_ErrMsg  
         SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
         GOTO EXIT_SP  
      END  
      ELSE  
      BEGIN  
         SET  @cCartonID = LEFT(replace(@jResult,'[{',''),len(@jResult)-4)  
         --SELECT @cCartonID AS cartonID  
      END   
   END  
         
   --Data Validate  
   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  
   --SAVE TRAN isp_PackConfirmALL  
  
  
   --Close: packHeader  
   IF NOT EXISTS( SELECT TOP 1 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo)  
   BEGIN 
      DECLARE @cRoute NVARCHAR(20) = ''
      DECLARE @cOrderRefNo NVARCHAR(60)   = ''
      DECLARE @cConsigneekey NVARCHAR(20)   = ''

         --(yeekung05)
      SELECT   @cRoute          = ISNULL(Route,''),
               @cOrderRefNo     = ISNULL(ExternOrderkey,''),
               @cConsigneekey   = ISNULL(Consigneekey,'')
      FROM ORDERS (NOLOCK)
      WHERE Orderkey = @cOrderkey
         AND Storerkey = @cStorerKey

      IF ISNULL(@cOrderRefNo,'') <> ''
         SET @cOrderRefNo = SUBSTRING(trim(@cOrderRefNo),1,18)

      INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey, AddWho, AddDate,Route,OrderRefNo,ConsigneeKey)  
      VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey, @cUserName, GETDATE(),@cRoute,@cOrderRefNo,@cConsigneekey)  
      
      IF @@ERROR <> 0  
      BEGIN        
         SET @b_Success = 0    
         SET @n_Err = 1001408    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackHeader. Function : isp_PackConfirmALL'  
         GOTO RollBackTran  
      END  
   END 

   --Get New cartonno  
   IF @nCartonNo <> 0 AND
   EXISTS (SELECT 1 FROM packdetail(nolock) --(yeekung03)
               WHERE pickslipno = @cPickSlipNo  
                  AND Storerkey = @cStorerKey 
                  AND cartonNo = @nCartonNo )
   BEGIN
      SET @nCartonNo = 0
   END

   --Close: packDetail  
   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT  SKU,QTY,WEIGHT,CUBE,lottableVal,UPC 
   FROM @CloseCartonList  
   ORDER BY RowRef ASC
      
   OPEN @curPD 
   FETCH NEXT FROM @curPD INTO @cSKU,@nQTY,@cWeight,@cCube,@cLottableJSON,@cUPCJSON  
   WHILE @@FETCH_STATUS <> -1  
   BEGIN     
      --check pickQty < packQty (per sku)    
      IF (SELECT ISNULL(SUM(QtyToPack),0) FROM @pickSKUDetail WHERE sku = @cSKU) < @nQTY  
      BEGIN  
         SET @b_Success = 0    
         SET @n_Err = 1001412  
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Closed Quantity > Pick Quantity. Please enter valid Quantity. Function : isp_PackConfirmALL'    
         GOTO RollBackTran  
      END  

      IF  EXISTS( SELECT 1
      FROM OPENJSON(@cUPCJSON)  
      WITH (  
         UPC               NVARCHAR( 30)  '$.UPC',  
         QTY               INT            '$.QTY'
      ) ) OR EXISTS ( SELECT 1
      FROM OPENJSON(@cLottableJSON)  
      WITH (  
         Lottable               NVARCHAR( 30)  '$.Lottable',  
         PackedQTY                    INT            '$.PackedQty'
      ) )
      BEGIN

         IF  EXISTS( SELECT 1
            FROM OPENJSON(@cUPCJSON)  
            WITH (  
               UPC               NVARCHAR( 30)  '$.UPC',  
               QTY               INT            '$.QTY'
            ) )
         BEGIN
            SET @cUCCCounter = 0 

            DELETE FROM @oUPCList
            WHERE 1=1

            DELETE FROM @oMappedUPC
            WHERE 1=1

            INSERT INTO @oUPCList
            SELECT ISNULL(RTRIM(UPC), '') 
            FROM UPC (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND SKU = @cSKU

            ;WITH JsonData AS (
               --------------------------------------------------------
               -- Step 1: Read JSON in array order
               --------------------------------------------------------
               SELECT  CAST([key] AS INT) + 1 AS RowNo
                     , JSON_VALUE([value], '$.UPC') AS UPC
                     , TRY_CAST(JSON_VALUE([value], '$.QTY') AS INT) AS Qty
               FROM OPENJSON(@cUPCJSON)
               WHERE JSON_VALUE([value], '$.UPC') IS NOT NULL
               AND LTRIM(RTRIM(JSON_VALUE([value], '$.UPC'))) <> ''
            ),
            Checked AS (
               --------------------------------------------------------
               -- Step 2: Check UPC valid for SKU
               --------------------------------------------------------
               SELECT  j.RowNo
                     , j.UPC
                     , j.Qty
                     ,  CASE 
                           WHEN  S.AltSKU IS NOT NULL 
                              OR S.RetailSKU IS NOT NULL 
                              OR S.ManufacturerSKU IS NOT NULL 
                              OR EXISTS ( SELECT 1 
                                       FROM @oUPCList o 
                                       WHERE o.UPC = j.UPC
                                    )
                              THEN 1
                              ELSE 0
                        END AS IsValid
               FROM JsonData j
               LEFT JOIN SKU (NOLOCK) S
               ON S.SKU = @cSKU
               AND S.StorerKey = @cStorerKey
               AND (S.AltSKU = j.UPC 
                  OR S.RetailSKU = j.UPC
                  OR S.ManufacturerSKU = j.UPC
                  OR EXISTS ( SELECT 1 
                              FROM @oUPCList o 
                              WHERE o.UPC = j.UPC
                           )
               )
            ),
            Grouped AS (
               --------------------------------------------------------
               -- Step 3:
               -- Create running group based on how many valid barcodes
               -- have appeared so far
               --------------------------------------------------------
               SELECT  c.*
                     , SUM(CASE WHEN c.IsValid = 1 THEN 1 ELSE 0 END)
                           OVER (ORDER BY c.RowNo ROWS UNBOUNDED PRECEDING) AS ValidGroup
               FROM Checked c
            ),
            Mapped AS (
               --------------------------------------------------------
               -- Step 4:
               -- Map each row to surviving valid barcode
               --
               -- Cases:
               -- A) ValidGroup > 0
               --    => use the valid barcode of that group
               --
               -- B) ValidGroup = 0
               --    => means rows before first valid barcode
               --       map them to the FIRST valid barcode in the whole list
               --------------------------------------------------------
               SELECT  g.RowNo
                     , g.UPC
                     , g.Qty
                     , g.IsValid
                     , g.ValidGroup
                     ,  CASE
                           WHEN g.ValidGroup > 0 THEN
                              (
                                 SELECT TOP 1 x.UPC
                                 FROM Grouped x
                                 WHERE x.ValidGroup = g.ValidGroup
                                    AND x.IsValid = 1
                                 ORDER BY x.RowNo
                              )
                           ELSE
                              (
                                 SELECT TOP 1 x.UPC
                                 FROM Grouped x
                                 WHERE x.IsValid = 1
                                 ORDER BY x.RowNo
                              )
                        END AS TargetBarcode
               FROM Grouped g
            )
            ------------------------------------------------------------
            -- Step 5: Final grouped result
            ------------------------------------------------------------
            INSERT INTO @oMappedUPC (UPC, Qty)
            SELECT TargetBarcode, SUM(Qty)
            FROM Mapped
            WHERE TargetBarcode IS NOT NULL
            GROUP BY TargetBarcode

            SET @cCurUPC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
            SELECT UPC, Qty 
            FROM @oMappedUPC
            
            OPEN @cCurUPC 
            FETCH NEXT FROM @cCurUPC INTO @cUPC,@nUPCQTY
            WHILE @@FETCH_STATUS <> -1  
            BEGIN  
               IF ISNULL(@cUPC,'') =''
                  GOTO NEXT_UPC

               -- Get LabelLine  
               SET @cLabelLine = ''
               SET @nPackedQTY = 0
               SELECT @cLabelLine = LabelLine, @nPackedQTY = qty 
               FROM dbo.PackDetail WITH (NOLOCK)   
               WHERE PickSlipNo = @cPickSlipNo   
                  AND CartonNo = @nCartonNo  
                  AND LabelNo = @cCartonID   
                  AND SKU = @cSKU  
                  and upc=@cupc
         
               IF @cLabelLine = ''  
                  SELECT @cLabelLine = LabelLine  
                  FROM dbo.PackDetail WITH (NOLOCK)   
                  WHERE PickSlipNo = @cPickSlipNo   
                     AND CartonNo = @nCartonNo  
                     AND LabelNo = @cCartonID   
                     AND SKU = ''  

               SET @nPackedQTY = CASE WHEN ISNULL(@nPackedQTY,'') ='' THEN 0 ELSE @nPackedQTY END 

               IF @nPackedQTY <> @nUPCQTY
               BEGIN
                  SET @nUPCQTY = @nUPCQTY - @nPackedQTY
   
                  --IF @cLabelLine = ''  
                  --BEGIN  
                  --   SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
                  --   FROM dbo.PackDetail (NOLOCK)  
                  --   WHERE Pickslipno = @cPickSlipNo  
                  --      AND CartonNo = @nCartonNo  
                  --      AND LabelNo = @cCartonID  
                  --END 

                  -- Close: PackDetail  
                  IF NOT EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo AND cartonno =@nCartonNo AND SKU=@cSKU and upc=@cupc)  
                  BEGIN  
                     SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
                     FROM dbo.PackDetail (NOLOCK)  
                     WHERE Pickslipno = @cPickSlipNo  
                        AND CartonNo = @nCartonNo  
                        AND LabelNo = @cCartonID  

                     -- Insert PackDetail  
                     INSERT INTO dbo.PackDetail  
                        (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,  
                        AddWho, AddDate, EditWho, EditDate  
                        ,UPC)--(cc05)  
                     VALUES  
                        (@cPickSlipNo, @nCartonNo, @cCartonID, @cLabelLine, @cStorerKey, @cSKU, @nUPCQTY, ISNULL(@cDropID,''),  
                           @cUserName, GETDATE(), @cUserName, GETDATE()  
                           ,@cUPC) --(cc05)  
                     IF @@ERROR <> 0  
                     BEGIN  
                        SET @b_Success = 0    
                        SET @n_Err = 1001413    
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackDetail. Function : isp_PackConfirmALL'          
                        GOTO RollBackTran  
                     END

                     -- Get system assigned CartonoNo and LabelNo
                     IF @nCartonNo = 0
                     BEGIN
                        -- If insert cartonno = 0, system will auto assign max cartonno
                        SELECT TOP 1 
                           @nCartonNo = CartonNo
                        FROM PackDetail WITH (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                           AND SKU = @cSKU
                           AND AddWho = @cUserName
                        ORDER BY CartonNo DESC -- max cartonno
                     END   
                  END  
                  ELSE  
                  BEGIN  
                     -- Update Packdetail  
                     UPDATE dbo.PackDetail WITH (ROWLOCK) SET     
                        SKU = @cSKU,   
                        QTY = QTY+ @nUPCQTY,   
                        DropID = ISNULL(@cDropID,''),  
                        EditWho =  @cUserName,   
                        EditDate = GETDATE(),   
                        ArchiveCop = NULL
                     WHERE PickSlipNo = @cPickSlipNo  
                        AND SKU = @cSKU 
                        AND cartonno =@nCartonNo 
                        and upc = @cupc
                     IF @@ERROR <> 0  
                     BEGIN           
                        SET @b_Success = 0    
                        SET @n_Err = 1001414    
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackDetail. Function : isp_PackConfirmAll'   
                        GOTO RollBackTran  
                     END
                  END  
               END

               SET @nQTY = @nQTY- @nUPCQTY

               NEXT_UPC:

               FETCH NEXT FROM @cCurUPC INTO @cUPC,@nUPCQTY
            END
            CLOSE @cCurUPC
            DEALLOCATE @cCurUPC
         END

         IF EXISTS ( SELECT 1
            FROM OPENJSON(@cLottableJSON)  
            WITH (  
               Lottable               NVARCHAR( 30)  '$.Lottable',  
               PackedQTY                    INT            '$.PackedQty'
            ) )
         BEGIN
            DECLARE @cCurLottable Cursor
            DECLARE @nLotQTY INT

            SET @cCurLottable = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT Lottable,SUM(PackedQTY ) 
            FROM OPENJSON(@cLottableJSON)  
            WITH (  
               Lottable               NVARCHAR( 30)  '$.Lottable',  
               PackedQTY              INT            '$.PackedQty'
            )
            GROUP BY Lottable

            OPEN @cCurLottable 
            FETCH NEXT FROM @cCurLottable INTO @cLottableValue,@nLotQTY
            WHILE @@FETCH_STATUS <> -1  
            BEGIN  
               IF ISNULL(@cLottableValue,'') =''
                  GOTO NEXT_Lottable

                     -- Get LabelLine  
               SET @cLabelLine = ''  
               SET @nPackedQTY = 0
               SELECT @cLabelLine = LabelLine, @nPackedQTY =qty
               FROM dbo.PackDetail WITH (NOLOCK)   
               WHERE PickSlipNo = @cPickSlipNo   
                  AND CartonNo = @nCartonNo  
                  AND LabelNo = @cCartonID   
                  AND SKU = @cSKU  
                  and LOTTABLEVALUE=@cLottableValue
         
               IF @cLabelLine = ''  
                  SELECT @cLabelLine = LabelLine  
                  FROM dbo.PackDetail WITH (NOLOCK)   
                  WHERE PickSlipNo = @cPickSlipNo   
                     AND CartonNo = @nCartonNo  
                     AND LabelNo = @cCartonID   
                     AND SKU = ''  
               
               SET @nPackedQTY = CASE WHEN ISNULL(@nPackedQTY,'') ='' THEN 0 ELSE @nPackedQTY END 

               IF @nPackedQTY <> @nLotQTY
               BEGIN
                  SET @nLotQTY = @nLotQTY - @nPackedQTY
   
                  --IF @cLabelLine = ''  
                  --BEGIN  
                  --   SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
                  --   FROM dbo.PackDetail (NOLOCK)  
                  --   WHERE Pickslipno = @cPickSlipNo  
                  --      AND CartonNo = @nCartonNo  
                  --      AND LabelNo = @cCartonID  
                  --END 

                  -- Close: PackDetail  
                  IF NOT EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo AND cartonno =@nCartonNo AND SKU=@cSKU AND LOTTABLEVALUE = @cLottableValue)  
                  BEGIN  
                  
                     SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
                     FROM dbo.PackDetail (NOLOCK)  
                     WHERE Pickslipno = @cPickSlipNo  
                        AND CartonNo = @nCartonNo  
                        AND LabelNo = @cCartonID  

         
                     -- Insert PackDetail  
                     INSERT INTO dbo.PackDetail  
                        (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,  
                        AddWho, AddDate, EditWho, EditDate  
                        , LOTTABLEVALUE)--(cc05)  
                     VALUES  
                        (@cPickSlipNo, @nCartonNo, @cCartonID, @cLabelLine, @cStorerKey, @cSKU, @nLotQTY,ISNULL(@cDropID,''),  
                           @cUserName, GETDATE(), @cUserName, GETDATE()  
                           , @cLottableValue) --(cc05)  
                     IF @@ERROR <> 0  
                     BEGIN  
                        SET @b_Success = 0    
                        SET @n_Err = 1001415    
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackDetail. Function : isp_PackConfirmALL'          
                        GOTO RollBackTran  
                     END 
                     
                     -- Get system assigned CartonoNo and LabelNo
                     IF @nCartonNo = 0
                     BEGIN
                        -- If insert cartonno = 0, system will auto assign max cartonno
                        SELECT TOP 1 
                           @nCartonNo = CartonNo
                        FROM PackDetail WITH (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                           AND SKU = @cSKU
                           AND AddWho = @cUserName
                        ORDER BY CartonNo DESC -- max cartonno
                     END   
                  END  
                  ELSE  
                  BEGIN  
                     -- Update Packdetail  
                     UPDATE dbo.PackDetail WITH (ROWLOCK) SET     
                        SKU = @cSKU,   
                        QTY = QTY+ @nLotQTY,   
                        DropID = ISNULL(@cDropID,''),  
                        EditWho =  @cUserName,   
                        EditDate = GETDATE(),   
                        ArchiveCop = NULL
                     WHERE PickSlipNo = @cPickSlipNo  
                        AND SKU = @cSKU 
                        AND cartonno =@nCartonNo
                        and LOTTABLEVALUE = @cLottableValue
                     IF @@ERROR <> 0  
                     BEGIN           
                        SET @b_Success = 0    
                        SET @n_Err = 1001416    
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackDetail. Function : isp_PackConfirmALL'   
                        GOTO RollBackTran  
                     END
                  END 
               END

               SET @nQTY = @nQTY- @nLotQTY  

               NEXT_Lottable:

               FETCH NEXT FROM @cCurLottable INTO @cLottableValue,@nLotQTY
            END
            CLOSE @cCurLottable
            DEALLOCATE @cCurLottable

         END

         SET @cUPC = ''
         SET @cLottableValue = ''
      END

      IF @nQTY >0
      BEGIN
                        -- Get LabelLine  
         SET @cLabelLine = ''  
         SET @nPackedQTY = 0
         SELECT @cLabelLine = LabelLine, @nPackedQTY =qty  
         FROM dbo.PackDetail WITH (NOLOCK)   
         WHERE PickSlipNo = @cPickSlipNo   
            AND CartonNo = @nCartonNo  
            AND LabelNo = @cCartonID   
            AND SKU = @cSKU  
            AND UPC = @cSKU
         
         IF @cLabelLine = ''  
            SELECT @cLabelLine = LabelLine  
            FROM dbo.PackDetail WITH (NOLOCK)   
            WHERE PickSlipNo = @cPickSlipNo   
               AND CartonNo = @nCartonNo  
               AND LabelNo = @cCartonID  
               AND SKU = '' 
            
   
         --IF @cLabelLine = ''  
         --BEGIN  
         --   SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
         --   FROM dbo.PackDetail (NOLOCK)  
         --   WHERE Pickslipno = @cPickSlipNo  
         --      AND CartonNo = @nCartonNo  
         --      AND LabelNo = @cCartonID  
         --END 


         SET @cUPC = @cSKU

         SET @nPackedQTY = CASE WHEN ISNULL(@nPackedQTY,'') ='' THEN 0 ELSE @nPackedQTY END 

         SET @nQTY = @nQTY - @nPackedQTY

         IF @nQTY > 0
         BEGIN
            -- Close: PackDetail  
            IF NOT EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo AND cartonno =@nCartonNo AND UPC = @cUPC AND SKU=@cSKU) 
            BEGIN  
            
               SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
               FROM dbo.PackDetail (NOLOCK)  
               WHERE Pickslipno = @cPickSlipNo  
                  AND CartonNo = @nCartonNo  
                  AND LabelNo = @cCartonID  

               -- Insert PackDetail  
               INSERT INTO dbo.PackDetail  
                  (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,  
                  AddWho, AddDate, EditWho, EditDate  
                  , LOTTABLEVALUE, UPC)--(cc05)  
               VALUES  
                  (@cPickSlipNo, @nCartonNo, @cCartonID, @cLabelLine, @cStorerKey, @cSKU, @nQTY, ISNULL(@cDropID,''),  
                     @cUserName, GETDATE(), @cUserName, GETDATE()  
                     , @cLottableValue, @cUPC) --(cc05)  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @b_Success = 0    
                  SET @n_Err = 1001417    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackDetail. Function : isp_PackConfirmALL'          
                  GOTO RollBackTran  
               END  

               -- Get system assigned CartonoNo and LabelNo
               IF @nCartonNo = 0
               BEGIN
                  -- If insert cartonno = 0, system will auto assign max cartonno
                  SELECT TOP 1 
                     @nCartonNo = CartonNo
                  FROM PackDetail WITH (NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                     AND SKU = @cSKU
                     AND AddWho = @cUserName
                  ORDER BY CartonNo DESC -- max cartonno
               END   
            END  
            ELSE  
            BEGIN  
               -- Update Packdetail  
               UPDATE dbo.PackDetail WITH (ROWLOCK) SET     
                  SKU = @cSKU,   
                  QTY = QTY + @nQTY,   
                  DropID = ISNULL(@cDropID,''),  
                  EditWho =  @cUserName,   
                  EditDate = GETDATE(),   
                  ArchiveCop = NULL,
                  LOTTABLEVALUE = @cLottableValue,
                  UPC   = @cUPC
               WHERE PickSlipNo = @cPickSlipNo  
                  AND CartonNo = @nCartonNo  
                  AND LabelNo = @cCartonID  
                  AND SKU     = @cSKU 
                  AND UPC   = @cUPC

               IF @@ERROR <> 0  
               BEGIN           
                  SET @b_Success = 0    
                  SET @n_Err = 1001418    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackDetail. Function : isp_PackConfirmALL'   
                  GOTO RollBackTran  
               END  
            END  
         END
      END

      --Close: Dynamic EcomWeight  
      IF @EcomSingle = '1'    
      BEGIN      
         --Ecom Carton type  
         IF EXISTS (SELECT TOP 1 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey and SKU = @cSKU and ISNULL(EcomCartonType,'')='' )    
         BEGIN     
            UPDATE SKU WITH (ROWLOCK) SET   
               EcomCartonType = @cCartonType  
            WHERE StorerKey = @cStorerKey   
            and SKU = @cSKU    
         END    
         
      ----Dynamic Ecom Weight col  
         IF @UpdDymEcomWeight = 'Y'  
         BEGIN  
            SET @cDymWgtSQL = 'IF EXISTS (SELECT TOP 1 1 FROM '+@cDymEcomCtnWgtTb+' WITH (NOLOCK) WHERE StorerKey = '''+@cStorerKey+''' and SKU = ''' +@cSKU+''' and (ISNULL('+@cDymEcomCtnWgtCol+','''')='''' OR '+@cDymEcomCtnWgtCol+' = 0))  
               BEGIN  
               UPDATE '+@cDymEcomCtnWgtTb+' WITH (ROWLOCK) SET '+@cDymEcomCtnWgtCol+' = '+@cCartonWeight+' WHERE StorerKey = '''+@cStorerKey+''' and SKU = ''' +@cSKU+'''  
               END  
      '   
            EXEC (@cDymWgtSQL)                   
         END  
         ELSE  
         --Default Ecom Weight col  
         BEGIN  
            IF EXISTS (SELECT TOP 1 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey and SKU = @cSKU and (ISNULL(WEIGHT,'')='' OR WEIGHT = 0))    
            BEGIN     
               UPDATE SKU WITH (ROWLOCK) SET   
                  WEIGHT = @cCartonWeight   
               WHERE StorerKey = @cStorerKey   
               and SKU = @cSKU    
            END  
            
            IF @@ERROR <> 0  
            BEGIN           
               SET @b_Success = 0    
               SET @n_Err = 1001419    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into SKU. Function : isp_PackConfirmALL'   
               GOTO RollBackTran  
            END  
         END  
         
      --Dynamic Ecom Cube col  
         IF @UpdDymEcomCube = 'Y'  
         BEGIN  
            SET @cDymCubeSQL = 'IF EXISTS (SELECT TOP 1 1 FROM '+@cDymEcomCtnCubeTb+' WITH (NOLOCK) WHERE StorerKey = '''+@cStorerKey+''' and SKU = ''' +@cSKU+''' and (ISNULL('+@cDymEcomCtnCubeCol+','''')='''' OR '+@cDymEcomCtnCubeCol+' = 0))  
               BEGIN  
               UPDATE '+@cDymEcomCtnCubeTb+' WITH (ROWLOCK) SET '+@cDymEcomCtnCubeCol+' = '+@cCartonCube+' WHERE StorerKey = '''+@cStorerKey+''' and SKU = ''' +@cSKU+'''  
               END  
               '   
            EXEC (@cDymCubeSQL)                   
         END  
         ELSE  
         --Default Ecom Cube col  
         BEGIN  
            IF EXISTS (SELECT TOP 1 1 FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey and SKU = @cSKU and (ISNULL(Cube,'')='' OR Cube = 0))    
            BEGIN     
               UPDATE SKU WITH (ROWLOCK) SET   
                  Cube = @cCartonCube  
               WHERE StorerKey = @cStorerKey   
               and SKU = @cSKU    

               IF @@ERROR <> 0  
               BEGIN           
                  SET @b_Success = 0    
                  SET @n_Err = 1001420    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into SKU. Function : isp_PackConfirmALL'   
                  GOTO RollBackTran  
               END 
            END    
         END   
      END     
         
      FETCH NEXT FROM @curPD INTO @cSKU,@nQTY,@cWeight,@cCube,@cLottableJSON,@cUPCJSON  
   END  

   SELECT @nPackQtyCarton = SUM(Qty) FROM packDetail (NOLOCK) WHERE storerKey = @cStorerKey AND pickSlipNo = @cPickSlipNo AND cartonNo = @nCartonNo  

   IF EXISTS (   SELECT  1
      FROM @CloseCartonList    )
   BEGIN
      DECLARE @cWeightItf INT  
      DECLARE @nCtnCube Float
      DECLARE @nCtnWeight Float
      SET @cWeightItf = 0 
      SET @nCtnCube  = 0      --XULU01

      IF EXISTS(SELECT 1 FROM STORER (NOLOCK) WHERE StorerKey = @cStorerKey AND CartonGroup <> '')
      BEGIN
         SELECT   @nCtnCube = c.[cube],
                  @nCtnWeight = c.CartonWeight
         FROM STORER s (NOLOCK)
            INNER JOIN Cartonization c (NOLOCK) 
         ON s.CartonGroup = c.CartonizationGroup
         WHERE s.StorerKey = @cStorerKey
         AND c.cartontype = @cCartonType  
      END
      ELSE
      BEGIN
         SELECT TOP 1  @nCtnCube = c.[cube],
                  @nCtnWeight = c.CartonWeight
         FROM Cartonization c (NOLOCK)
         WHERE c.cartontype = @cCartonType 
         ORDER BY CartonizationKey DESC
      END
   
      IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE configkey ='TPS-CubeByCarton' AND storerKey = @cStorerKey AND sValue = 1)    
      BEGIN    
         SET @fCartonCube= @nCtnCube  
      END   

      SET @cWeightItf = 0  
   
      IF (@fCartonWeight > 0 OR @fCartonCube > 0)   
      BEGIN  
         IF @fCartonWeight > 30   
         BEGIN  
            SET @cWeightItf = 1  
         END  

         IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE configkey ='TPS-WeightByCarton' AND storerKey = @cStorerKey AND sValue = 1)    
         BEGIN    
            SET @fCartonWeight = @fCartonWeight + @nCtnWeight
         END   

      --SELECT 'update cartonWeight'  
         IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)  
         BEGIN  
            INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY, Weight, Cube, CartonType,CartonStatus, AddWho,AddDate,EditWho,EditDate)  
            VALUES (@cPickSlipNo, @nCartonNo, @nPackQtyCarton, @fCartonWeight, @fCartonCube, @cCartonType,'Closed',SUSER_NAME(),GETDATE(),SUSER_NAME(),GETDATE())  
      
            IF @@ERROR <> 0  
            BEGIN    
               SET @b_Success = 0    
               SET @n_Err = 1001421    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackInfo. Function : isp_PackConfirmALL'  
               GOTO RollBackTran  
            END  
         END  
         ELSE  
         BEGIN  
            UPDATE dbo.PackInfo WITH (ROWLOCK) SET   
            --   Qty = @nPackQtyCarton,  
               CartonType = @cCartonType,  
               Weight = @fCartonWeight,  
               [Cube] = @fCartonCube,  
               EditDate = GETDATE(),   
               EditWho = @cUserName,   
               TrafficCop = NULL,  
               cartonStatus = 'Closed'  
            WHERE PickSlipNo = @cPickSlipNo  
               AND CartonNo = @nCartonNo  
         
            IF @@ERROR <> 0  
            BEGIN        
               SET @b_Success = 0    
               SET @n_Err = 1001422     
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackInfo. Function : isp_PackConfirmALL'  
               GOTO RollBackTran  
            END  
         END  
      END  
      ELSE  
      BEGIN  
      --SELECT 'update skuWeight'  
         DECLARE @ttlWeight FLOAT  
         DECLARE @ttlCube   FLOAT  
      
         IF @ttlWeight > 30   
         BEGIN  
            SET @cWeightItf = 1  
         END  
      
         SELECT @ttlWeight = SUM(WEIGHT),@ttlCube = SUM(CUBE) FROM @CloseCartonList GROUP BY SKU,QTY,lottableVal  

         IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE configkey ='TPS-WeightByCarton' AND storerKey = @cStorerKey AND sValue = 1)    
         BEGIN    
            SET @ttlWeight = @ttlWeight + @nCtnWeight
         END   
         
         IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)  
         BEGIN  
            INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY, Weight, Cube, CartonType,CartonStatus, AddWho,AddDate,EditWho,EditDate)  
            VALUES (@cPickSlipNo, @nCartonNo, @nPackQtyCarton, @ttlWeight, @ttlCube, @cCartonType,'Closed',@cUserName,GETDATE(),@cUserName,GETDATE())  
      
            IF @@ERROR <> 0  
            BEGIN    
               SET @b_Success = 0    
               SET @n_Err = 1001423    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackInfo. Function : isp_PackConfirmALL'  
               GOTO RollBackTran   
            END  
         END  
         ELSE  
         BEGIN  
            UPDATE dbo.PackInfo WITH (ROWLOCK) SET   
         --     QTY = @nPackQtyCarton,  
               CartonType = @cCartonType,  
               Weight = @ttlWeight,  
               [Cube] = @ttlCube,  
               EditDate = GETDATE(),   
               EditWho = @cUserName,   
               TrafficCop = NULL,  
               cartonStatus = 'Closed'  
            WHERE PickSlipNo = @cPickSlipNo  
               AND CartonNo = @nCartonNo  
         
            IF @@ERROR <> 0  
            BEGIN        
               SET @b_Success = 0    
               SET @n_Err = 1001424    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackInfo. Function : isp_PackConfirmALL'  
   
               GOTO RollBackTran  
            END  
         END  
      END  
   END

   IF @bUpdateAllCartonStatus = 1
   BEGIN
      IF EXISTS (SELECT 1 
      FROM dbo.PackInfo WITH (NOLOCK) 
      WHERE PickSlipNo = @cPickSlipNo 
      AND CartonStatus ='HOLD'
      )  
      BEGIN
         UPDATE PackInfo
         SET   CartonStatus = 'Closed',
               EditDate = getdate(),
               EditWho  = @cUsername
         WHERE PickSlipNo = @cPickSlipNo 
            AND CartonStatus ='HOLD'
      END
   END
   ELSE
   BEGIN
      IF EXISTS (SELECT 1 
      FROM dbo.PackInfo WITH (NOLOCK) 
      WHERE PickSlipNo = @cPickSlipNo 
      AND CartonStatus ='HOLD'
      AND ADDWHO = @cUserName 
      )  
      BEGIN
         UPDATE PackInfo
         SET   CartonStatus = 'Closed',
               EditDate = getdate(),
               EditWho  = @cUsername
         WHERE PickSlipNo = @cPickSlipNo 
            AND ADDWHO = @cUserName
            AND CartonStatus ='HOLD'
      END
   END

   --DECLARE @cSQL NVARCHAR (MAX)  
   --DECLARE @cSQLParam NVARCHAR(MAX)  
   DECLARE @cPrintCartonLabelByITF INT  
   
   SET @cPrintCartonLabelByITF = 0  
   --check weight >30 and hav config  
   IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE configkey ='PrintCartonLabelByITF' AND storerKey = @cStorerKey AND sValue = 1)  
   BEGIN  
      SET @cPrintCartonLabelByITF = 1  
   END  
   
   IF @cWeightItf = 1 AND @cPrintCartonLabelByITF = 1  
   BEGIN  
      SET @cSQL = 'EXEC isp_PrintCartonLabel_Interface @c_Pickslipno=@cPickSlipNo, @n_CartonNo_Min=@nCartonNoMin, @n_CartonNo_Max=@nCartonNoMax, @b_Success=@b_Success OUTPUT, @n_Err=@n_Err OUTPUT, @c_ErrMsg=@c_ErrMsg OUTPUT '      
               
      EXEC sp_executesql @cSQL       
         ,N'@cPickSlipNo NVARCHAR(10), @nCartonNoMin INT, @nCartonNoMax INT, @b_Success INT OUTPUT, @n_Err INT OUTPUT, @c_ErrMsg NVARCHAR(255) OUTPUT '       
         ,@cPickSlipNo           
         ,@nCartonNo    
         ,@nCartonNo    
         ,@b_Success      OUTPUT      
         ,@n_Err          OUTPUT      
         ,@c_ErrMsg       OUTPUT      
               
      --SELECT @b_Success AS b_Success, @n_Err AS n_Err, @c_ErrMsg AS c_ErrMsg  
         
      IF @n_Err > 0  
      BEGIN  
         GOTO RollBackTran  
      END     
   END  

   --@cpickslipNo = PickslipNo, @cDropID = DropID,  @cOrderKey=OrderKey, @cLoadKey = LoadKey, @cZone = Zone, @EcomSingle = EcomSingle  
   -- Extended validate  --(cc09)  
   SELECT @cExtendedUpdateSP = svalue FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPSExtUpdSP'  
   IF @cExtendedUpdateSP <> ''    
   BEGIN    
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')    
      BEGIN    
         SET @cSQL = 'EXEC API.' + RTRIM( @cExtendedUpdateSP) +  
            ' @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo, ' +   
            ' @cpickslipNo, @cDropID, @cOrderKey, @cLoadKey, @cZone, @EcomSingle, ' +  
            ' @nCartonNo, @cCartonType, @cType, @fCartonWeight, @fCartonCube, @cWorkstation, @cLabelNo, ' +   
            ' @cCloseCartonJson,@pickSkuDetailJson, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT '  
         SET @cSQLParam =     
            '@cStorerKey      NVARCHAR( 15), ' +  
            '@cFacility       NVARCHAR( 5),  ' +   
            '@nFunc           INT,           ' +  
            '@cUserName       NVARCHAR( 128),' +  
            '@cLangCode       NVARCHAR( 3),  ' +  
            '@cScanNo         NVARCHAR( 50), ' +  
            '@cpickslipNo     NVARCHAR( 30), ' +  
            '@cDropID         NVARCHAR( 50), ' +  
            '@cOrderKey       NVARCHAR( 10), ' +  
            '@cLoadKey        NVARCHAR( 10), ' +  
            '@cZone           NVARCHAR( 18), ' +  
            '@EcomSingle      NVARCHAR( 1),  ' +  
            '@nCartonNo       INT,           ' +  
            '@cCartonType     NVARCHAR( 10), ' +   
            '@cType           NVARCHAR( 30), ' +   
            '@fCartonWeight   FLOAT,         ' +   
            '@fCartonCube     FLOAT,         ' +   
            '@cWorkstation    NVARCHAR( 30), ' +   
            '@cLabelNo        NVARCHAR( 20), ' +  
            '@cCloseCartonJson NVARCHAR( Max), ' +  
      '@pickSkuDetailJson   NVARCHAR( MAX),'+
            '@b_Success       INT            OUTPUT, ' +  
            '@n_Err           INT            OUTPUT, ' +  
            '@c_ErrMsg        NVARCHAR(255)  OUTPUT'  
   
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo,   
            @cpickslipNo, @cDropID, @cOrderKey, @cLoadKey, @cZone, @EcomSingle,  
            @nCartonNo, @cCartonType, @cType, @fCartonWeight, @fCartonCube, @cWorkstation, @cLabelNo,   
            @cCloseCartonJson,@pickSkuDetailJson, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT  
      
         IF @b_Success <> 1  
         BEGIN           
            SET @b_Success = 0   
            SET @n_Err = @n_Err  
            SET @c_ErrMsg = @c_ErrMsg  
            SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
            GOTO RollBackTran  
         END             
      END    
   END    
  
  
   
   
   -- check Qty on pickslip   
   DECLARE @nPickslipPackQty INT  
   DECLARE @nPickslipPickQty INT  
   Declare @cPrintPackList   NVARCHAR( 1)  
   DECLARE @CntCarton         INT
   DECLARE @CntPACKLine       INT
   
   SET @cPrintPackList = 'N'  
   
   SELECT @nPickslipPackQty = ISNULL(SUM(PD.Qty),0)   
        , @CntCarton = COUNT(DISTINCT PD.CartonNo)
        , @CntPACKLine = COUNT(1)
   FROM PackDetail PD WITH (NOLOCK)   
   JOIN packInfo PKI WITH (NOLOCK) ON (PD.PickSlipNo = PKI.PickSlipNo AND PD.CartonNo = PKI.CartonNo)  
   WHERE PD.pickslipno = @cPickSlipNo AND PD.Storerkey = @cStorerKey AND PKI.CartonStatus IN ('Closed', '')  
  
   SELECT @nPickslipPickQty = SUM(QtyToPack) FROM @pickSKUDetail WHERE pickslipNo = @cPickSlipNo  
   
   IF @nPickslipPackQty = @nPickslipPickQty AND @bIsAutoPack = 1
   BEGIN  

      DECLARE @CountOrders INT = 1
      DECLARE @CntPICKLine INT = 1

      IF ISNULL(@cLoadkey,'') <> ''
      BEGIN
         SELECT @CountOrders = COUNT(DISTINCT PD.Orderkey)
           , @CntPICKLine = COUNT(PickDetailKey)
      FROM PICKDETAIL PD (NOLOCK)
      WHERE PD.StorerKey = @cStorerKey
      AND EXISTS (SELECT 1 
                  FROM LOADPLANDETAIL LPD (NOLOCK)
                  WHERE LPD.LoadKey = @cLoadkey
                  AND LPD.OrderKey = PD.OrderKey
      )
      AND PD.[Status] <= '5'
      AND PD.[Status] NOT IN  ('4')

    --  SELECT  @CountOrders =   COUNT( DISTINCT PD.Orderkey) --(yeekung24)
    --FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
    --     JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
    --     --LEFT JOIN UCC UCC WITH (NOLOCK) ON (PD.SKU=UCC.SKU AND PD.storerkey=UCC.storerkey AND PD.Lot=UCC.lot AND PD.LOC=UCC.LOC)
    --  WHERE LPD.LoadKey = @cLoadKey
    --     AND PD.Status <= '5'
    --     AND PD.Status NOT IN  ('4')

      END

      IF (@CountOrders > 40 OR @CntPICKLine > 400) AND (@CntCarton > 40 OR @CntPACKLine > 400 ) --(yeekung24)
      BEGIN
         DECLARE @cIPAddress     NVARCHAR( 40) = ''  
         DECLARE @cPortNo        NVARCHAR( 5) = ''  
         DECLARE @cIniFilePath   NVARCHAR( 200) = ''
         DECLARE @cCommand       NVARCHAR( MAX)
         DECLARE @nQueueID       BIGINT
   
         -- Check QCommander setup  
         SELECT @cPortNo = SHORT,
               @cIPAddress = Long,
               @cIniFilePath = UDF01
         FROM CODELKUP (NOLOCK) 
         WHERE LISTNAME = 'TPQMDSVC'
            AND Storerkey='ALL'

         SET @cCommand = 'UPDATE PackHeader WITH (ROWLOCK) SET' +   
            '  Status = ''9'' ' +   
            ' WHERE PickSlipNo = ''' +   @cPickSlipNo +''''


         INSERT INTO TCPSocket_QueueTask (CmdType, Cmd, StorerKey, Port, TargetDB, IP, TransmitLogKey, DataStream)               
         VALUES ('SQL', @cCommand, @cStorerKey, @cPortNo, DB_NAME(), @cIPAddress, '', 'TPS')    
         SELECT @nQueueID = SCOPE_IDENTITY(), @nErrNo = @@ERROR    
         IF @nErrNo <> 0    
         BEGIN    
            SET @n_Err = 1001428    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --INS QTask Fail    
            GOTO Quit    
         END  
         

         SET @cCommand =     
         '<STX>' +     
            'SQL|' +     
            CAST( @nQueueID AS NVARCHAR( 20)) + '|' +     
            DB_NAME() + '|' +     
            'EXEC ' +  DB_NAME() + '..' + 'isp_QCmd_ExecuteSQL' +   
               ' @cTargetDB=''' + DB_NAME() + '''' +   
               ', @nQTaskID=' + CAST( @nQueueID AS NVARCHAR( 20)) +   
               ', @cPort=''' + @cPortNo + '''' +   
         '<ETX>'  

         -- Call Qcommander    
         EXEC isp_QCmd_SendTCPSocketMsg    
            @cApplication  = 'QCommander',    
            @cStorerKey    = @cStorerKey,     
            @cMessageNum   = @nQueueID,    
            @cData         = @cCommand,    
            @cIP           = @cIPAddress,     
            @cPORT         = @cPortNo,     
            @cIniFilePath  = @cIniFilePath,     
            @cDataReceived = '', --@cDataReceived OUTPUT,    
            @bSuccess      = @bSuccess      OUTPUT,     
            @nErr          = @nErrNo        OUTPUT,     
            @cErrMsg       = @cErrMsg       OUTPUT    
         IF @nErrNo <> 0    
         BEGIN    
            DECLARE @cDBName NVARCHAR( 30) = DB_NAME()  
            EXEC dbo.isp_QCmd_UpdateQueueTaskStatus    
               @cTargetDB    = @cDBName,    
               @nQTaskID     = @nQueueID,     
               @cQStatus     = 'X',    
               @cThreadID    = '',    
               @cMsgRecvDate = '',    
               @cQErrMsg     = ''    
               -- @bSuccess     = @bSuccess OUTPUT,     
               -- @nErr         = @nErrNo   OUTPUT,     
               -- @cErrMsg      = @cErrMsg  OUTPUT    
            IF @@ERROR <> 0    
            BEGIN    
               SET @n_Err = 1001429   
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --UPD QTask Fail    
               GOTO Quit  
            END    
         END  
      
         

      END
      ELSE
      BEGIN

         UPDATE PackHeader WITH (ROWLOCK) SET   
            Status = '9'   
         WHERE PickSlipNo = @cPickSlipNo  
            AND Status <> '9'  
         
         IF @@ERROR <> 0  
         BEGIN  
            SET @b_Success = 0    
            SET @n_Err = 1001425   
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackHeader. Function : isp_PackConfirmALL'  
            GOTO RollBackTran  
         END  
      END
      --(cc08)  
      EXEC nspGetRight    
            @c_Facility   = @cFacility      
         ,  @c_StorerKey  = @cStorerKey     
         ,  @c_sku        = ''           
         ,  @c_ConfigKey  = 'AssignPackLabelToOrdCfg'     
         ,  @b_Success    = @b_Success                OUTPUT    
         ,  @c_authority  = @cAssignPackLabelToOrdCfg OUTPUT     
         ,  @n_err        = @n_Err                    OUTPUT    
         ,  @c_errmsg     = @c_ErrMsg                 OUTPUT    
      
      IF @cAssignPackLabelToOrdCfg = '1'  
      BEGIN  
         SET @cSQL = 'EXEC isp_AssignPackLabelToOrderByLoad' +                      
                     ' @cPickSlipNo, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT '                     
         SET @cSQLParam =                      
            '@cPickSlipNo    NVARCHAR( 20), ' +                      
            '@b_Success      NVARCHAR( 1)  OUTPUT, ' +                           
            '@n_Err          INT           OUTPUT, ' +                      
            '@c_ErrMsg       NVARCHAR( 20) OUTPUT  '                    
                        
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                      
            @cPickSlipNo, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT  
         
         IF @n_Err <> 0
            GOTO RollBackTran  

         SELECT @cPostExtUpdSP = sValue
         FROM STORERCONFIG (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND ConfigKey = 'TPS-PostExtUpdSP'

         IF @@ROWCOUNT = 1
         BEGIN
            IF NOT EXISTS( SELECT 1 FROM sys.objects WHERE name = @cPostExtUpdSP AND type = 'P')    
            BEGIN    
               SET @b_Success = 0    
               SET @n_Err = 1001433    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Invalid Post Extended Update SP Name Function : isp_PackConfirmALL'  
               GOTO RollBackTran                  
            END  
         
            SET @cSQL = 'EXEC API.' + RTRIM( @cPostExtUpdSP) +  
               ' @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo, ' +   
               ' @cpickslipNo, @cDropID, @cOrderKey, @cLoadKey, @cZone, @EcomSingle, ' +  
               ' @nCartonNo, @cCartonType, @cType, @fCartonWeight, @fCartonCube, @cWorkstation, @cLabelNo, ' +   
               ' @cCloseCartonJson,@pickSkuDetailJson, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT '  
            SET @cSQLParam =     
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cFacility       NVARCHAR( 5),  ' +   
               '@nFunc           INT,           ' +  
               '@cUserName       NVARCHAR( 128),' +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@cScanNo         NVARCHAR( 50), ' +  
               '@cpickslipNo     NVARCHAR( 30), ' +  
               '@cDropID         NVARCHAR( 50), ' +  
               '@cOrderKey       NVARCHAR( 10), ' +  
               '@cLoadKey        NVARCHAR( 10), ' +  
               '@cZone           NVARCHAR( 18), ' +  
               '@EcomSingle      NVARCHAR( 1),  ' +  
               '@nCartonNo       INT,           ' +  
               '@cCartonType     NVARCHAR( 10), ' +   
               '@cType           NVARCHAR( 30), ' +   
               '@fCartonWeight   FLOAT,         ' +   
               '@fCartonCube     FLOAT,         ' +   
               '@cWorkstation    NVARCHAR( 30), ' +   
               '@cLabelNo        NVARCHAR( 20), ' +  
               '@cCloseCartonJson NVARCHAR( Max), ' +
               '@pickSkuDetailJson   NVARCHAR( MAX),'+
               '@b_Success       INT            OUTPUT, ' +  
               '@n_Err           INT            OUTPUT, ' +  
               '@c_ErrMsg        NVARCHAR(255)  OUTPUT'  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo,   
               @cpickslipNo, @cDropID, @cOrderKey, @cLoadKey, @cZone, @EcomSingle,  
               @nCartonNo, @cCartonType, @cType, @fCartonWeight, @fCartonCube, @cWorkstation, @cCartonID,   --yeekung16
               @cCloseCartonJson,@pickSkuDetailJson, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT  
    
            IF @b_Success <> 1  
            BEGIN           
               SET @b_Success = 0   
               SET @n_Err = @n_Err  
               SET @c_ErrMsg = @c_ErrMsg  
               SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
               GOTO RollBackTran  
            END
         END
      END  
         
      SET @cPrintPackList = 'Y'  
      SET @bToPrint = 1  
   END  
  
   IF @cPrintCartonLabelByITF = 1  
   BEGIN  
      SET @cSQL = 'EXEC isp_PrintCartonLabel_Interface @c_Pickslipno=@cPickSlipNo, @n_CartonNo_Min=@nCartonNoMin, @n_CartonNo_Max=@nCartonNoMax, @b_Success=@b_Success OUTPUT, @n_Err=@n_Err OUTPUT, @c_ErrMsg=@c_ErrMsg OUTPUT '      
            
      EXEC sp_executesql @cSQL       
         ,N'@cPickSlipNo NVARCHAR(10), @nCartonNoMin INT, @nCartonNoMax INT, @b_Success INT OUTPUT, @n_Err INT OUTPUT, @c_ErrMsg NVARCHAR(255) OUTPUT '       
         ,@cPickSlipNo           
         ,@nCartonNo    
         ,@nCartonNo    
         ,@b_Success      OUTPUT      
         ,@n_Err          OUTPUT      
         ,@c_ErrMsg       OUTPUT      
            
      --SELECT @b_Success AS b_Success, @n_Err AS n_Err, @c_ErrMsg AS c_ErrMsg  
      
      IF @n_Err > 0  
      BEGIN  
         SET @b_Success = 0    
         SET @n_Err = @n_Err  
         SET @c_ErrMsg = @c_ErrMsg   
         GOTO RollBackTran  
      END     
   END  
  
   GOTO Quit  
        
   RollBackTran:  
      ROLLBACK TRAN --isp_PackConfirmALL  
      SET @b_Success = 0  
      SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
      SET @bToPrint = 0  
      --SELECT @bToPrint AS bToPrint  
  
   Quit:  
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
         COMMIT TRAN --isp_PackConfirmALL  
  
   IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey ='TPS-ExtInfoVAS' AND sValue <> '')  
   BEGIN  
      DECLARE @nVasConfig     INT  
      DECLARE @cVasCol1Name   NVARCHAR(30)  
      DECLARE @cVasSP         NVARCHAR(50)  
      DECLARE @cVasSQL        NVARCHAR(MAX)  
      DECLARE @cWorkInstruction  NVARCHAR(4000)  
      DECLARE @cVasCol1Value     NVARCHAR(250)  
      
      SET @nVasConfig = 1  
      SELECT @cVasCol1Name = OPTION1,@cVasSP = sValue FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey ='TPS-ExtInfoVAS'  
      
      IF ISNULL(@cVasSP,'') <> ''  
      BEGIN  
         SET @cVasSQL = 'EXEC API.'+ @cVasSP+' @cStorerKey=@cStorerKey, @cOrderKey=@cOrderKey, @b_Success=@b_Success OUTPUT, @n_Err=@n_Err OUTPUT, @c_ErrMsg=@c_ErrMsg OUTPUT, @cNotes=@cNotes OUTPUT, @cLong=@cLong OUTPUT '      
            
         EXEC sp_executesql @cVasSQL       
            ,N'@cStorerKey NVARCHAR(15), @cOrderKey NVARCHAR(15), @b_Success INT OUTPUT, @n_Err INT OUTPUT, @c_ErrMsg NVARCHAR(255) OUTPUT, @cNotes NVARCHAR( 4000) OUTPUT, @cLong NVARCHAR( 250) OUTPUT'       
            ,@cStorerKey           
            ,@cOrderKey    
            ,@b_Success    OUTPUT      
            ,@n_Err        OUTPUT      
            ,@c_ErrMsg     OUTPUT      
            ,@cWorkInstruction     OUTPUT  
            ,@cVasCol1Value        OUTPUT  
            
         IF @b_Success = 0  
         BEGIN  
            SET @n_Err = @n_Err  
            SET @c_ErrMsg = @c_ErrMsg  
            SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )   
            GOTO EXIT_SP  
         END    
      END  
   END  
  
   IF @bToPrint = 1  
   BEGIN  
   DECLARE @cLabelPrinter NVARCHAR ( 30)  
      DECLARE @cPaperPrinter NVARCHAR ( 30)  
      DECLARE @cLabelJobID   NVARCHAR ( 30)  
      DECLARE @cPackingJobID NVARCHAR ( 30)  

      DECLARE   @c_ModuleID           NVARCHAR(30) ='TPPack'
               , @c_ReportID           NVARCHAR(10) 
               , @c_PrinterID          NVARCHAR(30)  
               , @c_JobIDs             NVARCHAR(50)   = ''         --(Wan03) -- May return multiple jobs ID.JobID seperate by '|'
               , @c_PrintSource        NVARCHAR(20)
               , @c_AutoPrint          NVARCHAR(1)    = 'N'        --(Wan07)
   
      set @cLabelJobID = ''  
      set @cPackingJobID = ''  
      SET @nProceedPrintFlag = '1'  
      
      -- Extended Print  --(cc10)  
      SELECT @cExtendedPrintSP = svalue FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPSExtPrintSP'  
      IF ISNULL(@cExtendedPrintSP,'') <> ''
      BEGIN    
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedPrintSP AND type = 'P')    
         BEGIN    
            SET @cSQL = 'EXEC API.' + RTRIM( @cExtendedPrintSP) +  
               ' @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo, ' +   
               ' @cpickslipNo, @cDropID, @cOrderKey, @cLoadKey, @cZone, @EcomSingle, ' +  
               ' @nCartonNo, @cCartonType, @cType, @fCartonWeight, @fCartonCube, @cWorkstation, @cLabelNo, ' +   
               ' @cCloseCartonJson, @cPrintPackList,'+
               ' @cLabelJobID OUTPUT, @cPackingJobID OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT ' 
            SET @cSQLParam =     
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cFacility       NVARCHAR( 5),  ' +   
               '@nFunc           INT,           ' +  
               '@cUserName       NVARCHAR( 128),' +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@cScanNo         NVARCHAR( 50), ' +  
               '@cpickslipNo     NVARCHAR( 30), ' +  
               '@cDropID         NVARCHAR( 50), ' +  
               '@cOrderKey       NVARCHAR( 10), ' +  
               '@cLoadKey        NVARCHAR( 10), ' +  
               '@cZone           NVARCHAR( 18), ' +  
               '@EcomSingle      NVARCHAR( 1),  ' +  
               '@nCartonNo       INT,    ' +  
               '@cCartonType     NVARCHAR( 10), ' +   
               '@cType           NVARCHAR( 30), ' +   
               '@fCartonWeight   FLOAT,         ' +   
               '@fCartonCube     FLOAT,         ' +   
               '@cWorkstation    NVARCHAR( 30), ' +   
               '@cLabelNo        NVARCHAR( 20), ' +  
               '@cCloseCartonJson NVARCHAR( Max), ' +  
               '@cPrintPackList  NVARCHAR( 1),  ' +  
               '@cLabelJobID     NVARCHAR ( 30) OUTPUT,  ' +
               '@cPackingJobID   NVARCHAR ( 30) OUTPUT,  ' +
               '@b_Success       INT            OUTPUT, ' +
               '@n_Err           INT            OUTPUT, ' +
               '@c_ErrMsg        NVARCHAR(255)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo,
               @cpickslipNo, @cDropID, @cOrderKey, @cLoadKey, @cZone, @EcomSingle,
               @nCartonNo, @cCartonType, @cType, @fCartonWeight, @fCartonCube, @cWorkstation, @cLabelNo,
               @cCloseCartonJson, @cPrintPackList, @cLabelJobID OUTPUT, 
               @cPackingJobID OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT
      
            IF @b_Success <> 1  
            BEGIN  
               SET @b_Success = 0   
               SET @n_Err = @n_Err  
               SET @c_ErrMsg = @c_ErrMsg  
               SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
               GOTO RollBackTran  
            END             
         END    
      END    
      ELSE  
      BEGIN  
         --(cc03)  
         DECLARE @tShipLabel AS VariableTable  
         DECLARE @nStartCartonNo INT  
         DECLARE @nEndCartonNo INT  
         IF @cPrintAfterPacked = '1'  
         BEGIN  
      
            SELECT @nStartCartonNo = MIN(cartonNo),@nEndCartonNo = MAX(CartonNo) FROM PackDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND pickslipNo = @cPickSlipNo  
            -- Common params ofr printing  
               --INSERT INTO @tShipLabel (Variable, Value) VALUES   
               --   ( '@c_StorerKey',     @cStorerKey),   
               --   ( '@c_PickSlipNo',    @cPickSlipNo),   
               --   ( '@c_StartCartonNo', CAST( @nStartCartonNo AS NVARCHAR(10))),  
               --   ( '@c_EndCartonNo',   CAST( @nEndCartonNo AS NVARCHAR(10)))  
         END  
         ELSE  
         BEGIN  
            SET @nStartCartonNo = CAST( @nCartonNo AS NVARCHAR(10))
            SET @nEndCartonNo = CAST( @nCartonNo AS NVARCHAR(10))
            ---- Common params ofr printing  
            --INSERT INTO @tShipLabel (Variable, Value) VALUES   
            --   ( '@c_StorerKey',     @cStorerKey),   
            --   ( '@c_PickSlipNo',    @cPickSlipNo),   
            --   ( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),  
            --   ( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))   
         END  
      
         --lookup printer  
         SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'  
         SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'  
         
         IF @cDisableLblPrint=0  
         BEGIN  
            -- Print label  
            IF EXISTS (SELECT  TOP 1 1 FROM dbo.WMReport WMR WITH (NOLOCK) 
                     JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
                     WHERE Storerkey = @cStorerKey 
                        AND reporttype ='TPSHIPPLBL'
                        AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility))  
            BEGIN  
            
               IF ISNULL(@cLabelPrinter,'') = ''  
               BEGIN  
                  SET @b_Success = 0    
                  SET @n_Err = 1001426     
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_PackConfirmALL'  
                  SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )   
                  GOTO EXIT_SP  
               END  
               ELSE  
               BEGIN  
                  --EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,   
                  --   'TPSHIPPLBL', -- Report type  
                  --   @tShipLabel, -- Report params  
                  --   'API.isp_PackConfim', --source Type  
                  --   @n_Err  OUTPUT,  
                  --   @c_ErrMsg OUTPUT,  
                  --   '1', --noOfCopy  
                  --   '', --@cPrintCommand  
                  --   @nJobID OUTPUT,  
                  --   @cUsername  
   
                  --set @cLabelJobID = @nJobID  

                  SELECT @c_ReportID = WMR.reportid,
                        @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END
                  FROM WMReport WMR (NOLOCK)
                  JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
                  WHERE Storerkey = @cStorerkey
                     AND reporttype = 'TPSHIPPLBL'
                     AND ModuleID ='TPPack'
                     and (WMRD.username = '' OR WMRD.username = @cUsername)
                     AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)

                  IF ISNULL(@cNewLabelPrinter,'')= ''
                  BEGIN
                     SET @cNewLabelPrinter = @cLabelPrinter
                     -- Check if printer is a group  
                     IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cLabelPrinter)  
                     BEGIN  
                        SET @cPrinterInGroup = ''  
  
                        -- Check if report print to a specific printer in group  
                        SELECT @cPrinterInGroup = PrinterID  
                        FROM rdt.rdtReportToPrinter WITH (NOLOCK)  
                        WHERE Function_ID = @nFunc  
                           AND StorerKey = @cStorerKey  
                           AND ReportType = 'TPSHIPPLBL'  
                           AND PrinterGroup = @cLabelPrinter  
  
                        IF @cPrinterInGroup = ''  
                        BEGIN  
                           -- Get default printer in the group  
                           SELECT @cPrinterInGroup = PrinterID  
                           FROM rdt.rdtPrinterGroup WITH (NOLOCK)  
                           WHERE PrinterGroup = @cLabelPrinter  
                              AND DefaultPrinter = 1  
                        END
                        
                        -- Check no default printer
                        IF @cPrinterInGroup = ''  
                        BEGIN  
                           SET @b_Success = 0    
                           SET @n_Err = 1001430    
                           SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_PackConfirmALL'  
                           SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )   
                           GOTO EXIT_SP  
                        END 
                        SET @cNewLabelPrinter = @cPrinterInGroup
                     END
                  END

                  EXEC  [WM].[lsp_WM_Print_Report]
                     @c_ModuleID = @c_ModuleID           
                     , @c_ReportID = @c_ReportID         
                     , @c_Storerkey = @cStorerkey         
                     , @c_Facility  = @cFacility        
                     , @c_UserName  = @cUsername   
                     , @c_ComputerName = ''
                     , @c_PrinterID = @cNewLabelPrinter         
                     , @n_NoOfCopy  = '1'     
                     , @c_KeyValue1 = @cStorerKey        
                     , @c_KeyValue2 = @cPickSlipNo        
                     , @c_KeyValue3 = @nStartCartonNo     
                     , @c_KeyValue4 = @nEndCartonNo       
                     , @b_Success   = @b_Success         OUTPUT      
                     , @n_Err       = @n_Err             OUTPUT
                     , @c_ErrMsg    = @c_ErrMsg          OUTPUT
                     , @c_PrintSource  = @c_PrintSource        
                     , @b_SCEPreView   = 0         
                     , @c_JobIDs      = @cLabelJobID         OUTPUT    
                     , @c_AutoPrint  = 'N'     
            
   
                  IF @n_Err <> 0   
                  BEGIN  
                     SET @b_Success = 0  
                     SET @n_Err = @n_Err  
                     SET @c_ErrMsg = @c_ErrMsg  
                     SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )   
                     GOTO EXIT_SP  
                  END  
               END   
            END  
         END  
   
         IF @cDisablePLPrint=0  
         BEGIN  
            IF @cPrintPackList = 'Y'   
            BEGIN  
               IF EXISTS (SELECT  TOP 1 1 FROM dbo.WMReport WMR WITH (NOLOCK) 
                        JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
                        WHERE Storerkey = @cStorerKey 
                           AND reportType ='TPPACKLIST'
                           AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility))  
               BEGIN  
                  IF ISNULL(@cPaperPrinter,'') = ''  
                  BEGIN  
                     SET @b_Success = 0    
                     SET @n_Err = 1001427  
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Paper Printer setup not done. Please setup the Paper Printer. Function : isp_PackConfirmALL'  
                     SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )   
                     GOTO EXIT_SP  
                  END  
                  ELSE  
                  BEGIN  
                  --  DECLARE @tPackList AS VariableTable

                     --INSERT INTO @tPackList (Variable, Value) VALUES
                  --     ( '@c_PickSlipNo',    @cPickSlipNo)


                     --EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     --   'TPPACKLIST', -- Report type
                     --   @tPackList, -- Report params
                     --   'API.isp_PackConfim', --source Type
                     --   @n_Err  OUTPUT,
                     --   @c_ErrMsg OUTPUT,
                     --   '1', --noOfCopy
                     --   '', --@cPrintCommand
                     --   @nJobID OUTPUT,
                     --   @cUsername
   
                  --  SET @cPackingJobID = @nJobID  

                  SELECT @c_ReportID = WMR.reportid,
                        @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END
                  FROM WMReport WMR (NOLOCK)
                  JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
                  WHERE Storerkey = @cStorerkey
                     AND reporttype = 'TPPACKLIST'
                     AND ModuleID ='TPPack'
                     and (WMRD.username = '' OR WMRD.username = @cUsername)
                     AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)

                  IF ISNULL(@cNewPaperPrinter,'')= ''
                  BEGIN
                     SET @cNewPaperPrinter = @cPaperPrinter
                     -- Check if printer is a group  
                     IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cPaperPrinter)  
                     BEGIN  
                        SET @cPrinterInGroup = ''  

                        -- Check if report print to a specific printer in group  
                        SELECT @cPrinterInGroup = PrinterID  
                        FROM rdt.rdtReportToPrinter WITH (NOLOCK)  
                        WHERE Function_ID = @nFunc  
                           AND StorerKey = @cStorerKey  
                           AND ReportType = 'TPPACKLIST'  
                           AND PrinterGroup = @cPaperPrinter  

                        IF @cPrinterInGroup = ''  
                        BEGIN  
                           -- Get default printer in the group  
                           SELECT @cPrinterInGroup = PrinterID  
                           FROM rdt.rdtPrinterGroup WITH (NOLOCK)  
                           WHERE PrinterGroup = @cPaperPrinter  
                              AND DefaultPrinter = 1  

                           -- Check no default printer  
                           IF @cPrinterInGroup = ''  
                           BEGIN  
                              SET @b_Success = 0    
                              SET @n_Err = 1001431    
                              SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_PackConfirmALL'  
                              SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )   
                              GOTO EXIT_SP  
                           END  
                        END  
                        SET @cNewPaperPrinter = @cPrinterInGroup
                     END
                  END

                  EXEC  [WM].[lsp_WM_Print_Report]
                     @c_ModuleID = @c_ModuleID           
                     , @c_ReportID = @c_ReportID         
                     , @c_Storerkey = @cStorerkey         
                     , @c_Facility  = @cFacility        
                     , @c_UserName  = @cUsername     
                     , @c_ComputerName = ''
                     , @c_PrinterID = @cNewPaperPrinter         
                     , @n_NoOfCopy  = '1'     
                     , @c_KeyValue1 = @cPickSlipNo        
                     , @c_KeyValue2 = ''     
                     , @c_KeyValue3 = ''     
                     , @c_KeyValue4 = ''     
                     , @b_Success   = @b_Success         OUTPUT      
                     , @n_Err       = @n_Err             OUTPUT
                     , @c_ErrMsg    = @c_ErrMsg          OUTPUT
                     , @c_PrintSource  = @c_PrintSource        
                     , @b_SCEPreView   = 0         
                     , @c_JobIDs      = @cPackingJobID         OUTPUT    
                     , @c_AutoPrint  = 'N'   
   
                     IF @n_Err <> 0   
                     BEGIN  
                        SET @b_Success = 0  
                        SET @n_Err = @n_Err  
                        SET @c_ErrMsg = @c_ErrMsg  
                        SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )   
                        GOTO EXIT_SP  
                     END  
                  END   
               END  
            END  
         END  
      
         --custom printSP --(cc04)  
         DECLARE @cCustomLabelSP    NVARCHAR(30)  
         SELECT @cCustomLabelSP = svalue FROM storerConfig WITH (NOLOCK) WHERE storerKey =@cStorerKey AND configKey = 'TPS-labelSP'   
      
         IF ISNULL (@cCustomLabelSP,'') <> ''  
         BEGIN  
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cCustomLabelSP AND type = 'P')    
            BEGIN  
               SET @cSQL = 'EXEC ' + RTRIM( @cCustomLabelSP) +    
                  ' @cStorerKey, @cFacility, @cUserName,  @cPickSlipNo, @cLabelPrinter, @cPaperPrinter, @nErrNo OUTPUT, @cErrMsg OUTPUT'    
               SET @cSQLParam =    
                  '@cStorerKey      NVARCHAR( 15),' +    
                  '@cFacility       NVARCHAR( 5), ' +  
                  '@cUserName       NVARCHAR(128),' +      
                  '@cPickSlipNo     NVARCHAR( 30),' +    
                  '@cLabelPrinter   NVARCHAR( 30),' +    
                  '@cPaperPrinter  NVARCHAR( 30),' +    
                  '@nErrNo          INT OUTPUT,  ' +    
                  '@cErrMsg         NVARCHAR( 20) OUTPUT'    
      
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
                  @cStorerKey, @cFacility, @cPickSlipNo, @cLabelPrinter, @cPaperPrinter, @nErrNo OUTPUT, @cErrMsg OUTPUT    
      
               IF @nErrNo <> 0    
                  GOTO Quit    
            END  
         END  
      
      
         IF EXISTS (SELECT  TOP 1 1 FROM dbo.WMReport WMR WITH (NOLOCK) 
                     JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
                     WHERE Storerkey = @cStorerKey 
                        AND reportType ='TPCtnLbl'
                        AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility))   
         BEGIN  
            --DECLARE @tCtnLabel AS VariableTable  
         
            --INSERT INTO @tCtnLabel (Variable, Value) VALUES   
            --   ( '@c_PickSlipNo',    @cPickSlipNo)  
         
            --EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,   
            --   'TPCtnLbl', -- Report type  
            --   @tCtnLabel, -- Report params  
            --   'API.isp_PackConfim', --source Type  
            --   @n_Err  OUTPUT,  
            --   @c_ErrMsg OUTPUT,  
            --   '1', --noOfCopy  
            --   '', --@cPrintCommand  
            --   @nJobID OUTPUT,  
            --   @cUsername  
            
            SELECT @c_ReportID = WMR.reportid,
                     @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END
            FROM WMReport WMR (NOLOCK)
            JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
            WHERE Storerkey = @cStorerkey
               AND reporttype = 'TPCtnLbl'
               AND ModuleID ='TPPack'
               and (WMRD.username = '' OR WMRD.username = @cUsername)
               AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)

            EXEC  [WM].[lsp_WM_Print_Report]
               @c_ModuleID = @c_ModuleID           
               , @c_ReportID = @c_ReportID         
               , @c_Storerkey = @cStorerkey         
               , @c_Facility  = @cFacility        
               , @c_UserName  = @cUsername          
               , @c_ComputerName = ''
               , @c_PrinterID = @cLabelPrinter         
               , @n_NoOfCopy  = '1'     
               , @c_KeyValue1 = @cPickSlipNo        
               , @c_KeyValue2 = ''     
               , @c_KeyValue3 = ''     
               , @c_KeyValue4 = ''     
               , @b_Success   = @b_Success         OUTPUT      
               , @n_Err       = @n_Err             OUTPUT
               , @c_ErrMsg    = @c_ErrMsg          OUTPUT
               , @c_PrintSource  = @c_PrintSource        
               , @b_SCEPreView   = 0         
               , @c_JobIDs      = @cPackingJobID         OUTPUT    
               , @c_AutoPrint  = 'N'    
   
            IF @n_Err <> 0   
            BEGIN  
               SET @b_Success = 0  
               SET @n_Err = @n_Err  
               SET @c_ErrMsg = @c_ErrMsg  
               SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,'' AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )   
               GOTO EXIT_SP  
            END  
         END  
      END  
   END  
  
   IF @b_Success = 1  
   BEGIN  
      SET @n_Err = 0  
      SET @c_ErrMsg = ''  
      SET @jResult = (select @cOrderKey AS OrderKey, @cLabelJobID as LabelJobID, @cPackingJobID as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, @nVasConfig AS VasConfig, @cVasCol1Name AS VasCol1Name, @cVasCol1Value AS VasCol1Value, @cWorkInstruction AS WorkInstruction 
      ,(CASE WHEN ISNULL(@cShowCartonNo,'') = '1' THEN @nCartonNo ELSE NULL END) AS CartonNo --(yeekung14)
      FOR JSON PATH )   
   END     
            
   EXIT_SP:  
   IF @b_ExecuteAs= 1 REVERT
   EXEC [WM].[lsp_ResetUser]  
  
END  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_PackConfirmALL TO NSQL
GO
