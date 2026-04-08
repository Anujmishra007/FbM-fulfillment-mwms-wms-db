SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_838PackCfmSP12                                        */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: ONBR BRA                                                          */
/*                                                                            */
/* Date       Rev  Author      Purposes                                       */
/* 2026-02-12 1.0  NLT013      UWP-48240. Created                             */
/* 2026-03-31 1.1  JackC       FCR-11193 Move Inv from FromDropID to LabelNo  */
/* 2026-04-08 1.2  NLT013      FCR-11343. Update Packheader for single        */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838PackCfmSP12] (
    @nMobile      INT
   ,@nFunc        INT
   ,@cLangCode    NVARCHAR( 3)
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cFacility    NVARCHAR( 5)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cPickSlipNo  NVARCHAR( 10)
   ,@cFromDropID  NVARCHAR( 20)
   ,@cPackDtlDropID NVARCHAR( 20)
   ,@cPrintPackList NVARCHAR( 1) OUTPUT
   ,@nErrNo       INT            OUTPUT
   ,@cErrMsg      NVARCHAR(250)  OUTPUT
)
AS
BEGIN      
   SET NOCOUNT ON      
   SET QUOTED_IDENTIFIER OFF      
   SET ANSI_NULLS OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @nDebugFlag  INT = 0

   DECLARE @bSuccess  INT      
   DECLARE @cLoadKey  NVARCHAR( 10)      
   DECLARE @cOrderKey NVARCHAR( 10)      
   DECLARE @cZone     NVARCHAR( 18)      
   DECLARE @nPackQTY  INT      
   DECLARE @nPickQTY  INT      
   DECLARE @cPickStatus  NVARCHAR(1)      
   DECLARE @cPackConfirm NVARCHAR(1)      

   --V1.1 variables
   DECLARE @nFromDropID_PickQty     INT
   DECLARE @nFromDropID_PackQty     INT
   DECLARE @cLoopDropID             NVARCHAR(20)
   DECLARE @cPackByFromDropID       NVARCHAR( 1)
   DECLARE @cMoveInvFlag            NVARCHAR( 1)
   DECLARE @cLoopSKU                NVARCHAR(20)
   DECLARE @cLoopLot                NVARCHAR(10)
   DECLARE @nLoopQTY                INT
   DECLARE @cFromLOC                NVARCHAR(10)
   DECLARE @cMoveQTYPick            NVARCHAR(1)

   SET @cOrderKey = ''      
   SET @cLoadKey = ''      
   SET @cZone = ''      
   SET @cPackConfirm = ''      
   SET @nPackQTY = 0      
   SET @nPickQTY = 0      
      
   -- Check pack confirm already      
   IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')      
      GOTO Quit      
      
   -- Storer config      
   SET @cPickStatus = rdt.rdtGetConfig( @nFunc, 'PickStatus', @cStorerKey)
   --V1.1
   SET @cPackByFromDropID = rdt.rdtGetConfig( @nFunc, 'PackByFromDropID', @cStorerKey)      

   DECLARE @cIsB2CSingle         NVARCHAR(1) = '0'
   DECLARE @cB2CSingleFlexPack   NVARCHAR(20) = '0'

   SELECT 
      @cIsB2CSingle        = C_String1
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cB2CSingleFlexPack = rdt.rdtGetConfig(@nFunc, 'B2CSingleFlexPack', @cStorerKey)
      
   -- Get PickHeader info      
   SELECT TOP 1      
      @cOrderKey = OrderKey,      
      @cLoadKey = ExternOrderKey,      
      @cZone = Zone      
   FROM dbo.PickHeader WITH (NOLOCK)      
   WHERE PickHeaderKey = @cPickSlipNo      
      
   -- Calc pack QTY      
   SET @nPackQTY = 0      
   SELECT @nPackQTY = ISNULL( SUM( QTY), 0) FROM PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo      
      
   -- Cross dock PickSlip      
   IF @cZone IN ('XD', 'LB', 'LP')      
   BEGIN      
      -- Check outstanding PickDetail      
      IF EXISTS( SELECT TOP 1 1      
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK)      
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)      
         WHERE RKL.PickSlipNo = @cPickSlipNo      
            AND PD.Status < '5'      
            AND PD.QTY > 0      
            AND (PD.Status = '4' OR PD.Status <> @cPickStatus))  -- Short or not yet pick      
         SET @cPackConfirm = 'N'      
      ELSE      
         SET @cPackConfirm = 'Y'      
            
      -- Check fully packed      
      IF @cPackConfirm = 'Y'      
      BEGIN      
         SELECT @nPickQTY = SUM( QTY)       
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK)      
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)      
         WHERE RKL.PickSlipNo = @cPickSlipNo      
               
         IF @nPickQTY <> @nPackQTY      
            SET @cPackConfirm = 'N'      
      END      
   END      
      
   -- Discrete PickSlip      
   ELSE IF @cOrderKey <> ''      
   BEGIN      
      -- Check outstanding PickDetail      
      IF EXISTS( SELECT TOP 1 1      
         FROM dbo.PickDetail PD WITH (NOLOCK)      
         WHERE PD.OrderKey = @cOrderKey      
            AND PD.Status < '5'      
            AND PD.QTY > 0      
            AND (PD.Status = '4' OR PD.Status <> @cPickStatus))  -- Short or not yet pick      
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
   END      
         
   -- Conso PickSlip      
   ELSE IF @cLoadKey <> ''      
   BEGIN      
      -- Check outstanding PickDetail      
   IF EXISTS( SELECT TOP 1 1       
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)       
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)      
         WHERE LPD.LoadKey = @cLoadKey      
            AND PD.Status < '5'      
            AND PD.QTY > 0      
            AND (PD.Status = '4' OR PD.Status <> @cPickStatus))  -- Short or not yet pick      
         SET @cPackConfirm = 'N'      
      ELSE      
         SET @cPackConfirm = 'Y'      
            
      -- Check fully packed      
      IF @cPackConfirm = 'Y'      
      BEGIN      
         SELECT @nPickQTY = SUM( PD.QTY)       
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)       
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)      
         WHERE LPD.LoadKey = @cLoadKey      
               
         IF @nPickQTY <> @nPackQTY      
            SET @cPackConfirm = 'N'      
      END      
   END      
      
   -- Custom PickSlip      
   ELSE      
   BEGIN      
      -- Check outstanding PickDetail      
      IF EXISTS( SELECT TOP 1 1       
         FROM PickDetail PD WITH (NOLOCK)       
         WHERE PD.PickSlipNo = @cPickSlipNo      
            AND PD.Status < '5'      
            AND PD.QTY > 0      
            AND (PD.Status = '4' OR PD.Status <> @cPickStatus))  -- Short or not yet pick      
         SET @cPackConfirm = 'N'      
      ELSE      
         SET @cPackConfirm = 'Y'      
      
      -- Check fully packed      
      IF @cPackConfirm = 'Y'      
      BEGIN      
         SELECT @nPickQTY = SUM( PD.QTY)       
         FROM PickDetail PD WITH (NOLOCK)       
         WHERE PD.PickSlipNo = @cPickSlipNo      
               
         IF @nPickQTY <> @nPackQTY      
            SET @cPackConfirm = 'N'      
      END      
   END

   --V1.1 start --set Move inventory flag
   SET @cMoveInvFlag = '0'

   IF @nDebugFlag = 1
      SELECT 'Set Move FromDropID flag'

   IF @cPackByFromDropID = '1' AND ISNULL (@cFromDropID, '') <> ''
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) 
                        WHERE StorerKey = @cStorerKey
                           AND DropID = @cFromDropID
                           AND UOM = '2')
      BEGIN
         SELECT @nFromDropID_PickQty = ISNULL(SUM(QTY), 0)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND DropID = @cFromDropID
         AND Status = @cPickStatus

         SELECT @nFromDropID_PackQty = ISNULL(SUM(QTY), 0)
         FROM dbo.PackDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND DropID = @cFromDropID

         IF @nFromDropID_PickQty = @nFromDropID_PackQty
         BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.PickDetail WITH (NOLOCK) 
                           WHERE StorerKey = @cStorerKey
                              AND DropID = @cFromDropID
                              AND CaseId = ''
                              AND Status = @cPickStatus)
            BEGIN
               SET @cMoveQTYPick = rdt.RDTGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)

               IF @cMoveQTYPick <> '1'
               BEGIN
                  SET @nErrNo = 262655
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               IF @nDebugFlag = 1
                  SELECT 'Set MoveInvFlag = 1'
               SET @cMoveInvFlag = '1' 
            END
            ELSE
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'FromDropId still exists in PKD'
            END
         END
         ELSE
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'PickQty <> PackQty', @nFromDropID_PickQty AS PickQty, @nFromDropID_PackQty AS PackQty
         END
      END
      ELSE
      BEGIN
         IF @nDebugFlag = 1
               SELECT 'UCC Pack, No need to movement'
      END
   END
   ELSE
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'PackByFromDropID is off, or FromDropID is empty'
   END
   --V1.1 end      

   DECLARE @tPickSlipNo TABLE (RowRef INT IDENTITY(1,1), PickSlipNo NVARCHAR(10))
   IF @cB2CSingleFlexPack = '1' AND @cIsB2CSingle = '1'
   BEGIN
      IF @cPackByFromDropID = '1' AND ISNULL(@cFromDropID, '') <> ''
      BEGIN
         IF NOT EXISTS( SELECT 1 
            FROM dbo.PackDetail WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND DropID = @cFromDropID
               AND Qty <> ExpQty
               AND ExpQty > 0)
         BEGIN
            SET @cPackConfirm = 'Y'

            INSERT INTO @tPickSlipNo (PickSlipNo)
            SELECT PickSlipNo 
            FROM dbo.PackDetail WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND DropID = @cFromDropID
         END
         ELSE
         BEGIN
            SET @cPackConfirm = 'N'
         END
      END
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
      GOTO Quit
      
   -- Handling transaction      
   DECLARE @nTranCount  INT      
   SET @nTranCount = @@TRANCOUNT      
   BEGIN TRAN  -- Begin our own transaction      
   SAVE TRAN rdt_838PackCfmSP12 -- For rollback or commit only our own transaction      

   -- Pack confirm      
   IF @cPackConfirm = 'Y'      
   BEGIN      
      IF EXISTS(SELECT 1 FROM @tPickSlipNo)
      BEGIN
         DECLARE @nLoopIndex INT = -1
         WHILE 1 = 1
         BEGIN
            SELECT TOP 1 @nLoopIndex = RowRef, @cPickSlipNo = PickSlipNo
            FROM @tPickSlipNo
            WHERE RowRef > @nLoopIndex
            ORDER BY RowRef

            IF @@ROWCOUNT = 0
               BREAK

            BEGIN TRY
               UPDATE dbo.PackHeader WITH(ROWLOCK)
                  SET Status = '9'
               WHERE PickSlipNo = @cPickSlipNo
                  AND Status <> '9'
            END TRY
            BEGIN CATCH
               SET @nErrNo = 262657
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --  Update PackHeader failed
               GOTO RollBackTran
            END CATCH

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
         END
      END
      ELSE
      BEGIN
         -- Pack confirm      
         UPDATE PackHeader SET       
            Status = '9'       
         WHERE PickSlipNo = @cPickSlipNo      
            AND Status <> '9'      
         SET @nErrNo = @@ERROR       
         IF @nErrNo <> 0      
         BEGIN      
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PackCfm Fail      
            GOTO RollBackTran      
         END      
         
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
         
         --- ABS    
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
                  VALUES (@cPickSlipNo, @nCartonNo, '0', @nCube, @nQTY, @cCartonType, @nCartonLength, @nCartonWidth, @nCartonHeight)    
                  IF @nErrNo <> 0    
                  BEGIN    
                     SET @nErrNo = 193601     
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- INS PKInf Fail    
                     GOTO RollBackTran    
                  END    
      
                  FETCH NEXT FROM @curPD INTO @nCartonNo    
               END    
            END    
         END    
      END
    
      --abs    
      IF NOT EXISTS ( SELECT 1       
            FROM Packinfo (NOLOCK)      
            WHERE PickSlipNo = @cPickslipNo      
               AND ISNULL(weight,'') IN (0,'')      
            )  AND NOT EXISTS (      
            SELECT 1    
            FROM (      
               SELECT COUNT(DISTINCT CartonNo) AS CNT1      
               FROM PackDetail WITH (NOLOCK)      
               WHERE PickSlipNo = @cPickSlipNo      
            ) AS A,      
            (      
               SELECT COUNT(DISTINCT CartonNo) AS CNT2      
               FROM PackInfo WITH (NOLOCK)      
               WHERE PickSlipNo = @cPickSlipNo    
            ) AS B      
            WHERE A.CNT1 <> B.CNT2)      
      BEGIN      
         -- Insert transmitlog2 here (trigger S272)        
         SET @bSuccess = 1        
         EXEC ispGenTransmitLog2         
             @c_TableName        = 'WSRDTPACKCFM'        
            ,@c_Key1             = @cPickslipNo        
            ,@c_Key2             = ''        
            ,@c_Key3             = @cStorerkey        
            ,@c_TransmitBatch    = ''        
            ,@b_Success          = @bSuccess    OUTPUT        
            ,@n_err              = @nErrNo      OUTPUT        
            ,@c_errmsg           = @cErrMsg     OUTPUT              
        
         IF @bSuccess <> 1            
            GOTO RollBackTran       
      END 
   END-- pack confirm

   --V1.1 start: Move inventory from FromDropID to LabelNo
   IF @cMoveInvFlag = '1'
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Move Inventory from fromDropID to LabelNo Logic', @cFromDropID AS FromDropID

      BEGIN TRY
         UPDATE dbo.PickDetail WITH (ROWLOCK) SET
            DropID = CaseId,
            Status = '5',
            EditWho = SUSER_SNAME(),
            EditDate = GETDATE()
         WHERE StorerKey = @cStorerKey
            AND ID = @cFromDropID
            AND Status = @cPickStatus
      END TRY
      BEGIN CATCH
         SET @nErrNo = 262652
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH

      SELECT TOP 1 @cFromLOC = LOC
      FROM dbo.LotxLocxID WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ID = @cFromDropID

      IF ISNULL(@cFromLOC,'') = ''
      BEGIN
         SET @nErrNo = 262654
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END

      DECLARE curMove CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DropID, SKU, Lot, SUM(QTY) AS QTY
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND ID = @cFromDropID
            AND Status = '5'
         GROUP BY DropID, SKU, Lot
         HAVING SUM(QTY) > 0

      OPEN curMove
      FETCH NEXT FROM curMove INTO @cLoopDropID, @cLoopSKU, @cLoopLot, @nLoopQTY

      WHILE @@FETCH_STATUS = 0
      BEGIN
         EXECUTE rdt.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode,
            @nErrNo      = @nErrNo OUTPUT,
            @cErrMsg     = @cErrMsg OUTPUT,
            @cSourceType = 'rdt_838PackCfmSP12',
            @cStorerKey  = @cStorerKey,
            @cFacility   = @cFacility,
            @cFromLOC    = @cFromLOC,
            @cToLOC      = @cFromLOC,
            @cFromID     = @cFromDropID,
            @cToID       = @cLoopDropID,
            @cSKU        = @cLoopSKU,
            @nQTY        = @nLoopQTY,
            @nQTYPick    = @nLoopQTY,
            @cFromLOT    = @cLoopLot,
            @cCaseID     = @cLoopDropID,
            @nFunc       = @nFunc

         IF @nErrNo <> 0
         BEGIN
            CLOSE curMove
            DEALLOCATE curMove
            GOTO RollBackTran
         END

         FETCH NEXT FROM curMove INTO @cLoopDropID, @cLoopSKU, @cLoopLot, @nLoopQTY
      END

      CLOSE curMove
      DEALLOCATE curMove

      BEGIN TRY
         UPDATE dbo.PackDetail WITh (ROWLOCK)
         SET DropID = LabelNo
         WHERE StorerKey = @cStorerKey
            AND DropID = @cFromDropID
      END TRY
      BEGIN CATCh
         SET @nErrNo = 262656
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH
   END
   --V1.1 end          
      
   COMMIT TRAN rdt_838PackCfmSP12      
   GOTO Quit      
      
RollBackTran:      
   ROLLBACK TRAN rdt_838PackCfmSP12 -- Only rollback change made here      
Quit:      
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started      
      COMMIT TRAN      
      
END 
GO
GRANT EXECUTE ON  [RDT].[rdt_838PackCfmSP12] TO [NSQL]
GO
