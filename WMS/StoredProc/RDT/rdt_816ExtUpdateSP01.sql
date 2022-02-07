if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_816ExtUpdateSP01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_816ExtUpdateSP01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/  
/* Store procedure: rdt_816ExtUpdateSP01                                */  
/* Copyright      : IDS                                                 */  
/*                                                                      */  
/* Purpose: Extended Update SP for DcToDc Order                         */  
/*                                                                      */  
/* Modifications log:                                                   */  
/* Date        Rev  Author   Purposes                                   */  
/* 2014-06-03  1.0  ChewKP   Created                                    */  
/************************************************************************/  
  
CREATE PROC [RDT].[rdt_816ExtUpdateSP01] (  
   @nMobile     INT,  
   @nFunc       INT,  
   @cLangCode  NVARCHAR( 3),  
   @cUserName   NVARCHAR( 15),  
   @cFacility   NVARCHAR( 5),  
   @cStorerKey  NVARCHAR( 15),  
   @cObjectType NVARCHAR( 10),
   @cPickSlipNo NVARCHAR( 10),  
   @cDropID     NVARCHAR( 20),  
   @cLoadKey    NVARCHAR( 10),  
   @cWaveKey    NVARCHAR( 10),  
   @nErrNo      INT          OUTPUT,  
   @cErrMsg     NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max  
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   
   Declare @cOrderType           NVARCHAR(10)
         , @cConsigneeKey        NVARCHAR(15)
         , @nQty                 INT
         , @cSKU                 NVARCHAR(20)   
         , @nTotalPickedQty      INT
         , @nTotalPackedQty      INT
         , @cDeviceProfileLogKey NVARCHAR(10)
         , @nCartonNo            INT
         , @cLabelNo             NVARCHAR(20)
         , @cLabelLine           NVARCHAR(5)
         , @nTranCount           INT
         , @cGenLabelNoSP         NVARCHAR(30)
         , @cExecStatements       NVARCHAR(4000)   
         , @cExecArguments        NVARCHAR(4000)
         , @cPickDetailKey        NVARCHAR(10)
         , @b_success             INT
         , @cWCS                  NVARCHAR(1) 
         , @cPTSLoc               NVARCHAR(10)
         , @cPutawayZone          NVARCHAR(10) 
         , @cCurrentStation       NVARCHAR(10)
         , @cRDTBartenderSP       NVARCHAR(40)
         , @cLabelPrinter         NVARCHAR(10)
         
      
   SET @nErrNo = 0  
   SET @cErrMsg = ''  
   SET @nQty = 0 
   SET @cDeviceProfileLogKey = ''
   SET @cConsigneeKey        = ''
   SET @nQty                 = 0 
   SET @cSKU                 = ''
   SET @nTotalPickedQty      = 0 
   SET @nTotalPackedQty      = 0 
   SET @cDeviceProfileLogKey = ''
   SET @nCartonNo            = 0 
   SET @cLabelNo             = ''
   SET @cLabelLine           = ''
   SET @nTranCount           = 0 
   SET @cGenLabelNoSP        = ''
   SET @cExecStatements      = ''  
   SET @cExecArguments       = ''
   SET @cPickDetailKey       = ''
   SET @b_success            = 0 
   SET @cWCS                 = ''
   SET @cPTSLoc              = ''
   SET @cPutawayZone         = ''
   SET @cCurrentStation      = ''
   SET @cRDTBartenderSP      = ''
   SET @cLabelPrinter        = ''

   
   
   SELECT @cWCS = SValue 
   FROM dbo.StorerConfig WITH (NOLOCK)
   WHERE ConfigKey = 'WCS' 
   AND StorerKey = @cStorerKey
   
   SELECT @cLabelPrinter = Printer 
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   SELECT @cGenLabelNoSP = SValue
   FROM dbo.StorerConfig WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND ConfigKey = 'GenLabelNo_SP'

         
    IF NOT EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = ISNULL(RTRIM(@cGenLabelNoSP),'') AND type = 'P')  
    BEGIN
            
          SET @nErrNo = 84062
          --SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'UpdPackHFail'
          SET @cErrMsg = 'GenLblSPNotFound'
          GOTO RollBackTran
    END
   
   
   SELECT Top 1 @cConsigneeKey = OD.UserDefine02 
               ,@cOrderType    = O.Type
   FROM dbo.OrderDetail OD WITH (NOLOCK) 
   INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = OD.OrderKey
   INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.OrderKey = OD.OrderKey AND PD.OrderLineNumber = OD.OrderLineNumber 
   WHERE PD.WaveKey           = @cWaveKey
   AND PD.PickSlipNo          = @cPickSlipNo 
   AND PD.DropID              = @cDropID
   AND ISNULL(PD.CaseID, '')  = '' 
   
   SELECT @cPTSLoc = Loc 
   FROM dbo.StoreToLocDetail WITH (NOLOCK)
   WHERE ConsigneeKey = @cConsigneeKey
   AND StoreGroup = 'OTHERS'
   
   SELECT @cFacility = Facility 
   FROM dbo.Loc WITH (NOLOCK) 
   WHERE Loc = @cPTSLoc
         
   SELECT @cPutawayZone = PutawayZone
   FROM dbo.Loc WITH (NOLOCK)
   WHERE Loc = @cPTSLoc 
   AND Facility = @cFacility
   

   SELECT @cCurrentStation = ISNULL(RTRIM(SHORT), '')                  
   FROM CODELKUP WITH (NOLOCK)                  
   WHERE Listname = 'WCSSTATION'                  
   AND   Code = @cPutawayZone 

   
   
   
  
   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  
   SAVE TRAN rdt_816ExtUpdateSP01  
  
   IF @cObjectType = 'TOTE' AND @cOrderType = 'DcToDc' 
   BEGIN
      /***************************************************/
     /* Insert PackHeader                               */
     /***************************************************/
     IF NOT EXISTS(SELECT 1 FROM dbo.PACKHEADER WITH (NOLOCK) WHERE PickSlipNo = ISNULL(RTRIM(@cPickSlipNo),''))
     BEGIN
        INSERT INTO dbo.PACKHEADER
        (PickSlipNo, StorerKey, OrderKey, LoadKey, Route, ConsigneeKey, OrderRefNo, TtlCnts, ConsoOrderKey, [STATUS]) 
        VALUES
        (@cPickSlipNo, @cStorerKey, '', @cLoadKey, '', '', '', 0, '', '0') 
        
        IF @@ERROR <> 0
        BEGIN
           SET @nErrNo = 88903
           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'UpdPackHFail'
           --SET @cErrMsg = 'Error Update PackDetail table.'
           GOTO RollBackTran
        END
      END 
    
     /***************************************************/
     /* Insert PackDetail                               */
     /***************************************************/
     SET @nCartonNo = 0
     SET @cLabelLine = '00000'
      
     DECLARE CursorPackDetailPrev CURSOR LOCAL FAST_FORWARD READ_ONLY FOR            
     
     SELECT  PD.SKU 
            ,SUM(PD.Qty)
     FROM dbo.Pickdetail PD WITH (NOLOCK)
     INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
     JOIN dbo.OrderDetail OD (NOLOCK) ON OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber
     WHERE PD.DropID = @cDropID
     AND PD.Status = '5'
     AND O.LoadKey = @cLoadKey
     AND OD.UserDefine02 = @cConsigneeKey 
     AND ISNULL(PD.CaseID, '') = '' 
     GROUP BY PD.SKU
     HAVING SUM(PD.Qty) > 0 
     ORDER BY PD.SKU
     
     OPEN CursorPackDetailPrev            
     
     FETCH NEXT FROM CursorPackDetailPrev INTO @cSKU, @nQty
      
     
     WHILE @@FETCH_STATUS <> -1     
     BEGIN   


        -- Prevent OverPacked by ConsigneeKey -- 
         -- Want to Check OverPack Here How To Handle ? --
         SET @nTotalPickedQty = 0
         SET @nTotalPackedQty = 0
         
         SELECT @nTotalPickedQty = ISNULL(SUM(PD.QTY),0)
         FROM dbo.PickDetail PD WITH (NOLOCK) 
         INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
         INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON OD.OrderKey = O.OrderKey 
         INNER JOIN dbo.LoadPlanDetail LP WITH (NOLOCK) ON LP.OrderKey = PD.OrderKey
         WHERE PD.PickslipNo  = @cPickSlipNo
         AND   LP.LoadKey     = @cLoadKey
         AND   PD.StorerKey   = @cStorerKey
         AND   PD.SKU         = @cSKU
         AND   PD.Status      = '5'
         --AND   OD.UserDefine02 = @cConsigneeKey
   

         SELECT @nTotalPackedQty = ISNULL(SUM(PD.QTY),0) FROM dbo.PackDetail PD WITH (NOLOCK) 
         WHERE PD.PickSlipNo = @cPickSlipNo
         AND PD.SKU = @cSKU
         
         
         
         IF (ISNULL(@nTotalPackedQty,0) + ISNULL(@nQty,0)) > ISNULL(@nTotalPickedQty,0)
         BEGIN
            SET @nErrNo = 88901
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'OverPacked'
            GOTO RollBackTran
         END 
         

         
