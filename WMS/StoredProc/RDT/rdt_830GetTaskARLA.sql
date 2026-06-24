
/****** Object:  StoredProcedure [RDT].[rdt_830GetTaskARLA]    Script Date: 6/24/2026 12:37:41 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: rdt_830GetTaskARLA                                      */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : RDT Should suggest highest weight item*qty first for picking    */
/*using 830 Function   UWP-59502                                             */
/*                                                                           */
/* Called By:  rdt_830GetTaskARLA                                            */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 01-04-2026   KMS043   1.0  Initial version created                        */
/*****************************************************************************/
ALTER     PROCEDURE [RDT].[rdt_830GetTaskARLA]
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR(3),
   @nStep         INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR(5),
   @cStorerKey    NVARCHAR(15),
   @cPickSlipNo   NVARCHAR(10),
   @cPickZone     NVARCHAR(10),
   @cLOC          NVARCHAR(10),
   @cID           NVARCHAR(18),
   @cSKU          NVARCHAR(20)  OUTPUT,
   @nTaskQTY      INT           OUTPUT,
   @cLottable01   NVARCHAR(18)  OUTPUT,
   @cLottable02   NVARCHAR(18)  OUTPUT,
   @cLottable03   NVARCHAR(18)  OUTPUT,
   @dLottable04   DATETIME      OUTPUT,
   @dLottable05   DATETIME      OUTPUT,
   @cLottable06   NVARCHAR(30)  OUTPUT,
   @cLottable07   NVARCHAR(30)  OUTPUT,
   @cLottable08   NVARCHAR(30)  OUTPUT,
   @cLottable09   NVARCHAR(30)  OUTPUT,
   @cLottable10   NVARCHAR(30)  OUTPUT,
   @cLottable11   NVARCHAR(30)  OUTPUT,
   @cLottable12   NVARCHAR(30)  OUTPUT,
   @dLottable13   DATETIME      OUTPUT,
   @dLottable14   DATETIME      OUTPUT,
   @dLottable15   DATETIME      OUTPUT,
   @cLottableCode NVARCHAR(30)  OUTPUT,
   @cSKUDescr     NVARCHAR(60)  OUTPUT,
   @cMUOM_Desc    NVARCHAR(5)   OUTPUT,
   @cPUOM_Desc    NVARCHAR(5)   OUTPUT,
   @nPUOM_Div     INT           OUTPUT,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR(20)  OUTPUT,
   @cPPK          NVARCHAR(5)   OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cOrderKey          NVARCHAR(10)
   DECLARE @cLoadKey           NVARCHAR(10)
   DECLARE @cZone              NVARCHAR(18)
   DECLARE @cGetNextSKU        NVARCHAR(1)
   DECLARE @cVerifyID          NVARCHAR(1)
   DECLARE @cSQL               NVARCHAR(MAX)
   DECLARE @cSQLParam          NVARCHAR(MAX)
   DECLARE @cPickConfirmStatus NVARCHAR(1)
   DECLARE @cTempSKU           NCHAR(20)
   DECLARE @nTempQTY           INT
   DECLARE @cTempLottable01    NVARCHAR(18)
   DECLARE @cTempLottable02    NVARCHAR(18)
   DECLARE @cTempLottable03    NVARCHAR(18)
   DECLARE @dTempLottable04    DATETIME
   DECLARE @dTempLottable05    DATETIME
   DECLARE @cTempLottable06    NVARCHAR(30)
   DECLARE @cTempLottable07    NVARCHAR(30)
   DECLARE @cTempLottable08    NVARCHAR(30)
   DECLARE @cTempLottable09    NVARCHAR(30)
   DECLARE @cTempLottable10    NVARCHAR(30)
   DECLARE @cTempLottable11    NVARCHAR(30)
   DECLARE @cTempLottable12    NVARCHAR(30)
   DECLARE @dTempLottable13    DATETIME
   DECLARE @dTempLottable14    DATETIME
   DECLARE @dTempLottable15    DATETIME
   DECLARE @cTempLottableCode  NVARCHAR(30)

   -- Temp table 1: SKUs already tried with no QTY result
   CREATE TABLE #SkippedSKU (SKU NVARCHAR(20) NOT NULL PRIMARY KEY)

   -- Temp table 2: pre-computed weight per SKU for the pickslip
   -- Weight computed ONCE before loop, outside ANSI_NULLS influence
   CREATE TABLE #SKUWeight
   (
       SKU         NVARCHAR(20) NOT NULL PRIMARY KEY,
       TotalWeight FLOAT        NOT NULL DEFAULT 0
   )

   -- Assign inputs to temp variables
   SET @cTempSKU          = @cSKU
   SET @nTempQTY          = 0
   SET @cTempLottable01   = @cLottable01
   SET @cTempLottable02   = @cLottable02
   SET @cTempLottable03   = @cLottable03
   SET @dTempLottable04   = @dLottable04
   SET @dTempLottable05   = @dLottable05
   SET @cTempLottable06   = @cLottable06
   SET @cTempLottable07   = @cLottable07
   SET @cTempLottable08   = @cLottable08
   SET @cTempLottable09   = @cLottable09
   SET @cTempLottable10   = @cLottable10
   SET @cTempLottable11   = @cLottable11
   SET @cTempLottable12   = @cLottable12
   SET @dTempLottable13   = @dLottable13
   SET @dTempLottable14   = @dLottable14
   SET @dTempLottable15   = @dLottable15
   SET @cTempLottableCode = @cLottableCode

   IF @cTempSKU = ''
      SET @cGetNextSKU = 'Y'
   ELSE
      SET @cGetNextSKU = 'N'

   IF @nStep = 6
      SET @cGetNextSKU = 'Y'

   -- Get storer config
   SET @cPickConfirmStatus = rdt.RDTGetConfig(@nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   SET @cVerifyID = rdt.RDTGetConfig(@nFunc, 'VerifyID', @cStorerKey)

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

  

   -- Cross dock PickSlip
   IF @cZone IN ('XD', 'LB', 'LP')
      INSERT INTO #SKUWeight (SKU, TotalWeight)
      SELECT
          PD.SKU,
          SUM(
              CAST(PD.Qty AS FLOAT) *
              CASE
                  WHEN ISNULL(NULLIF(SC.USERDEFINE01,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE01) = 1
                       THEN CAST(SC.USERDEFINE01 AS FLOAT)
                  WHEN ISNULL(NULLIF(SC.USERDEFINE02,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE02) = 1
                       THEN CAST(SC.USERDEFINE02 AS FLOAT)
                  WHEN ISNULL(S.STDGROSSWGT, 0) > 0 THEN CAST(S.STDGROSSWGT AS FLOAT)
                  WHEN ISNULL(S.GROSSWGT,    0) > 0 THEN CAST(S.GROSSWGT    AS FLOAT)
                  WHEN ISNULL(S.STDNETWGT,   0) > 0 THEN CAST(S.STDNETWGT   AS FLOAT)
                  WHEN ISNULL(S.NETWGT,       0) > 0 THEN CAST(S.NETWGT      AS FLOAT)
                  ELSE 0
              END
          )
      FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
          JOIN dbo.PickDetail PD     WITH (NOLOCK) ON PD.PickDetailKey  = RKL.PickDetailKey
          JOIN dbo.SKU S             WITH (NOLOCK) ON S.SKU             = PD.SKU
                                                  AND S.STORERKEY       = PD.STORERKEY
          LEFT JOIN dbo.SKUCONFIG SC WITH (NOLOCK) ON SC.SKU            = S.SKU
                                                  AND SC.STORERKEY      = PD.STORERKEY
      WHERE RKL.PickSlipNo = @cPickSlipNo
        AND PD.QTY         > 0
        AND PD.Status     <> '4'
        AND PD.Status      < @cPickConfirmStatus
      GROUP BY PD.SKU
	 ORDER BY  SUM(
              CAST(PD.Qty AS FLOAT) *
              CASE
                  WHEN ISNULL(NULLIF(SC.USERDEFINE01,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE01) = 1
                       THEN CAST(SC.USERDEFINE01 AS FLOAT)
                  WHEN ISNULL(NULLIF(SC.USERDEFINE02,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE02) = 1
                       THEN CAST(SC.USERDEFINE02 AS FLOAT)
                  WHEN ISNULL(S.STDGROSSWGT, 0) > 0 THEN CAST(S.STDGROSSWGT AS FLOAT)
                  WHEN ISNULL(S.GROSSWGT,    0) > 0 THEN CAST(S.GROSSWGT    AS FLOAT)
                  WHEN ISNULL(S.STDNETWGT,   0) > 0 THEN CAST(S.STDNETWGT   AS FLOAT)
                  WHEN ISNULL(S.NETWGT,       0) > 0 THEN CAST(S.NETWGT      AS FLOAT)
                  ELSE 0
              END
          )  DESC;  

   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
      INSERT INTO #SKUWeight (SKU, TotalWeight)
      SELECT
          PD.SKU,
          SUM(
              CAST(PD.Qty AS FLOAT) *
              CASE
                  WHEN ISNULL(NULLIF(SC.USERDEFINE01,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE01) = 1
                       THEN CAST(SC.USERDEFINE01 AS FLOAT)
                  WHEN ISNULL(NULLIF(SC.USERDEFINE02,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE02) = 1
                       THEN CAST(SC.USERDEFINE02 AS FLOAT)
                  WHEN ISNULL(S.STDGROSSWGT, 0) > 0 THEN CAST(S.STDGROSSWGT AS FLOAT)
                  WHEN ISNULL(S.GROSSWGT,    0) > 0 THEN CAST(S.GROSSWGT    AS FLOAT)
                  WHEN ISNULL(S.STDNETWGT,   0) > 0 THEN CAST(S.STDNETWGT   AS FLOAT)
                  WHEN ISNULL(S.NETWGT,       0) > 0 THEN CAST(S.NETWGT      AS FLOAT)
                  ELSE 0
              END
          )
      FROM dbo.PickDetail PD         WITH (NOLOCK)
          JOIN dbo.SKU S             WITH (NOLOCK) ON S.SKU        = PD.SKU
                                                  AND S.STORERKEY  = PD.STORERKEY
          LEFT JOIN dbo.SKUCONFIG SC WITH (NOLOCK) ON SC.SKU       = S.SKU
                                                  AND SC.STORERKEY = PD.STORERKEY
      WHERE PD.OrderKey  = @cOrderKey
        AND PD.QTY       > 0
        AND PD.Status   <> '4'
        AND PD.Status    < @cPickConfirmStatus
      GROUP BY PD.SKU
	  ORDER BY SUM(
              CAST(PD.Qty AS FLOAT) *
              CASE
                  WHEN ISNULL(NULLIF(SC.USERDEFINE01,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE01) = 1
                       THEN CAST(SC.USERDEFINE01 AS FLOAT)
                  WHEN ISNULL(NULLIF(SC.USERDEFINE02,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE02) = 1
                       THEN CAST(SC.USERDEFINE02 AS FLOAT)
                  WHEN ISNULL(S.STDGROSSWGT, 0) > 0 THEN CAST(S.STDGROSSWGT AS FLOAT)
                  WHEN ISNULL(S.GROSSWGT,    0) > 0 THEN CAST(S.GROSSWGT    AS FLOAT)
                  WHEN ISNULL(S.STDNETWGT,   0) > 0 THEN CAST(S.STDNETWGT   AS FLOAT)
                  WHEN ISNULL(S.NETWGT,       0) > 0 THEN CAST(S.NETWGT      AS FLOAT)
                  ELSE 0
              END
          )  DESC;  

   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
      INSERT INTO #SKUWeight (SKU, TotalWeight)
      SELECT
          PD.SKU,
          SUM(
              CAST(PD.Qty AS FLOAT) *
              CASE
                  WHEN ISNULL(NULLIF(SC.USERDEFINE01,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE01) = 1
                       THEN CAST(SC.USERDEFINE01 AS FLOAT)
                  WHEN ISNULL(NULLIF(SC.USERDEFINE02,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE02) = 1
                       THEN CAST(SC.USERDEFINE02 AS FLOAT)
                  WHEN ISNULL(S.STDGROSSWGT, 0) > 0 THEN CAST(S.STDGROSSWGT AS FLOAT)
                  WHEN ISNULL(S.GROSSWGT,    0) > 0 THEN CAST(S.GROSSWGT    AS FLOAT)
                  WHEN ISNULL(S.STDNETWGT,   0) > 0 THEN CAST(S.STDNETWGT   AS FLOAT)
                  WHEN ISNULL(S.NETWGT,       0) > 0 THEN CAST(S.NETWGT      AS FLOAT)
                  ELSE 0
              END
          )
      FROM dbo.LoadPlanDetail LPD    WITH (NOLOCK)
          JOIN dbo.PickDetail PD     WITH (NOLOCK) ON PD.OrderKey   = LPD.OrderKey
          JOIN dbo.SKU S             WITH (NOLOCK) ON S.SKU         = PD.SKU
                                                  AND S.STORERKEY   = PD.STORERKEY
          LEFT JOIN dbo.SKUCONFIG SC WITH (NOLOCK) ON SC.SKU        = S.SKU
                                                  AND SC.STORERKEY  = PD.STORERKEY
      WHERE LPD.LoadKey  = @cLoadKey
        AND PD.QTY       > 0
        AND PD.Status   <> '4'
        AND PD.Status    < @cPickConfirmStatus
      GROUP BY PD.SKU
	  ORDER BY SUM(
              CAST(PD.Qty AS FLOAT) *
              CASE
                  WHEN ISNULL(NULLIF(SC.USERDEFINE01,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE01) = 1
                       THEN CAST(SC.USERDEFINE01 AS FLOAT)
                  WHEN ISNULL(NULLIF(SC.USERDEFINE02,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE02) = 1
                       THEN CAST(SC.USERDEFINE02 AS FLOAT)
                  WHEN ISNULL(S.STDGROSSWGT, 0) > 0 THEN CAST(S.STDGROSSWGT AS FLOAT)
                  WHEN ISNULL(S.GROSSWGT,    0) > 0 THEN CAST(S.GROSSWGT    AS FLOAT)
                  WHEN ISNULL(S.STDNETWGT,   0) > 0 THEN CAST(S.STDNETWGT   AS FLOAT)
                  WHEN ISNULL(S.NETWGT,       0) > 0 THEN CAST(S.NETWGT      AS FLOAT)
                  ELSE 0
              END
          )  DESC;  
   -- Custom PickSlip
   ELSE
      INSERT INTO #SKUWeight (SKU, TotalWeight)
      SELECT
          PD.SKU,
          SUM(
              CAST(PD.Qty AS FLOAT) *
              CASE
                  WHEN ISNULL(NULLIF(SC.USERDEFINE01,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE01) = 1
                       THEN CAST(SC.USERDEFINE01 AS FLOAT)
                  WHEN ISNULL(NULLIF(SC.USERDEFINE02,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE02) = 1
                       THEN CAST(SC.USERDEFINE02 AS FLOAT)
                  WHEN ISNULL(S.STDGROSSWGT, 0) > 0 THEN CAST(S.STDGROSSWGT AS FLOAT)
                  WHEN ISNULL(S.GROSSWGT,    0) > 0 THEN CAST(S.GROSSWGT    AS FLOAT)
                  WHEN ISNULL(S.STDNETWGT,   0) > 0 THEN CAST(S.STDNETWGT   AS FLOAT)
                  WHEN ISNULL(S.NETWGT,       0) > 0 THEN CAST(S.NETWGT      AS FLOAT)
                  ELSE 0
              END
          )
      FROM dbo.PickDetail PD         WITH (NOLOCK)
          JOIN dbo.SKU S             WITH (NOLOCK) ON S.SKU        = PD.SKU
                                                  AND S.STORERKEY  = PD.STORERKEY
          LEFT JOIN dbo.SKUCONFIG SC WITH (NOLOCK) ON SC.SKU       = S.SKU
                                                  AND SC.STORERKEY = PD.STORERKEY
      WHERE PD.PickSlipNo = @cPickSlipNo
        AND PD.QTY        > 0
        AND PD.Status    <> '4'
        AND PD.Status     < @cPickConfirmStatus
      GROUP BY PD.SKU
	  ORDER BY SUM(
              CAST(PD.Qty AS FLOAT) *
              CASE
                  WHEN ISNULL(NULLIF(SC.USERDEFINE01,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE01) = 1
                       THEN CAST(SC.USERDEFINE01 AS FLOAT)
                  WHEN ISNULL(NULLIF(SC.USERDEFINE02,''),'0') <> '0'
                       AND ISNUMERIC(SC.USERDEFINE02) = 1
                       THEN CAST(SC.USERDEFINE02 AS FLOAT)
                  WHEN ISNULL(S.STDGROSSWGT, 0) > 0 THEN CAST(S.STDGROSSWGT AS FLOAT)
                  WHEN ISNULL(S.GROSSWGT,    0) > 0 THEN CAST(S.GROSSWGT    AS FLOAT)
                  WHEN ISNULL(S.STDNETWGT,   0) > 0 THEN CAST(S.STDNETWGT   AS FLOAT)
                  WHEN ISNULL(S.NETWGT,       0) > 0 THEN CAST(S.NETWGT      AS FLOAT)
                  ELSE 0
              END
          )  DESC;  
   -- No SKUs found at all
   IF NOT EXISTS (SELECT 1 FROM #SKUWeight)
   BEGIN
      SET @nErrNo  = 271151
      SET @cErrMsg = rdt.rdtgetmessage(271151, @cLangCode, 'DSP')
      SET @nErrNo  = -1
      GOTO Quit
   END

   WHILE (1=1)
   BEGIN
    
      IF @cGetNextSKU = 'Y'
      BEGIN
        
         SELECT TOP 1
            @cTempSKU = W.SKU
         FROM #SKUWeight W
         WHERE W.SKU NOT IN (SELECT SKU FROM #SkippedSKU)
         ORDER BY W.TotalWeight DESC, W.SKU ASC

         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo  = 271151
            SET @cErrMsg = rdt.rdtgetmessage(271151, @cLangCode, 'DSP')
            SET @nErrNo  = -1
            GOTO Quit
         END

         -- Get lottable code for this SKU
         SELECT @cTempLottableCode = LottableCode
         FROM dbo.SKU WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND SKU       = @cTempSKU

         SET @cGetNextSKU = 'N'
      END

      /************************************** Get QTY and lottables *********************************/
      DECLARE @cSelect  NVARCHAR(MAX)
      DECLARE @cFrom    NVARCHAR(MAX)
      DECLARE @cWhere1  NVARCHAR(MAX)
      DECLARE @cWhere2  NVARCHAR(MAX)
      DECLARE @cGroupBy NVARCHAR(MAX)
      DECLARE @cOrderBy NVARCHAR(MAX)

      SET @nTempQTY = 0

      EXEC rdt.rdt_Lottable_GetNextSQL
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey,
         @cFacility, @cStorerKey, 4, @cTempLottableCode, 'LA',
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
         SET @cSQL =
            ' SELECT TOP 1' +
            ' @nQTY = ISNULL(SUM(PD.QTY), 0)' +
            CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
            ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK)' +
            ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)' +
            ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)' +
            ' JOIN dbo.LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)' +
            ' WHERE RKL.PickSlipNo = @cPickSlipNo' +
            ' AND LOC.LOC = @cLOC' +
            CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID' ELSE '' END +
            ' AND PD.SKU = @cSKU' +
            ' AND PD.QTY > 0' +
            ' AND PD.Status <> ''4''' +
            ' AND PD.Status < @cStatus' +
            CASE WHEN @cPickZone <> '' THEN ' AND LOC.PickZone = @cPickZone' ELSE '' END +
            CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
            CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
            CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
            CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END

      -- Discrete PickSlip
      ELSE IF @cOrderKey <> ''
         SET @cSQL =
            ' SELECT TOP 1' +
            ' @nQTY = ISNULL(SUM(PD.QTY), 0)' +
            CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
            ' FROM dbo.PickDetail PD WITH (NOLOCK)' +
            ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)' +
            ' JOIN dbo.LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)' +
            ' WHERE PD.OrderKey = @cOrderKey' +
            ' AND LOC.LOC = @cLOC' +
            CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID' ELSE '' END +
            ' AND PD.SKU = @cSKU' +
            ' AND PD.QTY > 0' +
            ' AND PD.Status <> ''4''' +
            ' AND PD.Status < @cStatus' +
            CASE WHEN @cPickZone <> '' THEN ' AND LOC.PickZone = @cPickZone' ELSE '' END +
            CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
            CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
            CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
            CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END

      -- Conso PickSlip
      ELSE IF @cLoadKey <> ''
         SET @cSQL =
            ' SELECT TOP 1' +
            ' @nQTY = ISNULL(SUM(PD.QTY), 0)' +
            CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
            ' FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)' +
            ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)' +
            ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)' +
            ' JOIN dbo.LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)' +
            ' WHERE LPD.LoadKey = @cLoadKey' +
            ' AND LOC.LOC = @cLOC' +
            CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID' ELSE '' END +
            ' AND PD.SKU = @cSKU' +
            ' AND PD.QTY > 0' +
            ' AND PD.Status <> ''4''' +
            ' AND PD.Status < @cStatus' +
            CASE WHEN @cPickZone <> '' THEN ' AND LOC.PickZone = @cPickZone' ELSE '' END +
            CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
            CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
            CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
            CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END

      -- Custom PickSlip
      ELSE
         SET @cSQL =
            ' SELECT TOP 1' +
            ' @nQTY = ISNULL(SUM(PD.QTY), 0)' +
            CASE WHEN @cSelect = '' THEN '' ELSE ', ' + @cSelect END +
            ' FROM dbo.PickDetail PD WITH (NOLOCK)' +
            ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)' +
            ' JOIN dbo.LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)' +
            ' WHERE PD.PickSlipNo = @cPickSlipNo' +
            ' AND LOC.LOC = @cLOC' +
            CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID' ELSE '' END +
            ' AND PD.SKU = @cSKU' +
            ' AND PD.QTY > 0' +
            ' AND PD.Status <> ''4''' +
            ' AND PD.Status < @cStatus' +
            CASE WHEN @cPickZone <> '' THEN ' AND LOC.PickZone = @cPickZone' ELSE '' END +
            CASE WHEN @cWhere1 = '' THEN '' ELSE ' AND ' + @cWhere1 END +
            CASE WHEN @cWhere2 = '' THEN '' ELSE ' > '   + @cWhere2 END +
            CASE WHEN @cGroupBy = '' THEN '' ELSE ' GROUP BY ' + @cGroupBy END +
            CASE WHEN @cOrderBy = '' THEN '' ELSE ' ORDER BY ' + @cOrderBy END

      SET @cSQLParam =
         '@cPickSlipNo NVARCHAR(10), ' +
         '@cOrderKey   NVARCHAR(10), ' +
         '@cLoadKey    NVARCHAR(10), ' +
         '@cPickZone   NVARCHAR(10), ' +
         '@cLOC        NVARCHAR(10), ' +
         '@cID         NVARCHAR(18), ' +
         '@cSKU        NVARCHAR(20), ' +
         '@cStatus     NVARCHAR(1) , ' +
         '@nQTY        INT           OUTPUT, ' +
         '@cLottable01 NVARCHAR(18)  OUTPUT, ' +
         '@cLottable02 NVARCHAR(18)  OUTPUT, ' +
         '@cLottable03 NVARCHAR(18)  OUTPUT, ' +
         '@dLottable04 DATETIME      OUTPUT, ' +
         '@dLottable05 DATETIME      OUTPUT, ' +
         '@cLottable06 NVARCHAR(30)  OUTPUT, ' +
         '@cLottable07 NVARCHAR(30)  OUTPUT, ' +
         '@cLottable08 NVARCHAR(30)  OUTPUT, ' +
         '@cLottable09 NVARCHAR(30)  OUTPUT, ' +
         '@cLottable10 NVARCHAR(30)  OUTPUT, ' +
         '@cLottable11 NVARCHAR(30)  OUTPUT, ' +
         '@cLottable12 NVARCHAR(30)  OUTPUT, ' +
         '@dLottable13 DATETIME      OUTPUT, ' +
         '@dLottable14 DATETIME      OUTPUT, ' +
         '@dLottable15 DATETIME      OUTPUT  '

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
         @cPickSlipNo = @cPickSlipNo,
         @cOrderKey   = @cOrderKey,
         @cLoadKey    = @cLoadKey,
         @cPickZone   = @cPickZone,
         @cLOC        = @cLOC,
         @cID         = @cID,
         @cSKU        = @cTempSKU,
         @cStatus     = @cPickConfirmStatus,
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

      IF @nTempQTY > 0
         BREAK
      ELSE
      BEGIN
         -- Add to skip list, loop back for next-heaviest SKU
         IF NOT EXISTS (SELECT 1 FROM #SkippedSKU WHERE SKU = @cTempSKU)
            INSERT INTO #SkippedSKU (SKU) VALUES (@cTempSKU)

         SELECT
            @cGetNextSKU     = 'Y',
            @cTempLottable01 = '', @cTempLottable02 = '', @cTempLottable03 = '',
            @dTempLottable04 = NULL, @dTempLottable05 = NULL,
            @cTempLottable06 = '', @cTempLottable07 = '', @cTempLottable08 = '',
            @cTempLottable09 = '', @cTempLottable10 = '',
            @cTempLottable11 = '', @cTempLottable12 = '',
            @dTempLottable13 = NULL, @dTempLottable14 = NULL, @dTempLottable15 = NULL
      END
   END

   IF @nTempQTY = 0
   BEGIN
      SET @nErrNo  = 271152
      SET @cErrMsg = rdt.rdtgetmessage(271152, @cLangCode, 'DSP')
      SET @nErrNo  = -1
      GOTO Quit
   END

   -- Assign to actual OUTPUT params
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
      @cSKUDescr     = ISNULL(DescR, ''),
      @cLottableCode = LottableCode,
      @cPPK          =
         CASE WHEN SKU.PrePackIndicator = '2'
            THEN CAST(SKU.PackQtyIndicator AS NVARCHAR(5))
            ELSE ''
         END,
      @cMUOM_Desc    = Pack.PackUOM3
   FROM dbo.SKU  WITH (NOLOCK)
      JOIN dbo.Pack WITH (NOLOCK) ON SKU.PackKey = Pack.PackKey
   WHERE SKU.StorerKey = @cStorerKey
     AND SKU.SKU       = @cSKU

Quit:
   IF OBJECT_ID('tempdb..#SkippedSKU') IS NOT NULL DROP TABLE #SkippedSKU
   IF OBJECT_ID('tempdb..#SKUWeight')  IS NOT NULL DROP TABLE #SKUWeight

END

