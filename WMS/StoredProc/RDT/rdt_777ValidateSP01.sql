
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_777ValidateSP01                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Input Qty on step3 is qty in carton not added qty for       */
/*          for LVSUSA                                                  */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2025-11-19 1.0  NickT       FCR-9200 Created                         */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_777ValidateSP01 (
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5)
   ,@cStorerKey      NVARCHAR( 15)
   ,@cType           NVARCHAR( 10)  -- PICKSLIPNO/SKU/QTY
   ,@cPickSlipNo     NVARCHAR( 10)
   ,@cFromDropID     NVARCHAR( 20)
   ,@cPackDtlDropID  NVARCHAR( 20)
   ,@cSKU            NVARCHAR( 20)
   ,@nQTY            INT 
   ,@nCartonNo       INT
   ,@nErrNo          INT   OUTPUT
   ,@cErrMsg         NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL           NVARCHAR(MAX)
   DECLARE @cSQLParam      NVARCHAR(MAX)
   DECLARE @cValidateSP    NVARCHAR(20)


   DECLARE @cPackFilter       NVARCHAR( MAX) = ''
   DECLARE @cPickFilter       NVARCHAR( MAX) = ''
   DECLARE @cOrderKey         NVARCHAR( 10)
   DECLARE @cLoadKey          NVARCHAR( 10)
   DECLARE @cZone             NVARCHAR( 18)
   DECLARE @cPickStatus       NVARCHAR( 20)
   DECLARE @nPackQTY          INT
   DECLARE @nPickQTY          INT
   DECLARE @nPackCartonQTY    INT
   DECLARE @nMPOCFlag         INT
   DECLARE @cPackByFromDropID NVARCHAR( 1)
   DECLARE @cWaveKey          NVARCHAR(10)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)

   SET @cOrderKey = ''
   SET @cLoadKey = ''
   SET @cZone = ''
   SET @nPackQTY = 0
   SET @nPickQTY = 0

   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   
   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   SELECT @nMPOCFlag = V_Integer12
   FROM rdt.rdtMobRec WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SELECT @cWaveKey = WaveKey
   FROM dbo.WaveDetail WITH(NOLOCK)
   WHERE OrderKey = @cOrderKey

   -- Cross dock PickSlip
   IF @cZone IN ('XD', 'LB', 'LP')
   BEGIN
      IF @cType = 'PickSlipNo'
      BEGIN
         -- Check PickSlipNo valid 
         IF NOT EXISTS( SELECT TOP 1 1 FROM dbo.RefKeyLookup RKL WITH (NOLOCK) WHERE RKL.PickSlipNo = @cPickSlipNo)
         BEGIN
            SET @nErrNo = 100351
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO
            GOTO Quit
         END

         -- Check diff storer
         IF EXISTS( SELECT TOP 1 1
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
               JOIN dbo.Orders O WITH (NOLOCK) ON (O.OrderKey = RKL.Orderkey)
            WHERE RKL.PickSlipNo = @cPickSlipNo
               AND O.StorerKey <> @cStorerKey)
         BEGIN
            SET @nErrNo = 100352
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer
            GOTO Quit
         END
      END
      
      ELSE IF @cType = 'SKU'
      BEGIN
         IF @cFromDropID = '' 
         BEGIN
            -- Check SKU in PickSlipNo
            IF NOT EXISTS( SELECT TOP 1 1
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.StorerKey = @cStorerKey
                  AND PD.SKU = @cSKU
                  AND PD.QTY > 0)
            BEGIN
               SET @nErrNo = 100353
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU NotIn PSNO
               EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
               SET @cErrMsg = ''
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            -- Check SKU in DropID
            IF NOT EXISTS( SELECT TOP 1 1
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.StorerKey = @cStorerKey
                  AND PD.SKU = @cSKU
                  AND PD.QTY > 0
                  AND PD.DropID = @cFromDropID)
            BEGIN
               SET @nErrNo = 100369
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKUNotInDropID
               EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
               SET @cErrMsg = ''
               GOTO Quit
            END
         END
      END
      
      ELSE IF @cType = 'QTY'
      BEGIN
         /*
         SELECT @nPickQTY = ISNULL( SUM( QTY), 0)
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
            JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
         WHERE RKL.PickSlipNo = @cPickSlipNo
            AND PD.StorerKey = @cStorerKey
            AND PD.SKU = @cSKU
            AND PD.Status IN (@cPickStatus) 
            AND (@cFromDropID = '' OR PD.DropID = @cFromDropID)
         */      
         SET @cSQL = 
            ' SELECT @nPickQTY = ISNULL( SUM( QTY), 0) ' + 
            ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK) ' + 
               ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) ' + 
            ' WHERE RKL.PickSlipNo = @cPickSlipNo ' + 
               ' AND PD.StorerKey = @cStorerKey ' + 
               ' AND PD.SKU = @cSKU ' + 
               ' AND PD.Status IN (' + @cPickStatus + ') ' + 
               CASE WHEN @cFromDropID <> '' THEN ' AND PD.DropID = @cFromDropID ' ELSE '' END + 
               CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
         SET @cSQLParam = 
            ' @cPickSlipNo NVARCHAR( 10), ' + 
            ' @cStorerKey  NVARCHAR( 15), ' + 
            ' @cSKU        NVARCHAR( 20), ' + 
            ' @cFromDropID NVARCHAR( 20), ' + 
            ' @nPickQTY    INT OUTPUT '
         EXEC sp_executeSQL @cSQL, @cSQLParam
            ,@cPickSlipNo = @cPickSlipNo
            ,@cStorerKey  = @cStorerKey
            ,@cSKU        = @cSKU
            ,@cFromDropID = @cFromDropID
            ,@nPickQTY    = @nPickQTY OUTPUT

         IF @nPackQTY > @nPickQTY
         BEGIN
            SET @nErrNo = 100354
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Over pack
            EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
            SET @cErrMsg = ''
            GOTO Quit
         END
      END
   END

   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
   BEGIN
      IF @cType = 'PickSlipNo'
      BEGIN
         DECLARE @cChkStorerKey NVARCHAR( 15)
         DECLARE @cChkStatus    NVARCHAR( 10)
         DECLARE @cChkSOStatus  NVARCHAR( 10)

         -- Get Order info
         SELECT 
            @cChkStorerKey = StorerKey, 
            @cChkStatus = Status, 
            @cChkSOStatus = SOStatus
         FROM dbo.Orders WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey
         
         -- Check PickSlipNo valid 
         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 100355
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO
            GOTO Quit
         END
         
         -- Check storer
         IF @cChkStorerKey <> @cStorerKey
         BEGIN
            SET @nErrNo = 100357
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer
            GOTO Quit
         END
         
         -- Check order shipped
         IF @cChkStatus > '5'
         BEGIN
            SET @nErrNo = 100356
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Order shipped
            GOTO Quit
         END
         
         -- Check order cancel
         IF @cChkSOStatus = 'CANC'
         BEGIN
            SET @nErrNo = 100368
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Order CANCEL
            GOTO Quit
         END
      END

      ELSE IF @cType = 'SKU'
      BEGIN
         DECLARE @cCaseID     NVARCHAR(20)
         IF @nMPOCFlag <> 1
         BEGIN
            IF NOT EXISTS(SELECT 1 FROM dbo.PickDetail WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND OrderKey = @cOrderKey AND SKU = @cSKU)
            BEGIN
               SET @nErrNo = 251752
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU Not In Order
               GOTO Quit
            END

            IF NOT EXISTS(SELECT 1 FROM dbo.PickDetail WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND OrderKey = @cOrderKey AND SKU = @cSKU AND Status = '5')
            BEGIN
               SET @nErrNo = 251756
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Order is not picked yet
               GOTO Quit
            END

            IF EXISTS(SELECT 1 FROM dbo.PickDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND OrderKey = @cOrderKey
               AND SKU = @cSKU
               AND Status = @cPickConfirmStatus
               AND Qty > 0
               AND LEN(CaseID) < 18)
            BEGIN
               GOTO Quit 
            END
            ELSE
            BEGIN
               SET @nErrNo = 251751
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Order is packed
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            IF EXISTS(SELECT 1 FROM dbo.WaveDetail WD
                     INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON WD.OrderKey = PD.OrderKey
                     WHERE PD.StorerKey = @cStorerKey
                        AND PD.Status = @cPickConfirmStatus
                        AND PD.Qty > 0
                        AND WD.WaveKey = @cWaveKey
                        AND LEN(PD.CaseID) < 18
                        AND PD.SKU = @cSKU)
            BEGIN
               GOTO Quit
            END
            ELSE
            BEGIN
               SET @nErrNo = 251753
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU Not In Wave
               GOTO Quit
            END
         END
      END
      ELSE IF @cType = 'QTY'
      BEGIN
         IF @nMPOCFlag <> 1
         BEGIN
            SELECT @nPickQTY = SUM(Qty)
            FROM dbo.PickDetail WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND OrderKey = @cOrderKey
               AND SKU = @cSKU
               AND Status = @cPickConfirmStatus
               AND Qty > 0
               AND LEN(CaseID) < 18

            IF @nPickQTY < @nQty
            BEGIN
               SET @nErrNo = 251754
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Over Pack
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            SELECT @nPickQTY = SUM(PD.Qty) 
            FROM dbo.WaveDetail WD
            INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON WD.OrderKey = PD.OrderKey
            WHERE PD.StorerKey = @cStorerKey
               AND PD.Status = @cPickConfirmStatus
               AND WD.WaveKey = @cWaveKey
               AND PD.Qty > 0
               AND LEN(PD.CaseID) < 18
               AND PD.SKU = @cSKU

            IF @nPickQTY < @nQty
            BEGIN
               SET @nErrNo = 251755
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Over Pack
               GOTO Quit
            END
         END
      END
   END
               
   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
   BEGIN
      IF @cType = 'PickSlipNo'
      BEGIN
         -- Check PickSlip valid
         IF NOT EXISTS( SELECT TOP 1 1 FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) WHERE LPD.LoadKey = @cLoadKey)
         BEGIN
            SET @nErrNo = 100360
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO
            GOTO Quit
         END
        
         -- Check diff storer
         IF EXISTS( SELECT TOP 1 1 
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
               JOIN dbo.Orders O (NOLOCK) ON (LPD.OrderKey = O.OrderKey)    
            WHERE LPD.LoadKey = @cLoadKey
               AND O.StorerKey <> @cStorerKey)
         BEGIN
            SET @nErrNo = 100361
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer
            GOTO Quit
         END
      END
      
      ELSE IF @cType = 'SKU'
      BEGIN
         IF @cFromDropID = '' 
         BEGIN
            -- Check SKU in PickSlipNo
            IF NOT EXISTS( SELECT TOP 1 1 
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.StorerKey = @cStorerKey
                  AND PD.SKU = @cSKU
                  AND PD.QTY > 0)
            BEGIN
               SET @nErrNo = 100362
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU NotIn PSNO
               EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
               SET @cErrMsg = ''
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            -- Check SKU in PickSlipNo
            IF NOT EXISTS( SELECT TOP 1 1 
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
                  JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
               WHERE LPD.LoadKey = @cLoadKey
                  AND PD.StorerKey = @cStorerKey
                  AND PD.SKU = @cSKU
                  AND PD.QTY > 0
                  AND PD.DropID = @cFromDropID)
            BEGIN
               SET @nErrNo = 100371
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKUNotInDropID
               EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
               SET @cErrMsg = ''
               GOTO Quit
            END
         END
      END
      
      ELSE IF @cType = 'QTY'
      BEGIN
         /*
         SELECT @nPickQTY = ISNULL( SUM( QTY), 0)
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
            JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
         WHERE LPD.LoadKey = @cLoadKey
            AND PD.StorerKey = @cStorerKey
            AND PD.SKU = @cSKU
            AND PD.Status IN (@cPickStatus) 
            AND (@cFromDropID = '' OR PD.DropID = @cFromDropID)
         */
         SET @cSQL = 
            ' SELECT @nPickQTY = ISNULL( SUM( QTY), 0) ' +
            ' FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' + 
               ' JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' +
            ' WHERE LPD.LoadKey = @cLoadKey ' +
               ' AND PD.StorerKey = @cStorerKey ' +
               ' AND PD.SKU = @cSKU ' +
               ' AND PD.Status IN (' + @cPickStatus + ') ' + 
               CASE WHEN @cFromDropID <> '' THEN ' AND PD.DropID = @cFromDropID ' ELSE '' END + 
               CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
         SET @cSQLParam = 
            ' @cLoadKey    NVARCHAR( 10), ' + 
            ' @cStorerKey  NVARCHAR( 15), ' + 
            ' @cSKU        NVARCHAR( 20), ' + 
            ' @cFromDropID NVARCHAR( 20), ' + 
            ' @nPickQTY    INT OUTPUT '
         EXEC sp_executeSQL @cSQL, @cSQLParam
            ,@cLoadKey    = @cLoadKey
            ,@cStorerKey  = @cStorerKey
            ,@cSKU        = @cSKU
            ,@cFromDropID = @cFromDropID
            ,@nPickQTY    = @nPickQTY OUTPUT
         
         IF @nPackQTY > @nPickQTY
         BEGIN
            SET @nErrNo = 100363
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Over pack
            EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
            SET @cErrMsg = ''
            GOTO Quit
         END
      END
   END
   
   -- Custom PickSlip
   ELSE
   BEGIN
      IF @cType = 'PickSlipNo'
      BEGIN
         -- Check PickSlip valid 
         IF NOT EXISTS( SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
         BEGIN
            SET @nErrNo = 100364
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO
            GOTO Quit
         END

         -- Check diff storer
         IF EXISTS( SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND StorerKey <> @cStorerKey)
         BEGIN
            SET @nErrNo = 100365
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer
            GOTO Quit
         END
      END

      ELSE IF @cType = 'SKU'
      BEGIN
         IF @cFromDropID = '' 
         BEGIN
            -- Check SKU in PickSlipNo
            IF NOT EXISTS( SELECT TOP 1 1 
               FROM dbo.PickDetail PD (NOLOCK) 
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.StorerKey = @cStorerKey
                  AND PD.SKU = @cSKU
                  AND PD.QTY > 0)
            BEGIN
               SET @nErrNo = 100366
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU NotIn PSNO
               EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
               SET @cErrMsg = ''
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            -- Check SKU in PickSlipNo
            IF NOT EXISTS( SELECT TOP 1 1 
               FROM dbo.PickDetail PD (NOLOCK) 
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.StorerKey = @cStorerKey
                  AND PD.SKU = @cSKU
                  AND PD.QTY > 0
                  AND PD.DropID = @cFromDropID)
            BEGIN
               SET @nErrNo = 100372
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKUNotInDropID
               EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
               SET @cErrMsg = ''
               GOTO Quit
            END
         END
      END
      
      ELSE IF @cType = 'QTY'
      BEGIN
         /*
         SELECT @nPickQTY = ISNULL( SUM( QTY), 0)
         FROM dbo.PickDetail PD (NOLOCK) 
         WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.StorerKey = @cStorerKey
            AND PD.SKU = @cSKU
            AND PD.Status IN (@cPickStatus)
            AND (@cFromDropID = '' OR PD.DropID = @cFromDropID)
         */
         SET @cSQL = 
            ' SELECT @nPickQTY = ISNULL( SUM( QTY), 0) ' + 
            ' FROM dbo.PickDetail PD (NOLOCK) ' + 
            ' WHERE PD.PickSlipNo = @cPickSlipNo ' + 
               ' AND PD.StorerKey = @cStorerKey ' + 
               ' AND PD.SKU = @cSKU ' + 
               ' AND PD.Status IN (' + @cPickStatus + ') ' + 
               CASE WHEN @cFromDropID <> '' THEN ' AND PD.DropID = @cFromDropID ' ELSE '' END + 
               CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
         SET @cSQLParam = 
            ' @cPickSlipNo NVARCHAR( 10), ' + 
            ' @cStorerKey  NVARCHAR( 15), ' + 
            ' @cSKU        NVARCHAR( 20), ' + 
            ' @cFromDropID NVARCHAR( 20), ' + 
            ' @nPickQTY    INT OUTPUT '
         EXEC sp_executeSQL @cSQL, @cSQLParam
            ,@cPickSlipNo = @cPickSlipNo
            ,@cStorerKey  = @cStorerKey
            ,@cSKU        = @cSKU
            ,@cFromDropID = @cFromDropID
            ,@nPickQTY    = @nPickQTY OUTPUT
         
         IF @nPackQTY > @nPickQTY
         BEGIN
            SET @nErrNo = 100367
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Over pack
            EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
            SET @cErrMsg = ''
            GOTO Quit
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

GRANT EXECUTE ON RDT.rdt_777ValidateSP01 TO NSQL
GO
