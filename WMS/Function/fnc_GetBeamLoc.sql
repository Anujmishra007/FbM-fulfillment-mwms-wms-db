SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Function: fnc_GetBeamLoc                                             */
/* Creation Date: 2025-04-15                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: UWP-32707 - FCR-3957 - JCB Putaway Using TM SCE             */
/*                                                                      */
/* Input Parameters:  @c_ReceiptKey                                     */
/*                                                                      */
/* Output Parameters:  @b_Success                                       */
/*                   , @n_err                                           */
/*                   , @c_errmsg                                        */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: JCB - mspPARL01                                           */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2025-04-16  Wan      1.0   UWP-32707 - FCR-3957 - JCB Putaway Using  */
/*                            TM SCE                                    */
/************************************************************************/

CREATE OR ALTER FUNCTION [dbo].[fnc_GetBeamLoc] 
(  @c_Storerkey         NVARCHAR(15)  
,  @c_Facility          NVARCHAR(50)  
,  @c_LocationGroups    NVARCHAR(200)= '' 
,  @c_LocationCategory  NVARCHAR(10) = '' 
,  @c_LocAisle          NVARCHAR(10) = '' 
,  @c_LocationRoom      NVARCHAR(10) = ''
,  @n_LocLevel          INT          = 0
)
RETURNS @t_BeamLocs     TABLE 
(  LocationGroup        NVARCHAR(10)   DEFAULT ('')
,  LocationCategory     NVARCHAR(10)   DEFAULT ('')
,  LocAisle             NVARCHAR(10)   DEFAULT ('')
,  LocationRoom         NVARCHAR(10)   DEFAULT ('')
,  LocLevel             INT            DEFAULT (0)
,  [Status]             NVARCHAR(10)   DEFAULT ('')
,  StartLoc             NVARCHAR(10)   DEFAULT ('')
,  EndLoc               NVARCHAR(10)   DEFAULT ('')
,  EmptyLocCount        INT            DEFAULT (1)
,  EmptyLPNCount        INT            DEFAULT (1)
,  LocCount             INT            DEFAULT (1)
,  TotalPalletWeights   FLOAT          DEFAULT (0.00)
)
AS  
BEGIN
   DECLARE  @TMP_PALTYPE_CL TABLE                                                     
   (                           
       [LISTNAME]    [nvarchar](10)    NULL,  
       [Code]        [nvarchar](30)    NULL,  
       [Description] [nvarchar](250)   NULL,  
       [Short]       [nvarchar](10)    NULL,  
       [Long]        [nvarchar](250)   NULL,  
       [Notes]       [nvarchar](4000)  NULL,  
       [Notes2]      [nvarchar](4000)  NULL,  
       [Storerkey]   [nvarchar](50)    NOT NULL,  
       [UDF01]       [nvarchar](60)    NOT NULL,  
       [UDF02]       [nvarchar](60)    NOT NULL,  
       [UDF03]       [nvarchar](60)    NOT NULL,  
       [UDF04]       [nvarchar](60)    NOT NULL,  
       [UDF05]       [nvarchar](60)    NOT NULL,  
       [code2]       [nvarchar](30)    NOT NULL  
   )

    DECLARE @t_Locs     TABLE 
   (  RowId                INT            IDENTITY(1,1)   PRIMARY KEY
   ,  Loc                  NVARCHAR(10)   DEFAULT ('')   
   ,  LogicalLocation      NVARCHAR(10)   DEFAULT ('') 
   ,  LocationFlag         NVARCHAR(10)   DEFAULT ('')      
   ,  LocationGroup        NVARCHAR(10)   DEFAULT ('')
   ,  LocationCategory     NVARCHAR(10)   DEFAULT ('')
   ,  LocAisle             NVARCHAR(10)   DEFAULT ('')
   ,  LocationRoom         NVARCHAR(10)   DEFAULT ('')
   ,  LocLevel             INT            DEFAULT (0)
   ,  PALocNo              NVARCHAR(3)    DEFAULT ('') 
   ,  [Status]             NVARCHAR(10)   DEFAULT ('')
   ,  MaxPallet            INT            DEFAULT (0)
   )

   DECLARE @t_Beam         TABLE 
   (  LocationRoom         NVARCHAR(10)   DEFAULT ('')   PRIMARY KEY
   ,  MidRowID             INT            DEFAULT (0)
   ,  TotalPalletWeights   FLOAT          DEFAULT (0.00)
   )

   DECLARE @t_OccupiedLoc  TABLE 
   (  RowId                INT            DEFAULT (0)
   ,  Loc                  NVARCHAR(10)   DEFAULT ('')   PRIMARY KEY
   ,  LocationRoom         NVARCHAR(10)   DEFAULT ('')    
   ,  EmptyLPNCount        INT            DEFAULT (0)
   )

   INSERT INTO @TMP_PALTYPE_CL (Listname, Code, Description, Short, Long, Notes, Notes2, Storerkey
                              , UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
   SELECT CODELKUP.Listname   
        , CODELKUP.Code   
        , [Description] = ISNULL(CODELKUP.[Description],'')   
        , Short = CASE WHEN ISNUMERIC(CODELKUP.Short) = 1 THEN CODELKUP.Short ELSE '0' END     
        , Long  = ISNULL(CODELKUP.Long ,'')     
        , Notes = ISNULL(CODELKUP.Notes,'')      
        , Notes2= ISNULL(CODELKUP.Notes2,'')           
        , CODELKUP.Storerkey  
        , CODELKUP.UDF01   
        , CODELKUP.UDF02   
        , CODELKUP.UDF03   
        , CODELKUP.UDF04   
        , CODELKUP.UDF05   
        , CODELKUP.Code2  
   FROM CODELKUP (NOLOCK)  
   WHERE CODELKUP.Listname = 'JCBPALTYPE' 
   AND CODELKUP.Storerkey = @c_Storerkey 
   ORDER BY CODELKUP.Code

   IF @c_LocationRoom > ''
   BEGIN
      INSERT INTO @t_Locs ( Loc, LogicalLocation, LocationFlag
                        , LocationGroup, LocationCategory, LocAisle
                        , LocationRoom, LocLevel, [Status], MaxPallet
                        , PALocNo
                        )
      SELECT 
           l.Loc 
         , l.LogicalLocation
         , l.LocationFlag
         , l.LocationGroup
         , l.LocationCategory      
         , l.LocAisle              
         , l.LocationRoom
         , l.LocLevel
         , l.[Status]
         , l.MaxPallet
         , PALocNo = RIGHT(l.Loc,1) 
      FROM LOC l (NOLOCK)
      JOIN string_split (@c_LocationGroups, ',') ss ON ss.[value] = l.LocationGroup
      WHERE l.Facility = @c_Facility
      AND l.LocationCategory = @c_LocationCategory
      AND l.LocAisle = @c_LocAisle
      AND l.LocationRoom = @c_LocationRoom 
      AND l.LocLevel = @n_LocLevel
      AND l.MaxPallet > 0
      AND RIGHT(l.Loc,1) BETWEEN '1' AND '9'
      ORDER BY l.Loc;

      INSERT INTO @t_Beam (LocationRoom, MidRowID, TotalPalletWeights)
      SELECT l.LocationRoom
            ,MidRowID = CEILING(COUNT(1)/2.00)   
            ,TotalPalletWeights = SUM(CASE WHEN ISNULL(lli.Qty-lli.QtyPicked+lli.PendingMoveIN,0)=0 THEN 0 ELSE ISNULL(pm.GrossWgt,0.00) END)  
      FROM @t_Locs l  
      LEFT OUTER JOIN LotxLocxid lli (NOLOCK) ON lli.loc = l.loc and lli.Storerkey = @c_Storerkey
                                                AND lli.id > ''
      LEFT OUTER JOIN Pallet pm (NOLOCK) ON pm.PalletKey = lli.ID
      GROUP BY l.LocationRoom

      ;WITH OccupiedLoc AS  
      (  SELECT 
              l.Loc    
            , l.LocationRoom
            , StartRowID = l.RowId
            , EndRowID   = CASE  WHEN l.RowId < bl.MidRowID 
                                 THEN l.RowID + cl.Short - 1 
                                 ELSE l.RowID - cl.Short + 1 END
            FROM @t_Locs l   
            JOIN @t_Beam bl ON bl.LocationRoom = l.LocationRoom
            JOIN LotxLocxid lli (NOLOCK) ON lli.loc = l.loc and lli.ID > '' AND lli.Storerkey = @c_Storerkey
            JOIN Pallet pm (NOLOCK) ON pm.palletkey = lli.ID  
            JOIN @TMP_PALTYPE_CL cl ON cl.code = pm.PalletType AND cl.ListName = 'JCBPALTYPE'
            GROUP BY l.Loc
                  , l.LocationRoom 
                  , l.MaxPallet
                  , l.RowID
                  , bl.MidRowID
                  , cl.Short
            HAVING SUM(lli.Qty - lli.Qtypicked + lli.PendingMoveIN) > 0 
      )
      INSERT INTO @t_OccupiedLoc (RowID, Loc, LocationRoom, EmptyLPNCount)
      SELECT l.RowId, l.Loc, l.LocationRoom
            , EmptyLPNCount = l.MaxPallet - COUNT(DISTINCT lli.ID) 
                           - CASE WHEN ol.StartRowID = l.RowID THEN 0 ELSE 1 END
      FROM @t_Locs l
      JOIN OccupiedLoc ol ON ol.LocationRoom = l.LocationRoom
      LEFT OUTER JOIN LotxLocxid lli (NOLOCK) ON lli.loc = l.loc and lli.ID > '' AND lli.Storerkey = @c_Storerkey
      LEFT OUTER JOIN Pallet pm (NOLOCK) ON pm.palletkey = lli.ID  
      WHERE l.RowID BETWEEN ol.StartRowID AND ol.EndRowID
      GROUP BY l.RowId, l.Loc, l.LocationRoom, l.MaxPallet, ol.StartRowID 
      ORDER BY l.RowId;
    
      ; WITH EmptyLocs AS 
      (
         SELECT 
              l.Loc 
            , l.LocationRoom
            , l.RowId 
            , Grp = ROW_NUMBER() OVER (ORDER BY l.RowID) - l.RowID
            , PalletLocSeq = CASE WHEN l.RowId <= bl.MidRowID THEN 'F' ELSE 'B' END
            , bl.TotalPalletWeights
          FROM @t_Locs l  
          JOIN @t_Beam bl ON bl.LocationRoom = l.LocationRoom
          LEFT OUTER JOIN @t_OccupiedLoc ol ON ol.loc = l.loc
          LEFT OUTER JOIN LotxLocxid lli (NOLOCK) ON lli.loc = l.loc and lli.Storerkey = @c_Storerkey
          WHERE l.[Status] = 'OK' 
          AND   l.LocationFlag  IN ('', 'NONE')
          AND   ol.RowId IS NULL
          GROUP BY  l.Loc
                  , l.RowId 
                  , l.LocationRoom 
                  , l.[Status] 
                  , l.LocationFlag
                  , bl.MidRowID
                  , bl.TotalPalletWeights
          HAVING ISNULL(SUM(lli.Qty - lli.Qtypicked + lli.PendingMoveIN),0) = 0
      )
      INSERT INTO @t_BeamLocs (LocationGroup, LocationCategory, LocationRoom, LocLevel, [Status]
                              ,StartLoc, EndLoc, EmptyLocCount, EmptyLPNCount, LocCount, TotalPalletWeights)
      SELECT 
            l.LocationGroup, l.LocationCategory, l.LocationRoom, l.LocLevel, [Status] = 'E'
          , StartLoc = CASE WHEN el.PalletLocSeq = 'F' THEN MIN(el.Loc) ELSE MAX(el.Loc) END   
          , EndLoc   = CASE WHEN el.PalletLocSeq = 'F' THEN MAX(el.Loc) ELSE MIN(el.Loc) END    
          , EmptyLocCount = Count(1)
          , EmptyLPNCount = SUM(l.MaxPallet)
          , LocCount      = Count(1)
          , el.TotalPalletWeights
      FROM EmptyLocs el
      JOIN @t_Locs l ON l.RowId = el.RowId
      GROUP BY l.LocationGroup, l.LocationCategory, l.LocationRoom, l.LocLevel 
             , el.grp, el.PalletLocSeq, el.TotalPalletWeights
      ORDER BY MIN (l.LogicalLocation)


      INSERT INTO @t_BeamLocs (LocationGroup, LocationCategory, LocationRoom, LocLevel, [Status]
                              ,StartLoc, EndLoc, EmptyLocCount, EmptyLPNCount, LocCount, TotalPalletWeights)
      SELECT 
            l.LocationGroup, l.LocationCategory, l.LocationRoom, l.LocLevel, [Status] = 'O'
          , StartLoc = l.Loc
          , EndLoc   = l.Loc    
          , EmptyLocCount = 0
          , EmptyLPNCount = ol.EmptyLPNCount
          , LocCount      = Count(1)
          , b.TotalPalletWeights
      FROM @t_OccupiedLoc ol
      JOIN @t_Locs l ON l.RowId = ol.RowId
      JOIN @t_Beam b ON b.LocationRoom = l.LocationRoom
      WHERE ol.EmptyLPNCount > 0
      GROUP BY l.LocationGroup, l.LocationCategory, l.LocationRoom, l.LocLevel, l.Loc, l.LogicalLocation
             , ol.EmptyLPNCount, b.TotalPalletWeights
      ORDER BY l.LogicalLocation
   END

   RETURN 
END


 