--         IF EXISTS(SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)
--                  WHERE PickSlipNo = @cPickSlipNo
--                    AND DropID = @cDropID
--                    AND SKU = @cSKU )
--         BEGIN
--               SELECT @cLabelNo = LabelNo 
--               FROM dbo.PackDetail WITH (NOLOCK)
--               WHERE PickSlipNo = @cPickSlipNo
--                AND DropID = @cDropID
--                AND SKU = @cSKU
--               
--               UPDATE PACKDETAIL WITH (ROWLOCK)
--                 SET Qty = Qty + @nQty
--               WHERE PickSlipNo = @cPickSlipNo
--                AND DropID = @cDropID
--                AND SKU = @cSKU
--               
--               IF @@ERROR <> 0 
--               BEGIN
--                  SET @nErrNo = 88902
--                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'UpdPackDetFail'
--                  --SET @cErrMsg = 'Update PackDetail Failed'
--                  GOTO RollBackTran
--               END 
--         END
--         ELSE
--           BEGIN
--
--
--               IF NOT EXISTS ( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK)       
--                               WHERE PickSlipNo = @cPickSlipNo 
--                               AND DropID = @cDropID ) 
--               BEGIN
                 
                 SET @cLabelNo = @cDropID

                 
                 SET @cExecStatements = N'EXEC dbo.' + RTRIM( @cGenLabelNoSP) +  
                                         '   @cPickslipNo           ' +                     
                                         ' , @nCartonNo             ' + 
                                         ' , @cLabelNo     OUTPUT   ' +
                                         ' , @cStorerKey            ' + 
                                         ' , @cDeviceProfileLogKey  ' +   
                                         ' , @cConsigneeKey         ' +  
                                         ' , @b_success             ' +     
                                         ' , @nErrNo       OUTPUT   ' +  
                                         ' , @cErrMSG      OUTPUT   '   
       
                    
                 SET @cExecArguments =   
                           N'@cPickslipNo  nvarchar(10),       ' +  
                            '@nCartonNo    int,                ' +      
                            '@cLabelNo     nvarchar(20) OUTPUT, ' +      
                            '@cStorerKey   nvarchar(15),        ' +  
                            '@cDeviceProfileLogKey     nvarchar(10), ' +  
                            '@cConsigneeKey     nvarchar(15), ' +  
                            '@b_success   int,                 ' +      
                            '@nErrNo      int OUTPUT,          ' +     
                            '@cErrMSG     nvarchar(225) OUTPUT '   
                         
                   
                 EXEC sp_executesql @cExecStatements, @cExecArguments,   
                                       @cPickslipNo                 
                                     , @nCartonNo
                                     , @cLabelNo      OUTPUT
                                     , @cStorerKey                                 
                                     , '' -- @cDeviceProfileLogKey  
                                     , @cConsigneeKey                 
                                     , @b_success     
                                     , @nErrNo        OUTPUT  
                                     , @cErrMSG       OUTPUT

   
                 IF @nErrNo <> 0 
                 BEGIN
                   SET @nErrNo = 88904
                   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'GenLabelFail'
                   --SET @cErrMsg = 'Update PackDetail Failed'
                   GOTO RollBackTran
                    
                 END
