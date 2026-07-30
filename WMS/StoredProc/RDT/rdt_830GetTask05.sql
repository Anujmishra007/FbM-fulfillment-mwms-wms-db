
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_830GetTask05                                             */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: Custom GetTask SP for Michelin VN (MICVN01/MICVN02) - prioritise    */
/*          pick detail records with oldest PCS DOT (Lottable07) first,         */
/*          then oldest MIN DOT (Lottable02), then ascending PickDetailKey.      */
/*          DOT format: XXYY (XX=week, YY=year). Year-first sort applied.       */
/*          NULL Lottable07 treated as oldest ('0000' fallback).                 */
/*                                                                               */
/* Date        Rev  Author    Purposes                                             */
/* 2026-07-22  1.0  Jackc     FCR-14341 Created                                   */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_830GetTask05
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPickSlipNo   NVARCHAR( 10),
   @cPickZone     NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cID           NVARCHAR( 18),
   @cSKU          NVARCHAR( 20) OUTPUT,
   @nTaskQTY      INT           OUTPUT,
   @cLottable01   NVARCHAR( 18) OUTPUT,
   @cLottable02   NVARCHAR( 18) OUTPUT,
   @cLottable03   NVARCHAR( 18) OUTPUT,
   @dLottable04   DATETIME      OUTPUT,
   @dLottable05   DATETIME      OUTPUT,
   @cLottable06   NVARCHAR( 30) OUTPUT,
   @cLottable07   NVARCHAR( 30) OUTPUT,
   @cLottable08   NVARCHAR( 30) OUTPUT,
   @cLottable09   NVARCHAR( 30) OUTPUT,
   @cLottable10   NVARCHAR( 30) OUTPUT,
   @cLottable11   NVARCHAR( 30) OUTPUT,
   @cLottable12   NVARCHAR( 30) OUTPUT,
   @dLottable13   DATETIME      OUTPUT,
   @dLottable14   DATETIME      OUTPUT,
   @dLottable15   DATETIME      OUTPUT,
   @cLottableCode NVARCHAR( 30) OUTPUT,
   @cSKUDescr     NVARCHAR( 60) OUTPUT,
   @cMUOM_Desc    NVARCHAR( 5)  OUTPUT,
   @cPUOM_Desc    NVARCHAR( 5)  OUTPUT,
   @nPUOM_Div     INT           OUTPUT,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT,
   @cPPK          NVARCHAR( 5)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag         INT = 0   

   DECLARE @cOrderKey          NVARCHAR( 10)
   DECLARE @cLoadKey           NVARCHAR( 10)
   DECLARE @cZone              NVARCHAR( 18)
   DECLARE @cGetNextSKU        NVARCHAR( 1)
   DECLARE @cVerifyID          NVARCHAR( 1)
   DECLARE @cPUOM              NVARCHAR( 5)
   DECLARE @cSQL               NVARCHAR( MAX)
   DECLARE @cSQLParam          NVARCHAR( MAX)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)

   DECLARE @cTempSKU           NVARCHAR( 20)
   DECLARE @nTempQTY           INT
   DECLARE @cTempLottable01    NVARCHAR( 18)
   DECLARE @cTempLottable02    NVARCHAR( 18)
   DECLARE @cTempLottable03    NVARCHAR( 18)
   DECLARE @dTempLottable04    DATETIME
   DECLARE @dTempLottable05    DATETIME
   DECLARE @cTempLottable06    NVARCHAR( 30)
   DECLARE @cTempLottable07    NVARCHAR( 30)
   DECLARE @cTempLottable08    NVARCHAR( 30)
   DECLARE @cTempLottable09    NVARCHAR( 30)
   DECLARE @cTempLottable10    NVARCHAR( 30)
   DECLARE @cTempLottable11    NVARCHAR( 30)
   DECLARE @cTempLottable12    NVARCHAR( 30)
   DECLARE @dTempLottable13    DATETIME
   DECLARE @dTempLottable14    DATETIME
   DECLARE @dTempLottable15    DATETIME
   DECLARE @cTempLottableCode  NVARCHAR( 30)
   DECLARE @nLottableOnPage    INT

   SET @nLottableOnPage = 5

   -- Assign to temp
   SET @cTempSKU = @cSKU
   SET @nTempQTY = 0
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
   SET @cTempLottableCode = @cLottableCode

   SET @cTempSKU = ''

   IF ISNULL(@cTempSKU, '') = ''
      SET @cGetNextSKU = 'Y'
   ELSE
      SET @cGetNextSKU = 'N'

   IF @nStep = 6
      SET @cGetNextSKU = 'Y'

   -- Get storer config
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   SET @cVerifyID = rdt.RDTGetConfig( @nFunc, 'VerifyID', @cStorerKey)

   -- Get PickHeader info
   SET @cOrderKey = ''
   SET @cLoadKey  = ''
   SET @cZone     = ''
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey  = ExternOrderKey,
      @cZone     = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   IF @nDebugFlag = 1
      SELECT '830GetTask05', @cPickSlipNo AS PickSlipNo, @cOrderKey AS OrderKey, @cLoadKey AS LoadKey, 
         @cZone AS Zone, @cPickZone AS PickZone, @cGetNextSKU AS GetNextSKU

   WHILE (1=1)
   BEGIN
      /******************************************** Get SKU *****************************************/
      IF @cGetNextSKU = 'Y'
      BEGIN
         -- Cross dock PickSlip
         IF @cZone IN ('XD', 'LB', 'LP')
            IF @cPickZone <> ''
               SELECT TOP 1
                  @cTempSKU = PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
                  JOIN dbo.LotAttribute Lot WITH (NOLOCK) ON (Lot.LOT = PD.LOT AND Lot.SKU = PD.SKU AND Lot.StorerKey = PD.StorerKey)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.LOC = @cLOC
                  AND ((@cVerifyID = '1' AND PD.ID = @cID) OR @cVerifyID = '0')
                  AND PD.SKU > @cTempSKU
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.PickZone = @cPickZone
               ORDER BY PD.SKU
            ELSE
               SELECT TOP 1
                  @cTempSKU = PD.SKU
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
                  JOIN dbo.LotAttribute Lot WITH (NOLOCK) ON (Lot.LOT = PD.LOT AND Lot.SKU = PD.SKU AND Lot.StorerKey = PD.StorerKey)
               WHERE RKL.PickSlipNo = @cPickSlipNo
                  AND LOC.LOC = @cLOC
                  AND ((@cVerifyID = '1' AND PD.ID = @cID) OR @cVerifyID = '0')
                  AND PD.SKU > @cTempSKU
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
               ORDER BY PD.SKU

         -- Discrete PickSlip
         ELSE IF @cOrderKey <> ''
            IF @cPickZone <> ''
               SELECT TOP 1
                  @cTempSKU = PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
                  JOIN dbo.LotAttribute Lot WITH (NOLOCK) ON (Lot.LOT = PD.LOT AND Lot.SKU = PD.SKU AND Lot.StorerKey = PD.StorerKey)
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.LOC = @cLOC
                  AND ((@cVerifyID = '1' AND PD.ID = @cID) OR @cVerifyID = '0')
                  AND PD.SKU > @cTempSKU
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.PickZone = @cPickZone
               ORDER BY PD.SKU
            ELSE
               SELECT TOP 1
                  @cTempSKU = PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
                  JOIN dbo.LotAttribute Lot WITH (NOLOCK) ON (Lot.LOT = PD.LOT AND Lot.SKU = PD.SKU AND Lot.StorerKey = PD.StorerKey)
               WHERE PD.OrderKey = @cOrderKey
                  AND LOC.LOC = @cLOC
                  AND ((@cVerifyID = '1' AND PD.ID = @cID) OR @cVerifyID = '0')
                  AND PD.SKU > @cTempSKU
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
               ORDER BY PD.SKU

         -- Conso PickSlip
         ELSE IF @cLoadKey <> ''
            IF @cPickZone <> ''
               SELECT TOP 1
                  @cTempSKU = PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
                  JOIN dbo.LotAttribute Lot WITH (NOLOCK) ON (Lot.LOT = PD.LOT AND Lot.SKU = PD.SKU AND Lot.StorerKey = PD.StorerKey)
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.LOC = @cLOC
                  AND ((@cVerifyID = '1' AND PD.ID = @cID) OR @cVerifyID = '0')
                  AND PD.SKU > @cTempSKU
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.PickZone = @cPickZone
               ORDER BY PD.SKU
            ELSE
               SELECT TOP 1
                  @cTempSKU = PD.SKU
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
                  JOIN dbo.LotAttribute Lot WITH (NOLOCK) ON (Lot.LOT = PD.LOT AND Lot.SKU = PD.SKU AND Lot.StorerKey = PD.StorerKey)
               WHERE LPD.LoadKey = @cLoadKey
                  AND LOC.LOC = @cLOC
                  AND ((@cVerifyID = '1' AND PD.ID = @cID) OR @cVerifyID = '0')
                  AND PD.SKU > @cTempSKU
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
               ORDER BY PD.SKU

         -- Custom PickSlip
         ELSE
            IF @cPickZone <> ''
               SELECT TOP 1
                  @cTempSKU = PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
                  JOIN dbo.LotAttribute Lot WITH (NOLOCK) ON (Lot.LOT = PD.LOT AND Lot.SKU = PD.SKU AND Lot.StorerKey = PD.StorerKey)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.LOC = @cLOC
                  AND ((@cVerifyID = '1' AND PD.ID = @cID) OR @cVerifyID = '0')
                  AND PD.SKU > @cTempSKU
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
                  AND LOC.PickZone = @cPickZone
               ORDER BY PD.SKU
            ELSE
               SELECT TOP 1
                  @cTempSKU = PD.SKU
               FROM dbo.PickDetail PD WITH (NOLOCK)
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                  JOIN dbo.SKU SKU WITH (NOLOCK) ON (SKU.SKU = PD.SKU AND SKU.StorerKey = PD.StorerKey)
                  JOIN dbo.LotAttribute Lot WITH (NOLOCK) ON (Lot.LOT = PD.LOT AND Lot.SKU = PD.SKU AND Lot.StorerKey = PD.StorerKey)
               WHERE PD.PickSlipNo = @cPickSlipNo
                  AND LOC.LOC = @cLOC
                  AND ((@cVerifyID = '1' AND PD.ID = @cID) OR @cVerifyID = '0')
                  AND PD.SKU > @cTempSKU
                  AND PD.QTY > 0
                  AND PD.Status <> '4'
                  AND PD.Status < @cPickConfirmStatus
               ORDER BY PD.SKU

         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 275351
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No more task
            SET @nErrNo = -1 -- No more task
            GOTO Quit
         END

         -- Get SKU info
         SELECT
            @cTempLottableCode = LottableCode
         FROM dbo.SKU WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND SKU = @cTempSKU

         SET @cGetNextSKU = 'N'

         IF @nDebugFlag = 1
            SELECT 'Get Next SKU', @cTempSKU AS SKU, @cTempLottableCode AS LottableCode
      END

      -- Verify LottableCode has definition in rdtLottableCode for current function
      IF NOT EXISTS (
         SELECT TOP 1 1
         FROM rdt.rdtLottableCode WITH (NOLOCK)
         WHERE LottableCode = @cTempLottableCode
            AND Function_ID = @nFunc
            AND StorerKey   = @cStorerKey)
      BEGIN
         IF NOT EXISTS (
            SELECT TOP 1 1
            FROM rdt.rdtLottableCode WITH (NOLOCK)
            WHERE LottableCode = @cTempLottableCode
               AND Function_ID = 0
               AND StorerKey   = @cStorerKey)
         BEGIN
            SET @nErrNo = 275353
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- LottableCode not configured
            GOTO Quit
         END
      END

      /************************************** Get QTY and lottables *********************************/
      DECLARE @cSelect  NVARCHAR( MAX) = ''
      DECLARE @cFrom    NVARCHAR( MAX) = ''
      DECLARE @cWhere1  NVARCHAR( MAX) = ''
      DECLARE @cWhere2  NVARCHAR( MAX) = ''
      DECLARE @cGroupBy NVARCHAR( MAX) = ''
      DECLARE @cOrderBy NVARCHAR( MAX) = ''

      SET @nTempQTY = 0

      -- Get lottable filter clauses
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

      -- Verify Lottable07 (PCS DOT) and Lottable02 (MIN DOT) are visible in rdtLottableCode
      -- These are required for the fixed DOT ORDER BY; if absent @cGroupBy will not contain them
      -- and ORDER BY on non-grouped columns would cause a SQL error
      IF CHARINDEX('Lottable07', ISNULL(@cSelect, '')) = 0 OR CHARINDEX('Lottable02', ISNULL(@cSelect, '')) = 0
      BEGIN
         SET @nErrNo = 275354
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Lottable07/02 not visible
         GOTO Quit
      END

      -- Override ORDER BY: oldest PCS DOT (Lottable07) first, then MIN DOT (Lottable02), then smallest PickDetailKey
      -- DOT format XXYY (XX=week, YY=year) — RIGHT(2) extracts year for correct chronological sort
      -- ISNULL fallback '0000' sorts NULL Lottable07 first (treated as oldest stock)
      -- MIN(PD.PickDetailKey) is required as aggregate for GROUP BY context
      SET @cOrderBy = 'RIGHT(ISNULL(LA.Lottable07,''0000''),2) ASC, LEFT(ISNULL(LA.Lottable07,''0000''),2) ASC, RIGHT(ISNULL(LA.Lottable02,''0000''),2) ASC, LEFT(ISNULL(LA.Lottable02,''0000''),2) ASC, MIN(PD.PickDetailKey) ASC'

      IF @nDebugFlag = 1
         SELECT 'Get dynamic sql', @cSelect AS SelectClause, @cWhere1 AS WhereClause1, @cWhere2 AS WhereClause2, 
            @cGroupBy AS GroupByClause, @cOrderBy AS OrderByClause

      -- Cross dock PickSlip
      IF @cZone IN ('XD', 'LB', 'LP')
         SET @cSQL =
            ' SELECT TOP 1 ' +
               ' @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
               CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
            ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK)' +
               ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)' +
               ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)' +
               ' JOIN dbo.LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT AND LA.SKU = PD.SKU AND LA.StorerKey = PD.StorerKey) ' +
            ' WHERE RKL.PickSlipNo = @cPickSlipNo ' +
               ' AND LOC.LOC = @cLOC ' +
               CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END +
               ' AND PD.SKU = @cSKU ' +
               ' AND PD.QTY > 0' +
               ' AND PD.Status <> ''4''' +
               CASE WHEN @cPickZone <> '' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END +
               ' AND PD.Status < @cStatus ' +
               CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
               CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
            CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
            CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
         SET @cSQL =
            ' SELECT TOP 1 ' +
               ' @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
               CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
            ' FROM dbo.PickDetail PD WITH (NOLOCK)' +
               ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)' +
               ' JOIN dbo.LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT AND LA.SKU = PD.SKU AND LA.StorerKey = PD.StorerKey) ' +
            ' WHERE PD.OrderKey = @cOrderKey ' +
               ' AND LOC.LOC = @cLOC ' +
               CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END +
               ' AND PD.SKU = @cSKU ' +
               ' AND PD.QTY > 0' +
               ' AND PD.Status <> ''4''' +
               ' AND PD.Status < @cStatus ' +
               CASE WHEN @cPickZone <> '' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END +
               CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
               CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
            CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
            CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
         SET @cSQL =
            ' SELECT TOP 1 ' +
               ' @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
               CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
            ' FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' +
               ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' +
               ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
               ' JOIN dbo.LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT AND LA.SKU = PD.SKU AND LA.StorerKey = PD.StorerKey) ' +
            ' WHERE LPD.LoadKey = @cLoadKey ' +
               ' AND LOC.LOC = @cLOC ' +
               CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END +
               ' AND PD.SKU = @cSKU ' +
               ' AND PD.QTY > 0' +
               ' AND PD.Status <> ''4''' +
               ' AND PD.Status < @cStatus ' +
               CASE WHEN @cPickZone <> '' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END +
               CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
               CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
            CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
            CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END

      -- Custom PickSlip
      ELSE
         SET @cSQL =
            ' SELECT TOP 1 ' +
               ' @nQTY = ISNULL( SUM( PD.QTY), 0) ' +
               CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
            ' FROM dbo.PickDetail PD WITH (NOLOCK)' +
               ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)' +
               ' JOIN dbo.LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT AND LA.SKU = PD.SKU AND LA.StorerKey = PD.StorerKey) ' +
            ' WHERE PD.PickSlipNo = @cPickSlipNo ' +
               ' AND LOC.LOC = @cLOC ' +
               CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END +
               ' AND PD.SKU = @cSKU ' +
               ' AND PD.QTY > 0' +
               ' AND PD.Status <> ''4''' +
               ' AND PD.Status < @cStatus ' +
               CASE WHEN @cPickZone <> '' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END +
               CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
               CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
            CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
            CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END

      SET @cSQLParam =
         '@cPickSlipNo NVARCHAR( 10) , ' +
         '@cOrderKey   NVARCHAR( 10) , ' +
         '@cLoadKey    NVARCHAR( 10) , ' +
         '@cPickZone   NVARCHAR( 10) , ' +
         '@cLOC        NVARCHAR( 10) , ' +
         '@cID         NVARCHAR( 18) , ' +
         '@cSKU        NVARCHAR( 20) , ' +
         '@cStatus     NVARCHAR( 1)  , ' +
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

      BEGIN TRY
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @cPickSlipNo = @cPickSlipNo,
            @cOrderKey   = @cOrderKey,
            @cLoadKey    = @cLoadKey,
            @cLOC        = @cLOC,
            @cID         = @cID,
            @cSKU        = @cTempSKU,
            @cStatus     = @cPickConfirmStatus,
            @cPickZone   = @cPickZone,
            @nQTY        = @nTempQTY        OUTPUT,
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
      END TRY
      BEGIN CATCH
         SET @nErrNo = 275355
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Execute SQL error
         GOTO Quit
      END CATCH

      IF @nTempQTY > 0
         BREAK
      ELSE
         SELECT
            @cGetNextSKU = 'Y',
            @cTempLottable01 = '', @cTempLottable02 = '', @cTempLottable03 = '',    @dTempLottable04 = NULL,  @dTempLottable05 = NULL,
            @cTempLottable06 = '', @cTempLottable07 = '', @cTempLottable08 = '',    @cTempLottable09 = '',    @cTempLottable10 = '',
            @cTempLottable11 = '', @cTempLottable12 = '', @dTempLottable13 = NULL,  @dTempLottable14 = NULL,  @dTempLottable15 = NULL
   END

   IF @nTempQTY = 0
   BEGIN
      SET @nErrNo = 275352
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No more task
      SET @nErrNo = -1 -- No more task
      GOTO Quit
   END -- while

   -- Assign to actual
   SET @cSKU        = @cTempSKU
   SET @nTaskQTY    = @nTempQTY
   SET @cLottable01 = @cTempLottable01
   SET @cLottable02 = @cTempLottable02
   SET @cLottable03 = @cTempLottable03
   SET @dLottable04 = @dTempLottable04
   SET @dLottable05 = @dTempLottable05
   SET @cLottable06 = @cTempLottable06
   SET @cLottable07 = @cTempLottable07
   SET @cLottable08 = @cTempLottable08
   SET @cLottable09 = @cTempLottable09
   SET @cLottable10 = @cTempLottable10
   SET @cLottable11 = @cTempLottable11
   SET @cLottable12 = @cTempLottable12
   SET @dLottable13 = @dTempLottable13
   SET @dLottable14 = @dTempLottable14
   SET @dLottable15 = @dTempLottable15

   -- Get SKU info
   SELECT
      @cSKUDescr     = ISNULL( DescR, ''),
      @cLottableCode = LottableCode,
      @cPPK          =
         CASE WHEN SKU.PrePackIndicator = '2'
            THEN ISNULL(TRY_CAST( SKU.PackQtyIndicator AS NVARCHAR( 5)), '')
            ELSE ''
         END,
      @cMUOM_Desc    = Pack.PackUOM3,
      @cPUOM_Desc    =
         CASE @cPUOM
            WHEN '2' THEN Pack.PackUOM1
            WHEN '3' THEN Pack.PackUOM2
            WHEN '6' THEN Pack.PackUOM3
            WHEN '1' THEN Pack.PackUOM4
            WHEN '4' THEN Pack.PackUOM8
            WHEN '5' THEN Pack.PackUOM9
         END,
      @nPUOM_Div     = CAST( ISNULL(
         CASE @cPUOM
            WHEN '2' THEN Pack.CaseCNT
            WHEN '3' THEN Pack.InnerPack
            WHEN '6' THEN Pack.QTY
            WHEN '1' THEN Pack.Pallet
            WHEN '4' THEN Pack.OtherUnit1
            WHEN '5' THEN Pack.OtherUnit2
         END, 1) AS INT)
   FROM dbo.SKU WITH (NOLOCK)
      JOIN dbo.Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
   WHERE SKU.StorerKey = @cStorerKey
      AND SKU.SKU = @cSKU

Quit:

END
GO

GRANT EXECUTE ON rdt.rdt_830GetTask05 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
