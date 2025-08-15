
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

   -- Check for locations without double pal hold that require it  
   IF EXISTS (
   SELECT 1
   FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
   INNER JOIN dbo.PALLET P WITH(NOLOCK)
      ON LLI.Id = P.PalletKey
      AND LLI.StorerKey = @cStorerKey
      AND P.StorerKey = @cStorerKey
      AND P.PalletType LIKE 'D%'
      AND LLI.Qty > 0
   INNER JOIN dbo.LOC L WITH(NOLOCK)
      ON L.Loc = LLI.Loc
      AND LLI.StorerKey = @cStorerKey
      AND L.Facility = @cFacility
      AND L.LocationFlag IN ('','NONE')
   LEFT JOIN dbo.LOTxLOCxID LLIx WITH(NOLOCK)
      ON LLIx.StorerKey = @cStorerKey
      AND L.Facility = @cFacility
      AND LLI.Loc <> LLIx.Loc
      AND LLIx.Qty + LLIx.PendingMoveIN > 0
      AND LLIx.Loc IN (L.LocationRoom + '1', L.LocationRoom + '2', L.LocationRoom + '3')
   LEFT JOIN dbo.INVENTORYHOLD IH WITH(NOLOCK)
      ON IH.Loc LIKE L.LocationRoom + '%'
      AND IH.Hold = '1'
      AND IH.Status = 'DoublePal'
   WHERE IH.Status IS NULL
     AND L.LocationCategory = 'WA'
   )
   BEGIN
      DECLARE @DoublePalletLocations TABLE (LocToHold NVARCHAR(10));
      DECLARE @cLocToHold NVARCHAR(10);

      -- Populate temp table with locations to hold
      INSERT INTO @DoublePalletLocations (LocToHold)
      SELECT DISTINCT
         CASE 
            WHEN RIGHT(Loc,1) IN ('3','1') AND SecondLoc IS NULL THEN LocBeam +'2'
            WHEN RIGHT(Loc,1) = '2' AND FirstLoc IS NULL THEN LocBeam +'1'
            WHEN RIGHT(Loc,1) = '2' AND ThirdLoc IS NULL THEN LocBeam +'3'
         END AS LocToHold
      FROM (
         SELECT DISTINCT
            LLI.Loc,
            L.LocationRoom AS LocBeam,
            MAX(CASE WHEN LLIx.Loc = L.LocationRoom + '1' THEN LLIx.Loc END) AS FirstLoc,
            MAX(CASE WHEN LLIx.Loc = L.LocationRoom + '2' THEN LLIx.Loc END) AS SecondLoc,
            MAX(CASE WHEN LLIx.Loc = L.LocationRoom + '3' THEN LLIx.Loc END) AS ThirdLoc
         FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
         INNER JOIN dbo.PALLET P WITH(NOLOCK)
            ON LLI.Id = P.PalletKey
               AND LLI.StorerKey = @cStorerKey
               AND P.StorerKey = @cStorerKey
               AND P.PalletType LIKE 'D%'
               AND LLI.Qty > 0
         INNER JOIN dbo.LOC L WITH(NOLOCK)
            ON L.Loc = LLI.Loc
               AND LLI.StorerKey = @cStorerKey
               AND L.Facility = @cFacility
               AND L.LocationFlag IN ('','NONE')
         LEFT JOIN dbo.LOTxLOCxID LLIx WITH(NOLOCK)
            ON LLIx.StorerKey = @cStorerKey
               AND L.Facility = @cFacility
               AND LLI.Loc <> LLIx.Loc
               AND LLIx.Qty + LLIx.PendingMoveIN > 0
               AND LLIx.Loc IN (L.LocationRoom + '1', L.LocationRoom + '2', L.LocationRoom + '3')
         LEFT JOIN dbo.INVENTORYHOLD IH WITH(NOLOCK)
            ON IH.Loc LIKE L.LocationRoom + '%'
               AND IH.Hold = '1'
               AND IH.Status = 'DoublePal'
         WHERE IH.Status IS NULL
            AND L.LocationCategory = 'WA'
         GROUP BY LLI.Loc, L.LocationRoom
      ) T
      WHERE (
         (FirstLoc IS NULL AND SecondLoc IS NULL) OR
         (FirstLoc IS NULL AND ThirdLoc IS NULL) OR
         (SecondLoc IS NULL AND ThirdLoc IS NULL)
      ) 
	     AND CASE 
            WHEN RIGHT(Loc,1) IN ('3','1') AND SecondLoc IS NULL THEN LocBeam +'2'
            WHEN RIGHT(Loc,1) = '2' AND FirstLoc IS NULL THEN LocBeam +'1'
            WHEN RIGHT(Loc,1) = '2' AND ThirdLoc IS NULL THEN LocBeam +'3'
         END IS NOT NULL;

      -- Loop through top 10 locations and call the hold procedure
      DECLARE @nCounter INT = 1;
      DECLARE @nLimit   INT = 0;

      SELECT TOP 1 @nLimit = COUNT(LocToHold)
      FROM (
         SELECT LocToHold, 
		    ROW_NUMBER() OVER(ORDER BY LocToHold) AS RowID
         FROM @DoublePalletLocations DPL
		    INNER JOIN dbo.LOC L WITH(NOLOCK)
			ON L.Loc = DPL.LocToHold
		 WHERE L.LocationFlag IN ('','NONE')
	  )T

      WHILE @nCounter <= @nLimit AND @nCounter <= 20
      BEGIN
         SELECT TOP 1 @cLocToHold = LocToHold
         FROM (
            SELECT LocToHold, 
		       ROW_NUMBER() OVER(ORDER BY LocToHold) AS RowID
            FROM @DoublePalletLocations DPL
		       INNER JOIN dbo.LOC L WITH(NOLOCK)
			   ON L.Loc = DPL.LocToHold
		    WHERE L.LocationFlag IN ('','NONE')
         ) T
         WHERE RowID = @nCounter;

	     IF ISNULL(@cLocToHold, '') <> ''
         BEGIN
            EXEC [WM].[lsp_Inventoryhold_Wrapper]
                 @c_StorerKey   = @cStorerKey,
                 @c_SKU         = N'',
                 @c_lot         = N'',
                 @c_Loc         = @cLocToHold,
                 @c_ID          = N'',
                 @c_lottable01  = N'',
                 @c_lottable02  = N'',
                 @c_lottable03  = N'',
                 @dt_lottable04 = '',
                 @dt_lottable05 = '',
                 @c_lottable06  = N'',
                 @c_lottable07  = N'',
                 @c_lottable08  = N'',
                 @c_lottable09  = N'',
                 @c_lottable10  = N'',
                 @c_lottable11  = N'',
                 @c_lottable12  = N'',
                 @dt_lottable13 = '',
                 @dt_lottable14 = '',
                 @dt_lottable15 = '',
                 @c_Status      = N'DoublePal',
                 @c_Hold        = 1,
                 @c_Remark      = N'DoublePal',
                 @b_Success     = @b_Success OUTPUT,
                 @n_Err         = @n_Err OUTPUT,
                 @c_ErrMsg      = @c_ErrMsg OUTPUT,
                 @c_UserName    = @cUserKey;
         END
	     SET @nCounter = @nCounter + 1;
      END
   END

   IF EXISTS (
      SELECT 1
      FROM (
         SELECT 
		    LOC, 
            Hold, 
            Status, 
            DateOn, 
            WhoOn, 
            DateOff, 
            WhoOff,
            ROW_NUMBER() OVER(PARTITION BY LOC ORDER BY LOC, Hold, DateOn) AS RowID,
            COUNT(*) OVER(PARTITION BY LOC) AS TotalPerLoc
         FROM dbo.INVENTORYHOLD IH WITH(NOLOCK)
      WHERE Status = 'DoublePal'
      ) AS T
      WHERE TotalPerLoc > 1 AND RowID = 1
   )

   BEGIN
      UPDATE IH WITH(ROWLOCK)
      SET Hold = 0,
         Remark = 'deleteDP'
      FROM dbo.INVENTORYHOLD IH
         INNER JOIN (
            SELECT LOC, 
	           Hold, 
		       DateOn, 
		       WhoOn
            FROM (
               SELECT 
			      LOC,
                  Hold,
                  DateOn,
                  WhoOn,
                  ROW_NUMBER() OVER(PARTITION BY LOC ORDER BY LOC, Hold, DateOn) AS RowID,
                  COUNT(*) OVER(PARTITION BY LOC) AS TotalPerLoc
               FROM dbo.INVENTORYHOLD WITH(NOLOCK)
               WHERE Status = 'DoublePal'
            ) AS T
            WHERE TotalPerLoc > 1 AND RowID = 1
         ) AS Dups
         ON IH.LOC = Dups.LOC
            AND IH.Hold = Dups.Hold
            AND IH.DateOn = Dups.DateOn
            AND IH.WhoOn = Dups.WhoOn
      WHERE IH.Status = 'DoublePal';

      DELETE FROM dbo.INVENTORYHOLD
      WHERE Status = 'DoublePal'
         AND Hold = '0'
         AND Remark = 'DeleteDP'
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

   BEGIN
      -- 1. Declare the temp table
      DECLARE @TempLocationRooms TABLE (
         Loc NVARCHAR(10)
      );

      -- 2. Insert results with suffixes (1, 2, 3) into the temp table
      INSERT INTO @TempLocationRooms (Loc)
      SELECT LocationRoom + CAST(Number AS NVARCHAR(1)) AS Loc
      FROM (
         -- Base query to get distinct LocationRooms
         SELECT DISTINCT LocationRoom
         FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
         RIGHT JOIN (
            SELECT L.LocationRoom, L.Facility
            FROM dbo.INVENTORYHOLD IH WITH(NOLOCK)
            INNER JOIN LOC L WITH(NOLOCK)
               ON IH.Loc = L.Loc
               AND L.Facility = @cFacility
               AND IH.Status = 'DoublePal'
               AND IH.Hold = '1'
         ) LR
            ON LLI.Loc LIKE LR.LocationRoom + '%'
            AND LLI.StorerKey = @cStorerKey
            AND LR.Facility = @cFacility
            AND LLI.Qty > 0
         LEFT JOIN PALLET P WITH(NOLOCK)
            ON LLI.Id = P.PalletKey
            AND LLI.StorerKey = @cStorerKey
            AND P.PalletType LIKE 'D%'
            AND P.StorerKey = @cStorerKey
         GROUP BY LocationRoom
         HAVING MAX(PalletKey) IS NULL
      ) AS BaseRooms
      CROSS JOIN (VALUES (1), (2), (3)) AS Suffix(Number);

      -- 3. Update INVENTORYHOLD based on locations in the temp table
      UPDATE dbo.INVENTORYHOLD WITH(ROWLOCK)
      SET Hold = '0'
      WHERE Status = 'DoublePal'
         AND Hold = '1'
         AND LOC IN (
            SELECT Loc FROM @TempLocationRooms
         )

      -- 4. Update LOCs to have status 'OK' when there are no Holds
      UPDATE dbo.LOC WITH(ROWLOCK)
	  SET Status = 'OK'
	  WHERE Facility = @cFacility
	     AND LOC IN ( 
	        SELECT L.Loc
            FROM dbo.Loc L WITH(NOLOCK)
               LEFT JOIN dbo.InventoryHold IH WITH(NOLOCK)
                  ON IH.Loc = L.Loc AND IH.Hold = '1'
            WHERE IH.Loc IS NULL
               AND L.Facility = @cFacility
               AND L.Status <> 'OK'
         )
   END

   --Cancel tasks that can no longer be fulfilled
   UPDATE TD WITH(ROWLOCK)
   SET TD.Status = 'X'
   FROM dbo.TaskDetail TD
      LEFT JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
         ON TD.FromID = LLI.Id 
		    AND LLI.Qty > 0
			AND TD.StorerKey = @cStorerKey
			AND LLI.StorerKey = @cStorerKey
   WHERE TD.Status = '0'
      AND TD.FromLoc <> LLI.Loc
      AND TD.StorerKey = @cStorerKey
      AND LLI.StorerKey = @cStorerKey

   --Delete RFPutaway that can no longer be done, to free up the location
   DELETE FROM RFPUTAWAY
   WHERE FromID IN (
      SELECT LLI1.ID
      FROM dbo.LOTxLOCxID LLI1 WITH(NOLOCK)
         LEFT JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK)
            ON LLI1.Id = LLI2.Id 
	           AND LLI2.Qty > 0
		       AND LLI1.StorerKey = @cStorerKey
		       AND LLI2.StorerKey = @cStorerKey
         INNER JOIN LOC L WITH(NOLOCK)
            ON L.Loc = LLI2.Loc
	           AND LLI2.StorerKey = @cStorerKey
		       AND L.Facility = @cFacility
      WHERE LLI1.StorerKey = @cStorerKey
         AND LLI1.PendingMoveIN > 0
         AND LocationCategory NOT IN ('STAGE','PNDIN')
   )

   --Update pending qty that can no longer be done, to free up the location
   UPDATE LOTxLOCxID WITH(ROWLOCK)
   SET PendingMoveIN = 0
   WHERE ID IN (
      SELECT LLI1.ID
      FROM dbo.LOTxLOCxID LLI1 WITH(NOLOCK)
         LEFT JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK)
            ON LLI1.Id = LLI2.Id 
	           AND LLI2.Qty > 0
		       AND LLI1.StorerKey = @cStorerKey
		       AND LLI2.StorerKey = @cStorerKey
         INNER JOIN LOC L WITH(NOLOCK)
            ON L.Loc = LLI2.Loc
	           AND LLI2.StorerKey = @cStorerKey
		       AND L.Facility = @cFacility
      WHERE LLI1.StorerKey = @cStorerKey
         AND LLI1.PendingMoveIN > 0
         AND LocationCategory NOT IN ('STAGE','PNDIN')
   )

   --Delete RFPUTAWAY that got tasks archived
   DELETE R
   FROM dbo.RFPUTAWAY R
      INNER JOIN (
         SELECT LLI1.Loc, LLI1.ID
         FROM dbo.LOTxLOCxID LLI1 WITH(NOLOCK)
            LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK)
               ON (TD.ToLoc = LLI1.LOC OR TD.FinalLOC = LLI1.LOC)
                  AND TD.FromID = LLI1.ID
				  AND TD.StorerKey = @cStorerKey
				  AND LLI1.StorerKey = @cStorerKey
         WHERE LLI1.StorerKey = @cStorerKey
            AND LLI1.PendingMoveIN > 0
            AND TD.TaskDetailKey IS NULL
         ) AS Sub
         ON R.ID = Sub.ID 
		    AND R.SuggestedLoc = Sub.Loc;

   --Update pending that got task archived
   UPDATE LLI
   SET LLI.PendingMoveIN = '0'
   FROM dbo.LOTxLOCxID LLI WITH(ROWLOCK)
      LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK)
         ON (TD.ToLoc = LLI.LOC OR TD.FinalLOC = LLI.LOC)
            AND TD.FromID = LLI.ID
            AND TD.StorerKey = @cStorerKey
            AND LLI.StorerKey = @cStorerKey
   WHERE LLI.StorerKey = @cStorerKey
      AND LLI.PendingMoveIN > 0
      AND TD.TaskDetailKey IS NULL

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
