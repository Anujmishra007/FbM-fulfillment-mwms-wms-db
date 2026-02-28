
/************************************************************************************/
/* Store procedure: rdt_838ExtUpd24                                                 */
/* Copyright      : Maersk                                                          */
/*                                                                                  */
/* Purpose: Extended Upd for AMZDGL VNM                                             */
/*                                                                                  */
/* Date       Rev   Author      Purposes                                            */
/* 2025-06-03 1.0.0 Jackc       FCR-3848 Created                                    */
/************************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtUpd24 (
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

   DECLARE  @nDebugFlag INT = 0

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 8 -- UCC
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Executing rdt_838ExtUpd24 St8'
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @nDebugFlag = 1
               SELECT @cLabelNo AS LabelNo, @cPickSlipNo AS PickSlipNo

            IF EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                           AND Status = '9')
            BEGIN
               SET @nErrNo = 239301
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END -- PackHeader Status = 9

            --insert into packserialno
            IF EXISTS (SELECT 1 
                        FROM dbo.SerialNo SN WITH (NOLOCK)
                        JOIN dbo.PackDetail PD WITH (NOLOCK)
                           ON SN.StorerKey = PD.StorerKey
                           AND SN.UCCNo = PD.LabelNo
                        WHERE PD.StorerKey = @cStorerKey
                        AND PD.LabelNo = @cLabelNo
                        AND PD.PickSlipNo = @cPickSlipNo
                      )
            BEGIN
               IF NOT EXISTS (SELECT 1 
                           FROM dbo.PackSerialNo PSN WITH (NOLOCK)
                           WHERE PSN.StorerKey = @cStorerKey
                             AND PSN.LabelNo = @cLabelNo
                             AND PSN.PickSlipNo = @cPickSlipNo)
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Insert into PackSerialNo'
                  BEGIN TRY
                     INSERT INTO dbo.PackSerialNo (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY)
                        SELECT @cPickSlipNo, PD.CartonNo, @cLabelNo, PD.LabelLine, @cStorerKey, PD.SKU, SerialNo, SN.QTY 
                        FROM dbo.SerialNo SN WITH (NOLOCK)
                        JOIN dbo.PackDetail PD WITH (NOLOCK)
                           ON SN.StorerKey = PD.StorerKey
                           AND SN.UCCNo = PD.LabelNo
                        WHERE PD.StorerKey = @cStorerKey
                        AND PD.LabelNo = @cLabelNo
                        AND PD.PickSlipNo = @cPickSlipNo
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 239302
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END CATCH
               END -- not exists PackSerialNo
            END --step8

            GOTO Quit

         END -- key=1
      END -- step8
      ELSE IF @nStep = 2
      BEGIN
         IF @nInputKey = 0 --ESC
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Executing rdt_838ExtUpd24 St2 ESC'
            
            IF EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                           AND Status = '9')
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Update SerialNo under pickslipno'
               BEGIN TRY
                  -- update serialno under this picslipno to status 6
                  UPDATE SN WITH (ROWLOCK)
                  SET Status = '6'
                  FROM dbo.SerialNo SN
                  JOIN dbo.PackDetail PD WITH (NOLOCK)
                     ON SN.StorerKey = PD.StorerKey
                     AND SN.UCCNo = PD.LabelNo
                  WHERE PD.StorerKey = @cStorerKey
                  AND PD.PickSlipNo = @cPickSlipNo
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 239303
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END CATCH
            END
         END -- ESC
      END -- step2
   END -- 838

   GOTO Quit

   Quit:
   IF @nDebugFlag = 1
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

END--sp
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtUpd24 TO NSQL
GO