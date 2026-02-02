SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store Procedure: isp_FetchLocByLot                                   */
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
/* 19-Sep-2025 USH022   1.0   Loc Fetching                              */
/************************************************************************/

CREATE OR ALTER PROCEDURE dbo.isp_FetchLocByLot
    @c_StorerKey NVARCHAR(50),
    @c_Facility NVARCHAR(50),
    @c_Lot NVARCHAR(MAX) -- Comma Seperated Values
AS
BEGIN
    SET NOCOUNT ON;

    -- Table for valid SKUs
    DECLARE @tLot TABLE (LOT NVARCHAR(100));

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
    ) tmp ON lt.Lot = tmp.Lot
    WHERE lt.StorerKey = @c_StorerKey --AND l.Facility = @c_Facility;

    -- Final query
    SELECT
        LLI.Loc,
        SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked) AS Quantity,
        LLI.Lot
    FROM LOTxLOCxID LLI WITH (NOLOCK)
    JOIN LOC L WITH (NOLOCK)  ON LLI.Loc = L.LOC
    JOIN ID  I WITH (NOLOCK)  ON LLI.ID  = I.ID
    JOIN LOT LT WITH (NOLOCK)  ON LLI.LOT = LT.LOT
    JOIN @tLot tlot             ON tLot.LOT = LT.Lot
    WHERE LLI.StorerKey = @c_StorerKey
      AND L.Facility = @c_Facility
      AND LT.STATUS = 'OK'
      AND L.STATUS = 'OK'
      AND I.STATUS  = 'OK'
      AND (LLI.Qty > LLI.QtyAllocated + LLI.QtyPicked)
    GROUP BY LLI.Loc, LLI.Lot;
END;
GO
