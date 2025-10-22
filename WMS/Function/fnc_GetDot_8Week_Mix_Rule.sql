IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnc_GetDot_8Week_Mix_Rule]')  AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')) 
   DROP FUNCTION [dbo].[fnc_GetDot_8Week_Mix_Rule]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Function: fnc_GetDot_8Week_Mix_Rule                           */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Version    Author   Purposes                            */
/* 2025-05-21   1.0.0      Dennis   FCR-4217 created                    */
/************************************************************************/
CREATE FUNCTION dbo.fnc_GetDot_8Week_Mix_Rule
(
   @cID    NVARCHAR(18),--Fromid
   @cLoc   NVARCHAR(10),--ToLoc
   @cSKU   NVARCHAR(20)
)
RETURNS NVARCHAR(1)
BEGIN

   DECLARE @PalletDOT AS NVARCHAR(4) -- the 31 week, 23 Year(2023)

   SELECT @PalletDOT = la.Lottable02
   FROM LOTxLOCxID lli(nolock)
   left join LOTATTRIBUTE la (nolock) on lli.Lot=la.Lot
   WHERE lli.ID = @cID
   AND lli.sku = @cSKU
   AND lli.qty-lli.qtypicked > 0
   AND LEN(la.lottable02) = 4

   BEGIN
      -- Declare variables for the week and year parts of the new pallet's DOT value
      DECLARE @PalletDotWeek INT = CAST(LEFT(@PalletDOT, 2) AS INT);
      DECLARE @PalletDotYear INT = CAST(SUBSTRING(@PalletDOT, 3, 2) AS INT);
      -- DECLARE @StartDate DATE, @EndDate DATE;
      -- -- Calculate the date range starting from 8 weeks before to 8 weeks after the new pallet's week
      -- SET @StartDate = CAST(('20' + RIGHT(@PalletDotYear - 1, 2) + '-01-01') AS DATE); -- Start date is the beginning of the previous year
      -- SET @EndDate = CAST(('20' + RIGHT(@PalletDotYear + 1, 2) + '-12-31') AS DATE); --
      -- Check if there are any pallets at the cLoc with a DOT value outside the 8-week range
      -- Lottable02 = DOT, format is 2digits week number+2 digits year number, like 0224, 4324
      IF EXISTS (
      SELECT 1
      FROM LOTxLOCxID lli(nolock)
      left join LOTATTRIBUTE la (nolock) on lli.Lot=la.Lot
      WHERE lli.Loc = @cLoc
      AND LLI.SKU = @cSKU
      AND lli.qty-lli.qtypicked > 0
      AND LEN(la.lottable02) = 4 -- Ensures that Lottable02 is exactly 4 characters long
      AND (
            SUBSTRING(la.Lottable02,3,2) <> @PalletDotYear
      OR  CAST(SUBSTRING(la.Lottable02,1,2) AS int) < @PalletDotWeek - 8
      OR  CAST(SUBSTRING(la.Lottable02,1,2) AS int) > @PalletDotWeek + 8
         ))
      BEGIN
         -- If there is a pallet outside the range, return False
         --PRINT '0, not meet 8 weeks rule'
         RETURN '0'
      END
      ELSE
         RETURN '1'
   END
   RETURN '0' -- Default return value if no conditions are met
END
GO

GRANT EXECUTE ON dbo.fnc_GetDot_8Week_Mix_Rule TO NSQL
GO