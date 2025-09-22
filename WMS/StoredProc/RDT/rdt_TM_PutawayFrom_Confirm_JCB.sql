
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_TM_PutawayFrom_Confirm_JCB                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 2025-08-05  1.0  Dennis   FCR-3954 Created                           */
/* 2025-08-14  2.0  PPA374   Adding housekeepiing for holds and tasks   */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_TM_PutawayFrom_Confirm_JCB] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @cUserName      NVARCHAR( 18), 
   @cTaskDetailKey NVARCHAR( 10),
   @nErrNo         INT          OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cFromLOT    NVARCHAR( 10)
   DECLARE @cFromLOC    NVARCHAR( 10)
   DECLARE @cFromID     NVARCHAR( 18)
   DECLARE @cToLOC      NVARCHAR( 10)
   DECLARE @cToID       NVARCHAR( 18)
   DECLARE @cStorerKey  NVARCHAR( 15)
   DECLARE @cSKU        NVARCHAR( 20)
   DECLARE @nQTY        INT
   DECLARE @cFacility   NVARCHAR( 5)
   DECLARE @cFinalLOC   NVARCHAR( 10)
   DECLARE @cTransitLOC NVARCHAR( 10)
   DECLARE @cListKey    NVARCHAR( 10)
   DECLARE @cPalType    NVARCHAR( 15)
   DECLARE @cLocRoom    NVARCHAR( 20)
   DECLARE @cUserKey    NVARCHAR( 30)
   DECLARE @cMidLoc     NVARCHAR( 10)
   DECLARE @cTrdLoc     NVARCHAR( 10)
   DECLARE @cFstLoc     NVARCHAR( 10)
   DECLARE @cLocCat     NVARCHAR( 20)

   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''

   -- Get task info
   SELECT 
      @cListKey = ListKey, 
      @cStorerKey = StorerKey, 
      @cFromLOC = FromLOC, 
      @cFromID = FromID, 
      @cToLOC = ToLOC, 
      @cTransitLOC = TransitLOC, 
      @cFinalLOC = FinalLOC
   FROM dbo.TaskDetail WITH (NOLOCK) 
   WHERE TaskDetailKey = @cTaskDetailKey

   IF @cListKey = ''
      SET @cListKey = @cTaskdetailKey

   -- Get LoseID
   DECLARE @cLoseID NVARCHAR(1)
   SELECT @cLoseID = @cLoseID FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC
   IF @cLoseID = '1'
      SET @cToID = ''
   ELSE
      SET @cToID = @cFromID

   -- Get facility
   SELECT @cFacility = Facility FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cFromLOC

   -- Handling transaction
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_TM_PutawayFrom_Confirm_JCB -- For rollback or commit only our own transaction

   -- Execute move process
   EXECUTE rdt.rdt_Move
      @nMobile     = @nMobile,
      @cLangCode   = @cLangCode, 
      @nErrNo      = @nErrNo  OUTPUT,
      @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
      @cSourceType = 'rdt_TM_PutawayFrom_Confirm_JCB', 
      @cStorerKey  = @cStorerKey,
      @cFacility   = @cFacility, 
      @cFromLOC    = @cFromLOC, 
      @cToLOC      = @cToLOC, 
      @cFromID     = @cFromID, 
      @cToID       = NULL,  -- NULL means not changing ID
      @nFunc       = @nFunc
   IF @nErrNo <> 0
      GOTO RollBackTran

   -- Update Task
   UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
      Status = '9', -- Picked
      ToID = @cToID, 
      EndTime = GETDATE(),
      EditDate = GETDATE(),
      EditWho  = @cUserName, 
      Trafficcop = NULL
   WHERE TaskDetailKey = @cTaskDetailKey
   IF @@ERROR <> 0
   BEGIN
      SET @nErrNo = 79251
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdTaskdetFail
      GOTO RollBackTran
   END

   -- Unlock SuggestedLOC
   EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK' 
      ,''       --@cLOC      
      ,@cToID   --@cID       
      ,@cToLOC  --@cFinalLOC 
      ,''       --@cStorerKey
      ,@nErrNo  OUTPUT
      ,@cErrMsg OUTPUT
   IF @nErrNo <> 0
      GOTO RollBackTran

   SELECT TOP 1 @cPalType = ISNULL(PalletType,'U') 
   FROM dbo.PALLET WITH(NOLOCK)
   WHERE StorerKey = @cStorerkey
      AND PalletKey = @cFromID

   SELECT TOP 1 @cLocRoom = LocationRoom
   FROM dbo.LOC WITH(NOLOCK)
   WHERE LOC = @cToLOC
      AND Facility = @cFacility
		 
   SELECT TOP 1 @cMidLoc = LOC
   FROM dbo.LOC WITH(NOLOCK)
   WHERE LocationRoom = @cLocRoom
      AND Facility = @cFacility
      AND RIGHT(SUBSTRING(LOC,1,7),1) = '2'

   SELECT TOP 1 @cTrdLoc = LOC
   FROM dbo.LOC WITH(NOLOCK)
   WHERE LocationRoom = @cLocRoom
      AND Facility = @cFacility
	  AND RIGHT(SUBSTRING(LOC,1,7),1) = '3'

   SELECT TOP 1 @cFstLoc = LOC
   FROM dbo.LOC WITH(NOLOCK)
   WHERE LocationRoom = @cLocRoom
      AND Facility = @cFacility
      AND RIGHT(SUBSTRING(LOC,1,7),1) = '1'

   DECLARE @b_Success INT;
   DECLARE @n_Err INT;
   DECLARE @c_ErrMsg NVARCHAR(250);

   IF @cPalType LIKE ('D%') 
      AND @cLocCat = 'WA' 
	  AND @cToLOC <> @cMidLoc
   BEGIN
      EXEC [WM].[lsp_Inventoryhold_Wrapper]
         @c_StorerKey   = @cStorerkey
         ,@c_SKU         = N''
         ,@c_lot         = N''
         ,@c_Loc         = @cMidLoc
         ,@c_ID          = N''
         ,@c_lottable01  = N''
         ,@c_lottable02  = N''
         ,@c_lottable03  = N''
         ,@dt_lottable04 = ''
         ,@dt_lottable05 = ''
         ,@c_lottable06  = N''
         ,@c_lottable07  = N''
         ,@c_lottable08  = N''
         ,@c_lottable09  = N''
         ,@c_lottable10  = N''
         ,@c_lottable11  = N''
         ,@c_lottable12  = N''
         ,@dt_lottable13 = ''
         ,@dt_lottable14 = ''
         ,@dt_lottable15 = ''
         ,@c_Status      = N'DoublePal'
         ,@c_Hold        = 1
         ,@c_Remark      = N'DoublePal'
         ,@b_Success     = @b_Success OUTPUT
         ,@n_Err         = @n_Err OUTPUT
         ,@c_ErrMsg      = @c_ErrMsg OUTPUT
         ,@c_UserName    = @cUserKey
   END

   IF @cPalType LIKE ('D%') 
      AND @cLocCat = 'WA' 
      AND @cToLOC = @cMidLoc 
	  AND NOT EXISTS (
	     SELECT 1 
		 FROM LOTxLOCxID WITH(NOLOCK)
		 WHERE Loc = @cFstLoc
		    AND Qty + PendingMoveIN > 0
			AND StorerKey = @cStorerkey
		 )
   BEGIN
      EXEC [WM].[lsp_Inventoryhold_Wrapper]
         @c_StorerKey   = @cStorerkey
         ,@c_SKU         = N''
         ,@c_lot         = N''
         ,@c_Loc         = @cFstLoc
         ,@c_ID          = N''
         ,@c_lottable01  = N''
         ,@c_lottable02  = N''
         ,@c_lottable03  = N''
         ,@dt_lottable04 = ''
         ,@dt_lottable05 = ''
         ,@c_lottable06  = N''
         ,@c_lottable07  = N''
         ,@c_lottable08  = N''
         ,@c_lottable09  = N''
         ,@c_lottable10  = N''
         ,@c_lottable11  = N''
         ,@c_lottable12  = N''
         ,@dt_lottable13 = ''
         ,@dt_lottable14 = ''
         ,@dt_lottable15 = ''
         ,@c_Status      = N'DoublePal'
         ,@c_Hold        = 1
         ,@c_Remark      = N'DoublePal'
         ,@b_Success     = @b_Success OUTPUT
         ,@n_Err         = @n_Err OUTPUT
         ,@c_ErrMsg      = @c_ErrMsg OUTPUT
         ,@c_UserName    = @cUserKey
   END

   ELSE IF @cPalType LIKE ('D%') 
      AND @cLocCat = 'WA' 
	  AND @cToLOC = @cMidLoc
   BEGIN
      EXEC [WM].[lsp_Inventoryhold_Wrapper]
         @c_StorerKey   = @cStorerkey
         ,@c_SKU         = N''
         ,@c_lot         = N''
         ,@c_Loc         = @cTrdLoc
         ,@c_ID          = N''
         ,@c_lottable01  = N''
         ,@c_lottable02  = N''
         ,@c_lottable03  = N''
         ,@dt_lottable04 = ''
         ,@dt_lottable05 = ''
         ,@c_lottable06  = N''
         ,@c_lottable07  = N''
         ,@c_lottable08  = N''
         ,@c_lottable09  = N''
         ,@c_lottable10  = N''
         ,@c_lottable11  = N''
         ,@c_lottable12  = N''
         ,@dt_lottable13 = ''
         ,@dt_lottable14 = ''
         ,@dt_lottable15 = ''
         ,@c_Status      = N'DoublePal'
         ,@c_Hold        = 1
         ,@c_Remark      = N'DoublePal'
         ,@b_Success     = @b_Success OUTPUT
         ,@n_Err         = @n_Err OUTPUT
         ,@c_ErrMsg      = @c_ErrMsg OUTPUT
         ,@c_UserName    = @cUserKey
   END
   
   -- Create next task
   IF @cTransitLOC <> ''
   BEGIN
      EXEC rdt.rdt_TM_PutawayFrom_CreateNextTask @nMobile, @nFunc, @cLangCode,
         @cUserName,
         @cTaskDetailKey,
         @cFinalLOC, 
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT
      IF @nErrNo <> 0
         GOTO RollBackTran
   END

   COMMIT TRAN rdt_TM_PutawayFrom_Confirm_JCB -- Only commit change made here
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_TM_PutawayFrom_Confirm_JCB -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_TM_PutawayFrom_Confirm_JCB] TO NSQL
GO
