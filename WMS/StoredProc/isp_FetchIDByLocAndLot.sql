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
/************************************************************************/

CREATE OR ALTER PROCEDURE dbo.isp_FetchIDByLocAndLot
    @c_StorerKey NVARCHAR(50),
    @c_Facility NVARCHAR(50),
    @c_Lot NVARCHAR(MAX), --Comma Seperated Values
    @c_Loc NVARCHAR(MAX)  --Comma Seperated Values
AS
BEGIN
    SET NOCOUNT ON;

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
END;
GO
