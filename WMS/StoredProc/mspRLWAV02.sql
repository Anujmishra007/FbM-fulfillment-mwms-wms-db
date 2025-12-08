SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspRLWAV02                                          */    
/* Creation Date: 2024-05-15                                             */
/* Copyright: Maersk                                                     */    
/* Written by: Supriya Sangeetham                                        */    
/*                                                                       */    
/* Purpose: UWP-18823 - Trigger replenishment with wave release          */  
/*                                                                       */    
/* Called By: Wave Release                                               */    
/*                                                                       */    
/* Version: 1.0                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 2024-06-04  SSA01    1.1   Updated to update the taskdetailkey        */
/*                            in the pickDetail table                    */
/* 2024-10-04  SSA02    1.2   UWP-25919-JCB-Release & Reverse Wave       */
/*                            for Kitting and Decanting                  */
/* 2024-11-04  SSA03    1.3   Updating size for the LOC and ID variables */
/*                            while fetching qty from inventory ,updated */
/*                            lot mapping while fetching orderkey        */
/* 2024-11-06  SSA04    1.4   Updating to fetch @n_qty, @c_FromID for the*/
/*                            UOM= 1 and updated to fetch the sortlane   */
/* 2024-11-07  SSA05    1.5   Updating to fetch @n_qty for the K4 Kitting*/
/* 2024-11-07  SSA06    1.6   Updating to remove the creating task for   */
/*                            type 2 with UOM1                           */
/* 2024-11-12  SSA07    1.7   Updating to add two step replenishment for */
/*                            type 1 with UOM7                           */
/* 2025-05-09  Wan01    1.8   FCR-3958 - JCB Picking Task                */
/* 2025-06-17                 Overwrite the whole logic as implement new */
/*                            process. Use back same SP                  */
/* 2025-07-01                 Version 1.90 & 1.91 & fixes. Add v2.0      */
/* 2025-07-02                 Version v2.1 & fixes                       */
/* 2025-07-04                 Version v2.2 & fix                         */
/* 2025-09-04                 fix                                        */
/* 2025-10-10  SSA08    1.9   UWP-42248 -Enhanced session management     */
/* 2025-10-24  PPA374   1.10  UWP-42949 -Added PP type for the RPF task  */
/* 2025-12-04  Wan01    1.11  FCR-3958 CR V2.3 (Work with PPA374)        */
/* 2025-12-05  Wan01          UWP-45254                                  */  
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV02]
   @c_Wavekey      NVARCHAR(10)
