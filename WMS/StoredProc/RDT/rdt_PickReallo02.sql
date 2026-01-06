
/************************************************************************/
/* Store procedure: rdt_PickReallo02                                    */
/* Copyright      : Maersk                                              */
/* Customer       : Mattel                                              */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2025-06-09 1.0.0  CYU027   FCR-4328 Re-allocation if short happens   */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_PickReallo02] (
   @nMobile             INT          
   ,@nFunc              INT          
   ,@cLangCode          NVARCHAR( 3) 
   ,@cFacility          NVARCHAR( 5) 
   ,@cStorerKey         NVARCHAR( 15)
   ,@cPickSlipNo        NVARCHAR( 10)  OUTPUT
   ,@tAdditionalData    VariableTable  READONLY
   ,@cType              NVARCHAR( 5) --UCC/SKU
   ,@cLOC               NVARCHAR( 10)
   ,@cID                NVARCHAR( 18) = ''
   ,@cSKU               NVARCHAR( 20)
   ,@nQTY               INT
   ,@cLot               NVARCHAR( 10)  OUTPUT
   ,@cPickZone          NVARCHAR( 10)  OUTPUT
   ,@cSuggestLOC        NVARCHAR( 10)  OUTPUT
   ,@cSuggestID         NVARCHAR( 18)  OUTPUT
   ,@nErrNo             INT            OUTPUT
   ,@cErrMsg            NVARCHAR(250)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   ----------------------------------------------------------------------------------------
   -- Coding Convention
   -- 1. If no loc found, set ErrNo = -1, and set all resturned values to ''
   -- 2. Can set all output values to '' based on requirement
   ----------------------------------------------------------------------------------------
   DECLARE @nDebugFlag  INT = 0 --1 print log, 2 insert trace info

   DECLARE
      @cSuggestPutawayZone    NVARCHAR(10),
      @cSuggestPSNO        NVARCHAR(10),
      @cPickDetailKey      NVARCHAR(18),
      @cNewPickDetailKey   NVARCHAR(18),
      @cPKDNotes           NVARCHAR(1024),
      @cUserName           NVARCHAR(128),
      @cLottable01         NVARCHAR(10),
      @nPickDetailQty      INT,
      @cTotalShortQty      INT,
      @cWaveKey            NVARCHAR(10),
      @cLoadKey            NVARCHAR(10), --v1.0.1
      @cShortUCCNo         NVARCHAR(20),
      @nShortUCCQty        INT,
      @cShortUCCStatus     NVARCHAR(1),
      @cShortUOM           NVARCHAR( 10),
      @cOrderKey           NVARCHAR( 10),
      @cPutawayZone        NVARCHAR( 10),
      @cPickZoneHeader     NVARCHAR( 10),
      @cVerifyID           NVARCHAR( 1),
      @cSQL                NVARCHAR( MAX),
      @cSQLParam           NVARCHAR( MAX),


      
      @nBal_Qty            INT,
      @cAllocatedQty       INT,
      @cAllocatedUCC       NVARCHAR(20),
      @cAllocatedLot       NVARCHAR(10),

      @bSuccess            BIT,
      @nTranCount          INT,
      @nRowCount           INT,
      @nLoopIndex          INT,
      @nPKDRowCount        INT, --V1.0.1
      @nUCCRowCount        INT, --V1.0.1
      @nPKDLoopIndex       INT, --V1.0.1
      @nUCCLoopIndex       INT  --V1.0.1

   IF OBJECT_ID('tempdb..#tShortPickDetails') IS NOT NULL
      DROP TABLE #tShortPickDetails

   CREATE TABLE #tShortPickDetails
   (
      PKDRowRef         INT  NOT NULL, --v1.0.1
      PickDetailKey     NVARCHAR( 10) NOT NULL,
      CaseID            NVARCHAR( 20) NOT NULL,
      PickHeaderKey     NVARCHAR( 18) NOT NULL,
      OrderKey          NVARCHAR( 10) NOT NULL,
      OrderLineNumber   NVARCHAR( 5)  NOT NULL,
      SKU               NVARCHAR( 20) NOT NULL, 
      QTY               INT           NOT NULL,
      Lot               NVARCHAR( 10) NOT NULL,
      StorerKey         NVARCHAR( 15) NOT NULL,
      UOM               NVARCHAR( 10) NOT NULL,
      UOMQty            INT           NOT NULL,
      DropID            NVARCHAR( 20) NULL,
      Loc               NVARCHAR( 10) NOT NULL,
      ID                NVARCHAR( 18) NULL,
      PackKey           NVARCHAR( 10) NOT NULL,
      CartonGroup       NVARCHAR( 10) NULL,
      PickMethod        NVARCHAR( 1)  NOT NULL,
      WaveKey           NVARCHAR( 10) NULL,
      NewFlag           NVARCHAR( 1)  NULL DEFAULT 'N',
      OldPickDetailKey  NVARCHAR( 10) NULL
   )


   DECLARE @tShortUCC TABLE --V1.0.1
   (
      UCCRowRef        INT IDENTITY (1, 1)  NOT NULL,
      UCCNo            NVARCHAR( 20) NOT NULL,
      ShortQty         INT           NOT NULL DEFAULT 0
   )

    DECLARE @tAllocation TABLE
   (
      PickDetailKey     NVARCHAR( 10) NOT NULL,
      CaseID            NVARCHAR( 20) NULL,
      PickHeaderKey     NVARCHAR( 18) NOT NULL,
      OrderKey          NVARCHAR( 10) NOT NULL,
      OrderLineNumber   NVARCHAR( 5)  NOT NULL,
      SKU               NVARCHAR( 20) NOT NULL, 
      QTY               INT           NOT NULL,
      Lot               NVARCHAR( 10) NOT NULL,
      StorerKey         NVARCHAR( 15) NOT NULL,
      UOM               NVARCHAR( 10) NOT NULL,
      UOMQty            INT           NOT NULL,
      DropID            NVARCHAR( 20) NULL,
      Loc               NVARCHAR( 10) NOT NULL,
      ID                NVARCHAR( 18) NULL,
      PackKey           NVARCHAR( 10) NOT NULL,
      CartonGroup       NVARCHAR( 10) NULL,
      PickMethod        NVARCHAR( 1)  NOT NULL,
      WaveKey           NVARCHAR( 10) NULL,
      PickSlipNo        NVARCHAR( 10) NULL,
      NewFlag           NVARCHAR( 1)  NULL DEFAULT 'N',
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   DECLARE @tPutawayZoneCandidate TABLE
   (
      PutawayZone      NVARCHAR( 10) NOT NULL,
      Priority         INT           NOT NULL DEFAULT 99
   )

   DECLARE @tAvailableLots TABLE
   (
      Lot            NVARCHAR(10),
      AvailableQty   INT,
      AllocatedQty   INT
   )

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Running rdt_PickReallo02'
   END

   SET @cVerifyID = rdt.RDTGetConfig( @nFunc, 'VerifyID', @cStorerKey)

   --General validation
   IF @cType NOT IN ('UCC', 'SKU')
   BEGIN
      SET @nErrNo = 240001
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cSKU, '') = ''
   BEGIN
      SET @nErrNo = 240002
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cLOC, '') = ''
   BEGIN
      SET @nErrNo = 240004
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   SELECT @cPutawayZone = PutawayZone FROM LOC WITH (NOLOCK)
   WHERE Loc = @cLOC
     AND Facility = @cFacility

   IF ISNULL(@cPutawayZone, '') = ''
   BEGIN
      SET @nErrNo = 240003
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cPickSlipNo, '') = ''
   BEGIN
      SET @nErrNo = 240005
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cLot, '') = ''
   BEGIN
      SET @nErrNo = 240006
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   SELECT @cUserName = UserName FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Short PKD query parameters', @cStorerKey AS Storer, @cPickSlipNo AS PSNO, 
               @cLOC AS LOC, @cID AS ID, @cSKU AS SKU, @cLot AS LOT


   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cPickZoneHeader = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo


   -- Cross dock PickSlip
   IF @cPickZoneHeader IN ('XD', 'LB', 'LP')
      SET @cSQL =
           ' SELECT ROW_NUMBER() OVER (PARTITION BY pd.DropID ORDER BY pd.Qty), '
         + ' pd.PickDetailKey, pd.CaseID, pd.PickHeaderKey, pd.OrderKey, pd.OrderLineNumber, pd.SKU, pd.QTY,'
         + ' pd.LOT, pd.StorerKey, pd.UOM, pd.UOMQTY, pd.DropID, pd.Loc, pd.ID, pd.PackKey, pd.CartonGroup,'
         + ' pd.PickMethod, pd.WaveKey'
         + ' FROM dbo.PickDetail pd WITH (NOLOCK)'
         + ' JOIN dbo.RefKeyLookup RKL WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)'
         + ' JOIN dbo.Loc LOC WITH (NOLOCK) ON (LOC.LOC=PD.LOC)'+
         --+ ' JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) '
         + ' WHERE RKL.PickSlipNo = @cPickSlipNo '
         + ' AND PD.LOC = @cLOC '
         + CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END
         + ' AND PD.SKU = @cSKU '
         + ' AND PD.Status = ''4'''
        -- + CASE WHEN @cPickZone <>'' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END
         + 'ORDER BY pd.DropID, pd.Qty DESC'


   ELSE IF @cOrderKey <> ''
      SET @cSQL =
           ' SELECT  ROW_NUMBER() OVER (PARTITION BY pd.DropID ORDER BY pd.Qty), '
         + ' pd.PickDetailKey, pd.CaseID, pd.PickHeaderKey, pd.OrderKey, pd.OrderLineNumber, pd.SKU, pd.QTY, '
         + ' pd.LOT, pd.StorerKey, pd.UOM, pd.UOMQTY, pd.DropID, pd.Loc, pd.ID, pd.PackKey, pd.CartonGroup,'
         + ' pd.PickMethod, pd.WaveKey'
         + ' FROM dbo.PickDetail pd WITH (NOLOCK)'
         + ' JOIN dbo.Loc LOC WITH (NOLOCK) ON (LOC.LOC=PD.LOC)'
         --+ ' JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) '
         + ' WHERE PD.OrderKey = @cOrderKey '
         + ' AND PD.LOC = @cLOC '
         + CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END
         + ' AND PD.SKU = @cSKU '
         + ' AND PD.Status = ''4'''
       --  + CASE WHEN @cPickZone <>'' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END
         + 'ORDER BY pd.DropID, pd.Qty DESC'

      -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
      SET @cSQL =
           '  SELECT  ROW_NUMBER() OVER (PARTITION BY pd.DropID ORDER BY pd.Qty), '
         + ' pd.PickDetailKey, pd.CaseID, pd.PickHeaderKey, pd.OrderKey, pd.OrderLineNumber, pd.SKU, pd.QTY'
         + ' pd.LOT, pd.StorerKey, pd.UOM, pd.UOMQTY, pd.DropID, pd.Loc, pd.ID, pd.PackKey, pd.CartonGroup,'
         + ' pd.PickMethod, pd.WaveKey'
         + ' FROM dbo.PickDetail pd WITH (NOLOCK)'
         + ' JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)'
         + ' JOIN dbo.Loc LOC WITH (NOLOCK) ON (LOC.LOC=PD.LOC)'
         --+ ' JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) '
         + ' WHERE LPD.LoadKey = @cLoadKey '
         + ' AND PD.LOC = @cLOC '
         + CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END
         + ' AND PD.SKU = @cSKU '
         + ' AND PD.Status = ''4'''
        -- +CASE WHEN @cPickZone <>'' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END
         + ' ORDER BY pd.DropID, pd.Qty DESC'

      -- Custom PickSlip
   ELSE
      SET @cSQL =
          ' SELECT  ROW_NUMBER() OVER (PARTITION BY pd.DropID ORDER BY pd.Qty), '
         + ' pd.PickDetailKey, pd.CaseID, pd.PickHeaderKey, pd.OrderKey, pd.OrderLineNumber, pd.SKU, pd.QTY'
         + ' pd.LOT, pd.StorerKey, pd.UOM, pd.UOMQTY, pd.DropID, pd.Loc, pd.ID, pd.PackKey, pd.CartonGroup,'
         + ' pd.PickMethod, pd.WaveKey'
         + ' FROM dbo.PickDetail pd WITH (NOLOCK)'
         + ' JOIN dbo.Loc LOC WITH (NOLOCK) ON (LOC.LOC=PD.LOC)'
         --+ ' JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) '
         +' WHERE PD.PickSlipNo = @cPickSlipNo '
         +' AND PD.LOC = @cLOC '
         + CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END
         + ' AND PD.SKU = @cSKU '
         + ' AND PD.Status = ''4'''
        -- + CASE WHEN @cPickZone <>'' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END
         + ' ORDER BY pd.DropID, pd.Qty DESC'

   SET @cSQL =
           ' INSERT INTO #tShortPickDetails ( PKDRowRef, '
         + '  PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, '
         + '  Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, '
         + ' PickMethod, WaveKey) '
         +  @cSQL
   SET @cSQLParam =
           ' @cPickSlipNo NVARCHAR( 10), ' +
           ' @cOrderKey   NVARCHAR( 10), ' +
           ' @cLoadKey    NVARCHAR( 10), ' +
           ' @@cPickZoneHeader   NVARCHAR( 10), ' +
           ' @cLOC        NVARCHAR( 10), ' +
           ' @cID         NVARCHAR( 18), ' +
           ' @cSKU        NVARCHAR( 20) '

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'GET SQL'
      SELECT @cSQL as 'SQL'
      SELECT 'GET SQL Params'
      SELECT @cPickSlipNo as PickSlipNo, @cOrderKey as OrderKey,@cLoadKey as LoadKey, @cPickZoneHeader as PickZone ,@cLOC as LOC, @cID as ID ,@cSKU as SKU
   END

   EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @cPickSlipNo, @cOrderKey, @cLoadKey, @cPickZoneHeader, @cLOC, @cID, @cSKU