--               END
--               ELSE 
--               BEGIN   
--                   SELECT @cLabelNo = LabelNo 
--                   FROM dbo.PackDetail WITH (NOLOCK)
--                   WHERE PickSlipNo = @cPickSlipNo
--                   AND DropID = @cDropID 
--   
--               END
      
               

               INSERT INTO dbo.PACKDETAIL
               (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, Sku, Qty, DropID, RefNo)
               VALUES
               (@cPickSlipNo, @nCartonNo, @cLabelNo, @cLabelLine, @cStorerKey, @cSku,
                @nQty, @cDropID,'')
               
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 88905
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsPackDetFail'
                  --SET @cErrMsg = 'Insert PackDetail Failed'
                  GOTO RollBackTran
               END
               
               
               IF NOT EXISTS ( SELECT 1 FROM dbo.DropIDDetail WITH (NOLOCK)
                               WHERE DropID = @cDropID
                               AND ChildID = @cLabelNo ) 
               BEGIN                
                  INSERT INTO dbo.DropIDDetail (DropID, ChildID ) 
                  VALUES ( @cDropID , @cLabelNo ) 
                 
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 889056
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsDropIDDetFail'
                     --SET @cErrMsg = 'Insert DropIDDetail Failed'
                     GOTO RollBackTran
                  END
                  
               END
         --END
            
         -- Update PickDetail.CaseID = LabelNo
         DECLARE CursorPickDetail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR            
         
         SELECT  PD.PickDetailKey
         FROM dbo.Pickdetail PD WITH (NOLOCK)
         INNER JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
         WHERE PD.DropID = @cDropID
         AND PD.Status = '5'
         AND O.LoadKey = @cLoadKey
         AND PD.SKU    = @cSKU
         AND ISNULL(PD.CaseID,'')  = ''
         AND PD.Qty > 0 
         ORDER BY PD.SKU
         
         OPEN  CursorPickDetail
         
         FETCH NEXT FROM CursorPickDetail INTO @cPickDetailKey
         
         WHILE @@FETCH_STATUS <> -1     
         BEGIN
           
           UPDATE PickDetail WITH (ROWLOCK)
           SET CaseID = @cLabelNo, Trafficcop = NULL
           WHERE PickDetailKey = @cPickDetailKey
           AND Status = '5'
           
           IF @@ERROR <> 0 
           BEGIN
              SET @nErrNo = 88907
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsDropIDDetFail'
               --SET @cErrMsg = 'Update PickDetail Failed'
               GOTO RollBackTran
           END
            
              
              FETCH NEXT FROM CursorPickDetail INTO @cPickDetailKey  
         END
         CLOSE CursorPickDetail         
         DEALLOCATE CursorPickDetail
            
   
         FETCH NEXT FROM CursorPackDetailPrev INTO @cSKU, @nQty
     END     
     CLOSE CursorPackDetailPrev         
     DEALLOCATE CursorPackDetailPrev
     
     CONTINUE_PROCESS:
     /***************************************************/
     /* Insert PackInfo                                 */
     /***************************************************/
     SET @nCartonNo = 0
     
     SELECT @nCartonNo = MAX(CartonNo)
     FROM dbo.PACKDETAIL WITH (NOLOCK)
     WHERE PickSlipNo = @cPickSlipNo
     AND DropID = @cDropID
     
     IF ISNULL(@nCartonNo,0) <> 0
     BEGIN
        IF NOT EXISTS(SELECT 1 FROM dbo.PACKINFO WITH (NOLOCK)
                      WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo)
        BEGIN
           INSERT INTO dbo.PACKINFO
           (PickSlipNo, CartonNo, CartonType, RefNo)
           VALUES
           (@cPickSlipNo, @nCartonNo, 'GOH', @cLabelNo) 
     
           IF @@ERROR <> 0
           BEGIN
               SET @nErrNo = 88908
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsDropIDDetFail'
               --SET @cErrMsg = 'Insert PackInfo Failed'
               GOTO RollBackTran
           END
     
        END -- Not Exists in PackInfo
     END
     
     SET @cRDTBartenderSP = ''        
     SET @cRDTBartenderSP = rdt.RDTGetConfig( @nFunc, 'RDTBartenderSP', @cStorerkey)     
     
      
         
     IF @cRDTBartenderSP <> ''    
     BEGIN    
            
        IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cRDTBartenderSP AND type = 'P')    
        BEGIN    
                    
