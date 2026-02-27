
/************************************************************************/
/* Store procedure: rdt_PickReallo03                                    */
/* Copyright      : Maersk                                              */
/* Customer       : South Africa PMI                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2025-10-21 1.0.0  JCH507   FCR-7948 created, for Fn1864              */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_PickReallo03] (
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
   DECLARE @nDebugFlag  INT = 0 --1 print log, 2 insert trace info

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

   DECLARE @tShortPickDetails TABLE
   (
      PKDRowRef         INT  NOT NULL, 
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

   /*
   DECLARE @tShortUCC TABLE 
   (
      UCCRowRef        INT IDENTITY (1, 1)  NOT NULL,
      UCCNo            NVARCHAR( 20) NOT NULL,
      ShortQty         INT           NOT NULL DEFAULT 0
   )*/

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

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Running rdt_PickReallo03'
   END

   --General validation
   IF @cType NOT IN ('ID')
   BEGIN
      SET @nErrNo = 249301
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cID, '') = ''
   BEGIN
      SET @nErrNo = 249302
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

   IF (SELECT COUNT (DISTINCT SKU) 
      FROM dbo.LOTxLOCxID WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey 
         AND ID = @cID) > 1
   BEGIN
      SET @nErrNo = 249305
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- muli SKU
      GOTO Quit
   END

   SELECT @cUserName = UserName FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Short PKD query parameters', @cStorerKey AS Storer, @cLOC AS LOC, @cID AS ID

   INSERT INTO @tShortPickDetails ( PKDRowRef,
                                    PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
                                    Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
                                    PickMethod, WaveKey)
   SELECT  ROW_NUMBER() OVER (PARTITION BY ID ORDER BY Qty), 
         PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
         LOT, StorerKey, UOM, UOMQTY, DropID, Loc, ID, PackKey, CartonGroup, 
         PickMethod, WaveKey
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE Storerkey = @cStorerKey
      AND Loc = @cLOC
      AND ID = @cID
      AND Status = '0'
      AND ShipFlag <> 'Y'
   ORDER BY ID, Qty DESC 

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 249306
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No record found
      GOTO Quit
   END

   SELECT 
      @cTotalShortQty = SUM(QTY),
      @cWaveKey = MAX(WAVEKEY),
      @cLoadKey = MAX(LPD.LoadKey),
      @cSKU = MAX(t.SKU) 
   FROM @tShortPickDetails t
   JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
      ON t.LOT = LA.Lot
      AND LA.StorerKey = t.Storerkey
   JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) 
      ON LPD.OrderKey = t.OrderKey

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Get short pickdetail info'
      SELECT * FROM @tShortPickDetails
      SELECT @cTotalShortQty AS TotalShortQty, @cWaveKey AS WaveKey, @cLoadKey AS Loadkey, @cSKU AS SKU
   END

   IF @cType = 'ID' --Fnc1864
   BEGIN
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'ID Type'
         SELECT 'Finding suggestted loc'
      END

      --Get candidate LLI
      SELECT TOP 1
         @cSuggestLOC = Agg.Loc,
         @cSuggestID = Agg.ID
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
           AND LLI.ID <> @cID
           AND NOT EXISTS (
              SELECT 1
              FROM dbo.InventoryHold H WITH (NOLOCK)
              WHERE StorerKey = @cStorerKey
               AND H.LOC = LLI.LOC OR H.ID = LLI.ID
            )
            AND NOT EXISTS (
               SELECT 1 FROM dbo.Replenishment rpl WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND rpl.Id = LLI.ID
                  AND Confirmed <> 'Y'
            )
         GROUP BY LLI.Loc, LLI.ID
         HAVING SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) = @cTotalShortQty
            AND SUM(LLI.QtyAllocated) = 0
            AND SUM(LLI.QtyPicked) = 0
            AND SUM(LLI.QtyReplen) = 0
      ) Agg
      ORDER BY Agg.MinLottable04 ASC, Agg.MinLogicLoc, Agg.Loc, Agg.ID;

      IF @@ROWCOUNT = 0
      BEGIN
         BEGIN TRY
            DELETE FROM PickDetail
            WHERE StorerKey = @cStorerKey
               AND Status = '0'
               AND ID = @cID
               AND ShipFlag <> 'Y'
         END TRY
         BEGIN CATCH
            SET @nErrNo = 249313
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Delete PKD failed
            GOTO Quit
         END CATCH

         SET @nErrNo = -1 
         --SET @cPickSlipNo = ''
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
         SELECT @cSuggestLOC AS SuggestLoc, @cSuggestID AS SuggestID
      END

      -- start re-allocation
      SET @nLoopIndex = 1

      SELECT @nRowCount = COUNT(1)
      FROM @tShortPickDetails

      SET @nTranCount = @@TRANCOUNT

      IF @nTranCount = 0
         BEGIN TRAN  -- Begin our own transaction
      ELSE
         SAVE TRAN rdt_PickReallo03_ID -- For rollback or commit only our own transaction

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
               VALUES('rdt_PickRello03', GETDATE(), CAST(@nFunc AS NVARCHAR(10)), 'Type ID', 
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
               target.EditWho = SUSER_SNAME()
         WHEN NOT MATCHED BY TARGET THEN
            INSERT (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, Qty, 
                  Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
                  PickMethod, PickSlipNo, WaveKey, Status, EditDate, EditWho, Notes)
            VALUES (source.PickDetailKey, source.CaseID, source.PickHeaderKey, source.OrderKey, source.OrderLineNumber, source.SKU, source.QTY, 
                  source.Lot, source.StorerKey, source.UOM, source.UOMQty, source.DropID, source.Loc, source.ID, source.PackKey, source.CartonGroup, 
                  source.PickMethod, '', source.WaveKey, '0', GETDATE(), SUSER_SNAME(), ISNULL(@cPKDNotes,''));
      END TRY
      BEGIN CATCH
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
         COMMIT TRAN -- Only commit change made here

      GOTO Quit
   END -- ID

   ROLLBACK_ID:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'ROLLBACK ID'
         SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      END
      IF @nTranCount > 0 AND XACT_STATE() <> -1
         ROLLBACK TRAN rdt_PickReallo03_ID -- Only rollback change made here
      ELSE
         ROLLBACK TRAN
      GOTO Quit

   Quit:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Quit rdt_PickReallo03'
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

GRANT EXEC ON [RDT].[rdt_PickReallo03] TO NSQL
GO


