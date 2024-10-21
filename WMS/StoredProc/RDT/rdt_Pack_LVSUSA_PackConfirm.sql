
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/  
/* Store procedure: rdt_Pack_LVSUSA_PackConfirm                         */  
/* Copyright      : Maersk                                              */  
/*                                                                      */
/* Purpose: New PackConfirm logic for LVSUSA                            */
/*                                                                      */  
/* Date       Rev  Author      Purposes                                 */  
/* 2024-10-20 1.0  JCH507      FCR-946 Created                          */  
/************************************************************************/  
  
CREATE OR ALTER PROC rdt.rdt_Pack_LVSUSA_PackConfirm (  
    @nMobile         INT  
   ,@nFunc           INT  
   ,@cLangCode       NVARCHAR( 3)  
   ,@nStep           INT  
   ,@nInputKey       INT  
   ,@cFacility       NVARCHAR( 5)  
   ,@cStorerKey      NVARCHAR( 15)  
   ,@cPickSlipNo     NVARCHAR( 10)  
   ,@cFromDropID     NVARCHAR( 20)  
   ,@cPackDtlDropID  NVARCHAR( 20)
   ,@cLabelNo        NVARCHAR( 20)  
   ,@cPrintPackList  NVARCHAR( 1) OUTPUT  
   ,@nErrNo          INT            OUTPUT  
   ,@cErrMsg         NVARCHAR(250)  OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @cSQL           NVARCHAR(MAX)  
   DECLARE @cSQLParam      NVARCHAR(MAX)  
   DECLARE @cPackConfirmSP NVARCHAR(20)  
  
   -- Get storer configure  
   SET @cPackConfirmSP = rdt.RDTGetConfig( @nFunc, 'PackConfirmSP', @cStorerKey)  
   IF @cPackConfirmSP = '0'  
      SET @cPackConfirmSP = ''  
  
   /***********************************************************************************************  
                                              Custom pack confirm  
   ***********************************************************************************************/  
   -- Custom logic  
   IF @cPackConfirmSP <> ''  
   BEGIN  
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cPackConfirmSP AND type = 'P')  
      BEGIN  
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cPackConfirmSP) +  
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @cPackDtlDropID, @cLabelNo' +  
            ' @cPrintPackList OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '  
  
         SET @cSQLParam =  
            ' @nMobile        INT,           ' +   
            ' @nFunc          INT,           ' +   
            ' @cLangCode      NVARCHAR( 3),  ' +   
            ' @nStep          INT,           ' +   
            ' @nInputKey      INT,           ' +   
            ' @cFacility      NVARCHAR( 5),  ' +   
            ' @cStorerKey     NVARCHAR( 15), ' +     
            ' @cPickSlipNo    NVARCHAR( 10), ' +     
            ' @cFromDropID    NVARCHAR( 20), ' +   
            ' @cPackDtlDropID NVARCHAR( 20), ' +
            ' @cLabelNo       NVARCHAR( 20), ' +   
            ' @cPrintPackList NVARCHAR( 1)  OUTPUT, ' +   
            ' @nErrNo         INT           OUTPUT, ' +   
            ' @cErrMsg        NVARCHAR(250) OUTPUT  '  
              
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cFromDropID, @cPackDtlDropID,   
            @cPrintPackList OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
         GOTO Quit  
      END  
   END  
  
   /***********************************************************************************************  
                                          Standard pack confirm  
   ***********************************************************************************************/  
   DECLARE @bSuccess       INT  
   DECLARE @cLoadKey       NVARCHAR( 10)  
   DECLARE @cOrderKey      NVARCHAR( 10)  
   DECLARE @cZone          NVARCHAR( 18)  
   DECLARE @nPackQTY       INT  
   DECLARE @nPickQTY       INT  
   DECLARE @cPickStatus    NVARCHAR( 20)  
   DECLARE @cPackConfirm   NVARCHAR( 1)
   DECLARE @nCounter       INT = 0
   DECLARE @nMax           INT = 0
   DECLARE @bDebugFlag     BINARY

   DECLARE @tPSNO TABLE
   (
      RowNumber   INT IDENTITY NOT NULL,
      PickSlipNo  NVARCHAR(20) NOT NULL
   )

   DECLARE @tOrder TABLE
   (
      RowNumber   INT IDENTITY NOT NULL,
      PickSlipNo  NVARCHAR(20) NOT NULL,
      OrderKey    NVARCHAR(10) NOT NULL
   )  
  
   SET @cOrderKey = ''  
   SET @cLoadKey = ''  
   SET @cZone = ''  
   SET @cPackConfirm = '' 
   SET @cPickSlipNo = '' 
   SET @nPackQTY = 0  
   SET @nPickQTY = 0

   INSERT INTO @tPSNO (PickSlipNO)
      SELECT DISTINCT PH.PickSlipNO
      FROM PackHeader PH WITH (NOLOCK)
      JOIN PackDetail PD WITH (NOLOCK)
         ON PH.StorerKey = PD.StorerKey
         AND PH.PickSlipNo = PD.PickSlipNo
      WHERE PH.StorerKey = @cStorerKey
         AND PD.LabelNo = @cLabelNo
      Order BY PH.PickSlipNo

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 226901  
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- No PSNO Found
      GOTO Quit
   END

   IF @bDebugFlag = 1
   BEGIN
      SELECT 'PSNO List', @cLabelNo AS LabelNo
      SELECT * FROM @tPSNO
   END

   -- Get Order Info
   INSERT INTO @tOrder (PickSlipNo,OrderKey)
      SELECT DISTINCT PickSlipNo, OrderKey
      FROM PickHeader PKH WITH (NOLOCK)
      JOIN @tPSNO PSNO
      ON PKH.PickHeaderKey = PSNO.PickSlipNo
      ORDER BY OrderKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 226902  
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- No Order Found
      GOTO Quit
   END
   
   IF @bDebugFlag = 1
   BEGIN
      SELECT 'Order List'
      SELECT * FROM @tOrder
   END

   -- Check pack confirm already  
   IF NOT EXISTS( SELECT 1 FROM PackHeader PH WITH (NOLOCK)
               JOIN @tPSNO PSNO 
                  ON  PH.PickSlipNo = PSNO.PickSlipNo
               WHERE Status <> '9')
   BEGIN
      IF @bDebugFlag = 1
         SELECT 'All Confirmed. Quit'  
      GOTO Quit
   END

   -- Storer config  
   SET @cPickStatus = rdt.rdtGetConfig( @nFunc, 'PickStatus', @cStorerKey) 

   -- Go through each orderkey in the carton
   SET @nCounter = 1

   SELECT @nMax = COUNT(1)
   FROM @tOrder

   WHILE @nCounter <= @nMax
   BEGIN
      IF @bDebugFlag = 1
         SELECT @nCounter AS Counter, @nMax AS Max

      SET @cPickSlipNo = ''
      SET @cOrderKey = ''
      SET @cPackConfirm = 'Y'
      SET @nPackQTY = 0

      SELECT @cPickSlipNo = PickSlipNo,
         @cOrderKey = OrderKey
      FROM @tOrder
      WHERE RowNumber = @nCounter

      -- Calc pack QTY   
      SELECT @nPackQTY = ISNULL( SUM( QTY), 0) 
      FROM PackDetail PD WITH (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo

      IF EXISTS( SELECT TOP 1 1  
         FROM dbo.PickDetail PD WITH (NOLOCK)  
         WHERE PD.OrderKey = @cOrderKey  
            AND PD.Status < '5'  
            AND PD.QTY > 0  
            AND (PD.Status = '4' OR CHARINDEX( PD.Status, @cPickStatus) = 0))  -- Short or not yet pick  
         SET @cPackConfirm = 'N'  
      ELSE  
         SET @cPackConfirm = 'Y'

      -- Check fully packed  
      IF @cPackConfirm = 'Y'  
      BEGIN  
         SELECT @nPickQTY = SUM( PD.QTY)   
         FROM dbo.PickDetail PD WITH (NOLOCK)   
         WHERE PD.OrderKey = @cOrderKey  
           
         IF @nPickQTY <> @nPackQTY  
            SET @cPackConfirm = 'N'  
      END

      IF @bDebugFlag = 1
         SELECT @cPickSlipNo AS PSNO, @cOrderKey AS OrderKey, @cPackConfirm AS PackConfirm, @nPickQty AS PickQty,
               @nPackQty AS PackQty 
      
      -- Close the PackHeader
      IF @cPackConfirm = 'Y'
      BEGIN TRY
         UPDATE PackHeader WITH (ROWLOCK) SET   
            Status = '9'   
         WHERE PickSlipNo = @cPickSlipNo  
            AND Status <> '9'  
         
      END TRY
      BEGIN CATCH
         SET @nErrNo = @@ERROR
         IF @nErrNo <> 0  
         BEGIN  
            SET @nErrNo = 226903  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PackCfm Fail  
            GOTO Quit  
         END
      END CATCH

      SET @nCounter = @nCounter + 1

   END -- Go through orderky
      
  
   /*
   -- Handling transaction  
   DECLARE @nTranCount  INT  
   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  -- Begin our own transaction  
   SAVE TRAN rdt_Pack_LVSUSA_PackConfirm -- For rollback or commit only our own transaction  
  
   -- Pack confirm  
   IF @cPackConfirm = 'Y'  
   BEGIN  
      -- Pack confirm  
      UPDATE PackHeader SET   
         Status = '9'   
      WHERE PickSlipNo = @cPickSlipNo  
         AND Status <> '9'  
      SET @nErrNo = @@ERROR   
      IF @nErrNo <> 0  
      BEGIN  
         -- SET @nErrNo = 100251  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PackCfm Fail  
         GOTO RollBackTran  
      END  

      
      -- Get storer config  
      DECLARE @cAssignPackLabelToOrdCfg NVARCHAR(1)  
      EXECUTE nspGetRight  
         @cFacility,  
         @cStorerKey,  
         '', --@c_sku  
         'AssignPackLabelToOrdCfg',  
         @bSuccess                 OUTPUT,  
         @cAssignPackLabelToOrdCfg OUTPUT,  
         @nErrNo                   OUTPUT,  
         @cErrMsg                  OUTPUT  
      IF @nErrNo <> 0  
         GOTO RollBackTran  
  
      -- Assign  
      IF @cAssignPackLabelToOrdCfg = '1'  
      BEGIN  
         -- Update PickDetail, base on PackDetail.DropID  
         EXEC isp_AssignPackLabelToOrderByLoad  
             @cPickSlipNo  
            ,@bSuccess OUTPUT  
            ,@nErrNo   OUTPUT  
            ,@cErrMsg  OUTPUT  
         IF @nErrNo <> 0  
            GOTO RollBackTran  
      END  
  
      -- Get storer config  
      DECLARE @cDefault_PackInfo NVARCHAR(1)  
      EXECUTE nspGetRight  
         @cFacility,  
         @cStorerKey,  
         '', --@c_sku  
         'Default_PackInfo',  
         @bSuccess          OUTPUT,  
         @cDefault_PackInfo OUTPUT,  
         @nErrNo            OUTPUT,  
         @cErrMsg           OUTPUT  
      IF @nErrNo <> 0  
         GOTO RollBackTran  
           
      IF @cDefault_PackInfo = '1'  
      BEGIN  
         IF EXISTS( SELECT 1   
            FROM PackDetail PD WITH (NOLOCK)  
               LEFT JOIN PackInfo PInf WITH (NOLOCK) ON (PD.PickSlipNo = PInf.PickSlipNo AND PD.CartonNo = PInf.CartonNo)  
            WHERE PD.PickSlipNo = @cPickSlipNo  
               AND PInf.PickSlipNo IS NULL)  
         BEGIN  
            DECLARE @nCartonNo      INT   
            DECLARE @nWeight        FLOAT  
            DECLARE @nCube          FLOAT  
            DECLARE @nQTY           INT  
            DECLARE @cCartonType    NVARCHAR( 10)  
            DECLARE @nCartonWeight  FLOAT  
            DECLARE @nCartonCube    FLOAT  
            DECLARE @nCartonLength  FLOAT  
            DECLARE @nCartonWidth   FLOAT  
            DECLARE @nCartonHeight  FLOAT  
  
            -- Get carton info  
            SET @cCartontype = ''  
            SELECT TOP 1   
               @cCartonType = CartonType,   
               @nCartonWeight = ISNULL( CartonWeight, 0),   
               @nCartonCube = ISNULL( Cube, 0),   
               @nCartonLength = ISNULL( CartonLength, 0),  
               @nCartonWidth  = ISNULL( CartonWidth, 0),   
               @nCartonHeight = ISNULL( CartonHeight, 0)  
            FROM Storer S WITH (NOLOCK)  
               JOIN Cartonization C WITH (NOLOCK) ON (S.CartonGroup = C.CartonizationGroup)  
            WHERE S.StorerKey = @cStorerKey  
            ORDER BY C.UseSequence  
              
            -- Loop missing PackInfo  
            DECLARE @curPD CURSOR  
            SET @curPD = CURSOR FOR  
               SELECT DISTINCT PD.CartonNo  
               FROM PackDetail PD WITH (NOLOCK)  
                  LEFT JOIN PackInfo PInf WITH (NOLOCK) ON (PD.PickSlipNo = PInf.PickSlipNo AND PD.CartonNo = PInf.CartonNo)  
               WHERE PD.PickSlipNo = @cPickSlipNo  
                  AND PInf.PickSlipNo IS NULL  
            OPEN @curPD  
            FETCH NEXT FROM @curPD INTO @nCartonNo  
            WHILE @@FETCH_STATUS = 0  
            BEGIN  
               -- Get PackDetail info  
               SELECT   
                  @nQTY = SUM( PD.QTY),   
                  @nWeight = SUM( PD.QTY * SKU.STDGrossWGT),   
                  @nCube = SUM( PD.QTY * SKU.STDCube)  
               FROM PackDetail PD WITH (NOLOCK)   
                  JOIN SKU WITH (NOLOCK) ON (PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)  
               WHERE PD.PickSlipNo = @cPickSlipNo  
                  AND PD.CartonNo = @nCartonNo                 
                 
               -- Calc weight, cube  
               SET @nWeight = @nWeight + ISNULL(@nCartonWeight,0)   --(cc01)
               IF ISNULL(@nCartonCube,0) <> 0                       --(cc01)
                  SET @nCube = ISNULL(@nCartonCube,0)                --(cc01)        
  
               -- Insert PackInfo  
               INSERT INTO PackInfo (PickSlipNo, CartonNo, Weight, Cube, Qty, Cartontype, Length, Width, Height)  
               VALUES (@cPickSlipNo, @nCartonNo, @nWeight, @nCube, @nQTY, @cCartonType, @nCartonLength, @nCartonWidth, @nCartonHeight)  
               IF @nErrNo <> 0  
               BEGIN  
                  SET @nErrNo = 100252  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- INS PKInf Fail  
                  GOTO RollBackTran  
               END  
                 
               FETCH NEXT FROM @curPD INTO @nCartonNo  
            END  
         END  
      END  
   END 
  
   COMMIT TRAN rdt_Pack_LVSUSA_PackConfirm 
   GOTO Quit  
  
RollBackTran:  
   ROLLBACK TRAN rdt_Pack_LVSUSA_PackConfirm -- Only rollback change made here */ 
Quit:  
   /*WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN*/  
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_Pack_LVSUSA_PackConfirm TO NSQL
GO
