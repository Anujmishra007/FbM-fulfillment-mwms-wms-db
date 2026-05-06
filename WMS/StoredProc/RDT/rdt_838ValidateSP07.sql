
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_838ValidateSP07                                  */
/* Copyright      : Maersk                                               */
/*                                                                       */
/* Date       Rev  Author      Purposes                                  */
/* 2026-03-27 1.0  Dennis      FCR-7820 Created                          */
/*                             Validate based on rdtPickLog scanned      */
/*                             DropIDs or PickSlipNo                     */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838ValidateSP07 (
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
   DECLARE @cPackFilter    NVARCHAR(MAX) = ''
   DECLARE @cPickFilter    NVARCHAR(MAX) = ''
   DECLARE @cOrderKey      NVARCHAR(10)
   DECLARE @cLoadKey       NVARCHAR(10)
   DECLARE @cZone          NVARCHAR(18)
   DECLARE @cPickStatus    NVARCHAR(20)
   DECLARE @nPackQTY       INT
   DECLARE @nPickQTY       INT
   DECLARE @cPackByFromDropID NVARCHAR(1)
   DECLARE @nDropIDCount   INT = 0

   SET @cOrderKey = ''
   SET @cLoadKey = ''
   SET @cZone = ''
   SET @nPackQTY = 0
   SET @nPickQTY = 0

   -- Check if any DropID scanned in rdtPickLog
   SELECT @nDropIDCount = COUNT(DISTINCT DropID)
   FROM RDT.rdtPickLog WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND Mobile = @nMobile
      AND Status = '0'

   /***********************************************************************************************
                                    Validate based on rdtPickLog DropIDs
   ***********************************************************************************************/
   IF @nDropIDCount > 0
   BEGIN
      -- Get PickHeader info from first scanned DropID
      SELECT TOP 1
         @cOrderKey = PH.OrderKey,
         @cLoadKey = PH.ExternOrderKey,
         @cZone = PH.Zone
      FROM RDT.rdtPickLog PL WITH (NOLOCK)
      JOIN dbo.PickHeader PH WITH (NOLOCK) ON PH.OrderKey = PL.OrderKey
      WHERE PL.StorerKey = @cStorerKey
         AND PL.Mobile = @nMobile
         AND PL.Status = '0'

      -- Check QTY
      IF @cType = 'QTY'
      BEGIN
         -- Get storer config
         SET @cPackByFromDropID = rdt.rdtGetConfig( @nFunc, 'PackByFromDropID', @cStorerKey)
         SET @cPickStatus = rdt.rdtGetConfig( @nFunc, 'PickStatus', @cStorerKey)

         -- Add default PickStatus 5-picked, if not specified
         IF CHARINDEX( '5', @cPickStatus) = 0
            SET @cPickStatus += ',5'

         -- Make PickStatus into comma delimeted, quoted string
         SELECT @cPickStatus = STRING_AGG( QUOTENAME( a.value, ''''), ',')
         FROM
         (
            SELECT TRIM( value) value FROM STRING_SPLIT( @cPickStatus, ',') WHERE value <> ''
         ) a

         -- Get pick filter
         SELECT @cPickFilter = ISNULL( Long, '')
         FROM CodeLKUP WITH (NOLOCK)
         WHERE ListName = 'PickFilter'
            AND Code = @nFunc
            AND StorerKey = @cStorerKey
            AND Code2 = @cFacility

         -- Get pack filter
         SELECT @cPackFilter = ISNULL( Long, '')
         FROM CodeLKUP WITH (NOLOCK)
         WHERE ListName = 'PackFilter'
            AND Code = @nFunc
            AND StorerKey = @cStorerKey
            AND Code2 = @cFacility

         -- Calc pack QTY from all scanned DropIDs using PackSerialNo
         SET @cSQL =
            ' SELECT @nPackQTY = ISNULL( COUNT(*), 0) ' +
            ' FROM PackSerialNo PS WITH (NOLOCK) ' +
            ' JOIN RDT.rdtPickLog PL WITH (NOLOCK) ON PS.PickDetailKey = PL.PickDetailKey ' +
            ' WHERE PS.StorerKey = @cStorerKey ' +
               ' AND PS.SKU = @cSKU '  +
               ' AND PL.Mobile = @nMobile ' +
               ' AND PL.Status = ''0'' ' +
               CASE WHEN @cPackFilter <> '' THEN @cPackFilter ELSE '' END
         SET @cSQLParam =
            ' @cStorerKey  NVARCHAR( 15), ' +
            ' @cSKU        NVARCHAR( 20), ' +
            ' @nMobile     INT, ' +
            ' @nPackQTY    INT OUTPUT '
         EXEC sp_executeSQL @cSQL, @cSQLParam
            ,@cStorerKey  = @cStorerKey
            ,@cSKU        = @cSKU
            ,@nMobile     = @nMobile
            ,@nPackQTY    = @nPackQTY OUTPUT

         -- Add QTY
         SET @nPackQTY = @nPackQTY + @nQTY

         -- Calc pick QTY from all scanned DropIDs in rdtPickLog
         SET @cSQL =
            ' SELECT @nPickQTY = ISNULL( SUM( PD.QTY), 0) ' +
            ' FROM dbo.PickDetail PD WITH (NOLOCK) ' +
            ' JOIN RDT.rdtPickLog PL WITH (NOLOCK) ON PD.PickDetailKey = PL.PickDetailKey' +
            ' WHERE PD.StorerKey = @cStorerKey ' +
               ' AND PD.SKU = @cSKU ' +
               ' AND PD.Status IN (' + @cPickStatus + ') ' +
               ' AND PL.Mobile = @nMobile ' +
               ' AND PL.Status = ''0'' ' +
               CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
         SET @cSQLParam =
            ' @cStorerKey  NVARCHAR( 15), ' +
            ' @cSKU        NVARCHAR( 20), ' +
            ' @nMobile     INT, ' +
            ' @nPickQTY    INT OUTPUT '
         EXEC sp_executeSQL @cSQL, @cSQLParam
            ,@cStorerKey  = @cStorerKey
            ,@cSKU        = @cSKU
            ,@nMobile     = @nMobile
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

      ELSE IF @cType = 'SKU'
      BEGIN
         -- Check SKU exists in scanned DropIDs
         IF NOT EXISTS(
            SELECT TOP 1 1
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN RDT.rdtPickLog PL WITH (NOLOCK) ON PD.DropID = PL.DropID AND PD.StorerKey = PL.StorerKey
            WHERE PD.StorerKey = @cStorerKey
               AND PD.SKU = @cSKU
               AND PD.QTY > 0
               AND PL.Mobile = @nMobile
               AND PL.Status = '0'
         )
         BEGIN
            SET @nErrNo = 100370
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKUNotInDropID
            EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
            SET @cErrMsg = ''
            GOTO Quit
         END
      END

      ELSE IF @cType = 'PICKSLIPNO'
      BEGIN
         -- Check PickSlipNo matches scanned DropIDs
         IF NOT EXISTS(
            SELECT TOP 1 1
            FROM RDT.rdtPickLog PL WITH (NOLOCK)
            WHERE PL.StorerKey = @cStorerKey
               AND PL.Mobile = @nMobile
               AND PL.Status = '0'
               AND PL.PickSlipNo = @cPickSlipNo
         )
         BEGIN
            -- Allow if PickSlipNo is derived from scanned DropIDs
            IF NOT EXISTS(
               SELECT TOP 1 1
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN RDT.rdtPickLog PL WITH (NOLOCK) ON PD.DropID = PL.DropID AND PD.StorerKey = PL.StorerKey
               WHERE PD.StorerKey = @cStorerKey
                  AND PL.Mobile = @nMobile
                  AND PL.Status = '0'
                  AND PD.PickSlipNo = @cPickSlipNo
            )
            BEGIN
               SET @nErrNo = 100355
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO
               GOTO Quit
            END
         END

         -- Check diff storer
         IF EXISTS(
            SELECT TOP 1 1
            FROM RDT.rdtPickLog PL WITH (NOLOCK)
            WHERE PL.Mobile = @nMobile
               AND PL.Status = '0'
               AND PL.StorerKey <> @cStorerKey
         )
         BEGIN
            SET @nErrNo = 100357
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer
            GOTO Quit
         END
      END

      GOTO Quit
   END

   /***********************************************************************************************
                              Validate based on PickSlipNo (no DropID scanned)
   ***********************************************************************************************/
   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   -- Check QTY
   IF @cType = 'QTY'
   BEGIN
      -- Get storer config
      SET @cPackByFromDropID = rdt.rdtGetConfig( @nFunc, 'PackByFromDropID', @cStorerKey)
      SET @cPickStatus = rdt.rdtGetConfig( @nFunc, 'PickStatus', @cStorerKey)

      -- Add default PickStatus 5-picked, if not specified
      IF CHARINDEX( '5', @cPickStatus) = 0
         SET @cPickStatus += ',5'

      -- Make PickStatus into comma delimeted, quoted string
      SELECT @cPickStatus = STRING_AGG( QUOTENAME( a.value, ''''), ',')
      FROM
      (
         SELECT TRIM( value) value FROM STRING_SPLIT( @cPickStatus, ',') WHERE value <> ''
      ) a

      -- Get pick filter
      SELECT @cPickFilter = ISNULL( Long, '')
      FROM CodeLKUP WITH (NOLOCK)
      WHERE ListName = 'PickFilter'
         AND Code = @nFunc
         AND StorerKey = @cStorerKey
         AND Code2 = @cFacility

      -- Get pack filter
      SELECT @cPackFilter = ISNULL( Long, '')
      FROM CodeLKUP WITH (NOLOCK)
      WHERE ListName = 'PackFilter'
         AND Code = @nFunc
         AND StorerKey = @cStorerKey
         AND Code2 = @cFacility

      -- Calc pack QTY
      SET @nPackQTY = 0
      SET @cSQL =
         ' SELECT @nPackQTY = ISNULL( SUM( PD.QTY), 0) ' +
         ' FROM PackDetail PD WITH (NOLOCK) ' +
         ' WHERE PD.PickSlipNo = @cPickSlipNo ' +
            ' AND PD.StorerKey = @cStorerKey ' +
            ' AND PD.SKU = @cSKU '  +
            CASE WHEN @cFromDropID <> '' AND @cPackByFromDropID = '1' THEN ' AND PD.DropID = @cFromDropID ' ELSE '' END +
            CASE WHEN @cPackFilter <> '' THEN @cPackFilter ELSE '' END
      SET @cSQLParam =
         ' @cPickSlipNo NVARCHAR( 10), ' +
         ' @cStorerKey  NVARCHAR( 15), ' +
         ' @cSKU        NVARCHAR( 20), ' +
         ' @cFromDropID NVARCHAR( 20), ' +
         ' @nPackQTY    INT OUTPUT '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@cPickSlipNo = @cPickSlipNo
         ,@cStorerKey  = @cStorerKey
         ,@cSKU        = @cSKU
         ,@cFromDropID = @cFromDropID
         ,@nPackQTY    = @nPackQTY OUTPUT

      -- Add QTY
      SET @nPackQTY = @nPackQTY + @nQTY
   END

   -- Discrete PickSlip
   IF @cOrderKey <> ''
   BEGIN
      IF @cType = 'PICKSLIPNO'
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
         -- Check SKU in PickSlipNo
         IF NOT EXISTS( SELECT TOP 1 1
            FROM dbo.PickDetail PD WITH (NOLOCK)
            WHERE PD.OrderKey = @cOrderKey
               AND PD.StorerKey = @cStorerKey
               AND PD.SKU = @cSKU
               AND PD.QTY > 0)
         BEGIN
            SET @nErrNo = 100358
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU NotIn PSNO
            EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
            SET @cErrMsg = ''
            GOTO Quit
         END
      END

      ELSE IF @cType = 'QTY'
      BEGIN
         SET @cSQL =
            ' SELECT @nPickQTY = ISNULL( SUM( QTY), 0) ' +
            ' FROM dbo.PickDetail PD WITH (NOLOCK) ' +
            ' WHERE PD.OrderKey = @cOrderKey ' +
               ' AND PD.StorerKey = @cStorerKey ' +
               ' AND PD.SKU = @cSKU ' +
               ' AND PD.Status IN (' + @cPickStatus + ') ' +
               CASE WHEN @cFromDropID <> '' THEN ' AND PD.DropID = @cFromDropID ' ELSE '' END +
               CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
         SET @cSQLParam =
            ' @cOrderKey   NVARCHAR( 10), ' +
            ' @cStorerKey  NVARCHAR( 15), ' +
            ' @cSKU        NVARCHAR( 20), ' +
            ' @cFromDropID NVARCHAR( 20), ' +
            ' @nPickQTY    INT OUTPUT '
         EXEC sp_executeSQL @cSQL, @cSQLParam
            ,@cOrderKey   = @cOrderKey
            ,@cStorerKey  = @cStorerKey
            ,@cSKU        = @cSKU
            ,@cFromDropID = @cFromDropID
            ,@nPickQTY    = @nPickQTY OUTPUT

         IF @nPackQTY > @nPickQTY
         BEGIN
            SET @nErrNo = 100359
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Over pack
            EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', '', @nErrNo, @cErrMsg
            SET @cErrMsg = ''
            GOTO Quit
         END
      END
   END

   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
   BEGIN
      IF @cType = 'PICKSLIPNO'
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

      ELSE IF @cType = 'QTY'
      BEGIN
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
      IF @cType = 'PICKSLIPNO'
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

      ELSE IF @cType = 'QTY'
      BEGIN
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

GRANT EXECUTE ON RDT.rdt_838ValidateSP07 TO NSQL
GO