--    INSERT INTO #tShortPickDetails ( PKDRowRef,
--       PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY,
--       Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup,
--       PickMethod, WaveKey)
--    SELECT  ROW_NUMBER() OVER (PARTITION BY pd.DropID ORDER BY pd.Qty), --V1.0.1
--            pd.PickDetailKey, pd.CaseID, pd.PickHeaderKey, pd.OrderKey, pd.OrderLineNumber, pd.SKU, pd.QTY,
--            pd.LOT, pd.StorerKey, pd.UOM, pd.UOMQTY, pd.DropID, pd.Loc, pd.ID, pd.PackKey, pd.CartonGroup,
--            pd.PickMethod, pd.WaveKey
--    FROM dbo.PickDetail pd WITH (NOLOCK)
--    JOIN PICKHEADER ph on ph.orderkey = pd.OrderKey
--    WHERE pd.Storerkey = @cStorerKey
--       AND ph.PickHeaderKey = @cPickSlipNo
--       AND pd.Status = '4'
--       AND pd.Loc = @cLOC
--       AND pd.SKU = @cSKU
--    ORDER BY pd.DropID, pd.Qty DESC

   IF (SELECT COUNT (*) FROM #tShortPickDetails) = 0
   BEGIN
      SET @nErrNo = 240007
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No record found
      GOTO Quit
   END

   SELECT
      @cTotalShortQty = SUM(QTY),
      @cWaveKey = MAX(WAVEKEY),
      @cLottable01 = MAX(LA.Lottable01),
      @cLoadKey = MAX(LPD.LoadKey) --v1.0.1
   FROM #tShortPickDetails t
   JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) --v1.0.1
        ON LPD.OrderKey = t.OrderKey
   JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
        ON t.Lot = LA.Lot
           AND LA.StorerKey = t.Storerkey


   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Get short pickdetail info'
      SELECT * FROM #tShortPickDetails
      SELECT @cTotalShortQty AS TotalShortQty, @cWaveKey AS WaveKey, @cLottable01 AS Lottable01, @cLoadKey AS Loadkey
   END

