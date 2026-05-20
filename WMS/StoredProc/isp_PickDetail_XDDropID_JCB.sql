USE [GBRWMS]
GO
/****** Object:  StoredProcedure [dbo].[isp_PickDetail_XDDropID_JCB]    Script Date: 5/20/2026 3:03:06 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure:  isp_PickDetail_XDDropID_JCB                       */
/* Creation Date: 22-AUG-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  Due to removing IDtoDROPID due to using casepicking        */
/*           this is needed to be still for JCB, OrderType=0            */
/*           , OrderGroup=XDOCK and Status<'9' so users do not need     */
/*           to do this manually, this is workaround solution before    */
/*           full outbound XD is availalbe                              */
/*                                                                      */
/* Called By:  MSQL Scheduled JOB BEJ - BackEndIDtoDropID XD(GBR - JCB) */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: V1                                                          */
/*                                                                      */
/* Data Modifications:                                                  */
/* Updates:                                                             */
/* Date        Author   Rev   Purposes                                  */
/* 2025-08-22  TPT001   1.0   Creation                                  */
/* 2025-09-30  PPA374   1.1   Adding FromID filter for housekeeping     */
/* 2025-12-11  PPA374   1.2   Adding message to Statusmsg when          */
/*                               cancelling the task                    */
/* 2026-05-20  SKE140   1.3   Merged Unicode control char cleanup       */
/*                               for Lottable09 (U+202C, U+202D)        */
/************************************************************************/

