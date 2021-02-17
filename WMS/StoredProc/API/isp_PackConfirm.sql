IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[isp_PackConfirm]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[isp_PackConfirm]
GO
/****** Object:  StoredProcedure [API].[isp_PackConfirm]    Script Date: 6/3/2020 4:58:54 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_PackConfirm                                           */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2020-04-09   1.0  Chermaine  Created                                       */
/******************************************************************************/

CREATE PROC [API].[isp_PackConfirm] (
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
	@cOriUserName     NVARCHAR( 128),
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
   @cLoadKey         NVARCHAR( 10),
   @cOrderKey        NVARCHAR( 10),
   @nPickQty         INT,
   @nPackQty         INT,
   @nPackQtyCarton   INT,

   @cUPC             NVARCHAR( 30),
   @cLabelLine       NVARCHAR(5),
   @CalOrderSKU      NVARCHAR( 1),
   @EcomSingle       NVARCHAR( 1),
   @nProceedPrintFlag NVARCHAR( 1),
   
   @cDymEcomCtnWgtTb    NVARCHAR( 20),
   @cDymEcomCtnWgtCol   NVARCHAR( 20),
   @cDymEcomCtnCubeTb   NVARCHAR( 20),
   @cDymEcomCtnCubeCol  NVARCHAR( 20),
   @UpdDymEcomWeight    NVARCHAR( 1),
   @UpdDymEcomCube      NVARCHAR( 1),
   @cDymWgtSQL          NVARCHAR( MAX),
   @cDymCubeSQL         NVARCHAR( MAX),
   @cCartonWeight       NVARCHAR( 10),
   @cCartonCube         NVARCHAR( 10),

   @bSuccess         INT,
   @nErrNo           INT, 
   @cErrMsg          NVARCHAR(250),
   @nTranCount       INT,
   @curPD            CURSOR,
   @GetCartonID      NVARCHAR( MAX),
   @cShipLabel       NVARCHAR( 10),
   @nJobID           INT,
   @cWorkstation     NVARCHAR( 30),
   @pickSkuDetailJson   NVARCHAR( MAX),
   @bToPrint         INT

SET @UpdDymEcomWeight = 'N'
SET @EcomSingle = '0'
SET @UpdDymEcomCube = 'N'
SET @nProceedPrintFlag = '0'
SET @bToPrint = 1

DECLARE @CartonIDList TABLE (
   CartonID        NVARCHAR( 20)
)

DECLARE @CloseCartonList TABLE (
   SKU             NVARCHAR( 20),
   QTY             INT,
   Weight          FLOAT,
   Cube            Float  
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
select @cStorerKey = StorerKey, @cFacility = Facility,@nFunc = Func,@cUserName = UserName,@cLangCode = LangCode,@cScanNo = ScanNo,@nCartonNo = CartonNo,@cCartonType = CartonType, @cType = ctype, @fCartonWeight = CartonWeight, @fCartonCube = CartonCube, @cWorkstation = Workstation, @cCloseCartonJson=CloseCarton
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
      CloseCarton    NVARCHAR( max) as json
   ) 
   
   --SELECT @cUserName AS cUserNameb4
--SELECT @cStorerKey AS StorerKey, @cFacility AS Facility,@nFunc AS Func,@cUserName AS UserName,@cScanNo AS ScanNo,@nCartonNo AS CartonNo,@ctype AS ctype,@cWeight AS cWeight, @cCube AS cCube

INSERT INTO @CloseCartonList
SELECT *
FROM OPENJSON(@cCloseCartonJson)
WITH (
      SKU             NVARCHAR( 20) '$.SKU',
      Qty             INT           '$.PackedQty',
      Weight          Float         '$.WEIGHT',
      Cube            Float         '$.CUBE'
)

--SELECT * FROM @CloseCartonList

SET @cCartonWeight = CONVERT(NVARCHAR(10),@fCartonWeight)
SET @cCartonCube = CONVERT(NVARCHAR(10),@fCartonCube)
SET @cOriUserName = @cUserName
--convert login 
SET @n_Err = 0 
EXEC [WM].[lsp_SetUser] @c_UserName = @cUserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

EXECUTE AS LOGIN = @cUserName

IF @n_Err <> 0 
BEGIN  
   --INSERT INTO @errMsg(nErrNo,cErrMsg)  
   SET @b_Success = 0  
   SET @n_Err = @n_Err  
   SET @c_ErrMsg = @c_ErrMsg 
   --SET @jResult = (select @nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH ) 
   SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )
   GOTO EXIT_SP  
