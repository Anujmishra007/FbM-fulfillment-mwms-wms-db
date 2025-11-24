
/************************************************************************************/
/* Store procedure: rdt_777ExtUpd01                                                 */
/* Copyright      : Maersk                                                          */
/*                                                                                  */
/* Purpose: Extended Upd for AMZDGL VNM                                             */
/*                                                                                  */
/* Date       Rev   Author      Purposes                                            */
/* 2025-11-21 1.0.0 NickT       FCR-9200 Created                                    */
/************************************************************************************/

CREATE OR ALTER PROC rdt.rdt_777ExtUpd01 (
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

   DECLARE 
      @nTranCount    INT

   SELECT @nTranCount = @@TRANCOUNT

   IF @nTranCount = 0
      BEGIN TRANSACTION
   ELSE
      SAVE TRANSACTION rdt_777ExtUpd01

   IF @nFunc = 777 -- Pack
   BEGIN
      IF @nStep = 4 -- Capture weight/CartonType/Cube
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE
               @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),   @cFieldAttr04 NVARCHAR( 1),
               @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),   @cFieldAttr05 NVARCHAR( 1),
               @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),   @cFieldAttr06 NVARCHAR( 1),
               @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),   @cFieldAttr07 NVARCHAR( 1),
               @cLength             NVARCHAR( 10),
               @cWidth              NVARCHAR( 10),
               @cHeight             NVARCHAR( 10)

            SELECT 
               @cFieldAttr05 = FieldAttr05,
               @cFieldAttr06 = FieldAttr06,
               @cFieldAttr07 = FieldAttr07,
               @cInField05 = I_Field05,   @cOutField05 = O_Field05,
               @cInField06 = I_Field06,   @cOutField06 = O_Field06,
               @cInField07 = I_Field07,   @cOutField07 = O_Field07
            FROM RDT.RDTMOBREC WITH(NOLOCK)
            WHERE Mobile = @nMobile

            SET @cLength         = CASE WHEN @cFieldAttr05 = '' THEN @cInField05 ELSE @cOutField05 END
            SET @cWidth          = CASE WHEN @cFieldAttr06 = '' THEN @cInField06 ELSE @cOutField06 END
            SET @cHeight         = CASE WHEN @cFieldAttr07 = '' THEN @cInField07 ELSE @cOutField07 END

            DECLARE @fCube          FLOAT
            DECLARE @fWeight        FLOAT
            DECLARE @fLength        FLOAT
            DECLARE @fWidth         FLOAT
            DECLARE @fHeight        FLOAT

            SET @fCube     = CAST( @cCube AS FLOAT)
            SET @fWeight   = CAST( @cWeight AS FLOAT)
            SET @fLength   = CAST( @cLength AS FLOAT)
            SET @fWidth    = CAST( @cWidth AS FLOAT)
            SET @fHeight   = CAST( @cHeight AS FLOAT)
            
            DECLARE @curPackInfo CURSOR

            SET @curPackInfo = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT PickSlipNo, CartonNo
               FROM dbo.PackInfo WITH (NOLOCK)
               WHERE RefNo IS NOT NULL
                  AND RefNo = @cLabelNo
                  AND AddWho = SUSER_NAME()
               ORDER BY PickSlipNo, CartonNo

            OPEN @curPackInfo
            FETCH NEXT FROM @curPackInfo INTO @cPickSlipNo, @nCartonNo
            WHILE @@FETCH_STATUS = 0
            BEGIN
               BEGIN TRY
                  UPDATE dbo.PackInfo WITH(ROWLOCK) 
                  SET
                     CartonType = @cCartonType,
                     Weight = @fWeight,
                     Cube = @fCube,
                     Length = @fLength,
                     Width = @fWidth,
                     Height = @fHeight 
                  WHERE PickSlipNo = @cPickSlipNo
                     AND CartonNo = @nCartonNo
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 251701
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --  Update PackInfo Failed
                  GOTO RollBackTran
               END CATCH

               FETCH NEXT FROM @curPackInfo INTO @cPickSlipNo, @nCartonNo
            END
         END -- key=1
      END -- step4
   END -- 838

   COMMIT TRANSACTION

   GOTO Quit

   RollBackTran:
   IF XACT_STATE() = -1
   BEGIN
      ROLLBACK TRANSACTION
   END

   Quit:

END--sp
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_777ExtUpd01 TO NSQL
GO