
/************************************************************************/
/* Store procedure: rdt_PickReallo05                                    */
/* Copyright      : Maersk                                              */
/* Customer       : GM                                                  */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-02-03 1.0.0  JCH507   FCR-10041 Re-allocation if short happens  */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_PickReallo05] (
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
      @cSuggestPickZone    NVARCHAR(10),
      @cSuggestPSNO        NVARCHAR(10),
      @cPickDetailKey      NVARCHAR(18),
      @cNewPickDetailKey   NVARCHAR(18),
      @cPKDNotes           NVARCHAR(1024),
      @cUserName           NVARCHAR(128),
      @cLottable01         NVARCHAR(10),
      @nPickDetailQty      INT,
      @cTotalShortQty      INT,
      @cWaveKey            NVARCHAR(10),
      @cLoadKey            NVARCHAR(10), 
      @cShortUCCNo         NVARCHAR(20),
      @nShortUCCQty        INT,
      @cShortUCCStatus     NVARCHAR(1),
      
      @nBal_Qty            INT,
      @cAllocatedQty       INT,
      @cAllocatedLot       NVARCHAR(10),
      @cAllocatedID        NVARCHAR(18),

      @bSuccess            BIT,
      @nTranCount          INT,
      @nRowCount           INT,
      @nLoopIndex          INT,
      @nPKDRowCount        INT, --V1.0.1
      @nUCCRowCount        INT, --V1.0.1
      @nPKDLoopIndex       INT, --V1.0.1
      @nUCCLoopIndex       INT  --V1.0.1

   DECLARE @tShortPickDetails TABLE
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

   DECLARE @tConsolidatedAllocation TABLE
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
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   DECLARE @tAvailableIDLots TABLE
   (
      ID             NVARCHAR(18),
      Lot            NVARCHAR(10),
      AvailableQty   INT,
      AllocatedQty   INT
   )

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Running rdt_PickReallo05'
   END

   --General validation
   IF @cType <> 'SKU'
   BEGIN
      SET @nErrNo = 258201
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cSKU, '') = ''
   BEGIN
      SET @nErrNo = 258202
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cPickZone, '') = ''
   BEGIN
      SET @nErrNo = 258203
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cLOC, '') = ''
   BEGIN
      SET @nErrNo = 258204
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cPickSlipNo, '') = ''
   BEGIN
      SET @nErrNo = 258205
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   --IF ISNULL(@cLot, '') = ''
   --BEGIN
      --SET @nErrNo = 235656
      --SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      --GOTO Quit
   --END

   SELECT @cUserName = UserName FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Short PKD query parameters', @cStorerKey AS Storer, @cPickSlipNo AS PSNO, 
               @cLOC AS LOC, @cID AS ID, @cSKU AS SKU, @cLot AS LOT

   INSERT INTO @tShortPickDetails ( PKDRowRef,
                                    PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
                                    Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
                                    PickMethod, WaveKey)
   SELECT  ROW_NUMBER() OVER (PARTITION BY DropID ORDER BY Qty), --V1.0.1
         PickDetailKey, CaseID, PD.PickHeaderKey, PD.OrderKey, OrderLineNumber, SKU, QTY, 
         LOT, PD.StorerKey, UOM, UOMQTY, DropID, Loc, ID, PackKey, CartonGroup, 
         PickMethod, PD.WaveKey
   FROM dbo.PickDetail PD WITH (NOLOCK)
   JOIN dbo.PickHeader PH WITH (NOLOCK) 
      ON PD.OrderKey = PH.OrderKey
   WHERE PD.Storerkey = @cStorerKey
      AND PH.PickHeaderKey = @cPickSlipNo
      AND PD.Status = '4'
      AND Loc = @cLOC
      AND SKU = @cSKU
   ORDER BY DropID, Qty DESC 

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 258207
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No record found
      GOTO Quit
   END

   SELECT 
      @cTotalShortQty = SUM(QTY)
   FROM @tShortPickDetails t

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Get short pickdetail info'
      SELECT * FROM @tShortPickDetails
      SELECT @cTotalShortQty AS TotalShortQty
   END

   IF @cType = 'SKU' --Fnc839
   BEGIN
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'SKU Type'
         SELECT 'Finding suggestted loc'
      END

      --Get candidate LLI
      SELECT TOP 1
         @cSuggestLOC = LLI.Loc,
         --@cSuggestID = LLI.ID,
         @cSuggestPickZone = MAX(LOC.PickZone),
         @cSuggestPSNO = @cPickSlipNo
      FROM dbo.lotxlocxid LLI WITH (NOLOCK)
      JOIN dbo.LOC LOC WITH (NOLOCK)
         ON LLI.Loc = LOC.Loc
         AND LOC.Facility = @cFacility
      WHERE LLI.StorerKey = @cStorerKey
         AND LOC.LocationFlag = 'None'
         AND LOC.Status = 'OK'
         AND LLI.SKU = @cSKU
         AND LLI.Loc <> @cLOC
      GROUP BY LOC.Loc, LLI.Loc
      HAVING SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) >= @cTotalShortQty
      ORDER BY 
         CASE WHEN MAX(LOC.PickZone) = @cPickZone THEN 0 ELSE 1 END,
         MAX(LOC.LogicalLocation),
         LOC.Loc;

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
         SELECT @cSuggestLOC AS SuggestLoc, @cSuggestID AS SuggestID, @cSuggestPickZone AS SuggestPickZone, @cSuggestPSNO AS SuggestPSNO
      END

      -- start re-allocation
      SET @nLoopIndex = 1

      SELECT @nRowCount = COUNT(1)
      FROM @tShortPickDetails

      SET @nTranCount = @@TRANCOUNT

      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_PickReallo05_SKU -- For rollback or commit only our own transaction

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

         INSERT INTO @tAvailableIDLots (ID, Lot, AvailableQty, AllocatedQty)
            SELECT
               LLI.ID, 
               LLI.Lot,
               SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) AS AvailableQty,
               SUM(ISNULL(t.QTY,0)) AS AllocatedQty
            FROM dbo.lotxlocxid LLI WITH (NOLOCK)
            LEFT JOIN (
                     SELECT ID, Lot, SUM(QTY) AS QTY
                     FROM @tAllocation
                     GROUP BY ID, Lot
                     ) t
               ON LLI.Lot = t.Lot
               AND LLI.ID = t.ID
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.SKU = @cSKU
               AND LLI.Loc = @cSuggestLOC
               --AND LLI.ID = @cSuggestID
               --AND LLI.Lot NOT IN (SELECT Lot FROM @tAllocation)
            GROUP BY LLI.ID,LLI.Lot
            HAVING SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) - SUM(ISNULL(t.QTY,0)) > 0
            ORDER BY LLI.Lot DESC

         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Get available Lot'
            SELECT * FROM @tAvailableIDLots
         END
         
         --initiate parameters for lot looping
         DECLARE @nRemainingQty INT = @nPickDetailQty
         DECLARE @cOldPickDetailKey NVARCHAR (10) = ''

         WHILE @nRemainingQty > 0
         BEGIN
            SELECT TOP 1
               @cAllocatedID  = ID,
               @cAllocatedLot = Lot,
               @nBal_Qty = AvailableQty - AllocatedQty
            FROM @tAvailableIDLots
            WHERE AvailableQty > AllocatedQty
            ORDER BY AvailableQty DESC, ID

            IF @@ROWCOUNT = 0 
            BEGIN
               SET @nErrNo = 258213
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No enough lot found
               GOTO RollBack_SKU
            END

            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Remaining PKD Qty', @nRemainingQty, 'Allocating ID ' + @cAllocatedID, 'Allocating lot:' + @cAllocatedLot AS Lot, @nBal_Qty AS BalQty
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
                     SET @nErrNo = 258214
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
                     @cAllocatedLot, StorerKey, UOM, UOMQty, DropID, @cSuggestLOC, @cAllocatedID, PackKey, CartonGroup, PickMethod, WaveKey, 
                     @cSuggestPSNO, NewFlag
               FROM @tShortPickDetails
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
                     SET @nErrNo = 258217
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
                     @cAllocatedLot, StorerKey, UOM, UOMQty, DropID, @cSuggestLOC, @cAllocatedID, PackKey, CartonGroup, PickMethod, WaveKey, 
                     @cSuggestPSNO, NewFlag
               FROM @tShortPickDetails
               WHERE PickDetailKey = @cPickDetailKey

               IF @cOldPickDetailKey = ''
                  SET @cOldPickDetailKey = @cPickDetailKey

               SET @nRemainingQty -= @nBal_Qty

               IF @nDebugFlag = 1
                  SELECT @nRemainingQty AS RemainingQty

               DELETE FROM @tAvailableIDLots WHERE Lot = @cAllocatedLot AND ID = @cAllocatedID
               IF @nDebugFlag = 1
               BEGIN
                  SELECT 'Delete lot from AvailableLots table', @cAllocatedLot AS lot, @cAllocatedID AS ID
                  SELECT 'new available Lot'
                  SELECT * FROM @tAvailableIDLots
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
         DELETE FROM @tAvailableIDLots

         IF @nDebugFlag = 1
         BEGIN
            SELECT '@tAllocation Table after handing each PKD'
            SELECT * FROM @tAllocation
            SELECT 'Delete AvailableLots temp table for next refill'
         END

         SET @nLoopIndex += 1
      END -- end of short pkd loop

      INSERT INTO @tConsolidatedAllocation (PickDetailKey, 
                           CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
                           Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
                           PickMethod, WaveKey, PickSlipNo)
      SELECT 
         MIN(PickDetailKey) ,   
         MIN(CaseID), '', OrderKey, OrderLineNumber, MAX(SKU), SUM(QTY),             
         Lot, @cStorerKey, 6, SUM(UOMQty), MIN(DropID), Loc, ID, MAX(PackKey), NULL,      
         MAX(PickMethod), WaveKey, PickSlipNo 
      FROM @tAllocation
      GROUP BY WaveKey, PickSlipNo, OrderKey, OrderLineNumber, Loc, ID, Lot     

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Allocation finished'
         SELECT 'ShortPickDetail'
         SELECT * FROM @tShortPickDetails
         SELECT 'Allocation result'
         SELECT * FROM @tAllocation
         SELECT 'Consolidate allo result'
         SELECT * FROM @tConsolidatedAllocation
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
         SET @nErrNo = 258215
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
         USING @tConsolidatedAllocation AS source
            ON target.PickDetailKey = source.PickDetailKey
         WHEN MATCHED THEN
            UPDATE SET 
               target.Qty = source.QTY,
               target.Loc = source.Loc,
               target.ID = source.ID,
               target.Lot = source.Lot,
               --target.PickSlipNo = source.PickSlipNo,
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
         SET @nErrNo = 258216
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PKD failed
         GOTO RollBack_SKU
      END CATCH

      --Update RefKeyLookup
      IF EXISTS(SELECT 1 FROM dbo.RefKeyLookup WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo)
      BEGIN TRY
         MERGE dbo.RefKeyLookup AS target
         USING @tConsolidatedAllocation AS source
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
         SET @nErrNo = 258219
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Merge to RefKeyLookup failed
         GOTO RollBack_SKU
      END CATCH

      COMMIT_SKU:
         COMMIT TRAN rdt_PickReallo05_SKU -- Only commit change made here

      SET @cPickZone = @cSuggestPickZone
      SET @cPickSlipNo = @cSuggestPSNO

      GOTO Quit
   END -- SKU

   ROLLBACK_SKU:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'ROLLBACK SKU'
         SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      END
      ROLLBACK TRAN rdt_PickReallo05_SKU -- Only rollback change made here
      GOTO Quit

   Quit:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Quit rdt_PickReallo05'
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

GRANT EXEC ON [RDT].[rdt_PickReallo05] TO NSQL
GO


