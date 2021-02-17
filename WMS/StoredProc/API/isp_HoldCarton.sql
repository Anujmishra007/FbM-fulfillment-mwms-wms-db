IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[isp_HoldCarton]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[isp_HoldCarton]
GO

/****** Object:  StoredProcedure [API].[isp_HoldCarton]    Script Date: 6/3/2020 4:57:55 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_HoldCarton                                            */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2020-03-24   1.0  Chermaine  Created                                       */
/******************************************************************************/

CREATE PROC [API].[isp_HoldCarton] (
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
   @cScanNo          NVARCHAR( 50),
   @cDropID          NVARCHAR( 50),
   @cPickSlipNo      NVARCHAR( 30),
   @nCartonNo        INT,
   @cCartonID        NVARCHAR( 20),
   @cType            NVARCHAR( 30),
   @nQTY             INT,
   @cSKU             NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            FLOAT,
   @cWeight          FLOAT,
   @cHoldCartonJson  NVARCHAR( MAX),
   @cLoadKey         NVARCHAR( 10),
   @cOrderKey        NVARCHAR( 10),
   @nPickQty         INT,
   @nPackQty         INT,

   @cUPC             NVARCHAR( 30),
   @cLabelLine       NVARCHAR(5),
   @cScanNoType      NVARCHAR( 30),
   @cZone            NVARCHAR( 18),

   @bSuccess         INT,
   @nErrNo           INT, 
   @cErrMsg          NVARCHAR(250),
   @nTranCount       INT,
   @curPD            CURSOR,
   @GetCartonID      NVARCHAR( MAX),
   @pickSkuDetailJson   NVARCHAR( MAX)
   --@nCtnRn           INT,
   --@cCtnTyp          NVARCHAR( 10),
   --@cCtnTyp1         NVARCHAR( 10),  
   --@cCtnTyp2         NVARCHAR( 10),  
   --@cCtnTyp3         NVARCHAR( 10),  
   --@cCtnTyp4         NVARCHAR( 10),  
   --@cCtnTyp5         NVARCHAR( 10),
   --@curCtn           CURSOR,
   --@cCartonGroup     NVARCHAR( 30) 


DECLARE @HoldCartonList TABLE (
   SKU             NVARCHAR( 20),
   QTY             INT,
   Weight          FLOAT,
   Cube            FLOAT   
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
select @cStorerKey = StorerKey, @cFacility = Facility,@nFunc = Func,@cUserName = UserName,@cLangCode = LangCode,@cScanNo = ScanNo,@nCartonNo = CartonNo, @cType = ctype,@cHoldCartonJson=HoldCarton--,@cCartonID = CartonID, @cSKU = SKU, @nQTY = QTY, @cWeight = Weight, @cCube = Cube
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
      HoldCarton  NVARCHAR( max) as json
   ) 
   
   --SELECT @cUserName AS cUserNameb4
--SELECT @cStorerKey AS StorerKey, @cFacility AS Facility,@nFunc AS Func,@cUserName AS UserName,@cScanNo AS ScanNo,@nCartonNo AS CartonNo,@ctype AS ctype

INSERT INTO @HoldCartonList
SELECT *
FROM OPENJSON(@cHoldCartonJson)
WITH (
      SKU             NVARCHAR( 20) '$.SKU',
      Qty             INT           '$.PackedQty',
      Weight          FLOAT         '$.WEIGHT',
      Cube            FLOAT         '$.CUBE'
)

--SELECT * FROM @HoldCartonList

--convert login 
SET @n_Err = 0 
EXEC [WM].[lsp_SetUser] @c_UserName = @cUserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

EXECUTE AS LOGIN = @cUserName

IF @n_Err <> 0 
BEGIN  
   --INSERT INTO @errMsg(nErrNo,cErrMsg)  
   SET @b_Success = 0  
   SET @n_Err = @n_Err  
--   SET @c_ErrMsg = @c_ErrMsg 
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


IF EXISTS (SELECT sku FROM @HoldCartonList EXCEPT SELECT sku FROM @pickSKUDetail)
BEGIN
	SET @b_Success = 0  
   SET @n_Err = 101300  
   SET @c_ErrMsg = 'Invalid SKU. Scanned SKU not found in SKU table.'
         
   GOTO EXIT_SP
END

SELECT @cPickSlipNo AS pickslipno


--check status     
IF EXISTS (SELECT TOP 1 1 FROM packInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND CartonStatus = 'Hold')
BEGIN
   SET @b_Success = 0  
   SET @n_Err = 101301  
   SET @c_ErrMsg = 'Carton No is already in On-Hold Status.'
         
   GOTO EXIT_SP
END

-- Check pack confirm already
IF EXISTS( SELECT 1 FROM PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND cartonNo = @nCartonNo AND cartonStatus = 'Closed')
BEGIN
   SET @b_Success = 0  
   SET @n_Err = 101302  
   SET @c_ErrMsg = 'Carton No is already Closed/Packed.'
   
   GOTO EXIT_SP
END

IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')
BEGIN
   SET @b_Success = 0  
   SET @n_Err = 101303  
   SET @c_ErrMsg = 'Pickslip No is already Closed/Packed.'
   
   GOTO EXIT_SP
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
SAVE TRAN isp_HoldCarton

--Hold: packHeader
IF NOT EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickslipNo = @cPickslipNo)
BEGIN
   --INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey, AddWho, AddDate,CtnTyp1,CtnTyp2,CtnTyp3,CtnTyp4,CtnTyp5,CartonGroup)
   --VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey, SUSER_NAME(), GETDATE(),@cCtnTyp1,@cCtnTyp2,@cCtnTyp3,@cCtnTyp4,@cCtnTyp5,@cCartonGroup)
   INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey, AddWho, AddDate)
   VALUES (@cPickSlipNo, @cStorerKey, @cOrderKey, @cLoadKey, SUSER_NAME(), GETDATE())
   IF @@ERROR <> 0
   BEGIN      
      SET @b_Success = 0  
      SET @n_Err = 101304  
      SET @c_ErrMsg = 'Fail to insert into PackHeader. Function : isp_HoldCarton'

      GOTO RollBackTran
   END
