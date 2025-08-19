
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/
/* Store procedure: [rdt_869ExtUpd01]                                   */
/* Copyright: Maersk                                                    */
/* Customer:  Levis                                                     */
/*                                                                      */
/* Date         VER    Author   Purpose                                 */
/* 2024-11-21   1.0.0  Dennis   FCR-1349 Created                        */
/* 2025-04-09   1.1.0  Dennis   FCR-3925 Remove Trigger For Transmitlog2*/
/* 2025-07-02   1.2.0  Dennis   FCR-5019 Remove Pack Header             */
/* 2025-08-19   1.3.0  NickT    UWP-39586 Performance tuning            */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_869ExtUpd01] (
@nMobile    INT,
@nFunc      INT,
@cLangCode  NVARCHAR( 3),
@nStep      INT,
@nInputKey  INT,
@cFacility  NVARCHAR( 5),
@cStorerKey NVARCHAR( 15),
@cOption    NVARCHAR(  1),
@cLoadKey   NVARCHAR( 10),
@cOrderKey  NVARCHAR( 10),
@cWaveKey   NVARCHAR( 10),
@nErrNo     INT           OUTPUT,
@cErrMsg    NVARCHAR( 20) OUTPUT
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
DECLARE 
   @nLoopIndex INT = -1,
   @cCaseID    NVARCHAR(20),
   @nQTY       INT,
   @nRowCount  INT,
   @nTranCount INT,
   @bSuccess   INT,
   @cPickslipNo NVARCHAR( 10),
   @cSKU       NVARCHAR(20)
DECLARE @List TABLE
   (
   ID INT IDENTITY(1,1) NOT NULL,
   CASEID NVARCHAR(20),
   OrderKey NVARCHAR(20),
   SKU      NVARCHAR(20)
   )
DECLARE @tPackDetail TABLE
(
   RowNumber   INT IDENTITY,
   PickSlipNo  NVARCHAR( 10) NOT NULL,
   CartonNo    INT NOT NULL,
   LabelNo     NVARCHAR( 20) NOT NULL,
   LabelLine   NVARCHAR( 5) NOT NULL,
   PRIMARY KEY CLUSTERED(PickSlipNo, CartonNo, LabelNo, LabelLine)
)

IF @nFunc = 869
BEGIN
   IF @nStep = 3 
   BEGIN
      IF @nInputKey = 1 AND @cOption = '1'
      BEGIN
         DECLARE @curPD CURSOR
         IF @cOrderKey <> ''
         BEGIN
            INSERT INTO @List
               SELECT DISTINCT CaseID,@cOrderKey,SKU
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE OrderKey = @cOrderKey
         END

         IF @cLoadKey <> ''
         BEGIN
            INSERT INTO @List
               SELECT DISTINCT CaseID, OD.OrderKey,PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
               WHERE OD.LoadKey = @cLoadKey
         END

         IF @cWaveKey <> ''
         BEGIN
            INSERT INTO @List
               SELECT DISTINCT CaseID,OD.OrderKey,PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
                  INNER JOIN dbo.WaveDetail WD  WITH (NOLOCK) ON (OD.OrderKey = WD.OrderKey)
               WHERE WD.WaveKey = @cWaveKey
         END

         SET @nTranCount = @@TRANCOUNT  
         IF @nTranCount = 0
            BEGIN TRANSACTION
         ELSE
            SAVE TRANSACTION rdt_869ExtUpd01

         -- CASE ID
         SET @nLoopIndex = -1
         WHILE 1 = 1
         BEGIN
            SELECT TOP 1 
               @cCaseID = CaseID,
               @cOrderKey = OrderKey,
               @cSKU = SKU,
               @nLoopIndex = id
            FROM @List
            WHERE id > @nLoopIndex
            ORDER BY id

            SELECT @nRowCount = @@ROWCOUNT
            IF @nRowCount = 0
               BREAK

            DELETE FROM @tPackDetail

            INSERT INTO @tPackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine)
            SELECT DISTINCT PickSlipNo, CartonNo, LabelNo, LabelLine 
            FROM dbo.PackDetail WITH(NOLOCK) 
            WHERE LabelNo = @cCaseID 
               AND StorerKey = @cStorerKey

            SELECT @nRowCount = @@ROWCOUNT

            --IF EXISTS (SELECT 1 FROM dbo.PackDetail WITH(NOLOCK) WHERE LABELNO = @cCaseID AND StorerKey = @cStorerKey)
            IF @nRowCount > 0
            BEGIN
               SELECT @nQTY = SUM(QTY) FROM dbo.PickDetail WITH(NOLOCK) WHERE CaseID = @cCaseID AND StorerKey = @cStorerKey AND SKU = @cSKU
               --UPDATE dbo.PackDetail WITH(ROWLOCK) SET QTY = @nQTY WHERE LABELNO = @cCaseID AND StorerKey = @cStorerKey AND SKU = @cSKU
               UPDATE PD WITH(ROWLOCK)
               SET QTY = @nQTY
               FROM dbo.PackDetail PD WITH(ROWLOCK)
               INNER JOIN @tPackDetail tPD 
                  ON PD.PickSlipNo = tPD.PickSLipNo 
                  AND PD.CartonNo = tPD.CartonNo
                  AND PD.LabelNo = tPD.LabelNo
                  AND PD.LabelLine = tPD.LabelLine
            END

            SELECT TOP 1 @cPickSlipNo = PICKHEADERKEY FROM dbo.PICKHEADER(NOLOCK) WHERE OrderKey=@cOrderKey AND @cStorerKey = StorerKey

            --All pickdetail status = 0
            --No packdetail exists
            IF NOT EXISTS (SELECT 1 FROM dbo.PICKDETAIL(NOLOCK) WHERE OrderKey = @cOrderKey AND STATUS <> '0')
            AND NOT EXISTS (SELECT 1 FROM dbo.PACKDETAIL PD(NOLOCK) WHERE PickSLipNo = @cPickSlipNo AND PD.StorerKey = @cStorerKey)
            BEGIN
               DELETE FROM PackHeader WHERE OrderKey = @cOrderKey AND StorerKey = @cStorerKey
            END
         END

         WHILE @@TRANCOUNT > @nTranCount
            COMMIT TRANSACTION
         GOTO QUIT
      END
   END
END
GOTO QUIT

RollBackTran:
   ROLLBACK TRANSACTION
QUIT:

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO   
GRANT EXECUTE ON [RDT].[rdt_869ExtUpd01] TO [NSQL]