END  
--SELECT @cUserName AS cUserName
--SELECT SUSER_NAME() AS sname


--check pickslipNo
EXEC [API].[isp_GetPicklsipNo] @cStorerKey,@cFacility,@nFunc,@cLangCode,@cScanNo,@cType,@cUserName, @jResult OUTPUT,@b_Success OUTPUT,@n_Err OUTPUT,@c_ErrMsg OUTPUT

IF @n_Err <>0
BEGIN
	--SET @jResult = ''
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

IF EXISTS (SELECT sku FROM @CloseCartonList EXCEPT SELECT sku FROM @pickSKUDetail)
BEGIN
	SET @b_Success = 0  
   SET @n_Err = 101400  
   SET @c_ErrMsg = 'Invalid SKU. Scanned SKU not found in SKU table.'
   --SET @jResult = (select @nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH ) 
   SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )
         
   GOTO EXIT_SP
END


IF @EcomSingle IN ('1','2')
BEGIN
	DECLARE @cEcomSKU NVARCHAR( 30)
	         
	SELECT @cEcomSKU = SKU FROM @CloseCartonList
	         
	SELECT TOP 1 @cOrderKey = orderkey,@cPickSlipNo = PickslipNo, @cLoadKey = LoadKey
	FROM @pickSKUDetail 
	WHERE pickslipNo NOT IN (SELECT DISTINCT pickslipNo FROM packDetail WITH (NOLOCK) WHERE storerKey = @cStorerKey AND SKU = @cEcomSKU)
	AND sku = @cEcomSKU
	         	         
	SELECT @cOrderKey AS cOrderKeyEcom, @cPickSlipNo AS cPickSlipNoEcom
END
SELECT @cOrderKey AS orderKeyAAAAA

--SELECT @cEcomSKU AS ecomSKU	         
--SELECT * FROM @pickSKUDetail
--SELECT @cPickSlipNo AS pickslipno
--GOTO EXIT_SP

--check status     
IF EXISTS (SELECT TOP 1 1 FROM packInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND CartonStatus = 'Hold')
BEGIN
   SET @b_Success = 0  
   SET @n_Err = 101401  
   SET @c_ErrMsg = 'Carton No in On-Hold Status. Unable to proceed to Closed Carton. Please Unhold this Carton to proceed.'
   --SET @jResult = (select @nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH ) 
   SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )
         
   GOTO EXIT_SP
END

-- Check pack confirm already
IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')
BEGIN
   SET @b_Success = 0  
   SET @n_Err = 101402  
   SET @c_ErrMsg = 'Pickslip No is already Closed/Packed.'
   --SET @jResult = (select @nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH ) 
   SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )
   
   GOTO EXIT_SP
END

-- Check pack confirm already
IF EXISTS( SELECT 1 FROM PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND cartonNo = @nCartonNo AND cartonStatus = 'Closed')
BEGIN
   SET @b_Success = 0  
   SET @n_Err = 101403  
   SET @c_ErrMsg = 'Carton No is already Closed/Packed.'
   --SET @jResult = (select @nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH ) 
   SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )
   
   GOTO EXIT_SP
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
         SET @n_Err = 101404
         SET @c_ErrMsg = 'Incorrect dynamic E-Comm Carton Weight column setup. Function : isp_PackConfirm'
         --SET @jResult = (select @nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH ) 
         SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )
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
         SET @n_Err = 101405
         SET @c_ErrMsg = 'Incorrect dynamic E-Comm Cube column setup. Function : isp_packConfirm'
         --SET @jResult = (select @nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH ) 
         SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )
         GOTO EXIT_SP
      END
      ELSE
      BEGIN
      	SET @UpdDymEcomCube = 'Y'
      END
   END
END
		   

--Get CartonID to insert/update packDetail
SELECT @cCartonID = LabelNo FROM PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND StorerKey = @cStorerKey
--SELECT @cCartonID AS cCartonID

