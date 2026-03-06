SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/    
/* Stored Procedure: mspRLWAV10_CPK                                      */    
/* Creation Date: 2026-01-22                                             */    
/* Copyright: Maersk Logistics                                           */    
/* Written by: Wan                                                       */    
/*                                                                       */    
/* Purpose: FCR-10124 - UK Columbia SportWear Release Wave               */   
/*                                                                       */    
/* Called By: Wave                                                       */    
/*                                                                       */    
/* Version: 1.5                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 10-Feb-2026 WLChooi  1.0   Initial Version                            */
/* 25-Feb-2026 WLChooi  1.1   FCR-11138 Add ASTCPK TaskType (WL01)       */
/* 23-Feb-2026 WLChooi  1.2   FCR-11090 Fix CPK Task Status (WL02)       */
/* 05-Mar-2026 WLChooi  1.3   FCR-11338 Hold the task if the same caseID */
/*                            has been put on hold (WL03)                */
/* 05-Mar-2026 WLChooi  1.4   FCR-10124 Modify B2C Groupkey & Pickmethod */
/*                            mapping (WL04)                             */
/* 06-Mar-2026 WLChooi  1.5   FCR-10124 Fix missing Taskdetailkey in     */
/*                            Pickdetail for ASTCPK (WL05)               */
/*************************************************************************/  
CREATE OR ALTER PROC [dbo].[mspRLWAV10_CPK]  
   @c_Wavekey            NVARCHAR(10)   
