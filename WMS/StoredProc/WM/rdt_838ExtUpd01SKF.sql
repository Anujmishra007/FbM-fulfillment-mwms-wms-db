SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_838ExtUpd01SKF                                           */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Date       Rev  Author      Purposes                                          */
/* 2025-10-22 1.0  SYO054       Created based on rdt_838ExtUpd01 FOR SKF         */
/*                             Change Wave.Status =6 (if all packed)             */
/* 2025-11-03 1.1  SYO054        Fixed logic to properly check all packed        */
/* 2025-11-04 1.2  SYO054        Added logic to add record into DROPID table     */
/*                                                                               */
/*********************************************************************************/
CREATE PROC [RDT].[rdt_838ExtUpd01SKF] (
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

   DECLARE @cLabelLine NVARCHAR(5)
   DECLARE @nTranCount INT
   DECLARE @cOrderKey   NVARCHAR( 10)
   DECLARE @c_errmsg    NVARCHAR(225)
   DECLARE @n_continue  Int
   DECLARE @b_success   Int
   DECLARE @n_err       Int    

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nStep = 2
      BEGIN
        IF @nInputKey = 0 -- ESC
          --BEGIN: Update orderkey in packheader
          UPDATE PackHeader
          SET OrderKey = (SELECT TOP 1 PH.OrderKey FROM PackDetail PD
                            JOIN PICKDETAIL PH
                            ON PH.PickSlipNo = PD.PickSlipNo
                            AND PH.StorerKey = PD.StorerKey
                            WHERE PH.StorerKey = @cStorerKey AND PD.DropID = @cPackDtlDropID)
          WHERE  LEN(OrderKey) = 0
          AND StorerKey = @cStorerKey
          AND PickSlipNo = (SELECT TOP 1 PD.PickSlipNo FROM PackDetail PD
                            WHERE PD.StorerKey = @cStorerKey AND PD.DropID = @cPackDtlDropID)  
          --END: Update orderkey in packheader
          --BEGIN: WAVE.status update to Packed
          BEGIN
            -- Check if all orders in the wave are fully packed
            -- Must have pack records AND quantities must match AND pack headers complete
            IF EXISTS (
                SELECT 1
                FROM WAVEDETAIL WD WITH (NOLOCK)
                INNER JOIN PICKDETAIL PD WITH (NOLOCK) ON WD.OrderKey = PD.OrderKey
                WHERE PD.PickSlipNo = (SELECT TOP 1 PD.PickSlipNo FROM PackDetail PD
                                        WHERE PD.StorerKey = @cStorerKey AND PD.DropID = @cPackDtlDropID)  
            )
            AND NOT EXISTS (
                SELECT 1
                FROM WAVEDETAIL WD WITH (NOLOCK)
                INNER JOIN PICKDETAIL PD WITH (NOLOCK) ON WD.OrderKey = PD.OrderKey
                LEFT JOIN PACKDETAIL PKD WITH (NOLOCK) ON PD.PickSlipNo = PKD.PickSlipNo
                    AND PD.SKU = PKD.SKU
                    AND PD.StorerKey = PKD.StorerKey
                LEFT JOIN PACKHEADER PKH WITH (NOLOCK) ON PD.PickSlipNo = PKH.PickSlipNo
                    AND PD.StorerKey = PKH.StorerKey
                WHERE PD.PickSlipNo = (SELECT TOP 1 PD.PickSlipNo FROM PackDetail PD
                                        WHERE PD.StorerKey = @cStorerKey AND PD.DropID = @cPackDtlDropID)  
                GROUP BY WD.OrderKey
                HAVING SUM(PD.Qty) <> ISNULL(SUM(PKD.Qty), 0)
                    OR MIN(ISNULL(PKH.Status, 0)) <> 9
                    OR COUNT(PKD.SKU) = 0  -- No pack records exist
            )
            BEGIN
                -- All orders are fully packed, update wave status to 6
                   -- Debug: Print key parameters
                    --PRINT 'Func: ' + CAST(@nFunc AS NVARCHAR(10)) + ', Step: ' + CAST(@nStep AS NVARCHAR(10)) + ', InputKey: ' + CAST(@nInputKey AS NVARCHAR(10))
                    --PRINT 'PickSlip: ' + ISNULL(@cPickSlipNo, 'NULL') + ', StorerKey: ' + ISNULL(@cStorerKey, 'NULL')
                UPDATE WAVE
                SET Status = 6,
                    EditWho = 'sys.' + SUSER_SNAME(),
                    EditDate = GETDATE()
                WHERE WaveKey IN (
                    SELECT DISTINCT W.WaveKey
                    FROM WAVE W
                    INNER JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.WaveKey = W.WaveKey
                    INNER JOIN PICKDETAIL PD WITH (NOLOCK) ON WD.OrderKey = PD.OrderKey
                    WHERE PD.StorerKey = @cStorerKey
                        AND PD.PickSlipNo = (SELECT TOP 1 PD.PickSlipNo FROM PackDetail PD
                                                WHERE PD.StorerKey = @cStorerKey AND PD.DropID = @cPackDtlDropID)  
                        AND W.Status = 5
                )
            END
          END
          --END: WAVE.status update to Packed
      END
               --BEGIN: Insert record into DROPID
               DECLARE
                @LOADKEY nvarchar(20),
                @PICKSLIP nvarchar(20)
             --Finding load key, pickslip number
            SELECT TOP 1 @LOADKEY = LoadKey FROM ORDERS (NOLOCK) WHERE StorerKey = @cStorerKey and orderkey = (SELECT TOP 1 OrderKey FROM PICKDETAIL (NOLOCK) WHERE DropID = @cFromDropID and Storerkey = @cStorerKey)
            SELECT TOP 1 @PICKSLIP = PickHeaderKey FROM PICKHEADER (NOLOCK) WHERE orderkey = (SELECT TOP 1 OrderKey FROM PICKDETAIL (NOLOCK) WHERE DropID = @cFromDropID and Storerkey = @cStorerKey)
            IF @nStep = 3 -- SKU QTY
            AND NOT EXISTS (SELECT 1 FROM dropid (NOLOCK) WHERE dropid = @cPackDtlDropID)
            BEGIN
                INSERT INTO Dropid(Dropid,Droploc,AdditionalLoc,DropIDType,LabelPrinted,ManifestPrinted,Status,AddDate,AddWho,EditDate,EditWho,TrafficCop,ArchiveCop,Loadkey,PickSlipNo,UDF01,UDF02,UDF03,UDF04,UDF05)
                VALUES(@cPackDtlDropID,'','',0,'N',0,5,GETDATE(),SUSER_NAME(),GETDATE(),SUSER_NAME(),null,null,@LOADKEY,@PICKSLIP,'','','','','')
            END
            --END: Insert record into DROPID
   END
END
GO