--           SET @cLabelNo = ''     
--           SELECT Top 1  @cLabelNo = LabelNo   
--           FROM dbo.PackDetail WITH (NOLOCK)  
--           WHERE PickSlipNo = @cPickSlipNo  
--           AND DropID = @cDropID 
     
      
     
               
           SET @cExecStatements = N'EXEC rdt.' + RTRIM( @cRDTBartenderSP) +     
                                   '   @nMobile               ' +      
                                   ' , @nFunc                 ' +                       
                                   ' , @cLangCode             ' +          
                                   ' , @cFacility             ' +          
                                   ' , @cStorerKey            ' +       
                                   ' , @cLabelPrinter         ' +       
                                   ' , @cDropID               ' +    
                                   ' , @cLoadKey              ' +   
                                   ' , @cLabelNo              ' +    
                                   ' , @cUserName             ' +     
                                   ' , @nErrNo       OUTPUT   ' +    
                                   ' , @cErrMSG      OUTPUT   '     
     
                
           SET @cExecArguments =     
                      N'@nMobile     int,                   ' +    
                      '@nFunc       int,                    ' +        
                      '@cLangCode   nvarchar(3),            ' +        
                      '@cFacility   nvarchar(5),            ' +        
                      '@cStorerKey  nvarchar(15),           ' +        
                      '@cLabelPrinter  nvarchar(10),        ' +       
                      '@cDropID        nvarchar(20),        ' +        
                      '@cLoadKey    nvarchar(10),           ' +  
                      '@cLabelNo    nvarchar(20),           ' +                             
                      '@cUserName   nvarchar(18),           ' +    
                      '@nErrNo      int  OUTPUT,            ' +    
                      '@cErrMsg     nvarchar(1024) OUTPUT   '     
                          
          
               
           EXEC sp_executesql @cExecStatements, @cExecArguments,     
                                 @nMobile                   
                               , @nFunc                                     
                               , @cLangCode                        
                               , @cFacility           
                               , @cStorerKey       
                               , @cLabelPrinter                
                               , @cDropID    
                               , @cLoadKey  
                               , @cLabelNo  
                               , @cUserName    
                               , @nErrNo       OUTPUT       
                               , @cErrMSG      OUTPUT       
                
            IF @nErrNo <> 0        
            BEGIN        
      
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InvalidCarton'    
            

               GOTO RollBackTran        
            END      
     
              
        END    
            
            
     END    
         
     
     UPDATE dbo.DropID WITH (ROWLOCK) 
     SET Status = '9'
     WHERE DropID = @cDropID
     AND LoadKey = @cLoadKey
     AND Status = '5'
     
     IF @@ERROR <> 0 
     BEGIN    
        SET @nErrNo = 88909
        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --'InsDropIDDetFail'
        --SET @cErrMsg = 'UpdDropIDFail'
        GOTO RollBackTran
     END  
         

      
   END
  
   --COMMIT TRAN rdt_816ExtUpdateSP01 -- Only commit change made in rdt_816ExtUpdateSP01  
   GOTO Quit  
  
RollBackTran:  
   ROLLBACK TRAN rdt_816ExtUpdateSP01 -- Only rollback change made in rdt_816ExtUpdateSP01  
Quit:  
   -- Commit until the level we started  
   WHILE @@TRANCOUNT > @nTranCount  
      COMMIT TRAN  rdt_816ExtUpdateSP01
Fail:  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_816ExtUpdateSP01 TO NSQL
GO
