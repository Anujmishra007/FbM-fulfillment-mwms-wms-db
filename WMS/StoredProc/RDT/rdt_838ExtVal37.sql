SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ExtVal37                                     */
/* Copyright      : Maersk WMS                                          */
/* Customer       : PAGEIND                                             */
/*                                                                      */
/* Date       Rev    Author      Purposes                               */
/* 2026-01-05 1.0    Dennis      FCR-7820 Created                       */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ExtVal37 (
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
      @cPickSlipNoForSerialNo       NVARCHAR( 10),
      @nScn                         INT,
      @nRowCount                    INT
   DECLARE @bSuccess  INT  
   DECLARE @cLoadKey  NVARCHAR( 10)  
   DECLARE @cOrderKey NVARCHAR( 10)  
   DECLARE @cZone     NVARCHAR( 18)  
   DECLARE @nPackQTY  INT  
   DECLARE @nPickQTY  INT  
   DECLARE @cPickStatus  NVARCHAR( 20) = '5'  -- Status 5 = Picked
   DECLARE @cPackConfirm NVARCHAR( 1)
   DECLARE @cFullyPickedCheck NVARCHAR( 1)

   SELECT @nScn = SCN FROM RDT.rdtMobRec WHERE Mobile = @nMobile

   IF @nFunc = 838 -- Pack
   BEGIN
      IF @nScn = 6861
      BEGIN
         -- Get FullyPickedCheck config
         SET @cFullyPickedCheck = rdt.RDTGetConfig( @nFunc, 'FullyPickedCheck', @cStorerKey)

         IF @cFullyPickedCheck = '1'
         BEGIN
            -- Get PickHeader info
            SELECT TOP 1
               @cOrderKey = OrderKey,
               @cLoadKey = ExternOrderKey,
               @cZone = Zone
            FROM dbo.PickHeader WITH (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo

            -- Cross dock PickSlip
            IF @cZone IN ('XD', 'LB', 'LP')
            BEGIN
               -- Check outstanding PickDetail
               IF EXISTS( SELECT TOP 1 1
                  FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  WHERE RKL.PickSlipNo = @cPickSlipNo
                     AND PD.Status < '5'
                     AND PD.QTY > 0
                     AND (PD.Status = '4' OR CHARINDEX( PD.Status, @cPickStatus) = 0))  -- Short or not yet pick
                  SET @cPackConfirm = 'N'
               ELSE
                  SET @cPackConfirm = 'Y'
            END
            -- Discrete PickSlip
            ELSE IF @cOrderKey <> ''
            BEGIN
               -- Check outstanding PickDetail
               IF EXISTS( SELECT TOP 1 1
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                  WHERE PD.OrderKey = @cOrderKey
                     AND PD.Status < '5'
                     AND PD.QTY > 0
                     AND (PD.Status = '4' OR CHARINDEX( PD.Status, @cPickStatus) = 0))  -- Short or not yet pick
                  SET @cPackConfirm = 'N'
               ELSE
                  SET @cPackConfirm = 'Y'
            END
            -- Conso PickSlip
            ELSE IF @cLoadKey <> ''
            BEGIN
               -- Check outstanding PickDetail
               IF EXISTS( SELECT TOP 1 1
                  FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                     JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)
                  WHERE LPD.LoadKey = @cLoadKey
                     AND PD.Status < '5'
                     AND PD.QTY > 0
                     AND (PD.Status = '4' OR CHARINDEX( PD.Status, @cPickStatus) = 0))  -- Short or not yet pick
                  SET @cPackConfirm = 'N'
               ELSE
                  SET @cPackConfirm = 'Y'
            END

            -- Custom PickSlip
            ELSE
            BEGIN
               -- Check outstanding PickDetail
               IF EXISTS( SELECT TOP 1 1
                  FROM PickDetail PD WITH (NOLOCK)
                  WHERE PD.PickSlipNo = @cPickSlipNo
                     AND PD.Status < '5'
                     AND PD.QTY > 0
                     AND (PD.Status = '4' OR CHARINDEX( PD.Status, @cPickStatus) = 0))  -- Short or not yet pick
                  SET @cPackConfirm = 'N'
               ELSE
                  SET @cPackConfirm = 'Y'
            END

            IF @cPackConfirm = 'N'
            BEGIN
               SET @nErrNo = 255752
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --255752NotFullyPicked
               GOTO QUIT
            END
         END

         IF EXISTS (SELECT 1 FROM PACKDETAIL PD (NOLOCK) 
            JOIN PICKHEADER PH (NOLOCK) ON PD.PickSlipNo = PH.PickHeaderKey
            JOIN ORDERS O (NOLOCK) ON PH.ORDERKEY = O.ORDERKEY AND O.SOStatus <> 'CANC'
            WHERE PD.LabelNo = @cPackDtlDropID
            AND PD.QTY > 0)
         AND ISNULL(@cPackDtlDropID ,'') <> ''
         BEGIN
            SET @nErrNo = 255755
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --255755ToDropIDScanned
            GOTO QUIT
         END
      END
      ELSE IF @nStep = 2
      BEGIN
         IF ISNULL(@cPackDtlDropID, '') <> '' AND @cOption = '1'
         BEGIN
            SET @nErrNo = 255756
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --255756Option1NotAllowed
            GOTO QUIT
         END
         IF ISNULL(@cPackDtlDropID, '') = '' AND @cOption <> '1'
         BEGIN
            SET @nErrNo = 255757
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 255757Option23NotAllowed
            GOTO QUIT
         END
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtVal37 TO NSQL
GO