,  @b_Success      int            = 1   OUTPUT
,  @n_err          int            = 0   OUTPUT
,  @c_errmsg       NVARCHAR(250)  = ''  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue    int = 1
         , @n_starttcnt   int = @@TRANCOUNT         -- Holds the current transaction count
         , @n_debug       int = 0
         , @n_Cnt         int = 0

   SET @b_success = 0
   SET @n_err = 0
   SET @c_errmsg = ''

   DECLARE @c_Facility                 NVARCHAR(5)    = ''
         , @c_Storerkey                NVARCHAR(15)   = ''
         , @c_TMReleaseFlag            NVARCHAR(10)   = 'N'   
 
         , @c_InValid                  NVARCHAR(10)   = ''                           
         , @c_ShortErrMsg              NVARCHAR(20)   = ''  
         , @c_ToLocCodes               NVARCHAR(100)  = ''                          --v1.91
         , @c_FCP                      NCHAR(1)       = 'N'                          
         , @c_RPF                      NCHAR(1)       = 'N'                          
         , @c_OrderType                NVARCHAR(50)   = ''                           
         , @c_C_Company                NVARCHAR(350)  = ''       

         , @c_Taskdetailkey            NVARCHAR(10)   = ''
         , @c_TaskType                 NVARCHAR(10)   = ''
         , @c_SourceType               NVARCHAR(30)   = ''
         , @c_TaskStatus               NVARCHAR(10)   = '0'    
         , @c_Sku                      NVARCHAR(20)   = ''
         , @c_Lot                      NVARCHAR(10)   = ''
         , @c_FromLoc                  NVARCHAR(10)   = ''
         , @c_FromID                   NVARCHAR(18)   = ''
         , @c_Toloc                    NVARCHAR(10)   = ''
         , @c_ToID                     NVARCHAR(18)   = ''
         , @c_FinalLoc                 NVARCHAR(10)   = ''  
         , @c_FinalID                  NVARCHAR(18)   = ''  
         , @c_CaseID                   NVARCHAR(20)   = '' 
         , @n_IDQty                    INT            = 0
         , @n_Qty                      INT            = 0
         , @n_UOMQty                   INT            = 0
         , @c_UOM                      NVARCHAR(10)   = ''
         , @c_Orderkey                 NVARCHAR(10)   = ''
         , @c_LoadKey                  NVARCHAR(10)   = ''
         , @c_Groupkey                 NVARCHAR(10)   = ''
         , @c_RefTaskkey               NVARCHAR(10)   = ''                          --v1.90
         , @c_ReplFromLoc              NVARCHAR(10)   = ''                          --v1.90
         , @c_ReplFromID               NVARCHAR(18)   = ''                          --v1.90
         , @c_Priority                 NVARCHAR(10)   = ''
         , @c_PickMethod               NVARCHAR(10)   = ''
         , @c_Putawayzone              NVARCHAR(10)   = '' 
         , @c_LocationGroup            NVARCHAR(10)   = ''            
         , @c_LocationCategory         NVARCHAR(10)   = ''                           
         , @c_LocAisle                 NVARCHAR(10)   = ''                           
         , @c_Floor                    NVARCHAR(6)    = ''                           
         , @c_Lanes                    NVARCHAR(100)  = '' 
         , @c_LinkTaskToPick_SQL       NVARCHAR(4000) = ''         

         , @c_SQL                      NVARCHAR(MAX)  = ''            
         , @c_SQLParams                NVARCHAR(1000) = '' 
         
         , @cur_RPF                    CURSOR                                                                                         
         , @cur_FCP                    CURSOR                                        
                                                                                     
   DECLARE @TMP_FCP_CL                 TABLE                                                                                
      ( [RowID]                        INT               IDENTITY(1,1) PRIMARY KEY                   
      , [LISTNAME]                     [nvarchar](10)    NULL     
      , [Code]                         [nvarchar](30)    NULL  
      , [Description]                  [nvarchar](250)   NULL  
      , [Short]                        [nvarchar](10)    NULL  
      , [Long]                         [nvarchar](250)   NULL  
      , [Notes]                        [nvarchar](4000)  NULL  
      , [Notes2]                       [nvarchar](4000)  NULL  
      , [Storerkey]                    [nvarchar](50)    NOT NULL  
      , [UDF01]                        [nvarchar](60)    NOT NULL  
      , [UDF02]                        [nvarchar](60)    NOT NULL  
      , [UDF03]                        [nvarchar](60)    NOT NULL  
      , [UDF04]                        [nvarchar](60)    NOT NULL  
      , [UDF05]                        [nvarchar](60)    NOT NULL  
      , [code2]                        [nvarchar](30)    NOT NULL 
      )

   SET @c_SourceType = 'mspRLWAV02'
   SET @c_Priority   = '9'
   SET @c_TaskType   = 'RPF'
   SET @c_PickMethod = 'FP'

   -----Get Storerkey and facility
   SELECT TOP 1 @c_StorerKey= O.Storerkey 
               ,@c_Facility = O.Facility
               ,@c_TMReleaseFlag = w.TMReleaseFlag
   FROM WAVE W (NOLOCK)
   JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
   JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
   WHERE WD.Wavekey = @c_Wavekey
   ORDER BY WD.WaveDetailKey
 
   IF @n_Continue = 1                                                                
   BEGIN
      INSERT INTO @TMP_FCP_CL (Listname, Code, Description, Short, Long                
                              ,Notes, Notes2, Storerkey
                              ,UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
      SELECT CODELKUP.Listname   
           , CODELKUP.Code   
           , [Description] = ISNULL(CODELKUP.[Description],'')   
           , Short = ISNULL(CODELKUP.Short,'')      
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
      WHERE CODELKUP.Listname = 'JCBCOMPML'  
      AND   CODELKUP.Storerkey = @c_Storerkey
      ORDER BY CODELKUP.Code 
      
      INSERT INTO @TMP_FCP_CL (Listname, Code, Description, Short, Long                
                              ,Notes, Notes2, Storerkey
                              ,UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
      SELECT CODELKUP.Listname   
           , CODELKUP.Code   
           , [Description] = ISNULL(CODELKUP.[Description],'')   
           , Short = ISNULL(CODELKUP.Short,'')      
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
      WHERE CODELKUP.Listname = 'JCBORDPR'  
      AND   CODELKUP.Storerkey = @c_Storerkey
      ORDER BY CODELKUP.Code 

      INSERT INTO @TMP_FCP_CL (Listname, Code, Description, Short, Long                
                              ,Notes, Notes2, Storerkey
                              ,UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
      SELECT CODELKUP.Listname   
           , CODELKUP.Code   
           , [Description] = ISNULL(CODELKUP.[Description],'')   
           , Short = ISNULL(CODELKUP.Short,'')      
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
      WHERE CODELKUP.Listname = 'JCBKITORDT'  
      AND   CODELKUP.Storerkey = @c_Storerkey
      ORDER BY CODELKUP.Code 

      IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL                                     
      BEGIN
         DROP TABLE #TMP_ORD
      END

      CREATE TABLE #TMP_ORD
      (  Orderkey       NVARCHAR(10)   NOT NULL    DEFAULT('') PRIMARY KEY
      ,  LoadKey        NVARCHAR(10)   NOT NULL    DEFAULT('')
      ,  MBOLKey        NVARCHAR(10)   NOT NULL    DEFAULT('')
      ,  OtherReference NVARCHAR(30)   NOT NULL    DEFAULT('')
      ,  Facility       NVARCHAR(5)    NOT NULL    DEFAULT('') 
      ,  Storerkey      NVARCHAR(15)   NOT NULL    DEFAULT('')
      ,  [Type]         NVARCHAR(10)   NOT NULL    DEFAULT('')
      ,  [Priority]     NVARCHAR(10)   NOT NULL    DEFAULT('')
      ,  [Status]       NVARCHAR(10)   NOT NULL    DEFAULT('')
      ,  C_Company      NVARCHAR(100)  NOT NULL    DEFAULT('')
      ,  CompML         NVARCHAR(10)   NOT NULL    DEFAULT('')
      ,  KitOrder       INT            NOT NULL    DEFAULT(0)
      ,  KitLoc         NVARCHAR(100)  NOT NULL    DEFAULT('')                      --2025-07-03
      ,  MSLanes        NVARCHAR(100)  NOT NULL    DEFAULT('')                      --2025-07-03
      ,  ToLocCodes     NVARCHAR(100)  NOT NULL    DEFAULT('')                      --v1.91
      ,  AutoRL         NCHAR(1)       NOT NULL    DEFAULT('N')
      ,  FCP            NCHAR(1)       NOT NULL    DEFAULT('N')
      ,  RPF            NCHAR(1)       NOT NULL    DEFAULT('N')
      ,  PRGRP          NVARCHAR(30)   NOT NULL    DEFAULT('')                      --v2.1      
      )

      INSERT INTO #TMP_ORD ( Orderkey, Facility, Storerkey, Loadkey, MBOLKey
                           , OtherReference, [Type], [Priority], [Status]
                           , C_Company, CompML, MSLanes, ToLocCodes                 --v1.91
                           , AutoRL, FCP, RPF, PRGRP                                --v2.1
                           )
      SELECT  
              o.Orderkey
            , o.Facility
            , o.StorerKey
            , LoadKey = ISNULL(lpd.LoadKey,'')
            , MbolKey = ISNULL(md.MbolKey,'')
            , OtherReference = ISNULL(m.OtherReference, '')
            , o.[Type]
            , [Priority]= ISNULL(cl2.Short, '')
            , [Status]  = ISNULL(od.[Status],'0')                                   --2025-09-04
            , C_Company = ISNULL(o.C_Company,'')
            , CompML    = ISNULL(MIN(cl.ListName),'')
            , MSLanes=  ISNULL(STRING_AGG(l.Loc , ',')     
                        WITHIN GROUP (ORDER BY l.Loc, cl.Short ASC),'')             --2025-07-03
            , ToLocCodes=ISNULL(STRING_AGG(cl.Short , ',')     
                        WITHIN GROUP (ORDER BY l.Loc, cl.Short ASC),'')             --2025-07-03
            , AutoRL = CASE WHEN cl2.UDF01 = 'Y' THEN cl2.UDF01 ELSE 'N' END
            , FCP    = CASE WHEN cl2.UDF04 = 'Y' THEN cl2.UDF04 ELSE 'N' END
            , RPF    = CASE WHEN cl2.UDF05 = 'Y' THEN cl2.UDF05 ELSE 'N' END
            , PRGRP  = ISNULL(cl2.Code,'')                                          --v2.1            
      FROM WAVE w (NOLOCK) 
      JOIN WAVEDETAIL wd (NOLOCK) ON wd.Wavekey  = w.Wavekey
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = wd.OrderKey
      LEFT OUTER JOIN LOADPLANDETAIL lpd (NOLOCK) ON lpd.Orderkey = o.Orderkey
      LEFT OUTER JOIN MBOLDETAIL md (NOLOCK) ON md.Orderkey = o.Orderkey
      LEFT OUTER JOIN MBOL       m  (NOLOCK) ON m.MbolKey = md.MbolKey
      LEFT OUTER JOIN @TMP_FCP_CL cl ON cl.ListName = 'JCBCOMPML' 
                                    AND cl.Storerkey= o.StorerKey
                                    AND cl.Long = o.C_Company
                                    AND o.C_Company <> '' AND o.C_Company IS NOT NULL
      LEFT OUTER JOIN LOC l (NOLOCK) ON  l.loc = cl.Short
                                     AND l.Facility = o.Facility
                                     AND cl.Short <> '' AND cl.Short IS NOT NULL
                                     AND l.LocationFlag <> 'INACTIVE'                                      
      OUTER APPLY (SELECT TOP 1 WITH TIES                                           --v2.1
                     cl.Code, cl.Short, cl.UDF01, cl.UDF04, cl.UDF05
                   FROM @TMP_FCP_CL cl   
                   WHERE cl.ListName = 'JCBORDPR' 
                   AND cl.Storerkey= o.StorerKey
                   AND cl.Code2 = o.[Type]
                   AND cl.UDF02 IN ('', o.[Priority])
                   AND cl.UDF03 IN ('', o.[OrderGroup]) 
                   GROUP BY cl.Code, cl.Short, cl.UDF01, cl.UDF02, cl.UDF03, cl.UDF04, cl.UDF05
                   ORDER BY DENSE_RANK() OVER (PARTITION BY o.Orderkey                            
                                               ORDER BY o.Orderkey
                                              ,CASE WHEN cl.UDF02 = o.[Priority]   THEN 1
                                                    WHEN cl.UDF03 = o.[OrderGroup] THEN 2 
                                                    ELSE 3 END)
                  ) cl2  
      OUTER APPLY (SELECT od1.Orderkey                                              --2025-09-04
                        , [Status] = CASE WHEN SUM(od1.QtyAllocated + od1.QtyPicked) = 0
                                          THEN '0'
                                          WHEN SUM(od1.OpenQty) = SUM(od1.QtyAllocated + od1.QtyPicked) 
                                          THEN '2'
                                          ELSE '1'
                                          END
                   FROM ORDERDETAIL od1 (NOLOCK)  
                   WHERE od1.Orderkey = o.Orderkey
                   GROUP BY od1.Orderkey
                  ) od  
      WHERE w.WaveKey = @c_Wavekey
      GROUP BY o.Orderkey
            ,  o.Facility
            ,  o.StorerKey
            ,  ISNULL(lpd.LoadKey,'')
            ,  ISNULL(md.MbolKey,'')
            ,  ISNULL(m.OtherReference, '')
            ,  o.[Type]
            ,  ISNULL(cl2.Short, '')
            ,  ISNULL(od.[Status],'0')                                              --2025-09-04
            ,  ISNULL(o.C_Company,'')
            ,  CASE WHEN cl2.UDF01 = 'Y' THEN cl2.UDF01 ELSE 'N' END
            ,  CASE WHEN cl2.UDF04 = 'Y' THEN cl2.UDF04 ELSE 'N' END
            ,  CASE WHEN cl2.UDF05 = 'Y' THEN cl2.UDF05 ELSE 'N' END
            ,  ISNULL(cl2.Code,'')                                                  --v2.1    

      SET @c_InValid = ''
      SELECT @c_InValid = CASE WHEN SUM(CASE WHEN o.Loadkey = '' THEN 1 ELSE 0 END) > 0 
                               THEN 'BLP' 
                               WHEN SUM(CASE WHEN o.MBOLKey = '' THEN 1 ELSE 0 END) > 0 
                               THEN 'BMB'
                               WHEN COUNT(DISTINCT o.[Type]) > 1    
                               THEN 'MT'
                               WHEN COUNT(DISTINCT o.PRGrp) > 1                     --v2.1 
                               THEN 'MPG'                               
                               WHEN COUNT(DISTINCT o.C_Company) > 1 
                               THEN 'MC'
                               END
            ,@c_FCP = MAX(CASE WHEN @c_TMReleaseFlag = 'A' AND o.AutoRL = 'Y' THEN 'Y'
                               WHEN @c_TMReleaseFlag <>'A' THEN o.FCP
                               ELSE 'N'
                               END)   
            ,@c_RPF = MAX(o.RPF)                     
      FROM #TMP_ORD o 

      IF @c_FCP = 'N' 
      BEGIN
         SET @n_Continue = 4
         GOTO QUIT_SP 
      END

      IF @c_InValid = 'BLP'
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 83010
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Empty Loadplan Found'
                       + '. (mspRLWAV02)'
         SET @c_ShortErrMsg = 'Bad Loadplan'
      END
      ELSE IF @c_InValid = 'BMB'
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 83020
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Empty Ship Reference Found'
                       + '. (mspRLWAV02)'
         SET @c_ShortErrMsg = 'Bad Ship Ref.'
      END
      ELSE IF @c_InValid = 'MT'
      BEGIN
         SET @c_errmsg = ''
         ;WITH OT AS
         (
         SELECT TOP 2 WITH TIES o.[Type], Orderkey = MIN(o.Orderkey) 
         FROM #TMP_ORD o 
         GROUP BY o.[Type]
         ORDER BY ROW_NUMBER() OVER (PARTITION BY o.[Type] ORDER BY o.[Type])
         )
         SELECT @c_ErrMsg = String_Agg( OT.[Type] + ' - ' + OT.Orderkey, ', ' )
                          WITHIN GROUP (ORDER BY OT.[Type]) 
         FROM OT 

         SET @n_Continue = 3
         SET @n_err = 83030
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': More than one order type in the wave:'
                       + @c_errmsg
                       + '. (mspRLWAV02)'
         SET @c_ShortErrMsg = 'Bad Order Type'
      END
      ELSE IF @c_InValid = 'MPG'                                                    --v2.1
      BEGIN
         SET @c_errmsg = ''
         ;WITH PG AS
         (
         SELECT TOP 2 WITH TIES o.PRGrp, Orderkey = MIN(o.Orderkey) 
         FROM #TMP_ORD o 
         GROUP BY o.PRGrp
         ORDER BY ROW_NUMBER() OVER (PARTITION BY o.PRGrp ORDER BY o.PRGrp)
         )
         SELECT @c_ErrMsg = String_Agg( PG.PRGrp + ' - ' + PG.Orderkey, ', ' )
                          WITHIN GROUP (ORDER BY PG.PRGrp) 
         FROM PG 

         SET @n_Continue = 3
         SET @n_err = 83032
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': More than one JCBORDPR''s code in the wave:'
                       + @c_errmsg
                       + '. (mspRLWAV02)'
         SET @c_ShortErrMsg = 'Bad JCBORDPR Code'
      END
      ELSE IF @c_InValid = 'MC'
      BEGIN
         SET @c_errmsg = ''
         
         ;WITH OCC  AS
         (
         SELECT TOP 2 WITH TIES o.[C_Company], Orderkey = MIN(o.Orderkey) 
         FROM #TMP_ORD o 
         GROUP BY o.C_Company
         ORDER BY ROW_NUMBER() OVER (PARTITION BY o.C_Company ORDER BY o.C_Company)
         )
         SELECT @c_ErrMsg = String_Agg( OCC.[C_Company] + ' - ' + OCC.Orderkey, ', ' )
                          WITHIN GROUP (ORDER BY OCC.C_Company) 
         FROM OCC 

         SET @n_Continue = 3
         SET @n_err = 83040
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': More than one C_Company in the wave:'
                       + @c_errmsg
                       + '. (mspRLWAV02)'
         SET @c_ShortErrMsg = 'Bad Company'
      END

      IF @n_Continue = 1 
      BEGIN
         ;WITH ko  AS  
         (SELECT o.Orderkey 
                , KitOrder = 1
                , KitLoc   = ISNULL(STRING_AGG(l.Loc , ',')                      --2025-07-03   
                             WITHIN GROUP (ORDER BY l.Loc, cl.Long ASC),'')      --v1.91
                , ToLocCodes= ISNULL(STRING_AGG(cl.Long , ',')                   --v1.91
                              WITHIN GROUP (ORDER BY l.Loc, cl.Long ASC),'')     --2025-07-03
         FROM #TMP_ORD o
         JOIN @TMP_FCP_CL cl ON  cl.ListName = 'JCBKITORDT' 
                             AND cl.Storerkey= o.StorerKey
                             AND cl.Code = o.[Type] 
                             AND cl.Short = 'Y' 
         LEFT OUTER JOIN LOC l (NOLOCK) ON  l.LocationCategory = cl.Long
                                        AND l.Facility = o.Facility
                                        AND l.LocationFlag <> 'INACTIVE'                                           
         GROUP BY o.Orderkey
         )
         UPDATE o
            SET  KitOrder = ko.KitOrder
               , KitLoc   = ko.KitLoc
               , ToLocCodes = ko.ToLocCodes                                      --v1.91
         FROM #TMP_ORD o
         JOIN ko  ON  ko.Orderkey = o.Orderkey

         SET @c_InValid = ''
         SELECT TOP 1 WITH TIES                       
             @c_Orderkey= o.Orderkey
            ,@c_InValid = CASE WHEN o.[Status] <> '2'      
                               THEN 'PA'
                               WHEN o.CompML = ''          
                               THEN 'BC'
                               WHEN o.KitOrder = 1 AND k.KitLoc = ''                --2025-07-03     
                               THEN 'BKL'
                               WHEN o.KitOrder = 0 AND o.OtherReference > '' AND l.Loc IS NULL
                               THEN 'BMBL'
                               WHEN o.KitOrder = 0 AND o.OtherReference = '' AND m.MSLanes = ''                                         
                               THEN 'BML'
                               ELSE '' END
            ,@c_ToLocCodes = CASE WHEN o.KitOrder = 1   THEN tc.ToLocCodes     --v1.91
                                  WHEN o.KitOrder = 0 AND o.OtherReference = '' THEN tc.ToLocCodes --2025-07-02
                                  ELSE o.OtherReference END
         FROM #TMP_ORD o 
         LEFT OUTER JOIN LOC l (NOLOCK) ON  l.loc = o.OtherReference
                                        AND l.Facility = @c_Facility
                                        AND l.LocationFlag <> 'INACTIVE' 
         OUTER APPLY (SELECT TOP 1 [value] AS KitLoc                                
                      FROM string_split (o.KitLoc,',')
                      ORDER BY [value]) k  
         OUTER APPLY (SELECT TOP 1 [value] AS MSLanes
                      FROM string_split (o.MSLanes,',')
                      ORDER BY [value]) m  
         OUTER APPLY (SELECT TOP 1 [value] AS ToLocCodes                            --v1.91                             
                      FROM string_split (o.ToLocCodes,',')
                      ORDER BY [value]) tc                        
         ORDER BY CASE WHEN o.[Status] <> '2'      
                       THEN 1
                       WHEN o.CompML = ''          
                       THEN 2
                       WHEN o.KitOrder = 1 AND k.KitLoc = ''        
                       THEN 3
                       WHEN o.KitOrder = 0 AND o.OtherReference > '' AND l.Loc IS NULL             --2025-07-02
                       THEN 3
                       WHEN o.KitOrder = 0 AND o.OtherReference = '' AND m.MSLanes = ''            --2025-07-03                                         
                       THEN 3
                       ELSE 9 END

         IF @c_InValid = 'PA'
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 83050
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Orderkey ' + @c_Orderkey 
                         +' is not fully Allocated. (mspRLWAV02)'
            SET @c_ShortErrMsg = 'Not Fully Allocated'
         END
         ELSE IF @c_InValid = 'BC'
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 83060
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Orderkey ' + @c_Orderkey 
                         +' has bad C_Company. (mspRLWAV02)'
            SET @c_ShortErrMsg = 'Bad Company'
         END
         ELSE IF @c_InValid = 'BKL'
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 83070
            IF  @c_ToLocCodes = ''                                                  --2025-07-03
            BEGIN 
               SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err) 
                             + ': Invalid Location Category. (mspRLWAV02)'
            END
            ELSE
            BEGIN
               SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err) 
                             + ': No Location OR INACTIVE Location with Category: (' + @c_ToLocCodes  
                             + ') exists in ' + @c_Facility + ' facility'
                             + '. (mspRLWAV02)'
            END
            SET @c_ShortErrMsg = 'Bad Kit Loc'
         END
         ELSE IF @c_InValid IN ('BMBL','BML')
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 83080
            IF  @c_ToLocCodes = ''                                                  --2025-07-03
            BEGIN
               SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err) 
                  + ': Invalid JCBCOMPML''s Short. (mspRLWAV02)'
            END
            ELSE
            BEGIN 
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err) 
                            + CASE WHEN @c_InValid = 'BMBL' THEN ': Location ('
                                   ELSE ': Marshalling lane ('
                                   END
                            + @c_ToLocCodes 
                            +') does not exist OR INACTIVE in ' + @c_Facility 
                            + ' facility. (mspRLWAV02)'
            END
            SET @c_ShortErrMsg = 'Bad Marshall Lane'
         END
      END
   END                                                                                                                                                         
  
   -----Wave Validation
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN
      SET @n_Cnt = 0
      IF @c_RPF = 'Y'                                                                
      BEGIN
         SELECT @n_Cnt = 1
         FROM WAVEDETAIL wd (NOLOCK)
         JOIN PICKDETAIL pd (NOLOCK) ON wd.Orderkey= pd.Orderkey
         JOIN LOTxLOCxID lli (NOLOCK) ON  lli.lot = pd.Lot
                                      AND lli.Loc = pd.Toloc
                                      AND lli.ID  = pd.CaseID
         WHERE wd.Wavekey    = @c_Wavekey
         AND   pd.UOM        = '7'
         AND   pd.ToLoc      > '' 
         AND   pd.CaseID     > ''
         AND   pd.[Status]   = '0'
         AND   lli.Qty       > 0             
         AND   lli.QtyReplen = 0
      END

      IF @c_FCP = 'Y'
      BEGIN
         IF @n_Cnt = 0 AND
            NOT EXISTS (SELECT 1                                                   --2025-07-01
                        FROM WAVEDETAIL wd (NOLOCK)
                        JOIN PICKDETail pd (NOLOCK) ON wd.Orderkey= pd.Orderkey
                        LEFT OUTER JOIN Taskdetail td (NOLOCK) 
                                                    ON td.TaskDetailKey= pd.TaskDetailKey
                                                    AND TD.Sourcetype = @c_SourceType
                                                    AND TD.Tasktype   = 'FCP'
                        WHERE wd.Wavekey    = @c_Wavekey
                        AND   pd.[Status]   = '0'
                        GROUP BY pd.pickdetailkey
                        HAVING COUNT(1) = SUM(CASE WHEN ISNULL(td.[Status],'X') = 'X' 
                                                   THEN 1 ELSE 0 END)
                  )
         BEGIN
            SET @n_Continue = 3 
            SET @n_err = 83090
            SET @c_errmsg = 'NSQL' +CONVERT(NVARCHAR(5),@n_err)+ ': Nothing to release'
                          + '. (mspRLWAV02)'
            SET @c_ShortErrMsg = 'Nothing To Release'
         END
      END
   END

   --Create pickdetail Work in progress temporary table
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
      BEGIN
         DROP TABLE #PICKDETAIL_WIP
      END

      CREATE TABLE #PickDetail_WIP(
         [PickDetailKey]   [nvarchar](18) NOT NULL PRIMARY KEY
      ,  [CaseID]          [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [PickHeaderKey]   [nvarchar](18) NOT NULL
      ,  [OrderKey]        [nvarchar](10) NOT NULL
      ,  [OrderLineNumber] [nvarchar](5)  NOT NULL
      ,  [Lot]             [nvarchar](10) NOT NULL
      ,  [Storerkey]       [nvarchar](15) NOT NULL
      ,  [Sku]             [nvarchar](20) NOT NULL
      ,  [AltSku]          [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [UOM]             [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [UOMQty]          [int]          NOT NULL DEFAULT ((0))
      ,  [Qty]             [int]          NOT NULL DEFAULT ((0))
      ,  [QtyMoved]        [int]          NOT NULL DEFAULT ((0))
      ,  [Status]          [nvarchar](10) NOT NULL DEFAULT ('0')
      ,  [DropID]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [Loc]             [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN')
      ,  [ID]              [nvarchar](18) NOT NULL DEFAULT (' ')
      ,  [PackKey]         [nvarchar](10) NULL     DEFAULT (' ')
      ,  [UpdateSource]    [nvarchar](10) NULL     DEFAULT ('0')
      ,  [CartonGroup]     [nvarchar](10) NULL
      ,  [CartonType]      [nvarchar](10) NULL
      ,  [ToLoc]           [nvarchar](10) NULL     DEFAULT (' ')
      ,  [DoReplenish]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [ReplenishZone]   [nvarchar](10) NULL     DEFAULT (' ')
      ,  [DoCartonize]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [PickMethod]      [nvarchar](1)  NOT NULL DEFAULT (' ')
      ,  [WaveKey]         [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [EffectiveDate]   [datetime]     NOT NULL DEFAULT (getdate())
      ,  [AddDate]         [datetime]     NOT NULL DEFAULT (getdate())               --(SSA08)
      ,  [AddWho]          [nvarchar](128)NOT NULL DEFAULT (suser_sname())           --(SSA08)
      ,  [EditDate]        [datetime]     NOT NULL DEFAULT (getdate())               --(SSA08)
      ,  [EditWho]         [nvarchar](128)NOT NULL DEFAULT (suser_sname())           --(SSA08)
      ,  [TrafficCop]      [nvarchar](1)  NULL
      ,  [ArchiveCop]      [nvarchar](1)  NULL
      ,  [OptimizeCop]     [nvarchar](1)  NULL
      ,  [ShipFlag]        [nvarchar](1)  NULL     DEFAULT ('0')
      ,  [PickSlipNo]      [nvarchar](10) NULL
      ,  [TaskDetailKey]   [nvarchar](10) NULL
      ,  [TaskManagerReasonKey] [nvarchar](10) NULL
      ,  [Notes]           [nvarchar](4000)NULL
      ,  [MoveRefKey]      [nvarchar](10) NULL DEFAULT ('')
      ,  [WIP_Refno]       [nvarchar](30) NULL DEFAULT ('')
      ,  [Channel_ID]      [bigint]       NULL DEFAULT ((0)))
   END

   IF @n_Continue = 1 AND @@TRANCOUNT = 0 
   BEGIN
      BEGIN TRAN
   END

   --Initialize Pickdetail work in progress staging table
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      EXEC isp_CreatePickdetail_WIP
          @c_Loadkey               = ''
         ,@c_Wavekey               = @c_Wavekey
         ,@c_WIP_RefNo             = @c_SourceType
         ,@c_PickCondition_SQL     = ''
         ,@c_Action                = 'I'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
         ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
         ,@b_Success               = @b_Success OUTPUT
         ,@n_Err                   = @n_Err     OUTPUT
         ,@c_ErrMsg                = @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
 
      IF @n_Continue = 1
      BEGIN
         UPDATE p                                                                   
         SET p.Taskdetailkey = ''
         FROM #PICKDETAIL_WIP p
         LEFT JOIN TASKDETAIL TD (NOLOCK) ON  TD.Taskdetailkey = p.Taskdetailkey
                                          AND TD.[Status] NOT IN ('X','9')
                                          AND TD.Sourcetype = @c_SourceType
                                          AND TD.Tasktype   = 'FCP'                 --2025-07-01
         WHERE TD.Taskdetailkey IS NULL
      END
   END

   IF @n_Continue IN (1,2) AND @c_RPF = 'Y'
   BEGIN
      SET @cur_RPF = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT Orderkey = CASE WHEN COUNT(DISTINCT pd.Orderkey) > 1 THEN '' 
                             ELSE MIN(pd.Orderkey) END
            ,pd.Storerkey
            ,Sku = CASE WHEN COUNT(DISTINCT pd.Sku) > 1 THEN '' ELSE MIN(pd.SKU) END
            ,lot = CASE WHEN COUNT(DISTINCT pd.Lot) > 1 THEN '' ELSE MIN(pd.Lot) END
            ,pd.ToLoc
            ,pd.CaseID
            ,pd.Loc
            ,pd.ID
            --,KitLoc = CASE WHEN o.OtherReference > '' THEN o.OtherReference       --2025-08-25
            --               WHEN o.KitOrder = 1 THEN o.KitLoc
            --               ELSE o.MSLanes
            --               END

            ,Qty    = SUM(pd.Qty)
            ,IDQty  = ISNULL(lpn.Qty,0)
            ,la.Lottable11
      FROM #TMP_ORD o 
      JOIN #PICKDETAIL_WIP pd ON pd.OrderKey = o.Orderkey
      JOIN LOTxLOCxID lli (NOLOCK) ON  lli.lot = pd.Lot
                                   AND lli.Loc = pd.Toloc
                                   AND lli.ID  = pd.CaseID
      JOIN LotAttribute la(NOLOCK) ON  la.lot  = lli.Lot
      JOIN Loc l (NOLOCK) ON pd.ToLoc = l.Loc                                       --v2.2
      OUTER APPLY ( SELECT Qty = SUM(lli1.Qty)
                    FROM LOTxLOCxID lli1 (NOLOCK) 
                    WHERE lli1.Storerkey = pd.Storerkey
                    AND lli1.Loc = pd.Toloc
                    AND lli1.ID  = pd.CaseID
                    GROUP BY  lli1.Storerkey
                           ,  lli1.Loc
                           ,  lli1.ID 
                  ) lpn
      WHERE pd.UOM        = '7'
      AND   pd.ToLoc      > ''
      AND   pd.CaseID     > ''
      AND   pd.[Status]   = '0'
      AND   lli.Qty       > 0
      AND   lli.QtyReplen = 0
      GROUP BY pd.Wavekey
            ,  pd.Storerkey
            ,  pd.toLoc
            ,  pd.CaseID
            ,  pd.Loc
            ,  pd.ID
            --,  CASE WHEN o.OtherReference > '' THEN o.OtherReference              --2025-08-25
            --        WHEN o.KitOrder = 1 THEN o.KitLoc
            --        ELSE o.MSLanes
            --        END
            ,  ISNULL(lpn.Qty,0)
            ,  la.Lottable11
            ,  l.LogicalLocation                                                    --v2.2
      ORDER BY l.LogicalLocation                                                    --v2.2
            ,  pd.ToLoc                                                             --v2.2
            ,  pd.CaseID                                                            --v2.2

      OPEN @cur_RPF

      FETCH NEXT FROM @cur_RPF INTO @c_Orderkey
                                 ,  @c_Storerkey
                                 ,  @c_Sku
                                 ,  @c_Lot
                                 ,  @c_FromLoc
                                 ,  @c_FromID
                                 ,  @c_ToLoc
                                 ,  @c_ToID
                                 --,  @c_Lanes                                      --2025-08-25
                                 ,  @n_Qty
                                 ,  @n_IDQty                                 
                                 ,  @c_CaseID    

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         SET @c_Taskdetailkey = ''
         SET @c_TaskType   = 'RPF'
         SET @c_PickMethod = CASE WHEN @c_CaseID > ''                            --2025-10-24 - PPA374
                                     THEN 'PP' 
                                     WHEN @c_FromID = ''
                                     THEN 'PP' 
                                     ELSE 'FP' END
         SET @c_UOM        = '1'
         SET @c_FinalLoc   = ''
         SET @c_Priority   = ''                                                     --(Wan01) FCR-3958 CR V2.3
         SET @c_TaskStatus = '0'                                                    --v2.2         
         
         
         SELECT TOP 1 @c_Priority = Priority                                        --(Wan01) FCR-3958 CR V2.3
         FROM #TMP_ORD  
         
         --SELECT TOP 1 @c_FinalLoc = l.Loc                                         --2025-08-25 - START
         --FROM string_split (@c_Lanes, ',') ss
         --JOIN LOC l (NOLOCK) ON l.Loc = ss.[value]
         --WHERE l.Facility = @c_Facility
         --ORDER BY CASE WHEN l.[Status] =  'OK' AND l.LocationFlag = 'NONE' THEN 1
         --              WHEN l.[Status] <> 'OK' THEN 2
         --              WHEN l.LocationFlag <> 'NONE' THEN 2
         --              ELSE 9
         --              END 
         --         ,l.LogicalLocation

         SET @c_FinalLoc = @c_ToLoc                                                  

         SET @c_LocAisle = ''
         SET @c_Floor    = ''
         SELECT @c_LocAisle = l.LocAisle
               ,@c_Floor    = l.[Floor]
         FROM Loc l (NOLOCK)
         WHERE l.Loc = @c_FromLoc

         SET @n_Cnt = 0                                                             --2025-09-01
         SELECT TOP 1 @c_ToLoc = l.Loc
               ,  @n_Cnt = 1                                                        --2025-09-01
         FROM LOC l (NOLOCK)
         WHERE l.Facility = @c_Facility
         AND   l.LocationCategory = 'PND_OUT'                                        
         AND   l.LocAisle = @c_LocAisle
         AND   l.[Floor]  = @c_Floor
         ORDER BY l.LogicalLocation                                                 --2025-08-25 - END

         IF @n_Cnt = 1                                                                 
         BEGIN
            SET @c_ToId = @c_FromID                                                 --2025-09-01 Fix for UWP-40397
         END
 
         IF @n_IDQty > @n_Qty AND @c_CaseID > ''                     --Lottable11
         BEGIN
            SELECT @n_Qty = SUM(lli.Qty)
            FROM LOTxLOCxID lli (NOLOCK) 
            JOIN LotAttribute la(NOLOCK) ON  la.lot  = lli.Lot 
            WHERE lli.Storerkey = @c_Storerkey
            AND   lli.Loc = @c_FromLoc
            AND   lli.ID  = @c_FromID 
            AND   la.Lottable11 = @c_CaseID
         END
         ELSE                                                                       --2025-07-04 - START
         BEGIN
            SET @n_Qty = @n_IDQty
         END                                                                        --2025-07-04 - END  

         EXEC isp_InsertTaskDetail
            @c_Taskdetailkey         = @c_Taskdetailkey OUTPUT
         ,  @c_TaskType              = @c_TaskType
         ,  @c_Storerkey             = @c_Storerkey
         ,  @c_Sku                   = @c_Sku
         ,  @c_Lot                   = @c_Lot
         ,  @c_UOM                   = @c_UOM
         ,  @n_UOMQty                = @n_Qty
         ,  @n_Qty                   = @n_Qty
         ,  @c_FromLoc               = @c_FromLoc
         ,  @c_LogicalFromLoc        = @c_FromLoc
         ,  @c_FromID                = @c_FromID                                    --Confirm refer to Inv's ID
         ,  @c_ToLoc                 = @c_ToLoc
         ,  @c_LogicalToLoc          = @c_ToLoc
         ,  @c_ToID                  = @c_ToID                                      --Confirm refer to Inv's ID
         ,  @c_CaseID                = @c_CaseID                                    --2025-06-17
         ,  @c_PickMethod            = @c_PickMethod
         ,  @c_Status                = @c_TaskStatus                                --v2.2         
         ,  @c_Priority              = @c_Priority
         ,  @c_SourcePriority        = '9'
         ,  @c_SourceType            = @c_SourceType
         ,  @c_SourceKey             = @c_Wavekey
         ,  @c_OrderKey              = @c_Orderkey
         ,  @c_Groupkey              = ''
         ,  @c_Wavekey               = @c_Wavekey
         ,  @c_FinalLoc              = @c_FinalLoc
         ,  @c_FinalID               = @c_ToID                                      --Confirm refer to Inv's ID            
         ,  @c_AreaKey               = '?F'  -- ?F=Get from location areakey
         ,  @c_Message03             = ''
         ,  @n_QtyReplen             = @n_Qty
         ,  @c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip
         ,  @c_LinkTaskToPick_SQL    = ''
         ,  @c_WIP_RefNo             = @c_SourceType
         ,  @b_Success               = @b_Success OUTPUT
         ,  @n_Err                   = @n_err OUTPUT
         ,  @c_ErrMsg                = @c_errmsg OUTPUT

         IF @b_Success <> 1
         BEGIN
            SET @n_Continue = 3
         END

         FETCH NEXT FROM @cur_RPF INTO @c_Orderkey
                                    ,  @c_Storerkey
                                    ,  @c_Sku
                                    ,  @c_Lot
                                    ,  @c_FromLoc
                                    ,  @c_FromID
                                    ,  @c_ToLoc
                                    ,  @c_ToID
                                    --,  @c_Lanes                                   --2025-08-25
                                    ,  @n_Qty
                                    ,  @n_IDQty  
                                    ,  @c_CaseID      
      END
      CLOSE @cur_RPF
      DEALLOCATE @cur_RPF
   END

   IF @n_Continue IN (1,2) AND @c_FCP = 'Y'                                          
   BEGIN
      SET @cur_FCP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT o.Orderkey
         ,   o.[Priority]
         ,   o.C_Company
         ,   Lanes = CASE  WHEN o.KitOrder = 1 THEN o.KitLoc                        --2025-07-03
                           WHEN o.KitOrder = 0 AND o.OtherReference > '' THEN o.OtherReference
                           ELSE o.MSLanes
                           END
         ,   pd.Storerkey
         ,   Sku = CASE WHEN COUNT(DISTINCT pd.Sku) > 1 THEN '' ELSE MIN(pd.SKU) END
         ,   UOM = MAX(pd.UOM)   --UOM='7' if Have RPF, Use for Reverse Logic
         ,   Lot = CASE WHEN COUNT(DISTINCT pd.Lot) > 1 THEN '' ELSE MIN(pd.Lot) END
         ,   pd.Loc
         ,   pd.ID
         ,   CaseID = la.Lottable11                                                 --2025-08-27
         ,   ReplFromLoc = ISNULL(pd.ToLoc,'')                                      --v1.90
         ,   ReplFromID  = pd.CaseID                                                --v1.90
         ,   Qty = SUM(pd.Qty)
         ,   l.LocAisle
         ,   l.[Floor]
         ,   l.Putawayzone  
         ,   l.LocationGroup 
         ,   l.LocationCategory 
      FROM #PickDetail_WIP pd
      JOIN #TMP_ORD o ON o.Orderkey  = pd.Orderkey
      JOIN LOTATTRIBUTE la (NOLOCK) ON la.lot = pd.lot
      JOIN LOC l (NOLOCK) ON l.loc = pd.Loc
      OUTER APPLY (   SELECT TOP 1                                                     --2025-12-05
                            RecCnt = CASE WHEN pd.ID > '' AND la.Lottable11  = ''      --(Wan01) FCR-3958 CR V2.3  
                                          THEN 1
                                          WHEN td.Lot = pd.Lot 
                                          THEN 1
                                          ELSE 0
                                          END
                      FROM dbo.Taskdetail td (NOLOCK)
                      WHERE td.CaseID = la.Lottable11
                      AND   td.TaskType IN ('FCP','FCP1')
                      AND   td.Status IN ('9','X')
                      AND   td.Storerkey = pd.Storerkey
                      AND   td.FromID    = pd.ID
                      ORDER BY 1 DESC                                                  --2025-12-05
                  ) tdr
      WHERE pd.TaskDetailKey = ''                                                   --2025-07-01  
      AND tdr.RecCnt IN (0,NULL)                                                    --(Wan01) FCR-3958 CR V2.3  
      AND pd.Status < '5'                                                           --(Wan01) FCR-3958 CR V2.3 
      GROUP BY o.Orderkey
            ,  o.[Priority]      
            ,  o.C_Company
            ,  CASE  WHEN o.KitOrder = 1 THEN o.KitLoc                              --2025-07-03
                     WHEN o.KitOrder = 0 AND o.OtherReference > '' THEN o.OtherReference
                     ELSE o.MSLanes
                     END
            ,  pd.Storerkey
            ,  pd.Loc
            ,  pd.ID
            ,  la.Lottable11                                                        --2025-08-27                                  
            ,  ISNULL(pd.ToLoc,'')                                                  --v1.90
            ,  pd.CaseID                                                            --v1.90
            ,  l.LocAisle
            ,  l.[Floor]
            ,  l.Putawayzone  
            ,  l.LocationGroup 
            ,  l.LocationCategory 
      ORDER BY MIN(pd.Pickdetailkey)

      OPEN @cur_FCP

      FETCH NEXT FROM @cur_FCP INTO @c_Orderkey, @c_Priority, @c_C_Company, @c_Lanes
                                  , @c_Storerkey, @c_Sku, @c_UOM
                                  , @c_Lot, @c_FromLoc, @c_FromID, @c_CaseID
                                  , @c_ReplFromLoc, @c_ReplFromID                   --v1.90
                                  , @n_Qty, @c_LocAisle, @c_Floor
                                  , @c_Putawayzone, @c_LocationGroup, @c_LocationCategory 

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         SET @c_Taskdetailkey = ''
         SET @c_TaskType      = 'FCP'
         SET @c_ToLoc         = ''
         SET @c_FinalLoc      = ''
         SET @c_ToID          = @c_FromID                                                
         SET @c_FinalID       = @c_ToID                                                
         SET @c_PickMethod    = CASE WHEN @c_CaseID > ''                            --2025-08-27
                                     THEN 'PP' 
                                     WHEN @c_FromID = ''
                                     THEN 'PP' 
                                     ELSE 'FP' END
         SET @c_TaskStatus    = '0'
         SET @c_RefTaskkey    = ''                                                  --v1.90
         SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.Orderkey= @c_Orderkey'
                                   +' AND PICKDETAIL.Loc = @c_FromLoc'
                                   +' AND PICKDETAIL.ID  = @c_FromID'
         SET @c_LocationGroup = ISNULL(@c_LocationGroup,'')                         --2025-09-25

         IF @c_UOM = '7'
         BEGIN
            IF EXISTS ( SELECT 1
                        FROM #PickDetail_WIP pd
                        JOIN LOTxLOCxID lli (NOLOCK) ON  lli.lot = pd.Lot
                                                     AND lli.Loc = pd.ToLoc
                                                     AND lli.ID  = pd.CaseID
                        WHERE pd.Orderkey = @c_Orderkey
                        AND   pd.UOM = @c_UOM
                        AND   pd.Loc = @c_FromLoc
                        AND   pd.ID  = @c_FromID
                        AND   lli.QtyReplen > 0
                      )
            BEGIN
               SET @c_TaskStatus = 'S'

               SELECT @c_RefTaskKey =  td.TaskDetailKey 
               FROM TASKDETAIL td (NOLOCK)
               WHERE td.TaskType   = 'RPF'
               --AND   td.Caseid     = ''                                           --(Wan01) FCR-3958 CR V2.3                                
               AND   td.Storerkey  = @c_Storerkey
               AND   td.UOM        = '1'
               AND   td.FromLoc    = @c_ReplFromLoc 
               AND   td.FromID     = @c_ReplFromID
               AND   td.SourceType = @c_SourceType

               SET @c_Putawayzone      = ''                                         --2025-08-27
               SET @c_LocationGroup    = ''                                         --2025-08-27
               SET @c_LocationCategory = ''                                         --2025-08-27
            END
         END
      
         SELECT TOP 1 @c_FinalLoc = l.Loc
         FROM string_split (@c_Lanes, ',') ss
         JOIN LOC l (NOLOCK) ON l.Loc = ss.[value]
         WHERE l.Facility = @c_Facility
         ORDER BY CASE WHEN l.[Status] =  'OK' AND l.LocationFlag = 'NONE' THEN 1
                       WHEN l.[Status] <> 'OK' THEN 2
                       WHEN l.LocationFlag <> 'NONE' THEN 2
                       ELSE 9
                       END 
                  ,l.LogicalLocation
 
         SET @c_ToLoc = @c_FinalLoc

         SELECT TOP 1 @c_ToLoc = l.Loc
         FROM LOC l (NOLOCK)
         WHERE l.Facility = @c_Facility
         AND   l.LocationCategory = 'PND_OUT'                                       --v2.0
         AND   l.LocAisle = @c_LocAisle
         AND   l.[Floor]  = @c_Floor
         ORDER BY l.LogicalLocation
                
         SET @b_Success = 1
         SET @n_Err = 0
         SET @c_errmsg = ''

         EXEC isp_InsertTaskDetail
            @c_Taskdetailkey         = @c_Taskdetailkey OUTPUT
         ,  @c_TaskType              = @c_TaskType
         ,  @c_Storerkey             = @c_Storerkey
         ,  @c_Sku                   = @c_Sku
         ,  @c_Lot                   = @c_Lot
         ,  @c_UOM                   = @c_UOM
         ,  @n_UOMQty                = @n_Qty
         ,  @n_Qty                   = @n_Qty
         ,  @c_FromLoc               = @c_FromLoc
         ,  @c_LogicalFromLoc        = @c_FromLoc
         ,  @c_FromID                = @c_FromID                                    --Confirm refer to Inv's ID
         ,  @c_ToLoc                 = @c_ToLoc
         ,  @c_LogicalToLoc          = @c_ToLoc
         ,  @c_ToID                  = @c_ToID                                      --Confirm refer to Inv's ID
         ,  @c_CaseID                = @c_CaseID
         ,  @c_PickMethod            = @c_PickMethod
         ,  @c_Status                = @c_TaskStatus
         ,  @c_Priority              = @c_Priority
         ,  @c_SourcePriority        = '9'
         ,  @c_SourceType            = @c_SourceType
         ,  @c_SourceKey             = @c_Wavekey
         ,  @c_OrderKey              = @c_Orderkey
         ,  @c_Groupkey              = ''
         ,  @c_RefTaskkey            = @c_RefTaskkey                                --v1.90
         ,  @c_Wavekey               = @c_Wavekey
         ,  @c_FinalLoc              = @c_FinalLoc
         ,  @c_FinalID               = @c_FinalID                                    --Confirm refer to Inv's ID    
         ,  @c_AreaKey               = '?F'  -- ?F=Get from location areakey
         ,  @c_Message01             = @c_Putawayzone
         ,  @c_Message02             = @c_LocationGroup
         ,  @c_Message03             = @c_LocationCategory
         ,  @c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip
         ,  @c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL
         ,  @c_WIP_RefNo             = @c_SourceType
         ,  @b_Success               = @b_Success OUTPUT
         ,  @n_Err                   = @n_err OUTPUT
         ,  @c_ErrMsg                = @c_errmsg OUTPUT

         IF @b_Success <> 1
         BEGIN
            SET @n_Continue = 3
         END         

         FETCH NEXT FROM @cur_FCP INTO @c_Orderkey, @c_Priority, @c_C_Company, @c_Lanes 
                                    ,  @c_Storerkey, @c_Sku, @c_UOM
                                    ,  @c_Lot, @c_FromLoc, @c_FromID, @c_CaseID 
                                    ,  @c_ReplFromLoc, @c_ReplFromID                --v1.90
                                    ,  @n_Qty, @c_LocAisle, @c_Floor
                                    ,  @c_Putawayzone, @c_LocationGroup, @c_LocationCategory 
      END
      CLOSE @cur_FCP
      DEALLOCATE @cur_FCP                                                           
   END       
      
   IF @n_Continue IN (1,2) AND @c_FCP = 'Y'   
   BEGIN
      SET @n_Cnt = 0                                                                --2025-07-02 - START
      SELECT @n_Cnt = CASE WHEN w.[Status] = '99'   THEN 1
                           WHEN w.UserDefine04 > '' THEN 1
                           ELSE 0
                           END
      FROM WAVE w (NOLOCK) 
      WHERE w.Wavekey = @c_Wavekey
      
      IF @n_Cnt > 0                                                                 --2025-07-02 - END
      BEGIN 
         UPDATE Wave WITH (ROWLOCK)
            SET UserDefine04 = ''
               ,[Status]   = '2'                                                    --v1.91
               ,TrafficCop = NULL 
         WHERE Wavekey = @c_Wavekey
            
         SET @n_err =  @@ERROR
         IF  @n_err <> 0
         BEGIN
            SET @c_errmsg = ERROR_MESSAGE()
         END
      END
   END

   -----Update pickdetail_WIP work in progress staging table back to pickdetail
   IF @n_Continue IN (1,2)
   BEGIN
      EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
         ,  @c_Wavekey               = @c_Wavekey
         ,  @c_WIP_RefNo             = @c_SourceType
         ,  @c_PickCondition_SQL     = ''
         ,  @c_Action                = 'U'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
         ,  @c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
         ,  @b_Success               = @b_Success OUTPUT
         ,  @n_Err                   = @n_Err     OUTPUT
         ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   -----Delete pickdetail_WIP work in progress staging table
   IF @n_Continue IN (1,2)
   BEGIN
      EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
         ,  @c_Wavekey               = @c_Wavekey
         ,  @c_WIP_RefNo             = @c_SourceType
         ,  @c_PickCondition_SQL     = ''
         ,  @c_Action                = 'D'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
         ,  @c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
         ,  @b_Success               = @b_Success OUTPUT
         ,  @n_Err                   = @n_Err     OUTPUT
         ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

QUIT_SP:
   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
   BEGIN
      DROP TABLE #PICKDETAIL_WIP
   END

   IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL                                      
   BEGIN
      DROP TABLE #TMP_ORD
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      
      IF @c_FCP = 'Y'                                                               
      BEGIN
         WHILE @@TRANCOUNT > 0                                 
         BEGIN
            COMMIT TRAN
         END  
            
         UPDATE Wave WITH (ROWLOCK)
            SET UserDefine04 = @c_ShortErrMsg 
               ,Status = '99'
               ,TrafficCop = NULL 
         WHERE Wavekey = @c_Wavekey
         
         SET @n_err =  @@ERROR
         IF  @n_err <> 0
         BEGIN
            SET @c_errmsg = ERROR_MESSAGE()
         END
         
         WHILE @@TRANCOUNT < @n_starttcnt
         BEGIN
            BEGIN TRAN
         END 
      END                                                                            
      
      execute nsp_logerror @n_err, @c_errmsg, "mspRLWAV02"
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
   END
END
GO
GRANT EXECUTE ON [dbo].[mspRLWAV02] TO [NSQL]
GO
