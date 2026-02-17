SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_HoldCarton                                            */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2020-03-24   1.0  Chermaine  Created                                       */
/* 2021-01-07   1.1  Chermaine  TPS-555 if hav @PackCaptureNewLabelno config  */
/*                              pre-set a labelNo to hold a carton (cc01)     */
/* 2021-09-02   1.2  Chermaine  TPS-592 Add catonNo param (cc02)              */
/* 2021-09-05   1.3  Chermaine  TPS-11 ErrMsg add to rdtmsg (cc03)            */
/* 2023-07-05   1.4  YeeKung    TPS-735 add hold carton printing(yeekung01)   */
/* 2023-08-09   1.5  YeeKung    TPS-727 add UPC on packdetail (yeekung02)     */
/* 2023-12-29   1.6  YeeKung    TPS-832 change calling cartonweight and cube  */
/* 2024-01-30   1.7  Yeekung    JSM-205854 Fix labelline (yeekung03)          */
/* 2024-02-27   1.8  Yeekung    TPS-888 Fix the labelline (yeekung04)         */
/* 2025-01-28   1.9  YeeKung    UWP-29489 Change API Username (yeekung05)     */
/* 2025-02-14   2.0  yeekung    TPS-995 Change Error Message (yeekung06)      */
/* 2025-03-26   2.1  YeeKung    UWP-32005 Add consigneekey packheader         */
/* 2025-04-23   2.2  GhChan     FCR-4207 Fix DynamicPrinter (Gh03)            */
/* 2025-04-28   2.3  GhChan     UWP-33185 Changed CartonStatus Condition (Gh04)*/
/* 2025-04-28   2.4  Yeekung    FCR-3819 Pack Merge with other app(yeekung07) */
/* 2025-05-16   2.4  Yeekung    UWP-33699 Merge username (yeekung08)          */
/* 2025-07-22   2.5  GCH225     UWP-38184 Enhanced the lsp_SetUser logic      */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_HoldCarton] (
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
   @cDropID          NVARCHAR( 50),
   @cPickSlipNo      NVARCHAR( 30),
   @nCartonNo        INT,
   @cCartonNo        NVARCHAR( 10),
   @cType            NVARCHAR( 30),
   @nQTY             INT,
   @cSKU             NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            FLOAT,
   @cWeight          FLOAT,
   @cHoldCartonJson  NVARCHAR( MAX),
   @cExtendedUpdateSP   NVARCHAR( 20), 
   @cLoadKey         NVARCHAR( 10),
   @cOrderKey        NVARCHAR( 10),
   @nPackQtyCarton   INT,  

   @cUPC             NVARCHAR( 30),
   @cLabelLine       NVARCHAR(5),
   @cScanNoType      NVARCHAR( 30),
   @cZone            NVARCHAR( 18),

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

   @bSuccess         INT,
   @nErrNo           INT,
   @cErrMsg          NVARCHAR(250),
   @nTranCount       INT,
   @curPD            CURSOR,
   @GetCartonID      NVARCHAR( MAX),
   @pickSkuDetailJson   NVARCHAR( MAX),
   @cUPCJSON         NVARCHAR( MAX),  
   @cLottableJSON    NVARCHAR( MAX),  
   @c_authority  NVARCHAR(30), --(cc01)
   @bToPrint            INT,
   @nProceedPrintFlag NVARCHAR( 1),
   @cExtendedPrintSP    NVARCHAR( 20),
   @EcomSingle          NVARCHAR( 1),
   @fCartonWeight    FLOAT,  
   @fCartonCube      FLOAT,
   @cWorkstation     NVARCHAR( 30),
   @cLabelNo         NVARCHAR( 20),
   @cDisableLblPrint NVARCHAR(1) = 0, --(yeekung01)  
   @cDisablePLPrint  NVARCHAR(1) = 0 , --(yeekung01)  
   @cDefaultCartonType  NVARCHAR(20), --(yeekung06) 
   @nUPCQTY          INT,
   @cCurUPC          CURSOR,
   @nJobID           INT,
   @nPackedQTY       INT,
   @cPrinterInGroup NVARCHAR(10),
   @cShowCartonNo       NVARCHAR(20), --(yeekung07)
   @cCartonStatus       NVARCHAR(20),
   @cPackInfoAddWho     NVARCHAR(128)

   Declare @cPrintPackList   NVARCHAR( 1)  
   DECLARE @nVasConfig     INT  

   DECLARE     @cSQL             NVARCHAR(MAX), --(cc08)  
               @cSQLParam        NVARCHAR(MAX) --(cc08)  
   --@nCtnRn           INT,
   --@cCtnTyp          NVARCHAR( 10),
   --@cCtnTyp1         NVARCHAR( 10),
   --@cCtnTyp2         NVARCHAR( 10),
   --@cCtnTyp3         NVARCHAR( 10),
   --@cCtnTyp4         NVARCHAR( 10),
   --@cCtnTyp5         NVARCHAR( 10),
   --@curCtn           CURSOR,
   --@cCartonGroup     NVARCHAR( 30)

   DECLARE @cFieldName1 NVARCHAR(max),
           @cFieldName2 NVARCHAR(max),
           @cFieldName3 NVARCHAR(max),
           @cFieldName4 NVARCHAR(max),
           @cParams1    NVARCHAR(max),
           @cParams2    NVARCHAR(max),
           @cParams3    NVARCHAR(max),
           @cParams4    NVARCHAR(max),
           @IsAggregate1 BIT = 0,
           @IsAggregate2 BIT = 0,
           @IsAggregate3 BIT = 0,
           @IsAggregate4 BIT = 0

   DECLARE @cNewPaperPrinter NVARCHAR(20)
   DECLARE @cNewLabelPrinter NVARCHAR(20)
   DECLARE @groupByFields NVARCHAR(MAX) = ''

   DECLARE @ttlWeight FLOAT
   DECLARE @ttlCube   FLOAT
   DECLARE @nOutputCount INT
   DECLARE @b_ExecuteAs BIT

DECLARE @HoldCartonList TABLE (
   SKU             NVARCHAR( 20),
   QTY             INT,
   Weight          FLOAT,
   Cube            FLOAT,
   lottableVal     NVARCHAR(MAX), 
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
select @cStorerKey = StorerKey, @cFacility = Facility,@nFunc = Func,@cUserName = UserName,@cLangCode = LangCode,@cScanNo = ScanNo,@nCartonNo = CartonNo, @cType = ctype, @cWorkstation = Workstation,@cHoldCartonJson=HoldCarton,@cLabelNo=LabelNo --, @cSKU = SKU, @nQTY = QTY, @cWeight = Weight, @cCube = Cube
   FROM OPENJSON(@json)
   WITH (
    StorerKey   NVARCHAR( 30),
    Facility    NVARCHAR( 30),
      Func        NVARCHAR( 5),
      UserName    NVARCHAR( 128),
      LangCode    NVARCHAR( 3),
      ScanNo      NVARCHAR( 30),
      CartonNo    INT,
      cType       NVARCHAR( 30),
      Workstation    NVARCHAR( 30), 
      HoldCarton  NVARCHAR( max) as json,
      LabelNo     NVARCHAR(20)
   )

   --SELECT @cUserName AS cUserNameb4
--SELECT @cStorerKey AS StorerKey, @cFacility AS Facility,@nFunc AS Func,@cUserName AS UserName,@cScanNo AS ScanNo,@nCartonNo AS CartonNo,@ctype AS ctype

INSERT INTO @HoldCartonList
SELECT Hdr.SKU  
      , Hdr.Qty  
      , Hdr.Weight  
      , Hdr.Cube  
      , Hdr.lottableValue  
      , Det.barcodeVal   
      , Det.AntiDiversionCode  
      , Hdr.UPC 
FROM OPENJSON(@cHoldCartonJson)
WITH (
      SKU             NVARCHAR( 20) '$.SKU',
      Qty             INT           '$.PackedQty',
      Weight          FLOAT         '$.WEIGHT',
      Cube            FLOAT         '$.CUBE',
      lottableValue  NVARCHAR(MAX)   '$.Lottable' AS JSON, --(cc05)  
      barcodeObj     NVARCHAR(MAX)  '$.barcodeObj' AS JSON, --(cc09)  
      UPC            NVARCHAR(MAX)  '$.UPC' AS JSON --(cc09)  
)AS Hdr  
OUTER APPLY OPENJSON(barcodeObj)  
WITH (  
   barcodeVal        NVARCHAR(60) '$.barcodeVal',  
   AntiDiversionCode NVARCHAR(60) '$.AntiDiversionCode'  
) AS Det  


--SELECT * FROM @HoldCartonList

   SET @c_UserName = @cUserName

   SET @n_Err = 0
   SET @b_ExecuteAs = 0
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
      --INSERT INTO @errMsg(nErrNo,cErrMsg)
      SET @b_Success = 0
      SET @n_Err = @n_Err
      SET @c_ErrMsg = @c_ErrMsg
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
            SET @n_Err = 1001375
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No Session context found. Function : isp_HoldCarton'
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


SET @cPrintPackList = 'N'  

SET @bToPrint = 0 

IF EXISTS (SELECT TOP 1 1 FROM storerConfig WITH (NOLOCK) WHERE configkey ='TPS-OnHoldPrint' AND storerKey = @cStorerKey AND sValue = 1)  
BEGIN  
   SET @bToPrint = 1 
END 


If ISNULL(@cWorkstation,'') = ''
BEGIN
   SELECT TOP 1 @cWorkstation = WorkStation
   FROM api.appsection API (NOLOCK)
      JOIN API.AppWorkstation WORK (NOLOCK) ON API.DeviceID =WORK.DeviceID
   WHERE API.UserID = @cUserName
      AND API.PickslipNo = @cPickSlipNo

END


--Decode pickslipNo Json Format
SELECT @cScanNoType = ScanNoType, @cpickslipNo = PickslipNo, @cDropID = DropID,  @cOrderKey=ISNULL(OrderKey,''), @cLoadKey = LoadKey, @cZone = Zone--, @EcomSingle = EcomSingle
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
SELECT @cScanNoType as ScanNoType, @cpickslipNo as PickslipNo, @cDropID as DropID,  @cOrderKey as OrderKey, @cLoadKey as LoadKey, @cZone as Zone--, @EcomSingle as EcomSingle
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
   SET @n_Err = 1001354
   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Pickslip No is already Closed/Packed. Function : isp_HoldCarton'
   GOTO EXIT_SP
END

IF EXISTS (SELECT sku FROM @HoldCartonList EXCEPT SELECT sku FROM @pickSKUDetail)
BEGIN
 SET @b_Success = 0
   SET @n_Err = 1001351
   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Invalid SKU. Scanned SKU not found in SKU table. Function : isp_HoldCarton'
   GOTO EXIT_SP
END

-- Check SKU blank or NULL
IF EXISTS (SELECT 1 FROM @HoldCartonList WHERE SKU IS NULL OR SKU = '')  
BEGIN     
   SET @b_Success = 0    
   SET @n_Err = 1001356    
   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No SKU entered. Please enter or scan valid SKU. Function : isp_HoldCarton'     
   GOTO EXIT_SP
END  
        
-- Check blank QTY  
IF EXISTS (SELECT 1 FROM @HoldCartonList WHERE QTY IS NULL OR QTY = 0)  
BEGIN       
   SET @b_Success = 0    
   SET @n_Err = 1001357    
   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No Quantity entered. Please enter valid Quantity. Function : isp_HoldCarton'           
   GOTO EXIT_SP  
END   

SELECT @cPickSlipNo AS pickslipno

--Show CartonNo used for some carton is pack by other system or Automation and they used up the current carton no and required to take the new carton no and show to user when response back.
EXEC nspGetRight  -- (yeekung07)  
      @c_Facility   = @cFacility   
   ,  @c_StorerKey  = @cStorerKey   
   ,  @c_sku        = ''    
   ,  @c_ConfigKey  = 'TPS-ShowCartonNo'    
   ,  @b_Success    = @b_Success       OUTPUT    
   ,  @c_authority  = @cShowCartonNo   OUTPUT    
   ,  @n_err        = @n_Err           OUTPUT    
   ,  @c_errmsg     = @c_ErrMsg        OUTPUT  


SELECT @cCartonStatus = CartonStatus,
       @cPackInfoAddWho = AddWho
FROM dbo.PackInfo WITH (NOLOCK) 
WHERE PickSlipNo = @cPickSlipNo 
AND CartonNo = @nCartonNo

IF @@ROWCOUNT > 0
BEGIN
   --check status   
   IF @cPackInfoAddWho = @cUserName
   BEGIN
      IF @cCartonStatus = 'Hold'
      BEGIN  
         SET @b_Success = 0
         SET @n_Err = 1001352
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Carton No is already in On-Hold Status. Function : isp_HoldCarton'
         GOTO EXIT_SP 
      END 
      ELSE IF @cCartonStatus = 'Closed'
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1001353
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Carton No is already Closed/Packed. Function : isp_HoldCarton'
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN --current carton packed by automation therefore carton no need to set to 0
      SET @nCartonNo = 0
   END
END

--(cc01) user manual Key in lableNo
EXECUTE nspGetRight null,
   @cStorerKey,   -- Storerkey
   '',       -- Sku
   'PackCaptureNewLabelno', -- Configkey
   @b_success  OUTPUT,
   @c_authority OUTPUT,
   @n_err     OUTPUT,
   @c_errmsg  OUTPUT

IF @c_authority = '1'
BEGIN
 SET @cLabelNo = 'PreLabelNo'+RIGHT( '00000' + CAST( @nCartonNo AS NVARCHAR( 5)), 5)
END

IF ISNULL(@cLabelNo,'') =''
BEGIN
 SELECT @cLabelNo = LabelNo FROM PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND StorerKey = @cStorerKey
END

SET @cCartonNo = CONVERT(NVARCHAR(10),@nCartonNo)

DECLARE @SQLParam NVARCHAR(MAX)
IF ISNULL(@cLabelNo,'') =''
BEGIN
    --(cc02)
   SET @GetCartonID = '
   EXEC [API].[isp_GetPackCartonID] ''[{"StorerKey":"' +@cStorerKey+ '","Facility":"' +@cFacility + '","Func":"' +@nFunc + '","PickSlipNo":"' +@cPickSlipNo+ '","CartonNo":"' +@cCartonNo+ '","LangCode":"' +@cLangCode+ '"}]'' ,@jResult OUTPUT,@b_Success OUTPUT,@n_Err OUTPUT,@c_ErrMsg OUTPUT'
   --SELECT @GetCartonID

   SET @SQLParam = '
   @jResult NVARCHAR(MAX) OUTPUT,
   @b_Success  INT OUTPUT,
   @n_Err      INT OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) OUTPUT
   '
    EXEC sp_ExecuteSQL @GetCartonID,@SQLParam, @jResult OUTPUT , @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT

    IF @b_Success <> 1
    BEGIN
     GOTO EXIT_SP
    END
    ELSE
    BEGIN
     SET  @cLabelNo = LEFT(replace(@jResult,'[{',''),len(@jResult)-4)
    END
END

--Data Validate
SET @nTranCount = @@TRANCOUNT
BEGIN TRAN
SAVE TRAN isp_HoldCarton

--Hold: packHeader
IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo)
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
      SET @n_Err = 1001355
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackHeader. Function : isp_HoldCarton'
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
   SET @nCartonNO = 0