DECLARE @SQLParam NVARCHAR(MAX) 
IF ISNULL(@cCartonID,'') ='' 
BEGIN   
      	
   SET @GetCartonID = '     
   EXEC [API].[isp_GetPackCartonID] ''[{"StorerKey":"' +@cStorerKey+ '","Facility":"' +@cFacility + '","Func":"' +@nFunc + '","PickSlipNo":"' +@cPickSlipNo+ '"}]'' ,@jResult OUTPUT,@b_Success OUTPUT,@n_Err OUTPUT,@c_ErrMsg OUTPUT'
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
--SAVE TRAN isp_PackConfirm

--Close: packHeader
IF NOT EXISTS( SELECT TOP 1 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo)
BEGIN
   INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey, AddWho, AddDate)
   VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey, SUSER_NAME(), GETDATE())
   IF @@ERROR <> 0
   BEGIN      
      SET @b_Success = 0  
      SET @n_Err = 101406  
      SET @c_ErrMsg = 'Fail to insert into PackHeader. Function : isp_PackConfirm'

      GOTO RollBackTran
   END
END

-- Close: PackInfo
DECLARE @cWeightItf INT

SET @cWeightItf = 0

IF (@fCartonWeight > 0 OR @fCartonCube > 0) 
BEGIN
	IF @fCartonWeight > 30 
	BEGIN
		SET @cWeightItf = 1
	END
	
	--SELECT 'update cartonWeight'
	IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
   BEGIN
      INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY, Weight, Cube, CartonType,CartonStatus, AddWho,AddDate,EditWho,EditDate)
      VALUES (@cPickSlipNo, @nCartonNo, @nPackQtyCarton, @fCartonWeight, @fCartonCube, @cCartonType,'Closed',SUSER_NAME(),GETDATE(),SUSER_NAME(),GETDATE())
   
      IF @@ERROR <> 0
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 101413  
         SET @c_ErrMsg = 'Fail to insert into PackInfo. Function : isp_PackConfirm'
                
         GOTO RollBackTran
      END
   END
   ELSE
   BEGIN
      UPDATE dbo.PackInfo WITH (ROWLOCK) SET 
         Qty = @nPackQtyCarton,
         CartonType = @cCartonType,
         Weight = @fCartonWeight,
         [Cube] = @fCartonCube,
         EditDate = GETDATE(), 
         EditWho = SUSER_NAME(), 
         TrafficCop = NULL,
         cartonStatus = 'Closed'
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
      
      IF @@ERROR <> 0
      BEGIN      
         SET @b_Success = 0  
         SET @n_Err = 101414  
         SET @c_ErrMsg = 'Fail to update into PackInfo. Function : isp_PackConfirm'

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
	
	SELECT @ttlWeight = SUM(WEIGHT),@ttlCube = SUM(CUBE) FROM @CloseCartonList
	IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
   BEGIN
      INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY, Weight, Cube, CartonType,CartonStatus, AddWho,AddDate,EditWho,EditDate)
      VALUES (@cPickSlipNo, @nCartonNo, @nPackQtyCarton, @ttlWeight, @ttlCube, @cCartonType,'Closed',SUSER_NAME(),GETDATE(),SUSER_NAME(),GETDATE())
   
      IF @@ERROR <> 0
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 101414  
         SET @c_ErrMsg = 'Fail to insert into PackInfo. Function : isp_PackConfirm'
                
         GOTO RollBackTran
      END
   END
   ELSE
   BEGIN
      UPDATE dbo.PackInfo WITH (ROWLOCK) SET 
         QTY = @nPackQtyCarton,
         CartonType = @cCartonType,
         Weight = @ttlWeight,
         [Cube] = @ttlCube,
         EditDate = GETDATE(), 
         EditWho = SUSER_NAME(), 
         TrafficCop = NULL,
         cartonStatus = 'Closed'
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
      
      IF @@ERROR <> 0
      BEGIN      
         SET @b_Success = 0  
         SET @n_Err = 101415  
         SET @c_ErrMsg = 'Fail to update into PackInfo. Function : isp_PackConfirm'

         GOTO RollBackTran
      END
   END
END

