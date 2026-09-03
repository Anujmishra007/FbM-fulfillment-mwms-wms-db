SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1856MbolCreate04                                      */
/* Copyright      : Maersk                                                    */
/* Customer       : AEOMX                                                     */
/* DB Name        : MEXWMS                                                    */
/*                                                                            */
/* Purpose: Pallet-based MBOL creation/update for AEOMX MEXWMS.               */
/*          Routes ECOM pallets via DropID+Wave, RTL/WHSLE pallets via        */
/*          LoadPlan. Adds pallet to an existing MBOL when @cMBOLKey <> ''.   */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2026-09-01   1.0  NickT      FCR-15446 CREATED                             */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_1856MbolCreate04](
    @nMobile      INT
   ,@nFunc        INT
   ,@cLangCode    NVARCHAR( 3)
   ,@nStep        INT
   ,@nInputKey    INT
   ,@cFacility    NVARCHAR( 5)
   ,@cStorerKey   NVARCHAR( 15)
   ,@cOrderKey    NVARCHAR( 10)
   ,@cLoadKey     NVARCHAR( 10)
   ,@cRefNo1      NVARCHAR( 20)
   ,@cRefNo2      NVARCHAR( 20)
   ,@cRefNo3      NVARCHAR( 20)
   ,@tMbolCreate  VariableTable READONLY
   ,@cMBOLKey     NVARCHAR( 10)  OUTPUT
   ,@nErrNo       INT            OUTPUT
   ,@cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount           INT
   DECLARE @nSuccess             INT
   DECLARE @nLineSeq             INT = 0
   DECLARE @cWaveType            NVARCHAR( 10) = ''
   DECLARE @cExistingWaveType    NVARCHAR( 10) = ''
   DECLARE @cCarrier             NVARCHAR( 20) = ''
   DECLARE @cExistingCarrier     NVARCHAR( 20) = ''
   DECLARE @cExistingWaveKey     NVARCHAR( 10) = ''
   DECLARE @cOUTOrderKey         NVARCHAR( 10) = ''
   DECLARE @cOUTLoadKey          NVARCHAR( 10) = ''
   DECLARE @cOUTExternOrderKey   NVARCHAR( 50) = ''
   DECLARE @curOrder             CURSOR
   DECLARE @cUserName            NVARCHAR( 18) = ''
   DECLARE @cWaveKey             NVARCHAR( 10) = ''
   DECLARE @cDropIDMBOLKey       NVARCHAR( 10) = ''

   SELECT @cUserName = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN MbolCreation

   -- =========================================================
   -- Section A: Determine wave type of scanned pallet (DropID)
   -- =========================================================
   SELECT TOP 1
      @cWaveType = ISNULL(W.UserDefine03, '')
      ,@cCarrier  = ISNULL(O.InterModalVehicle, '')
      ,@cWaveKey = ISNULL(W.WaveKey, '')
   FROM dbo.PICKDETAIL PD WITH (NOLOCK)
   INNER JOIN dbo.WAVE W WITH (NOLOCK) ON W.WaveKey = PD.WaveKey
   INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
   WHERE PD.DropID   = @cRefNo1
      AND O.StorerKey = @cStorerKey
      AND O.Facility  = @cFacility
   ORDER BY PD.PickDetailKey

   IF @cWaveType = ''
   BEGIN
      SET @nErrNo = 279651
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- DropID not found in PICKDETAIL or no eligible orders (Status=5)
      GOTO RollBackTran
   END

   -- =========================================================
   -- Section A2: Validate ECOM order DropID exclusivity
   -- =========================================================
   IF @cWaveType = 'ECOM'
   BEGIN
      IF EXISTS (
         SELECT 1
         FROM dbo.PICKDETAIL PD1 WITH (NOLOCK)
         INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = PD1.OrderKey
         WHERE PD1.DropID  = @cRefNo1
           AND O.StorerKey = @cStorerKey
           AND O.Facility  = @cFacility
           AND EXISTS (
              SELECT 1
              FROM dbo.PICKDETAIL PD2 WITH (NOLOCK)
              WHERE PD2.OrderKey = PD1.OrderKey
                AND PD2.DropID  <> @cRefNo1
           )
      )
      BEGIN
         SET @nErrNo = 279666
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- ECOM order exists in multiple DropIDs
         GOTO RollBackTran
      END
   END

   IF @cMBOLKey = ''
   BEGIN
      -------------------------------------------------------
      -- Section B: New MBOL creation
      -------------------------------------------------------
      IF @cWaveType = 'ECOM'
      BEGIN
         -- B1: ECOM - collect orders by DropID, write PalletKey
         SET @nSuccess = 1
         EXECUTE dbo.nspg_getkey
              'MBOL'
            , 10
            , @cMBOLKey OUTPUT
            , @nSuccess OUTPUT
            , @nErrNo   OUTPUT
            , @cErrMsg  OUTPUT

         IF @nSuccess <> 1
         BEGIN
            SET @nErrNo = 279652
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Key Gen Fail (B1)
            GOTO RollBackTran
         END

         BEGIN TRY
            INSERT INTO dbo.MBOL
               (MbolKey, Facility, Status, AddWho, AddDate, EditWho, EditDate)
            VALUES
               (@cMBOLKey, @cFacility, '0',
                LEFT('rdt.' + SUSER_SNAME(), 18), GETDATE(),
                LEFT('rdt.' + SUSER_SNAME(), 18), GETDATE())
         END TRY
         BEGIN CATCH
            SET @nErrNo = 279653
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- INSERT into dbo.MBOL failed (B1)
            GOTO RollBackTran
         END CATCH

         SET @curOrder = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT DISTINCT O.OrderKey, O.LoadKey, O.ExternOrderKey
            FROM dbo.PICKDETAIL PD WITH (NOLOCK)
            INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON O.StorerKey = PD.StorerKey AND O.OrderKey = PD.OrderKey
            WHERE PD.DropID   = @cRefNo1
               AND O.StorerKey = @cStorerKey
               AND O.Facility  = @cFacility
               AND O.Status    = '5'
         OPEN @curOrder
         FETCH NEXT FROM @curOrder INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey

         WHILE @@FETCH_STATUS = 0
         BEGIN
            SET @nLineSeq = @nLineSeq + 1
            BEGIN TRY
               INSERT INTO dbo.MBOLDetail
                  (MBOLKey, MBOLLineNumber, OrderKey, LoadKey, ExternOrderKey, PalletKey,
                  AddWho, AddDate, EditWho, EditDate)
                  VALUES
                  (@cMBOLKey, RIGHT(N'00000' + CAST(@nLineSeq AS NVARCHAR(5)), 5), @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey, @cRefNo1,
                  @cUserName, GETDATE(), @cUserName, GETDATE())
            END TRY
            BEGIN CATCH
               SET @nErrNo = 279654
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- INSERT into dbo.MBOLDETAIL failed (B1)
               GOTO RollBackTran
            END CATCH
            FETCH NEXT FROM @curOrder INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey
         END
      END -- B1 ECOM new
      ELSE IF @cWaveType IN ('RTL', 'WHSLE')
      BEGIN
         -- B2: RTL/WHSLE - collect orders by LoadPlan, no PalletKey
         SELECT TOP 1 @cOUTLoadKey = LPD.LoadKey
         FROM dbo.LOADPLANDETAIL LPD WITH (NOLOCK)
         INNER JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey = LPD.OrderKey
         WHERE PD.StorerKey = @cStorerKey
            AND PD.DropID = @cRefNo1
         ORDER BY LPD.LoadKey

         IF ISNULL(@cOUTLoadKey, '') = ''
         BEGIN
            SET @nErrNo = 279655
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No Load Found
            GOTO RollBackTran
         END

         SET @nSuccess = 1
         EXECUTE dbo.nspg_getkey
              'MBOL'
            , 10
            , @cMBOLKey OUTPUT
            , @nSuccess OUTPUT
            , @nErrNo   OUTPUT
            , @cErrMsg  OUTPUT

         IF @nSuccess <> 1
         BEGIN
            SET @nErrNo = 279656
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Key Gen Fail (B2)
            GOTO RollBackTran
         END

         BEGIN TRY
            INSERT INTO dbo.MBOL
               (MbolKey, Facility, Status, AddWho, AddDate, EditWho, EditDate)
            VALUES
               (@cMBOLKey, @cFacility, '0',
                LEFT('rdt.' + SUSER_SNAME(), 18), GETDATE(),
                LEFT('rdt.' + SUSER_SNAME(), 18), GETDATE())
         END TRY
         BEGIN CATCH
            SET @nErrNo = 279657
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- INSERT into dbo.MBOL failed (B2)
            GOTO RollBackTran
         END CATCH

         SET @curOrder = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT DISTINCT LPD.OrderKey
            FROM dbo.LOADPLANDETAIL LPD WITH (NOLOCK)
            INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = LPD.OrderKey
            WHERE LPD.LoadKey = @cOUTLoadKey
               AND O.StorerKey = @cStorerKey
               AND O.Status    = '5'
         OPEN @curOrder
         FETCH NEXT FROM @curOrder INTO @cOUTOrderKey

         WHILE @@FETCH_STATUS = 0
         BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.MBOLDETAIL WITH (NOLOCK)
                           WHERE OrderKey = @cOUTOrderKey)
            BEGIN
               SET @nLineSeq = @nLineSeq + 1
               BEGIN TRY
                  INSERT INTO dbo.MBOLDETAIL
                     (MbolKey, MbolLineNumber, OrderKey, LoadKey,
                     AddWho, AddDate, EditWho, EditDate)
                  VALUES
                     (@cMBOLKey, RIGHT(N'00000' + CAST(@nLineSeq AS NVARCHAR(5)), 5), @cOUTOrderKey, @cOUTLoadKey,
                     @cUserName, GETDATE(), @cUserName, GETDATE())
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 279658
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- INSERT into dbo.MBOLDETAIL failed (B2)
                  GOTO RollBackTran
               END CATCH
            END
            FETCH NEXT FROM @curOrder INTO @cOUTOrderKey
         END
      END -- B2 RTL/WHSLE new
   END -- @cMBOLKey = ''
   ELSE
   BEGIN
      -------------------------------------------------------
      -- Section C: Add pallet to existing MBOL
      -------------------------------------------------------

      -- C1: Get wave type, carrier, and wave key of existing MBOL
      SELECT TOP 1
         @cExistingWaveType = ISNULL(O.Type, '')
         ,@cExistingCarrier  = ISNULL(O.InterModalVehicle, '')
         ,@cExistingWaveKey  = ISNULL(O.UserDefine09, '')
      FROM dbo.MBOLDETAIL MD WITH (NOLOCK)
      JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = MD.OrderKey
      WHERE MD.MbolKey  = @cMBOLKey
      AND   O.StorerKey = @cStorerKey

      -- C2: Validate wave type consistency
      IF @cExistingWaveType = 'ECOM'
      BEGIN
         IF @cWaveType <> 'ECOM'
         BEGIN
            SET @nErrNo = 279659
            SET @cErrMsg = REPLACE( rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP'),'{1}', @cExistingWaveType ) -- Different wave type. MBOL is {1}
            GOTO RollBackTran
         END
         ELSE
         BEGIN
            -- C3: Validate carrier consistency (ECOM)
            IF @cCarrier <> @cExistingCarrier
            BEGIN
               SET @nErrNo = 279660
               SET @cErrMsg = REPLACE( rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP'),'{1}', @cExistingCarrier ) -- Wrong Carrier. MBOL is for {1}
               GOTO RollBackTran
            END
         END
      END
      ELSE IF @cExistingWaveType IN ('RTL', 'WHSLE')
      BEGIN
         IF @cWaveKey <> @cExistingWaveKey
         BEGIN
            SET @nErrNo = 279661
            SET @cErrMsg = REPLACE( rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP'),'{1}', @cExistingWaveKey ) -- Different Wave. MBOL is for {1}
            GOTO RollBackTran
         END

         IF @cCarrier <> @cExistingCarrier
         BEGIN
            SET @nErrNo = 279662
            SET @cErrMsg = REPLACE( rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP'),'{1}', @cExistingCarrier ) -- Wrong Carrier. MBOL is for {1}
            GOTO RollBackTran
         END
         ELSE
         BEGIN
            IF EXISTS(SELECT 1
               FROM dbo.PICKDETAIL PD WITH (NOLOCK)
               INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
               INNER JOIN dbo.MBOLDETAIL MD WITH (NOLOCK) ON MD.OrderKey = O.OrderKey
               WHERE PD.DropID   = @cRefNo1
                  AND O.StorerKey = @cStorerKey
                  AND O.Facility  = @cFacility
                  AND O.Status    = '5'
                  AND MD.MbolKey  <> @cMBOLKey)
            BEGIN
               SET @nErrNo = 279663
               SET @cErrMsg = REPLACE( rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP'),'{1}', @cMBOLKey ) -- Pallet belongs to another MBOL. MBOL is {1}
               GOTO RollBackTran
            END
         END
      END

      -- Get current max line sequence for sequential numbering of new rows
      SELECT @nLineSeq = ISNULL(MAX(TRY_CAST(MbolLineNumber AS INT)), 0)
      FROM dbo.MBOLDETAIL WITH (NOLOCK)
      WHERE MbolKey = @cMBOLKey

      IF @cWaveType = 'ECOM'
      BEGIN
         -- C4a: Add pallet to existing ECOM MBOL; orders already in this MBOL are silently skipped
         SET @curOrder = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT DISTINCT O.OrderKey, O.LoadKey, O.ExternOrderKey
            FROM dbo.PICKDETAIL PD WITH (NOLOCK)
            INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON O.StorerKey = PD.StorerKey AND O.OrderKey = PD.OrderKey
            WHERE PD.DropID   = @cRefNo1
               AND O.StorerKey = @cStorerKey
               AND O.Facility  = @cFacility
               AND O.Status    = '5'
         OPEN @curOrder
         FETCH NEXT FROM @curOrder INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey

         WHILE @@FETCH_STATUS = 0
         BEGIN
            SET @nLineSeq = @nLineSeq + 1
            BEGIN TRY
               INSERT INTO dbo.MBOLDetail
               (MBOLKey, MBOLLineNumber, OrderKey, LoadKey, ExternOrderKey, PalletKey,
               AddWho, AddDate, EditWho, EditDate)
               VALUES
               (@cMBOLKey, RIGHT(N'00000' + CAST(@nLineSeq AS NVARCHAR(5)), 5), @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey, @cRefNo1,
               @cUserName, GETDATE(), @cUserName, GETDATE())
            END TRY
            BEGIN CATCH
               SET @nErrNo = 279664
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- INSERT into dbo.MBOLDETAIL failed (C4a)
               GOTO RollBackTran
            END CATCH
            FETCH NEXT FROM @curOrder INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey
         END
      END -- C4a ECOM add-to-existing
      ELSE IF @cWaveType IN ('RTL', 'WHSLE')
      BEGIN
         SET @curOrder = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT DISTINCT O.OrderKey, O.LoadKey, O.ExternOrderKey
            FROM dbo.PICKDETAIL PD WITH (NOLOCK)
            INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey
            WHERE PD.DropID   = @cRefNo1
               AND O.StorerKey = @cStorerKey
               AND O.Facility  = @cFacility
               AND O.Status    = '5'
         OPEN @curOrder
         FETCH NEXT FROM @curOrder INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey

         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- Silently skip orders already in any MBOL
            IF NOT EXISTS (SELECT 1 FROM dbo.MBOLDETAIL WITH (NOLOCK)
                           WHERE OrderKey = @cOUTOrderKey)
            BEGIN
               SET @nLineSeq = @nLineSeq + 1
               BEGIN TRY
                  INSERT INTO dbo.MBOLDetail
                  (MBOLKey, MBOLLineNumber, OrderKey, LoadKey, ExternOrderKey,
                  AddWho, AddDate, EditWho, EditDate)
                  VALUES
                  (@cMBOLKey, RIGHT(N'00000' + CAST(@nLineSeq AS NVARCHAR(5)), 5), @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey,
                  @cUserName, GETDATE(), @cUserName, GETDATE())
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 279665
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- INSERT into dbo.MBOLDETAIL failed (C4b)
                  GOTO RollBackTran
               END CATCH
            END
            FETCH NEXT FROM @curOrder INTO @cOUTOrderKey, @cOUTLoadKey, @cOUTExternOrderKey
         END
      END -- C4b non-ECOM add-to-existing
   END -- @cMBOLKey <> ''

   COMMIT TRAN MbolCreation
   GOTO Quit

RollBackTran:
   IF XACT_STATE() = -1
      ROLLBACK TRANSACTION
   ELSE IF XACT_STATE() = 1
      ROLLBACK TRAN MbolCreation
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
Quit_SP:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1856MbolCreate04] TO [NSQL]
GO
