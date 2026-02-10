
/************************************************************************/
/* Store procedure: rdt_PickReallo04                                    */
/* Copyright      : Maersk                                              */
/* Customer       :                                                     */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2025-11-12 1.0.0  Dennis   FCR-7949 created                          */
/************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_PickReallo04] (
   @nMobile             INT          
   ,@nFunc              INT          
   ,@cLangCode          NVARCHAR( 3) 
   ,@cFacility          NVARCHAR( 5) 
   ,@cStorerKey         NVARCHAR( 15)
   ,@cPickSlipNo        NVARCHAR( 10)  OUTPUT
   ,@tAdditionalData    VariableTable  READONLY
   ,@cType              NVARCHAR( 5) --ID
   ,@cLOC               NVARCHAR( 10)
   ,@cID                NVARCHAR( 18)
   ,@cSKU               NVARCHAR( 20)
   ,@nQTY               INT = 0
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
   DECLARE @nDebugFlag  INT = 1 --1 print log, 2 insert trace info

   DECLARE
      @cPickDetailKey      NVARCHAR(18),
      @cNewPickDetailKey   NVARCHAR(18),
      @cPKDNotes           NVARCHAR(1024),
      @cUserName           NVARCHAR(128),
      @nPickDetailQty      INT,
      @cTotalShortQty      INT,
      @cWaveKey            NVARCHAR(10),
      @cLoadKey            NVARCHAR(10),
      @cShortUCCNo         NVARCHAR(20),
      @nShortUCCQty        INT,
      @cShortUCCStatus     NVARCHAR(1),
      
      @nBal_Qty            INT,
      @cAllocatedQty       INT,
      @cAllocatedUCC       NVARCHAR(20),
      @cAllocatedLot       NVARCHAR(10),

      @bSuccess            BIT,
      @nTranCount          INT,
      @nRowCount           INT,
      @nLoopIndex          INT,
      @nPKDRowCount        INT, 
      @nUCCRowCount        INT, 
      @nPKDLoopIndex       INT, 
      @nUCCLoopIndex       INT  
   DECLARE @cOrderKey   NVARCHAR( 10)    
   DECLARE @cZone       NVARCHAR( 18)  
   DECLARE @tShortPickDetails TABLE
   (
      PKDRowRef         INT IDENTITY(1,1),
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

   DECLARE @cSQL      NVARCHAR( MAX)
   DECLARE @cSQLParam NVARCHAR( MAX)

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
   DECLARE @cVerifyID         NVARCHAR( 1)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)
   DECLARE @tPickZoneCandidate TABLE
   (
      PickZone         NVARCHAR( 10) NOT NULL,
      PickSlipNo       NVARCHAR( 10) NOT NULL,
      Priority         INT           NOT NULL DEFAULT 99
   )
   
   DECLARE @tAvailableLots TABLE
   (
      Lot            NVARCHAR(10),
      AvailableQty   INT,
      AllocatedQty   INT
   )
   SET @cVerifyID = rdt.RDTGetConfig( @nFunc, 'VerifyID', @cStorerKey)
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Running rdt_PickReallo04'
   END

   --General validation
   IF @cType NOT IN ('SKU')
   BEGIN
      SET @nErrNo = 249301
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cLOC, '') = ''
   BEGIN
      SET @nErrNo = 249303
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cPickSlipNo, '') = ''
   BEGIN
      SET @nErrNo = 249304
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   SELECT @cUserName = UserName FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Short PKD query parameters', @cStorerKey AS Storer, @cLOC AS LOC, @cID AS ID

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   IF @nDebugFlag = 1
      SELECT 'Short PKD query parameters', @cOrderKey AS OrderKey, @cLoadKey AS Loadkey, @cZone AS Zone
   
   IF @cZone IN ('XD', 'LB', 'LP')
   BEGIN
      INSERT INTO @tShortPickDetails (
         PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
         Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
         PickMethod, WaveKey
      )
      SELECT 
         PD.PickDetailKey, PD.CaseID, PD.PickHeaderKey, PD.OrderKey, PD.OrderLineNumber, PD.SKU, PD.QTY, 
         PD.LOT, PD.StorerKey, PD.UOM, PD.UOMQTY, PD.DropID, PD.Loc, PD.ID, PD.PackKey, PD.CartonGroup, 
         PD.PickMethod, PD.WaveKey
      FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
      JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
      JOIN dbo.Loc LOC WITH (NOLOCK) ON (LOC.LOC=PD.LOC)
      JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)
      WHERE RKL.PickSlipNo = @cPickSlipNo 
        AND PD.LOC = @cLOC 
        AND (@cVerifyID <> '1' OR PD.ID = @cID)
        AND PD.SKU = @cSKU 
        AND PD.QTY > 0
        AND PD.Status = '4'
   END
   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
   BEGIN
      INSERT INTO @tShortPickDetails (
         PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
         Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
         PickMethod, WaveKey
      )
      SELECT 
         PD.PickDetailKey, PD.CaseID, PD.PickHeaderKey, PD.OrderKey, PD.OrderLineNumber, PD.SKU, PD.QTY, 
         PD.LOT, PD.StorerKey, PD.UOM, PD.UOMQTY, PD.DropID, PD.Loc, PD.ID, PD.PackKey, PD.CartonGroup, 
         PD.PickMethod, PD.WaveKey
      FROM dbo.PickDetail PD WITH (NOLOCK)
      JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
      JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)
      WHERE PD.OrderKey = @cOrderKey 
        AND PD.LOC = @cLOC 
        AND (@cVerifyID <> '1' OR PD.ID = @cID)
        AND PD.SKU = @cSKU 
        AND PD.QTY > 0
        AND PD.Status = '4'
   END
   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
   BEGIN
      INSERT INTO @tShortPickDetails (
         PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
         Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
         PickMethod, WaveKey
      )
      SELECT 
         PD.PickDetailKey, PD.CaseID, PD.PickHeaderKey, PD.OrderKey, PD.OrderLineNumber, PD.SKU, PD.QTY, 
         PD.LOT, PD.StorerKey, PD.UOM, PD.UOMQTY, PD.DropID, PD.Loc, PD.ID, PD.PackKey, PD.CartonGroup, 
         PD.PickMethod, PD.WaveKey
      FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
      JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
      JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
      JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)
      WHERE LPD.LoadKey = @cLoadKey 
        AND PD.LOC = @cLOC 
        AND (@cVerifyID <> '1' OR PD.ID = @cID)
        AND PD.SKU = @cSKU 
        AND PD.QTY > 0
        AND PD.Status = '4'
   END
   -- Custom PickSlip
   ELSE
   BEGIN
      INSERT INTO @tShortPickDetails (
         PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
         Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
         PickMethod, WaveKey
      )
      SELECT 
         PD.PickDetailKey, PD.CaseID, PD.PickHeaderKey, PD.OrderKey, PD.OrderLineNumber, PD.SKU, PD.QTY, 
         PD.LOT, PD.StorerKey, PD.UOM, PD.UOMQTY, PD.DropID, PD.Loc, PD.ID, PD.PackKey, PD.CartonGroup, 
         PD.PickMethod, PD.WaveKey
      FROM dbo.PickDetail PD WITH (NOLOCK)
      JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
      JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT)
      WHERE PD.PickSlipNo = @cPickSlipNo 
        AND PD.LOC = @cLOC 
        AND (@cVerifyID <> '1' OR PD.ID = @cID)
        AND PD.SKU = @cSKU 
        AND PD.QTY > 0
        AND PD.Status = '4'
   END

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 249306
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No record found
      GOTO Quit
   END

   SELECT 
      @cTotalShortQty = SUM(QTY),
      @cWaveKey = MAX(WAVEKEY)
   FROM @tShortPickDetails t
   JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
      ON t.LOT = LA.Lot
      AND LA.StorerKey = t.StorerKey

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Get short pickdetail info'
      SELECT * FROM @tShortPickDetails
      SELECT @cTotalShortQty AS TotalShortQty, @cWaveKey AS WaveKey, @cLoadKey AS Loadkey, @cSKU AS SKU
   END

   IF @cType = 'SKU' --Fnc830
   BEGIN
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'SKU Type'
         SELECT 'Finding suggestted loc','@cFacility'+@cFacility,'@cStorerKey'+@cStorerKey,'@cID'+@cID,'@cSKU'+@cSKU,'@cTotalShortQty'+CAST(@cTotalShortQty AS NVARCHAR(10))
      END

      --Get candidate LLI
      SELECT TOP 1
         @cSuggestLOC = Agg.Loc,
         @csuggestID = Agg.ID
      FROM
      (
         SELECT
            LLI.Loc,
            LLI.ID,
            MIN(LOC.LogicalLocation) AS MinLogicLoc,
            MIN(LA.Lottable04) AS MinLottable04
         FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
         JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
            ON LLI.Lot = LA.Lot
            AND LA.StorerKey = LLI.StorerKey
         JOIN dbo.LOC LOC WITH (NOLOCK)
            ON LLI.Loc = LOC.Loc
            AND LOC.Facility = @cFacility
         WHERE LLI.StorerKey = @cStorerKey
           AND LOC.LocationFlag IN ('None', '')
           AND LOC.Status = 'OK'
           AND LLI.SKU = @cSKU
           AND ISNULL(LLI.ID,'') <> ISNULL(@cID,'')
           AND NOT EXISTS (
              SELECT 1
              FROM dbo.InventoryHold H WITH (NOLOCK)
              WHERE StorerKey = @cStorerKey
               AND (H.LOC = LLI.LOC OR H.ID = LLI.ID)
            )
            AND NOT EXISTS (
               SELECT 1 FROM dbo.Replenishment rpl WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND rpl.Id = LLI.ID
                  AND Confirmed <> 'Y'
            )
         GROUP BY LLI.Loc, LLI.SKU, LLI.ID
         HAVING SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) >= @cTotalShortQty
            AND SUM(LLI.QtyAllocated) = 0
            AND SUM(LLI.QtyPicked) = 0
            AND SUM(LLI.QtyReplen) = 0
      ) Agg
      ORDER BY Agg.MinLottable04 ASC, Agg.MinLogicLoc, Agg.Loc

      IF @@ROWCOUNT = 0
      BEGIN
         IF @nDebugFlag = 1
            BEGIN
               SELECT 'Loc Not Found'
            END
         BEGIN TRY
            UPDATE PICKDETAIL WITH (ROWLOCK)
            SET Qty = 0
            WHERE PickDetailKey IN (SELECT PickDetailKey FROM @tShortPickDetails)

            DELETE FROM PickDetail
            WHERE PickDetailKey IN (SELECT PickDetailKey FROM @tShortPickDetails)
         END TRY
         BEGIN CATCH
            SET @nErrNo = 249313
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Delete PKD failed
            GOTO Quit
         END CATCH   

         SET @nErrNo = -1 
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
         SELECT @cSuggestLOC AS SuggestLoc
      END

      -- start re-allocation
      SET @nLoopIndex = 1

      SELECT @nRowCount = COUNT(1)
      FROM @tShortPickDetails

      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_PickReallo04_ID -- For rollback or commit only our own transaction

      --Go through short pick details
      WHILE @nLoopIndex <= @nRowCount
      BEGIN
         SELECT TOP 1
            @cPickDetailKey = PickDetailKey,
            @nPickDetailQty = QTY
         FROM @tShortPickDetails
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
         DECLARE @cShortPickDetailKey NVARCHAR (10) = ''

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
               SET @nErrNo = 249307
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No enough lot found
               GOTO RollBack_ID
            END

            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Remaining PKD Qty', @nRemainingQty, 'Allocating lot:', @cAllocatedLot AS Lot, @nBal_Qty AS BalQty
               SELECT 'ShortPickDetailKey', @cShortPickDetailKey AS OldPickDetailKey
            END

            IF @nBal_Qty >= @nRemainingQty
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Bal_Qty >= PickDetail Qty'

               IF @cShortPickDetailKey <> ''
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
                     SET @nErrNo = 249308
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail
                     GOTO RollBack_ID
                  END
               END--oldpickdetailkey

               MERGE INTO @tAllocation AS target
                  USING (
                    SELECT 
                      CASE WHEN @cShortPickDetailKey = '' THEN PickDetailKey ELSE @cNewPickDetailKey END AS PickDetailKey,
                      CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, @nRemainingQty AS QTY,
                      @cAllocatedLot AS Lot, StorerKey, UOM, UOMQty, DropID, @cSuggestLOC AS Loc, @cSuggestID AS ID,
                      PackKey, CartonGroup, PickMethod, WaveKey, @cPickSlipNo AS PickSlipNo,
                      CASE WHEN @cShortPickDetailKey = '' THEN NewFlag ELSE 'Y' END AS NewFlag
                    FROM @tShortPickDetails
                    WHERE PickDetailKey = @cPickDetailKey
                  ) AS source
                  ON
                    target.CaseID = source.CaseID AND
                    target.OrderKey = source.OrderKey AND
                    target.OrderLineNumber = source.OrderLineNumber AND
                    target.SKU = source.SKU AND
                    target.Lot = source.Lot AND
                    target.StorerKey = source.StorerKey AND
                    target.UOM = source.UOM AND
                    ISNULL(target.DropID, '') = ISNULL(source.DropID, '') AND
                    target.Loc = source.Loc AND
                    target.ID = source.ID AND
                    target.PackKey = source.PackKey AND
                    ISNULL(target.CartonGroup, '') = ISNULL(source.CartonGroup, '') AND
                    target.PickMethod = source.PickMethod AND
                    ISNULL(target.WaveKey, '') = ISNULL(source.WaveKey, '') AND
                    ISNULL(target.PickSlipNo, '') = ISNULL(source.PickSlipNo, '')
                  WHEN MATCHED THEN
                    UPDATE SET target.QTY = target.QTY + source.QTY
                  WHEN NOT MATCHED BY TARGET THEN
                    INSERT (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
                          Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, PickMethod, WaveKey, 
                          PickSlipNo, NewFlag)
                    VALUES (source.PickDetailKey, source.CaseID, source.PickHeaderKey, source.OrderKey, source.OrderLineNumber, source.SKU, source.QTY, 
                          source.Lot, source.StorerKey, source.UOM, source.UOMQty, source.DropID, source.Loc, source.ID, source.PackKey, source.CartonGroup, source.PickMethod, source.WaveKey, 
                          source.PickSlipNo, source.NewFlag);

               SET @nRemainingQty = 0
            END
            ELSE -- BalQty < ReaminingQty
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'BAL_Qty < PickDetail Qty'

               IF @cShortPickDetailKey <> ''
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
                     SET @nErrNo = 235667
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail
                     GOTO RollBack_ID
                  END
               END--oldpickdetailkey
                  MERGE INTO @tAllocation AS target
                  USING (
                    SELECT 
                      CASE WHEN @cShortPickDetailKey = '' THEN PickDetailKey ELSE @cNewPickDetailKey END AS PickDetailKey,
                      CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, @nBal_Qty AS QTY,
                      @cAllocatedLot AS Lot, StorerKey, UOM, UOMQty, DropID, @cSuggestLOC AS Loc, @cSuggestID AS ID,
                      PackKey, CartonGroup, PickMethod, WaveKey, @cPickSlipNo AS PickSlipNo,
                      CASE WHEN @cShortPickDetailKey = '' THEN NewFlag ELSE 'Y' END AS NewFlag
                    FROM @tShortPickDetails
                    WHERE PickDetailKey = @cPickDetailKey
                  ) AS source
                  ON
                    target.CaseID = source.CaseID AND
                    target.OrderKey = source.OrderKey AND
                    target.OrderLineNumber = source.OrderLineNumber AND
                    target.SKU = source.SKU AND
                    target.Lot = source.Lot AND
                    target.StorerKey = source.StorerKey AND
                    target.UOM = source.UOM AND
                    ISNULL(target.DropID, '') = ISNULL(source.DropID, '') AND
                    target.Loc = source.Loc AND
                    target.ID = source.ID AND
                    target.PackKey = source.PackKey AND
                    ISNULL(target.CartonGroup, '') = ISNULL(source.CartonGroup, '') AND
                    target.PickMethod = source.PickMethod AND
                    ISNULL(target.WaveKey, '') = ISNULL(source.WaveKey, '') AND
                    ISNULL(target.PickSlipNo, '') = ISNULL(source.PickSlipNo, '')
                  WHEN MATCHED THEN
                    UPDATE SET target.QTY = target.QTY + source.QTY
                  WHEN NOT MATCHED BY TARGET THEN
                    INSERT (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
                          Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, PickMethod, WaveKey, 
                          PickSlipNo, NewFlag)
                    VALUES (source.PickDetailKey, source.CaseID, source.PickHeaderKey, source.OrderKey, source.OrderLineNumber, source.SKU, source.QTY, 
                          source.Lot, source.StorerKey, source.UOM, source.UOMQty, source.DropID, source.Loc, source.ID, source.PackKey, source.CartonGroup, source.PickMethod, source.WaveKey, 
                          source.PickSlipNo, source.NewFlag);

               IF @cShortPickDetailKey = ''
                  SET @cShortPickDetailKey = @cPickDetailKey

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
               VALUES('rdt_PickReallo04', GETDATE(), CAST(@nFunc AS NVARCHAR(10)), 'Type ID', 
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
         SELECT * FROM @tShortPickDetails
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
         JOIN @tShortPickDetails T
            ON PD.PickDetailKey = T.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 249310
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PKD failed
         GOTO RollBack_ID
      END CATCH

      SET @cPKDNotes = 'Alternate pick requested by ' + @cUserName

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Generate PKDNotes', @cPKDNotes AS PKDNotes
         SELECT 'Update phyical PKD with reallocation result'
      END

      --Reallocate the pickdetail to new LLI
      BEGIN TRY
--          --overcome FK_PICKDETAIL_LOTLOCID_01
--          INSERT INTO dbo.LOTxLOCxID (LOT, LOC, ID, StorerKey, SKU)
--          SELECT DISTINCT Lot, Loc, ID, Storerkey, SKU
--          FROM @tAllocation A
--          WHERE NOT EXISTS (
--             SELECT 1 FROM dbo.LOTxLOCxID L
--             WHERE L.Lot = A.Lot
--               AND L.Loc = A.Loc
--               AND L.ID = A.ID
--          )

         MERGE dbo.PickDetail AS target
         USING @tAllocation AS source
            ON target.PickDetailKey = source.PickDetailKey
         WHEN MATCHED THEN
            UPDATE SET 
               target.Qty = source.QTY,
               target.Loc = source.Loc,
               target.ID = source.ID,
               target.Lot = source.Lot,
               target.EditDate = GETDATE(),
               target.EditWho = SUSER_SNAME(),
               target.notes = 'Alter pick requested by ' + @cUserName
         WHEN NOT MATCHED BY TARGET THEN
            INSERT (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, Qty, 
                  Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
                  PickMethod, PickSlipNo, WaveKey, Status, EditDate, EditWho, Notes)
            VALUES (source.PickDetailKey, source.CaseID, source.PickHeaderKey, source.OrderKey, source.OrderLineNumber, source.SKU, source.QTY, 
                  source.Lot, source.StorerKey, source.UOM, source.UOMQty, source.DropID, source.Loc, source.ID, source.PackKey, source.CartonGroup, 
                  source.PickMethod, '', source.WaveKey, '0', GETDATE(), SUSER_SNAME(), 'Alter pick requested by ' + @cUserName);
      END TRY
      BEGIN CATCH
         IF @nDebugFlag = 1
         BEGIN
            SELECT ERROR_MESSAGE()
         END
         SET @nErrNo = 249311
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PKD failed
         GOTO RollBack_ID
      END CATCH

      IF EXISTS (SELECT 1 FROM 
                  dbo.RefKeyLookup REF WITH (NOLOCK) 
                  JOIN dbo.PickDetail PKD WITH (NOLOCK)
                     ON REF.PickDetailKey = PKD.PickDetailKey
                  WHERE PKD.StorerKey = @cStorerKey
                     AND PKD.ID = @cID)
      BEGIN
         --Update RefKeyLookup
         BEGIN TRY
            MERGE dbo.RefKeyLookup AS target
            USING @tAllocation AS source
               ON target.PickDetailKey = source.PickDetailKey
            WHEN NOT MATCHED BY TARGET THEN
               INSERT (PickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, EditDate, EditWho )
               VALUES (source.PickDetailKey, source.PickSlipNo, source.OrderKey, source.OrderLineNumber,  GETDATE(), SUSER_SNAME());
         END TRY
         BEGIN CATCH
            SET @nErrNo = 249312
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Merge to RefKeyLookup failed
            GOTO RollBack_ID
         END CATCH
      END

      COMMIT_ID:
         COMMIT TRAN rdt_PickReallo04_ID -- Only commit change made here

      GOTO Quit
   END -- ID

   ROLLBACK_ID:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'ROLLBACK ID'
         SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      END
      IF @nTranCount > 0 AND XACT_STATE() <> -1
         ROLLBACK TRAN rdt_PickReallo04_ID -- Only rollback change made here
      ELSE
         ROLLBACK TRAN
      GOTO Quit

   Quit:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Quit rdt_PickReallo04'
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

GRANT EXEC ON [RDT].[rdt_PickReallo04] TO NSQL
GO


