
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/******************************************************************************/
/* Store procedure: rdt_839GetBalQty                                          */
/* Copyright      : Maersk                                                    */
/* Customer       : PAGEIND                                                   */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2026-01-05 1.0  NickT      FCR-9040. Created                               */
/******************************************************************************/
    
CREATE OR ALTER PROC rdt.rdt_839GetBalQty (
   @nMobile          INT,                
   @nFunc            INT,                
   @cLangCode        NVARCHAR( 3),       
   @nStep            INT,                
   @nInputKey        INT,                
   @cFacility        NVARCHAR( 5) ,      
   @cStorerKey       NVARCHAR( 15),
   @cType            NVARCHAR( 10), -- UCC/Piece
   @cPickSlipNo      NVARCHAR( 10),
   @cPickZone        NVARCHAR( 10),
   @cLot             NVARCHAR( 20), 
   @cLOC             NVARCHAR( 10),
   @cSKU             NVARCHAR( 20),
   @cLottableCode    NVARCHAR( 30),
   @nLottableOnPage  INT,
   @cLottable01      NVARCHAR( 18),
   @cLottable02      NVARCHAR( 18),
   @cLottable03      NVARCHAR( 18),
   @dLottable04      DATETIME     ,
   @dLottable05      DATETIME     ,
   @cLottable06      NVARCHAR( 30),
   @cLottable07      NVARCHAR( 30),
   @cLottable08      NVARCHAR( 30),
   @cLottable09      NVARCHAR( 30),
   @cLottable10      NVARCHAR( 30),
   @cLottable11      NVARCHAR( 30),
   @cLottable12      NVARCHAR( 30),
   @dLottable13      DATETIME     ,
   @dLottable14      DATETIME     ,
   @dLottable15      DATETIME     ,
   @nQTY             INT           OUTPUT,
   @nTtlBalQty       INT           OUTPUT,
   @nBalQty          INT           OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQL      NVARCHAR( MAX)
   DECLARE @cSQLParam NVARCHAR( MAX)

   DECLARE @cCurrLOC             NVARCHAR( 10)
   DECLARE @cPickConfirmStatus   NVARCHAR( 1)
   DECLARE @cOrderKey            NVARCHAR( 10)
   DECLARE @cLoadKey             NVARCHAR( 10)
   DECLARE @cZone                NVARCHAR( 18)
   DECLARE @cCurrSKU             NVARCHAR( 20)
   DECLARE @nRdtLogPickedQty     INT
   DECLARE @nSuggQty             INT

   DECLARE @cGetTaskSP NVARCHAR( 20)
   DECLARE @cTempLottable01 NVARCHAR( 18)
   DECLARE @cTempLottable02 NVARCHAR( 18)
   DECLARE @cTempLottable03 NVARCHAR( 18)
   DECLARE @dTempLottable04 DATETIME
   DECLARE @dTempLottable05 DATETIME
   DECLARE @cTempLottable06 NVARCHAR( 30)
   DECLARE @cTempLottable07 NVARCHAR( 30)
   DECLARE @cTempLottable08 NVARCHAR( 30)
   DECLARE @cTempLottable09 NVARCHAR( 30)
   DECLARE @cTempLottable10 NVARCHAR( 30)
   DECLARE @cTempLottable11 NVARCHAR( 30)
   DECLARE @cTempLottable12 NVARCHAR( 30)
   DECLARE @dTempLottable13 DATETIME
   DECLARE @dTempLottable14 DATETIME
   DECLARE @dTempLottable15 DATETIME
   DECLARE @cTempLottableCode NVARCHAR( 30)
   DECLARE @cUserName          NVARCHAR( 128)

   DECLARE @cSelect  NVARCHAR( MAX)
   DECLARE @cFrom    NVARCHAR( MAX)
   DECLARE @cWhere1  NVARCHAR( MAX)
   DECLARE @cWhere2  NVARCHAR( MAX)
   DECLARE @cGroupBy NVARCHAR( MAX)
   DECLARE @cOrderBy NVARCHAR( MAX)

   SET @cOrderKey = ''
   SET @cLoadKey = ''
   SET @cZone = ''
   SET @cUserName = SUSER_NAME()

   SET @cCurrLOC = @cLOC
   SET @cCurrSKU = CASE WHEN @cType = 'BALPICK' THEN @cSKU ELSE '' END

   -- Get storer config
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

   -- Get SKU info
   SELECT
      @cTempLottableCode = LottableCode
   FROM dbo.SKU WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU

   -- Assign to temp
   SET @cTempLottable01 = @cLottable01
   SET @cTempLottable02 = @cLottable02
   SET @cTempLottable03 = @cLottable03
   SET @dTempLottable04 = @dLottable04
   SET @dTempLottable05 = @dLottable05
   SET @cTempLottable06 = @cLottable06
   SET @cTempLottable07 = @cLottable07
   SET @cTempLottable08 = @cLottable08
   SET @cTempLottable09 = @cLottable09
   SET @cTempLottable10 = @cLottable10
   SET @cTempLottable11 = @cLottable11
   SET @cTempLottable12 = @cLottable12
   SET @dTempLottable13 = @dLottable13
   SET @dTempLottable14 = @dLottable14
   SET @dTempLottable15 = @dLottable15
   SET @cTempLottableCode = @cTempLottableCode   -- (james02)

   /************************************** Get QTY and lottables *********************************/

   -- Get lottable filter
   EXEC rdt.rdt_Lottable_GetNextSQL @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @nLottableOnPage, @cTempLottableCode, 'LA',
      @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
      @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
      @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
      @cSelect  OUTPUT,
      @cWhere1  OUTPUT,
      @cWhere2  OUTPUT,
      @cGroupBy OUTPUT,
      @cOrderBy OUTPUT,
      @nErrNo   OUTPUT,
      @cErrMsg  OUTPUT

   -- Cross dock PickSlip
   IF @cZone IN ('XD', 'LB', 'LP')
   BEGIN
      SET @cSQL =
      '    SELECT TOP 1 @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
      CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
      '    FROM dbo.RefKeyLookup RKL WITH (NOLOCK) ' +
      '       JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) ' +
      '       JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
      '       JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' +
      '    WHERE RKL.PickSlipNo = @cPickSlipNo ' +
      '       AND PD.QTY > 0 ' +
      '       AND PD.Status <> ''4'' ' +
      '       AND PD.Status < @cStatus ' +
      '       AND LOC.LOC = @cLOC ' +
      '       AND PD.LOT = @cLOT ' + --INC0720911
      CASE WHEN @cPickZone = '' THEN '' ELSE '    AND LOC.PickZone = @cPickZone ' END +
      CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
      CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
      CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
      CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END
   END

   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
   BEGIN
      SET @cSQL =
      '    SELECT TOP 1 @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
      CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
      '    FROM dbo.PickDetail PD WITH (NOLOCK) ' +
      '       JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
      '       JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' +
      '    WHERE PD.OrderKey = @cOrderKey ' +
      '       AND PD.QTY > 0 ' +
      '       AND PD.Status <> ''4'' ' +
      '       AND PD.Status < @cStatus ' +
      '       AND LOC.LOC = @cLOC ' +
      '       AND PD.LOT = @cLOT ' + --INC0720911
      CASE WHEN @cPickZone = '' THEN '' ELSE '    AND LOC.PickZone = @cPickZone ' END +
      CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
      CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
      CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
      CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END
   END

   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
   BEGIN
      SET @cSQL =
      '    SELECT TOP 1 @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
      CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
      '    FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' +
      '       JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' +
      '       JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
      '       JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' +
      '    WHERE LPD.LoadKey = @cLoadKey ' +
      '       AND PD.QTY > 0 ' +
      '       AND PD.Status <> ''4'' ' +
      '       AND PD.Status < @cStatus ' +
      '       AND LOC.LOC = @cLOC ' +
      '       AND PD.LOT = @cLOT ' + --INC0720911
      CASE WHEN @cPickZone = '' THEN '' ELSE '    AND LOC.PickZone = @cPickZone ' END +
      CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
      CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
      CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
      CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END
   END

   -- Custom PickSlip
   ELSE
   BEGIN
      SET @cSQL =
      '    SELECT TOP 1 @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
      CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
      '    FROM dbo.PickDetail PD WITH (NOLOCK) ' +
      '       JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
      '       JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' +
      '    WHERE PD.PickSlipNo = @cPickSlipNo ' +
      '       AND PD.QTY > 0 ' +
      '       AND PD.Status <> ''4'' ' +
      '       AND PD.Status < @cStatus ' +
      '       AND LOC.LOC = @cLOC ' +
      '       AND PD.LOT = @cLOT ' + --INC0720911
      CASE WHEN @cPickZone = '' THEN '' ELSE '    AND LOC.PickZone = @cPickZone ' END +
      CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
      CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
      CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
      CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END
   END

   SET @cSQLParam =
      '@cPickSlipNo NVARCHAR( 10) , ' +
      '@cOrderKey   NVARCHAR( 10) , ' +
      '@cLoadKey    NVARCHAR( 10) , ' +
      '@cLOC        NVARCHAR( 10) , ' +
      '@cLOT        NVARCHAR( 20) , ' +
      '@cSKU        NVARCHAR( 20) , ' +
      '@cStatus     NVARCHAR( 1)  , ' +
      '@cPickZone   NVARCHAR( 10) , ' +
      '@nQTY        INT           OUTPUT, ' +
      '@cLottable01 NVARCHAR( 18) OUTPUT, ' +
      '@cLottable02 NVARCHAR( 18) OUTPUT, ' +
      '@cLottable03 NVARCHAR( 18) OUTPUT, ' +
      '@dLottable04 DATETIME      OUTPUT, ' +
      '@dLottable05 DATETIME      OUTPUT, ' +
      '@cLottable06 NVARCHAR( 30) OUTPUT, ' +
      '@cLottable07 NVARCHAR( 30) OUTPUT, ' +
      '@cLottable08 NVARCHAR( 30) OUTPUT, ' +
      '@cLottable09 NVARCHAR( 30) OUTPUT, ' +
      '@cLottable10 NVARCHAR( 30) OUTPUT, ' +
      '@cLottable11 NVARCHAR( 30) OUTPUT, ' +
      '@cLottable12 NVARCHAR( 30) OUTPUT, ' +
      '@dLottable13 DATETIME      OUTPUT, ' +
      '@dLottable14 DATETIME      OUTPUT, ' +
      '@dLottable15 DATETIME      OUTPUT  '

   EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
      @cPickSlipNo = @cPickSlipNo,
      @cOrderKey   = @cOrderKey,
      @cLoadKey    = @cLoadKey,
      @cLOC        = @cLOC,
      @cLOT        = @cLOT,
      @cSKU        = @cSKU,
      @cStatus     = @cPickConfirmStatus,
      @cPickZone   = @cPickZone,
      @nQTY        = @nSuggQTY        OUTPUT,
      @cLottable01 = @cTempLottable01 OUTPUT,
      @cLottable02 = @cTempLottable02 OUTPUT,
      @cLottable03 = @cTempLottable03 OUTPUT,
      @dLottable04 = @dTempLottable04 OUTPUT,
      @dLottable05 = @dTempLottable05 OUTPUT,
      @cLottable06 = @cTempLottable06 OUTPUT,
      @cLottable07 = @cTempLottable07 OUTPUT,
      @cLottable08 = @cTempLottable08 OUTPUT,
      @cLottable09 = @cTempLottable09 OUTPUT,
      @cLottable10 = @cTempLottable10 OUTPUT,
      @cLottable11 = @cTempLottable11 OUTPUT,
      @cLottable12 = @cTempLottable12 OUTPUT,
      @dLottable13 = @dTempLottable13 OUTPUT,
      @dLottable14 = @dTempLottable14 OUTPUT,
      @dLottable15 = @dTempLottable15 OUTPUT

   IF ISNULL( @nSuggQty, 0) = 0
   BEGIN
         -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         SET @cSQL =
         '    SELECT TOP 1 @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
         '    FROM dbo.RefKeyLookup RKL WITH (NOLOCK) ' +
         '       JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) ' +
         '       JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
         '       JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' +
         '    WHERE RKL.PickSlipNo = @cPickSlipNo ' +
         '       AND PD.QTY > 0 ' +
         '       AND PD.Status <> ''4'' ' +
         '       AND PD.Status < @cStatus ' +
         '       AND LOC.LOC = @cLOC ' +
         '       AND PD.LOT = @cLOT ' +
         CASE WHEN @cPickZone = '' THEN '' ELSE '    AND LOC.PickZone = @cPickZone ' END
      END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         SET @cSQL =
         '    SELECT TOP 1 @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
         '    FROM dbo.PickDetail PD WITH (NOLOCK) ' +
         '       JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
         '       JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' +
         '    WHERE PD.OrderKey = @cOrderKey ' +
         '       AND PD.QTY > 0 ' +
         '       AND PD.Status <> ''4'' ' +
         '       AND PD.Status < @cStatus ' +
         '       AND LOC.LOC = @cLOC ' +
         '       AND PD.LOT = @cLOT ' +
         CASE WHEN @cPickZone = '' THEN '' ELSE '    AND LOC.PickZone = @cPickZone ' END
      END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         SET @cSQL =
         '    SELECT TOP 1 @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
         '    FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' +
         '       JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' +
         '       JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
         '       JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' +
         '    WHERE LPD.LoadKey = @cLoadKey ' +
         '       AND PD.QTY > 0 ' +
         '       AND PD.Status <> ''4'' ' +
         '       AND PD.Status < @cStatus ' +
         '       AND LOC.LOC = @cLOC ' +
         '       AND PD.LOT = @cLOT ' +
         CASE WHEN @cPickZone = '' THEN '' ELSE '    AND LOC.PickZone = @cPickZone ' END
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         SET @cSQL =
         '    SELECT TOP 1 @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
         '    FROM dbo.PickDetail PD WITH (NOLOCK) ' +
         '       JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
         '       JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' +
         '    WHERE PD.PickSlipNo = @cPickSlipNo ' +
         '       AND PD.QTY > 0 ' +
         '       AND PD.Status <> ''4'' ' +
         '       AND PD.Status < @cStatus ' +
         '       AND LOC.LOC = @cLOC ' +
         '       AND PD.LOT = @cLOT ' +
         CASE WHEN @cPickZone = '' THEN '' ELSE '    AND LOC.PickZone = @cPickZone ' END
      END

      SET @cSQLParam =
         '@cPickSlipNo NVARCHAR( 10) , ' +
         '@cOrderKey   NVARCHAR( 10) , ' +
         '@cLoadKey    NVARCHAR( 10) , ' +
         '@cLOC        NVARCHAR( 10) , ' +
         '@cSKU        NVARCHAR( 20) , ' +
         '@cStatus     NVARCHAR( 1)  , ' +
         '@cPickZone   NVARCHAR( 10) , ' +
         '@cLOT        NVARCHAR( 20) , ' +
         '@nQTY        INT           OUTPUT '

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
         @cPickSlipNo = @cPickSlipNo,
         @cOrderKey   = @cOrderKey,
         @cLoadKey    = @cLoadKey,
         @cLOC        = @cCurrLOC,
         @cSKU        = @cCurrSKU,
         @cLOT        = @cLOT,
         @cStatus     = @cPickConfirmStatus,
         @cPickZone   = @cPickZone,
         @nQTY        = @nSuggQTY  OUTPUT
   END

   IF ISNULL( @nSuggQty, 0) = 0
   BEGIN
      DECLARE @cSuggUCC NVARCHAR( 20)
      DECLARE @cUOM NVARCHAR( 10)

      SELECT @cSuggUCC = C_String1,
         @cUOM = C_String6
      FROM rdt.RDTMOBREC WITH (NOLOCK)
      WHERE Mobile = @nMobile

      IF ISNULL(@cSuggUCC, '') <> '' AND ISNULL(@cUOM, '') = '2'
      BEGIN
         SELECT @nSuggQty = Qty
         FROM dbo.UCC WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND UCCNo = @cSuggUCC
      END
   END

   SET @nQty = @nSuggQty

   -- get @nTtlBalQty
   BEGIN
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
            SELECT  @nTtlBalQty= SUM(PD.QTY)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
         ELSE
            SELECT  @nTtlBalQty= SUM(PD.QTY)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
      END
      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT  @nTtlBalQty= SUM(PD.QTY)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND PD.QTY > 0
         ELSE
            SELECT  @nTtlBalQty= SUM(PD.QTY)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
      END
      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT  @nTtlBalQty= SUM(PD.QTY)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
            JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND PD.QTY > 0
         ELSE
            SELECT  @nTtlBalQty= SUM(PD.QTY)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         IF @cPickZone = ''
            SELECT  @nTtlBalQty= SUM(PD.QTY)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
         ELSE
         SELECT  @nTtlBalQty= SUM(PD.QTY)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
      END
   END

   -- get @nBalQty
   BEGIN
      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
      BEGIN
         IF @cPickZone = ''
         BEGIN
            SELECT  @nBalQty= SUM(PD.QTY)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND PD.QTY > 0
                  AND PD.Status < '4'
                  AND NOT EXISTS(SELECT 1 
                              FROM [RDT].[rdtPickLog] RPL WITH(NOLOCK)
                              WHERE RPL.PickSlipNo = @cPickSlipNo
                                 AND RPL.Mobile = @nMobile
                                 AND RPL.AddWho = @cUserName
                                 AND RPL.PickMethod IN ( 'GetTask-U', 'GetTask-P' )
                                 AND RPL.Status IN( '4', '9' )
                                 AND RPL.PickDetailKey = PD.PickDetailKey)
         END
         ELSE
         BEGIN
            SELECT  @nBalQty= SUM(PD.QTY)
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.PickZone = @cPickZone
                  AND PD.QTY > 0
                  AND PD.Status < '4'
                  AND NOT EXISTS(SELECT 1 
                              FROM [RDT].[rdtPickLog] RPL WITH(NOLOCK)
                              WHERE RPL.PickSlipNo = @cPickSlipNo
                                 AND RPL.Mobile = @nMobile
                                 AND RPL.AddWho = @cUserName
                                 AND RPL.PickMethod IN ( 'GetTask-U', 'GetTask-P' )
                                 AND RPL.Status IN( '4', '9' )
                                 AND RPL.PickDetailKey = PD.PickDetailKey)
         END
      END
   
      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT  @nBalQty= SUM(PD.QTY)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND PD.QTY > 0
               AND PD.Status < '4'
               AND NOT EXISTS(SELECT 1 
                              FROM [RDT].[rdtPickLog] RPL WITH(NOLOCK)
                              WHERE RPL.PickSlipNo = @cPickSlipNo
                                 AND RPL.Mobile = @nMobile
                                 AND RPL.AddWho = @cUserName
                                 AND RPL.PickMethod IN ( 'GetTask-U', 'GetTask-P' )
                                 AND RPL.Status IN( '4', '9' )
                                 AND RPL.PickDetailKey = PD.PickDetailKey)

         ELSE
            SELECT  @nBalQty= SUM(PD.QTY)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.OrderKey = @cOrderKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               AND PD.Status < '4'
               AND NOT EXISTS(SELECT 1 
                              FROM [RDT].[rdtPickLog] RPL WITH(NOLOCK)
                              WHERE RPL.PickSlipNo = @cPickSlipNo
                                 AND RPL.Mobile = @nMobile
                                 AND RPL.AddWho = @cUserName
                                 AND RPL.PickMethod IN ( 'GetTask-U', 'GetTask-P' )
                                 AND RPL.Status IN( '4', '9' )
                                 AND RPL.PickDetailKey = PD.PickDetailKey)
      END
      
      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF @cPickZone = ''
            SELECT  @nBalQty= SUM(PD.QTY)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND PD.QTY > 0
               AND PD.Status < '4'
               AND NOT EXISTS(SELECT 1 
                              FROM [RDT].[rdtPickLog] RPL WITH(NOLOCK)
                              WHERE RPL.PickSlipNo = @cPickSlipNo
                                 AND RPL.Mobile = @nMobile
                                 AND RPL.AddWho = @cUserName
                                 AND RPL.PickMethod IN ( 'GetTask-U', 'GetTask-P' )
                                 AND RPL.Status IN( '4', '9' )
                                 AND RPL.PickDetailKey = PD.PickDetailKey)
         ELSE
            SELECT  @nBalQty= SUM(PD.QTY)
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
               JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE LPD.LoadKey = @cLoadKey
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               --AND PD.Status <>'4'
               AND PD.Status < '4'
               AND NOT EXISTS(SELECT 1 
                              FROM [RDT].[rdtPickLog] RPL WITH(NOLOCK)
                              WHERE RPL.PickSlipNo = @cPickSlipNo
                                 AND RPL.Mobile = @nMobile
                                 AND RPL.AddWho = @cUserName
                                 AND RPL.PickMethod IN ( 'GetTask-U', 'GetTask-P' )
                                 AND RPL.Status IN( '4', '9' )
                                 AND RPL.PickDetailKey = PD.PickDetailKey)
      END

      -- Custom PickSlip
      ELSE
      BEGIN
         IF @cPickZone = ''
            SELECT  @nBalQty= SUM(PD.QTY)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND PD.QTY > 0
               --AND PD.Status <>'4'
               AND PD.Status < '4'
               AND NOT EXISTS(SELECT 1 
                              FROM [RDT].[rdtPickLog] RPL WITH(NOLOCK)
                              WHERE RPL.PickSlipNo = @cPickSlipNo
                                 AND RPL.Mobile = @nMobile
                                 AND RPL.AddWho = @cUserName
                                 AND RPL.PickMethod IN ( 'GetTask-U', 'GetTask-P' )
                                 AND RPL.Status IN( '4', '9' )
                                 AND RPL.PickDetailKey = PD.PickDetailKey)
         ELSE
            SELECT  @nBalQty= SUM(PD.QTY)
            FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
            WHERE PD.PickSlipNo = @cPickSlipNo
               AND LOC.PickZone = @cPickZone
               AND PD.QTY > 0
               --AND PD.Status <>'4'
               AND PD.Status < '4'
               AND NOT EXISTS(SELECT 1 
                              FROM [RDT].[rdtPickLog] RPL WITH(NOLOCK)
                              WHERE RPL.PickSlipNo = @cPickSlipNo
                                 AND RPL.Mobile = @nMobile
                                 AND RPL.AddWho = @cUserName
                                 AND RPL.PickMethod IN ( 'GetTask-U', 'GetTask-P' )
                                 AND RPL.Status IN( '4', '9' )
                                 AND RPL.PickDetailKey = PD.PickDetailKey)
      END

      SELECT @nRdtLogPickedQty = SUM(PickLockQty)
      FROM RDT.rdtPickLog WITH(NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
         AND PickMethod = 'Pick-P'

      SET @nBalQty = ISNULL(@nBalQty,0) - ISNULL(@nRdtLogPickedQty,0)
      SET @nBalQty = CASE WHEN @nBalQty < 0 THEN 0 ELSE @nBalQty END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_839GetBalQty] TO NSQL
GO  