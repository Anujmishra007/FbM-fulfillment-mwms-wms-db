SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Function:  fnc_GetBookingDescByGrpFloor                              */
/* Creation Date: 2022-02-28                                            */
/* Copyright: LFL                                                       */
/* Written by: WAN                                                      */
/*                                                                      */
/* Purpose: Get booking count in description                            */
/*        : Copy from fnc_GetBookingDescByDate to modify                */
/*        : LFWM-3336 - Door Booking SPsDB queries clarification        */
/*                                                                      */
/* Called By:  Booking Module                                           */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver.  Purposes                                  */
/* 2022-02-28  Wan      1.0   Created & DevOps Combine Script           */
/* 2022-11-16  Wan01    1.1   WMS-21173-[PH] - Colgate-Palmolive Inbound*/
/*                            Doorbooking EndTime                       */
/************************************************************************/

CREATE OR ALTER FUNCTION [dbo].[fnc_GetBookingDescByGrpFloor] ( 
      @c_Facility    NVARCHAR(5)
   ,  @d_FromDate    DATETIME
   ,  @d_ToDate      DATETIME       
   ,  @c_InOut       NVARCHAR(1)
   ,  @c_LocGroup    NVARCHAR(10)=  ''               
   ,  @c_Floor       NVARCHAR(3) =  ''                
) RETURNS @t_DoorBook TABLE
   (
      [Date]            DATETIME   
   ,  [Desc]            NVARCHAR(80) 
   ,  LocUsedperctg     FLOAT          DEFAULT(0.00)
   ,  NoOfReserved      INT            DEFAULT(0)
   )   
