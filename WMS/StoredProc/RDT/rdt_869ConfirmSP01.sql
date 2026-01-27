SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************************/
/* Store procedure: rdt_869ConfirmSP01                                                 */
/* Copyright      : Maersk                                                             */
/* Customer       : USA Levis                                                          */
/*                                                                                     */
/* Purpose: Print GS1 label                                                            */
/*                                                                                     */
/* Modifications log:                                                                  */
/*                                                                                     */
/* Date       Rev    Author   Purposes                                                 */
/* 2025-08-27 1.0.0  NickT    FCR-6730 Created                                         */
/* 2025-11-07 1.1.0  JackC    UWP-43820 Commit tran per update to                      */
/*                            improve deadlock                                         */
/* 2026-01-15 1.2.0  NickT    FCR-7928 Only trigger WSSOAlloUpd for real short PKD     */
/***************************************************************************************/

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
      @cErrMsg1         NVARCHAR( 125),
      @cErrMsg2         NVARCHAR( 125),
      @cErrMsg3         NVARCHAR( 125),
      @nLoopIndex       INT,
      @nRowCount        INT,
      @nTranCount       INT,
      @bSuccess         INT,
      @nQty             INT,
      @cTaskManagerReasonKey NVARCHAR( 10)

   SELECT @cShipRef = C_String1,
         @cStorerKey = StorerKey
   FROM rdt.rdtMobRec (NOLOCK)
   WHERE Mobile = @nMobile

   DECLARE @tShortPickDetail TABLE
   (
      ID                INT IDENTITY(1,1) PRIMARY KEY,
      PickDetailKey     NVARCHAR(10),
      OrderKey          NVARCHAR(10)
   )

   DECLARE @tPD TABLE
   (
      OrderKey NVARCHAR(10),
      OrderLineNumber NVARCHAR(5),
      PickDetailKey NVARCHAR(18)
   )

   SET @nTranCount = @@TRANCOUNT

   /* V1.1
   IF @nTranCount = 0
      BEGIN TRAN
   ELSE
      SAVE TRAN rdt_869ConfirmSP01
   */

   /*--------------------------------------------------------------------------------------------------

                                             PickDetail line

   --------------------------------------------------------------------------------------------------*/
   IF @cOrderKey <> ''
   BEGIN
      INSERT INTO @tPD (OrderKey, OrderLineNumber, PickDetailKey)
      SELECT OrderKey, OrderLineNumber, PickDetailKey
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey
         AND Status = '4'
   END

   IF @cLoadKey <> ''
   BEGIN
      INSERT INTO @tPD (OrderKey, OrderLineNumber, PickDetailKey)
      SELECT DISTINCT PD.OrderKey, PD.OrderLineNumber, PD.PickDetailKey
      FROM dbo.PickDetail PD WITH (NOLOCK)
      INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
      WHERE OD.LoadKey = @cLoadKey
         AND PD.Status = '4'
   END
         
   IF @cWaveKey <> ''
   BEGIN
      IF @cShipRef = ''
      BEGIN
         INSERT INTO @tPD (OrderKey, OrderLineNumber, PickDetailKey)
         SELECT DISTINCT PD.OrderKey, PD.OrderLineNumber, PD.PickDetailKey
         FROM dbo.PickDetail PD WITH (NOLOCK)
         INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
         INNER JOIN dbo.WaveDetail WD  WITH (NOLOCK) ON (OD.OrderKey = WD.OrderKey)
         WHERE WD.WaveKey = @cWaveKey
            AND PD.Status = '4'
      END
      ELSE
      BEGIN
         INSERT INTO @tPD (OrderKey, OrderLineNumber, PickDetailKey)
         SELECT DISTINCT PD.OrderKey, PD.OrderLineNumber, PD.PickDetailKey
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

   INSERT INTO @tShortPickDetail (PickDetailKey, OrderKey)
   SELECT PickDetailKey, OrderKey
   FROM @tPD
   ORDER BY OrderKey, OrderLineNumber, PickDetailKey  

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

      BEGIN TRAN --V.1
      SAVE TRAN rdt_869ConfirmSP01_Pack

      -- Scan out
      IF EXISTS( SELECT 1 FROM dbo.PickingInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND ScanOutDate IS NULL)
      BEGIN
         BEGIN TRY
            UPDATE dbo.PickingInfo SET
               ScanOutDate = GETDATE()
            WHERE PickSlipNo = @cPickSlipNo
         END TRY
         BEGIN CATCH
            SET @nErrNo = 245603
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickingInfo Failed
            GOTO RollBackTranPack
         END CATCH
      END
      
      -- Pack confirm
      IF EXISTS( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND Status <> 9)
      BEGIN
         BEGIN TRY
            UPDATE dbo.PackHeader SET
               Status = 9
            WHERE PickSlipNo = @cPickSlipNo
         END TRY
         BEGIN CATCH
            SET @nErrNo = 245604
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PackHeader Failed
            GOTO RollBackTranPack
         END CATCH
      END

      COMMIT TRAN --V1.1
      FETCH NEXT FROM @curPickSlipNo INTO @cPickSlipNo
   END

   --Picking handling
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

      BEGIN TRAN  --v1.1
      SAVE TRAN rdt_869ConfirmSP01_Pick --v1.1

      -- Unallocate
      BEGIN TRY
         UPDATE dbo.PickDetail WITH(ROWLOCK) SET
            QTY = 0,
            EditDate = GETDATE(),
            EditWho = SUSER_NAME()
         WHERE PickDetailKey = @cPickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 245601
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail Failed
         GOTO RollBackTranPick
      END CATCH

      -- Confirm short pick
      BEGIN TRY
         UPDATE dbo.PickDetail WITH(ROWLOCK) SET
            Status = 0,
            EditDate = GETDATE(),
            EditWho = SUSER_NAME()
         WHERE PickDetailKey = @cPickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 245602
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail Failed
         GOTO RollBackTranPick
      END CATCH

      SELECT @nQty = Qty,
         @cTaskManagerReasonKey = ISNULL(TaskManagerReasonKey, '')
      FROM dbo.PickDetail WITH(NOLOCK)
      WHERE PickDetailKey = @cPickDetailKey
         AND StorerKey = @cStorerkey

      IF NOT EXISTS (SELECT 1 FROM dbo.Transmitlog2 WITH (NOLOCK) 
                     WHERE key1 = @cLoopOrderKey
                        AND Key2 = @cPickDetailKey
                        AND Key3 = @cStorerkey
                        AND TableName = 'WSSOAlloUpd')
         AND @nQty > 0 AND @cTaskManagerReasonKey <> 'SHORT'
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
                  GOTO RollBackTranPick

               IF @bSuccess <> 1 
               BEGIN
                  SET @nErrNo = 245605
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert Transmitlog2 Failed
                  GOTO RollBackTranPick
               END
         END TRY
         BEGIN CATCH
            SET @nErrNo = 245606
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert Transmitlog2 Failed
               GOTO RollBackTranPick
         END CATCH
      END

      COMMIT TRAN
   END-- end while

   GOTO Quit

   RollBackTranPack:
      IF @nTranCount > 0 AND XACT_STATE() <> -1
         ROLLBACK TRAN rdt_869ConfirmSP01_Pack
      ELSE
         ROLLBACK TRAN

      SET @cErrMsg1 = CAST(@nErrNo AS VARCHAR(10))
      SET @cErrMsg2 = @cErrMsg
      SET @cErrMsg3 = 'PSNO: ' + @cPickSlipNo
      EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                           @nErrNo = @nErrNo,
                           @cErrMsg = @cErrMsg,
                           @cLine01 = @cErrMsg1,
                           @cLine02 = @cErrMsg2,
                           @cLine03 = @cErrMsg3,
                           @nDisplayMsg = 0
      GOTO Quit

   RollBackTranPick:
      IF @nTranCount > 0 AND XACT_STATE() <> -1
         ROLLBACK TRAN rdt_869ConfirmSP01_Pick
      ELSE
         ROLLBACK TRAN

      SET @cErrMsg1 = CAST(@nErrNo AS VARCHAR(10))
      SET @cErrMsg2 = @cErrMsg
      SET @cErrMsg3 = 'PickDtlKey: ' + @cPickDetailKey
      EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                     @nErrNo = @nErrNo,
                     @cErrMsg = @cErrMsg,
                     @cLine01 = @cErrMsg1,
                     @cLine02 = @cErrMsg2,
                     @cLine03 = @cErrMsg3,
                     @nDisplayMsg = 0
      GOTO Quit

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
