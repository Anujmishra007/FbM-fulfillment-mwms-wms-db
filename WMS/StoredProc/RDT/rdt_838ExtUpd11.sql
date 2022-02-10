if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_838ExtUpd11]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_838ExtUpd11]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtUpd11                                     */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 06-05-2021 1.0  yeekung    WMS-16963 Created                         */
/************************************************************************/

CREATE PROC rdt.rdt_838ExtUpd11 (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cFromDropID      NVARCHAR( 20),
   @nCartonNo        INT,
   @cLabelNo         NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cUCCNo           NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            NVARCHAR( 10),
   @cWeight          NVARCHAR( 10),
   @cRefNo           NVARCHAR( 20),
   @cSerialNo        NVARCHAR( 30),
   @nSerialQTY       INT,
   @cOption          NVARCHAR( 1),
   @cPackDtlRefNo    NVARCHAR( 20), 
   @cPackDtlRefNo2   NVARCHAR( 20), 
   @cPackDtlUPC      NVARCHAR( 30), 
   @cPackDtlDropID   NVARCHAR( 20), 
   @cPackData1       NVARCHAR( 30), 
   @cPackData2       NVARCHAR( 30), 
   @cPackData3       NVARCHAR( 30), 
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLabelLine NVARCHAR(5)
   DECLARE @nTranCount INT
   DECLARE @cPackDetailCartonID  NVARCHAR( 20),
           @cOrderkey  NVARCHAR(20),
           @cuserdefine04 NVARCHAR(20)

   SET @nTranCount = @@TRANCOUNT

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 3 -- SKU    
      BEGIN    
         IF @nInputKey = 1 -- ENTER    
         BEGIN    
            -- Without ToDropID    
            IF @cPackDtlDropID = ''    
               GOTO Quit    
                   
            -- New carton without SKU QTY    
            IF @nCartonNo = 0    
               GOTO Quit    
             
            -- PackDetail need to update    
            IF EXISTS( SELECT 1    
               FROM dbo.PackDetail WITH (NOLOCK)    
               WHERE PickSlipNo = @cPickSlipNo    
                  AND CartonNo = @nCartonNo    
                  AND LabelNo = @cLabelNo    
                  AND DropID <> @cPackDtlDropID)    
            BEGIN    
               -- Handling transaction    
               BEGIN TRAN  -- Begin our own transaction    
               SAVE TRAN rdt_838ExtUpd11 -- For rollback or commit only our own transaction    
                
               DECLARE @curPD CURSOR    
               SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
                  SELECT LabelLine    
                  FROM dbo.PackDetail WITH (NOLOCK)    
                  WHERE PickSlipNo = @cPickSlipNo    
                     AND CartonNo = @nCartonNo    
                     AND LabelNo = @cLabelNo    
                     AND DropID <> @cPackDtlDropID    
                
               -- Loop PickDetail    
               OPEN @curPD    
               FETCH NEXT FROM @curPD INTO @cLabelLine    
               WHILE @@FETCH_STATUS = 0    
               BEGIN    
                  -- Update Packdetail    
                  UPDATE dbo.PackDetail WITH (ROWLOCK) SET    
                     DropID = @cPackDtlDropID,     
                     EditWho = 'rdt.' + SUSER_SNAME(),    
                     EditDate = GETDATE(),    
                     ArchiveCop = NULL    
                  WHERE PickSlipNo = @cPickSlipNo    
                     AND CartonNo = @nCartonNo    
                     AND LabelNo = @cLabelNo    
                  AND LabelLine = @cLabelLine    
                  IF @@ERROR <> 0    
                  BEGIN    
                     SET @nErrNo = 168351    
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPackDtlFail    
                     GOTO RollBackTran    
                  END    
                   
                  FETCH NEXT FROM @curPD INTO @cLabelLine    
               END    
             
               COMMIT TRAN rdt_838ExtUpd11    
            END    
         END    
      END   

      IF @nStep = 4-- Weight,Cube
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @c_OrderKey NVARCHAR(20)

            SELECT @c_OrderKey=OrderKey
            FROM pickheader PH  WITH (NOLOCK) 
            WHERE PH.PickHeaderKey=@cPickSlipNo



            IF EXISTS ( SELECT 1 FROM dbo.CODELKUP C WITH (NOLOCK)                            
                     JOIN dbo.Orders O WITH (NOLOCK) ON (C.Code = O.Type AND C.StorerKey = O.StorerKey)     
                     WHERE C.ListName = 'HMORDTYPE'     
                     AND   C.UDF01 = 'M'     
                     AND   O.OrderKey = @c_OrderKey     
                     AND   O.StorerKey = @cStorerkey)
            BEGIN

               DECLARE @cLabelPrinter NVARCHAR(20),
                       @cPaperPrinter NVARCHAR(20),
                       @cCartonlbl   NVARCHAR(20)

               SET @cCartonlbl = rdt.RDTGetConfig( @nFunc, 'cartonlbl', @cStorerKey)  

               SELECT @cLabelPrinter=Printer,
               @cPaperPrinter=Printer_Paper
               FROM rdt.RDTMOBREC (nolock)
               WHERE mobile=@nMobile

               DECLARE c_orderkey CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT lpd.OrderKey
               FROM pickheader PH  WITH (NOLOCK) 
               JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK)  ON(PH.ExternOrderKey=LPD.LoadKey)  
               JOIN dbo.pickdetail pd WITH (NOLOCK) ON (PD.OrderKey=lpd.OrderKey)
               JOIN dbo.PackHeader phr (NOLOCK) ON (ph.PickHeaderKey=phr.PickSlipNo)
               JOIN dbo.PackDetail pds (NOLOCK) ON (pds.sku=pd.sku AND phr.PickSlipNo=pds.PickSlipNo AND pd.Storerkey=pd.Storerkey)
               WHERE ph.PickHeaderKey=@cPickSlipNo
               AND pds.LabelNo=@cLabelNo
               GROUP BY lpd.OrderKey

               OPEN c_orderkey      
               FETCH NEXT FROM c_orderkey INTO  @cOrderKey      
               WHILE (@@FETCH_STATUS <> -1)      
               BEGIN    
                   -- Common params  
                  DECLARE @tOrderlabel AS VariableTable  
                  INSERT INTO @tOrderlabel (Variable, Value) VALUES   
                     ( '@cOrderKey',     @cOrderKey),   
                     ( '@nFromCartonNo', CAST( @nCartonNo AS NVARCHAR(5)))
  
                  -- Print label  
                  EXEC RDT.rdt_Print @nMobile, 838, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,   
                     @cCartonlbl, -- Report type  
                     @tOrderlabel, -- Report params  
                     'rdt_838ExtUpd11',   
                     @nErrNo  OUTPUT,  
                     @cErrMsg OUTPUT  
                  IF @nErrNo <> 0  
                     GOTO Quit 
                  
                  DELETE   @tOrderlabel

                  FETCH NEXT FROM c_orderkey INTO  @cOrderKey 
               END
            END
         END
      END
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_838ExtUpd11 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtUpd11 TO NSQL
GO
