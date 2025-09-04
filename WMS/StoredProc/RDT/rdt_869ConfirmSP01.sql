SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_869ConfirmSP01                                  */
/* Copyright      : Maersk                                              */
/* Customer       : USA Levis                                           */
/*                                                                      */
/* Purpose: Print GS1 label                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2025-08-27 1.0.0  NickT    FCR-6730 Created                          */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_869ConfirmSP01 (
   @nMobile    INT,
   @nFunc      INT,
   @cStorerKey NVARCHAR( 15),
   @cLangCode  NVARCHAR( 3),
   @cWaveKey   NVARCHAR( 10),
   @cLoadKey   NVARCHAR( 10), 
   @cOrderkey  NVARCHAR( 10),
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cPickDetailKey   NVARCHAR( 10),
      @cPickSlipNo      NVARCHAR( 10),
      @cShipRef         NVARCHAR( 10),
      @cLoopOrderKey    NVARCHAR( 10),
      @nLoopIndex       INT,
      @nRowCount        INT,
      @nTranCount       INT,
      @bSuccess         INT

   SELECT @cShipRef = C_String1,
         @cStorerKey = StorerKey
   FROM rdt.rdtMobRec (NOLOCK)
   WHERE Mobile = @nMobile

   DECLARE @tShortPickDetail TABLE
   (
      ID                INT IDENTITY(1,1) NOT NULL,
      PickDetailKey     NVARCHAR(10),
      OrderKey          NVARCHAR(10)
   )

   SET @nTranCount = @@TRANCOUNT

   IF @nTranCount = 0
      BEGIN TRAN
   ELSE
      SAVE TRAN rdt_869ConfirmSP01

   /*--------------------------------------------------------------------------------------------------

                                             PickDetail line

   --------------------------------------------------------------------------------------------------*/
   IF @cOrderKey <> ''
   BEGIN
      INSERT INTO @tShortPickDetail (PickDetailKey, OrderKey)
      SELECT PickDetailKey, @cOrderKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey
         AND Status = '4'
   END

   IF @cLoadKey <> ''
      INSERT INTO @tShortPickDetail (PickDetailKey, OrderKey)
      SELECT DISTINCT PD.PickDetailKey, PD.OrderKey
      FROM dbo.PickDetail PD WITH (NOLOCK)
      INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
      WHERE OD.LoadKey = @cLoadKey
         AND PD.Status = '4'
         
   IF @cWaveKey <> ''
   BEGIN
      IF @cShipRef = ''
      BEGIN
         INSERT INTO @tShortPickDetail (PickDetailKey, OrderKey)
         SELECT DISTINCT PD.PickDetailKey, PD.OrderKey
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
         INNER JOIN dbo.WaveDetail WD  WITH (NOLOCK) ON (OD.OrderKey = WD.OrderKey)
         WHERE WD.WaveKey = @cWaveKey
            AND PD.Status = '4'
      END
      ELSE
      BEGIN
         INSERT INTO @tShortPickDetail (PickDetailKey, OrderKey)
         SELECT DISTINCT PD.PickDetailKey, PD.OrderKey
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
         INNER JOIN dbo.WaveDetail WD WITH (NOLOCK) ON (OD.OrderKey = WD.OrderKey)
         INNER JOIN dbo.ORDERS ORM WITH (NOLOCK) ON (ORM.OrderKey = OD.OrderKey AND ORM.StorerKey = OD.StorerKey)
         WHERE WD.WaveKey = @cWaveKey
            AND ORM.MBOLKey IS NOT NULL
            AND ORM.MBOLKey = @cShipRef
            AND PD.Status = '4'
      END
   END
         

   /*--------------------------------------------------------------------------------------------------

                                                PickSlip 

   --------------------------------------------------------------------------------------------------*/
   DECLARE @curPickSlipNo CURSOR
   IF @cOrderKey <> ''
      SET @curPickSlipNo = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PickHeaderKey FROM PickHeader WITH (NOLOCK) WHERE OrderKey = @cOrderKey

   IF @cLoadKey <> ''
      SET @curPickSlipNo = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PickHeaderKey FROM PickHeader WITH (NOLOCK) WHERE ExternOrderKey = @cLoadKey

   IF @cWaveKey <> ''
   BEGIN
      IF @cShipRef = ''
      BEGIN
         SET @curPickSlipNo = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT PickHeaderKey 
            FROM dbo.PickHeader PH WITH (NOLOCK)
            INNER JOIN dbo.WaveDetail WD  WITH (NOLOCK) ON (PH.OrderKey = WD.OrderKey)
            WHERE WD.WaveKey = @cWaveKey
      END
      ELSE
      BEGIN
         SET @curPickSlipNo = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PickHeaderKey 
         FROM dbo.PickHeader PH WITH (NOLOCK)
         INNER JOIN dbo.WaveDetail WD WITH (NOLOCK) ON (PH.OrderKey = WD.OrderKey)
         INNER JOIN dbo.ORDERS ORM WITH (NOLOCK) ON (ORM.OrderKey = PH.OrderKey AND ORM.StorerKey = PH.StorerKey)
         WHERE WD.WaveKey = @cWaveKey
            AND ORM.MBOLKey IS NOT NULL
            AND ORM.MBOLKey  = @cShipRef
      END
   END

   OPEN @curPickSlipNo
   FETCH NEXT FROM @curPickSlipNo INTO @cPickSlipNo
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Scan out
      IF EXISTS( SELECT 1 FROM dbo.PickingInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND ScanOutDate IS NULL)
      BEGIN
         UPDATE dbo.PickingInfo SET
            ScanOutDate = GETDATE()
         WHERE PickSlipNo = @cPickSlipNo
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 245603
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickingInfo Failed
            GOTO RollBackTran
         END
      END
      
      -- Pack confirm
      IF EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status <> 9)
      BEGIN
         UPDATE dbo.PackHeader SET
            Status = 9
         WHERE PickSlipNo = @cPickSlipNo
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 245604
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PackHeader Failed
            GOTO RollBackTran
         END
      END
      FETCH NEXT FROM @curPickSlipNo INTO @cPickSlipNo
   END

   SET @nLoopIndex = -1
   WHILE(1=1)
   BEGIN
      SELECT TOP 1
         @cPickDetailKey = PickDetailKey,
         @cLoopOrderKey = OrderKey,
         @nLoopIndex = id
      FROM @tShortPickDetail
      WHERE id > @nLoopIndex
      ORDER BY id

      SELECT @nRowCount = @@ROWCOUNT
      IF @nRowCount = 0
         BREAK

      -- Unallocate
      UPDATE dbo.PickDetail WITH(ROWLOCK) SET
         QTY = 0
      WHERE PickDetailKey = @cPickDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 245601
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail Failed
         GOTO RollBackTran
      END

      -- Confirm short pick
      UPDATE dbo.PickDetail WITH(ROWLOCK) SET
         Status = 0
      WHERE PickDetailKey = @cPickDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 245602
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail Failed
         GOTO RollBackTran
      END

      IF NOT EXISTS (SELECT 1 FROM dbo.Transmitlog2 WITH (NOLOCK) 
                     WHERE key1 = @cLoopOrderKey
                        AND Key2 = @cPickDetailKey
                        AND Key3 = @cStorerkey
                        AND TableName = 'WSSOAlloUpd')
      BEGIN
         BEGIN TRY
            EXECUTE ispGenTransmitLog2
                  @c_TableName      = 'WSSOAlloUpd',
                  @c_Key1           = @cLoopOrderKey,
                  @c_Key2           = @cPickDetailKey,
                  @c_Key3           = @cStorerkey,
                  @c_TransmitBatch  = '',
                  @b_Success        = @bSuccess   OUTPUT,
                  @n_err            = @nErrNo     OUTPUT,
                  @c_errmsg         = @cErrMsg    OUTPUT

               IF @nErrNo <> 0
                  GOTO RollBackTran

               IF @bSuccess <> 1 
               BEGIN
                  SET @nErrNo = 245605
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert Transmitlog2 Failed
                  GOTO RollBackTran
               END
         END TRY
         BEGIN CATCH
            SET @nErrNo = 245606
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert Transmitlog2 Failed
               GOTO RollBackTran
         END CATCH
      END
   END

   COMMIT TRAN rdt_869ConfirmSP01 -- Only commit change made in rdt_869ConfirmSP01
   GOTO Quit

   RollBackTran:
      IF @nTranCount = 0
         ROLLBACK TRAN
      ELSE
         ROLLBACK TRAN rdt_869ConfirmSP01 -- Only rollback change made in rdt_869ConfirmSP01
   Quit:
      -- Commit until the level we started
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN
   Fail:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_869ConfirmSP01 TO NSQL
GO
