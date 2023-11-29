SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_840ExtUpd30                                     */
/* Purpose:                                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2023-09-27 1.0  James      WMS-23619 - Created                       */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_840ExtUpd30 (
   @nMobile     INT,
   @nFunc       INT, 
   @cLangCode   NVARCHAR( 3), 
   @nStep       INT, 
   @nInputKey   INT, 
   @cStorerkey  NVARCHAR( 15), 
   @cOrderKey   NVARCHAR( 10), 
   @cPickSlipNo NVARCHAR( 10), 
   @cTrackNo    NVARCHAR( 20), 
   @cSKU        NVARCHAR( 20), 
   @nCartonNo   INT,
   @cSerialNo   NVARCHAR( 30), 
   @nSerialQTY  INT,   
   @nErrNo      INT           OUTPUT, 
   @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @cUserDefine04     NVARCHAR( 20)
   DECLARE @cCartonType       NVARCHAR( 10)
   DECLARE @cCarrierName      NVARCHAR( 30)   
   DECLARE @cKeyName          NVARCHAR( 30)
   DECLARE @cNewTrackingNo    NVARCHAR( 20)
   DECLARE @cCurTrackingNo    NVARCHAR( 20)
   DECLARE @cShipperKey       NVARCHAR( 15)
   DECLARE @cLabelPrinter     NVARCHAR( 10)
   DECLARE @cFacility         NVARCHAR( 5)
   DECLARE @cPickDetailKey    NVARCHAR( 10)
   DECLARE @cLabelNo          NVARCHAR( 20)
   DECLARE @cLabelLine        NVARCHAR( 5)
   DECLARE @cShipLabel        NVARCHAR( 10)
   DECLARE @cNekopostLabel    NVARCHAR( 10)
   DECLARE @nTranCount        INT

   DECLARE @cPreDelNote       NVARCHAR( 10)  -- (james02)
   DECLARE @cPaperPrinter     NVARCHAR( 10)  -- (james02)
   DECLARE @cOrderGroup       NVARCHAR( 20)
   DECLARE @cTrackingNo       NVARCHAR( 20)
   DECLARE @nPackInfCtnNo     INT = 0
   DECLARE @curPackInfo       CURSOR
   DECLARE @nExpectedQty      INT = 0
   DECLARE @nPackedQty        INT = 0
   DECLARE @cDefEcomCartonCnt INT,
           @nCurrentCtnNo     INT,
           @nNewCartonNo      INT,
           @cCommand          NVARCHAR(1000)= '',  
           @cTransmitlogKey   NVARCHAR(10)  = '', 
           @cIP               VARCHAR(20)   = '',  
           @cPort             VARCHAR(10)   = '',  
           @nThreadPerAcct    INT           = 0,  
           @nMilisecondDelay  INT           = 0,  
           @cAPP_DB_Name      VARCHAR(30)   = '',      
           @nThreadPerStream  INT           = 0,  
           @cIniFilePath      NVARCHAR(200) = '',  
           @cDataStream       VARCHAR(10)   = '',
           @cECOM_Platform    NVARCHAR( 30) = '',
           @cTableName        NVARCHAR( 30) = '',
           @bSuccess          INT,
           @ndebug            INT

   DECLARE @curUpdPack     CURSOR
   DECLARE @nTempCtnNo     INT
   DECLARE @nTempQty       INT
   DECLARE @cTempLabelNo   NVARCHAR( 20)
            
   SELECT @cCartonType = I_Field04,
          @cFacility = Facility, 
          @cLabelPrinter = Printer,
          @cPaperPrinter = Printer_Paper 
   FROM rdt.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile
      
   IF @nInputKey = 1
   BEGIN
      IF @nStep = 1
      BEGIN
         IF EXISTS ( SELECT 1 FROM dbo.ORDERS WITH (NOLOCK)
                     WHERE StorerKey = @cStorerkey
                     AND   DocType = 'E'
                     AND   UserDefine01 = 'VC30')
         BEGIN
            SET @cPreDelNote = rdt.RDTGetConfig( @nFunc, 'PreDelNote', @cStorerKey)
            IF @cPreDelNote = '0'
               SET @cPreDelNote = ''   

            IF @cPreDelNote <> ''
            BEGIN  
               DECLARE @tDELNOTES AS VariableTable  
               INSERT INTO @tDELNOTES (Variable, Value) VALUES ( '@cOrderKey',    @cOrderKey)  
               INSERT INTO @tDELNOTES (Variable, Value) VALUES ( '@cLoadKey',     '')  
               INSERT INTO @tDELNOTES (Variable, Value) VALUES ( '@cType',        '')  
  
               -- Print label  
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, '', @cPaperPrinter,   
                  @cPreDelNote,  -- Report type  
                  @tDELNOTES,    -- Report params  
                  'rdt_840ExtUpd30',   
                  @nErrNo     OUTPUT,  
                  @cErrMsg    OUTPUT   
            END  
         END
      END
      
      IF @nStep = 2
      BEGIN
         IF ISNULL( @cTrackNo, '') = ''
         BEGIN
            SET @nErrNo = 206851
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'NO TRACK NO'
            GOTO Quit
         END
                     
         --SELECT @cUserDefine04 = UserDefine04 
         SELECT @cUserDefine04 = TrackingNo -- (james02)
         FROM dbo.Orders WITH (NOLOCK) 
         WHERE Orderkey = @cOrderKey
         AND   Storerkey = @cStorerKey

         IF ISNULL( @cUserDefine04, '') <> ''
         BEGIN
            IF @cUserDefine04 <> @cTrackNo
            BEGIN
               SET @nErrNo = 206852
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'INV TRACK NO'
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            UPDATE dbo.Orders WITH (ROWLOCK) SET
               --UserDefine04 = @cTrackNo, TrafficCop = NULL
               TrackingNo = @cTrackNo, TrafficCop = NULL -- (james03)
            WHERE Orderkey = @cOrderKey
            AND   Storerkey = @cStorerKey

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 206852
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Upd Track Fail'
               GOTO Quit
            END
         END
      END   -- @nStep = 2
      
      IF @nStep = 4
      BEGIN
         SELECT 
            @cShipperKey = ShipperKey, 
            @cOrderGroup = OrderGroup,
            @cECOM_Platform = ECOM_Platform
         FROM dbo.ORDERS WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey

         SET @nTranCount = @@TRANCOUNT
         BEGIN TRAN  -- Begin our own transaction
         SAVE TRAN rdt_840ExtUpd30 -- For rollback or commit only our own transaction

         SELECT @nExpectedQty = ISNULL(SUM(Qty), 0) FROM PickDetail WITH (NOLOCK)  
         WHERE Orderkey = @cOrderkey  
         AND Storerkey = @cStorerkey  
  
         SELECT @nPackedQty = ISNULL(SUM(Qty), 0) FROM dbo.PackDetail WITH (NOLOCK)  
         WHERE PickSlipNo = @cPickSlipNo  
      
         IF @nExpectedQty > @nPackedQty
         BEGIN
            -- If not 1st carton, not exists in packdetail yet, get new tracking no
            IF NOT EXISTS ( SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) 
                            WHERE PickSlipNo = @cPickSlipNo 
                            AND CartonNo = @nCartonNo + 1)
            BEGIN
            	-- Decide whether need send interface to get new tracking no (james02)
            	SELECT @cDefEcomCartonCnt = UDF01 
            	FROM dbo.CODELKUP WITH (NOLOCK) 
            	WHERE ListName = 'WSCOURIER' 
            	AND   Code LIKE '%CourierMultiTrackNo' 
            	AND   Storerkey = @cStorerkey
            	AND   Short = @cShipperKey 
            	AND   code2 = @cECOM_Platform

               SELECT @nCurrentCtnNo = MAX( CartonNo)
               FROM dbo.PackDetail WITH (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               
               IF ( CAST( @cDefEcomCartonCnt AS INT) - @nCurrentCtnNo < 2) OR @cDefEcomCartonCnt is NULL
               BEGIN
                  SELECT @cTableName = Long
                  FROM dbo.CODELKUP WITH (NOLOCK)
                  WHERE LISTNAME = 'RDT840TBN'
                  AND   Short = @cECOM_Platform
                  AND   Storerkey = @cStorerkey
                  
                  IF ISNULL( @cTableName, '') = ''
                     SET @cTableName = 'Other'

                  IF @cTableName <> 'Other'
                  BEGIN
                  	IF @cTableName = 'WSCRPKADDCN'
                  	   SET @cDataStream = '6157'
                  	ELSE IF @cTableName = 'WSCRPKADDDY'
                  	   SET @cDataStream = '6476'
                  	ELSE IF @cTableName = 'WSCRPKADDJD'
                  	   SET @cDataStream = '6717'
                  	   
                     SET @nNewCartonNo = @nCartonNo + 1
                     SET @bSuccess = 1    
                     EXEC ispGenTransmitLog2    
                         @c_TableName        = @cTableName    
                        ,@c_Key1             = @cOrderKey    
                        ,@c_Key2             = @nNewCartonNo    
                        ,@c_Key3             = @cStorerkey    
                        ,@c_TransmitBatch    = ''    
                        ,@b_Success          = @bSuccess    OUTPUT    
                        ,@n_err              = @nErrNo      OUTPUT    
                        ,@c_errmsg           = @cErrMsg     OUTPUT    
    
                     IF @bSuccess <> 1    
                     BEGIN
                        SET @nErrNo = 206854  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InsTL2Log Err'  
                        GOTO RollBackTran    
                     END

                     SELECT TOP 1 @cTransmitlogKey = TransmitlogKey
                     FROM dbo.TRANSMITLOG2 WITH (NOLOCK)
                     WHERE tablename = @cTableName
                     AND   key1 = @cOrderKey
                     AND   key2 = @nNewCartonNo
                     AND   key3 = @cStorerkey
                     ORDER BY AddDate DESC
                     
                     SELECT @cCommand = StoredProcName + ',@c_TransmitlogKey=''' + @cTransmitlogKey + ''' '   
                           ,@cIP = IP  
                           ,@cPort = Port  
                           ,@nThreadPerAcct = ThreadPerAcct  
                           ,@nMilisecondDelay = MilisecondDelay   
                           ,@cAPP_DB_Name = App_DB_Name--TargetDB        
                           ,@cIniFilePath = IniFilePath                  
                           ,@nThreadPerStream = ThreadPerStream          
                     FROM  QCmd_TransmitlogConfig WITH (NOLOCK)    
                     WHERE DataStream = @cDataStream   
                        AND TableName = @cTableName    
                        AND StorerKey = @cStorerKey  
  
                     IF @ndebug = 1
                     BEGIN
                     	SELECT @cDataStream '@cDataStream', @cTableName '@cTableName', @cStorerKey '@cStorerKey', @cTransmitlogKey '@cTransmitlogKey'
                     END
                     
                     SET @bSuccess = 1
                        EXEC isp_QCmd_SubmitTaskToQCommander       
                              @cTaskType        = 'T'-- D=By Datastream, T=Transmitlog, O=Others             
                           ,  @cStorerKey       = @cStorerKey                                                  
                           ,  @cDataStream      = @cDataStream                                                           
                           ,  @cCmdType         = 'SQL'                                                        
                           ,  @cCommand         = @cCommand                                                    
                           ,  @cTransmitlogKey  = @cTransmitlogKey                                               
                           ,  @nThreadPerAcct   = @nThreadPerAcct                                                      
                           ,  @nThreadPerStream = @nThreadPerStream                                                            
                           ,  @nMilisecondDelay = @nMilisecondDelay                                                            
                           ,  @nSeq             = 1                             
                           ,  @cIP              = @cIP                                               
                           ,  @cPORT            = @cPort                                                      
                           ,  @cIniFilePath     = @cIniFilePath             
                           ,  @cAPPDBName       = @cAPP_DB_Name                                                     
                           ,  @bSuccess         = @bSuccess    OUTPUT                                       
                           ,  @nErr             = @nErrNo      OUTPUT        
                           ,  @cErrMsg          = @cErrMsg     OUTPUT   
                           ,  @nPriority        = 2                                                      

                     IF @bSuccess <> 1 OR ISNULL( @cErrMsg , '') <> ''     
                     BEGIN    
                        SET @nErrNo = 206855
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'TCP Socket Err'
                        GOTO RollBackTran
                     END   
                  END
               END
            END
         END
         ELSE
         BEGIN
            SET @curUpdPack = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT CartonNo, LabelNo, SUM( Qty)
            FROM dbo.PackDetail WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
            GROUP BY CartonNo, LabelNo
            ORDER BY CartonNo
            OPEN @curUpdPack
            FETCH NEXT FROM @curUpdPack INTO @nTempCtnNo, @cTempLabelNo, @nTempQty 
            WHILE @@FETCH_STATUS = 0
            BEGIN
         	   UPDATE dbo.PackInfo SET 
         	      Qty = @nTempQty, 
         	      RefNo = @cTempLabelNo,
         	      TrackingNo = @cTempLabelNo,
         	      EditWho = SUSER_SNAME(), 
         	      EditDate = GETDATE()
         	   WHERE PickSlipNo = @cPickSlipNo
         	   AND   CartonNo = @nTempCtnNo
         	
         	   IF @@ERROR <> 0
         	   BEGIN
         		   SET @nErrNo = 206863      
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD PACKINF Er'      
                  GOTO RollBackTran
         	   END
         	
         	   FETCH NEXT FROM @curUpdPack INTO @nTempCtnNo, @cTempLabelNo, @nTempQty
            END
         END
         
         IF EXISTS ( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                     AND   [Status] = '9')
         BEGIN
            IF @cOrderGroup = 'NETSDL'
            BEGIN
         	   SET @curPackInfo = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         	   SELECT CartonNo
         	   FROM dbo.PackInfo WITH (NOLOCK)
         	   WHERE PickSlipNo = @cPickSlipNo
         	   ORDER BY 1
         	   OPEN @curPackInfo
         	   FETCH NEXT FROM @curPackInfo INTO @nPackInfCtnNo
         	   WHILE @@FETCH_STATUS = 0
         	   BEGIN
         	   	IF @nPackInfCtnNo = 1
         	   	   SELECT @cTrackingNo = TrackingNo
         	   	   FROM dbo.ORDERS WITH (NOLOCK)
         	   	   WHERE OrderKey = @cOrderKey
         	   	ELSE
         	   		SELECT @cTrackingNo = TrackingNo
         	   		FROM dbo.CartonTrack WITH (NOLOCK)
         	   		WHERE LabelNo = @cOrderKey
         	   		AND   CarrierRef1 = @cOrderKey + CAST( @nPackInfCtnNo AS NVARCHAR( 2))
         	   	
         	   	UPDATE dbo.PackInfo SET
         	   	   TrackingNo = @cTrackingNo, 
         	   	   EditWho = SUSER_SNAME(), 
         	   	   EditDate = GETDATE()
         	   	WHERE PickSlipNo = @cPickSlipNo
         	   	AND   CartonNo = @nPackInfCtnNo

                  IF @@ERROR <> 0  
                  BEGIN      
                     SET @nErrNo = 206856      
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD PACKINF Er'      
                     GOTO RollBackTran      
                  END 
                     	   	
         	   	FETCH NEXT FROM @curPackInfo INTO @nPackInfCtnNo
         	   END
         	   
            END         
         END
         
         IF EXISTS ( SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK) 
                     WHERE LISTNAME = 'FJNekoPack'
                     AND   Storerkey = @cStorerkey
                     AND   Code = @cCartonType)
         BEGIN
            SELECT @cCarrierName = short,   
                   @cKeyName = Long  
            FROM dbo.Codelkup WITH (NOLOCK)  
            WHERE Listname = 'AsgnTNo'   
            AND   Code = '3'   
            AND   StorerKey = @cStorerKey  
  
            SELECT @cNewTrackingNo = MIN( TrackingNo)  
            FROM dbo.CartonTrack WITH (NOLOCK)  
            WHERE CarrierName = @cCarrierName   
            AND   Keyname = @cKeyName   
            AND   ISNULL( CarrierRef2, '') = ''  

            IF ISNULL( @cNewTrackingNo, '') = ''  
            BEGIN      
               SET @nErrNo = 206857      
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'NO TRACKING #'      
               GOTO RollBackTran      
            END   

            SELECT @cCurTrackingNo = LabelNo
            FROM dbo.PackDetail WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
            AND   CartonNo = @nCartonNo
            
            -- Lock new Tracking no  
            UPDATE dbo.CartonTrack WITH (ROWLOCK) SET   
               LabelNo = @cOrderKey,    
               Carrierref2 = 'GET'  
            WHERE CarrierName = @cCarrierName   
            AND   Keyname = @cKeyName   
            AND   CarrierRef2 = ''  
            AND   TrackingNo = @cNewTrackingNo  
  
            IF @@ERROR <> 0  
            BEGIN      
               SET @nErrNo = 206858      
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ASSIGN TRACK# Err'      
               GOTO RollBackTran      
            END   
            
            -- Release current tracking no
            UPDATE dbo.CartonTrack WITH (ROWLOCK) SET   
               LabelNo = '',    
               Carrierref2 = ''  
            WHERE CarrierName = @cCarrierName   
            AND   Keyname = @cKeyName   
            AND   CarrierRef2 = 'GET'  
            AND   TrackingNo = @cCurTrackingNo
            AND   LabelNo = @cOrderKey  
  
            IF @@ERROR <> 0  
            BEGIN      
               SET @nErrNo = 206859      
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'RELEASE TRACK# Err'      
               GOTO RollBackTran      
            END   

            UPDATE dbo.ORDERS SET 
               TrackingNo = @cNewTrackingNo, 
               UserDefine04 = @cNewTrackingNo, 
               ShipperKey = @cCarrierName,
               EditDate = GETDATE(),
               EditWho = SUSER_SNAME()
            WHERE OrderKey = @cOrderKey

            IF @@ERROR <> 0  
            BEGIN      
               SET @nErrNo = 206860      
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD Orders Err'      
               GOTO RollBackTran      
            END   

            DECLARE @cur_UpdPickDtl CURSOR 
            SET @cur_UpdPickDtl = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
            SELECT PickDetailKey
            FROM dbo.PICKDETAIL WITH (NOLOCK)
            WHERE OrderKey = @cOrderKey 
            AND   CaseID = @cCurTrackingNo
            AND   Storerkey = @cStorerkey
            AND   [Status] < '9'
            OPEN @cur_UpdPickDtl
            FETCH NEXT FROM @cur_UpdPickDtl INTO @cPickDetailKey
            WHILE @@FETCH_STATUS = 0
            BEGIN
               
               UPDATE dbo.PICKDETAIL SET 
                  CaseID = @cNewTrackingNo,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cPickDetailKey

               IF @@ERROR <> 0  
               BEGIN      
                  SET @nErrNo = 206860      
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD PKDTL Err'      
                  GOTO RollBackTran      
               END   

               FETCH NEXT FROM @cur_UpdPickDtl INTO @cPickDetailKey
            END

            DECLARE @cur_UpdPackDtl CURSOR 
            SET @cur_UpdPackDtl = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
            SELECT LabelNo, LabelLine
            FROM dbo.PACKDETAIL WITH (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo 
            AND   CartonNo = @nCartonNo
            OPEN @cur_UpdPackDtl
            FETCH NEXT FROM @cur_UpdPackDtl INTO @cLabelNo, @cLabelLine
            WHILE @@FETCH_STATUS = 0
            BEGIN
               
               UPDATE dbo.PACKDETAIL SET 
                  LabelNo = @cNewTrackingNo,
                  EditDate = GETDATE(),
                  EditWho = SUSER_SNAME()
               WHERE PickSlipNo = @cPickSlipNo
               AND   CartonNo = @nCartonNo
               AND   LabelNo = @cLabelNo
               AND   LabelLine = @cLabelLine

               IF @@ERROR <> 0  
               BEGIN      
                  SET @nErrNo = 206862      
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UPD PKDTL Err'      
                  GOTO RollBackTran      
               END   

               FETCH NEXT FROM @cur_UpdPackDtl INTO @cLabelNo, @cLabelLine
            END

            SET @cNekopostLabel = rdt.RDTGetConfig( @nFunc, 'NekopostLabel', @cStorerKey)
            IF @cNekopostLabel = '0'
               SET @cNekopostLabel = ''

            IF @cNekopostLabel <> ''
            BEGIN
               DECLARE @tNekopost AS VariableTable
               INSERT INTO @tNekopost (Variable, Value) VALUES ( '@cStorerKey',  @cStorerKey)
               INSERT INTO @tNekopost (Variable, Value) VALUES ( '@cOrderKey',   @cOrderKey)
               INSERT INTO @tNekopost (Variable, Value) VALUES ( '@nCartonNo',   @nCartonNo)
               INSERT INTO @tNekopost (Variable, Value) VALUES ( '@cShipperKey',  @cCarrierName)

               -- Print label
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 2, 1, @cFacility, @cStorerkey, @cLabelPrinter, '', 
                  @cNekopostLabel, -- Report type
                  @tNekopost, -- Report params
                  'rdt_840ExtUpd30', 
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT 

               IF @nErrNo <> 0
                  GOTO RollBackTran
            END

         END
         ELSE
         BEGIN
            SET @cShipLabel = rdt.RDTGetConfig( @nFunc, 'FJShipLabel', @cStorerKey)
            IF @cShipLabel = '0'
               SET @cShipLabel = ''

            IF @cShipLabel <> ''
            BEGIN
               DECLARE @tSHIPPLABEL AS VariableTable
               INSERT INTO @tSHIPPLABEL (Variable, Value) VALUES ( '@cStorerKey',  @cStorerKey)
               INSERT INTO @tSHIPPLABEL (Variable, Value) VALUES ( '@cOrderKey',   @cOrderKey)
               INSERT INTO @tSHIPPLABEL (Variable, Value) VALUES ( '@nCartonNo',   @nCartonNo)
               INSERT INTO @tSHIPPLABEL (Variable, Value) VALUES ( '@cShipperKey',  @cShipperKey)

               -- Print label
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, 2, 1, @cFacility, @cStorerkey, @cLabelPrinter, '', 
                  @cShipLabel, -- Report type
                  @tSHIPPLABEL, -- Report params
                  'rdt_840ExtUpd30', 
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT
               
               IF @nErrNo <> 0
                  GOTO RollBackTran
            END
         END

         COMMIT TRAN rdt_840ExtUpd30

         GOTO Commit_Tran

         RollBackTran:
            ROLLBACK TRAN rdt_840ExtUpd30 -- Only rollback change made here
         Commit_Tran:
            WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
               COMMIT TRAN
      END
   END

   Quit:  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840ExtUpd30 TO NSQL
GO