ALTER   PROC [dbo].[isp_PickDetail_XDDropID_JCB] (
     @b_Success         INT           OUTPUT
   , @n_Err             INT           OUTPUT
   , @c_ErrMsg          NVARCHAR(250) OUTPUT
   , @b_debug           INT = 0 )

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_OrderKey      NVARCHAR( 10)
          ,@c_PickDetailKey NVARCHAR( 10)
    ,@cStorerKey      NVARCHAR( 30) = 'JCB'
    ,@cFacility       NVARCHAR( 30) = 'EMG03'
    ,@cPalType        NVARCHAR( 15)
    ,@cUserKey        NVARCHAR( 30) = 'AutoHK'

   SELECT @b_Success=1, @n_Err=0, @c_ErrMsg=''

   -- ============================================================
   -- Unicode control character cleanup (U+202D, U+202C)
   -- Cleans hidden bidi chars from Lottable09 before XML generation
   -- ============================================================
   UPDATE lotattribute
   SET Lottable09 = LTRIM(RTRIM(
       REPLACE(
       REPLACE(
           CONVERT(NVARCHAR(MAX), Lottable09) COLLATE Latin1_General_BIN2,
           NCHAR(0x202D), N''),
           NCHAR(0x202C), N'')
       ))
   WHERE Lottable09 LIKE N'%' + NCHAR(0x202C) + N'%' COLLATE Latin1_General_BIN2
      OR Lottable09 LIKE N'%' + NCHAR(0x202D) + N'%' COLLATE Latin1_General_BIN2;
   -- ============================================================

   -- Housekeping
   -- Check for locations without double pal hold that require it  
   IF EXISTS (
   SELECT 1
   FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
   INNER JOIN dbo.PALLET P WITH(NOLOCK)
      ON LLI.Id = P.PalletKey
      AND LLI.StorerKey = P.StorerKey
   INNER JOIN dbo.LOC L WITH(NOLOCK)
      ON L.Loc = LLI.Loc
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
   AND P.StorerKey = @cStorerKey
   AND P.PalletType LIKE 'D%'
   AND LLI.Qty > 0
      AND LLI.StorerKey = @cStorerKey
      AND L.Facility = @cFacility
   AND L.LocationFlag IN ('','NONE')
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
               AND LLI.StorerKey = P.StorerKey
               AND P.PalletType LIKE 'D%'
               AND LLI.Qty > 0
         INNER JOIN dbo.LOC L WITH(NOLOCK)
            ON L.Loc = LLI.Loc
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
   AND P.StorerKey = @cStorerKey
   AND LLI.StorerKey = @cStorerKey
   AND L.Facility = @cFacility
   AND L.LocationFlag IN ('','NONE')
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

   -- Update LOCs to have status 'OK' when there are no Holds
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
      /*UPDATE dbo.LOC WITH(ROWLOCK)
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
         )*/

      UPDATE L WITH (ROWLOCK)
      SET Status = 'OK'
      FROM dbo.Loc L
      WHERE L.Facility = @cFacility
         AND L.Status <> 'OK'
         AND NOT EXISTS (
            SELECT 1
            FROM dbo.InventoryHold IH
            WHERE IH.Loc = L.Loc
               AND IH.Hold = '1'
         )
   END

   --Cancel tasks that can no longer be fulfilled
   UPDATE TD WITH(ROWLOCK)
   SET TD.Status = 'X', TD.StatusMsg = 'FromID is in multi loc or not in the source loc'
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
   AND TD.FromID <> ''

   --Delete RFPutaway that got pending but no actual qty
   /*DELETE FROM RFPUTAWAY
   WHERE FromID IN (
      SELECT LLI1.ID
      FROM LOTxLOCxID LLI1 WITH (NOLOCK)
         INNER JOIN LOTxLOCxID LLI2 WITH (NOLOCK)
         ON LLI1.ID = LLI2.ID
            AND LLI2.StorerKey = LLI1.StorerKey
         LEFT JOIN LOTxLOCxID LLI3 WITH (NOLOCK)
         ON LLI1.ID = LLI3.ID
            AND LLI3.StorerKey = @cStorerKey
            AND LLI3.Qty > 0
      WHERE LLI1.StorerKey = @cStorerKey
         AND LLI3.ID IS NULL
   AND LLI2.PendingMoveIN > 0
   )*/

   DELETE RF
   FROM RFPUTAWAY RF
   WHERE EXISTS (
      SELECT 1
      FROM LOTxLOCxID LLI
      WHERE LLI.ID = RF.FromID
         AND LLI.StorerKey = @cStorerKey
         AND LLI.PendingMoveIN > 0
   AND RF.Id <> ''
   )
   AND NOT EXISTS (
      SELECT 1
      FROM LOTxLOCxID LLI
      WHERE LLI.ID = RF.FromID
         AND LLI.StorerKey = @cStorerKey
         AND LLI.Qty > 0
   AND RF.Id <> ''
    )

   --Update pending qty that can no longer be done, to free up the location
   /*UPDATE LOTxLOCxID WITH(ROWLOCK)
   SET PendingMoveIN = 0
   WHERE ID IN (
      SELECT LLI1.ID
      FROM LOTxLOCxID LLI1 WITH (NOLOCK)
         INNER JOIN LOTxLOCxID LLI2 WITH (NOLOCK)
         ON LLI1.ID = LLI2.ID
            AND LLI2.StorerKey = LLI1.StorerKey
         LEFT JOIN LOTxLOCxID LLI3 WITH (NOLOCK)
         ON LLI1.ID = LLI3.ID
            AND LLI3.StorerKey = @cStorerKey
            AND LLI3.Qty > 0
      WHERE LLI1.StorerKey = @cStorerKey
         AND LLI3.ID IS NULL
   AND LLI2.PendingMoveIN > 0
   )*/

   UPDATE LLI
   SET PendingMoveIN = 0
   FROM LOTxLOCxID LLI WITH (ROWLOCK)
   WHERE LLI.StorerKey = @cStorerKey
      AND LLI.PendingMoveIN > 0
      AND EXISTS (
         SELECT 1
         FROM LOTxLOCxID LLI2 WITH (NOLOCK)
         WHERE LLI2.ID = LLI.ID
            AND LLI2.StorerKey = LLI.StorerKey
      )
      AND NOT EXISTS (
         SELECT 1
         FROM LOTxLOCxID LLI3 WITH (NOLOCK)
         WHERE LLI3.ID = LLI.ID
            AND LLI3.StorerKey = @cStorerKey
            AND LLI3.Qty > 0
      )

   --Delete RFPutaway that can no longer be done, to free up the location
   /*DELETE FROM RFPUTAWAY
   WHERE FromID IN (
      SELECT LLI1.ID
      FROM dbo.LOTxLOCxID LLI1 WITH(NOLOCK)
         INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK)
            ON LLI1.Id = LLI2.Id 
         AND LLI1.StorerKey = LLI2.StorerKey
         INNER JOIN LOC L WITH(NOLOCK)
            ON L.Loc = LLI2.Loc
            AND LLI2.StorerKey = LLI1.StorerKey
      WHERE LLI1.StorerKey = @cStorerKey
         AND LLI1.PendingMoveIN > 0
         AND L.LocationCategory NOT IN ('STAGE','PNDIN')
   AND L.Facility = @cFacility
   AND LLI2.Qty > 0
   )*/

   DELETE RF
   FROM RFPUTAWAY RF
   INNER JOIN LOTxLOCxID LLI WITH(NOLOCK)
      ON LLI.ID = RF.FromID
      AND LLI.StorerKey = @cStorerKey
      AND LLI.PendingMoveIN > 0
      AND LLI.Qty > 0
   INNER JOIN LOC L WITH(NOLOCK)
      ON L.Loc = LLI.Loc
      AND L.Facility = @cFacility
      AND L.LocationCategory NOT IN ('STAGE','PNDIN')

   --Update pending qty that can no longer be done, to free up the location
   /*UPDATE LOTxLOCxID WITH(ROWLOCK)
   SET PendingMoveIN = 0
   WHERE ID IN (
      SELECT LLI1.ID
      FROM dbo.LOTxLOCxID LLI1 WITH(NOLOCK)
         INNER JOIN dbo.LOTxLOCxID LLI2 WITH(NOLOCK)
            ON LLI1.Id = LLI2.Id 
         AND LLI1.StorerKey = LLI2.StorerKey
         INNER JOIN LOC L WITH(NOLOCK)
            ON L.Loc = LLI2.Loc
            AND LLI2.StorerKey = LLI1.StorerKey
      WHERE LLI1.StorerKey = @cStorerKey
         AND LLI1.PendingMoveIN > 0
         AND L.LocationCategory NOT IN ('STAGE','PNDIN')
   AND L.Facility = @cFacility
   AND LLI2.Qty > 0
   )*/

   UPDATE LLI1
   SET PendingMoveIN = 0
   FROM LOTxLOCxID LLI1 WITH(ROWLOCK)
   INNER JOIN LOTxLOCxID LLI WITH(NOLOCK)
      ON LLI1.ID = LLI.ID
      AND LLI1.StorerKey = LLI.StorerKey
      AND LLI.StorerKey = @cStorerKey
      AND LLI.PendingMoveIN > 0
      AND LLI.Qty > 0
   INNER JOIN LOC L WITH(NOLOCK)
      ON L.Loc = LLI.Loc
      AND L.Facility = @cFacility
      AND L.LocationCategory NOT IN ('STAGE','PNDIN')

   --Delete RFPUTAWAY that got tasks archived
   DELETE R
   FROM dbo.RFPUTAWAY R
      INNER JOIN (
         SELECT LLI1.Loc, LLI1.ID
         FROM dbo.LOTxLOCxID LLI1 WITH(NOLOCK)
            LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK)
               ON (TD.ToLoc = LLI1.LOC OR TD.FinalLOC = LLI1.LOC)
                  AND TD.FromID = LLI1.ID
      AND TD.StorerKey = LLI1.StorerKey
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
            AND TD.StorerKey = LLI.StorerKey
   WHERE LLI.StorerKey = @cStorerKey
      AND LLI.PendingMoveIN > 0
      AND TD.TaskDetailKey IS NULL
   AND TD.FromID <> ''

   -- PRIMARY filter for XDOCK pickdetails that do not have DROPID but have ID and are not shipped yet
   DECLARE CUR_PICK_LINES CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT 
      O.OrderKey,
   PD.PickDetailKey
      FROM dbo.Orders O WITH(NOLOCK)
      INNER JOIN dbo.ORDERDETAIL OD WITH(NOLOCK)
   ON O.OrderKey=OD.OrderKey 
   INNER JOIN dbo.PICKDETAIL PD 
   ON OD.OrderLineNumber=PD.OrderLineNumber 
      AND OD.OrderKey=PD.OrderKey 
   AND PD.PickDetailKey IS NOT NULL
      WHERE O.StorerKey='JCB' 
      AND O.Type='0' 
   AND O.OrderGroup='XDOCK' 
   AND O.Status<>'9' 
   AND ISNULL(PD.DropID,'')='' 
   AND ISNULL(PD.ID,'')<>''

   OPEN CUR_PICK_LINES
      
   FETCH FROM CUR_PICK_LINES INTO @c_OrderKey, @c_PickDetailKey

   WHILE @@FETCH_STATUS = 0 
   BEGIN
      IF @b_debug = 1                                                           
         BEGIN
            SELECT  @c_OrderKey, @c_PickDetailKey
   PRINT 'Order: '+@c_OrderKey+' PickDetailKey: '+@c_PickDetailKey;
         END
      
      BEGIN TRY
            UPDATE dbo.PICKDETAIL WITH (ROWLOCK)
            SET DropID = ID
            WHERE Orderkey = @c_Orderkey
            AND PickDetailKey = @c_PickDetailKey
         END TRY
   BEGIN CATCH
      SET @b_Success=0
            SET @n_err = ERROR_NUMBER()
               
            IF @n_err <> 0
            BEGIN
               --SET @n_continue = 3   --Not breaking the loop as on failed update should only skip that particular row, but continue on the next ones
               SET @c_errmsg = CONVERT(NVARCHAR(250),ERROR_MESSAGE())
               --SET @n_err = 81010  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update XD PickDetail Failed. (isp_PickDetail_XDDropID_JCB)'
                           + '( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
         EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'isp_PickDetail_XDDropID_JCB'
            END
         END CATCH

      FETCH FROM CUR_PICK_LINES INTO @c_OrderKey, @c_PickDetailKey 
   END

   CLOSE CUR_PICK_LINES
   DEALLOCATE CUR_PICK_LINES
END