DECLARE @cSQL NVARCHAR (MAX)
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

   
--Close: packDetail
SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT SKU,QTY,WEIGHT,cube
   FROM @CloseCartonList
   
OPEN @curPD
FETCH NEXT FROM @curPD INTO @cSKU,@nQTY,@cWeight,@cCube
WHILE @@FETCH_STATUS <> -1
BEGIN

   SET @cUPC = LEFT( @cSKU, 30) -- SKU
   
   -- Check SKU blank
   IF @cSKU = ''
   BEGIN   
      SET @b_Success = 0  
      SET @n_Err = 101407  
      SET @c_ErrMsg = 'No SKU entered. Please enter or scan valid SKU.'
      
      GOTO RollBackTran
   END
      
   -- Check blank QTY
   IF @nQTY = 0
   BEGIN     
      SET @b_Success = 0  
      SET @n_Err = 101408  
      SET @c_ErrMsg = 'No Quantity entered. Please enter valid Quantity.'
               
      GOTO RollBackTran
   END 
      
   IF @nQTY <> '' AND ISNULL(@nQTY,0) = 0 --RDT.rdtIsValidQTY( @nQTY, 1) = 0 --Check zero
   BEGIN   
      SET @b_Success = 0  
      SET @n_Err = 101409  
      SET @c_ErrMsg = 'Invalid Quantity entered. Please enter valid Quantity.'
         
      GOTO RollBackTran
   END
      
   --check pickQty<=packQty (per sku)
   SELECT @nPackQty = ISNULL(SUM(Qty),0) FROM PackDetail WITH (NOLOCK) WHERE pickslipno = @cPickSlipNo AND SKU = @csku AND Storerkey = @cStorerKey
   SELECT @nPackQtyCarton = ISNULL(SUM(Qty),0) FROM PackDetail WITH (NOLOCK) WHERE pickslipno = @cPickSlipNo AND SKU = @csku AND Storerkey = @cStorerKey AND cartonNo = @nCartonNo
   SELECT @nPickQty = QtyToPack FROM @pickSKUDetail WHERE sku = @cSKU
     
   IF @nPickQty < @nQTY
   BEGIN
     	SET @b_Success = 0  
      SET @n_Err = 101410  
      SET @c_ErrMsg = 'Closed Quantity > Pick Quantity. Please enter valid Quantity.'
         
      GOTO RollBackTran
   END
        
   -- Get LabelLine
   SET @cLabelLine = ''
   SELECT @cLabelLine = LabelLine
   FROM dbo.PackDetail WITH (NOLOCK) 
   WHERE PickSlipNo = @cPickSlipNo 
      AND CartonNo = @nCartonNo
      AND LabelNo = @cCartonID 
      AND SKU = @cSKU
      
   IF @cLabelLine = ''
      SELECT @cLabelLine = LabelLine
      FROM dbo.PackDetail WITH (NOLOCK) 
      WHERE PickSlipNo = @cPickSlipNo 
         AND CartonNo = @nCartonNo
         AND LabelNo = @cCartonID 
         AND SKU = ''

   IF @cLabelLine = ''
   BEGIN
      SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5) 
      FROM dbo.PackDetail (NOLOCK)
      WHERE Pickslipno = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cCartonID
   END

   -- Close: PackDetail
   IF NOT EXISTS( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo AND cartonno =@nCartonNo AND labelNo=@cCartonID AND SKU=@cSKU)
   BEGIN
      -- Insert PackDetail
      INSERT INTO dbo.PackDetail
         (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, DropID,
         AddWho, AddDate, EditWho, EditDate)
      VALUES
         (@cPickSlipNo, @nCartonNo, @cCartonID, @cLabelLine, @cStorerKey, @cSKU, @nQTY, ISNULL(@cDropID,''),
            SUSER_NAME(), GETDATE(), SUSER_NAME(), GETDATE())
      IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0  
         SET @n_Err = 101411  
         SET @c_ErrMsg = 'Fail to insert into PackDetail. Function : isp_PackConfirm' 
                
         GOTO RollBackTran
      END
   END
   ELSE
   BEGIN
      -- Update Packdetail
      UPDATE dbo.PackDetail WITH (ROWLOCK) SET   
         SKU = @cSKU, 
         QTY = @nQTY, 
         DropID = ISNULL(@cDropID,''),
         EditWho =  SUSER_NAME(), 
         EditDate = GETDATE(), 
         ArchiveCop = NULL
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cCartonID
         AND LabelLine = @cLabelLine
      IF @@ERROR <> 0
      BEGIN         
         SET @b_Success = 0  
         SET @n_Err = 101412  
         SET @c_ErrMsg = 'Fail to update into PackDetail. Function : isp_PackConfirm' 
               
         GOTO RollBackTran
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
   		END  
   	END	
   END   
     
   FETCH NEXT FROM @curPD INTO @cSKU,@nQTY,@cWeight,@cCube
