SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*****************************************************************************/
/* Stored Procedure: rdt_838ExtUpd37                                         */
/* Copyright       : MAERSK                                                  */
/*                                                                           */
/*                                                                           */
/* Customer: COLUMBIA SPORTSWEAR                                             */
/*                                                                           */
/* Modification Log:                                                         */
/* Date         Author   Version  Description                                */
/* 08-Jul-2026  SSR259   1.0      FCR-14271 - Initial version                */
/*****************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_838ExtUpd37]
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
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success          INT
   DECLARE @c_LabelNo          NVARCHAR(20)
   DECLARE @c_NewLabelNo       NVARCHAR(20)
   DECLARE @n_Err              INT
   DECLARE @c_ErrMsg           NVARCHAR(255)
   DECLARE @c_UserName         NVARCHAR(18)
   DECLARE @n_NewCartonNo      INT
   DECLARE @n_OrigExpQty       INT
   DECLARE @c_OrigSKU          NVARCHAR(20)
   DECLARE @c_OrigLabelLine    NVARCHAR(5)
   DECLARE @c_OrigRefNo        NVARCHAR(20)
   DECLARE @c_OrigCartonStatus NVARCHAR(10)
   DECLARE @n_OrigCartonNo     INT
   DECLARE @c_OrigOrderKey     NVARCHAR(10)
   DECLARE @c_OrigLOT          NVARCHAR(10)
   DECLARE @n_TranCount        INT
   DECLARE @n_CartonLength     DECIMAL(18,5)
   DECLARE @n_CartonWidth      DECIMAL(18,5)
   DECLARE @n_CartonHeight     DECIMAL(18,5)
   DECLARE @n_CartonWeight     DECIMAL(18,5)

   SET @nErrNo    = 0
   SET @cErrMsg   = ''
   SET @c_UserName = SUSER_SNAME()

   IF @nFunc = 838
   BEGIN
      -- STEP 2 — Scn 4651 (Statistic screen), Option=1 only                 
      IF @nStep = 2
      BEGIN
         IF @nInputKey = 1 
         BEGIN
            IF @cOption = '1'
            BEGIN
               IF NOT EXISTS (
                  SELECT 1 FROM dbo.PACKDETAIL WITH (NOLOCK)
                  WHERE LabelNo = @cFromDropID AND StorerKey = @cStorerKey
               )
               BEGIN
                  SET @nErrNo  = 273651
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               SELECT TOP 1
                  @n_OrigCartonNo  = CartonNo,
                  @c_OrigSKU       = SKU,
                  @c_OrigLabelLine = LabelLine,
                  @c_OrigRefNo     = RefNo
               FROM dbo.PACKDETAIL WITH (NOLOCK)
               WHERE LabelNo = @cFromDropID AND StorerKey = @cStorerKey

               IF NOT EXISTS (
                  SELECT 1 FROM dbo.PACKINFO WITH (NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @n_OrigCartonNo
               )
               BEGIN
                  SET @nErrNo  = 273653
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               SET @n_TranCount = @@TRANCOUNT
               IF @n_TranCount = 0
                  BEGIN TRANSACTION
               ELSE
                  SAVE TRANSACTION rdt_838ExtUpd37_Step2

               SELECT @n_NewCartonNo = ISNULL(MAX(CartonNo), 0) + 1
               FROM dbo.PACKDETAIL WITH (UPDLOCK)
               WHERE PickSlipNo = @cPickSlipNo

               SET @c_NewLabelNo = ''
               EXEC dbo.msp_GLBL02
                  @c_PickSlipNo = @cPickSlipNo,
                  @n_CartonNo   = @n_NewCartonNo,
                  @c_LabelNo    = @c_NewLabelNo OUTPUT

               -- GS1 label format: SUSR5 + keycount (may be alphanumeric)
               IF ISNULL(@c_NewLabelNo, '') = ''
               BEGIN
                  SET @nErrNo  = 273654
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran_Step2
               END

               BEGIN TRY
                  INSERT INTO dbo.PACKDETAIL (
                     PickSlipNo,       CartonNo,        LabelNo,
                     LabelLine,        StorerKey,       SKU,
                     Qty,              ExpQty,          RefNo,
                     DropID,           AddWho,          AddDate,
                     EditWho,          EditDate
                  )
                  VALUES (
                     @cPickSlipNo,     @n_NewCartonNo,  @c_NewLabelNo,
                     @c_OrigLabelLine, @cStorerKey,     @c_OrigSKU,
                     0,                0,               @c_OrigRefNo,
                     @c_NewLabelNo,    @c_UserName,     GETDATE(),
                     @c_UserName,      GETDATE()
                  )
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273655
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran_Step2
               END CATCH

               IF @n_TranCount = 0
                  COMMIT TRANSACTION
               GOTO Quit

               RollBackTran_Step2:
                  IF XACT_STATE() = -1
                  BEGIN
                     IF @n_TranCount = 0 ROLLBACK TRANSACTION
                  END
                  ELSE IF XACT_STATE() = 1
                  BEGIN
                     IF @n_TranCount = 0
                        ROLLBACK TRANSACTION
                     ELSE
                        ROLLBACK TRANSACTION rdt_838ExtUpd37_Step2
                  END
               GOTO Quit

            END -- Step 2, Option=1
         END
      END -- Step 2

      -- STEP 4 — Scn 4653 (Pack info screen)                                
      IF @nStep = 4
      BEGIN
         IF @nInputKey = 1
         BEGIN

            IF @cOption = '1'
            BEGIN

               -- Locate placeholder created at Step 2 (Qty=0, ExpQty=0)
               SELECT TOP 1
                  @c_NewLabelNo  = LabelNo,
                  @n_NewCartonNo = CartonNo
               FROM dbo.PACKDETAIL WITH (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
                 AND LabelNo   <> @cFromDropID
                 AND Qty        = 0
                 AND ExpQty     = 0
               ORDER BY CartonNo DESC

               IF ISNULL(@c_NewLabelNo, '') = ''
               BEGIN
                  SET @nErrNo  = 273654
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               SELECT TOP 1
                  @n_OrigExpQty    = ExpQty,
                  @c_OrigSKU       = SKU,
                  @c_OrigLabelLine = LabelLine,
                  @c_OrigRefNo     = RefNo,
                  @n_OrigCartonNo  = CartonNo
               FROM dbo.PACKDETAIL WITH (NOLOCK)
               WHERE LabelNo = @cFromDropID AND StorerKey = @cStorerKey

               IF @n_OrigExpQty < @nQTY
               BEGIN
                  SET @nErrNo  = 273652
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               SELECT TOP 1
                  @c_OrigCartonStatus = CartonStatus
               FROM dbo.PACKINFO WITH (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @n_OrigCartonNo

               SELECT TOP 1
                  @c_OrigOrderKey = OrderKey,
                  @c_OrigLOT      = LOT
               FROM dbo.PICKDETAIL WITH (NOLOCK)
               WHERE DropID = @cFromDropID AND StorerKey = @cStorerKey

               SELECT TOP 1
                  @n_CartonLength = ISNULL(cz.CartonLength, 0),
                  @n_CartonWidth  = ISNULL(cz.CartonWidth,  0),
                  @n_CartonHeight = ISNULL(cz.CartonHeight, 0),
                  @n_CartonWeight = ISNULL(cz.CartonWeight, 0)
               FROM dbo.PackHeader ph WITH (NOLOCK)
               JOIN dbo.Cartonization cz WITH (NOLOCK)
                  ON cz.CartonizationGroup = ph.StorerKey
                 AND cz.CartonType         = @cCartonType
               WHERE ph.PickSlipNo = @cPickSlipNo

               SET @n_TranCount = @@TRANCOUNT
               IF @n_TranCount = 0
                  BEGIN TRANSACTION
               ELSE
                  SAVE TRANSACTION rdt_838ExtUpd37_Step4

               BEGIN TRY
                  -- Update new PACKDETAIL: Qty=0, ExpQty=@nQTY
                  UPDATE dbo.PACKDETAIL WITH (ROWLOCK)
                  SET Qty      = 0,
                      ExpQty   = @nQTY,
                      DropID   = @c_NewLabelNo,
                      EditWho  = @c_UserName,
                      EditDate = GETDATE()
                  WHERE LabelNo = @c_NewLabelNo AND StorerKey = @cStorerKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273655
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran_Step4
               END CATCH

               BEGIN TRY
                  -- Reduce ExpQty on original PACKDETAIL
                  UPDATE dbo.PACKDETAIL WITH (ROWLOCK)
                  SET ExpQty   = ExpQty - @nQTY,
                      EditWho  = @c_UserName,
                      EditDate = GETDATE()
                  WHERE LabelNo = @cFromDropID AND StorerKey = @cStorerKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273656
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran_Step4
               END CATCH

               BEGIN TRY
                  -- Create new PACKINFO; copy CartonStatus from original
                  INSERT INTO dbo.PACKINFO (
                     PickSlipNo,      CartonNo,        CartonType,
                     Qty,             [Cube],          [Weight],
                     [Length],        [Width],         [Height],
                     CartonStatus,    AddWho,          AddDate,
                     EditWho,         EditDate
                  )
                  VALUES (
                     @cPickSlipNo,    @n_NewCartonNo,  @cCartonType,
                     0,               0,               @n_CartonWeight,
                     @n_CartonLength, @n_CartonWidth,  @n_CartonHeight,
                     @c_OrigCartonStatus, @c_UserName, GETDATE(),
                     @c_UserName,     GETDATE()
                  )
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273657
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran_Step4
               END CATCH

               BEGIN TRY
                  -- Insert new PICKDETAIL for the split carton
                  INSERT INTO dbo.PICKDETAIL (
                     StorerKey,    OrderKey,        SKU,
                     LOT,          Qty,             DropID,
                     CaseID,       CartonType,      AddWho,
                     AddDate,      EditWho,         EditDate
                  )
                  VALUES (
                     @cStorerKey,  @c_OrigOrderKey, @c_OrigSKU,
                     @c_OrigLOT,   @nQTY,           @c_NewLabelNo,
                     @c_NewLabelNo,@cCartonType,    @c_UserName,
                     GETDATE(),    @c_UserName,     GETDATE()
                  )
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273658
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran_Step4
               END CATCH

               BEGIN TRY
                  -- Reduce Qty on original PICKDETAIL
                  UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
                  SET Qty      = Qty - @nQTY,
                      EditWho  = @c_UserName,
                      EditDate = GETDATE()
                  WHERE DropID = @cFromDropID AND StorerKey = @cStorerKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273659
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO RollBackTran_Step4
               END CATCH

               BEGIN TRY
                  -- Delete original PACKDETAIL + PACKINFO if ExpQty=0
                  IF EXISTS (
                     SELECT 1 FROM dbo.PACKDETAIL WITH (NOLOCK)
                     WHERE LabelNo   = @cFromDropID
                       AND StorerKey = @cStorerKey
                       AND ExpQty    = 0
                       AND Qty       = 0
                  )
                  BEGIN
                     DELETE FROM dbo.PACKDETAIL
                     WHERE LabelNo   = @cFromDropID
                       AND StorerKey = @cStorerKey
                       AND ExpQty    = 0
                       AND Qty       = 0

                     DELETE pi
                     FROM dbo.PACKINFO pi
                     WHERE pi.PickSlipNo = @cPickSlipNo
                       AND NOT EXISTS (
                          SELECT 1 FROM dbo.PACKDETAIL pd WITH (NOLOCK)
                          WHERE pd.PickSlipNo = pi.PickSlipNo
                            AND pd.CartonNo   = pi.CartonNo
                       )
                  END

                  -- Delete original PICKDETAIL if Qty=0
                  DELETE FROM dbo.PICKDETAIL
                  WHERE DropID    = @cFromDropID
                    AND StorerKey = @cStorerKey
                    AND Qty       = 0
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 0 -- Non-critical cleanup
               END CATCH

               IF @n_TranCount = 0
                  COMMIT TRANSACTION
               GOTO Quit

               RollBackTran_Step4:
                  IF XACT_STATE() = -1
                  BEGIN
                     IF @n_TranCount = 0 ROLLBACK TRANSACTION
                  END
                  ELSE IF XACT_STATE() = 1
                  BEGIN
                     IF @n_TranCount = 0
                        ROLLBACK TRANSACTION
                     ELSE
                        ROLLBACK TRANSACTION rdt_838ExtUpd37_Step4
                  END
               GOTO Quit

            END -- Step 4, Option=1
            ELSE
            BEGIN
               SET @b_success = 1
               SET @c_LabelNo = ''

               EXEC isp_GenUCCLabelNo_Std
                  @cPickslipNo = @cPickSlipNo,
                  @nCartonNo   = 0,
                  @cLabelNo    = @c_LabelNo   OUTPUT,
                  @b_success   = @b_success   OUTPUT,
                  @n_err       = @n_Err       OUTPUT,
                  @c_errmsg    = @c_ErrMsg    OUTPUT

               IF @b_Success = 0
               BEGIN
                  SET @nErrNo  = 273660
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               BEGIN TRY
                  UPDATE dbo.PACKDETAIL WITH (ROWLOCK)
                  SET LabelNo  = @c_LabelNo,
                      DropID   = @c_LabelNo,
                      Qty      = 0
                  WHERE PickSlipNo = @cPickSlipNo
                    AND CartonNo   = @nCartonNo
                    AND StorerKey  = @cStorerKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273661
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END CATCH

               BEGIN TRY
                  UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
                  SET DropID     = @c_LabelNo,
                      CaseID     = @c_LabelNo,
                      CartonType = @cCartonType,
                      EditDate   = GETDATE(),
                      EditWho    = SUSER_SNAME(),
                      TrafficCop = NULL
                  WHERE DropID = @cFromDropID
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273662
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END CATCH

               BEGIN TRY
                  UPDATE pi
                  SET pi.Length   = CASE WHEN ISNULL(cz.CartonLength, 0) = 0 THEN pi.Length ELSE cz.CartonLength END,
                      pi.Width    = CASE WHEN ISNULL(cz.CartonWidth,  0) = 0 THEN pi.Width  ELSE cz.CartonWidth  END,
                      pi.Height   = CASE WHEN ISNULL(cz.CartonHeight, 0) = 0 THEN pi.Height ELSE cz.CartonHeight END,
                      pi.EditDate = GETDATE(),
                      pi.EditWho  = SUSER_SNAME(),
                      pi.Qty      = 0
                  FROM dbo.PACKINFO pi WITH (ROWLOCK)
                  JOIN dbo.PackHeader ph WITH (NOLOCK)
                     ON ph.PickSlipNo = pi.PickSlipNo
                  JOIN dbo.Cartonization cz WITH (NOLOCK)
                     ON cz.CartonizationGroup = ph.StorerKey
                    AND cz.CartonType         = pi.CartonType
                  WHERE pi.PickSlipNo = @cPickSlipNo
                    AND pi.CartonNo   = @nCartonNo
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273663
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END CATCH

               BEGIN TRY
                  UPDATE dbo.TASKDETAIL WITH (ROWLOCK)
                  SET CaseID = @c_LabelNo
                  WHERE CaseID    = @cFromDropID
                    AND StorerKey = @cStorerKey
                    AND Status    IN ('X')
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 0 -- Non-critical
               END CATCH

               BEGIN TRY
                  UPDATE dbo.TASKDETAIL WITH (ROWLOCK)
                  SET Message01 = 'POST-HOSP'
                  WHERE CaseID    = @c_LabelNo
                    AND StorerKey = @cStorerKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 0 -- Non-critical
               END CATCH

               BEGIN TRY
                  UPDATE dbo.TASKDETAIL WITH (ROWLOCK)
                  SET Status = 'X'
                  WHERE CaseID    = @c_LabelNo
                    AND StorerKey = @cStorerKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo  = 273664
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END CATCH

            END -- Step 4, Option!=1

         END -- @nInputKey = 1
      END -- Step 4

   END -- @nFunc = 838

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_838ExtUpd37] TO [NSQL]
GO
