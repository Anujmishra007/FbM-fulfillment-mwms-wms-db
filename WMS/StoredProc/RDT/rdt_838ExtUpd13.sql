
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtUpd13                                     */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 04-03-2022 1.0  Ung        WMS-19000 Created                         */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtUpd13 (
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

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_838ExtUpd01 -- For rollback or commit only our own transaction

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 4-- Weight,Cube
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @fWeight FLOAT = 0
            DECLARE @nCartonWeight FLOAT = 0
            DECLARE @nCaseCNT FLOAT
            DECLARE @cUDF02 NVARCHAR( 30)
            
            -- Loop PackDetailInfo
            DECLARE @curPI CURSOR
            SET @curPI = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT SKU, UserDefine02, QTY
               FROM dbo.PackDetailInfo WITH (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
                  AND CartonNo = @nCartonNo
            OPEN @curPI
            FETCH NEXT FROM @curPI INTO @cSKU, @cUDF02, @nQTY
            WHILE @@FETCH_STATUS = 0
            BEGIN
               -- Get SKU info
               SELECT @nCaseCNT = Pack.CaseCNT
               FROM dbo.SKU WITH (NOLOCK)
                  JOIN dbo.Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
               WHERE SKU.StorerKey = @cStorerKey
                  AND SKU.SKU = @cSKU
               
               -- Calc weight
               IF @nCaseCNT > 0 AND ISNUMERIC( @cUDF02) = 1
                  SET @fWeight = @fWeight + (CEILING( @nQTY / @nCaseCNT) * @cUDF02)
                  
               FETCH NEXT FROM @curPI INTO @cSKU, @cUDF02, @nQTY
            END
            
            -- Add carton weight
            IF @cCartonType <> ''
            BEGIN
               SELECT @nCartonWeight = ISNULL( CartonWeight, 0)
               FROM dbo.Storer S WITH (NOLOCK)
                  JOIN dbo.Cartonization C WITH (NOLOCK) ON (S.CartonGroup = C.CartonizationGroup)
               WHERE S.StorerKey = @cStorerKey
                  AND C.CartonType = @cCartonType
            
               SET @fWeight = @fWeight + @nCartonWeight
            END
            
            -- Overwrite with calculated weight
            UPDATE dbo.PackInfo SET
               Weight = @fWeight,
               EditDate = GETDATE(), 
               EditWho = SUSER_SNAME(), 
               TrafficCop = NULL
            WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 183851
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDPackInfFail
               GOTO Quit
            END
         END
      END
   END
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_838ExtUpd13 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtUpd13 TO NSQL
GO