END
SELECT @nPackQtyCarton = SUM(Qty) FROM packDetail WHERE storerKey = @cStorerKey AND pickSlipNo = @cPickSlipNo AND cartonNo = @nCartonNo


-- check Qty on pickslip 
DECLARE @nPickslipPackQty INT
DECLARE @nPickslipPickQty INT
Declare @nPrintPackList   NVARCHAR( 1)

SET @nPrintPackList = 'N'

SELECT @nPickslipPackQty = ISNULL(SUM(PD.Qty),0) 
FROM PackDetail PD WITH (NOLOCK) 
JOIN packInfo PKI WITH (NOLOCK) ON (PD.PickSlipNo = PKI.PickSlipNo AND PD.CartonNo = PKI.CartonNo)
WHERE PD.pickslipno = @cPickSlipNo AND PD.Storerkey = @cStorerKey AND PKI.CartonStatus = 'Closed'

SELECT @nPickslipPickQty = SUM(QtyToPack) FROM @pickSKUDetail WHERE pickslipNo = @cPickSlipNo

INSERT INTO traceInfo (TraceName, col1,Col2,Col3,Col4)
VALUES('touchpadConfirm',@cPickSlipNo,@nPickslipPackQty,@nPickslipPickQty,GETDATE())

IF @nPickslipPackQty = @nPickslipPickQty
BEGIN
	
	UPDATE PackHeader WITH (ROWLOCK) SET 
      Status = '9' 
   WHERE PickSlipNo = @cPickSlipNo
      AND Status <> '9'
      
   IF @@ERROR <> 0
   BEGIN
      SET @b_Success = 0  
      SET @n_Err = 101417  
      SET @c_ErrMsg = 'Fail to update into PackHeader. Function : isp_PackConfirm'
         
      GOTO RollBackTran
   END
      

   SET @nPrintPackList = 'Y'
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
         
         SELECT @b_Success AS b_Success, @n_Err AS n_Err, @c_ErrMsg AS c_ErrMsg
   
   IF @n_Err > 0
      BEGIN
    	SET @b_Success = 0  
    	SET @n_Err = @n_Err
    	SET @c_ErrMsg = @c_ErrMsg
    	
             
      GOTO RollBackTran
      END   
END

UPDATE api.appsection WITH (ROWLOCK)
SET pickslipNo = @cPickSlipNo
WHERE userID = @cOriUserName
AND scanNo = @cScanNo


GOTO Quit
      
RollBackTran:
   ROLLBACK TRAN --isp_PackConfirm
   SET @b_Success = 0
   --SET @jResult = (select @nProceedPrintFlag AS nProceedPrintFlag FOR JSON PATH ) 
   SET @jResult = (select '' AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, '' AS VasConfig, '' AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH )
   SET @bToPrint = 0
   --SELECT @bToPrint AS bToPrint

Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN --isp_PackConfirm

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
         SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, @nVasConfig AS VasConfig, @cVasCol1Name AS VasCol1Name, '' AS VasCol1Value, '' AS WorkInstruction FOR JSON PATH ) 
         
         GOTO EXIT_SP
         END  
	END
END

