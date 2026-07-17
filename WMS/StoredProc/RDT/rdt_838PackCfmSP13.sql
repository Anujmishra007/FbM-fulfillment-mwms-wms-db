SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/********************************************************************************/
/* Store procedure: rdt_838PackCfmSP13                                          */
/* Copyright      : Maersk                                                      */
/*                                                                              */
/* Purpose: AEOMX                                                               */
/*                                                                              */
/* Date       Rev      Author      Purposes                                     */
/* 2026-07-08 1.0.0    JACKC       FCR-12984. Created                           */
/* 2026-07-09 1.0.1    JACKC       FCR-12984. Consider B2C single               */
/********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838PackCfmSP13] (
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

   DECLARE @nFromDropID_PickQty     INT
   DECLARE @nFromDropID_PackQty     INT
   DECLARE @cLoopCaseID             NVARCHAR(20)
   DECLARE @cPackByFromDropID       NVARCHAR( 1)
   DECLARE @cLoopSKU                NVARCHAR(20)
   DECLARE @cLoopLot                NVARCHAR(10)
   DECLARE @cLoopID                 NVARCHAR(18)
   DECLARE @nLoopQTY                INT
   DECLARE @cFromLOC                NVARCHAR(10)
   DECLARE @cMoveQTYAlloc           NVARCHAR(1)
   DECLARE @cPackStatus             NVARCHAR(1)
   DECLARE @cMsg01                  NVARCHAR (60)
   DECLARE @cMsg02                  NVARCHAR (60)
   DECLARE @cMsg03                  NVARCHAR (60)
   DECLARE @cUpdPKDFlag             NVARCHAR(1) = ''

   --B2C Single
   DECLARE @cB2CSingleFlag          NVARCHAR(1) = ''
   DECLARE @cB2CSingleLabelNo       NVARCHAR(20) = ''
   DECLARE @nB2CSinglePackQty       INT = 0
   DECLARE @nB2CSSingleExpPackQty   INT = 0

   DECLARE @tPickDetail TABLE (
      PickDetailKey NVARCHAR( 18)
   )

   SET @cOrderKey = ''      
   SET @cLoadKey = ''      
   SET @cZone = ''      
   SET @cPackConfirm = ''      
   SET @nPackQTY = 0      
   SET @nPickQTY = 0

   -- Storer config      
   SET @cPickStatus = rdt.rdtGetConfig( @nFunc, 'PickStatus', @cStorerKey)
   IF @cPickStatus = '0'
      SET @cPickStatus = '5'

   SET @cPackByFromDropID = rdt.rdtGetConfig( @nFunc, 'PackByFromDropID', @cStorerKey)


   SELECT
      @cB2CSingleLabelNo = V_STRING3, 
      @cB2CSingleFlag = C_STRING7 
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_838PackCfmSP13', @cPickSlipNo AS PickSlipNo, @cFromDropID AS FromDropID, 
         @cB2CSingleFlag AS B2CSingleFlag, @cB2CSingleLabelNo AS B2CSingleLabelNo

   --Update PickDetail status and dropid once FromDropID is fully packed
   IF @cPackByFromDropID = '1' AND ISNULL (@cFromDropID, '') <> ''
   BEGIN
      IF @cB2CSingleFlag <> 'Y'
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Set UpdPKDFlag, Not B2C Single', @cFromDropID AS FromDropID

         SELECT @nFromDropID_PickQty = ISNULL(SUM(QTY), 0)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND DropID = @cFromDropID
         AND Status = @cPickStatus

         SELECT @nFromDropID_PackQty = ISNULL(SUM(QTY), 0)
         FROM dbo.PackDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND DropID = @cFromDropID

         IF @nDebugFlag = 1
            SELECT 'FromDropID PickQty and PackQty', @nFromDropID_PickQty AS PickQty, @nFromDropID_PackQty AS PackQty

         IF @nFromDropID_PickQty = @nFromDropID_PackQty
         BEGIN
            BEGIN TRY
               INSERT INTO @tPickDetail (PickDetailKey)
               SELECT PickDetailKey
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cFromDropID
                  AND Status = @cPickStatus
                  AND Qty > 0
            END TRY
            BEGIN CATCH
               SET @nErrNo = 273251
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END CATCH

            IF EXISTS(SELECT 1 FROM @tPickDetail)
               SET @cUpdPKDFlag = 'Y'
         END
         ELSE
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'PickQty <> PackQty', @nFromDropID_PickQty AS PickQty, @nFromDropID_PackQty AS PackQty

            IF @nFromDropID_PackQty > @nFromDropID_PickQty
            BEGIN
               SET @nErrNo = 273252
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END
         END
      END -- not B2C single
      ELSE
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Set UpdPKDFlag, B2C Single', @cB2CSingleLabelNo AS LabelNo

         SELECT 
            @nB2CSinglePackQty = ISNULL(SUM(Qty),0),
            @nB2CSSingleExpPackQty = ISNULL(SUM(ExpQty),0)
         FROM dbo.PackDetail WITH(NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo 
            AND LabelNo = @cB2CSingleLabelNo
            AND StorerKey = @cStorerKey

         IF @nB2CSinglePackQty = @nB2CSSingleExpPackQty AND @nB2CSinglePackQty > 0
         BEGIN
            BEGIN TRY
               INSERT INTO @tPickDetail (PickDetailKey)
               SELECT PickDetailKey
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND CaseID = @cB2CSingleLabelNo
                  AND DropID = @cFromDropID
                  AND Status = @cPickStatus
                  AND Qty > 0
            END TRY
            BEGIN CATCH
               SET @nErrNo = 273256
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END CATCH

            IF EXISTS(SELECT 1 FROM @tPickDetail)
               SET @cUpdPKDFlag = 'Y'
         END
         ELSE
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'PackQty <> ExpPackQty', @nB2CSinglePackQty AS PackQty, @nB2CSSingleExpPackQty AS ExpPackQty

            IF @nB2CSinglePackQty > @nB2CSSingleExpPackQty
            BEGIN
               SET @nErrNo = 273257
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END
         END
      END
   END
   ELSE
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'PackByFromDropID is off, or FromDropID is empty'
   END

   IF EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status = '9')
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Pack was closed. Return'      
      GOTO Quit
   END      
   
   -- Get PickHeader info      
   SELECT TOP 1      
      @cOrderKey = OrderKey,      
      @cLoadKey = ExternOrderKey,      
      @cZone = Zone      
   FROM dbo.PickHeader WITH (NOLOCK)      
   WHERE PickHeaderKey = @cPickSlipNo      
      
   -- Calc pack QTY      
   SET @nPackQTY = 0      
   SELECT @nPackQTY = ISNULL( SUM( QTY), 0) FROM dbo.PackDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo      
      
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
         FROM dbo.PickDetail PD WITH (NOLOCK) 
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
         FROM dbo.PickDetail PD WITH (NOLOCK) 
         WHERE PD.PickSlipNo = @cPickSlipNo      
               
         IF @nPickQTY <> @nPackQTY      
            SET @cPackConfirm = 'N'      
      END      
   END

   -- Get storer config
   --PickDetail case id and dropid is handled by customized logic, turn off this config      
   DECLARE @cAssignPackLabelToOrdCfg NVARCHAR(1)  = 0    
   /*EXECUTE nspGetRight      
      @cFacility,      
      @cStorerKey,      
      '', --@c_sku      
      'AssignPackLabelToOrdCfg',      
      @bSuccess                 OUTPUT,      
      @cAssignPackLabelToOrdCfg OUTPUT,      
      @nErrNo                   OUTPUT,      
      @cErrMsg                  OUTPUT      

   IF @nErrNo <> 0      
      GOTO Quit*/
      
   -- Handling transaction      
   DECLARE @nTranCount  INT      
   SET @nTranCount = @@TRANCOUNT      
   BEGIN TRAN  -- Begin our own transaction      
   SAVE TRAN rdt_838PackCfmSP13 -- For rollback or commit only our own transaction

   IF @cUpdPKDFlag = 'Y'
   BEGIN
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Start update PickDetail', @cPickSlipNo AS PickSlipNo, @cFromDropID AS FromDropID
         SELECT * FROM @tPickDetail
      END

      BEGIN TRY
         UPDATE PD  WITH (ROWLOCK)
         SET PD.DropID = PD.CaseID,
            PD.Notes = REPLACE(ISNULL(PD.Notes, ''), '[PACKED]', ''),
            PD.EditDate = GETDATE(),
            PD.EditWho = SUSER_SNAME(),
            PD.TrafficCop = NULL
         FROM dbo.PickDetail PD
         JOIN @tPickDetail tPD ON (PD.PickDetailKey = tPD.PickDetailKey)
      END TRY
      BEGIN CATCH
         SET @nErrNo = 273253
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH

      --To avoid PICK-TRF config constrain
      BEGIN TRY
         UPDATE PD WITH (ROWLOCK)
         SET PD.[Status] = '5',
            PD.EditDate = GETDATE(),
            PD.EditWho = SUSER_SNAME()
         FROM dbo.PickDetail PD
         JOIN @tPickDetail tPD ON (PD.PickDetailKey = tPD.PickDetailKey)
      END TRY
      BEGIN CATCH
         SET @nErrNo = 273254
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH
   END -- upd pickdetail

   -- Pack confirm      
   IF @cPackConfirm = 'Y'      
   BEGIN 
      IF @nDebugFlag = 1
         SELECT 'Start Pack confirm', @cPickSlipNo AS PickSlipNo, @cPackConfirm AS PackConfirm     
      -- Pack confirm
      BEGIN TRY      
         UPDATE dbo.PackHeader SET
            Status = '9'
         WHERE PickSlipNo = @cPickSlipNo
            AND Status <> '9'      
      END TRY        
      BEGIN CATCH      
         SET @nErrNo = 273255
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- PackCfm Fail      
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

   END-- pack confirm          
      
   COMMIT TRAN rdt_838PackCfmSP13      
   GOTO Quit      
      
   RollBackTran:
      IF XACT_STATE() = -1
         ROLLBACK TRAN
      ELSE   
         ROLLBACK TRAN rdt_838PackCfmSP13 -- Only rollback change made here      
   Quit:
      IF @nDebugFlag = 1
         SELECT 'Quit', @nErrNo, @cErrMsg      
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started      
         COMMIT TRAN           
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_838PackCfmSP13] TO [NSQL]
GO
