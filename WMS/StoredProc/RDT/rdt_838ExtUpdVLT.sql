SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_838ExtUpdVLT                                    */
/*                                                                      */
/*                                                                      */
/* Date         Author   Purposes                                       */
/* 17/05/2024   PPA374   Inserts DROPID in the DropID table             */
/* 28/11/2024   AGA399   Inserts Weight and RefNo in the PackInfo table */
/* 12/12/2024   PPA374   Clearing SN after repack                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_838ExtUpdVLT] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFacility       NVARCHAR( 5),
   @cStorerKey      NVARCHAR( 15),
   @cPickSlipNo     NVARCHAR( 10),
   @cFromDropID     NVARCHAR( 20),
   @nCartonNo       INT,
   @cLabelNo        NVARCHAR( 20),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cUCCNo          NVARCHAR( 20),
   @cCartonType     NVARCHAR( 10),
   @cCube           NVARCHAR( 10),
   @cWeight         NVARCHAR( 10),
   @cRefNo          NVARCHAR( 20),
   @cSerialNo       NVARCHAR( 30),
   @nSerialQTY      INT,
   @cOption         NVARCHAR( 1),
   @cPackDtlRefNo   NVARCHAR( 20),
   @cPackDtlRefNo2  NVARCHAR( 20),
   @cPackDtlUPC     NVARCHAR( 30),
   @cPackDtlDropID  NVARCHAR( 20),
   @cPackData1      NVARCHAR( 30),
   @cPackData2      NVARCHAR( 30),
   @cPackData3      NVARCHAR( 30),
   @nErrNo          INT            OUTPUT,
   @cErrMsg         NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
   @LOADKEY nvarchar(20),
   @PICKSLIP nvarchar(20),
   @myOrderKey nvarchar(20),
   @nTotalCartonNo int,--AGA 28/11/24
   @nCurrentCartonNo int,--AGA 28/11/24
   @fCurrentGrossWgt FLOAT, --AGA 28/11/24
   @fStdGrossWgt    FLOAT --AGA 28/11/24

   --Finding load key AND pickslip number
   SELECT TOP 1 @LOADKEY = LoadKey FROM dbo.ORDERS WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND orderkey = (SELECT TOP 1 OrderKey FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE DropID = @cFromDropID AND Storerkey = @cStorerKey)
   SELECT TOP 1 @PICKSLIP = PickHeaderKey FROM dbo.PICKHEADER WITH(NOLOCK) WHERE orderkey = (SELECT TOP 1 OrderKey FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE DropID = @cFromDropID AND Storerkey = @cStorerKey)

   IF @nFunc = 838
   BEGIN
      --If operator is NOT printing the label for DROPID AND drop id record does NOT exist in the DropID table
      IF @nStep = 5 -- Print Label
         AND @cOption = 2 -- no
         AND NOT EXISTS (SELECT 1 FROM dbo.DROPID WITH(NOLOCK) WHERE dropid = @cPackDtlDropID)
      BEGIN
         INSERT INTO Dropid(Dropid,Droploc,AdditionalLoc,DropIDType,LabelPrinted,ManifestPrinted,Status,AddDate,AddWho,EditDate,EditWho,TrafficCop,ArchiveCop,Loadkey,PickSlipNo,UDF01,UDF02,UDF03,UDF04,UDF05)
         VALUES(@cPackDtlDropID,'','',0,'N',0,5,GETDATE(),SUSER_NAME(),GETDATE(),SUSER_NAME(),NULL,NULL,@LOADKEY,@PICKSLIP,'','','','','')
      END

      --If operator is printing the label for DROPID AND drop id record does NOT exist in the DropID table
      ELSE IF @nStep = 5 --Print Label
      AND @cOption = 1 -- Yes
      AND NOT EXISTS (SELECT 1 FROM dbo.DROPID WITH(NOLOCK) WHERE dropid = @cPackDtlDropID)
      BEGIN
         INSERT INTO Dropid(Dropid,Droploc,AdditionalLoc,DropIDType,LabelPrinted,ManifestPrinted,Status,AddDate,AddWho,EditDate,EditWho,TrafficCop,ArchiveCop,Loadkey,PickSlipNo,UDF01,UDF02,UDF03,UDF04,UDF05)
         VALUES(@cPackDtlDropID,'','',0,'Y',0,5,GETDATE(),SUSER_NAME(),GETDATE(),SUSER_NAME(),NULL,NULL,@LOADKEY,@PICKSLIP,'','','','','')
      END

      --If operator is printing the label for DROPID AND drop id record already exist in the DropID table
      ELSE IF @nStep = 5 -- Print Label
      AND @cOption = 1 -- Yes
      AND EXISTS (SELECT 1 FROM dbo.DROPID WITH(NOLOCK) WHERE dropid = @cPackDtlDropID AND LabelPrinted = 'N')
      BEGIN
         UPDATE dropid WITH(ROWLOCK)
         SET LabelPrinted = 'Y'
         WHERE dropid = @cPackDtlDropID
      END

     --Inserting DropID into the DropID table at SKU QTY step. Required in scenarios when label will NOT be printed.
      IF @nStep = 3 -- SKU QTY
      AND NOT EXISTS (SELECT 1 FROM dbo.DROPID WITH(NOLOCK) WHERE dropid = @cPackDtlDropID)
      BEGIN
         INSERT INTO Dropid(Dropid,Droploc,AdditionalLoc,DropIDType,LabelPrinted,ManifestPrinted,Status,AddDate,AddWho,EditDate,EditWho,TrafficCop,ArchiveCop,Loadkey,PickSlipNo,UDF01,UDF02,UDF03,UDF04,UDF05)
         VALUES(@cPackDtlDropID,'','',0,'N',0,5,GETDATE(),SUSER_NAME(),GETDATE(),SUSER_NAME(),NULL,NULL,@LOADKEY,@PICKSLIP,'','','','','')
      END

     IF @nStep = 2
     AND EXISTS (SELECT 1 FROM dbo.PICKDETAIL PD WITH(NOLOCK) WHERE DropID = @cFromDropID AND Status = 0 AND 
     EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE L.Loc = PD.Loc AND LocationType IN ('STAGEOB','TROLLEYOB','VAS')))
     BEGIN
       UPDATE PICKDETAIL WITH(ROWLOCK)
       SET STATUS = 5
       WHERE DropID = @cFromDropID AND Status = 0 AND EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE L.Loc = PICKDETAIL.Loc AND LocationType IN ('STAGEOB','TROLLEYOB','VAS'))
     END  

      IF @nStep = 2
        BEGIN

          DELETE FROM dbo.SERIALNO WHERE OrderKey = '' AND OrderLineNumber = '' AND StorerKey = @cStorerKey

          DELETE FROM dbo.SERIALNO 
            WHERE EXISTS
            (SELECT 1 FROM dbo.SERIALNO SN WITH(NOLOCK) WHERE SerialNo.SerialNo = SN.SerialNo AND StorerKey = @cStorerKey AND
            EXISTS (SELECT 1 FROM dbo.PICKDETAIL PID WITH(NOLOCK) WHERE SN.OrderKey = PID.OrderKey AND SN.OrderLineNumber = PID.OrderLineNumber 
            AND DropID = @cFromDropID AND Storerkey = @cStorerKey)
            AND NOT EXISTS (SELECT 1 FROM dbo.PACKDETAIL PAD WITH(NOLOCK) WHERE PAD.RefNo = SN.SerialNo AND StorerKey = @cStorerKey))

        END

     --Inserting Weight and RefNo into PackInfo Tbale for E-delivery mapping for those E-delivery orders that have been repacked by RDT 838
     IF @nStep = 2 -- In step 2 system updates PackInfo
     AND NOT EXISTS (SELECT 1 FROM dbo.PACKINFO WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo  AND RefNo = @cPackDtlDropID AND CartonNo = @nCartonNo)
     BEGIN
      SELECT @fStdGrossWgt = @nQTY * StdGrossWgt
      FROM dbo.SKU WITH(NOLOCK)
      WHERE SKU = @cSKU 
      AND StorerKey = @cStorerKey

      --Update table PackInfo with weight and RefNo
      UPDATE dbo.PACKINFO WITH(ROWLOCK)
      SET Weight = @fStdGrossWgt
      ,RefNo = @cPackDtlDropID
      WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo		
      
     END

	 IF @nStep = 2 AND 
	 EXISTS(SELECT 1 FROM dbo.PackDetail WITH(NOLOCK) WHERE DropID = @cPackDtlDropID) AND
	 EXISTS(SELECT 1 FROM dbo.Dropid WITH(NOLOCK) WHERE DropID = @cPackDtlDropID AND LoadKey IS NULL)
	 BEGIN
	    UPDATE dbo.Dropid WITH(ROWLOCK)
		SET LoadKey = (SELECT TOP 1 LoadKey FROM LOADPLAN WITH(NOLOCK) WHERE MBOLKEY = (SELECT TOP 1 MBOLKEY FROM ORDERS WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND OrderKey = (SELECT TOP 1 OrderKey FROM PICKHEADER WITH(NOLOCK) WHERE PICKHEADERKEY = (SELECT TOP 1 PICKSLIPNO FROM PACKDETAIL WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND DROPID = @cPackDtlDropID))))
		WHERE DropID = @cPackDtlDropID
	 END

     --In case is a E-delivery Order repacked, Update table TRANSMITLOG2 to resend to E-delivery the request
     IF @nStep = 6 -- Print pack List screen only showed when user pack the last carton of the order
     AND (@cOption = 1 OR @cOption = 2) -- 1 Yes / 2 No
     BEGIN
      --Get value of the current OrderKey that has been packed
      SELECT @myOrderKey = (SELECT ORDERKEY FROM dbo.PACKHEADER WITH(NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
      --If that SO etits in TRANSMITLOG2 it is E-delivery Order, Update value of transmitflag to send again to E-delivery
      IF EXISTS (SELECT 1 FROM dbo.TRANSMITLOG2 WITH(NOLOCK) WHERE tablename = 'WSCRSOEDELIV' AND Key1 = @myOrderKey and key3 = @cStorerKey)
         BEGIN
            /*Before resent request to E-delivery, update the values of weight in PACKINFO table
            base on PACKDETAIL table this is in case more than one SKU in the same dropId*/
            SET @nTotalCartonNo = (SELECT count (DISTINCT CartonNo) FROM dbo.PACKINFO WITH(NOLOCK)  WHERE pickslipno = @cPickSlipNo)
            SET @nCurrentCartonNo = 1

            WHILE  @nCurrentCartonNo <= @nTotalCartonNo
            BEGIN
               SELECT @fCurrentGrossWgt = (SELECT TOP 1 
                                SUM(SKU.STDGROSSWGT*PKD.Qty)OVER(PARTITION BY PKD.DropId) AS TOTALWEIGHT
                                FROM dbo.PACKDETAIL AS PKD WITH(NOLOCK)
                                INNER JOIN SKU (NOLOCK) SKU ON PKD.SKU = SKU.SKU
                                WHERE PKD.storerkey = @cStorerKey
                                AND PKD.PICKSLIPNO =  @cPickSlipNo
                                AND CartonNo = @nCurrentCartonNo)

               UPDATE dbo.PACKINFO WITH(ROWLOCK)
               SET Weight = @fCurrentGrossWgt
               WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo

                  SET @fCurrentGrossWgt = 0 
                  SET @nCurrentCartonNo = @nCurrentCartonNo + 1
               END

            --Update TRANSMITLOG2 to send again to E-delivery request
            UPDATE dbo.TRANSMITLOG2 WITH(ROWLOCK)
            SET transmitflag = 'R'
            WHERE tablename = 'WSCRSOEDELIV' AND Key1 = @myOrderKey AND key3 = @cStorerKey
      
            SET @myOrderKey = ''--Restart value of the OrderKey
         END
      END
   END
END-- end sp
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_838ExtUpdVLT] TO [NSQL]