AS
BEGIN
   SET QUOTED_IDENTIFIER OFF

   DECLARE @n_TotalLoc              INT = 0
          ,@n_interval              FLOAT        = 30.00             --CR 2.0
          ,@c_BayInOut              NVARCHAR(10) = 'BAYIN'
          
   DECLARE @t_Loc TABLE 
         ( Loc                      NVARCHAR(10)   PRIMARY KEY
         , LocationCategory         NVARCHAR(10)   NOT NULL DEFAULT('')
         , LocationGroup            NVARCHAR(10)   NOT NULL DEFAULT('')
         , [Floor]                  NVARCHAR(3)    NOT NULL DEFAULT('')
         )  

   SET @d_ToDate = CONVERT(NVARCHAR(10), @d_ToDate, 112) + ' 23:59:59:998'
   --SET @d_ToDate = DATEADD(dd, 1, @d_ToDate)
   
   --CR 2.0 (START)
   SELECT @n_interval = CAST(n.NSQLValue AS INT)  
   FROM dbo.NSQLCONFIG AS n WITH (NOLOCK) 
   WHERE n.ConfigKey = 'BOOKINGINTERVAL'
   
   IF @n_interval = 0 SET @n_interval = 30.00
   --CR 2.0 (END)
   
   IF @c_InOut = 'O'
   BEGIN
      SET @c_BayInOut = 'BAYOUT'
   END 

   SET @c_LocGroup = ISNULL(@c_LocGroup,'')  
   SET @c_Floor = ISNULL(@c_Floor,'')  
   
   IF @c_LocGroup = '' 
   BEGIN
      INSERT INTO @t_Loc
          (
              Loc
          ,   LocationCategory
          ,   LocationGroup
          ,   [Floor]
          )
      SELECT l.Loc
            ,l.LocationCategory
            ,LocationGroup = ISNULL(l.LocationGroup,'')
            ,l.[Floor]
      FROM dbo.LOC AS l WITH (NOLOCK)
      WHERE l.Facility = @c_Facility
      AND l.[Floor] = @c_Floor     
   END
   ELSE
   BEGIN
      ;WITH l AS
      (
         SELECT l.Loc
               ,l.LocationCategory
               ,LocationGroup = ISNULL(l.LocationGroup,'')
               ,l.[Floor]
         FROM dbo.LOC AS l WITH (NOLOCK)
         WHERE l.Facility = @c_Facility
         AND l.[Floor] = @c_Floor
      )
      INSERT INTO @t_Loc
          (
              Loc
          ,   LocationCategory
          ,   LocationGroup
          ,   [Floor]
          )
      SELECT l.Loc
            ,l.LocationCategory
            ,LocationGroup = ISNULL(l.LocationGroup,'')
            ,l.[Floor]
      FROM l
      WHERE l.LocationGroup = @c_LocGroup
   END
   
   SELECT @n_TotalLoc = COUNT(1)
   FROM @t_Loc AS tl
   WHERE tl.LocationCategory IN('BAY', @c_BayInOut)
   
   IF @c_InOut = 'I'
   BEGIN
      ;WITH B AS
      (
         SELECT [Count] = COUNT(1)
               ,DurationMin = SUM( CEILING(DATEDIFF(mi,'1900-01-01', BI.duration)/@n_interval) * @n_interval )             --CR 2.0 (END)
               ,[Date] = CASE WHEN BI.BookingDate BETWEEN @d_Fromdate AND @d_ToDate    --(Wan01) 
                              THEN CONVERT(CHAR(10), BI.BookingDate, 121)              --(Wan01) 
                              ELSE CONVERT(CHAR(10), BI.EndTime, 121)                  --(Wan01) 
                              END 
               ,NoOfReserved = 0
         FROM BOOKING_IN BI (NOLOCK)
         JOIN dbo.LOC AS l WITH (NOLOCK) ON l.Loc = BI.Loc                                                                                
         JOIN @t_Loc AS tl ON tl.Loc = l.Loc   
         WHERE BI.Facility = @c_Facility
         AND BI.[Status] <> '9'
         AND (BI.BookingDate BETWEEN @d_Fromdate AND @d_ToDate OR                      --(Wan01)
              BI.EndTime     BETWEEN @d_Fromdate AND @d_ToDate)                        --(Wan01)
         GROUP BY CASE WHEN BI.BookingDate BETWEEN @d_Fromdate AND @d_ToDate           --(Wan01) 
                              THEN CONVERT(CHAR(10), BI.BookingDate, 121)              --(Wan01) 
                              ELSE CONVERT(CHAR(10), BI.EndTime, 121)                  --(Wan01) 
                              END 
      )
      , SB AS
      (
         SELECT Count_ShareBay = COUNT(1)
               ,DurationMin_ShareBay = SUM( CEILING(DATEDIFF(mi,'1900-01-01', BO.duration)/@n_interval) * @n_interval )    --CR 2.0 (END)            
               ,[Date] = CASE WHEN BO.BookingDate BETWEEN @d_Fromdate AND @d_ToDate 
                              THEN CONVERT(CHAR(10), BO.BookingDate, 121) 
                              ELSE CONVERT(CHAR(10), BO.EndTime, 121) 
                              END
               ,NoOfReserved = SUM(IIF(BO.[Status] = 'R',1,0))         
         FROM BOOKING_OUT BO (NOLOCK)
         JOIN dbo.LOC AS l (NOLOCK) ON BO.Loc = l.Loc
         JOIN @t_Loc AS tl ON tl.Loc = l.Loc                 
         WHERE BO.Facility = @c_Facility
         AND BO.[Status] NOT IN ( '9' )
         AND ( BO.BookingDate BETWEEN @d_Fromdate AND @d_ToDate OR
               BO.EndTime     BETWEEN @d_Fromdate AND @d_ToDate )      
         AND l.LocationCategory = 'BAY'
         GROUP BY CASE WHEN BO.BookingDate BETWEEN @d_Fromdate AND @d_ToDate 
                       THEN CONVERT(CHAR(10), BO.BookingDate, 121) 
                       ELSE CONVERT(CHAR(10), BO.EndTime, 121) END
      )
      INSERT INTO @t_DoorBook
          (
            [Date]
          , [Desc]
          , LocUsedPerctg    
          , NoOfReserved
          )
      SELECT  B.[Date]
            , [Desc] = CASE WHEN ISNULL(SB.Count_ShareBay,0) > 0
                            THEN RTRIM(LTRIM(STR(B.[Count]))) + ' Booking (I)' + CHAR(10) + RTRIM(LTRIM(STR(ISNULL(SB.Count_ShareBay,0)))) + ' Booking (O)'
                            WHEN B.[Count] > 0
                            THEN RTRIM(LTRIM(STR(B.[Count]))) + ' Booking (I)'
                            ELSE ''
                            END
                     + CASE WHEN B.[Count] + ISNULL(SB.Count_ShareBay,0) > 0 AND B.DurationMin + ISNULL(SB.DurationMin_ShareBay,0) > 0
                            THEN CHAR(10) + ' ' + STR(( (B.DurationMin + ISNULL(SB.DurationMin_ShareBay,0)) / ((@n_TotalLoc * 24) * 60.00) * 100),5,2)+ '%'
                            ELSE ''
                            END 
            , LocUsedPerctg = CASE WHEN B.[Count] + ISNULL(SB.Count_ShareBay,0) > 0 AND B.DurationMin + ISNULL(SB.DurationMin_ShareBay,0) > 0
                                   THEN ROUND((B.DurationMin + ISNULL(SB.DurationMin_ShareBay,0)) / ((@n_TotalLoc * 24) * 60.00) * 100, 2)
                                   ELSE 0.00
                                   END 
            , NoOfReserved = B.NoOfReserved + ISNULL(SB.NoOfReserved,0)       
      FROM B
      LEFT OUTER JOIN SB ON SB.[Date] = B.[Date]
   END
   ELSE
   BEGIN
      ;WITH B AS
      (
         SELECT [Count] = COUNT(1)
               ,DurationMin = SUM( CEILING(DATEDIFF(mi,'1900-01-01', BO.duration)/@n_interval) * @n_interval )             --CR 2.0 (END)
               ,[Date] = CASE WHEN BO.BookingDate BETWEEN @d_Fromdate AND @d_ToDate 
                              THEN CONVERT(CHAR(10), BO.BookingDate, 121) 
                              ELSE CONVERT(CHAR(10), BO.EndTime, 121) 
                              END
               ,NoOfReserved = SUM(IIF(BO.[Status]= 'R', 1, 0))          
         FROM BOOKING_OUT BO (NOLOCK)
         JOIN dbo.LOC AS l WITH (NOLOCK) ON l.Loc = BO.Loc                                                                               
         JOIN @t_Loc AS tl ON tl.Loc = l.Loc  
         WHERE BO.Facility = @c_Facility
         AND BO.[Status] NOT IN ( '9' )
         AND ( BO.BookingDate BETWEEN @d_Fromdate AND @d_ToDate OR
               BO.EndTime     BETWEEN @d_Fromdate AND @d_ToDate )   
         GROUP BY CASE WHEN BO.BookingDate BETWEEN @d_Fromdate AND @d_ToDate 
                       THEN CONVERT(CHAR(10), BO.BookingDate, 121) 
                       ELSE CONVERT(CHAR(10), BO.EndTime, 121) 
                       END      
      )
      , SB AS
      (
         SELECT Count_ShareBay = COUNT(1)
               ,DurationMin_ShareBay = SUM( CEILING(DATEDIFF(mi,'1900-01-01', BI.duration)/@n_interval) * @n_interval )    --CR 2.0 (END)
               ,[Date] = CASE WHEN BI.BookingDate BETWEEN @d_Fromdate AND @d_ToDate    --(Wan01) 
                              THEN CONVERT(CHAR(10), BI.BookingDate, 121)              --(Wan01) 
                              ELSE CONVERT(CHAR(10), BI.EndTime, 121)                  --(Wan01) 
                              END                                                      --(Wan01) 
               ,NoOfReserved = 0
         FROM BOOKING_IN BI (NOLOCK)
         JOIN dbo.LOC AS l(NOLOCK) ON BI.Loc = l.Loc
         JOIN @t_Loc AS tl ON tl.Loc = l.Loc        
         WHERE BI.Facility = @c_Facility
         AND BI.[Status] <> '9'
         AND (BI.BookingDate BETWEEN @d_Fromdate AND @d_ToDate OR                      --(Wan01)
              BI.EndTime BETWEEN @d_Fromdate AND @d_ToDate)                            --(Wan01)
         AND l.LocationCategory = 'BAY'
         GROUP BY CASE WHEN BI.BookingDate BETWEEN @d_Fromdate AND @d_ToDate           --(Wan01) 
                       THEN CONVERT(CHAR(10), BI.BookingDate, 121)                     --(Wan01) 
                       ELSE CONVERT(CHAR(10), BI.EndTime, 121)                         --(Wan01) 
                       END 
      )
      INSERT INTO @t_DoorBook
          (
            [Date]
          , [Desc]
          , LocUsedPerctg    
          , NoOfReserved
          )
      SELECT B.[Date]
            ,[Desc] = CASE WHEN ISNULL(SB.Count_ShareBay,0) > 0
                           THEN RTRIM(LTRIM(STR(B.[Count]))) + ' Booking (O)' + CHAR(10) + RTRIM(LTRIM(STR(ISNULL(SB.Count_ShareBay,0)))) + ' Booking (I)'
                           WHEN B.[Count] > 0
                           THEN RTRIM(LTRIM(STR(B.[Count]))) + ' Booking (O)'
                           ELSE ''
                           END
                    + CASE WHEN B.[Count] + ISNULL(SB.Count_ShareBay,0) > 0 AND B.DurationMin + ISNULL(SB.DurationMin_ShareBay,0) > 0
                           THEN CHAR(10) + ' ' + STR(( (B.DurationMin + ISNULL(SB.DurationMin_ShareBay,0)) / ((@n_TotalLoc * 24) * 60.00) * 100),5,2)+ '%'
                           ELSE ''
                           END 
            ,LocUsedPerctg = CASE WHEN B.[Count] + ISNULL(SB.Count_ShareBay,0) > 0 AND B.DurationMin + ISNULL(SB.DurationMin_ShareBay,0) > 0
                                  THEN ROUND((B.DurationMin + ISNULL(SB.DurationMin_ShareBay,0)) / ((@n_TotalLoc * 24) * 60.00) * 100, 2)
                                  ELSE 0.00
                                  END 
            ,NoOfReserved = B.NoOfReserved + ISNULL(SB.NoOfReserved,0)                            
      FROM B
      LEFT OUTER JOIN SB ON SB.[Date] = B.[Date]
   END
   RETURN
END
GO
GRANT SELECT  ON [dbo].[fnc_GetBookingDescByGrpFloor] TO nSQL 
GO
