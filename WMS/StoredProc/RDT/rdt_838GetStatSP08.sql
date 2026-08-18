SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************************/
/* Store procedure: rdt_838GetStatSP08                                                 */
/* Copyright      : Maersk.                                                            */
/* Customer       : AEOMX                                                              */
/*                                                                                     */
/* Date       Rev  Author      Purposes                                                */
/* 2027-07-09 1.0  NickT       FCR-14763 Created, do not return LabelNo for B2C Single */
/***************************************************************************************/

CREATE OR ALTER PROC rdt.rdt_838GetStatSP08 (
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5)
   ,@cStorerKey      NVARCHAR( 15)
   ,@cType           NVARCHAR( 10)  -- CURRENT/NEXT
   ,@cPickSlipNo     NVARCHAR( 10)
   ,@cFromDropID     NVARCHAR( 20)
   ,@cPackDtlDropID  NVARCHAR( 20)
   ,@nCartonNo       INT            OUTPUT
   ,@cLabelNo        NVARCHAR( 20)  OUTPUT
   ,@cCustomNo       NVARCHAR( 5)   OUTPUT
   ,@cCustomID       NVARCHAR( 20)  OUTPUT
   ,@nCartonSKU      INT            OUTPUT
   ,@nCartonQTY      INT            OUTPUT
   ,@nTotalCarton    INT            OUTPUT
   ,@nTotalPick      INT            OUTPUT
   ,@nTotalPack      INT            OUTPUT
   ,@nTotalShort     INT            OUTPUT
   ,@nErrNo          INT            OUTPUT
   ,@cErrMsg         NVARCHAR(250)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cSQL           NVARCHAR(MAX)
   DECLARE @cSQLParam      NVARCHAR(MAX)
   DECLARE @cGetStatSP     NVARCHAR(20)

   /***********************************************************************************************
                                             Standard GetStat
   ***********************************************************************************************/
   DECLARE @cPackFilter NVARCHAR( MAX) = ''
   DECLARE @cPickFilter NVARCHAR( MAX) = ''
   DECLARE @cOrderKey   NVARCHAR( 10)
   DECLARE @cLoadKey    NVARCHAR( 10)
   DECLARE @cZone       NVARCHAR( 18)
   DECLARE @cDropID     NVARCHAR( 20)
   DECLARE @cRefNo      NVARCHAR( 20)
   DECLARE @cRefNo2     NVARCHAR( 30)
   DECLARE @cPickStatus NVARCHAR( 1)
   DECLARE @cWaveKey    NVARCHAR( 10)
   DECLARE @cWaveType   NVARCHAR( 20)
   DECLARE @cOrderType  NVARCHAR( 10)
   DECLARE @nRowCount   INT = 0

   SET @cOrderKey = ''
   SET @cLoadKey = ''
   SET @cZone = ''

   SET @cPickStatus = rdt.RDTGetConfig( @nFunc, 'PickStatus', @cStorerKey)
   IF @cPickStatus = '0'
      SET @cPickStatus = '5'

   SELECT TOP 1 
      @cWaveKey = ISNULL(WaveKey, '')
   FROM dbo.PickDetail WITH (NOLOCK)
      WHERE DropID = @cFromDropID
         AND StorerKey = @cStorerKey
         AND Status = @cPickStatus
         AND Qty > 0
         AND CHARINDEX('[PACKED]', ISNULL(NOTES, '')) = 0

   SELECT
      @cWaveType = ISNULL(UserDefine03, ''),
      @cOrderType = ISNULL(UserDefine05, '')
   FROM dbo.Wave WITH (NOLOCK)
      WHERE WaveKey = @cWaveKey

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   -- Get pick filter
   SELECT @cPickFilter = ISNULL( Long, '')
   FROM dbo.CodeLKUP WITH (NOLOCK) 
   WHERE ListName = 'PickFilter'
      AND Code = @nFunc 
      AND StorerKey = @cStorerKey
      AND Code2 = @cFacility

   -- Get pack filter
   SELECT @cPackFilter = ISNULL( Long, '')
   FROM dbo.CodeLKUP WITH (NOLOCK) 
   WHERE ListName = 'PackFilter'
      AND Code = @nFunc 
      AND StorerKey = @cStorerKey
      AND Code2 = @cFacility

   /***********************************************************************************************
                                                PackDetail
   ***********************************************************************************************/
   /*
   SELECT @nTotalPack = ISNULL( SUM( PD.QTY), 0)
   FROM dbo.PackDetail PD WITH (NOLOCK)
   WHERE PD.PickSlipNo = @cPickSlipNo
   */
   SET @cSQL = 
      ' SELECT @nTotalPack = ISNULL( SUM( PD.QTY), 0) ' + 
      ' FROM dbo.PackDetail PD WITH (NOLOCK) ' + 
      ' WHERE PD.PickSlipNo = @cPickSlipNo ' + 
         CASE WHEN @cPackFilter <> '' THEN @cPackFilter ELSE '' END
   SET @cSQLParam = 
      ' @cPickSlipNo NVARCHAR( 10), ' + 
      ' @nTotalPack  INT OUTPUT '
   EXEC sp_executeSQL @cSQL, @cSQLParam
      ,@cPickSlipNo = @cPickSlipNo
      ,@nTotalPack  = @nTotalPack OUTPUT

   /*
   SELECT @nTotalCarton = COUNT( DISTINCT PD.LabelNo)
   FROM dbo.PackDetail PD WITH (NOLOCK)
   WHERE PD.PickSlipNo = @cPickSlipNo
   */
   SET @cSQL = 
      ' SELECT @nTotalCarton = COUNT( DISTINCT PD.LabelNo) ' + 
      ' FROM dbo.PackDetail PD WITH (NOLOCK) ' + 
      ' WHERE PD.PickSlipNo = @cPickSlipNo ' + 
         CASE WHEN @cPackFilter <> '' THEN @cPackFilter ELSE '' END
   SET @cSQLParam = 
      ' @cPickSlipNo  NVARCHAR( 10), ' + 
      ' @nTotalCarton INT OUTPUT '
   EXEC sp_executeSQL @cSQL, @cSQLParam
      ,@cPickSlipNo  = @cPickSlipNo
      ,@nTotalCarton = @nTotalCarton OUTPUT
   
   IF @cType = 'CURRENT'
   BEGIN
      /*
      SELECT TOP 1 
         @nCartonNo = CartonNo, 
         @cLabelNo = LabelNo, 
         @cDropID = DropID, 
         @cRefNo = RefNo, 
         @cRefNo2 = RefNo2
      FROM dbo.PackDetail PD WITH (NOLOCK)
      WHERE PD.PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
      ORDER BY CartonNo
      */
      SET @cSQL = 
         ' SELECT TOP 1 ' + 
            ' @nCartonNo = CartonNo, ' + 
            ' @cLabelNo = LabelNo, ' + 
            ' @cDropID = DropID, ' + 
            ' @cRefNo = RefNo, ' + 
            ' @cRefNo2 = RefNo2 ' + 
         ' FROM dbo.PackDetail PD WITH (NOLOCK) ' + 
         ' WHERE PD.PickSlipNo = @cPickSlipNo ' + 
            ' AND CartonNo = @nCartonNo ' + 
              CASE WHEN @cPackFilter <> '' THEN @cPackFilter ELSE '' END + 
         ' ORDER BY CartonNo ' 
      SET @cSQLParam = 
         ' @nCartonNo   INT           OUTPUT, ' + 
         ' @cLabelNo    NVARCHAR( 20) OUTPUT, ' + 
         ' @cDropID     NVARCHAR( 20) OUTPUT, ' + 
         ' @cRefNo      NVARCHAR( 20) OUTPUT, ' + 
         ' @cRefNo2     NVARCHAR( 30) OUTPUT, ' + 
         ' @cPickSlipNo NVARCHAR( 10) '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@nCartonNo   = @nCartonNo OUTPUT
         ,@cLabelNo    = @cLabelNo  OUTPUT
         ,@cDropID     = @cDropID   OUTPUT
         ,@cRefNo      = @cRefNo    OUTPUT
         ,@cRefNo2     = @cRefNo2   OUTPUT
         ,@cPickSlipNo = @cPickSlipNo
   END
   
   IF @cType = 'NEXT'
   BEGIN
      -- for B2C Single, no need to return carton info, just return 0
      IF ISNULL(@cWaveType, '') = 'ECOM' AND ISNULL(@cOrderType, '') = 'S'
      BEGIN
         SET @nCartonNo       = 0
         SET @cLabelNo        = ''
         SET @cCustomNo       = ''
         SET @cCustomID       = ''
         SET @nCartonSKU      = 0
         SET @nCartonQTY      = 0
         SET @nTotalCarton    = 0
         SET @nTotalPick      = 0
         SET @nTotalPack      = 0
         SET @nTotalShort     = 0
         RETURN
      END
      /*
      SELECT TOP 1 
         @nCartonNo = CartonNo, 
         @cLabelNo = LabelNo, 
         @cDropID = DropID, 
         @cRefNo = RefNo, 
         @cRefNo2 = RefNo2
      FROM dbo.PackDetail PD WITH (NOLOCK)
      WHERE PD.PickSlipNo = @cPickSlipNo
         AND CartonNo > @nCartonNo
      ORDER BY CartonNo
      */
      SET @nRowCount = 0
      SET @cSQL = 
         ' SELECT TOP 1 ' + 
            ' @nCartonNo = CartonNo, ' + 
            ' @cLabelNo = LabelNo, ' + 
            ' @cDropID = DropID, ' + 
            ' @cRefNo = RefNo, ' + 
            ' @cRefNo2 = RefNo2 ' + 
         ' FROM dbo.PackDetail PD WITH (NOLOCK) ' + 
         ' WHERE PD.PickSlipNo = @cPickSlipNo ' + 
            ' AND CartonNo > @nCartonNo ' + 
              CASE WHEN @cPackFilter <> '' THEN @cPackFilter ELSE '' END + 
         ' ORDER BY CartonNo ' + 
         ' SET @nRowCount = @@ROWCOUNT '
      SET @cSQLParam = 
         ' @nCartonNo   INT           OUTPUT, ' + 
         ' @cLabelNo    NVARCHAR( 20) OUTPUT, ' + 
         ' @cDropID     NVARCHAR( 20) OUTPUT, ' + 
         ' @cRefNo      NVARCHAR( 20) OUTPUT, ' + 
         ' @cRefNo2     NVARCHAR( 30) OUTPUT, ' + 
         ' @nRowCount   INT           OUTPUT, ' + 
         ' @cPickSlipNo NVARCHAR( 10) '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@nCartonNo   = @nCartonNo OUTPUT
         ,@cLabelNo    = @cLabelNo  OUTPUT
         ,@cDropID     = @cDropID   OUTPUT
         ,@cRefNo      = @cRefNo    OUTPUT
         ,@cRefNo2     = @cRefNo2   OUTPUT
         ,@nRowCount   = @nRowCount OUTPUT
         ,@cPickSlipNo = @cPickSlipNo
   
      --IF @@ROWCOUNT = 0
      IF @nRowCount = 0
      BEGIN
         /*
         SELECT TOP 1 
            @nCartonNo = CartonNo, 
            @cLabelNo = LabelNo, 
            @cDropID = DropID, 
            @cRefNo = RefNo, 
            @cRefNo2 = RefNo2
         FROM dbo.PackDetail PD WITH (NOLOCK)
         WHERE PD.PickSlipNo = @cPickSlipNo
         ORDER BY CartonNo   
         */
         SET @nRowCount = 0
         SET @cSQL = 
            ' SELECT TOP 1 ' + 
               ' @nCartonNo = CartonNo, ' + 
               ' @cLabelNo = LabelNo, ' + 
               ' @cDropID = DropID, ' + 
               ' @cRefNo = RefNo, ' + 
               ' @cRefNo2 = RefNo2 ' + 
            ' FROM dbo.PackDetail PD WITH (NOLOCK) ' + 
            ' WHERE PD.PickSlipNo = @cPickSlipNo ' + 
                 CASE WHEN @cPackFilter <> '' THEN @cPackFilter ELSE '' END + 
            ' ORDER BY CartonNo ' + 
            ' SET @nRowCount = @@ROWCOUNT '
         SET @cSQLParam = 
            ' @nCartonNo   INT           OUTPUT, ' + 
            ' @cLabelNo    NVARCHAR( 20) OUTPUT, ' + 
            ' @cDropID     NVARCHAR( 20) OUTPUT, ' + 
            ' @cRefNo      NVARCHAR( 20) OUTPUT, ' + 
            ' @cRefNo2     NVARCHAR( 30) OUTPUT, ' + 
            ' @nRowCount   INT           OUTPUT, ' + 
            ' @cPickSlipNo NVARCHAR( 10) ' 
         EXEC sp_executeSQL @cSQL, @cSQLParam
            ,@nCartonNo   = @nCartonNo OUTPUT
            ,@cLabelNo    = @cLabelNo  OUTPUT
            ,@cDropID     = @cDropID   OUTPUT
            ,@cRefNo      = @cRefNo    OUTPUT
            ,@cRefNo2     = @cRefNo2   OUTPUT
            ,@nRowCount   = @nRowCount OUTPUT
            ,@cPickSlipNo = @cPickSlipNo   

         --IF @@ROWCOUNT = 0
         IF @nRowCount = 0
            SELECT 
               @nCartonNo = 0, 
               @cLabelNo = '', 
               @cDropID = '', 
               @cRefNo = '', 
               @cRefNo2 = ''
      END
   END
   
   SELECT 
      @nCartonSKU = COUNT( DISTINCT PD.SKU), 
      @nCartonQTY = ISNULL( SUM( PD.QTY), 0)
   FROM dbo.PackDetail PD WITH (NOLOCK)
   WHERE PD.PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND LabelNo = @cLabelNo

   -- Storer configure
   DECLARE @cCustomCartonNo NVARCHAR(1)
   DECLARE @cCustomCartonID NVARCHAR(1)
   SET @cCustomCartonNo = rdt.rdtGetConfig( @nFunc, 'CustomCartonNo', @cStorerKey)
   SET @cCustomCartonID = rdt.rdtGetConfig( @nFunc, 'CustomCartonID', @cStorerKey)
   
   -- Get customm carton no / label no
   SELECT 
      @cCustomNo = 
         CASE @cCustomCartonNo 
            WHEN '1' THEN LEFT( @cDropID, 5)
            WHEN '2' THEN LEFT( @cRefNo, 5)
            WHEN '3' THEN LEFT( @cRefNo2, 5)
            ELSE CAST( @nCartonNo AS NVARCHAR(5))
         END, 
      @cCustomID = 
         CASE @cCustomCartonID 
            WHEN '1' THEN @cDropID
            WHEN '2' THEN @cRefNo
            WHEN '3' THEN LEFT( @cRefNo2, 20)
            ELSE @cLabelNo
         END
   
   IF @cCustomNo = ''
      SET @cCustomNo = '0'

   /***********************************************************************************************
                                                PickDetail
   ***********************************************************************************************/
   -- Cross dock PickSlip
   IF @cZone IN ('XD', 'LB', 'LP')
   BEGIN
      /*
      SELECT @nTotalPick = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
         JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
      WHERE RKL.PickSlipNo = @cPickSlipNo
         AND PD.Status <= '5'
         AND PD.Status <> '4'
      */
      SET @cSQL = 
         ' SELECT @nTotalPick = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK) ' + 
            ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) ' + 
         ' WHERE RKL.PickSlipNo = @cPickSlipNo ' + 
            ' AND PD.Status <= ''5'' ' + 
            ' AND PD.Status <> ''4'' ' + 
            CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
      SET @cSQLParam = 
         ' @cPickSlipNo NVARCHAR( 10), ' + 
         ' @nTotalPick  INT OUTPUT '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@cPickSlipNo = @cPickSlipNo
         ,@nTotalPick  = @nTotalPick OUTPUT
      
      /*
      SELECT @nTotalShort = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
         JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
      WHERE RKL.PickSlipNo = @cPickSlipNo
         AND PD.Status = '4'
      */
      SET @cSQL = 
         ' SELECT @nTotalShort = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK) ' + 
            ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) ' + 
         ' WHERE RKL.PickSlipNo = @cPickSlipNo ' + 
            ' AND PD.Status = ''4'' ' + 
            CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
      SET @cSQLParam = 
         ' @cPickSlipNo NVARCHAR( 10), ' + 
         ' @nTotalShort  INT OUTPUT '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@cPickSlipNo = @cPickSlipNo
         ,@nTotalShort = @nTotalShort OUTPUT
   END

   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
   BEGIN
      /*
      SELECT @nTotalPick = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.PickDetail PD WITH (NOLOCK)
      WHERE PD.OrderKey = @cOrderKey
         AND PD.Status <= '5'
         AND PD.Status <> '4'
      */
      SET @cSQL = 
         ' SELECT @nTotalPick = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.PickDetail PD WITH (NOLOCK) ' + 
         ' WHERE PD.OrderKey = @cOrderKey ' + 
            ' AND PD.Status <= ''5'' ' + 
            ' AND PD.Status <> ''4'' ' + 
            CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
      SET @cSQLParam = 
         ' @cOrderKey   NVARCHAR( 10), ' + 
         ' @nTotalPick  INT OUTPUT '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@cOrderKey   = @cOrderKey
         ,@nTotalPick  = @nTotalPick OUTPUT
      
      /*
      SELECT @nTotalShort = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.PickDetail PD WITH (NOLOCK)
      WHERE PD.OrderKey = @cOrderKey
         AND PD.Status = '4'
      */
      SET @cSQL = 
         ' SELECT @nTotalShort = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.PickDetail PD WITH (NOLOCK) ' + 
         ' WHERE PD.OrderKey = @cOrderKey ' + 
            ' AND PD.Status = ''4'' ' + 
            CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
      SET @cSQLParam = 
         ' @cOrderKey    NVARCHAR( 10), ' + 
         ' @nTotalShort  INT OUTPUT '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@cOrderKey   = @cOrderKey
         ,@nTotalShort = @nTotalShort OUTPUT
   END
               
   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
   BEGIN
      /*
      SELECT @nTotalPick = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
         JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
      WHERE LPD.LoadKey = @cLoadKey  
         AND PD.Status <= '5'
         AND PD.Status <> '4'
      */
      SET @cSQL = 
         ' SELECT @nTotalPick = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' + 
            ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' + 
         ' WHERE LPD.LoadKey = @cLoadKey ' + 
            ' AND PD.Status <= ''5'' ' + 
            ' AND PD.Status <> ''4'' ' + 
            CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
      SET @cSQLParam = 
         ' @cLoadKey    NVARCHAR( 10), ' + 
         ' @nTotalPick  INT OUTPUT '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@cLoadKey    = @cLoadKey
         ,@nTotalPick  = @nTotalPick OUTPUT
      
      /*
      SELECT @nTotalShort = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
         JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)    
      WHERE LPD.LoadKey = @cLoadKey  
         AND PD.Status = '4'
      */
      SET @cSQL = 
         ' SELECT @nTotalShort = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' + 
            ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' + 
         ' WHERE LPD.LoadKey = @cLoadKey ' + 
            ' AND PD.Status = ''4'' ' + 
            CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
      SET @cSQLParam = 
         ' @cLoadKey     NVARCHAR( 10), ' + 
         ' @nTotalShort  INT OUTPUT '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@cLoadKey    = @cLoadKey
         ,@nTotalShort = @nTotalShort OUTPUT
   END
   
   -- Custom PickSlip
   ELSE
   BEGIN
      /*
      SELECT @nTotalPick = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.PickDetail PD WITH (NOLOCK)
      WHERE PD.PickSlipNo = @cPickSlipNo
         AND PD.Status <= '5'
         AND PD.Status <> '4'
      */
      SET @cSQL = 
         ' SELECT @nTotalPick = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.PickDetail PD WITH (NOLOCK) ' + 
         ' WHERE PD.PickSlipNo = @cPickSlipNo ' + 
            ' AND PD.Status <= ''5'' ' + 
            ' AND PD.Status <> ''4'' ' + 
            CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
      SET @cSQLParam = 
         ' @cPickSlipNo NVARCHAR( 10), ' + 
         ' @nTotalPick  INT OUTPUT '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@cPickSlipNo = @cPickSlipNo
         ,@nTotalPick  = @nTotalPick OUTPUT
      
      /*
      SELECT @nTotalShort = ISNULL( SUM( PD.QTY), 0)
      FROM dbo.PickDetail PD WITH (NOLOCK)
      WHERE PD.PickSlipNo = @cPickSlipNo
         AND PD.Status = '4'
      */
      SET @cSQL = 
         ' SELECT @nTotalShort = ISNULL( SUM( PD.QTY), 0) ' + 
         ' FROM dbo.PickDetail PD WITH (NOLOCK) ' +
         ' WHERE PD.PickSlipNo = @cPickSlipNo ' +
            ' AND PD.Status = ''4'' ' + 
            CASE WHEN @cPickFilter <> '' THEN @cPickFilter ELSE '' END
      SET @cSQLParam = 
         ' @cPickSlipNo  NVARCHAR( 10), ' + 
         ' @nTotalShort  INT OUTPUT '
      EXEC sp_executeSQL @cSQL, @cSQLParam
         ,@cPickSlipNo = @cPickSlipNo
         ,@nTotalShort = @nTotalShort OUTPUT
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838GetStatSP08 TO NSQL
GO
