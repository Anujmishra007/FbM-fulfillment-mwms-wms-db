
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_1641ExtUpdSP22                                  */
/* Copyright      : Maersk                                              */
/* Customer       : AEOMX - American Eagle                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2026-06-24 1.0.0  NickT      FCR-13319 Created                       */
/* 2026-08-07 1.1.0  NickT      UWP-63642 Fix some issues               */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1641ExtUpdSP22] (
   @nMobile     INT,
   @nFunc       INT,
   @cLangCode   NVARCHAR( 3),
   @cUserName   NVARCHAR( 15),
   @cFacility   NVARCHAR( 5),
   @cStorerKey  NVARCHAR( 15),
   @cDropID     NVARCHAR( 20),
   @cUCCNo      NVARCHAR( 20),
   @nErrNo      INT          OUTPUT,
   @cErrMsg     NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nStep                     INT,
      @nInputKey                 INT,
      @nTranCount                INT,
      @cLoc                      NVARCHAR(10) = '',
      @cLocationType             NVARCHAR(10) = '',
      @cLabelNo                  NVARCHAR(20) = '',
      @cIntermodalVehicle        NVARCHAR(30) = '',
      @cWaveKey                  NVARCHAR(10) = '',
      @cConsigneeKey             NVARCHAR(15) = '',
      @cOption                   NVARCHAR(10) = '',
      @cPOSTPICK                 NVARCHAR(8) = 'POSTPICK',
      @cSTAGEOB                  NVARCHAR(8) = 'STAGEOB'

   DECLARE @tPalletData TABLE 
   (
      RowRef INT IDENTITY(1,1) PRIMARY KEY,
      LabelNo NVARCHAR(20),
      IntermodalVehicle NVARCHAR(30),
      WaveKey NVARCHAR(10),
      ConsigneeKey NVARCHAR(15),
      OrderKey NVARCHAR(20)
   )

   DECLARE @tPickDetail TABLE
   (
      PickDetailKey NVARCHAR(18) NOT NULL PRIMARY KEY
   )

   SELECT @nStep = Step,
          @nInputKey = InputKey,
          @cLoc = V_String5,
          @cOption = I_Field01
   FROM RDT.RDTMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @nTranCount = @@TRANCOUNT

   IF @@TRANCOUNT = 0
      BEGIN TRANSACTION
   ELSE
      SAVE TRANSACTION rdt_1641ExtUpdSP22

   IF @nFunc = 1641
   BEGIN
      IF @nStep = 3 -- UCC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cLocationType= ''

            SELECT @cLocationType = LocationType
            FROM dbo.LOC WITH(NOLOCK)
            WHERE Loc = @cLoc
               AND Facility = @cFacility
            SET @cLocationType = ISNULL(@cLocationType, '')

            -- PostPick
            IF @cLocationType = @cPOSTPICK
            BEGIN
               IF EXISTS (SELECT 1 FROM dbo.PickDetail WITH(NOLOCK) WHERE DropID = @cUCCNo AND StorerKey = @cStorerKey) 
               BEGIN
                  DELETE FROM @tPalletData

                  INSERT INTO @tPalletData (LabelNo, IntermodalVehicle, WaveKey, ConsigneeKey, OrderKey)
                  SELECT DISTINCT
                     '',
                     OD.IntermodalVehicle,
                     PD.WaveKey,
                     OD.ConsigneeKey,
                     OD.OrderKey
                  FROM dbo.PickDetail PD WITH(NOLOCK)
                  INNER JOIN dbo.ORDERS OD WITH(NOLOCK) ON PD.OrderKey = OD.OrderKey AND PD.StorerKey = OD.StorerKey
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.DropID = @cUCCNo
                  ORDER BY OD.OrderKey

                  DELETE FROM @tPickDetail
                  INSERT INTO @tPickDetail (PickDetailKey)
                  SELECT
                     PD.PickDetailKey
                  FROM dbo.PickDetail PD WITH(NOLOCK)
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.DropID = @cUCCNo
                  
                  SET @cIntermodalVehicle = ''
                  SET @cWaveKey = ''
                  SET @cConsigneeKey = ''
                  SELECT TOP 1 
                     @cIntermodalVehicle = PD.IntermodalVehicle, 
                     @cWaveKey = PD.WaveKey,
                     @cConsigneeKey = PD.ConsigneeKey
                  FROM @tPalletData PD
                  ORDER BY PD.RowRef

                  IF EXISTS(SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cUCCNo)
                  BEGIN
                     BEGIN TRY
                        UPDATE dbo.DropIDDetail WITH(ROWLOCK) SET 
                           UserDefine01 = @cIntermodalVehicle, 
                           UserDefine02 = @cWaveKey, 
                           UserDefine03 = @cConsigneeKey
                        WHERE DropID = @cDropID
                           AND ChildID = @cUCCNo
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 271451
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Fail to update DropIDDetail
                        GOTO ROLLBACK_TRAN
                     END CATCH
                  END
                  ELSE
                  BEGIN
                     BEGIN TRY
                        IF NOT EXISTS(SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cUCCNo)
                           INSERT INTO dbo.DropIDDetail (Dropid, ChildID, UserDefine01, UserDefine02, UserDefine03) 
                           VALUES (@cDropID, @cUCCNo, @cIntermodalVehicle, @cWaveKey, @cConsigneeKey)
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 271452
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to insert data into DropIDDetail
                        GOTO ROLLBACK_TRAN
                     END CATCH
                  END

                  BEGIN TRY
                     UPDATE O WITH(ROWLOCK) 
                     SET
                        UserDefine03 = @cDropID,
                        EditDate = GETDATE(),
                        EditWho = @cUserName
                     FROM dbo.ORDERS O WITH(ROWLOCK)
                     INNER JOIN @tPalletData PD ON O.OrderKey = PD.OrderKey AND O.StorerKey = @cStorerKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 271459
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to update ORDERS with DropID
                     GOTO ROLLBACK_TRAN
                  END CATCH

                  GOTO Quit
               END
            END
            -- StageOB
            ELSE IF @cLocationType = @cSTAGEOB
            BEGIN
               -- 1. If scanned value is PACKDETAIL.LabelNo, store it in DropIDDetail (incl. WaveKey/Consignee/Vehicle)
               IF EXISTS (SELECT 1 FROM dbo.PACKDETAIL WITH(NOLOCK) WHERE LabelNo = @cUCCNo AND StorerKey = @cStorerKey) 
               BEGIN
                  DELETE FROM @tPalletData

                  INSERT INTO @tPalletData (LabelNo, IntermodalVehicle, WaveKey, ConsigneeKey, OrderKey)
                  SELECT DISTINCT
                     '',
                     OD.IntermodalVehicle,
                     PD.WaveKey,
                     OD.ConsigneeKey,
                     OD.OrderKey
                  FROM dbo.PickDetail PD WITH(NOLOCK)
                  INNER JOIN dbo.ORDERS OD WITH(NOLOCK) ON PD.OrderKey = OD.OrderKey AND PD.StorerKey = OD.StorerKey
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.DropID = @cUCCNo
                  ORDER BY OD.OrderKey

                  DELETE FROM @tPickDetail
                  INSERT INTO @tPickDetail (PickDetailKey)
                  SELECT
                     PD.PickDetailKey
                  FROM dbo.PickDetail PD WITH(NOLOCK)
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.DropID = @cUCCNo

                  SET @cIntermodalVehicle = ''
                  SET @cWaveKey = ''
                  SET @cConsigneeKey = ''
                  SELECT TOP 1 
                     @cIntermodalVehicle = PD.IntermodalVehicle, 
                     @cWaveKey = PD.WaveKey,
                     @cConsigneeKey = PD.ConsigneeKey
                  FROM @tPalletData PD
                  ORDER BY PD.RowRef

                  IF EXISTS (SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cUCCNo)
                  BEGIN
                     BEGIN TRY
                        UPDATE dbo.DropIDDetail WITH(ROWLOCK) SET
                           UserDefine01 = @cIntermodalVehicle,
                           UserDefine02 = @cWaveKey,
                           UserDefine03 = @cConsigneeKey
                        WHERE DropID = @cDropID
                           AND ChildID = @cUCCNo
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 271453
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Fail to update DropIDDetail
                        GOTO ROLLBACK_TRAN
                     END CATCH
                  END
                  ELSE
                  BEGIN
                     BEGIN TRY
                        IF NOT EXISTS(SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cUCCNo)
                           INSERT INTO dbo.DropIDDetail (Dropid, ChildID, UserDefine01, UserDefine02, UserDefine03) 
                           VALUES (@cDropID, @cUCCNo, @cIntermodalVehicle, @cWaveKey, @cConsigneeKey)
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 271454
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to insert data into DropIDDetail
                        GOTO ROLLBACK_TRAN
                     END CATCH
                  END

                  BEGIN TRY
                     UPDATE O WITH(ROWLOCK) 
                     SET
                        UserDefine03 = @cDropID,
                        EditDate = GETDATE(),
                        EditWho = @cUserName
                     FROM dbo.ORDERS O WITH(ROWLOCK)
                     INNER JOIN @tPalletData PD ON O.OrderKey = PD.OrderKey AND O.StorerKey = @cStorerKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 271460
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to update ORDERS with DropID
                     GOTO ROLLBACK_TRAN
                  END CATCH

                  BEGIN TRY
                     UPDATE PD WITH(ROWLOCK) 
                     SET
                        DropID = @cDropID,
                        EditDate = GETDATE(),
                        EditWho = @cUserName
                     FROM dbo.PickDetail PD WITH(ROWLOCK)
                     INNER JOIN @tPickDetail TPD ON PD.PickDetailKey = TPD.PickDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 271465
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Fail to update pickdetail DropID
                     GOTO ROLLBACK_TRAN
                  END CATCH
                  GOTO Quit
               END

               -- 2. Check if Scanned value is PACKINFO.TrackingNo,
               -- fetch the PACKDETAIL.LabelNo by querying PACKDETAIL.PickSlipNo = PACKINFO.PickSlipNo AND PACKDETAIL.CartonNo = PACKINFO.CartonNo
               IF EXISTS (SELECT 1 FROM dbo.PACKINFO WITH(NOLOCK)
                           WHERE TrackingNo IS NOT NULL
                           AND TrackingNo = @cUCCNo)
               BEGIN
                  DELETE FROM @tPalletData

                  INSERT INTO @tPalletData (LabelNo, IntermodalVehicle, WaveKey, ConsigneeKey, OrderKey)
                  SELECT DISTINCT
                     PD.LabelNo,
                     OD.IntermodalVehicle,
                     PKD.WaveKey,
                     OD.ConsigneeKey,
                     OD.OrderKey
                  FROM dbo.PackDetail PD WITH(NOLOCK)
                  INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
                  INNER JOIN dbo.PackHeader PH WITH(NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo AND PD.StorerKey = PH.StorerKey
                  INNER JOIN dbo.ORDERS OD WITH(NOLOCK) ON PH.OrderKey = OD.OrderKey AND PH.StorerKey = OD.StorerKey
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PKD.OrderKey = OD.OrderKey AND PKD.StorerKey = OD.StorerKey AND PD.LabelNo = PKD.DropID
                  WHERE PI.TrackingNo = @cUCCNo
                     AND PD.StorerKey = @cStorerKey
                  ORDER BY PD.LabelNo

                  DELETE FROM @tPickDetail
                  INSERT INTO @tPickDetail (PickDetailKey)
                  SELECT DISTINCT
                     PKD.PickDetailKey
                  FROM dbo.PackDetail PD WITH(NOLOCK)
                  INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
                  INNER JOIN dbo.PackHeader PH WITH(NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo AND PD.StorerKey = PH.StorerKey
                  INNER JOIN dbo.ORDERS OD WITH(NOLOCK) ON PH.OrderKey = OD.OrderKey AND PH.StorerKey = OD.StorerKey
                  INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PKD.OrderKey = OD.OrderKey AND PKD.StorerKey = OD.StorerKey AND PD.LabelNo = PKD.DropID
                  WHERE PI.TrackingNo = @cUCCNo
                     AND PD.StorerKey = @cStorerKey
                  
                  SET @cLabelNo = ''
                  SET @cIntermodalVehicle = ''
                  SET @cWaveKey = ''
                  SET @cConsigneeKey = ''
                  SELECT TOP 1 
                     @cLabelNo = PD.LabelNo, 
                     @cIntermodalVehicle = PD.IntermodalVehicle, 
                     @cWaveKey = PD.WaveKey,
                     @cConsigneeKey = PD.ConsigneeKey
                  FROM @tPalletData PD
                  ORDER BY PD.RowRef

                  -- Delete old record in DropIDDetail if exists
                  IF EXISTS(SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cUCCNo AND AddWho = @cUserName)
                  BEGIN
                     BEGIN TRY
                        DELETE FROM dbo.DropIDDetail
                        WHERE DropID = @cDropID
                           AND ChildID = @cUCCNo
                           AND AddWho = @cUserName
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 271455
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to delete DropIDDetail
                        GOTO ROLLBACK_TRAN
                     END CATCH
                  END

                  -- Insert new record in DropIDDetail, UCCNo is PackDetail.LabelNo
                  IF @cLabelNo IS NOT NULL AND @cLabelNo <> ''
                  BEGIN
                     BEGIN TRY
                        IF NOT EXISTS(SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cLabelNo)
                           INSERT INTO dbo.DropIDDetail (Dropid, ChildID, UserDefine01, UserDefine02, UserDefine03) 
                           VALUES (@cDropID, @cLabelNo, @cIntermodalVehicle, @cWaveKey, @cConsigneeKey)
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 271456
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to insert data into DropIDDetail
                        GOTO ROLLBACK_TRAN
                     END CATCH
                  END

                  BEGIN TRY
                     UPDATE O WITH(ROWLOCK) 
                     SET
                        UserDefine03 = @cDropID,
                        EditDate = GETDATE(),
                        EditWho = @cUserName
                     FROM dbo.ORDERS O WITH(ROWLOCK)
                     INNER JOIN @tPalletData PD ON O.OrderKey = PD.OrderKey AND O.StorerKey = @cStorerKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 271461
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to update ORDERS with DropID
                     GOTO ROLLBACK_TRAN
                  END CATCH

                  BEGIN TRY
                     UPDATE PD WITH(ROWLOCK) 
                     SET
                        DropID = @cDropID,
                        EditDate = GETDATE(),
                        EditWho = @cUserName
                     FROM dbo.PickDetail PD WITH(ROWLOCK)
                     INNER JOIN @tPickDetail TPD ON PD.PickDetailKey = TPD.PickDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 271466
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Fail to update pickdetail DropID
                     GOTO ROLLBACK_TRAN
                  END CATCH
                  GOTO Quit
               END

               -- 3. Extract the last 12 characters of the scanned barcode. Check this value for PACKINFO.TrackingNo match.
               -- fetch the PACKDETAIL.LabelNo by querying PACKDETAIL.PickSlipNo = PACKINFO.PickSlipNo AND PACKDETAIL.CartonNo = PACKINFO.CartonNo
               BEGIN
                  IF (LEN(@cUCCNo) >= 12)
                  BEGIN
                     DECLARE @cUCCNo12 NVARCHAR(20)
                     SET @cUCCNo12 = RIGHT(@cUCCNo, 12)

                     DELETE FROM @tPalletData

                     INSERT INTO @tPalletData (LabelNo, IntermodalVehicle, WaveKey, ConsigneeKey, OrderKey)
                     SELECT DISTINCT
                        PD.LabelNo,
                        OD.IntermodalVehicle,
                        PKD.WaveKey,
                        OD.ConsigneeKey,
                        OD.OrderKey
                     FROM dbo.PackDetail PD WITH(NOLOCK)
                     INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
                     INNER JOIN dbo.PackHeader PH WITH(NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo AND PD.StorerKey = PH.StorerKey
                     INNER JOIN dbo.ORDERS OD WITH(NOLOCK) ON PH.OrderKey = OD.OrderKey AND PH.StorerKey = OD.StorerKey
                     INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PKD.OrderKey = OD.OrderKey AND PKD.StorerKey = OD.StorerKey AND PD.LabelNo = PKD.DropID
                     WHERE PI.TrackingNo = @cUCCNo12
                        AND PD.StorerKey = @cStorerKey
                     ORDER BY PD.LabelNo

                     DELETE FROM @tPickDetail
                     INSERT INTO @tPickDetail (PickDetailKey)
                     SELECT DISTINCT
                        PKD.PickDetailKey
                     FROM dbo.PackDetail PD WITH(NOLOCK)
                     INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
                     INNER JOIN dbo.PackHeader PH WITH(NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo AND PD.StorerKey = PH.StorerKey
                     INNER JOIN dbo.ORDERS OD WITH(NOLOCK) ON PH.OrderKey = OD.OrderKey AND PH.StorerKey = OD.StorerKey
                     INNER JOIN dbo.PickDetail PKD WITH(NOLOCK) ON PKD.OrderKey = OD.OrderKey AND PKD.StorerKey = OD.StorerKey AND PD.LabelNo = PKD.DropID
                     WHERE PI.TrackingNo = @cUCCNo12
                        AND PD.StorerKey = @cStorerKey

                     SET @cLabelNo = ''
                     SET @cIntermodalVehicle = ''
                     SET @cWaveKey = ''
                     SET @cConsigneeKey = ''
                     SELECT TOP 1 
                        @cLabelNo = PD.LabelNo, 
                        @cIntermodalVehicle = PD.IntermodalVehicle, 
                        @cWaveKey = PD.WaveKey,
                        @cConsigneeKey = PD.ConsigneeKey
                     FROM @tPalletData PD
                     ORDER BY PD.RowRef

                     -- Delete old record in DropIDDetail if exists
                     IF EXISTS(SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cUCCNo AND AddWho = @cUserName)
                     BEGIN
                        BEGIN TRY
                           DELETE FROM dbo.DropIDDetail
                           WHERE DropID = @cDropID
                              AND ChildID = @cUCCNo
                              AND AddWho = @cUserName
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 271455
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to delete DropIDDetail
                           GOTO ROLLBACK_TRAN
                        END CATCH
                     END

                     IF @cLabelNo IS NOT NULL AND @cLabelNo <> ''
                     BEGIN
                        BEGIN TRY
                           IF NOT EXISTS(SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cLabelNo)
                              INSERT INTO dbo.DropIDDetail (Dropid, ChildID, UserDefine01, UserDefine02, UserDefine03) 
                              VALUES (@cDropID, @cLabelNo, @cIntermodalVehicle, @cWaveKey, @cConsigneeKey)
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 271457
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to insert data into DropIDDetail
                           GOTO ROLLBACK_TRAN
                        END CATCH
                     END
                     ELSE
                     BEGIN
                        SET @nErrNo = 271458
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid scanned UCC, no matching data is found
                        GOTO ROLLBACK_TRAN
                     END

                     BEGIN TRY
                        UPDATE O WITH(ROWLOCK) 
                        SET
                           UserDefine03 = @cDropID,
                           EditDate = GETDATE(),
                           EditWho = @cUserName
                        FROM dbo.ORDERS O WITH(ROWLOCK)
                        INNER JOIN @tPalletData PD ON O.OrderKey = PD.OrderKey AND O.StorerKey = @cStorerKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 271462
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to update ORDERS with DropID
                        GOTO ROLLBACK_TRAN
                     END CATCH

                     BEGIN TRY
                        UPDATE PD WITH(ROWLOCK) 
                        SET
                           DropID = @cDropID,
                           EditDate = GETDATE(),
                           EditWho = @cUserName
                        FROM dbo.PickDetail PD WITH(ROWLOCK)
                        INNER JOIN @tPickDetail TPD ON PD.PickDetailKey = TPD.PickDetailKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 271467
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Fail to update pickdetail DropID
                        GOTO ROLLBACK_TRAN
                     END CATCH
                  END
               END
            END
         END
      END

      ELSE IF @nStep = 4 -- Close Pallet
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cOption = '1' -- Option 1: Close Pallet
            BEGIN
               BEGIN TRY
                  UPDATE dbo.DropID WITH(ROWLOCK) 
                  SET 
                     Status = '9',
                     EditDate = GETDATE(),
                     EditWho = @cUserName
                  WHERE DropID = @cDropID
                     AND Status <> '9'
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 271463
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Fail to close DropID
                  GOTO ROLLBACK_TRAN
               END CATCH
            END
         END
      END
   END

   GOTO Quit

   ROLLBACK_TRAN:
   IF @@TRANCOUNT > 0
   BEGIN
      IF @nTranCount = 0
      BEGIN
         ROLLBACK TRANSACTION
      END
      ELSE
      BEGIN
         IF XACT_STATE() <> -1
            ROLLBACK TRANSACTION rdt_1641ExtUpdSP22
         ELSE
            ROLLBACK TRANSACTION
      END
   END
   Quit:
   IF @@TRANCOUNT > @nTranCount
   BEGIN
      IF XACT_STATE() = 1
         COMMIT TRANSACTION
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1641ExtUpdSP22 TO NSQL
GO
