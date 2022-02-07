IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdt_848ExtUpd03]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [rdt].[rdt_848ExtUpd03]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO   
/************************************************************************/  
/* Store procedure: rdt_848ExtUpd03                                     */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date        Rev  Author      Purposes                                */  
/* 2021-12-02  1.0  James       WMS-18457. Created                      */  
/************************************************************************/  
  
CREATE PROC [RDT].[rdt_848ExtUpd03] (  
   @nMobile      INT,   
   @nFunc        INT,   
   @cLangCode    NVARCHAR( 3),   
   @nStep        INT,   
   @nInputKey    INT,   
   @cStorerKey   NVARCHAR( 15),    
   @cRefNo       NVARCHAR( 10),   
   @cPickSlipNo  NVARCHAR( 10),   
   @cLoadKey     NVARCHAR( 10),   
   @cOrderKey    NVARCHAR( 10),   
   @cDropID      NVARCHAR( 20),   
   @cSKU         NVARCHAR( 20),    
   @cOption      NVARCHAR( 1),    
   @nErrNo       INT OUTPUT,    
   @cErrMsg      NVARCHAR( 20) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @nTranCount       INT,  
           @cLabelLine        NVARCHAR( 5),  
           @nCartonNo         INT  
  
   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  -- Begin our own transaction  
   SAVE TRAN rdt_848ExtUpd03 -- For rollback or commit only our own transaction  
  
   IF @nFunc = 848  
   BEGIN  
      IF @nStep = 4  
      BEGIN  
         -- Get Orders info  
         SELECT TOP 1 @cPickSlipNo = PickSlipNo   
         FROM dbo.PackDetail WITH (NOLOCK)   
         WHERE DropID = @cDropID  
         AND   StorerKey = @cStorerKey  
  
         IF ISNULL( @cPickSlipNo, '') = ''  
         BEGIN  
            SET @nErrNo = 179651  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Pickslip  
            GOTO RollBackTran  
         END  
  
         DECLARE CUR_DELPACKD CURSOR LOCAL READ_ONLY FAST_FORWARD FOR   
         SELECT CartonNo, LabelLine  
         FROM dbo.PackDetailInfo WITH (NOLOCK)  
         WHERE PickSlipNo = @cPickSlipNo  
         AND   LabelNo = @cDropID  
         AND   (( @cSKU = '') OR ( SKU = @cSKU))  
         OPEN CUR_DELPACKD  
         FETCH NEXT FROM CUR_DELPACKD INTO @nCartonNo, @cLabelLine  
         WHILE @@FETCH_STATUS <> -1  
         BEGIN  
            DELETE FROM dbo.PackDetailInfo   
            WHERE PickSlipNo = @cPickSlipNo  
            AND   CartonNo = @nCartonNo  
            AND   LabelNo = @cDropID  
            AND   LabelLine = @cLabelLine  
  
            IF @@ERROR <> 0  
            BEGIN  
               SET @nErrNo = 179652  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PackD Fail  
               CLOSE CUR_DELPACKD  
               DEALLOCATE CUR_DELPACKD  
               GOTO RollBackTran                    
            END  
  
            FETCH NEXT FROM CUR_DELPACKD INTO @nCartonNo, @cLabelLine  
         END  
         CLOSE CUR_DELPACKD  
         DEALLOCATE CUR_DELPACKD  
      END  
  
   END  
  
   GOTO Quit  
  
   RollBackTran:  
      ROLLBACK TRAN rdt_848ExtUpd03  
   Quit:  
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
         COMMIT TRAN  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_848ExtUpd03] TO NSQL
GO  
   