END

   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT SKU,QTY,Weight,CUBE,lottableVal,UPC 
   FROM @HoldCartonList

   OPEN @curPD
   FETCH NEXT FROM @curPD INTO @cSKU,@nQTY,@cWeight,@cCube,@cLottableJSON,@cUPCJSON 
   WHILE @@FETCH_STATUS <> -1
   BEGIN     
      --check pickQty<=packQty (per sku) 
      IF (SELECT ISNULL(SUM(QtyToPack),0) FROM @pickSKUDetail WHERE sku = @cSKU) < @nQTY  
      BEGIN  
         SET @b_Success = 0    
         SET @n_Err = 1001359    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Closed Quantity > Pick Quantity. Please enter valid Quantity. Function : isp_HoldCarton'    
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
            SET @cCurUPC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT UPC, SUM(QTY) 
            FROM OPENJSON(@cUPCJSON)  
            WITH (  
               UPC               NVARCHAR( 30)  '$.UPC',  
               QTY               INT            '$.QTY'
            )  
            WHERE ISNULL(UPC,'') <> ''
            GROUP BY  UPC

            OPEN @cCurUPC 
            FETCH NEXT FROM @cCurUPC INTO @cUPC,@nUPCQTY
            WHILE @@FETCH_STATUS <> -1  
            BEGIN  
                     -- Get LabelLine  
               SET @cLabelLine = ''  
               SET @nPackedQTY = 0
               SELECT @cLabelLine = LabelLine, @nPackedQTY = qty  
               FROM dbo.PackDetail WITH (NOLOCK)   
               WHERE PickSlipNo = @cPickSlipNo   
                  AND CartonNo = @nCartonNo  
                  AND LabelNo = @cLabelNo   
                  AND SKU = @cSKU  
                  and upc=@cupc
        
               IF @cLabelLine = ''  
                  SELECT @cLabelLine = LabelLine  
                  FROM dbo.PackDetail WITH (NOLOCK)   
                  WHERE PickSlipNo = @cPickSlipNo   
                     AND CartonNo = @nCartonNo  
                     AND LabelNo = @cLabelNo   
                     AND SKU = '' 
                     
               SET @nPackedQTY = CASE WHEN ISNULL(@nPackedQTY,'') ='' THEN 0 ELSE @nPackedQTY END 

               IF @nPackedQTY <> @nUPCQTY
               BEGIN
                  SET @nUPCQTY = @nUPCQTY - @nPackedQTY
                  -- Close: PackDetail  
                  IF NOT EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo AND cartonno =@nCartonNo AND SKU=@cSKU and upc=@cupc)  
                  BEGIN  
                     SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
                     FROM dbo.PackDetail (NOLOCK)  
                     WHERE Pickslipno = @cPickSlipNo  
                        AND CartonNo = @nCartonNo  
                        AND LabelNo = @cLabelNo  
      
                     -- Insert PackDetail  
                     INSERT INTO dbo.PackDetail  
                        (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,  
                        AddWho, AddDate, EditWho, EditDate, UPC)--(cc05)  
                     VALUES  
                        (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nUPCQTY, ISNULL(@cDropID,''),  
                           @cUserName, GETDATE(), @cUserName, GETDATE(),@cUPC) --(cc05)  
                     IF @@ERROR <> 0  
                     BEGIN  
                        SET @b_Success = 0    
                        SET @n_Err = 1001360    
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackDetail. Function : isp_HoldCarton'          
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
                        AND cartonno =@nCartonNo 
                        AND SKU = @cSKU 
                        and upc = @cupc
                     IF @@ERROR <> 0  
                     BEGIN           
                        SET @b_Success = 0    
                        SET @n_Err = 1001361    
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackDetail. Function : isp_HoldCarton'   
                        GOTO RollBackTran  
                     END
                  END  
               END

               SET @nQTY = @nQTY- @nUPCQTY

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
            DECLARE @cLottableValue NVARCHAR(30)
            DECLARE @nLotQTY INT

            SET @cCurLottable = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT Lottable,SUM(PackedQTY ) 
            FROM OPENJSON(@cLottableJSON)    
            WITH (  
               Lottable               NVARCHAR( 30)  '$.Lottable',  
               PackedQTY              INT            '$.PackedQty'
            )  
            WHERE ISNULL(Lottable,'') <> ''
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
                  AND LabelNo = @cLabelNo   
                  AND SKU = @cSKU  
                  and LOTTABLEVALUE=@cLottableValue
        
               IF @cLabelLine = ''  
                  SELECT @cLabelLine = LabelLine  
                  FROM dbo.PackDetail WITH (NOLOCK)   
                  WHERE PickSlipNo = @cPickSlipNo   
                     AND CartonNo = @nCartonNo  
                     AND LabelNo = @cLabelNo   
                     AND SKU = ''  
  
               --IF @cLabelLine = ''  
               --BEGIN  
               --   SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
               --   FROM dbo.PackDetail (NOLOCK)  
               --   WHERE Pickslipno = @cPickSlipNo  
               --      AND CartonNo = @nCartonNo  
               --      AND LabelNo = @cLabelNo  
               --END 

               SET @nPackedQTY = CASE WHEN ISNULL(@nPackedQTY,'') ='' THEN 0 ELSE @nPackedQTY END 

               IF @nPackedQTY <> @nLotQTY
               BEGIN
                   SET @nLotQTY = @nLotQTY - @nPackedQTY

                  -- Close: PackDetail  
                  IF NOT EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo AND cartonno =@nCartonNo AND SKU=@cSKU AND LOTTABLEVALUE = @cLottableValue)  
                  BEGIN  
                     SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
                     FROM dbo.PackDetail (NOLOCK)  
                     WHERE Pickslipno = @cPickSlipNo  
                        AND CartonNo = @nCartonNo  
                        AND LabelNo = @cLabelNo  
      
                     -- Insert PackDetail  
                     INSERT INTO dbo.PackDetail  
                        (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,  
                        AddWho, AddDate, EditWho, EditDate, LOTTABLEVALUE)--(cc05)  
                     VALUES  
                        (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nLotQTY, ISNULL(@cDropID,''),  
                           @cUserName, GETDATE(), @cUserName, GETDATE(), @cLottableValue) --(cc05)  
                     IF @@ERROR <> 0  
                     BEGIN  
                        SET @b_Success = 0    
                        SET @n_Err = 1001362    
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackDetail. Function : isp_HoldCarton'          
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
                        AND cartonno =@nCartonNo
                        AND SKU = @cSKU 
                        and LOTTABLEVALUE = @cLottableValue
                     IF @@ERROR <> 0  
                     BEGIN           
                        SET @b_Success = 0    
                        SET @n_Err = 1001363    
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackDetail. Function : isp_HoldCarton'   
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
            AND LabelNo = @cLabelNo   
            AND SKU = @cSKU  
            AND UPC = @cSKU
        
         IF @cLabelLine = ''  
            SELECT @cLabelLine = LabelLine  
            FROM dbo.PackDetail WITH (NOLOCK)   
            WHERE PickSlipNo = @cPickSlipNo   
               AND CartonNo = @nCartonNo  
               AND LabelNo = @cLabelNo   
               AND SKU = ''  
  
         --IF @cLabelLine = ''  
         --BEGIN  
         --   SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
         --   FROM dbo.PackDetail (NOLOCK)  
         --   WHERE Pickslipno = @cPickSlipNo  
         --      AND CartonNo = @nCartonNo  
         --      AND LabelNo = @cLabelNo 
         --END 

         SET @cUPC = @cSKU

         SET @nPackedQTY = CASE WHEN ISNULL(@nPackedQTY,'') ='' THEN 0 ELSE @nPackedQTY END 

         SET @nQTY = @nQTY - @nPackedQTY

         IF @nQTY > 0
         BEGIN
            -- Close: PackDetail  
            IF NOT EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo AND cartonno =@nCartonNo AND labelNo=@cLabelNo AND UPC = @cUPC AND SKU=@cSKU)
            BEGIN  
               SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)   
               FROM dbo.PackDetail (NOLOCK)  
               WHERE Pickslipno = @cPickSlipNo  
                  AND CartonNo = @nCartonNo  
                  AND LabelNo = @cLabelNo  
      
               -- Insert PackDetail  
               INSERT INTO dbo.PackDetail  
                  (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,  
                  AddWho, AddDate, EditWho, EditDate,UPC)--(cc05)  
               VALUES  
                  (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSKU, @nQTY, ISNULL(@cDropID,''),  
                     @cUserName, GETDATE(), @cUserName, GETDATE(),@cUPC) --(cc05)  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @b_Success = 0    
                  SET @n_Err = 1001364    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackDetail. Function : isp_HoldCarton'          
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
                  ArchiveCop = NULL
               WHERE PickSlipNo = @cPickSlipNo  
                  AND CartonNo = @nCartonNo  
                  AND LabelNo = @cLabelNo  
                  AND SKU = @cSKU 
                  AND UPC = @cUPC

               IF @@ERROR <> 0  
               BEGIN           
                  SET @b_Success = 0    
                  SET @n_Err = 1001365    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackDetail. Function : isp_HoldCarton'   
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
               SET @n_Err = 1001366    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into SKU. Function : isp_HoldCarton'   
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
                  SET @n_Err = 1001367    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into SKU. Function : isp_HoldCarton'   
                  GOTO RollBackTran  
               END 
            END    
         END   
      END     

      SELECT @ttlWeight = @ttlWeight + stdgrosswgt *@nQTY,
             @ttlCube = @ttlCube + stdcube *@nQTY
      FROM SKU (NOLOCK)
      WHERE SKU = @cSKU
         AND Storerkey = @cStorerkey
       
      FETCH NEXT FROM @curPD INTO @cSKU,@nQTY,@cWeight,@cCube,@cLottableJSON,@cUPCJSON  
   END 

  -- hold: PackInfo
  SELECT @nPackQtyCarton = SUM(Qty) FROM packDetail (NOLOCK) WHERE storerKey = @cStorerKey AND pickSlipNo = @cPickSlipNo AND cartonNo = @nCartonNo  

   IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
   BEGIN
      INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY, Weight, Cube, CartonType,CartonStatus, AddWho,AddDate,EditWho,EditDate)
      VALUES (@cPickSlipNo, @nCartonNo, @nPackQtyCarton, @ttlWeight, @ttlCube, @cCartonType,'Hold',@cUserName,GETDATE(),@cUserName,GETDATE())

      IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1001368
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to insert into PackInfo. Function : isp_HoldCarton'
         GOTO RollBackTran
      END
   END
   ELSE
   BEGIN
      UPDATE dbo.PackInfo WITH (ROWLOCK) SET
         CartonType = @cCartonType,
         Weight = @ttlWeight,
         [Cube] = @ttlCube,
         EditDate = GETDATE(),
         EditWho = @cUserName,
         TrafficCop = NULL,
         cartonStatus = 'Hold'
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo

      IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1001369
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PackInfo. Function : isp_HoldCarton'
         GOTO RollBackTran
      END
   END

   SELECT @cExtendedUpdateSP = svalue FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPSExtUpdHldSP'  
   IF @cExtendedUpdateSP <> ''    
   BEGIN    
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')    
      BEGIN    
         SET @cSQL = 'EXEC API.' + RTRIM( @cExtendedUpdateSP) +  
            ' @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo, ' +   
            ' @cpickslipNo, @cDropID, @cOrderKey, @cLoadKey, @cZone, @EcomSingle, ' +  
            ' @nCartonNo, @cCartonType, @cType, @fCartonWeight, @fCartonCube, @cWorkstation, @cLabelNo, ' +   
            ' @cHoldCartonJSON, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT '  
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
            '@cHoldCartonJSON NVARCHAR( Max), ' +  
            '@b_Success       INT            OUTPUT, ' +  
            '@n_Err           INT            OUTPUT, ' +  
            '@c_ErrMsg        NVARCHAR(255)  OUTPUT'  
  
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo,   
            @cpickslipNo, @cDropID, @cOrderKey, @cLoadKey, @cZone, @EcomSingle,  
            @nCartonNo, @cCartonType, @cType, @fCartonWeight, @fCartonCube, @cWorkstation, @cLabelNo,   
            @cHoldCartonJSON, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT  
    
         IF @b_Success <> 1  
         BEGIN           
          SET @b_Success = 0   
            SET @n_Err = @n_Err  
            SET @c_ErrMsg = @c_ErrMsg  
            SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
            GOTO RollBackTran  
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
               @cPrintPackList, @cLabelJobID OUTPUT, 
               @cPackingJobID OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT
    
            IF @b_Success <> 1  
            BEGIN  
               SET @b_Success = 0   
               SET @n_Err = @n_Err  
               SET @c_ErrMsg = @c_ErrMsg  
               SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )  
               GOTO RollBackTran  
            END             
         END    
      END    
      ELSE  
      BEGIN  
         --(cc03)  
         --DECLARE @tShipLabel AS VariableTable  

         ---- Common params ofr printing  
         --INSERT INTO @tShipLabel (Variable, Value) VALUES   
         --   ( '@c_StorerKey',     @cStorerKey),   
         --   ( '@c_PickSlipNo',    @cPickSlipNo),   
         --   ( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),  
         --   ( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))   

         --lookup printer  
         SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'  
         SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'  

      IF @cDisableLblPrint=0  
      BEGIN  
         -- Print label  
         IF EXISTS (SELECT  TOP 1 1 FROM dbo.WMReport WMR WITH (NOLOCK) 
                    JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
                    WHERE Storerkey = @cStorerKey 
                     AND reporttype ='TPSHIPPLBL')  
         BEGIN  
            SELECT   @c_ReportID = WMR.reportid,
               @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,
               @cNewLabelPrinter = Defaultprinterid,
               @cFieldName1  = keyFieldname1,
               @cFieldName2  = keyFieldname2,
               @cFieldName3  = keyFieldname3,
               @cFieldName4  = keyFieldname4
            FROM WMReport WMR (NOLOCK)
            JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
            WHERE Storerkey = @cStorerkey
               AND reporttype = 'TPSHIPPLBL'
               AND ModuleID ='TPPack'
               AND ispaperprinter <> 'Y'
               and (WMRD.username = '' OR WMRD.username = @cUsername)
               AND (ISNULL(ComputerName,'') ='' OR ComputerName= @cWorkstation)

            IF @@ROWCOUNT = 0
            BEGIN
               SET @b_Success = 0
               SET @n_Err = 1001370
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_HoldCarton'
               GOTO EXIT_SP
            END

            IF ISNULL(@cFieldName1,'') = ''
            BEGIN
               SET @b_Success = 0
               SET @n_Err = 1001371
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_HoldCarton'
               GOTO EXIT_SP
            END       
            
            SET @IsAggregate1 = CASE WHEN ISNULL(@cFieldName1,'') <> '' AND (
                                 UPPER(@cFieldName1) LIKE '%SUM(%' OR 
                                 UPPER(@cFieldName1) LIKE '%AVG(%' OR
                                 UPPER(@cFieldName1) LIKE '%COUNT(%' OR
                                 UPPER(@cFieldName1) LIKE '%MIN(%' OR
                                 UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                              ) THEN 1 ELSE 0 END

            SET @IsAggregate2 = CASE WHEN ISNULL(@cFieldName2,'') <> '' AND (
                                 UPPER(@cFieldName2) LIKE '%SUM(%' OR 
                                 UPPER(@cFieldName2) LIKE '%AVG(%' OR
                                 UPPER(@cFieldName2) LIKE '%COUNT(%' OR
                                 UPPER(@cFieldName2) LIKE '%MIN(%' OR
                                 UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                              ) THEN 1 ELSE 0 END

            SET @IsAggregate3 = CASE WHEN ISNULL(@cFieldName3,'') <> '' AND (
                                 UPPER(@cFieldName3) LIKE '%SUM(%' OR 
                                 UPPER(@cFieldName3) LIKE '%AVG(%' OR
                                 UPPER(@cFieldName3) LIKE '%COUNT(%' OR
                                 UPPER(@cFieldName3) LIKE '%MIN(%' OR
                                 UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                              ) THEN 1 ELSE 0 END

            SET @IsAggregate4 = CASE WHEN ISNULL(@cFieldName4,'') <> '' AND (
                                 UPPER(@cFieldName4) LIKE '%SUM(%' OR 
                                 UPPER(@cFieldName4) LIKE '%AVG(%' OR
                                 UPPER(@cFieldName4) LIKE '%COUNT(%' OR
                                 UPPER(@cFieldName4) LIKE '%MIN(%' OR
                                 UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                              ) THEN 1 ELSE 0 END


            SET  @cSQL =
            ' SELECT  @cParams1='+ @cFieldName1  
                     SELECT @cSQL= CASE  WHEN ISNULL(@cFieldName2,'')<>''THEN @cSQL +',@cParams2=' + @cFieldName2  ELSE  @cSQL END 
                     SELECT @cSQL= CASE WHEN ISNULL(@cFieldName3,'')<>''THEN @cSQL +',@cParams3='  + @cFieldName3  ELSE  @cSQL END
                     SELECT @cSQL= CASE WHEN ISNULL(@cFieldName4,'')<>''THEN @cSQL +',@cParams4='  + @cFieldName4  ELSE  @cSQL END
            SET @cSQL = @cSQL +' FROM Packdetail (NOLOCK)
               WHERE Storerkey = @cstorerkey
                  AND Pickslipno = @cPickslipno
                  AND CartonNo = @nCartonno '

            SET @groupByFields = ''

            IF ISNULL(@cFieldName1, '') <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName1

            IF ISNULL(@cFieldName2, '') <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
               SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName2

            IF ISNULL(@cFieldName3, '') <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
                  SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName3

            IF ISNULL(@cFieldName4, '') <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
                  SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName4

            -- If any valid fields found, append GROUP BY
            IF LEN(@groupByFields) > 0
                  SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

            SET @cSQLParam = 
            ' @cFieldName1 NVARCHAR(max),
               @cFieldName2 NVARCHAR(max),
               @cFieldName3 NVARCHAR(max),
               @cFieldName4 NVARCHAR(max),
               @cParams1    NVARCHAR(max) OUTPUT,
               @cParams2    NVARCHAR(max) OUTPUT,
               @cParams3    NVARCHAR(max) OUTPUT,
               @cParams4    NVARCHAR(max) OUTPUT,
               @cstorerkey  NVARCHAR(20),
               @cPickslipno NVARCHAR(20),
               @nCartonno   INT'

            EXEC sp_ExecuteSQL @cSQL,@cSQLParam,@cFieldName1,@cFieldName2,@cFieldName3,@cFieldName4,
                                 @cParams1 OUTPUT,@cParams2 OUTPUT,@cParams3 OUTPUT,@cParams4 OUTPUT,@cstorerkey,@cPickslipno,@nCartonno 
            

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
                     SET @n_Err = 1001372    
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_HoldCarton'  
                     SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH )   
                     GOTO EXIT_SP  
                  END
                  SET @cNewLabelPrinter = @cPrinterInGroup
               END
            END

            IF ISNULL(@cNewLabelPrinter,'') = ''  
            BEGIN  
               SET @b_Success = 0    
               SET @n_Err = 1001373    
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_HoldCarton'  
               SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH )   
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

                 EXEC  [WM].[lsp_WM_Print_Report]
                    @c_ModuleID = @c_ModuleID           
                  , @c_ReportID = @c_ReportID         
                  , @c_Storerkey = @cStorerkey         
                  , @c_Facility  = @cFacility        
                  , @c_UserName  = @cUsername   
                  , @c_ComputerName = ''
                  , @c_PrinterID = @cNewLabelPrinter         
                  , @n_NoOfCopy  = '1'     
                  , @c_KeyValue1 = @cParams1        
                  , @c_KeyValue2 = @cParams2        
                  , @c_KeyValue3 = @cParams3     
                  , @c_KeyValue4 = @cParams4    
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
                  SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH )   
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
                        AND reportType ='TPPACKLIST')  
            BEGIN  
               IF ISNULL(@cPaperPrinter,'') = ''  
               BEGIN  
                  SET @b_Success = 0    
                  SET @n_Err = 1001374    
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Paper Printer setup not done. Please setup the Paper Printer. Function : isp_HoldCarton'  
                  SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH )   
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

                  EXEC  [WM].[lsp_WM_Print_Report]
                     @c_ModuleID = @c_ModuleID           
                  , @c_ReportID = @c_ReportID         
                  , @c_Storerkey = @cStorerkey         
                  , @c_Facility  = @cFacility        
                  , @c_UserName  = @cUsername     
                  , @c_ComputerName = ''
                  , @c_PrinterID = @cPaperPrinter         
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
                     SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH )   
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
                  '@cErrMsg         NVARCHAR(255) OUTPUT'    
    
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
                  @cStorerKey, @cFacility, @cPickSlipNo, @cLabelPrinter, @cPaperPrinter, @nErrNo OUTPUT, @cErrMsg OUTPUT    
    
               IF @nErrNo <> 0    
                  GOTO Quit    
            END  
         END  
     
     
      IF EXISTS (SELECT  TOP 1 1 FROM dbo.WMReport WMR WITH (NOLOCK) 
                  JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
                  WHERE Storerkey = @cStorerKey 
                     AND reportType ='TPCtnLbl')   
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
            SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag                   
                           ,(CASE WHEN ISNULL(@cShowCartonNo,'') = '1' THEN @nCartonNo ELSE NULL END) AS CartonNo
                           FOR JSON PATH )    
            GOTO EXIT_SP  
         END  
      END  
      END  
   END  

   SET @b_Success = 1
   SET @jResult = '[{Success}]'
   SET @n_Err = 0
   SET @c_ErrMsg = ''
   GOTO Quit


   RollBackTran:
      ROLLBACK TRAN isp_HoldCarton
      SET @b_Success = 0
      SET @jResult = ''

   Quit:
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
       COMMIT TRAN isp_HoldCarton


   EXIT_SP:
   IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'lsp_RevertUser' AND type = 'P') AND SESSION_CONTEXT(N'mwms_user_name') IS NOT NULL
   BEGIN
      EXEC [WM].[lsp_RevertUser]
   END
   REVERT
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_HoldCarton TO NSQL
GO


