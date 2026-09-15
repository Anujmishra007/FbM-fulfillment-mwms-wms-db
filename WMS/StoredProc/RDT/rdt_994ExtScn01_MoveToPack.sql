
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/*******************************************************************************************************/
/* Store procedure: rdt_994ExtScn01_MoveToPack                                                         */
/* Copyright      : Maersk                                                                             */
/* Customer       : AEOMX                                                                              */
/*                                                                                                     */
/*                                                                                                     */
/* Date        Rev    Author     Purposes                                                              */
/* 2026-09-10  1.0.0  JackC      FCR-16295 Move Inv to pack, Upd pkd.dropid                            */
/*                                to one dummy value                                                   */
/* 2026-09-15  1.0.1  JackC      FCR-16295 Skip move inventory, update dropid and set UCC status to 6  */
/*******************************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_994ExtScn01_MoveToPack] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cOrderKey      NVARCHAR( 10),
   @cLoadKey       NVARCHAR( 10),
   @cWaveKey       NVARCHAR( 10),
   @cPickSlipNo    NVARCHAR( 10),
   @cWaveType      NVARCHAR( 20),
   @cPickStatus    NVARCHAR( 1),
   @cMoveQTYAlloc  NVARCHAR( 1),
   @cMoveQTYPick   NVARCHAR( 1),
   @cUserName      NVARCHAR( 18),
   @nDebugFlag     INT            = 0,
   @nErrNo         INT            OUTPUT,
   @cErrMsg        NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cPackSTGLoc    NVARCHAR( 10),
      @cMoveSKU       NVARCHAR( 20),
      @cMoveLot       NVARCHAR( 10),
      @cMoveFromLoc   NVARCHAR( 10),
      @cMoveToLoc     NVARCHAR( 10),
      @cMoveFromID    NVARCHAR( 18),
      @cMoveToID      NVARCHAR( 18),
      @cMoveOrderKey  NVARCHAR( 10),
      @nQTYAlloc      INT,
      @nQTYPick       INT,
      @nMoveQty       INT,
      @nCounter       INT

   --V1.0.1 remove inventory movement
   /*
   DECLARE @tMoveList TABLE (
      RowNumber   INT IDENTITY(1,1) PRIMARY KEY,
      FromLoc     NVARCHAR( 10) NOT NULL,
      FromID      NVARCHAR( 18) NOT NULL,
      ToLoc       NVARCHAR( 10) NOT NULL,
      ToID        NVARCHAR( 18) NOT NULL,
      SKU         NVARCHAR( 20) NOT NULL,
      Lot         NVARCHAR( 10) NOT NULL,
      Qty         INT           NOT NULL,
      OrderKey    NVARCHAR( 10) NOT NULL,
      REMARK      NVARCHAR( 100)
   )
   */

   DECLARE @tPD TABLE (
      PickDetailKey   NVARCHAR( 18) NOT NULL PRIMARY KEY CLUSTERED,
      CaseID          NVARCHAR( 20) NOT NULL,
      OrderKey        NVARCHAR( 10) NOT NULL,
      OrderLineNumber NVARCHAR( 5)  NOT NULL,
      UOM             NVARCHAR( 10)  NOT NULL,
      Lot             NVARCHAR( 10) NOT NULL,
      SKU             NVARCHAR( 20) NOT NULL,
      DropID          NVARCHAR( 20) NOT NULL,
      Loc             NVARCHAR( 10) NOT NULL,
      ID              NVARCHAR( 18) NOT NULL,
      Qty             INT           NOT NULL
   )

   DECLARE @tUCC TABLE (
      UCCNo       NVARCHAR( 20) NOT NULL,
      UCCRowRef   INT NOT NULL PRIMARY KEY CLUSTERED
   )

   DECLARE @tMerged TABLE (
      KeepPickDetailKey NVARCHAR( 18) NOT NULL PRIMARY KEY CLUSTERED,
      OrderKey          NVARCHAR( 10) NOT NULL,
      OrderLineNumber   NVARCHAR( 5)  NOT NULL,
      Loc               NVARCHAR( 10) NOT NULL,
      ID                NVARCHAR( 18) NOT NULL,
      CaseID            NVARCHAR( 20) NOT NULL,
      Lot               NVARCHAR( 10) NOT NULL,
      MergedQty         INT           NOT NULL,
      RecordCount       INT           NOT NULL
   )

   /* --1.0.1 remove inventory movment
   -- Determine Pack Staging location by wave type
   SET @cPackSTGLoc = ''

   IF @cWaveType = 'ECOM'
      SET @cPackSTGLoc = 'AEOMX_PAKE'
   ELSE IF @cWaveType = 'WHSLE'
      SET @cPackSTGLoc = 'AEOMX_PAKW'
   ELSE IF @cWaveType = 'RTL'
      SET @cPackSTGLoc = 'AEOMX_PAKR'
   ELSE
   BEGIN
      SET @cPackSTGLoc = ''
      SET @nErrNo = 281001
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pack Staging loc not defined
      GOTO Quit
   END

   IF @cPackSTGLoc <> '' AND NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE Loc = @cPackSTGLoc AND Facility = @cFacility)
   BEGIN
      SET @nErrNo = 281002
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pack Staging loc not exists
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Pack Staging location', @cPackSTGLoc AS PackSTGLoc

   -- Populate move list
   BEGIN TRY
      IF ISNULL(@cOrderKey, '') <> ''
      BEGIN
         INSERT INTO @tMoveList (FromLoc, FromID, ToLoc, ToID, SKU, Lot, Qty, OrderKey, REMARK)
         SELECT
            Loc,
            ID,
            @cPackSTGLoc, --Toloc
            @cPickSlipNo, --ToID
            SKU,
            LOT,
            SUM(QTY),
            OrderKey,
            ''
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND OrderKey = @cOrderKey
            AND Status   = @cPickStatus
            AND Qty > 0
         GROUP BY Loc, ID, OrderKey, SKU, LOT
      END
      ELSE IF ISNULL(@cLoadKey, '') <> ''
      BEGIN
         INSERT INTO @tMoveList (FromLoc, FromID, ToLoc, ToID, SKU, Lot, Qty, OrderKey, REMARK)
         SELECT
            PD.Loc,
            PD.ID,
            @cPackSTGLoc, --ToLoc
            @cPickSlipNo, --ToID
            PD.SKU,
            PD.LOT,
            SUM(PD.QTY),
            PD.OrderKey,
            ''
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
         JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.OrderKey = LPD.OrderKey
         WHERE LPD.LoadKey   = @cLoadKey
            AND PD.StorerKey = @cStorerKey
            AND PD.Status    = @cPickStatus
            AND PD.Qty > 0
         GROUP BY PD.Loc, PD.ID, PD.OrderKey, PD.SKU, PD.LOT
      END
   END TRY
   BEGIN CATCH
      SET @nErrNo = 281003
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert tMoveList failed
      GOTO Quit
   END CATCH

   -- Validate move list is not empty
   IF NOT EXISTS (SELECT 1 FROM @tMoveList)
   BEGIN
      SET @nErrNo = 281004
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PickDetail not found
      GOTO Quit
   END

   -- Validate config
   IF @cMoveQTYAlloc <> '1' AND @cMoveQTYPick <> '1'
   BEGIN
      SET @nErrNo = 281005
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   IF @cMoveQTYAlloc = '1' AND @cPickStatus = '5'
   BEGIN
      SET @nErrNo = 281006
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   IF @cMoveQTYPick = '1' AND @cPickStatus < '5'
   BEGIN
      SET @nErrNo = 281007
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IncorrectSetup
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'MoveList', * FROM @tMoveList
   */

   -- Execute moves
   -- Handling transaction
   DECLARE @nTranCount  INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_994ExtScn01_MoveToPack -- For rollback or commit only our own transaction

   SET @nCounter = 0

   --V1.0.1 remove inventory movement
   /*
   WHILE 1 = 1
   BEGIN
      SELECT TOP 1
         @nCounter    = RowNumber,
         @cMoveFromLoc = FromLoc,
         @cMoveToLoc  = ToLoc,
         @cMoveFromID = FromID,
         @cMoveToID   = ToID,
         @cMoveSKU    = SKU,
         @cMoveLot    = Lot,
         @nMoveQty    = Qty,
         @cMoveOrderKey = OrderKey
      FROM @tMoveList
      WHERE RowNumber > @nCounter
      ORDER BY RowNumber

      IF @@ROWCOUNT = 0
         BREAK

      IF @nDebugFlag = 1
         SELECT 'Moving inventory', @nCounter AS RowNumber, @cMoveFromLoc AS FromLoc, @cMoveToLoc AS ToLoc,
            @cMoveFromID AS FromID, @cMoveToID AS ToID, @cMoveSKU AS SKU, @cMoveLot AS Lot,
            @nMoveQty AS Qty, @cMoveOrderKey AS OrderKey

      IF @cMoveQTYAlloc = '1'
      BEGIN
         SET @nQTYAlloc = @nMoveQty
         SET @nQTYPick  = 0
      END
      ELSE
      BEGIN
         SET @nQTYAlloc = 0
         SET @nQTYPick  = @nMoveQty
      END

      IF @cMoveFromLoc = @cMoveToLoc AND @cMoveFromID = @cMoveToID
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Skip rdt_Move: same loc and ID, no movement needed',
               @cMoveFromLoc AS FromLoc, @cMoveFromID AS FromID, @cMoveToLoc AS ToLoc, @cMoveToID AS ToID
      END
      ELSE
      BEGIN
         EXECUTE rdt.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode,
            @nErrNo      = @nErrNo  OUTPUT,
            @cErrMsg     = @cErrMsg OUTPUT,
            @cSourceType = '994ExtScn01_MoveToPack',
            @cStorerKey  = @cStorerKey,
            @cFacility   = @cFacility,
            @cFromLOC    = @cMoveFromLoc,
            @cToLoc      = @cMoveToLoc,
            @cFromID     = @cMoveFromID,
            @cToID       = @cMoveToID,
            @cSKU        = @cMoveSKU,
            @nQTY        = @nMoveQty,
            @nQTYAlloc   = @nQTYAlloc,
            @nQTYPick    = @nQTYPick,
            @cFromLOT    = @cMoveLot,
            @cOrderKey   = @cMoveOrderKey,
            @nFunc       = @nFunc
         IF @nErrNo <> 0
            GOTO RollbackTran
      END

      BEGIN TRY
         EXEC RDT.rdt_STD_EventLog
            @cActionType    = '4', -- Move
            @cUserID        = @cUserName,
            @nMobileNo      = @nMobile,
            @nFunctionID    = @nFunc,
            @cFacility      = @cFacility,
            @cStorerKey     = @cStorerKey,
            @cLocation      = @cMoveFromLoc,
            @cToLocation    = @cMoveToLoc,
            @cID            = @cMoveFromID,
            @cToID          = @cMoveToID,
            @cSKU           = @cMoveSKU,
            @nQTY           = @nMoveQty,
            @cLOT           = @cMoveLot,
            @cOrderKey      = @cMoveOrderKey,
            @cPickSlipNo    = @cPickSlipNo
      END TRY
      BEGIN CATCH
         IF @nDebugFlag = 1
            SELECT 'Ins Event log failed'
      END CATCH
   END -- end loop
   */

   -- Merge PickDetail DropIDs to @cPickSlipNo
   IF @nDebugFlag = 1
      SELECT 'Merge PickDetail DropID to PickSlipNo', @cPickSlipNo AS NewDropID

   IF @cOrderKey <> ''
   BEGIN
      BEGIN TRY
         INSERT INTO @tPD (PickDetailKey, OrderKey, OrderLineNumber, UOM, Lot, SKU, DropID, Loc, ID, CaseID, Qty)
         SELECT PD.PickDetailKey, PD.OrderKey, PD.OrderLineNumber, PD.UOM, PD.Lot, PD.SKU, PD.DropID, PD.Loc, PD.ID, PD.CaseID, PD.Qty
         FROM dbo.PickDetail PD WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND PD.OrderKey  = @cOrderKey
            AND PD.Status    = @cPickStatus
            AND PD.Qty > 0
            AND PD.CaseID <> PD.ID -- get rid of the packed but not PackConfirmed pickdetails
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281001
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsPDFailed
         GOTO RollbackTran
      END CATCH
   END
   ELSE IF @cLoadKey <> ''
   BEGIN
      BEGIN TRY
         INSERT INTO @tPD (PickDetailKey, OrderKey, OrderLineNumber, UOM, Lot, SKU, DropID, Loc, ID, CaseID, Qty)
         SELECT PD.PickDetailKey, PD.OrderKey, PD.OrderLineNumber, PD.UOM, PD.Lot, PD.SKU, PD.DropID, PD.Loc, PD.ID, PD.CaseID, PD.Qty
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)
         JOIN dbo.PickDetail PD WITH (NOLOCK) ON PD.OrderKey = LPD.OrderKey
         WHERE PD.StorerKey = @cStorerKey
            AND LPD.LoadKey  = @cLoadKey
            AND PD.Status    = @cPickStatus
            AND PD.Qty > 0
            AND PD.CaseID <> PD.ID -- get rid of the packed but not PackConfirmed pickdetails
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281002
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsPDFailed
         GOTO RollbackTran
      END CATCH
   END

   IF EXISTS (SELECT 1 FROM @tPD) 
   BEGIN
      --V1.0.1 Get all UCCs
      BEGIN TRY
         INSERT INTO @tUCC (UCCNo, UCCRowRef)
         SELECT DISTINCT UCCNo, UCC_RowRef
         FROM dbo.UCC WITH (NOLOCK)
         JOIN @tPD PD 
            ON UCC.UCCNo = PD.DropID
            AND PD.UOM = '2'
         WHERE StorerKey = @cStorerKey
            AND UCC.Status <> '6'
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281003
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --InsUCCFailed
         GOTO RollbackTran
      END CATCH

      BEGIN TRY
         INSERT INTO @tMerged (KeepPickDetailKey, OrderKey, OrderLineNumber, Loc, ID, CaseID, Lot, MergedQty, RecordCount)
         SELECT MIN(PickDetailKey), OrderKey,OrderLineNumber, Loc, ID, CaseID, Lot, SUM(Qty), COUNT(1)
         FROM @tPD
         GROUP BY OrderKey, OrderLineNumber, Loc, ID, CaseID, Lot
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281011
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Merge PickDetail failed
         GOTO RollbackTran
      END CATCH

      IF @nDebugFlag = 1
      BEGIN
         SELECT '@tPD to merge'
         SELECT * FROM @tPD
         SELECT '@tMerged'
         SELECT * FROM @tMerged
         SELECT '@tUCC'
         SELECT * FROM @tUCC
      END

      BEGIN TRY
         DELETE PD FROM dbo.PickDetail PD WITH (ROWLOCK)
         JOIN @tPD tPD ON PD.PickDetailKey = tPD.PickDetailKey
         LEFT JOIN @tMerged M ON PD.PickDetailKey = M.KeepPickDetailKey
         WHERE M.KeepPickDetailKey IS NULL
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281008
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Delete merge duplicates failed
         GOTO RollbackTran
      END CATCH

      BEGIN TRY
         UPDATE PD WITH (ROWLOCK) SET
            PD.DropID   = @cPickSlipNo,
            PD.Qty      = M.MergedQty,
            PD.EditDate = GETDATE(),
            PD.EditWho  = 'rdt.' + SUSER_SNAME()
         FROM dbo.PickDetail PD
         INNER JOIN @tMerged M ON PD.PickDetailKey = M.KeepPickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281009
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update DropID/Qty failed
         GOTO RollbackTran
      END CATCH

      BEGIN TRY
         UPDATE UCC WITH (ROWLOCK) SET
            UCC.Status   = '6',
            UCC.EditDate = GETDATE(),
            UCC.EditWho  = 'rdt.' + SUSER_SNAME()
         FROM dbo.UCC UCC
         INNER JOIN @tUCC tUCC ON UCC.UCC_RowRef = tUCC.UCCRowRef
      END TRY
      BEGIN CATCH
         SET @nErrNo = 281010
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update UCC status failed
         GOTO RollbackTran
      END CATCH

      CommitTran:
         COMMIT TRANSACTION rdt_994ExtScn01_MoveToPack
      GOTO Quit
   END

   GOTO Quit

   RollbackTran:
      IF @nDebugFlag = 1
         SELECT 'Rolling back transaction'

      IF XACT_STATE() = -1
         ROLLBACK TRANSACTION
      ELSE IF XACT_STATE() = 1
         ROLLBACK TRANSACTION rdt_994ExtScn01_MoveToPack

   Quit:
      IF @nDebugFlag = 1
         SELECT 'Exiting rdt_994ExtScn01_MoveToPack', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg

      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_994ExtScn01_MoveToPack] TO NSQL
GO
