

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_838ExtUpd27                                              */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: Extended Upd for Cajamar                                             */
/*                                                                               */
/* Date       Rev  Author      Purposes                                          */
/* 2025-11-13 1.0  Jackc       FCR-8974 Created                                  */
/*********************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtUpd27 (
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

   DECLARE  @bDebugFlag    BINARY = 0,
            @cOrderKey     NVARCHAR(10),
            @nRowCount     INT

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 5 -- Print label
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cOption = 1 -- Yes
            BEGIN
               DECLARE @bSuccess             INT
 
               IF @bDebugFlag = 1
                  SELECT 'Generate Transmit Log2', @cPickSlipNo AS PSNO, @cLabelNo AS LabelNo, @cPackDtlDropID AS PackToDropID

               SELECT TOP 1 @cOrderKey = PH.OrderKey
               FROM dbo.PackDetail PD WITH (NOLOCK)
               JOIN dbo.PackHeader PH WITH (NOLOCK)
                  ON PD.StorerKey = PH.StorerKey
                  AND PD.PickSlipNo = PH.PickSlipNo
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.DropID = @cPackDtlDropID
                  AND PD.LabelNo = @cLabelNo

               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount <> 0 AND ISNULL(@cOrderKey, '') <> ''
               BEGIN

                  EXECUTE ispGenTransmitLog2 
                  @c_TableName      = 'WSSORFID', 
                  @c_Key1           = @cOrderKey, 
                  @c_Key2           = @cLabelNo, 
                  @c_Key3           = @cStorerkey, 
                  @c_TransmitBatch  = '', 
                  @b_Success        = @bSuccess   OUTPUT,    
                  @n_err            = @nErrNo     OUTPUT,    
                  @c_errmsg         = @cErrMsg    OUTPUT

                  IF @nErrNo <> 0 OR @bSuccess <> 1
                     GOTO Quit
               END
               ELSE
               BEGIN
                  SET @nErrNo = 250501
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               GOTO Quit
            END -- option=1
         END -- key=1
      END -- step5
   END -- 838

   GOTO Quit

   Quit:  



END--sp
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtUpd27 TO NSQL
GO