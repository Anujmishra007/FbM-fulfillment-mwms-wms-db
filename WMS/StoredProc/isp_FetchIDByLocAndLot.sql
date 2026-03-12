SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store Procedure: isp_FetchIDByLocAndLot                              */
/* Creation Date:                                                       */
/* Copyright: LFL                                                       */
/* Written by: USH022                                                   */
/*                                                                      */
/* Purpose: WM - Wave Creation                                          */
/*                                                                      */
/* Called By: SCE                                                       */
/*          :                                                           */
/* PVCS Version: 3.1                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver.  Purposes                                  */
/* 19-Sep-2025 USH022   1.0   Ids Fetching                              */
/* 27-Jan-2026 Michael  1.1   UWP-47770 - INC8918014 Perf. tuning (ML01)*/
/************************************************************************/

CREATE OR ALTER PROCEDURE dbo.isp_FetchIDByLocAndLot
    @c_StorerKey NVARCHAR(50),
    @c_Facility NVARCHAR(50),
    @c_Lot NVARCHAR(MAX), --Comma Seperated Values
    @c_Loc NVARCHAR(MAX)  --Comma Seperated Values
AS
BEGIN
    SET NOCOUNT ON;

/* ML01-S
    -- Table for valid SKUs
    DECLARE @tLot TABLE (LOT NVARCHAR(100));
    DECLARE @tLoc TABLE (Loc NVARCHAR(100));

    -- Split CSV into rows and validate against dbo.tLot
    INSERT INTO @tLot (LOT)
    SELECT lt.Lot
    FROM dbo.Lot lt WITH (NOLOCK)
    INNER JOIN LOTxLOCxID LLI WITH (NOLOCK) ON lli.Lot = lt.Lot
    INNER JOIN LOC L WITH (NOLOCK) ON L.Loc = lli.Loc
    INNER JOIN (
        SELECT LTRIM(RTRIM(value)) AS Lot
        FROM STRING_SPLIT(@c_Lot, ',')
        WHERE LTRIM(RTRIM(value)) <> ''
    ) tmp ON tmp.Lot = lt.Lot

    INSERT INTO @tLoc (LOC)
    SELECT lc.Loc
    FROM dbo.Loc lc WITH (NOLOCK)
    INNER JOIN LOTxLOCxID LLI WITH (NOLOCK) ON lli.Loc = lc.Loc
    INNER JOIN LOC L WITH (NOLOCK) ON L.Loc = lli.Loc
    INNER JOIN (
        SELECT LTRIM(RTRIM(value)) AS Loc
        FROM STRING_SPLIT(@c_Loc, ',')
        WHERE LTRIM(RTRIM(value)) <> ''
    ) tmp1 ON tmp1.Loc = lc.Loc

    WHERE LLI.StorerKey = @c_StorerKey ;

    -- Final query
    SELECT DISTINCT lll.Id, lll.Qty, lll.QtyAllocated, lll.QtyPicked, lll.Loc, lll.Lot
    FROM LOTxLOCxID lll WITH (NOLOCK)
    JOIN LOC loc WITH (NOLOCK) ON lll.LOC = loc.LOC
    JOIN ID id WITH (NOLOCK) ON lll.ID = id.ID
    JOIN LOT lot WITH (NOLOCK) ON lll.LOT = lot.LOT
	JOIN @tLot lot1 ON lot1.LOT = lot.Lot
    JOIN @tLoc loc1 ON loc1.LOC = loc.Loc

    WHERE lll.StorerKey = @c_StorerKey
	  AND lll.Qty > lll.QtyAllocated + lll.QtyPicked
      AND lot.STATUS = 'OK'
      AND loc.STATUS = 'OK'
      AND id.STATUS  = 'OK'
      AND loc.Facility = @c_Facility
ML01-E */

   --ML01-S
   -- Split CSV into temp tables
   CREATE TABLE #TEMP_LOT (
      Lot NVARCHAR(10) NOT NULL PRIMARY KEY
   )
   CREATE TABLE #TEMP_LOC (
      Loc NVARCHAR(10) NOT NULL PRIMARY KEY
   )
   INSERT INTO #TEMP_LOT (Lot)
   SELECT DISTINCT TRIM(s.value) AS Lot
     FROM STRING_SPLIT(@c_Lot, ',') AS s
    WHERE s.value <> N''

   INSERT INTO #TEMP_LOC (Loc)
   SELECT DISTINCT TRIM(s.value) AS Loc
     FROM STRING_SPLIT(@c_Loc, ',') AS s
    WHERE s.value <> N''

   IF EXISTS(SELECT TOP 1 1
        FROM #TEMP_LOT TMP
        JOIN dbo.LOT WITH(NOLOCK) ON TMP.Lot = LOT.Lot
       WHERE NOT (ISNULL(LOT.Status,'') = 'OK'))
   BEGIN
      DELETE TMP WITH(ROWLOCK)
        FROM #TEMP_LOT TMP
        JOIN dbo.LOT WITH(NOLOCK) ON TMP.Lot = LOT.Lot
       WHERE NOT (ISNULL(LOT.Status,'') = 'OK')
   END

   IF EXISTS(SELECT TOP 1 1
        FROM #TEMP_LOC TMP
        JOIN dbo.LOC WITH(NOLOCK) ON TMP.Loc = LOC.Loc
       WHERE NOT (ISNULL(LOC.Status,'') = 'OK' AND LOC.Facility = ISNULL(@c_Facility,'')))
   BEGIN
      DELETE TMP WITH(ROWLOCK)
        FROM #TEMP_LOC TMP
        JOIN dbo.LOC WITH(NOLOCK) ON TMP.Loc = LOC.Loc
       WHERE NOT (ISNULL(LOC.Status,'') = 'OK' AND LOC.Facility = ISNULL(@c_Facility,''))
   END

   -- Final query
   IF NOT EXISTS(SELECT TOP 1 1 FROM #TEMP_LOT) OR
      NOT EXISTS(SELECT TOP 1 1 FROM #TEMP_LOC)
   BEGIN
      SELECT CAST(NULL AS NVARCHAR(18)) AS ID
           , CAST(NULL AS INT)          AS Qty
           , CAST(NULL AS INT)          AS QtyAllocated
           , CAST(NULL AS INT)          AS QtyPicked
           , CAST(NULL AS NVARCHAR(10)) AS Loc
           , CAST(NULL AS NVARCHAR(10)) AS Lot
      WHERE 1 = 0
   END
   ELSE
   BEGIN
      SELECT DISTINCT LLI.Id, LLI.Qty, LLI.QtyAllocated, LLI.QtyPicked, LLI.Loc, LLI.Lot
        FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
        JOIN dbo.ID         ID  WITH (NOLOCK) ON LLI.ID = ID.ID
        JOIN #TEMP_LOT TMPLOT ON LLI.Lot = TMPLOT.Lot
        JOIN #TEMP_LOC TMPLOC ON LLI.Loc = TMPLOC.Loc
       WHERE LLI.StorerKey = @c_StorerKey
         AND LLI.Qty > LLI.QtyAllocated + LLI.QtyPicked
         AND ID.Status = 'OK'
   END
   --ML01-E
END;
GO
GRANT EXECUTE ON  [dbo].[isp_FetchIDByLocAndLot] TO [NSQL]
GO