--    -- Get all candidate pickzone for this SKU
--    -- For PUMA one wave, one pickzone only has one pickslipno
--    INSERT INTO @tPickZoneCandidate ( PickZone, PickSlipNo, Priority)
--    SELECT @cPickZone, @cPickSlipNo, 1
--    UNION ALL
--    SELECT LOC.PickZone, PD.PickSlipNo, 99
--       FROM dbo.PickDetail PD WITH (NOLOCK)
--       INNER JOIN dbo.LOC WITH (NOLOCK)
--          ON PD.Loc = LOC.Loc
--          AND LOC.Facility = @cFacility
--       INNER JOIN dbo.PickHeader PH WITH (NOLOCK)
--          ON PD.PickSlipNo = PH.PickHeaderKey
--          AND PD.Storerkey = PH.StorerKey
--       INNER JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK)
--          ON LPD.OrderKey = PD.OrderKey
--       WHERE PD.StorerKey = @cStorerKey
--          AND PD.Status = '0'
--          AND PD.Loc <> @cLOC
--          AND LOC.PickZone <> @cPickZone
--          AND ISNULL(LOC.PickZone, '') <> ''
--          AND PD.WaveKey = @cWaveKey
--          AND LPD.LoadKey = @cLoadKey --v1.0.1
--          AND LOC.Facility = @cFacility
--          --AND EXISTS ( --v1.0.1
--          --   SELECT 1
--          --   FROM #tShortPickDetails TSPD
--          --   WHERE TSPD.OrderKey = PD.OrderKey
--          --)
--       GROUP BY LOC.PickZone, PD.PickSlipNo

   INSERT INTO @tPutawayZoneCandidate (PutawayZone, Priority)
      SELECT value, IIF(value = @cPutawayZone, 1, 99) AS Priority
      FROM STRING_SPLIT(
          (SELECT ConfigDesc FROM rdt.storerconfig WITH (NOLOCK)
           WHERE StorerKey = @cStorerKey
             AND configkey = 'ExtScnSP'
             AND Svalue = 'rdt_830ExtScn02'), ',')
      WHERE value IS NOT NULL AND LTRIM(RTRIM(value)) <> ''

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Get candidate Putawayzone'
      SELECT * FROM @tPutawayZoneCandidate ORDER BY Priority, PutawayZone
   END

   IF @cType = 'SKU'
   BEGIN
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'SKU Type'
         SELECT 'Finding suggestted loc'
      END

      --Get candidate LLI
      SELECT TOP 1
         @cSuggestLOC = LLI.Loc,
         @cSuggestID = LLI.ID,
         @cSuggestPutawayZone = PZ.PutawayZone
      FROM dbo.lotxlocxid LLI WITH (NOLOCK)
      JOIN dbo.LOC LOC WITH (NOLOCK)
         ON LLI.Loc = LOC.Loc
         AND LOC.Facility = @cFacility
      JOIN dbo.lotattribute LA WITH (NOLOCK)
           ON LLI.Lot = LA.Lot
            AND LA.StorerKey = LLI.StorerKey
      JOIN @tPutawayZoneCandidate PZ
         ON LOC.PutawayZone = PZ.PutawayZone
      WHERE LLI.StorerKey = @cStorerKey
         AND (LOC.LocationFlag = 'None' OR LOC.LocationFlag = '')
         AND LOC.Status = 'OK'
        AND LA.Lottable01 = @cLottable01
        AND LLI.SKU = @cSKU
         AND LLI.Loc <> @cLOC
      GROUP BY LOC.Loc, LLI.Loc, LLI.ID,  PZ.Priority, PZ.PutawayZone
      HAVING SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) >= @cTotalShortQty
      ORDER BY PZ.Priority, MAX(LOC.LogicalLocation), LOC.Loc;

      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = -1
         SET @cPickSlipNo = ''
         SET @cPickZone = ''
         SET @cLot = ''
         SET @cSuggestLOC = ''
         SET @cSuggestID = ''
         SET @cErrMsg = 'Loc not found'
         GOTO Quit
      END

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Find suggestted loc'
         SELECT @cSuggestLOC AS SuggestLoc, @cSuggestID AS SuggestID, @cSuggestPutawayZone AS SuggestPutawayZone, @cSuggestPSNO AS SuggestPSNO
      END

      -- start re-allocation
      SET @nLoopIndex = 1

      SELECT @nRowCount = COUNT(1)
      FROM #tShortPickDetails

      SET @nTranCount = @@TRANCOUNT

      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_PickReallo02_SKU -- For rollback or commit only our own transaction

      --Go through short pick details
      WHILE @nLoopIndex <= @nRowCount
      BEGIN
         SELECT TOP 1
            @cPickDetailKey = PickDetailKey,
            @nPickDetailQty = QTY
         FROM #tShortPickDetails
         WHERE PKDRowRef = @nLoopIndex

         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Handling short Pickdetail'
            SELECT @nLoopIndex AS LoopIndex, @nRowCount AS TotalRow, @cPickDetailKey AS PickDetailKey, @nPickDetailQty AS PickDetailQty
         END

         INSERT INTO @tAvailableLots (Lot, AvailableQty, AllocatedQty)
            SELECT
               LLI.Lot,
               SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) AS AvailableQty,
               SUM(ISNULL(t.QTY,0)) AS AllocatedQty
            FROM dbo.lotxlocxid LLI WITH (NOLOCK)
            JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
               ON LLI.StorerKey = LA.StorerKey
               AND LLI.Lot = LA.Lot
            LEFT JOIN (
               SELECT Lot, SUM(QTY) AS QTY
               FROM @tAllocation
               GROUP BY Lot
            ) t
               ON LLI.Lot = t.Lot
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.SKU = @cSKU
               AND LLI.Loc = @cSuggestLOC
               AND LLI.ID = @cSuggestID
               AND LA.Lottable01 = @cLottable01
               AND LLI.Lot NOT IN (SELECT Lot FROM @tAllocation)
            GROUP BY LLI.Lot
            HAVING SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) - SUM(ISNULL(t.QTY,0)) > 0
            ORDER BY LLI.Lot DESC

         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Get available Lot'
            SELECT * FROM @tAvailableLots
         END

         --initiate parameters for lot looping
         DECLARE @nRemainingQty INT = @nPickDetailQty
         DECLARE @cOldPickDetailKey NVARCHAR (10) = ''

         WHILE @nRemainingQty > 0
         BEGIN
            SELECT TOP 1
               @cAllocatedLot = Lot,
               @nBal_Qty = AvailableQty - AllocatedQty
            FROM @tAvailableLots
            WHERE AvailableQty > AllocatedQty
            ORDER BY AvailableQty DESC

            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 240013
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No enough lot found
               GOTO RollBack_SKU
            END

            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Remaining PKD Qty', @nRemainingQty, 'Allocating lot:', @cAllocatedLot AS Lot, @nBal_Qty AS BalQty
               SELECT 'OldPickDetailKey', @cOldPickDetailKey AS OldPickDetailKey
            END

            IF @nBal_Qty >= @nRemainingQty
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Bal_Qty >= PickDetail Qty'

               IF @cOldPickDetailKey <> ''
               BEGIN
                  EXECUTE dbo.nspg_GetKey
                  'PICKDETAILKEY',
                  10 ,
                  @cNewPickDetailKey OUTPUT,
                  @bSuccess          OUTPUT,
                  @nErrNo            OUTPUT,
                  @cErrMsg           OUTPUT

                  IF @bSuccess <> 1
                  BEGIN
                     SET @nErrNo = 240014
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail
                     GOTO RollBack_SKU
                  END
               END--oldpickdetailkey

               INSERT INTO @tAllocation (PickDetailKey,
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY,
                  Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, PickMethod, WaveKey,
                  PickSlipNo, NewFlag)
               SELECT CASE WHEN @cOldPickDetailKey = '' THEN PickDetailKey ELSE @cNewPickDetailKey END,
                     CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, @nRemainingQty,
                     @cAllocatedLot, StorerKey, UOM, UOMQty, DropID, @cSuggestLOC, @cSuggestID, PackKey, CartonGroup, PickMethod, WaveKey,
                     @cSuggestPSNO, NewFlag
               FROM #tShortPickDetails
               WHERE PickDetailKey = @cPickDetailKey

               SET @nRemainingQty = 0
            END
            ELSE -- BalQty < ReaminingQty
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'BAL_Qty < PickDetail Qty'

               IF @cOldPickDetailKey <> ''
               BEGIN
                  EXECUTE dbo.nspg_GetKey
                  'PICKDETAILKEY',
                  10 ,
                  @cNewPickDetailKey OUTPUT,
                  @bSuccess          OUTPUT,
                  @nErrNo            OUTPUT,
                  @cErrMsg           OUTPUT

                  IF @bSuccess <> 1
                  BEGIN
                     SET @nErrNo = 240017
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail
                     GOTO RollBack_SKU
                  END
               END--oldpickdetailkey

               INSERT INTO @tAllocation (PickDetailKey,
                           CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY,
                           Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, PickMethod, WaveKey,
                           PickSlipNo, NewFlag)
               SELECT CASE WHEN @cOldPickDetailKey = '' THEN PickDetailKey ELSE @cNewPickDetailKey END,
                     CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, @nBal_Qty,
                     @cAllocatedLot, StorerKey, UOM, UOMQty, DropID, @cSuggestLOC, @cSuggestID, PackKey, CartonGroup, PickMethod, WaveKey,
                     @cSuggestPSNO, NewFlag
               FROM #tShortPickDetails
               WHERE PickDetailKey = @cPickDetailKey

               IF @cOldPickDetailKey = ''
                  SET @cOldPickDetailKey = @cPickDetailKey

               SET @nRemainingQty -= @nBal_Qty

               IF @nDebugFlag = 1
                  SELECT @nRemainingQty AS RemainingQty

               DELETE FROM @tAvailableLots WHERE Lot = @cAllocatedLot
               IF @nDebugFlag = 1
               BEGIN
                  SELECT 'Delete lot from AvailableLots table', @cAllocatedLot AS lot
                  SELECT 'new available Lot'
                  SELECT * FROM @tAvailableLots
               END
            END -- BalQty < ReaminingQty

            IF @nDebugFlag = 2
            BEGIN
               INSERT dbo.TraceInfo (TraceName, TimeIn, Step1, Step2,
               Step3, Step4, Step5,
               Col1, Col2, Col3, Col4, Col5)
               VALUES('rdt_PickRello01', GETDATE(), CAST(@nFunc AS NVARCHAR(10)), 'Type SKU',
                  CAST(@nLoopIndex AS NVARCHAR(10)), CAST(@nRowCount AS NVARCHAR(10)), CAST(@nMobile AS NVARCHAR(10)),
                  @cPickDetailKey, @cSuggestLOC, @cSuggestID, @cAllocatedLot, '')
            END
         END --loop lot for the short pick detail

         --Get next short pick detail
         --Clear the availablelots and refill in with the latest temp allocated result
         DELETE FROM @tAvailableLots

         IF @nDebugFlag = 1
         BEGIN
            SELECT '@tAllocation Table after handing each PKD'
            SELECT * FROM @tAllocation
            SELECT 'Delete AvailableLots temp table for next refill'
         END

         SET @nLoopIndex += 1
      END -- end of short pkd loop

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Allocation finished'
         SELECT 'ShortPickDetail'
         SELECT * FROM #tShortPickDetails
         SELECT 'Allocation result'
         SELECT * FROM @tAllocation
         SELECT 'Unallocate short pickdetail'
      END

      --Handle the pysical tables based on re-allocaton result
      --Unallocate the
      BEGIN TRY
         UPDATE PD WITH (ROWLOCK)
         SET PD.Status = '0',
             PD.Qty = 0,
             PD.EditDate = GETDATE(),
             PD.EditWho = SUSER_SNAME()
         FROM dbo.PickDetail PD WITH (ROWLOCK)
         JOIN #tShortPickDetails T
            ON PD.PickDetailKey = T.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 240015
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PKD failed
         GOTO RollBack_SKU
      END CATCH

      --Set PKD notes
      SET @cPKDNotes = 'Alternate allocation for short from ' + @cUserName + ' for ' + @cPickSlipNo

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Generate PKDNotes', @cPKDNotes AS PKDNotes
         SELECT 'Update phyical PKD with reallocation result'
      END

      --Reallocate the pickdetail to new LLI
      BEGIN TRY
         MERGE dbo.PickDetail AS target
         USING @tAllocation AS source
            ON target.PickDetailKey = source.PickDetailKey
         WHEN MATCHED THEN
            UPDATE SET
               target.Qty = source.QTY,
               target.Loc = source.Loc,
               target.ID = source.ID,
               target.Lot = source.Lot,
               target.PickSlipNo = source.PickSlipNo,
               target.EditDate = GETDATE(),
               target.EditWho = SUSER_SNAME(),
               target.Notes = @cPKDNotes
         WHEN NOT MATCHED BY TARGET THEN
            INSERT (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, Qty,
                  Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup,
                  PickMethod, WaveKey, PickSlipNo, Status, EditDate, EditWho, Notes)
            VALUES (source.PickDetailKey, source.CaseID, source.PickHeaderKey, source.OrderKey, source.OrderLineNumber, source.SKU, source.QTY,
                  source.Lot, source.StorerKey, source.UOM, source.UOMQty, source.DropID, source.Loc, source.ID, source.PackKey, source.CartonGroup,
                  source.PickMethod, source.WaveKey, source.PickSlipNo, '0', GETDATE(), SUSER_SNAME(), @cPKDNotes);
      END TRY
      BEGIN CATCH
         SET @nErrNo = 240016
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PKD failed
         GOTO RollBack_SKU
      END CATCH

      --Update RefKeyLookup
      -- V1.0.2 Start
      BEGIN TRY
         MERGE dbo.RefKeyLookup AS target
         USING @tAllocation AS source
            ON target.PickDetailKey = source.PickDetailKey
         WHEN MATCHED THEN
            UPDATE SET
               target.PickSlipNo = source.PickSlipNo,
               target.EditDate = GETDATE(),
               target.EditWho = SUSER_SNAME()
         WHEN NOT MATCHED BY TARGET THEN
            INSERT (PickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, EditDate, EditWho )
            VALUES (source.PickDetailKey, source.PickSlipNo, source.OrderKey, source.OrderLineNumber,  GETDATE(), SUSER_SNAME());
      END TRY
      BEGIN CATCH
         SET @nErrNo = 240019
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Merge to RefKeyLookup failed
         GOTO RollBack_SKU
      END CATCH
      -- V1.0.2 End

      COMMIT_SKU:
         COMMIT TRAN rdt_PickReallo02_SKU -- Only commit change made here

      GOTO Quit
   END -- SKU


   ROLLBACK_UCC:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'ROLLBACK UCC'
         SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      END
      ROLLBACK TRAN rdt_PickReallo02_UCC -- Only rollback change made here
      GOTO Quit

   ROLLBACK_SKU:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'ROLLBACK SKU'
         SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      END
      ROLLBACK TRAN rdt_PickReallo02_SKU -- Only rollback change made here
      GOTO Quit

   Quit:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Quit rdt_PickReallo02'
         SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @cPickSlipNo AS PickSlipNo, @cPickZone AS PickZone, @cLot AS Lot, 
               @cSuggestLOC AS SuggestLoc, @cSuggestID AS SuggestID
      END

      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON [RDT].[rdt_PickReallo02] TO NSQL
GO