,  @b_Success            INT            = 1  OUTPUT  
,  @n_Err                INT            = 0  OUTPUT  
,  @c_ErrMsg             NVARCHAR(255)  = '' OUTPUT  
,  @n_debug              INT            = 0   
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE    
         @n_StartTCnt            INT = @@TRANCOUNT  
      ,  @n_Continue             INT = 1 
      ,  @n_CasesPerCart         INT = 4

      ,  @c_TaskDetailKey        NVARCHAR(10)   = ''         
      ,  @c_TaskType             NVARCHAR(10)   = ''        
      ,  @c_Storerkey            NVARCHAR(15)   = ''        
      ,  @c_Sku                  NVARCHAR(20)   = ''        
      ,  @c_Lot                  NVARCHAR(10)   = ''        
      ,  @c_UOM                  NVARCHAR(5)    = ''    
      ,  @n_UOMQty               INT            = 0        
      ,  @n_Qty                  INT            = 0        
      ,  @c_FromLoc              NVARCHAR(10)   = ''        
      ,  @c_LogicalFromLoc       NVARCHAR(10)   = '?'    
      ,  @c_FromID               NVARCHAR(18)   = ''       
      ,  @c_ToLoc                NVARCHAR(10)   = ''         
      ,  @c_LogicalToLoc         NVARCHAR(10)   = '?'    
      ,  @c_ToID                 NVARCHAR(18)   = ''         
      ,  @c_Caseid               NVARCHAR(20)   = ''         
      ,  @c_PickMethod           NVARCHAR(10)   = ''     
      ,  @c_Status               NVARCHAR(10)   = '0'        
      ,  @c_StatusMsg            NVARCHAR(255)  = ''        
      ,  @c_Priority             NVARCHAR(10)   = ''        
      ,  @c_SourcePriority       NVARCHAR(10)   = ''        
      ,  @c_Holdkey              NVARCHAR(10)   = ''        
      ,  @c_UserKey              NVARCHAR(18)   = ''        
      ,  @c_UserPosition         NVARCHAR(10)   = '1'        
      ,  @c_UserKeyOverRide      NVARCHAR(18)   = ''        
      ,  @d_StartTime            DATETIME       = NULL        
      ,  @d_EndTime              DATETIME       = NULL  
      ,  @c_SourceType           NVARCHAR(30)   = 'mspRLWAV10'         
      ,  @c_SourceKey            NVARCHAR(30)   = ''        
      ,  @c_PickDetailKey        NVARCHAR(10)   = ''        
      ,  @c_OrderKey             NVARCHAR(10)   = ''        
      ,  @c_OrderLineNumber      NVARCHAR(5)    = ''        
      ,  @c_ListKey              NVARCHAR(10)   = ''        
      ,  @c_ReasonKey            NVARCHAR(10)   = ''         
      ,  @c_Message01            NVARCHAR(20)   = ''         
      ,  @c_Message02            NVARCHAR(20)   = ''         
      ,  @c_Message03            NVARCHAR(20)   = ''         
      ,  @n_SystemQty            INT            = 0      
      ,  @c_RefTaskKey           NVARCHAR(10)   = ''         
      ,  @c_LoadKey              NVARCHAR(10)   = ''         
      ,  @c_AreaKey              NVARCHAR(10)   = ''     
      ,  @c_DropID               NVARCHAR(20)   = ''         
      ,  @n_TransitCount         INT            = 0         
      ,  @c_TransitLOC           NVARCHAR(10)   = ''         
      ,  @c_FinalLOC             NVARCHAR(10)   = ''         
      ,  @c_FinalID              NVARCHAR(10)   = ''         
      ,  @c_Groupkey             NVARCHAR(10)   = ''    
      ,  @n_PendingMoveIn        INT            = 0      
      ,  @n_QtyReplen            INT            = 0      
      ,  @c_CallSource           NVARCHAR(20)   = 'WAVE' 
      ,  @c_LinkTaskToPick       NVARCHAR(5)    = ''    
      ,  @c_LinkTaskToPick_SQL   NVARCHAR(MAX)  = ''  
      ,  @c_RoundUpQty           NVARCHAR(5)    = ''     
      ,  @c_ReserveQtyReplen     NVARCHAR(10)   = 'N'    
      ,  @c_LinkTaskToReplen     NVARCHAR(5)    = 'N'    
      ,  @c_ReservePendingMoveIn NVARCHAR(5)    = 'N'    
      ,  @c_CombineTasks         NVARCHAR(5)    = 'N'   
      ,  @c_CasecntbyLocUCC      NVARCHAR(5)    = 'N'    
      ,  @c_SplitTaskByCase      NVARCHAR(5)    = 'N'    
      ,  @c_ZeroSystemQty        NVARCHAR(5)    = 'N'    
      ,  @c_MergedTaskPriority   NVARCHAR(10)   = '2'
      ,  @c_Groupkey_P           NVARCHAR(10)   = ''       
      ,  @c_Groupkey_New         NVARCHAR(10)   = ''
      ,  @c_DocType              NVARCHAR(10)   = ''   --WL01
      ,  @c_Facility             NVARCHAR(5)    = ''
      ,  @c_Option5              NVARCHAR(MAX)  = ''
      ,  @n_BatchGrpKey          INT            = 0
      
      ,  @CUR_TW                 CURSOR
 
    DECLARE @TMP_CL              TABLE                                                                                
      ( [RowID]                  INT               IDENTITY(1,1) PRIMARY KEY                   
      , [LISTNAME]               [NVARCHAR](10)    NULL     
      , [Code]                   [NVARCHAR](30)    NULL  
      , [Description]            [NVARCHAR](250)   NULL  
      , [Short]                  [NVARCHAR](10)    NULL  
      , [Long]                   [NVARCHAR](250)   NULL  
      , [Notes]                  [NVARCHAR](4000)  NULL  
      , [Notes2]                 [NVARCHAR](4000)  NULL  
      , [Storerkey]              [NVARCHAR](50)    NOT NULL  
      , [UDF01]                  [NVARCHAR](60)    NOT NULL  
      , [UDF02]                  [NVARCHAR](60)    NOT NULL  
      , [UDF03]                  [NVARCHAR](60)    NOT NULL  
      , [UDF04]                  [NVARCHAR](60)    NOT NULL  
      , [UDF05]                  [NVARCHAR](60)    NOT NULL  
      , [code2]                  [NVARCHAR](30)    NOT NULL 
      )

      IF OBJECT_ID('tempdb..#TASKDETAIL_WIP','U') IS NOT NULL  
      BEGIN  
         DROP TABLE #TASKDETAIL_WIP 
      END

      CREATE TABLE #TASKDETAIL_WIP    
         (  RowID             INT            IDENTITY(1,1)     PRIMARY KEY  
         ,  TaskDetailKey     NVARCHAR(10)   NOT NULL DEFAULT('') 
         ,  TaskType          NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  Storerkey         NVARCHAR(15)   NOT NULL DEFAULT('')
         ,  Sku               NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  Lot               NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  UOM               NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  UOMQty            INT            NOT NULL DEFAULT(0)  
         ,  Qty               INT            NOT NULL DEFAULT(0)  
         ,  FromLoc           NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  LogicalFromLoc    NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  FromID            NVARCHAR(18)   NOT NULL DEFAULT('')
         ,  ToLoc             NVARCHAR(10)   NOT NULL DEFAULT('')   
         ,  LogicalToLoc      NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  ToID              NVARCHAR(18)   NOT NULL DEFAULT('')
         ,  CaseId            NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  PickMethod        NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  Status            NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  StatusMsg         NVARCHAR(255)  NOT NULL DEFAULT('')
         ,  Priority          NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  SourcePriority    NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  Holdkey           NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  UserKey           NVARCHAR(18)   NOT NULL DEFAULT('')
         ,  UserPosition      NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  UserKeyOverRide   NVARCHAR(18)   NOT NULL DEFAULT('')
         ,  StartTime         DATETIME       NOT NULL DEFAULT(GETDATE())
         ,  EndTime           DATETIME       NOT NULL DEFAULT(GETDATE())
         ,  SourceType        NVARCHAR(30)   NOT NULL DEFAULT('')
         ,  SourceKey         NVARCHAR(30)   NOT NULL DEFAULT('')
         ,  PickDetailKey     NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  OrderKey          NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  OrderLineNumber   NVARCHAR(5)    NOT NULL DEFAULT('')
         ,  ListKey           NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  WaveKey           NVARCHAR(10)   NOT NULL DEFAULT('')  
         ,  ReasonKey         NVARCHAR(10)   NOT NULL DEFAULT('')  
         ,  Message01         NVARCHAR(20)   NOT NULL DEFAULT('')  
         ,  Message02         NVARCHAR(20)   NOT NULL DEFAULT('')  
         ,  Message03         NVARCHAR(20)   NOT NULL DEFAULT('')  
         ,  SystemQty         INT            NOT NULL DEFAULT(0)  
         ,  RefTaskKey        NVARCHAR(10)   NOT NULL DEFAULT('')  
         ,  LoadKey           NVARCHAR(10)   NOT NULL DEFAULT('')  
         ,  AreaKey           NVARCHAR(10)   NOT NULL DEFAULT('')  
         ,  DropID            NVARCHAR(20)   NOT NULL DEFAULT('')  
         ,  TransitCount      INT            NOT NULL DEFAULT(0)     
         ,  TransitLOC        NVARCHAR(10)   NOT NULL DEFAULT('')  
         ,  FinalLOC          NVARCHAR(10)   NOT NULL DEFAULT('')  
         ,  FinalID           NVARCHAR(18)   NOT NULL DEFAULT('')  
         ,  Groupkey          NVARCHAR(10)   NOT NULL DEFAULT('')  
         ,  PendingMoveIn     INT            NOT NULL DEFAULT(0)  
         ,  QtyReplen         INT            NOT NULL DEFAULT(0)  
         ,  DeviceID          NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  PickLocLevel      INT            NOT NULL DEFAULT(0)     
         ,  CartonPerLoc      INT            NOT NULL DEFAULT(0)  
         ,  SkuPerCarton      INT            NOT NULL DEFAULT(0)  
         ,  CartonType        NVARCHAR(10)   NOT NULL DEFAULT('')   
         ,  CartonCube        FLOAT          NOT NULL DEFAULT(0.00) 
         ,  SortNo            INT            NOT NULL DEFAULT(0)
         ,  DocType           NVARCHAR(10)   NOT NULL DEFAULT('')   --WL01
         ) 

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NULL
   BEGIN
      CREATE TABLE #PickDetail_WIP
      (
         [PickDetailKey]   [NVARCHAR](18) NOT NULL PRIMARY KEY
      ,  [CaseID]          [NVARCHAR](20) NOT NULL DEFAULT (' ')
      ,  [PickHeaderKey]   [NVARCHAR](18) NOT NULL
      ,  [OrderKey]        [NVARCHAR](10) NOT NULL
      ,  [OrderLineNumber] [NVARCHAR](5)  NOT NULL
      ,  [Lot]             [NVARCHAR](10) NOT NULL
      ,  [Storerkey]       [NVARCHAR](15) NOT NULL
      ,  [Sku]             [NVARCHAR](20) NOT NULL
      ,  [AltSku]          [NVARCHAR](20) NOT NULL DEFAULT (' ')
      ,  [UOM]             [NVARCHAR](10) NOT NULL DEFAULT (' ')
      ,  [UOMQty]          [INT]          NOT NULL DEFAULT (0)
      ,  [Qty]             [INT]          NOT NULL DEFAULT (0)
      ,  [QtyMoved]        [INT]          NOT NULL DEFAULT (0)
      ,  [Status]          [NVARCHAR](10) NOT NULL DEFAULT ('0')
      ,  [DropID]          [NVARCHAR](20) NOT NULL DEFAULT ('')
      ,  [Loc]             [NVARCHAR](10) NOT NULL DEFAULT ('UNKNOWN')
      ,  [ID]              [NVARCHAR](18) NOT NULL DEFAULT (' ')
      ,  [PackKey]         [NVARCHAR](10) NULL     DEFAULT (' ')
      ,  [UpdateSource]    [NVARCHAR](10) NULL     DEFAULT ('0')
      ,  [CartonGroup]     [NVARCHAR](10) NULL
      ,  [CartonType]      [NVARCHAR](10) NULL
      ,  [ToLoc]           [NVARCHAR](10) NULL     DEFAULT (' ')
      ,  [DoReplenish]     [NVARCHAR](1)  NULL     DEFAULT ('N')
      ,  [ReplenishZone]   [NVARCHAR](10) NULL     DEFAULT (' ')
      ,  [DoCartonize]     [NVARCHAR](1)  NULL     DEFAULT ('N')
      ,  [PickMethod]      [NVARCHAR](1)  NOT NULL DEFAULT (' ')
      ,  [WaveKey]         [NVARCHAR](10) NOT NULL DEFAULT (' ')
      ,  [LoadKey]         [NVARCHAR](10) NOT NULL DEFAULT (' ')
      ,  [EffectiveDate]   [DATETIME]     NOT NULL DEFAULT (GETDATE())
      ,  [AddDate]         [DATETIME]     NOT NULL DEFAULT (GETDATE())
      ,  [AddWho]          [NVARCHAR](128)NOT NULL DEFAULT (SUSER_SNAME())
      ,  [EditDate]        [DATETIME]     NOT NULL DEFAULT (GETDATE())
      ,  [EditWho]         [nvarchar](128)NOT NULL DEFAULT (suser_sname())
      ,  [TrafficCop]      [nvarchar](1)  NULL
      ,  [ArchiveCop]      [nvarchar](1)  NULL
      ,  [OptimizeCop]     [nvarchar](1)  NULL
      ,  [ShipFlag]        [nvarchar](1)  NULL     DEFAULT ('0')
      ,  [PickSlipNo]      [nvarchar](10) NULL
      ,  [TaskDetailKey]   [nvarchar](10) NULL
      ,  [TaskManagerReasonKey] [nvarchar](10) NULL
      ,  [Notes]           [nvarchar](4000)NULL
      ,  [MoveRefKey]      [nvarchar](10) NULL     DEFAULT ('')
      ,  [WIP_Refno]       [nvarchar](30) NULL     DEFAULT ('')
      ,  [Channel_ID]      [bigint]       NULL     DEFAULT (0)
      )
      CREATE INDEX IDX_Case ON #PickDetail_WIP (Orderkey, CaseID, Lot, Loc, ID)

      EXEC [dbo].[mspRLWAV10_DATA]        
         @c_Wavekey  = @c_Wavekey 
      ,  @b_Success  = @b_Success   OUTPUT
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT 
      ,  @n_debug    = @n_debug  
   END

   IF @n_Continue = 1 
   BEGIN
      SELECT TOP 1 @c_Storerkey = pw.Storerkey
                 , @c_Facility = o.Facility
      FROM #PickDetail_WIP AS pw
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = pw.OrderKey

      -- Get optional configuration if available
      SELECT @c_Option5 = ISNULL(fgr.Option5,'')
      FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'ReleaseWave_SP') AS fgr

      IF ISNULL(@c_Option5, '') <> ''
      BEGIN
         SELECT @n_CasesPerCart = TRY_CAST(dbo.fnc_GetParamValueFromString('@n_CasesPerCart', @c_Option5, @n_CasesPerCart) AS INT)

         IF ISNULL(@n_CasesPerCart, 0) = 0
            SET @n_CasesPerCart = 4
      END

      INSERT INTO @TMP_CL (Listname, Code, Description, Short, Long                
                        ,  Notes, Notes2, Storerkey
                        ,  UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
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
      WHERE CODELKUP.Listname IN ('CSCUK01ZNE', 'CSCUK01OPY' ) 
      AND   CODELKUP.Storerkey = @c_Storerkey
      ORDER BY CODELKUP.Listname
           ,   CODELKUP.Code 

      --------------------------------------------------------------------  
      -- INSERT #TASKDETAIL_WIP 
      --------------------------------------------------------------------  
      INSERT INTO #TASKDETAIL_WIP
         (
            Wavekey             
         ,  Orderkey            
         ,  Storerkey           
         ,  Sku    
         ,  UOM               
         ,  Qty                
         ,  CaseID   
         ,  Lot
         ,  FromLoc
         ,  FromID
         ,  RefTaskKey
         ,  CartonPerLoc
         ,  SkuPerCarton
         ,  DocType   --WL01
         )
      SELECT 
            pw.Wavekey             
         ,  pw.Orderkey            
         ,  pw.Storerkey           
         ,  pw.Sku    
         ,  pw.UOM               
         ,  Qty = SUM(pw.Qty)                 
         ,  pw.CaseID   
         ,  pw.Lot             
         ,  FromLoc = pw.ToLoc                        --Picking Loc. Update at mspRLWAV10_Data                      
         ,  FromID  = CASE WHEN l.LoseId = '1' 
                           THEN ''
                           ELSE pw.ID
                           END
         ,  RefTaskKey = pw.UpdateSource              --Picking Loc. Update at mspRLWAV10_Data 
         ,  p1.CartonPerLoc
         ,  p2.SkuPerCarton
         ,  O.DocType   --WL01
      FROM #PICKDETAIL_WIP AS pw
      JOIN LOC l (NOLOCK) ON l.loc = pw.Toloc
      JOIN  (  SELECT pw1.ToLoc  
                     ,CartonPerLoc = COUNT(DISTINCT pw1.CaseID)  
               FROM #PICKDETAIL_WIP pw1
               GROUP BY pw1.ToLoc
            ) AS p1 ON p1.ToLoc = pw.ToLoc 
      JOIN  (  SELECT pw2.CaseID  
                  ,  SkuPerCarton = COUNT(DISTINCT pw2.Sku)  
               FROM #PICKDETAIL_WIP pw2
               GROUP BY pw2.CaseID
            ) AS p2 ON p2.CaseID = pw.CaseID
      JOIN ORDERS O (NOLOCK) ON O.Orderkey = pw.Orderkey   --WL01 
      WHERE pw.UOM >= '6'
      GROUP BY         
            pw.Wavekey             
         ,  pw.Orderkey            
         ,  pw.Storerkey           
         ,  pw.Sku    
         ,  pw.UOM               
         ,  pw.CaseID   
         ,  pw.Lot
         ,  pw.ID
         ,  pw.ToLoc
         ,  pw.UpdateSource 
         ,  l.LoseId         
         ,  p1.CartonPerLoc
         ,  p2.SkuPerCarton
         ,  O.DocType   --WL01

      --------------------------------------------------------------------  
      -- Update Task Priority Base on ORDERS.Priority 
      -------------------------------------------------------------------- 
      UPDATE tw 
         SET tw.Priority = ISNULL(cl.Short,'')
      FROM #TASKDETAIL_WIP AS tw 
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = tw.Orderkey
      LEFT OUTER JOIN @TMP_CL cl ON  cl.LISTNAME = 'CSCUK01OPY'  
                                 AND cl.Code = o.Priority
                                 AND cl.Storerkey = o.Storerkey

      --------------------------------------------------------------------  
      -- Update ToLoc Base on FromLoc Inform 
      --------------------------------------------------------------------  
      UPDATE tw 
         SET tw.LogicalFromLoc = l.LogicalLocation
            ,tw.PickLocLevel   = l.LocLevel
            ,tw.AreaKey        = ad.AreaKey
            ,tw.ToLoc          = ISNULL(CL.Short,'')
      FROM #TASKDETAIL_WIP AS tw
      JOIN LOC l (NOLOCK) ON l.loc = tw.FromLoc 
      JOIN AREADETAIL ad (NOLOCK) ON ad.PutawayZone = l.PickZone   
      JOIN @TMP_CL CL ON  CL.ListName = 'CSCUK01ZNE'  
                      AND CL.Code     = l.PickZone  
                      AND CL.Storerkey= tw.Storerkey  

      --------------------------------------------------------------------  
      -- Update CartonType and Cube
      -------------------------------------------------------------------- 
      UPDATE tw 
         SET tw.CartonType = PACK.CartonType
            ,tw.CartonCube = PACK.[Cube]
      FROM #TASKDETAIL_WIP AS tw
      CROSS APPLY (  SELECT TOP 1 pd.PickSlipNo  
                        ,   pd.LabelNo  
                        ,   pif.CartonType
                        ,   pif.[Cube]
                     FROM PACKDETAIL pd  (NOLOCK)
                     JOIN PACKINFO   pif (NOLOCK) ON  pif.PickSlipNo = pd.PickSlipNo 
                                                  AND pif.CartonNo = pd.CartonNo
                     WHERE pd.LabelNo = tw.CaseID
                     AND   pd.Sku     = tw.Sku
                  ) PACK  
      WHERE tw.CaseID > '' 
 
      --------------------------------------------------------------------  
      -- Update Sorting Sequence to Taskdetailkey
      -------------------------------------------------------------------- 

      UPDATE tw 
         SET tw.SortNo = s.SortNo
      FROM #TASKDETAIL_WIP AS tw
      CROSS APPLY ( SELECT tw1.RowID
                        ,  SortNo = ROW_NUMBER() OVER ( ORDER BY tw1.AreaKey
                                                               , tw1.PickLocLevel
                                                               , tw1.CartonPerLoc DESC  
                                                               , tw1.SkuPerCarton
                                                               , tw1.LogicalFromLoc
                                                      )
                     FROM #TASKDETAIL_WIP AS tw1 
                  ) s 
      WHERE s.RowID = tw.RowID

      --------------------------------------------------------------------  
      -- Gen Cart = Groupkey for Carton/Case
      -- NOC = NoOfCase
      --------------------------------------------------------------------     
      ;WITH NOC AS               
      (
          SELECT 
                tw.RowID  
              , rno = DENSE_RANK() OVER (ORDER BY tw.AreaKey, tw.PickLocLevel, tw.CaseID) 
          FROM #TASKDETAIL_WIP tw
          WHERE tw.DocType <> 'E'   --WL04
      )
      UPDATE tw
         SET GroupKey =  ((rno - 1) / @n_CasesPerCart) 
      FROM NOC
      JOIN #TASKDETAIL_WIP tw ON tw.RowID = NOC.RowID

      --------------------------------------------------------------------  
      -- Assign Actual Groupkey
      --------------------------------------------------------------------
      SET @n_BatchGrpKey = 0
      SELECT @n_BatchGrpKey = COUNT(DISTINCT GroupKey)
      FROM #TASKDETAIL_WIP tw

      IF @n_BatchGrpKey > 0
      BEGIN
         EXEC dbo.nspg_GetKey @KeyName = N'GroupKey' -- nvarchar(18)
                            , @fieldlength = 10 -- int
                            , @keystring = @c_GroupKey_New  OUTPUT -- nvarchar(25)
                            , @b_Success = @b_Success       OUTPUT -- int
                            , @n_err = @n_err               OUTPUT -- int
                            , @c_errmsg = @c_errmsg         OUTPUT -- nvarchar(250)
                            , @n_batch = @n_BatchGrpKey -- int

         IF @b_Success = 1 AND ISNULL(TRIM(@c_GroupKey_New), '') <> ''
         BEGIN
            UPDATE #TASKDETAIL_WIP
            SET Groupkey = RIGHT(REPLICATE('0', 10) + CAST(CAST(TRIM(@c_GroupKey_New) AS INT) + CAST(GroupKey AS INT) AS NVARCHAR(10)), 10)
            WHERE Groupkey > ''
         END
      END

      --------------------------------------------------------------------  
      -- Calculate Carton Position in the Cart By Small to Large Sequence  
      -- CSP: Case Position
      -------------------------------------------------------------------- 
     ;WITH CSP AS               
      (
          SELECT 
                tw.RowID  
              , PickMethod = DENSE_RANK() OVER (PARTITION BY tw.GroupKey
                                                ORDER BY tw.CartonCube
                                                      ,  tw.SkuPerCarton
                                                      ,  tw.CaseID
                                               ) 
          FROM #TASKDETAIL_WIP tw
          WHERE tw.DocType <> 'E'   --WL04
      )
      UPDATE tw
         SET PickMethod = CSP.PickMethod  
      FROM CSP
      JOIN #TASKDETAIL_WIP tw ON tw.RowID = CSP.RowID   

      UPDATE tw
      SET [Status] = IIF(RefTaskKey > '', 'H', '0')
      FROM #TASKDETAIL_WIP tw

      --WL02: If open RPF/ASTTPA task within Wavekey, set CPK to H
      --WL03: If one CaseID is on-hold, hold other tasks with same CaseID
      UPDATE tw
      SET [Status] = 'H'
      FROM #TASKDETAIL_WIP tw
      WHERE [Status] = '0'
      AND ( EXISTS ( SELECT 1
                     FROM TASKDETAIL TD (NOLOCK)
                     WHERE TD.Wavekey = @c_Wavekey
                     AND TD.TaskType IN ('RPF', 'ASTTPA')
                     AND TD.[Status] NOT IN ('X', '9')
                   )
            OR EXISTS ( SELECT 1
                        FROM #TASKDETAIL_WIP TD
                        WHERE TD.CaseID = tw.CaseID
                        AND TD.Storerkey = tw.Storerkey
                        AND TD.[Status] = 'H'
                      )
          )
   END

   IF @n_Continue = 1
   BEGIN
      SET @CUR_TW = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
      SELECT tw.Storerkey
            ,tw.Sku
            ,tw.Lot
            ,tw.FromLoc
            ,tw.LogicalFromLoc
            ,tw.FromID
            ,tw.ToLoc
            ,tw.LogicalToLoc
            ,tw.ToID
            ,tw.UOM
            ,tw.UOMQty
            ,tw.Qty
            ,tw.CaseID
            ,tw.Wavekey
            ,tw.Orderkey
            ,tw.Priority
            ,tw.PickMethod
            ,tw.RefTaskKey
            ,tw.AreaKey
            ,tw.GroupKey
            ,tw.Status
            ,tw.DocType   --WL01
      FROM #TASKDETAIL_WIP tw
      ORDER BY tw.SortNo
            ,  tw.GroupKey
            
      OPEN @CUR_TW  
  
      FETCH NEXT FROM @CUR_TW INTO  @c_Storerkey
                                 ,  @c_Sku
                                 ,  @c_Lot
                                 ,  @c_FromLoc
                                 ,  @c_LogicalFromLoc
                                 ,  @c_FromID
                                 ,  @c_ToLoc
                                 ,  @c_LogicalToLoc
                                 ,  @c_ToID
                                 ,  @c_UOM
                                 ,  @n_UOMQty
                                 ,  @n_Qty
                                 ,  @c_CaseID
                                 ,  @c_Wavekey
                                 ,  @c_Orderkey
                                 ,  @c_Priority
                                 ,  @c_PickMethod
                                 ,  @c_RefTaskKey
                                 ,  @c_AreaKey
                                 ,  @c_GroupKey
                                 ,  @c_Status
                                 ,  @c_DocType   --WL01

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN  
         SET @c_TaskType  = IIF(@c_DocType = 'E', 'ASTCPK', 'CPK')   --WL01
         SET @c_SourceKey = @c_Wavekey
         SET @c_LinkTaskToPick_SQL = ' AND PICKDETAIL.UOM = @c_UOM'
                                   + IIF(@c_TaskType = 'CPK', ' AND PICKDETAIL.CaseID = @c_CaseID', '')   --WL05

         --WL04
         IF ISNULL(@c_PickMethod, '') = ''
            SET @c_PickMethod = '?'

         --IF  @c_Groupkey_P <> @c_Groupkey
         --BEGIN
         --   SET @c_GroupKey_New = ''
         --   EXECUTE nspg_getkey    
         --           @KeyName   = 'GroupKey'    
         --         , @fieldlength = 10       
         --         , @KeyString   = @c_GroupKey_New    OUTPUT    
         --         , @b_success   = @b_success         OUTPUT    
         --         , @n_err       = @n_err             OUTPUT    
         --         , @c_errmsg    = @c_errmsg          OUTPUT  
         --          
         --   IF @b_success = 0   
         --   BEGIN    
         --      SET @n_Continue = 3  
         --   END    
         --END

         IF @n_Continue = 1
         BEGIN
            SET @c_Taskdetailkey = ''
            SET @c_LogicalToLoc  = '?'

            EXEC isp_InsertTaskDetail
               @c_TaskDetailKey       = @c_TaskDetailKey OUTPUT       
            ,  @c_TaskType            = @c_TaskType        
            ,  @c_Storerkey           = @c_Storerkey        
            ,  @c_Sku                 = @c_Sku              
            ,  @c_Lot                 = @c_Lot              
            ,  @c_UOM                 = @c_UOM           
            ,  @n_UOMQty              = @n_Qty        
            ,  @n_Qty                 = @n_Qty        
            ,  @c_FromLoc             = @c_FromLoc        
            ,  @c_LogicalFromLoc      = @c_LogicalFromLoc    
            ,  @c_FromID              = @c_FromID     
            ,  @c_ToLoc               = @c_ToLoc        
            ,  @c_LogicalToLoc        = @c_LogicalToLoc      
            ,  @c_ToID                = @c_ToID         
            ,  @c_Caseid              = @c_Caseid         
            ,  @c_PickMethod          = @c_PickMethod    
            ,  @c_Status              = @c_Status     
            ,  @c_StatusMsg           = ''        
            ,  @c_Priority            = @c_Priority   
            ,  @c_SourcePriority      = @c_SourcePriority     
            ,  @c_Holdkey             = ''        
            ,  @c_UserKey             = ''        
            ,  @c_UserPosition        = '1'        
            ,  @c_UserKeyOverRide     = ''        
            ,  @d_StartTime           = NULL        
            ,  @d_EndTime             = NULL  
            ,  @c_SourceType          = @c_SourceType      
            ,  @c_SourceKey           = @c_Wavekey      
            ,  @c_PickDetailKey       = ''      
            ,  @c_OrderKey            = @c_Orderkey     
            ,  @c_OrderLineNumber     = ''      
            ,  @c_ListKey             = ''        
            ,  @c_WaveKey             = @c_Wavekey        
            ,  @c_ReasonKey           = ''         
            ,  @c_Message01           = ''         
            ,  @c_Message02           = ''         
            ,  @c_Message03           = ''         
            ,  @n_SystemQty           = 0   
            ,  @c_RefTaskKey          = @c_RefTaskKey       
            ,  @c_LoadKey             = @c_Loadkey           
            ,  @c_AreaKey             = ''            
            ,  @c_DropID              = ''     
            ,  @n_TransitCount        = 0         
            ,  @c_TransitLOC          = ''         
            ,  @c_FinalLOC            = ''         
            ,  @c_FinalID             = ''         
            ,  @c_Groupkey            = @c_Groupkey
            ,  @n_PendingMoveIn       = 0        
            ,  @n_QtyReplen           = 0     
            ,  @c_CallSource          = 'WAVE' 
            ,  @c_LinkTaskToPick      = 'WIP'    
            ,  @c_LinkTaskToPick_SQL  = @c_LinkTaskToPick_SQL  
            ,  @c_WIP_RefNo           = @c_SourceType   
            ,  @c_RoundUpQty          = ''     
            ,  @c_ReserveQtyReplen    = 'N'    
            ,  @c_LinkTaskToReplen    = 'N'    
            ,  @c_ReservePendingMoveIn= 'N'    
            ,  @c_CombineTasks        = 'N'    
            ,  @c_CasecntbyLocUCC     = 'N'    
            ,  @c_SplitTaskByCase     = 'N'    
            ,  @c_ZeroSystemQty       = 'N'    
            ,  @c_MergedTaskPriority  = '2'    
            ,  @b_Success             = @b_Success OUTPUT  
            ,  @n_Err                 = @n_Err     OUTPUT   
            ,  @c_ErrMsg              = @c_ErrMsg  OUTPUT  

            IF @b_Success = 0 
            BEGIN
               SET @n_Continue = 3
            END 
         END

         SET @c_Groupkey_P = @c_Groupkey
         FETCH NEXT FROM @CUR_TW INTO  @c_Storerkey
                                    ,  @c_Sku
                                    ,  @c_Lot
                                    ,  @c_FromLoc
                                    ,  @c_LogicalFromLoc
                                    ,  @c_FromID
                                    ,  @c_ToLoc
                                    ,  @c_LogicalToLoc
                                    ,  @c_ToID
                                    ,  @c_UOM
                                    ,  @n_UOMQty
                                    ,  @n_Qty
                                    ,  @c_CaseID
                                    ,  @c_Wavekey
                                    ,  @c_Orderkey
                                    ,  @c_Priority
                                    ,  @c_PickMethod
                                    ,  @c_RefTaskKey
                                    ,  @c_AreaKey
                                    ,  @c_GroupKey
                                    ,  @c_Status
                                    ,  @c_DocType   --WL01 
      END  
      CLOSE @CUR_TW  
      DEALLOCATE @CUR_TW
   END

   IF @n_Continue = 1
   BEGIN
      EXEC isp_CreatePickdetail_WIP 
         @c_Loadkey = ''                                 
      ,  @c_Wavekey   = @c_Wavekey
      ,  @c_WIP_RefNo = @c_SourceType
      ,  @c_PickCondition_SQL = ''  
      ,  @c_Action  = 'U' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records    
      ,  @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
      ,  @b_Success = @b_Success OUTPUT
      ,  @n_Err     = @n_err     OUTPUT
      ,  @c_ErrMsg  = @c_errmsg  OUTPUT
   END

   QUIT_SP: 
   IF OBJECT_ID('tempdb..#TASKDETAIL_WIP','U') IS NOT NULL  
   BEGIN  
      DROP TABLE #TASKDETAIL_WIP 
   END

   IF @n_Continue=3  -- Error Occured - Process And Return  
   BEGIN  
      SET @b_Success = 0  
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         ROLLBACK TRAN  
      END  
      ELSE  
      BEGIN  
         WHILE @@TRANCOUNT > @n_StartTCnt  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
  
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV10_CPK'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
   END  
   ELSE  
   BEGIN  
      SET @b_Success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         COMMIT TRAN  
      END  
   END  
END -- procedure  
GO
GRANT EXECUTE ON [dbo].[mspRLWAV10_CPK] TO [NSQL]
GO