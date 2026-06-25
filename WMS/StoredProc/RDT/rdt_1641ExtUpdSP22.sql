
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
      @nStep               INT,
      @nInputKey           INT,
      @nTranCount          INT,
      @nRowCount           INT,
      @cLabelNo            NVARCHAR(20) = ''

   SELECT @nStep = Step,
          @nInputKey = InputKey
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
            -- 1. Check if Scanned value is PACKDETAIL.LabelNo, it was handled by main SP
            IF EXISTS (SELECT 1 FROM dbo.PACKDETAIL WITH(NOLOCK) WHERE LabelNo = @cUCCNo AND StorerKey = @cStorerKey)
            BEGIN
               GOTO Quit
            END

            -- 2. Check if Scanned value is PACKINFO.TrackingNo,
            -- fetch the PACKDETAIL.LabelNo by querying PACKDETAIL.PickSlipNo = PACKINFO.PickSlipNo AND PACKDETAIL.CartonNo = PACKINFO.CartonNo
            IF EXISTS (SELECT 1 FROM dbo.PACKINFO WITH(NOLOCK)
                        WHERE TrackingNo IS NOT NULL
                        AND TrackingNo = @cUCCNo)
            BEGIN
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
                     SET @nErrNo = 271451
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to delete DropIDDetail
                     GOTO ROLLBACK_TRAN
                  END CATCH
               END

               -- Insert new record in DropIDDetail, UCCNo is PackDetail.LabelNo
               SET @cLabelNo = ''
               SELECT TOP 1 @cLabelNo = TRIM(PD.LabelNo)
               FROM dbo.PackDetail PD WITH(NOLOCK)
               INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
               WHERE PI.TrackingNo = @cUCCNo
                  AND PD.StorerKey = @cStorerKey
               ORDER BY PD.LabelNo
               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount > 0 AND @cLabelNo IS NOT NULL AND @cLabelNo <> ''
               BEGIN
                  BEGIN TRY
                     IF NOT EXISTS(SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cLabelNo)
                        INSERT INTO dbo.DropIDDetail (Dropid, ChildID) VALUES (@cDropID, @cLabelNo)
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 271452
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to insert data into DropIDDetail
                     GOTO ROLLBACK_TRAN
                  END CATCH
               END
               ELSE
               BEGIN
                  -- 3. Extract the last 12 characters of the scanned barcode. Check this value for PACKINFO.TrackingNo match.
                  -- fetch the PACKDETAIL.LabelNo by querying PACKDETAIL.PickSlipNo = PACKINFO.PickSlipNo AND PACKDETAIL.CartonNo = PACKINFO.CartonNo
                  IF (LEN(@cUCCNo) >= 12)
                  BEGIN
                     SET @cUCCNo = RIGHT(@cUCCNo, 12)

                     SET @cLabelNo = ''
                     SELECT TOP 1 @cLabelNo = TRIM(PD.LabelNo)
                     FROM dbo.PackDetail PD WITH(NOLOCK)
                     INNER JOIN dbo.PackInfo PI WITH(NOLOCK) ON PD.PickSlipNo = PI.PickSlipNo AND PD.CartonNo = PI.CartonNo
                     WHERE PI.TrackingNo = @cUCCNo
                        AND PD.StorerKey = @cStorerKey
                     ORDER BY PD.LabelNo
                     SELECT @nRowCount = @@ROWCOUNT

                     IF @nRowCount > 0 AND @cLabelNo IS NOT NULL AND @cLabelNo <> ''
                     BEGIN
                        BEGIN TRY
                           IF NOT EXISTS(SELECT 1 FROM dbo.DropIDDetail WITH(NOLOCK) WHERE DropID = @cDropID AND ChildID = @cLabelNo)
                              INSERT INTO dbo.DropIDDetail (Dropid, ChildID) VALUES (@cDropID, @cLabelNo)
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 271453
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Fail to insert data into DropIDDetail
                           GOTO ROLLBACK_TRAN
                        END CATCH
                     END
                     ELSE
                     BEGIN
                        SET @nErrNo = 271454
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid scanned UCC, no matching data is found
                        GOTO ROLLBACK_TRAN
                     END
                  END
               END
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
