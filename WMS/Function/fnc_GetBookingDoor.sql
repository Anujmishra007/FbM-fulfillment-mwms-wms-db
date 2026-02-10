IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnc_GetBookingDoor]')  AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')) 
DROP FUNCTION [dbo].[fnc_GetBookingDoor]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Function: fnc_GetBookingDoor                                         */
/* Creation Date: 01-FEB-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose: WMS-917 - WMS Door Booking Enhancement                      */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 2025-12-02   Michael   1.1 UWP-38004 Add @c_InOut = 'A' for All(ML01)*/
/************************************************************************/
CREATE FUNCTION [dbo].[fnc_GetBookingDoor]
         (
            @c_Facility       NVARCHAR(5)
          , @c_Loc            NVARCHAR(10)
          , @c_ToLoc          NVARCHAR(10) = ''
          , @c_Loc2           NVARCHAR(10) = ''
          , @c_InOut          CHAR(1) = 'I' )

RETURNS @tBookDoor TABLE
(     Loc   NVARCHAR(10) NOT NULL
)
AS
BEGIN
   DECLARE @c_LocCategory  NVARCHAR(10)
         , @c_LocCategory2 NVARCHAR(10)   --ML01

   IF ISNULL(@c_Loc,'') = ''
   BEGIN
      RETURN
   END

   IF ISNULL(@c_ToLoc,'') = ''
   BEGIN
      SET @c_ToLoc = @c_Loc
   END

   IF ISNULL(@c_Loc2,'') <> ''
   BEGIN
      INSERT INTO @tBookDoor ( Loc )
      VALUES (@c_Loc2)
   END

   --ML01-S
   IF @c_InOut = 'A'
   BEGIN
      SET @c_LocCategory = 'BayIn'
      SET @c_LocCategory2 = 'BayOut'
   END
   ELSE
   --ML01-E
   IF @c_InOut = 'I'
   BEGIN
      SET @c_LocCategory = 'BayIn'
      SET @c_LocCategory2 = 'BayIn'   --ML01
   END
   ELSE
   BEGIN
      SET @c_LocCategory = 'BayOut'
      SET @c_LocCategory2 = 'BayOut'  --ML01
   END


   INSERT INTO @tBookDoor ( Loc )
   SELECT LOC
   FROM LOC WITH (NOLOCK)
   LEFT JOIN CODELKUP WITH (NOLOCK) ON LOC.LOC = CODELKUP.Long
                                    AND LOC.Facility = CODELKUP.Short
                                    AND CODELKUP.Listname = 'USREXCLBAY'
                                    AND CODELKUP.UDF01 = SUSER_SNAME()
   WHERE LocationCategory IN (@c_LocCategory,@c_LocCategory2,'Bay')   --ML01
   AND LOC.Facility = @c_facility 
   AND LOC.Loc BETWEEN @c_Loc AND @c_ToLoc
   AND CODELKUP.Code IS NULL 
   GROUP BY Logicallocation, Loc 
   ORDER BY logicallocation, Loc
    

   RETURN
END -- procedure
GO
GRANT SELECT ON [dbo].[fnc_GetBookingDoor] TO nSQL 
GO
