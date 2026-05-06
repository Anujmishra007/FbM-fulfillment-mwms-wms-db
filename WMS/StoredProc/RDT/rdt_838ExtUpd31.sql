

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_838ExtUpd31                                              */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose:                                                                      */
/*                                                                               */
/* Date       Rev  Author      Purposes                                          */
/* 2026-01-12 1.0  Dennis      FCR-7820 Created                                  */
/*********************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtUpd31 (
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

   DECLARE  @bDebugFlag             BINARY = 0,
            @nCartonQTY             INT,
            @cNotAllowEscOnSKUQty   NVARCHAR(10)

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 5 -- Print label
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cOption = '1' -- Yes
            BEGIN
               DECLARE @bSuccess             INT
               DECLARE @cTransmitLogKey      NVARCHAR( 10)
               DECLARE @c_QCmdClass          NVARCHAR( 10)   = '' 
               DECLARE @cShipperKey          NVARCHAR( 15)
               DECLARE @fCartonWgt           FLOAT = 0  
               DECLARE @b_Debug              INT = 0
               DECLARE @nTranCount           INT
               DECLARE @fCartonCube          FLOAT = 0  

               --V1.2 Get upd carton weight to packinfo by JCH507
               BEGIN TRY
                  UPDATE PackInfo
                  SET
                     CartonStatus = 'Y'
                  WHERE PickSlipNo = @cPickSlipNo
                     AND CartonNo = @nCartonNo
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 221602
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd Packinfo failure
                  GOTO Quit
               END CATCH
               --V1.2 Get upd carton weight to packinfo by JCH507  end

               GOTO Quit

            END -- option=1
         END -- key=1
      END -- step5
      IF @nStep = 7
      BEGIN
         -- Restore PickDetail.CaseID to empty string where CaseID = LabelNo
         BEGIN TRY
            UPDATE PickDetail
            SET CaseID = '',
                EditDate = GETDATE(),
                EditWho = SUSER_SNAME(),
                TrafficCop = NULL
            WHERE CaseID = @cLabelNo
               AND StorerKey = @cStorerKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 221603
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Upd PickDetail failure
            GOTO Quit
         END CATCH
      END
   END -- 838

   GOTO Quit

Quit:  

END--sp
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtUpd31 TO NSQL
GO
