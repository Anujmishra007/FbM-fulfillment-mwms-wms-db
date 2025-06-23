
/************************************************************************/
/* Store procedure: rdt_PickReallo01                                    */
/* Copyright      : Maersk                                              */
/* Customer       : PUMACL                                              */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2025-03-26 1.0.0  JCH507   FCR-2704 Re-allocation if short happens   */
/* 2025-04-15 1.0.1  JCH507   FCR-2704 Support PickDetail.UOM = 7       */
/* 2025-04-24 1.0.2  NLT013   FCR-2704 Update RefKeyLookup              */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_PickReallo01] (
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
      @cLoadKey            NVARCHAR(10), --v1.0.1
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
      SELECT 'Running rdt_PickReallo01'
   END

   --General validation
   IF @cType NOT IN ('UCC', 'SKU')
   BEGIN
      SET @nErrNo = 235651
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cSKU, '') = ''
   BEGIN
      SET @nErrNo = 235652
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cPickZone, '') = ''
   BEGIN
      SET @nErrNo = 235653
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cLOC, '') = ''
   BEGIN
      SET @nErrNo = 235654
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cPickSlipNo, '') = ''
   BEGIN
      SET @nErrNo = 235655
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF ISNULL(@cLot, '') = ''
   BEGIN
      SET @nErrNo = 235656
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   SELECT @cUserName = UserName FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Short PKD query parameters', @cStorerKey AS Storer, @cPickSlipNo AS PSNO, 
               @cLOC AS LOC, @cID AS ID, @cSKU AS SKU, @cLot AS LOT

   INSERT INTO @tShortPickDetails ( PKDRowRef,
                                    PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
                                    Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, 
                                    PickMethod, WaveKey)
   SELECT  ROW_NUMBER() OVER (PARTITION BY DropID ORDER BY Qty), --V1.0.1
         PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
         LOT, StorerKey, UOM, UOMQTY, DropID, Loc, ID, PackKey, CartonGroup, 
         PickMethod, WaveKey
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE Storerkey = @cStorerKey
      AND PickSlipNo = @cPickSlipNo
      AND Status = '4'
      AND Loc = @cLOC
      AND (@cType = 'SKU'OR ID = @cID) -- 839 doesn't passin ID value
      AND SKU = @cSKU
      --AND Lot = @cLot -- Exclude lot, because 839 will combine all lots in one pick.
   ORDER BY DropID, Qty DESC --v1.0.1

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 235657
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No record found
      GOTO Quit
   END

   SELECT 
      @cTotalShortQty = SUM(QTY),
      @cWaveKey = MAX(WAVEKEY),
      @cLottable01 = MAX(LA.Lottable01),
      @cLoadKey = MAX(LPD.LoadKey) --v1.0.1
   FROM @tShortPickDetails t
   JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
      ON t.LOT = LA.Lot
      AND LA.StorerKey = t.Storerkey
   JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK) --v1.0.1
      ON LPD.OrderKey = t.OrderKey

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Get short pickdetail info'
      SELECT * FROM @tShortPickDetails
      SELECT @cTotalShortQty AS TotalShortQty, @cWaveKey AS WaveKey, @cLottable01 AS Lottable01, @cLoadKey AS Loadkey
   END

   -- Get all candidate pickzone for this SKU
   -- For PUMA one wave, one pickzone only has one pickslipno
   INSERT INTO @tPickZoneCandidate ( PickZone, PickSlipNo, Priority)
   SELECT @cPickZone, @cPickSlipNo, 1
   UNION ALL
   SELECT LOC.PickZone, PD.PickSlipNo, 99
      FROM dbo.PickDetail PD WITH (NOLOCK)
      INNER JOIN dbo.LOC WITH (NOLOCK) 
         ON PD.Loc = LOC.Loc
         AND LOC.Facility = @cFacility
      INNER JOIN dbo.PickHeader PH WITH (NOLOCK)
         ON PD.PickSlipNo = PH.PickHeaderKey
         AND PD.Storerkey = PH.StorerKey
      INNER JOIN dbo.LoadPlanDetail LPD WITH (NOLOCK)
         ON LPD.OrderKey = PD.OrderKey
      WHERE PD.StorerKey = @cStorerKey
         AND PD.Status = '0'
         AND PD.Loc <> @cLOC
         AND LOC.PickZone <> @cPickZone
         AND ISNULL(LOC.PickZone, '') <> ''
         AND PD.WaveKey = @cWaveKey
         AND LPD.LoadKey = @cLoadKey --v1.0.1
         AND LOC.Facility = @cFacility
         --AND EXISTS ( --v1.0.1
         --   SELECT 1
         --   FROM @tShortPickDetails TSPD
         --   WHERE TSPD.OrderKey = PD.OrderKey
         --)
      GROUP BY LOC.PickZone, PD.PickSlipNo

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Get candidate pickzone'
      SELECT * FROM @tPickZoneCandidate ORDER BY Priority, PickZone
   END
   
   IF @cType = 'UCC'
   BEGIN
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'UCC Type'
         SELECT 'Finding suggestted loc'
      END
      
      --Get Candidate LLI
      SELECT TOP 1
         @cSuggestLOC = LLI.Loc,
         @cSuggestID = LLI.ID,
         @cSuggestPickZone = PZ.PickZone,
         @cSuggestPSNO = PZ.PickSlipNo
      FROM dbo.lotxlocxid LLI WITH (NOLOCK)
      JOIN dbo.UCC UCC WITH (NOLOCK)
         ON LLI.Loc = UCC.Loc
         AND LLI.ID = UCC.ID
         AND LLI.Lot = UCC.Lot
         AND LLI.SKU = UCC.SKU
         AND LLI.StorerKey = UCC.StorerKey
         AND UCC.Status = '1'  ---- Only available UCC
      JOIN dbo.lotattribute LA WITH (NOLOCK) 
         ON LLI.Lot = LA.Lot
         AND LA.StorerKey = LLI.StorerKey
      JOIN dbo.LOC LOC WITH (NOLOCK)
         ON LLI.Loc = LOC.Loc
         AND LOC.Facility = @cFacility
      JOIN @tPickZoneCandidate PZ
         ON LOC.PickZone = PZ.PickZone
      WHERE LLI.StorerKey = @cStorerKey
         AND LLI.SKU = @cSKU
         AND LLI.Loc <> @cLOC
         AND LOC.LocationFlag = 'None'
         AND LOC.Status = 'OK'
         AND LA.Lottable01 = @cLottable01
      GROUP BY LOC.Loc, LLI.Loc, LLI.ID,  PZ.Priority, PZ.PickZone, PZ.PickSlipNo
      HAVING COUNT(UCC.ID) >= (SELECT COUNT(DISTINCT DropID)
                                 FROM @tShortPickDetails
                                 WHERE Loc = LLI.Loc) --UCC status = 1 count >= shorted UCC count
         AND SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) >= @cTotalShortQty
      ORDER BY PZ.Priority, PZ.PickZone, MAX(LOC.LogicalLocation), LOC.Loc;

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
         SELECT 'Suggestted loc found'
         SELECT @cSuggestLOC AS SuggestLoc, @cSuggestID AS SuggestID, @cSuggestPickZone AS SuggestPickZone, @cSuggestPSNO AS SuggestPSNO
      END

      --V1.0.1 Fill @tShortUCC table
      INSERT INTO @tShortUCC ( UCCNo, ShortQty)
         SELECT DropID, SUM(QTY)
         FROM @tShortPickDetails
         GROUP BY DropID
         ORDER BY DropID

      IF EXISTS (SELECT 1 FROM @tShortUCC WHERE UCCNo = '')
      BEGIN
         SET @nErrNo = 235668
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Empty DropID in Pickdetail
         GOTO Quit
      END

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Fill in short UCC data'
         SELECT * FROM @tShortUCC
      END

      SET @nUCCLoopIndex = 1

      SELECT @nUCCRowCount = COUNT(1)
      FROM @tShortUCC

      SET @nTranCount = @@TRANCOUNT

      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_PickReallo01_UCC -- For rollback or commit only our own transaction

      WHILE @nUCCLoopIndex <= @nUCCRowCount
      BEGIN
         SELECT TOP 1 
            @cShortUCCNo = UCCNo,
            @nShortUCCQty = ShortQty
         FROM @tShortUCC
         WHERE UCCRowRef = @nUCCLoopIndex

         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Handling UCCNo'
            SELECT @nUCCLoopIndex AS LoopIndex, @nUCCRowCount AS TotalRow, @cShortUCCNo AS ShortUCCNo, @nShortUCCQty AS ShortUCCQty
         END

         SELECT TOP 1
            @cAllocatedUCC = UCCNo,
            @cAllocatedLot = UCC.Lot
         FROM dbo.UCC WITH(NOLOCK)
         JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) 
            ON UCC.Lot = LA.Lot
            AND UCC.StorerKey = LA.StorerKey
         WHERE Loc = @cSuggestLOC
            AND ID = @cSuggestID
            AND UCC.SKU = @cSKU
            AND QTY = @nShortUCCQty
            AND STATUS = '1'
            AND LA.Lottable01 = @cLottable01
            AND NOT EXISTS (
               SELECT 1
               FROM @tAllocation
               WHERE DropID = UCCNo -- UCC not in allocation temp table
            )
         ORDER BY UCCNo;

         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 235658
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No enough UCC
            GOTO RollBack_UCC
         END

         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Reallocate to new UCC', @cAllocatedUCC AS AllocatedUCC, @cAllocatedLot AS AllocatedLot, @cShortUCCNo AS ShortUCCNo
         END

         SET @nPKDLoopIndex = 1

         SELECT @nPKDRowCount = COUNT(1)
         FROM @tShortPickDetails
         WHERE DropID = @cShortUCCNo

         WHILE @nPKDLoopIndex <= @nPKDRowCount
         BEGIN
            SELECT TOP 1
               @cPickDetailKey = PickDetailKey,
               @nPickDetailQty = QTY
            FROM @tShortPickDetails
            WHERE DropID = @cShortUCCNo
               AND PKDRowRef = @nPKDLoopIndex

            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Handling short Pickdetail Under UCC ' + @cShortUCCNo
               SELECT @nPKDLoopIndex AS LoopIndex, @nPKDRowCount AS TotalRow, @cPickDetailKey AS PickDetailKey, @nPickDetailQty AS PickDetailQty, 
               @cAllocatedUCC AS AllocatedUCC, @cAllocatedLot AS AllocatedLot
            END
            ELSE IF @nDebugFlag = 2
            BEGIN
               INSERT dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                  Step3, Step4, Step5,
                  Col1, Col2, Col3, Col4, Col5)
               VALUES('rdt_PickRello01', GETDATE(), CAST(@nFunc AS NVARCHAR(10)), 'Type UCC', 
                  CAST(@nPKDLoopIndex AS NVARCHAR(10)), CAST(@nPKDRowCount AS NVARCHAR(10)), CAST(@nMobile AS NVARCHAR(10)),
                  @cPickDetailKey, @cSuggestLOC, @cSuggestID, @cAllocatedUCC, '')
            END

            INSERT INTO @tAllocation ( PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
               Lot, StorerKey, UOM, UOMQty, DropID, Loc, ID, PackKey, CartonGroup, PickMethod, WaveKey, PickSlipNo)
            SELECT PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, SKU, QTY, 
               @cAllocatedLot, StorerKey, UOM, UOMQty, @cAllocatedUCC, @cSuggestLOC, @cSuggestID, PackKey, CartonGroup, PickMethod, WaveKey, @cSuggestPSNO
            FROM @tShortPickDetails 
            WHERE PickDetailKey = @cPickDetailKey

            SET @nPKDLoopIndex += 1
         END -- end insert @tAllocation loop

         SET @nUCCLoopIndex += 1
      END -- end of loop UCC
      --V1.0.1 end
      

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Allocation finished'
         SELECT * FROM @tAllocation
         SELECT 'Unallocate short pickdetail, short UCC'
      END

      --Handle the pysical tables based on re-allocaton result
      -- Get short UCC status
      SELECT TOP 1
         @cShortUCCStatus = UCC.Status
      FROM dbo.UCC WITH (NOLOCK)
      JOIN @tShortPickDetails T
         ON UCCNo = T.DropID
         AND UCC.Storerkey = T.StorerKey

      -- Unallocate short pickdetail, short UCC
      BEGIN TRY
         UPDATE UCC WITH (ROWLOCK)
         SET Status = '1'
         FROM dbo.UCC
         JOIN @tShortPickDetails T
            ON UCCNo = T.DropID
            AND UCC.Storerkey = T.StorerKey
         WHERE UCC.Status <> '1';
      END TRY
      BEGIN CATCH
         SET @nErrNo = 235659
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update UCC failed
         GOTO RollBack_UCC
      END CATCH

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
         SET @nErrNo = 235660
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PKD failed
         GOTO RollBack_UCC
      END CATCH

      --reallocate new UCC to pickdetail
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Reallocate new UCC to pickdetail'
      END

      BEGIN TRY
         UPDATE UCC WITH (ROWLOCK)
         SET Status = @cShortUCCStatus
         FROM dbo.UCC
         JOIN @tAllocation T
            ON UCCNo = T.DropID
            AND UCC.Storerkey = T.StorerKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 235661
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update UCC failed
         GOTO RollBack_UCC
      END CATCH

      --Set PKD notes
      SET @cPKDNotes = 'Alternate allocation for short from ' + @cUserName + ' for ' + @cPickSlipNo

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Generate PKD notes', @cPKDNotes AS PKDNotes
      END

      BEGIN TRY
         UPDATE PD WITH (ROWLOCK)
         SET PD.Status = '0',
             PD.Qty = T.QTY,
             PD.DropID = T.DropID,
             PD.Loc = T.Loc,
             PD.ID = T.ID,
             PD.Lot = T.Lot,
             PD.EditDate = GETDATE(),
             PD.EditWho = SUSER_SNAME(),
             PD.PickSlipNo = T.PickSlipNo,
             PD.Notes = @cPKDNotes
         FROM dbo.PickDetail PD WITH (ROWLOCK)
         JOIN @tAllocation T
            ON PD.PickDetailKey = T.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 235662
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PKD failed
         GOTO RollBack_UCC
      END CATCH

      --Update RefKeyLookup
      -- V1.0.2 Start
      BEGIN TRY
         UPDATE RKL WITH (ROWLOCK)
         SET RKL.PickSlipNo = T.PickSlipNo,
            RKL.EditDate = GETDATE(),
            RKL.EditWho = SUSER_SNAME()
         FROM dbo.RefKeyLookup RKL
         INNER JOIN @tAllocation T
            ON RKL.PickDetailKey = T.PickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 235670
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Merge to RefKeyLookup failed
         GOTO RollBack_UCC
      END CATCH
      -- V1.0.2 End


      COMMIT_UCC:
         COMMIT TRAN rdt_PickReallo01_UCC -- Only commit change made here

      SET @cPickZone = @cSuggestPickZone
      SET @cPickSlipNo = @cSuggestPSNO

      GOTO Quit

   END -- UCC

   ELSE IF @cType = 'SKU'
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
         @cSuggestPickZone = PZ.PickZone,
         @cSuggestPSNO = PZ.PickSlipNo
      FROM dbo.lotxlocxid LLI WITH (NOLOCK)
      JOIN dbo.lotattribute LA WITH (NOLOCK) 
         ON LLI.Lot = LA.Lot
         AND LA.StorerKey = LLI.StorerKey
      JOIN dbo.LOC LOC WITH (NOLOCK)
         ON LLI.Loc = LOC.Loc
         AND LOC.Facility = @cFacility
      JOIN @tPickZoneCandidate PZ
         ON LOC.PickZone = PZ.PickZone
      WHERE LLI.StorerKey = @cStorerKey
         AND LOC.LocationFlag = 'None'
         AND LOC.Status = 'OK'
         AND LLI.SKU = @cSKU
         AND LLI.Loc <> @cLOC
         AND LA.Lottable01 = @cLottable01
      GROUP BY LOC.Loc, LLI.Loc, LLI.ID,  PZ.Priority, PZ.PickZone, PZ.PickSlipNo
      HAVING SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) >= @cTotalShortQty
      ORDER BY PZ.Priority, PZ.PickZone, MAX(LOC.LogicalLocation), LOC.Loc;

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
      SAVE TRAN rdt_PickReallo01_SKU -- For rollback or commit only our own transaction

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
               AND LA.Lottable01 = @cLottable01
               --AND LLI.Lot NOT IN (SELECT Lot FROM @tAllocation)
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
               SET @nErrNo = 235663
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
                     SET @nErrNo = 235664
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
                     SET @nErrNo = 235667
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
               FROM @tShortPickDetails
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
         SET @nErrNo = 235665
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
         SET @nErrNo = 235666
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
         SET @nErrNo = 235669
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Merge to RefKeyLookup failed
         GOTO RollBack_SKU
      END CATCH
      -- V1.0.2 End

      COMMIT_SKU:
         COMMIT TRAN rdt_PickReallo01_SKU -- Only commit change made here

      SET @cPickZone = @cSuggestPickZone
      SET @cPickSlipNo = @cSuggestPSNO

      GOTO Quit
   END -- SKU


   ROLLBACK_UCC:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'ROLLBACK UCC'
         SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      END
      ROLLBACK TRAN rdt_PickReallo01_UCC -- Only rollback change made here
      GOTO Quit

   ROLLBACK_SKU:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'ROLLBACK SKU'
         SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg
      END
      ROLLBACK TRAN rdt_PickReallo01_SKU -- Only rollback change made here
      GOTO Quit

   Quit:
      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Quit rdt_PickReallo01'
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

GRANT EXEC ON [RDT].[rdt_PickReallo01] TO NSQL
GO