END
   
SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT SKU,QTY,Weight,CUBE 
   FROM @HoldCartonList
   
OPEN @curPD
   FETCH NEXT FROM @curPD INTO @cSKU,@nQTY,@cWeight,@cCube
   WHILE @@FETCH_STATUS <> -1
   BEGIN

      SET @cUPC = LEFT( @cSKU, 30) -- SKU


      -- Check SKU blank
      IF @cSKU = ''
      BEGIN   
         SET @b_Success = 0  
         SET @n_Err = 101305  
         SET @c_ErrMsg = 'No SKU entered. Please enter or scan valid SKU.'
      
         GOTO RollBackTran
      END
      
      -- Check blank QTY
      IF @nQTY = 0
      BEGIN     
      	SET @b_Success = 0  
         SET @n_Err = 101306  
         SET @c_ErrMsg = 'No Quantity entered. Please enter valid Quantity.'
               
         GOTO RollBackTran
      END 
      
      IF @nQTY <> '' AND ISNULL(@nQTY,0) = 0 --RDT.rdtIsValidQTY( @nQTY, 1) = 0 --Check zero
      BEGIN   
      	SET @b_Success = 0  
         SET @n_Err = 101307  
         SET @c_ErrMsg = 'Invalid Quantity entered. Please enter valid Quantity.'
         
         GOTO RollBackTran
      END
      
     --check pickQty<=packQty
     SELECT @nPackQty = ISNULL(SUM(Qty),0) FROM PackDetail WITH (NOLOCK) WHERE pickslipno = @cPickSlipNo AND SKU = @csku AND Storerkey = @cStorerKey
     SELECT @nPickQty = QtyToPack FROM @pickSKUDetail WHERE sku = @cSKU
     
     IF @nPickQty < @nQTY--(@nPackQty+@nQTY)
     BEGIN
     	   SET @b_Success = 0  
         SET @n_Err = 101308  
         SET @c_ErrMsg = 'Hold Quantity > Pick Quantity. Please enter valid Quantity.'
         
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

      -- hold: PackDetail
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
               SET @n_Err = 101309  
               SET @c_ErrMsg = 'Fail to insert into PackDetail. Function : isp_HoldCarton' 
                
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
               SET @n_Err = 101310  
               SET @c_ErrMsg = 'Fail to update into PackDetail. Function : isp_HoldCarton' 
               
               GOTO RollBackTran
            END
         END
         
      FETCH NEXT FROM @curPD INTO @cSKU,@nQTY,@cWeight,@cCube
   END
  
  -- hold: PackInfo
  DECLARE @ttlWeight FLOAT
  DECLARE @ttlCube   FLOAT
  
  SELECT @ttlWeight = SUM(WEIGHT),@ttlCube = SUM(CUBE) FROM @HoldCartonList
  
   IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo)
   BEGIN
      INSERT INTO dbo.PackInfo (PickslipNo, CartonNo, QTY, Weight, Cube, CartonType,CartonStatus, AddWho,AddDate,EditWho,EditDate)
      VALUES (@cPickSlipNo, @nCartonNo, @nQTY, @ttlWeight, @ttlCube, @cCartonType,'Hold',SUSER_NAME(),GETDATE(),SUSER_NAME(),GETDATE())
   
      IF @@ERROR <> 0
      BEGIN  
         SET @b_Success = 0  
         SET @n_Err = 101311  
         SET @c_ErrMsg = 'Fail to insert into PackInfo. Function : isp_HoldCarton'
                
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
         EditWho = SUSER_NAME(), 
         TrafficCop = NULL,
         cartonStatus = 'Hold'
      WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
      
      IF @@ERROR <> 0
      BEGIN      
         SET @b_Success = 0  
         SET @n_Err = 101312  
         SET @c_ErrMsg = 'Fail to update into PackInfo. Function : isp_HoldCarton'

         GOTO RollBackTran
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
   REVERT
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_HoldCarton TO NSQL
GO



