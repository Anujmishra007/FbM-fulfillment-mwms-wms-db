SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
     
/*********************************************************************************/        
/* Store procedure: isp_CheckPackStatus                                          */        
/* Copyright      : Maersk                                                       */        
/*                                                                               */        
/* Date         Rev  Author     Purposes                                         */        
/* 2024-09-19   1.0  YeeKung    TPS-960 Initial                                  */       
/* 2024-09-19   1.1  GHChan     Fix @b_Success to return 1 or 0                  */         
/*********************************************************************************/        
        
CREATE OR ALTER   PROC [API].[isp_CheckPackStatus] (        
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
   @cUPCJSON         NVARCHAR( MAX),        
   @cLottableJSON    NVARCHAR( MAX),        
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
           
   @cAssignPackLabelToOrdCfg     NVARCHAR(1), --(cc08)        
   @cAssignPackLabelToOrdCfgSP   NVARCHAR(30), --(cc08)        
           
   @cSKUBarcode         NVARCHAR( 60),   --(cc09)        
   @cExtendedUpdateSP   NVARCHAR( 20),   --(cc09)        
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
        
   @bSuccess         INT,        
   @nErrNo           INT,         
   @cErrMsg          NVARCHAR(250),        
   @nTranCount       INT,        
   @curPD            CURSOR,        
   @GetCartonID      NVARCHAR( MAX),        
   @cShipLabel       NVARCHAR( 10),        
   @nJobID           INT,        
   @cWorkstation     NVARCHAR( 30),        
   @cLabelNo         NVARCHAR( 20), --(cc01)        
   @pickSkuDetailJson   NVARCHAR( MAX),        
   @bToPrint            INT,        
   @cPrintAfterPacked   NVARCHAR( 1),        
   @cLottableVal     NVARCHAR( 60), --(cc05)        
   @cSQL             NVARCHAR(MAX), --(cc08)        
   @cSQLParam        NVARCHAR(MAX), --(cc08)        
   @cDisableLblPrint NVARCHAR(1), --(yeekung01)        
   @cDisablePLPrint  NVARCHAR(1), --(yeekung01)        
   @cDefaultCartonType  NVARCHAR(20), --(yeekung06)       
   @nUPCQTY          INT,      
   @cCurUPC          CURSOR,      
   @cUCCCounter      INT,      
   @nPackedQTY       INT,      
   @nQueueID         INT      
      
DECLARE @cFieldName1 NVARCHAR(max),      
      @cFieldName2 NVARCHAR(max),      
        @cFieldName3 NVARCHAR(max),      
        @cFieldName4 NVARCHAR(max),      
        @cParams1    NVARCHAR(max),      
        @cParams2    NVARCHAR(max),      
        @cParams3    NVARCHAR(max),      
        @cParams4    NVARCHAR(max)      
      
DECLARE @cNewPaperPrinter NVARCHAR(20)      
DECLARE @cNewLabelPrinter NVARCHAR(20)      
         
        
SET @UpdDymEcomWeight = 'N'        
SET @EcomSingle = '0'        
SET @UpdDymEcomCube = 'N'        
SET @nProceedPrintFlag = '0'        
SET @cDisableLblPrint = '0'        
SET @cDisablePLPrint = '0'        
        
DECLARE @CartonIDList TABLE (        
   CartonID        NVARCHAR( 20)        
)        
      
      
DECLARE @CloseCartonList TABLE (        
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
select @cStorerKey = StorerKey, @cFacility = Facility, @nFunc = Func, @cUserName = UserName, @cLangCode = LangCode,        
@cScanNo = ScanNo, @nQueueID =  QueueID      
FROM OPENJSON(@json)          
WITH (        
 StorerKey      NVARCHAR( 30),        
 Facility       NVARCHAR( 30),        
   Func           NVARCHAR( 5),        
   UserName       NVARCHAR( 128),        
   LangCode       NVARCHAR( 3),        
   ScanNo         NVARCHAR( 30),        
   QueueID       INT      
)         
      
   IF EXISTS ( SELECT 1      
               FROM Packheader (nolock)       
               WHERE Storerkey = @cStorerKey      
                  AND Pickslipno = @cScanNo      
                  AND Status = '9')      
   BEGIN      
      SET @b_Success =1      
   END      
   ELSE      
   BEGIN      
      SET @b_Success =0      
   END      
           
      
   SET @n_Err = 0        
   SET @c_ErrMsg = ''        
   SET @jResult = (SELECT @b_Success AS 'Status')      
      
        
END 
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_CheckPackStatus TO NSQL
GO
