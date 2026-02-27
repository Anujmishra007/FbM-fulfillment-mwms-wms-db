SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store Procedure: isp_FetchLotsForSkus                                */
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
/* 19-Sep-2025 USH022   1.0   Lot Fetching                              */
/************************************************************************/

CREATE OR ALTER PROCEDURE dbo.isp_FetchLotsForSkus
    @c_StorerKey VARCHAR(50),
    @c_Facility NVARCHAR(50),
    @c_SkuCsv NVARCHAR(MAX) -- Comma Separated Values
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
     --PRINT @c_SkuCsv;
-- Temp table for SKUs
    DECLARE @t TABLE (SKU NVARCHAR(50));


    -- Insert SKUs that exist for the given storer
    INSERT INTO @t (SKU)
    SELECT s.Sku
    FROM dbo.SKU s WITH (NOLOCK)
    INNER JOIN (
        SELECT LTRIM(RTRIM(value)) AS Sku
        FROM STRING_SPLIT(@c_SkuCsv, ',')
        WHERE LTRIM(RTRIM(value)) <> ''
    ) ss ON s.Sku = ss.Sku
    WHERE s.StorerKey = @c_StorerKey --AND s.Facility = @c_Facility;

    -- Main query
    SELECT
          lll.Lot,
          SUM(lll.Qty - lll.QtyAllocated - lll.QtyPicked) AS quantity,
          lll.StorerKey,
          lll.Sku,
          loc.Facility
    FROM LOTxLOCxID lll WITH (NOLOCK)
    JOIN LOC loc WITH (NOLOCK)
         ON lll.LOC = loc.LOC
    JOIN LOTAttribute la WITH (NOLOCK)
         ON lll.LOT = la.LOT
    JOIN ID id WITH (NOLOCK)
         ON lll.ID = id.ID
    JOIN LOT lot WITH (NOLOCK)
         ON lll.LOT = lot.LOT
    JOIN @t SKU
         ON lll.Sku = SKU.SKU
    WHERE lll.StorerKey = @c_StorerKey
      AND loc.Facility = @c_Facility
      AND lot.STATUS = 'OK'
      AND loc.STATUS = 'OK'
      AND id.STATUS = 'OK'
    GROUP BY
          lll.Lot,
          la.LOTTABLE02,
          lll.StorerKey,
          lll.Sku,
          loc.Facility;
END;
GO