IF @bToPrint = 1
BEGIN
	-- Common params ofr printing
   DECLARE @tShipLabel AS VariableTable
   INSERT INTO @tShipLabel (Variable, Value) VALUES 
      ( '@c_StorerKey',     @cStorerKey), 
      ( '@c_PickSlipNo',    @cPickSlipNo), 
      ( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),
      ( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))

   --lookup printer
   DECLARE @cLabelPrinter NVARCHAR ( 30)
   DECLARE @cPaperPrinter NVARCHAR ( 30)
   DECLARE @cLabelJobID   NVARCHAR ( 30)
   DECLARE @cPackingJobID NVARCHAR ( 30)

   set @cLabelJobID = ''
   set @cPackingJobID = ''
   SET @nProceedPrintFlag = '1'

   SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'
   SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'

   -- Print label
   IF EXISTS (select TOP 1 1 FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND reportType ='TPSHIPPLBL')
   BEGIN
	   IF ISNULL(@cLabelPrinter,'') = ''
	   BEGIN
		   SET @b_Success = 0  
            SET @n_Err = 101418  
            SET @c_ErrMsg = 'Label Printer setup not done. Please setup the Label Printer.'
            SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, @nVasConfig AS VasConfig, @cVasCol1Name AS VasCol1Name, @cVasCol1Value AS VasCol1Value, @cWorkInstruction AS WorkInstruction FOR JSON PATH ) 

            GOTO EXIT_SP
	   END
	   ELSE
	   BEGIN
		   EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, 
         'TPSHIPPLBL', -- Report type
         @tShipLabel, -- Report params
         'API.isp_PackConfim', --source Type
         @n_Err  OUTPUT,
         @c_ErrMsg OUTPUT,
         '1', --noOfCopy
         '', --@cPrintCommand
         @nJobID OUTPUT,
         @cUsername

         set @cLabelJobID = @nJobID

         IF @n_Err <> 0 
         BEGIN
            SET @b_Success = 0
            SET @n_Err = @n_Err
            SET @c_ErrMsg = @c_ErrMsg
            SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, @nVasConfig AS VasConfig, @cVasCol1Name AS VasCol1Name, @cVasCol1Value AS VasCol1Value, @cWorkInstruction AS WorkInstruction FOR JSON PATH ) 
         
            GOTO EXIT_SP
         END
	   END	
   END


   IF @nPrintPackList = 'Y' 
   BEGIN
      IF EXISTS (select TOP 1 1 FROM rdt.rdtReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND reportType ='TPPACKLIST')
      BEGIN
	      IF ISNULL(@cPaperPrinter,'') = ''
	      BEGIN
		      SET @b_Success = 0  
               SET @n_Err = 101419  
               SET @c_ErrMsg = 'Paper Printer setup not done. Please setup the Paper Printer.'
               SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, @nVasConfig AS VasConfig, @cVasCol1Name AS VasCol1Name, @cVasCol1Value AS VasCol1Value, @cWorkInstruction AS WorkInstruction FOR JSON PATH ) 

               GOTO EXIT_SP
	      END
	      ELSE
	      BEGIN
		      EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, 
            'TPPACKLIST', -- Report type
            @tShipLabel, -- Report params
            'API.isp_PackConfim', --source Type
            @n_Err  OUTPUT,
            @c_ErrMsg OUTPUT,
            '1', --noOfCopy
            '', --@cPrintCommand
            @nJobID OUTPUT,
            @cUsername

            SET @cPackingJobID = @nJobID

            IF @n_Err <> 0 
            BEGIN
               SET @b_Success = 0
               SET @n_Err = @n_Err
               SET @c_ErrMsg = @c_ErrMsg
               SET @jResult = (select @cOrderKey AS OrderKey, '' as LabelJobID, '' as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, @nVasConfig AS VasConfig, @cVasCol1Name AS VasCol1Name, @cVasCol1Value AS VasCol1Value, @cWorkInstruction AS WorkInstruction FOR JSON PATH ) 
            
               GOTO EXIT_SP
            END
	      END	
      END
   END
END

IF @b_Success = 1
BEGIN
   SET @n_Err = 0
   SET @c_ErrMsg = ''
   SET @jResult = (select @cOrderKey AS OrderKey, @cLabelJobID as LabelJobID, @cPackingJobID as PackingJobID ,@nProceedPrintFlag AS nProceedPrintFlag, @nVasConfig AS VasConfig, @cVasCol1Name AS VasCol1Name, @cVasCol1Value AS VasCol1Value, @cWorkInstruction AS WorkInstruction FOR JSON PATH ) 
END   
         
EXIT_SP:
REVERT

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_PackConfirm TO NSQL
GO


