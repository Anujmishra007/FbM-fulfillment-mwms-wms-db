SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Function: fnc_GetDot_MichWeek_Mix_Rule                        */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Version    Author   Purposes                            */
/* 2025-11-13   1.0.0      PYU015   UWP-54107 created                   */
/************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[fnc_GetDot_MichWeek_Mix_Rule]
(
   @c_StorerKey   NVARCHAR(15),--StorerKey
   @cID           NVARCHAR(18),--Fromid
   @cLoc          NVARCHAR(10) --ToLoc
)
RETURNS NVARCHAR(1)
BEGIN

   --DECLARE @PalletDOT AS NVARCHAR(4) -- the 31 week, 23 Year(2023)
   DECLARE @WeekRange AS INT

   SELECT @WeekRange = TRY_CAST(S.SUSR4	AS int)
     FROM STORER S (NOLOCK)
    WHERE S.StorerKey = @c_StorerKey

   --SELECT @PalletDOT = la.Lottable02,
   --       @WeekRange = TRY_CAST(s.SUSR4	AS int)
   --FROM LOTxLOCxID lli(nolock)
   --INNER JOIN STORER s (nolock)	on lli.StorerKey = s.StorerKey
   --left join LOTATTRIBUTE la (nolock) on lli.Lot=la.Lot
   --WHERE lli.ID = @cID
   --AND lli.qty-lli.qtypicked > 0
   --AND LEN(la.lottable02) = 4

   BEGIN
      -- Declare variables for the week and year parts of the new pallet's DOT value
      --DECLARE @PalletDotWeek INT = CAST(LEFT(@PalletDOT, 2) AS INT);
      --DECLARE @PalletDotYear INT = CAST(SUBSTRING(@PalletDOT, 3, 2) AS INT);
      -- DECLARE @StartDate DATE, @EndDate DATE;
      -- -- Calculate the date range starting from 8 weeks before to 8 weeks after the new pallet's week
      -- SET @StartDate = CAST(('20' + RIGHT(@PalletDotYear - 1, 2) + '-01-01') AS DATE); -- Start date is the beginning of the previous year
      -- SET @EndDate = CAST(('20' + RIGHT(@PalletDotYear + 1, 2) + '-12-31') AS DATE); --
      -- Check if there are any pallets at the cLoc with a DOT value outside the 8-week range
      -- Lottable02 = DOT, format is 2digits week number+2 digits year number, like 0224, 4324
       IF EXISTS(SELECT 1
                 FROM (SELECT lli.storerkey,lli.Sku,MIN(SUBSTRING(attr.Lottable02,3,2)+SUBSTRING(attr.Lottable02,1,2)) AS Dot
                         FROM LOTxLOCxID lli(NOLOCK)
                        INNER JOIN LOTATTRIBUTE attr(NOLOCK) ON lli.Lot = attr.Lot
                        WHERE lli.StorerKey = @c_StorerKey
                          AND lli.Loc = @cLoc
                          AND Qty - lli.QtyPicked > 0
                        GROUP BY lli.storerkey,lli.Sku
                     ) ta
                 WHERE 1 = 1
                   AND EXISTS (
                           SELECT 1
                             FROM LOTxLOCxID sto(NOLOCK)
                            INNER JOIN LOTATTRIBUTE attr1(NOLOCK) ON sto.Lot = attr1.Lot
                            WHERE sto.StorerKey = ta.StorerKey
                              AND sto.Sku = ta.Sku
                              AND sto.Id =  @cID
                              AND sto.Qty - sto.QtyPicked > 0
                            GROUP BY sto.StorerKey,sto.Sku
                            HAVING(SUBSTRING(MIN(SUBSTRING(attr1.Lottable02,3,2)+SUBSTRING(attr1.Lottable02,1,2)),1,2) <> SUBSTRING(ta.Dot,1,2) 
                                   OR CAST(SUBSTRING(MIN(SUBSTRING(attr1.Lottable02,3,2)+SUBSTRING(attr1.Lottable02,1,2)),3,2) AS int) < CAST(SUBSTRING(ta.Dot,3,2) AS int) - @WeekRange
                                   OR CAST(SUBSTRING(MIN(SUBSTRING(attr1.Lottable02,3,2)+SUBSTRING(attr1.Lottable02,1,2)),3,2) AS int) > CAST(SUBSTRING(ta.Dot,3,2) AS int) + @WeekRange
                                  )
                             )
               )
      BEGIN
         -- If there is a pallet outside the range, return False
         --PRINT '0, not meet DOT weeks rule'
         RETURN '0'
      END
      ELSE
         RETURN '1'
   END
   RETURN '0' -- Default return value if no conditions are met
END
GO

GRANT EXECUTE ON [dbo].[fnc_GetDot_MichWeek_Mix_Rule] TO nSQL 
GO
