SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Function: dbo.fnc_GetToZoneAisle                                     */
/* Creation Date: 2025-06-09                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:  FCR-2902 - MLP Enhancement - Allocate Case/Shrink at BULK, */
/*        :  Demand Replenishment to DPP                                */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author    Ver Purposes                                   */
/* 2025-06-09  Wan      1.0   Created                                   */
/************************************************************************/ 
CREATE OR ALTER FUNCTION [dbo].[fnc_GetToZoneAisle]
(  @c_Facility       NVARCHAR(5)    
,  @c_FromZone       NVARCHAR(10) = ''  
,  @c_ToZone         NVARCHAR(10) = ''  
,  @c_FromAisle      NVARCHAR(10) = ''
,  @c_ToAisle        NVARCHAR(10) = ''
,  @c_DirectionType  NVARCHAR(10) = ''
,  @c_PZJSon         NVARCHAR(MAX)= ''
)
RETURNS @t_ZoneAisle TABLE
(
  RowID        INT            IDENTITY(1,1)         PRIMARY KEY
, Facility     NVARCHAR(5)    NOT NULL DEFAULT('')
, [Zone]       NVARCHAR(10)   NOT NULL DEFAULT('')
, LocAisle     NVARCHAR(10)   NOT NULL DEFAULT('')
, Direction    NCHAR(1)       NOT NULL DEFAULT('')
)
AS
BEGIN 
   DECLARE @t_TZ TABLE  
   ( 
     Facility     NVARCHAR(5)    NOT NULL DEFAULT('')
   , [Zone]       NVARCHAR(10)   NOT NULL DEFAULT('')
   , RowNum       INT            NOT NULL DEFAULT(0) PRIMARY KEY
   )
 
   DECLARE @t_DZ TABLE 
   ( 
     Facility     NVARCHAR(5)    NOT NULL DEFAULT('')
   , [Zone]       NVARCHAR(10)   NOT NULL DEFAULT('')
   , RowNum       INT            NOT NULL DEFAULT(0) PRIMARY KEY
   )

   DECLARE @t_ZA TABLE 
   ( RowID        INT            IDENTITY(1,1)       PRIMARY KEY
   , Facility     NVARCHAR(5)    NOT NULL DEFAULT('')
   , [Zone]       NVARCHAR(10)   NOT NULL DEFAULT('')
   , LocAisle     NVARCHAR(10)   NOT NULL DEFAULT('')
   , Direction    NCHAR(1)       NOT NULL DEFAULT('')
   , RowNum       INT            NOT NULL DEFAULT(0) 
   )

   IF @c_PZJSON = ''
   BEGIN
      GOTO  QUIT_FNC
   END

   INSERT INTO @t_DZ (Facility, [Zone], RowNum)
   SELECT l.Facility
         ,l.PutawayZone 
         ,RowNum = CASE WHEN l.PutawayZone = @c_FromZone THEN 1
                        WHEN l.PutawayZone > @c_FromZone 
                        THEN  ROW_NUMBER() OVER (  
                                                PARTITION BY 
                                                CASE WHEN l.PutawayZone > @c_FromZone
                                                THEN 1 ELSE 0 END 
                                                ORDER BY l.PutawayZone ASC
                                                ) * 2 
                        ELSE (ROW_NUMBER() OVER (  
                                                PARTITION BY 
                                                CASE WHEN l.PutawayZone < @c_FromZone
                                                THEN 1 ELSE 0 END 
                                                ORDER BY l.PutawayZone DESC 
                                                ) * 2
                             ) + 1 
      END
   FROM OPENJSON(@c_PZJson)
   WITH  ( Facility      NVARCHAR(5)
         , PutawayZone   NVARCHAR(10)
         , LocAisle      NVARCHAR(10)
         ) l 
   GROUP BY l.Facility, l.PutawayZone
   ORDER BY RowNum

   IF @c_ToZone = ''
   BEGIN
      SELECT TOP 1 @c_ToZone = [Zone]
      FROM @t_DZ
      ORDER BY RowNum Desc
   END

   IF @c_DirectionType = 'FWD'
   BEGIN
      INSERT INTO @t_TZ (Facility, [Zone], RowNum)
      SELECT dz.Facility, dz.[Zone], dz.RowNum  
      FROM @t_DZ dz 
      OUTER APPLY (SELECT TOP 1 dz1.RowNum   
                   FROM @t_DZ dz1 WHERE dz1.[Zone] = @c_ToZone
                   ORDER BY dz1.RowNum 
                  ) tz
      WHERE dz.RowNum % 2 = 0 OR dz.RowNum = 1
      AND   dz.RowNum <= tz.RowNum
      ORDER BY dz.RowNum   
   END
   ELSE IF @c_DirectionType = 'BWD'
   BEGIN
      INSERT INTO @t_TZ (Facility, [Zone], RowNum)
      SELECT dz.Facility, dz.[Zone], dz.RowNum  
      FROM @t_DZ dz 
      OUTER APPLY (SELECT TOP 1 dz1.RowNum   
                   FROM @t_DZ dz1 WHERE dz1.[Zone] = @c_ToZone
                   ORDER BY dz1.RowNum 
                  ) tz
      WHERE dz.RowNum % 2 = 1
      AND   dz.RowNum <= tz.RowNum
      ORDER BY dz.RowNum  
   END
   ELSE IF @c_DirectionType = 'FWDBWD'
   BEGIN
      INSERT INTO @t_TZ (Facility, [Zone], RowNum)
      SELECT dz.Facility, dz.[Zone], dz.RowNum  
      FROM @t_DZ dz 
      OUTER APPLY (SELECT TOP 1 dz1.RowNum   
                   FROM @t_DZ dz1 WHERE dz1.[Zone] = @c_ToZone
                   ORDER BY dz1.RowNum 
                  ) tz
      WHERE dz.RowNum <= tz.RowNum
      ORDER BY dz.RowNum  
   END

   IF @c_FromAisle = '' AND @c_ToAisle = ''
   BEGIN
      INSERT INTO @t_ZoneAisle ( Facility, [Zone], LocAisle, Direction)
      SELECT tz.Facility
            ,tz.[Zone]
            ,LocAisle = ''
            ,Direction = CASE WHEN tz.RowNum % 2 = 0 OR tz.RowNum = 1
                              THEN 'F' ELSE 'B' END
      FROM @t_TZ tz 
      ORDER BY tz.RowNum  
   END
   ELSE
   BEGIN
      INSERT INTO @t_ZA (Facility, [Zone], LocAisle, RowNum, Direction)
      SELECT l.Facility
            ,l.PutawayZone
            ,l.LocAisle
            ,RowNum = CASE WHEN l.PutawayZone = @c_FromZone AND l.LocAisle = @c_FromAisle 
                           THEN 1
                           WHEN l.PutawayZone = @c_FromZone AND l.LocAisle >=@c_FromAisle 
                           THEN  ROW_NUMBER() OVER (
                                    PARTITION BY l.PutawayZone 
                                                ,CASE WHEN l.LocAisle > @c_FromAisle 
                                                      THEN 1 
                                                      ELSE 0 
                                                      END
                                    ORDER BY l.PutawayZone, l.LocAisle ASC) * 2  

                           WHEN l.PutawayZone = @c_FromZone AND l.LocAisle < @c_FromAisle 
                           THEN  (ROW_NUMBER() OVER (
                                    PARTITION BY l.PutawayZone 
                                                ,CASE WHEN l.LocAisle < @c_FromAisle  
                                                      THEN 1 
                                                      ELSE 0 
                                                      END
                                    ORDER BY l.PutawayZone, l.LocAisle DESC) * 2
                                 ) + 1  
                           WHEN l.PutawayZone > @c_FromZone
                           THEN ROW_NUMBER() OVER (PARTITION BY l.PutawayZone
                                                   ORDER BY l.PutawayZone, l.LocAisle ASC)
                           ELSE ROW_NUMBER() OVER (PARTITION BY l.PutawayZone
                                                   ORDER BY l.PutawayZone, l.LocAisle DESC)
                           END
            ,Direction =  CASE WHEN l.PutawayZone = @c_FromZone AND l.LocAisle >= @c_FromAisle 
                               THEN 'F'
                               WHEN l.PutawayZone > @c_FromZone 
                               THEN 'F'
                               ELSE 'B'
                               END
      FROM @t_TZ tz
      JOIN OPENJSON(@c_PZJson)
      WITH  ( Facility      NVARCHAR(5)
            , PutawayZone   NVARCHAR(10)
            , LocAisle      NVARCHAR(10)
            ) l ON  l.Facility    = tz.Facility
                AND l.PutawayZone = tz.[Zone] 
      GROUP BY tz.RowNum
            ,  l.Facility
            ,  l.PutawayZone
            ,  l.LocAisle
      ORDER BY tz.RowNum
             , RowNum

      IF @c_ToAisle = ''
      BEGIN
         SELECT TOP 1 @c_ToAisle = LocAisle
         FROM @t_ZA
         WHERE [Zone] = @c_ToZone                        --2025-08-13
         ORDER BY RowNum Desc
      END    

      INSERT INTO @t_ZoneAisle ( Facility, [Zone], LocAisle, Direction)
      SELECT za.Facility, za.[Zone], za.LocAisle, za.Direction
      FROM @t_ZA za 
      OUTER APPLY (SELECT TOP 1 za1.RowID   
                   FROM @t_ZA za1
                   WHERE za1.[Zone]   = @c_ToZone
                   AND   za1.LocAisle = @c_ToAisle
                   ORDER BY za.RowID DESC
                   ) tza
      WHERE za.RowID <= tza.RowID
      ORDER BY za.RowID
   END

   QUIT_FNC:
   RETURN
END