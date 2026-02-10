
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
/* 2025-08-19   1.4.0  NickT    UWP-38742 Fix: PackDetail Qty is wrong  */
/* 2025-08-19   1.5.0  NickT    FCR-6730 Add @cShipRef, fixed an issue  */
/* 2025-09-16   1.6.0  JackC    UWP-40608 Performance tuning            */
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
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @nDebugFlag INT = 0

   DECLARE 
      @cCaseID          NVARCHAR(20),
      @nQTY             INT,
      @nRowCount        INT,
      @nTranCount       INT,
      @bSuccess         INT,
      @cPickslipNo      NVARCHAR( 10),
      @cSKU             NVARCHAR( 20),
      @cShipRef         NVARCHAR( 10)

   DECLARE @nMaxPerBatch   INT = 5000    

   DECLARE @tShortCaseList TABLE
   (
      CASEID NVARCHAR(20)
      PRIMARY KEY CLUSTERED(CASEID)
   )

   DECLARE @tPackDetail TABLE
   (
      RowNumber   INT IDENTITY,
      PickSlipNo  NVARCHAR( 10)  NOT NULL,
      OrderKey    NVARCHAR( 10)  NOT NULL,
      CartonNo    INT            NOT NULL,
      LabelNo     NVARCHAR( 20)  NOT NULL,
      LabelLine   NVARCHAR( 5)   NOT NULL,
      SKU         NVARCHAR( 20)  NOT NULL,
      QTY         INT            NOT NULL DEFAULT 0,
      PRIMARY KEY CLUSTERED(PickSlipNo, CartonNo, LabelNo, LabelLine)
   );

   IF @nFunc = 869
   BEGIN
      IF @nStep = 3 
      BEGIN
         IF @nInputKey = 1 AND @cOption = '1'
         BEGIN
            SELECT 
               @cShipRef            = C_String1
            FROM rdt.rdtMobRec (NOLOCK)
            WHERE Mobile = @nMobile

            IF @cOrderKey <> ''
            BEGIN
               INSERT INTO @tShortCaseList
                  SELECT DISTINCT CaseID
                  FROM dbo.PickDetail WITH (NOLOCK)
                  WHERE OrderKey = @cOrderKey
                  AND StorerKey = @cStorerKey
                  AND Status = '0'
                  AND Qty = 0
            END

            IF @cLoadKey <> ''
            BEGIN
               INSERT INTO @tShortCaseList
                  SELECT DISTINCT CaseID
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                     INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
                  WHERE OD.LoadKey = @cLoadKey
                     AND PD.StorerKey = @cStorerKey
                     AND PD.Status = '0'
                     AND PD.Qty = 0
            END

            IF @cWaveKey <> ''
            BEGIN
               IF @cShipRef = ''
               BEGIN
                  INSERT INTO @tShortCaseList
                     SELECT DISTINCT CaseID
                     FROM dbo.PickDetail PD WITH (NOLOCK)
                        INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
                        INNER JOIN dbo.WaveDetail WD  WITH (NOLOCK) ON (OD.OrderKey = WD.OrderKey)
                     WHERE WD.WaveKey = @cWaveKey
                        AND PD.Storerkey = @cStorerKey
                        AND PD.Status = '0'
                        AND PD.Qty = 0
               END
               ELSE
               BEGIN
                  INSERT INTO @tShortCaseList
                     SELECT DISTINCT CaseID
                     FROM dbo.PickDetail PD WITH (NOLOCK)
                     INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON (OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber)
                     INNER JOIN dbo.WaveDetail WD  WITH (NOLOCK) ON (OD.OrderKey = WD.OrderKey)
                     INNER JOIN dbo.ORDERS ORD WITH (NOLOCK) ON (ORD.OrderKey = OD.OrderKey AND ORD.StorerKey = OD.StorerKey)
                     WHERE WD.WaveKey = @cWaveKey
                        AND PD.Storerkey = @cStorerKey
                        AND ORD.MBOLKey IS NOT NULL
                        AND ORD.MBOLKey  = @cShipRef
                        AND PD.Status = '0'
                        AND PD.Qty = 0
               END
            END

            IF @nDebugFlag = 1
            BEGIN
               SELECT '@tShortCaseList'
               SELECT * FROM @tShortCaseList
            END

            BEGIN TRY
               INSERT INTO @tPackDetail
                  SELECT  PH.PickHeaderKey, PKD.OrderKey, PD.CartonNo, PKD.CaseID, PD.LabelLine, PKD.SKU, SUM(PKD.Qty)
                  FROM dbo.PickDetail PKD WITH (NOLOCK)
                  INNER JOIN @tShortCaseList List
                     ON PKD.CaseID = List.CASEID
                  INNER JOIN dbo.PickHeader PH WITH (NOLOCK)
                     ON PKD.OrderKey = PH.OrderKey
                  INNER JOIN dbo.PackDetail PD WITH (NOLOCK)
                     ON PH.PickHeaderKey = PD.PickSlipNo
                     AND PKD.CaseID = PD.LabelNo
                     AND PKD.SKU = PD.SKU
                  GROUP BY PH.PickHeaderKey, PKD.OrderKey, PD.CartonNo, PKD.CaseID, PD.LabelLine, PKD.SKU
                  ORDER BY PH.PickHeaderKey, PKD.OrderKey, PD.CartonNo,PD.LabelLine, PKD.SKU
            END TRY
            BEGIN CATCH
               SET @nErrNo = 246851 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS fail
               GOTO QUIT
            END CATCH

            IF @nDebugFlag = 1
            BEGIN
               SELECT '@tPackDetail'
               SELECT * FROM @tPackDetail
            END

            --Update packdetail by batch
            WHILE EXISTS (SELECT 1 FROM @tPackDetail WHERE RowNumber > 0)
            BEGIN
               SET @nTranCount = @@TRANCOUNT  
               IF @nTranCount = 0
                  BEGIN TRANSACTION
               ELSE
                  SAVE TRANSACTION rdt_869ExtUpd01

               --Only hanlde 
               SELECT TOP (@nMaxPerBatch) *
               INTO #Batch
               FROM @tPackDetail
               ORDER BY RowNumber

               ALTER TABLE #Batch
               ADD CONSTRAINT PK_Batch PRIMARY KEY CLUSTERED (PickSlipNo, CartonNo, LabelNo, LabelLine)

               IF @nDebugFlag = 1
               BEGIN
                  SELECT 'Get batch data'
                  SELECT * FROM #Batch
               END

               BEGIN TRY
                  UPDATE PD
                     SET PD.QTY = B.QTY
                  FROM dbo.PackDetail PD WITH(ROWLOCK)
                  INNER JOIN #Batch B
                     ON PD.PickSlipNo = B.PickSlipNo
                  AND PD.CartonNo = B.CartonNo
                  AND PD.LabelNo = B.LabelNo
                  AND PD.LabelLine = B.LabelLine
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 246852 
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd pack detail fail
                  GOTO RollBackTran
               END CATCH

               BEGIN TRY
                  DELETE PH
                  FROM dbo.PackHeader PH WITH(ROWLOCK)
                  INNER JOIN #Batch B ON PH.PickSlipNo = B.PickSlipNo
                  WHERE NOT EXISTS (
                     SELECT 1 FROM dbo.PickDetail PD WITH(NOLOCK)
                     WHERE PD.OrderKey = B.OrderKey 
                        AND PD.Status <> 0
                  )
                  AND NOT EXISTS (
                     SELECT 1 FROM dbo.PackDetail PD WITH(NOLOCK)
                     WHERE PD.PickSlipNo = B.PickSlipNo
                  )
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 246853 
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS fail
                  GOTO RollBackTran
               END CATCH

               DELETE T
               FROM @tPackDetail T
               INNER JOIN #Batch B ON T.RowNumber = B.RowNumber

               DROP TABLE #Batch

               IF (XACT_STATE()) = -1
               BEGIN
                  SET @nErrNo = 246854
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS fail
                  GOTO RollBackTran
               END
               ELSE
                  COMMIT TRAN
            END --END while

            IF @nDebugFlag = 1
               SELECT 'End of loop'


            GOTO QUIT
         END --inputkey = 1
      END
   END
   GOTO QUIT

   RollBackTran:
      IF OBJECT_ID('tempdb..#Batch') IS NOT NULL
         DROP TABLE #Batch

      IF @nTranCount > 0 AND XACT_STATE() = 1
         ROLLBACK TRAN rdt_869ExtUpd01
      ELSE
         ROLLBACK TRAN

   QUIT:
      IF @nDebugFlag = 1
         SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO   
GRANT EXECUTE ON [RDT].[rdt_869ExtUpd01] TO [NSQL]
