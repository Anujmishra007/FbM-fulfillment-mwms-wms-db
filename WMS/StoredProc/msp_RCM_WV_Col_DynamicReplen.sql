SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************************************/             
/* Store Procedure: msp_RCM_WV_Col_DynamicReplen                                                */             
/* Creation Date:  07-Jan-2026                                                                  */             
/* Copyright: Maersk WMS                                                                        */             
/* Written by:  JihHaur                                                                         */             
/* JIRA TICKET: FCR-9741                                                                        */             
/* Purpose:  Dynamic Replenishment for order                                                    */             
/*                                                                                              */             
/* Input Parameters:                                                                            */             
/*  @c_WaveKey                                                                                  */             
/*  @c_StorerKey                                                                                */             
/*  @c_Facility                                                                                 */             
/*  @c_Uom                                                                                      */             
/*  @c_PickMethod                                                                               */             
/*  @c_LocationType                                                                             */             
/*                                                                                              */             
/* Output Parameters:  None                                                                     */             
/*                                                                                              */             
/* Return Status:  None                                                                         */             
/*                                                                                              */             
/* Usage:                                                                                       */             
/*                                                                                              */             
/* Local Variables:                                                                             */             
/*                                                                                              */             
/* Called By:                                                                                   */             
/*                                                                                              */             
/* PVCS Version: 1.3                                                                            */             
/*                                                                                              */             
/* Version: 5.4                                                                                 */             
/*                                                                                              */             
/* Data Modifications:                                                                          */             
/*                                                                                              */             
/* Updates:                                                                                     */             
/* Date               Author      Ver         Purposes                                          */             
/* YYYY-MM-DD         {author}    {ver}       Close Cursor                                      */             
/* 2026-02-09         JHT029      1.0         FCR9741 ver1.8                                    */       
/* 2026-02-16         PPA371      1.1         Added WaveReplenRelease validation               */      
/* 2026-02-17         USH022      1.2         Skip Replen for pick face validaiton              */      
/* 2026-02-17         PPA371      1.3         Update prioirty for existing task                 */      
/* 2026-02-19         JHT029      1.4         use TaskDetail to limit the carton to 4 for each location*/     
/* 2026-02-25         JHT029      1.5         fixed for update prioirty for existing task (JH05)*/      
/* 2026-02-25         JHT029      1.6         for reallocation purpose (JH06)         */  
/************************************************************************************************/             
CREATE OR ALTER PROCEDURE [dbo].[msp_RCM_WV_Col_DynamicReplen]                
      @c_WaveKey NVARCHAR(10),             
      @b_Success INT          OUTPUT,             
      @n_err     INT          OUTPUT,             
      @c_errmsg  NVARCHAR(250) OUTPUT,           
      @c_Code    NVARCHAR(10),           
      @b_debug   INT = 0            
AS             
BEGIN             
  SET NOCOUNT ON             
  --SQL 2005 Standard             
  SET QUOTED_IDENTIFIER OFF             
  SET ANSI_NULLS OFF             
  SET CONCAT_NULL_YIELDS_NULL OFF             
                  
      DECLARE @n_continue  INT            
         , @n_starttcnt INT -- Holds the current transaction count                
         , @n_debug     INT            
         , @n_cnt       INT            
                                
      SELECT @n_starttcnt = @@TRANCOUNT, @n_continue = 1, @b_success = 0, @n_err = 0, @c_errmsg = '', @n_cnt = 0               
      SELECT @n_debug = @b_debug             
            
  DECLARE             
      @c_SourceType              NVARCHAR(30),            
      @c_StorerKey               NVARCHAR(10),             
      @c_Facility                NVARCHAR(20),             
      @c_LocationType            NVARCHAR(10),             
      @c_PickMethod              NVARCHAR(10),             
      @c_Sku                     NVARCHAR(20),            
      @c_BUSR7                   NVARCHAR(30),                   
      @c_Lot                     NVARCHAR(10),             
      @c_Id                      NVARCHAR(18),             
      @c_UomQty                  NVARCHAR(10),             
      @c_DropId                  NVARCHAR(20),             
      @c_MoveRefKey              NVARCHAR(10),               
      @c_PickFaceLocation        NVARCHAR(50),             
      @c_DynamicPickFaceLocation NVARCHAR(50),             
      @n_MinQty                  INT,             
      @n_MaxQty                  INT,             
      @n_StartTranCnt            INT,             
      @c_ReplenishmentKey        NVARCHAR(50),             
      @c_UCCNo                   NVARCHAR(20),             
      @c_PickDetailKey           NVARCHAR(18),             
      @c_curPickdetailkey        NVARCHAR(18),             
      @c_Loc                     NVARCHAR(10),            
      @c_AreaKey                 NVARCHAR(10),                   
      @c_PutawayZone             NVARCHAR(10),             
      @c_UOM                     NVARCHAR(10),             
      @c_PackKey                 NVARCHAR(10),             
      @c_OrderKey                NVARCHAR(10),             
      @c_OrderLineNumber         NVARCHAR(5),            
      @n_UCCQty                  INT,             
      @c_FromLoc                 NVARCHAR(50),             
      @c_ToLoc                   NVARCHAR(50),             
      @n_UCC_RowRef              INT,             
      @n_qtytoReplen             INT ,             
      --@c_SuccessFlag           NVARCHAR(1),             
                  
      @c_Wavekey_PD              NVARCHAR(10) = '' ,              
      @c_TaskDetailKey           NVARCHAR(10) ,            
      @c_Consigneekey            NVARCHAR(15) ,            
      @c_Route                   NVARCHAR(10) ,            
      @c_ExternOrderkey          NVARCHAR(50) ,             
      @c_Loadkey                 NVARCHAR(10) ,            
      @c_TaskType                NVARCHAR(10) ,            
      @c_LocAisle                NVARCHAR(10) = '' ,            
     @c_PackingStation          NVARCHAR(10) = '' ,            
      @n_NoOfUCCToDP             INT ,            
      @n_TotalEmptyLoc           INT ,               
      @n_LocQty                  INT ,            
      @n_Qty                     INT ,            
      @n_RowRef                  INT ,            
      @c_LogicalFromLoc          NVARCHAR(10) ,            
      @c_PicDetailLoc            NVARCHAR(10) ,            
      @c_LogicalToLoc            NVARCHAR(10) ,              
      @c_FromLocType             NVARCHAR(10) ,            
      @c_ToLocType               NVARCHAR(10) ,             
      @c_FromPAZone              NVARCHAR(10) ,            
      @c_LocationCategory        NVARCHAR(10) ,             
      @c_logicalloc              NVARCHAR(10) = '' ,             
      @c_LogicalLocStart         NVARCHAR(10) = '' ,             
      @b_UpdMultiWave            BIT          = 0 ,            
      @c_DPPPKZone               NVARCHAR(10) ,               
      @c_TransitLoc  NVARCHAR(10) ,            
      @c_FinalLoc                NVARCHAR(10) ,            
      @c_FinalID                 NVARCHAR(18) ,            
      @c_AllowMinReplenAndWaveRelease NVARCHAR(10) ,            
      @n_NoOfUCC_Replen          INT,            
      @n_OtherTaskQty            INT,            
      @n_CurrentLocQty           INT,            
      @n_AllPickDetailQty        INT,            
      @n_OrderGroup            NVARCHAR(20),            
      @c_Priority                NVARCHAR(10),      
      @c_UOM_Prev                NVARCHAR(10),             
      @n_UCCWODPLoc              INT = 0 ,            
      @n_UCCWOBULKDPLoc          INT = 0 ,            
      @n_MinPalletCarton         INT,                   
      @n_TotatOrderForSameUCC    INT,          
      @n_TotatCartonForSameLoc   INT          
          
      SET @c_SourceType = 'msp_RCM_WV_Col_DynamicReplen'            
        
   ----PPA371 start     
    IF EXISTS( SELECT 1 FROM WAVE (nolock) WHERE WaveKey= @c_WaveKey AND userdefine01='WaveReplenRelease')            
         BEGIN             
            SELECT @n_continue = 3;             
            SELECT @n_err = 97425;             
            SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': ' + @c_WaveKey + ' Replenishment already released before. (msp_RCM_WV_Col_DynamicReplen)';             
            GOTO RETURN_SP;             
         END;         
   ----PPA371 end               
      SELECT TOP 1              
         @c_StorerKey = o.StorerKey,              
         @c_Facility = o.Facility              
      FROM ORDERS O (NOLOCK)             
      JOIN WAVEDETAIL WD (NOLOCK) ON O.OrderKey = WD.OrderKey             
      WHERE WD.Wavekey = @c_WaveKey             
            
      IF @n_debug=1              
         SELECT '@c_Wavekey', @c_WaveKey, '@c_Facility', @c_Facility            
                  
      --Check StorerConfig AllowMinReplenAndWaveRelease            
      BEGIN TRY               
         EXEC dbo.nspGetRight @c_Facility = @c_Facility -- nvarchar(5)              
                            , @c_StorerKey = @c_StorerKey -- nvarchar(15)              
                            , @c_sku = N'' -- nvarchar(20)              
                            , @c_ConfigKey = N'AllowMinReplenAndWaveRelease' -- nvarchar(30)              
                            , @b_Success = @b_Success OUTPUT -- int              
                            , @c_authority = @c_AllowMinReplenAndWaveRelease OUTPUT -- nvarchar(30)              
                            , @n_err = @n_err OUTPUT -- int              
                            , @c_errmsg = @c_errmsg OUTPUT -- nvarchar(250)              
      END TRY              
      BEGIN CATCH              
         SET @n_Continue = 3              
         SET @c_ErrMsg = ERROR_MESSAGE()              
      END CATCH             
                  
      IF @c_AllowMinReplenAndWaveRelease = 1             
      BEGIN            
         IF EXISTS(SELECT 1 From TASKDETAIL (NoLock) Where StorerKey = @c_StorerKey AND TaskType IN ('RPF','ASTRPT') AND WaveKey = '' AND STATUS < '9' AND STATUS <> 'X')            
         BEGIN             
            SELECT @n_continue = 3;             
            SELECT @n_err = 94710;             
            SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Min Replenishment task in progress. (msp_RCM_WV_Col_DynamicReplen)';             
            GOTO RETURN_SP;             
         END;             
      END            
            
  -- Error check for WaveKey existence             
      IF @n_continue = 1 OR @n_continue = 2              
      BEGIN              
         IF NOT EXISTS(SELECT 1 FROM WaveDetail WITH (NOLOCK) WHERE WaveKey = @c_WaveKey)             
         BEGIN             
            SELECT @n_continue = 3;             
            SELECT @n_err = 94711;             
            SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': No Orders is being populated into WaveDetail. (msp_RCM_WV_Col_DynamicReplen)';             
            GOTO RETURN_SP;             
         END;             
      END            
            
      -- Error check for WaveKey Status             
      IF @n_continue = 1 OR @n_continue = 2              
      BEGIN             
         IF EXISTS(SELECT 1 FROM Wave WITH (NOLOCK) WHERE WaveKey = @c_WaveKey AND STATUS = '0')             
         BEGIN             
            SELECT @n_continue = 3;           
            SELECT @n_err = 94712;             
            SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Wave is not Allocated. (msp_RCM_WV_Col_DynamicReplen)';             
            GOTO RETURN_SP;             
         END;             
      END            
            
      -- Error check for existing of Location P&D             
      IF @n_continue = 1 OR @n_continue = 2              
      BEGIN             
       --USH022 start     
            
         IF EXISTS (    
            SELECT 1    
            FROM TaskDetail TD    
            JOIN Loc L ON L.Loc = TD.FromLoc AND L.Facility = @c_Facility    
            LEFT JOIN Loc LocAisle ON LocAisle.Facility = L.Facility AND LocAisle.LocAisle = L.LocAisle AND LocAisle.LocationType = 'PND'    
            WHERE TD.TaskType = 'RPF'    
               AND TD.WaveKey = @c_WaveKey    
               AND LocAisle.Loc IS NULL    
         )    
         BEGIN    
            DECLARE @c_MissingAisle NVARCHAR(10)    
            SELECT TOP 1 @c_MissingAisle = L.LocAisle    
            FROM TaskDetail TD    
            JOIN Loc L ON L.Loc = TD.FromLoc AND L.Facility = @c_Facility    
            LEFT JOIN Loc LocAisle ON LocAisle.Facility = L.Facility AND LocAisle.LocAisle = L.LocAisle AND LocAisle.LocationType = 'PND'    
            WHERE TD.TaskType = 'RPF'    
               AND TD.WaveKey = @c_WaveKey    
               AND LocAisle.Loc IS NULL    
    
            SELECT @n_continue = 3;    
            SELECT @n_err = 94713;    
            SELECT @c_errmsg = @c_MissingAisle + ' No P&D available. (msp_RCM_WV_Col_DynamicReplen)';    
            GOTO RETURN_SP;    
         END    
    
      END         
           
   --USH022 end     
            
      -- Error check for existing of Packing Station            
      IF @n_continue = 1 OR @n_continue = 2              
      BEGIN             
         SELECT TOP 1 @c_PackingStation = L.Loc FROM Loc L WITH (NOLOCK)             
                     WHERE L.Facility = @c_Facility AND             
                           L.LocationType = 'OTHER' AND             
                           L.PutawayZone IN ('CSCPACK','CSCCNVYR')            
         IF @c_PackingStation = ''            
         BEGIN             
            SELECT @n_continue = 3;             
            SELECT @n_err = 94714;             
            SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ' Pack Station not setup in Loc table. (msp_RCM_WV_Col_DynamicReplen)';             
            GOTO RETURN_SP;             
         END;             
   END            
            
      -- Error check for existing Sku's home location            
      DECLARE @t_PZ TABLE              
         (  PickZone NVARCHAR(10) NULL )              
      INSERT INTO @t_PZ ( PickZone )              
      SELECT DISTINCT LOC.PickZone              
      FROM WAVEDETAIL WD    WITH (NOLOCK)               
      JOIN PICKDETAIL PD    WITH (NOLOCK) ON (WD.Orderkey = PD.Orderkey)              
      LEFT JOIN SKUxLOC SxL WITH (NOLOCK) ON (PD.Storerkey = SxL.Storerkey)              
                                          AND(PD.Sku = SxL.Sku)              
                                          AND(SxL.LocationType = 'PICK')                
      LEFT JOIN LOC         WITH (NOLOCK) ON (SxL.Loc = LOC.Loc) AND LOC.Facility = @c_Facility              
      WHERE  WD.Wavekey = @c_Wavekey              
      AND    PD.UOM = '2'                 
              
      IF EXISTS (SELECT 1 FROM @t_PZ WHERE PickZone IS NULL)                   
      BEGIN              
         SET @n_Continue = 3              
         SET @n_Err = 94715              
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+':Sku''s home location not found. (msp_RCM_WV_Col_DynamicReplen)'              
         GOTO RETURN_SP              
      END                   
            
      DECLARE @t_UPDPICK TABLE              
      (  RowRef            INT   IDENTITY(1,1) PRIMARY KEY              
      ,  PickDetailKey     NVARCHAR(10)   NOT NULL DEFAULT ('')              
      ,  Loadkey           NVARCHAR(10)   NOT NULL DEFAULT ('')              
      ,  Orderkey          NVARCHAR(10)   NOT NULL DEFAULT ('')              
      ,  Consigneekey      NVARCHAR(15)   NOT NULL DEFAULT ('')              
      ,  [Route]           NVARCHAR(10)   NOT NULL DEFAULT ('')              
      ,  ExternOrderkey  NVARCHAR(50)   NOT NULL DEFAULT ('')              
      ,  Wavekey           NVARCHAR(10)   NOT NULL DEFAULT ('')                
      ,  Qty               INT            NOT NULL DEFAULT(0)                                         
      )              
              
      DECLARE @t_DPRange TABLE              
      (  PickZone          NVARCHAR(10)   NOT NULL DEFAULT('') PRIMARY KEY              
      ,  LogicalLocStart   NVARCHAR(10)   NOT NULL DEFAULT('')              
      )              
            
      IF OBJECT_ID('tempdb..#TMP_LOC_DP','u') IS NOT NULL              
      BEGIN              
         DROP TABLE #TMP_LOC_DP;              
      END              
              
      CREATE TABLE #TMP_LOC_DP              
      (              
         Facility          NVARCHAR(5)    NOT NULL DEFAULT('')                 
      ,  Loc               NVARCHAR(10)   NOT NULL Primary Key              
      ,  LocationType      NVARCHAR(10)   NOT NULL DEFAULT('')               
      ,  LocationHandling  NVARCHAR(10)   NOT NULL DEFAULT('')                    
      ,  LocationCategory  NVARCHAR(10)   NOT NULL DEFAULT('')               
      ,  LogicalLocation   NVARCHAR(10)   NOT NULL DEFAULT('')                           
      ,  PickZone          NVARCHAR(10)   NOT NULL DEFAULT('')              
      ,  LocLevel          INT            NOT NULL DEFAULT(0)                
      --,  TotalUCC          INT            NOT NULL DEFAULT(0)        
      --,  MaxPallet         INT            NOT NULL DEFAULT(0)              
      )                   
                 
      IF OBJECT_ID('tempdb..#TMP_LOC_DPP','u') IS NOT NULL              
      BEGIN              
         DROP TABLE #TMP_LOC_DPP;              
      END              
              
      CREATE TABLE #TMP_LOC_DPP              
      (              
         Facility          NVARCHAR(5)    NOT NULL DEFAULT('')                 
      ,  Loc               NVARCHAR(10)   NOT NULL Primary Key              
      ,  LocationType      NVARCHAR(10)   NOT NULL DEFAULT('')               
      ,  LocationHandling  NVARCHAR(10)   NOT NULL DEFAULT('')                    
      ,  LocationCategory  NVARCHAR(10)   NOT NULL DEFAULT('')               
      ,  LogicalLocation   NVARCHAR(10)   NOT NULL DEFAULT('')                           
      ,  PickZone          NVARCHAR(10)   NOT NULL DEFAULT('')              
      ,  LocLevel          INT            NOT NULL DEFAULT(0)                
      --,  TotalUCC          INT            NOT NULL DEFAULT(0)        
      --,  MaxPallet         INT            NOT NULL DEFAULT(0)                
      )              
            
      CREATE TABLE #TMP_PICK              
      (  RowRef            INT            NOT NULL IDENTITY(1,1)  PRIMARY KEY              
      ,  Facility          NVARCHAR(5)    NULL              
      ,  Storerkey         NVARCHAR(15)   NULL              
      ,  Sku               NVARCHAR(20)   NULL              
      ,  UOM               NVARCHAR(10)   NULL              
      ,  Lot               NVARCHAR(10)   NULL              
      ,  Loc               NVARCHAR(10)   NULL              
      ,  ID                NVARCHAR(18)   NULL              
      ,  DropID            NVARCHAR(20)   NULL              
      ,  UCCQty            INT            NULL  DEFAULT (0)              
      ,  Qty               INT            NULL  DEFAULT (0)              
      ,  PickMethod        NVARCHAR(10)   NULL              
      ,  LogicalFromLoc    NVARCHAR(10)   NULL              
      ,  FromLocType       NVARCHAR(10)   NULL              
      ,  FromPAZone        NVARCHAR(10)   NULL              
      ,  LocationHandling  NVARCHAR(10)   NULL                  
      ,  LocationType      NVARCHAR(10)   NULL                 
      ,  LocationCategory  NVARCHAR(10)   NULL              
      ,  ToLoc             NVARCHAR(10)   NULL  DEFAULT ('')              
      --,  Style             NVARCHAR(20)   NULL                                     
      --,  Color             NVARCHAR(10)   NULL                                     
      --,  Size              NVARCHAR(10)   NULL                                     
      --,  Lottable01        NVARCHAR(18)   NULL               
      ,  TaskDetailKey     NVARCHAR(10)   NULL                                      
      ,  OrderGroup        NVARCHAR(20)   NULL            
      ,  Priority          NVARCHAR(10)   NULL                 
      --,  OrderKey          NVARCHAR(10)   NULL  /*JH02*/          
      --,  OrderLineNumber   NVARCHAR(5)    NULL  /*JH02*/          
      )                  
                  
      ------------------------------------------------------------------------------------              
      -- Getting PIckDetail for Release              
      ------------------------------------------------------------------------------------              
      INSERT INTO #TMP_PICK              
         (  Facility              
         ,  Storerkey              
         ,  Sku              
         ,  UOM              
         ,  Lot              
         ,  Loc              
         ,  ID              
         ,  DropID              
         ,  UCCQty              
         ,  Qty               
         ,  PickMethod                
         ,  LogicalFromLoc                
         ,  FromLocType               
         ,  FromPAZone                
         --,  LocationHandling                
         ,  LocationType                    
         ,  LocationCategory              
         --,  Style                           
         --,  Color                          
         --,  Size                
         --,  Lottable01              
         ,  TaskDetailKey                  
         ,  OrderGroup            
         ,  Priority            
         --,  OrderKey          /*JH02*/          
         --,  OrderLineNumber   /*JH02*/          
         )              
      SELECT LOC.Facility              
            ,PD.Storerkey              
            ,PD.Sku              
            ,PD.UOM              
            ,PD.Lot              
            ,PD.Loc              
            ,PD.ID              
            ,PD.DropID              
       ,UCCQty = ISNULL(UCC.Qty,0)              
            ,SUM(PD.Qty)                
            --,PickMethod  = CASE WHEN MIN(PD.PickMethod) = 'P' THEN 'FP'               
            --                    ELSE 'PP' END              
            ,PD.PickMethod            
            ,LogicalFromLoc   = ISNULL(RTRIM(LOC.LogicalLocation),'')              
            ,FromLocType = CASE WHEN LOC.LocationType     <> 'PICK' --'DYNPPICK'               
                                 --AND LOC.LocationCategory <> 'SHELVING'               
                                 AND SxL.LocationType NOT IN ('PICK','CASE')               
                                 THEN 'BULK'               
                                 ELSE 'DPP' END              
            ,FromPAZone       = ISNULL(RTRIM(LOC.PutawayZone),'')              
            --,LocationHandling = ISNULL(RTRIM(LOC.LocationHandling),'')              
            ,LocationType     = ISNULL(RTRIM(LOC.LocationType),'')              
            ,LocationCategory = ISNULL(RTRIM(LOC.LocationCategory),'')              
            --,Style = CASE WHEN PD.UOM = '6'                                                    
           --         THEN ISNULL(RTRIM(SKU.Style),'')                                          
            --         ELSE '' END                                                                           
            --,Color = CASE WHEN PD.UOM = '6'                                                    
            --         THEN ISNULL(RTRIM(SKU.Color),'')                                          
            --         ELSE '' END                                                               
            --,Size  = CASE WHEN PD.UOM = '6'                                                    
            --         THEN ISNULL(RTRIM(SKU.Size),'')                                           
            --         ELSE '' END                                                               
            --,Lottable01 = ISNULL(RTRIM(LA.Lottable01),'')                
            ,TaskDetailKey = ISNULL(RTRIM(TD.TaskDetailkey),'')                     
            ,O.OrderGroup            
            ,CLK.Short            
            --,PD.OrderKey      /*JH02*/          
            --,PD.OrderLineNumber /*JH02*/          
      FROM   WAVEDETAIL WD    WITH (NOLOCK)               
      JOIN   PICKDETAIL PD    WITH (NOLOCK) ON (WD.Orderkey = PD.Orderkey)          
      JOIN   ORDERS     O     WITH (NOLOCK) ON (WD.Orderkey = O.Orderkey)            
      JOIN   LOTATTRIBUTE LA  WITH (NOLOCK) ON (PD.Lot = LA.Lot)                               
      JOIN   LOC        LOC   WITH (NOLOCK) ON (PD.Loc = LOC.Loc)              
      JOIN   SKUxLOC    SxL   WITH (NOLOCK) ON (PD.Storerkey = SxL.Storerkey)              
                                            AND(PD.Sku = SxL.Sku)               
                                            AND(PD.Loc = SxL.Loc)              
      JOIN   SKU        SKU   WITH (NOLOCK) ON (PD.Storerkey = SKU.Storerkey)                  
                                            AND(PD.Sku = SKU.Sku)                                                     
      LEFT JOIN UCC     UCC   WITH (NOLOCK) ON (PD.DropID = UCC.UCCNo)              
                                            AND(UCC.Storerkey = @c_Storerkey)                      
                                            AND(UCC.UCCNo <> '')                                  
      LEFT JOIN TASKDETAIL TD WITH (NOLOCK) ON (PD.TaskDetailkey = TD.TaskdetailKey)              
                                            AND(TD.Taskdetailkey <> '')                           
                                            AND(TD.[Status] <> 'X')                 
      LEFT JOIN CODELKUP CLK WITH (NOLOCK) ON CLK.LISTNAME = 'CSCUK01OPY'            
                                            AND CAST(CLK.Code AS INTEGER) = CAST(O.Priority AS INTEGER)            
      WHERE  WD.Wavekey = @c_Wavekey              
      --AND    TD.TaskDetailKey IS NULL  
      AND NOT EXISTS ( SELECT 1                          /*JH06 Start*/
                       FROM TASKDETAIL T (NOLOCK)
                       WHERE T.Storerkey = PD.Storerkey
                       AND T.CaseID = PD.DropID
                       AND T.UOM = PD.UOM
                       AND T.FromLoc = PD.Loc
                       AND T.[Status] NOT IN ('9', 'X')
                       AND T.Wavekey = @c_Wavekey)  /*JH06 End*/
      GROUP BY LOC.Facility              
            ,  PD.Storerkey              
            ,  PD.Sku              
            ,  PD.UOM              
            ,  PD.Lot              
            ,  PD.Loc              
            ,  PD.ID              
            ,  PD.DropID              
            ,  PD.PickMethod            
            ,  ISNULL(UCC.Qty,0)              
            ,  ISNULL(RTRIM(LOC.LogicalLocation),'')              
            ,  CASE WHEN LOC.LocationType <> 'PICK' --'DYNPPICK'                  
                     --AND LOC.LocationCategory <> 'SHELVING'               
                     AND SxL.LocationType NOT IN ('PICK','CASE')               
                     THEN 'BULK'               
                     ELSE 'DPP' END              
            , ISNULL(RTRIM(LOC.PutawayZone),'')              
            --,  ISNULL(RTRIM(LOC.LocationHandling),'')              
            ,  ISNULL(RTRIM(LOC.LocationType),'')              
            ,  ISNULL(RTRIM(LOC.LocationCategory),'')              
            --,  CASE WHEN PD.UOM = '6'                                                          
       --        THEN ISNULL(RTRIM(SKU.Style),'')                                           
            --        ELSE '' END                                                     
            --,  CASE WHEN PD.UOM = '6'                                                          
            --        THEN ISNULL(RTRIM(SKU.Color),'')                                           
            --        ELSE '' END                                                                
            --,  CASE WHEN PD.UOM = '6'                                                          
            --        THEN ISNULL(RTRIM(SKU.Size),'')                                            
            --        ELSE '' END                                                                
            --,  ISNULL(RTRIM(LA.Lottable01),'')               
            ,  ISNULL(RTRIM(TD.TaskDetailkey),'')                
            ,  O.OrderGroup            
            ,  CLK.Short            
            --,  PD.OrderKey        /*JH02*/          
            --,  PD.OrderLineNumber /*JH02*/          
      ORDER BY PD.UOM              
            ,  LocationType                                                      
            ,  CASE WHEN PD.UOM = '6' THEN '' ELSE PD.Loc END                                  
            ,  PD.Storerkey              
            ,  PD.Sku              
            --,  Style                                                                           
            --,  Color                                           
            --,  Size                                                                            
            --,  Lottable01                            
                 
      IF NOT EXISTS ( SELECT 1 FROM #TMP_PICK TP WITH (NOLOCK)               
                    )              
      BEGIN              
         SET @n_Continue = 3              
         SET @n_Err = 94716              
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': No Allocated Pick record found to release.  (msp_RCM_WV_Col_DynamicReplen)'              
         GOTO RETURN_SP              
      END             
                  
      IF EXISTS ( SELECT 1 FROM #TMP_PICK TP WITH (NOLOCK)               
                  WHERE UOM = '6'              
                )              
      BEGIN              
         INSERT INTO #TMP_LOC_DP              
            (              
            Facility              
         ,  Loc                 
         ,  LocationType              
         ,  LocationHandling                         
         ,  LocationCategory               
         ,  LogicalLocation           
         ,  PickZone              
         ,  LocLevel          
         --,  MaxPallet              
         )               
         SELECT              
            Facility              
         ,  Loc                 
         ,  LocationType              
         ,  LocationHandling                         
         ,  LocationCategory               
         ,  LogicalLocation                                
         ,  PickZone           
         ,  LocLevel          
         --,  MaxPallet              
         FROM LOC WITH (NOLOCK)              
         WHERE Facility = @c_Facility    --'GBTAM'--          
         AND LocationType = 'DYNPPICK' ----'DYNPICKP'  --Dynamic Pick          
         AND Status = 'OK'          
      END             
                 
      IF EXISTS (  SELECT 1 FROM #TMP_PICK TP WITH (NOLOCK)               
                  WHERE UOM IN ('6', '7') AND FromLocType <> 'DPP'              
               )              
      BEGIN              
          INSERT INTO #TMP_LOC_DPP              
         (              
            Facility              
         ,  Loc                 
         ,  LocationType              
         ,  LocationHandling                         
         ,  LocationCategory               
         ,  LogicalLocation                                 
         ,  PickZone             
         ,  LocLevel          
         --,  MaxPallet              
         )               
         SELECT              
            Facility              
         ,  Loc                 
         ,  LocationType              
         ,  LocationHandling                         
         ,  LocationCategory               
         ,  LogicalLocation                                
      ,  PickZone           
         , LocLevel          
         --,  MaxPallet              
         FROM LOC WITH (NOLOCK)              
         WHERE Facility = @c_Facility              
         AND LocationType = 'PICK'--'DYNPPICK'    --Pick Face            
         AND Status = 'OK'          
      END              
            
      --SET @n_NoOfUCCToDP = 0              
      --SELECT @n_NoOfUCCToDP = ISNULL(SUM(PCK.NoOfUCCToDP),0)              
      --FROM               
      --   (  SELECT NoOfUCCToDP = COUNT(DISTINCT TP.DropID)              
      --      FROM #TMP_PICK TP WITH (NOLOCK)               
      --      WHERE TP.UOM = '6'              
      --      AND   TP.DropID <> ''              
      --      GROUP BY TP.Storerkey              
      --             , TP.Sku              
      --   ) PCK                
                        
      --SET @n_TotalEmptyLoc = 0                  
      --SELECT @n_TotalEmptyLoc = ISNULL(SUM(DP.EmptyLoc),0)                  
      --FROM (                  
      --   SELECT EmptyLoc = (1 * Loc.MaxPallet)                  
      --   FROM #TMP_LOC_DP LOC WITH (NOLOCK)                    
      --   LEFT JOIN  LOTxLOCxID LLI WITH (NOLOCK)  ON (LLI.Loc = LOC.Loc AND  LLI.Storerkey = @c_Storerkey  )                                                     
      --   WHERE   LOC.Facility = @c_Facility                    
      --   --AND     LLI.Storerkey IS NULL                  
      --   GROUP BY LOC.Facility, LOC.Loc, Loc.MaxPallet                   
      --   HAVING CASE WHEN ISNULL(SUM((LLI.Qty - LLi.QtyPicked) + LLI.PendingMoveIN),0) = 0 THEN 0                  
      --                           ELSE COUNT(1)                  
      --                           END  = 0                               
                  
      --   ) DP                  
              
      --IF @n_NoOfUCCToDP > @n_TotalEmptyLoc              
      --BEGIN              
      --   SET @n_Continue = 3              
      --   SET @n_Err = 94717              
      --   SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not enough DP Location. '              
      --                  +'No of UCC:' + CONVERT(NVARCHAR(5),@n_NoOfUCCToDP - @n_TotalEmptyLoc) + ' still need(s) DP Loc (msp_RCM_WV_Col_DynamicReplen)'              
      --   GOTO RETURN_SP              
      --END               
            
  ---------- Error check for Replenishment existence            
  --------    IF @n_continue = 1 OR @n_continue = 2              
  --------    BEGIN             
  --------   IF EXISTS(SELECT 1 FROM Replenishment WITH (NOLOCK) WHERE WaveKey = @c_WaveKey)             
  --------   BEGIN             
  --------    SELECT @n_continue = 3;             
  --------    SELECT @n_err = 562801;             
  --------    SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Replenishment Tasks exist for the Wave. (msp_RCM_WV_Col_DynamicReplen)';             
  --------    GOTO RETURN_SP;             
  --------   END;             
  --------END                  
            
      -- Begin Transaction               
  IF @@TRANCOUNT = 0            
      BEGIN TRAN            
      ------------------------------------------------------------------------------------              
      -- Calculate To Loc              
      ------------------------------------------------------------------------------------              
      DECLARE CUR_PD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR              
      SELECT RowRef              
         ,  Facility              
         ,  Storerkey              
         ,  Sku              
         ,  UOM              
         ,  Lot              
         ,  Loc              
         ,  ID              
         ,  DropID              
         ,  UCCQty              
         ,  Qty               
         ,  PickMethod               
         ,  FromPAZone               
         ,  LogicalFromLoc                                                                    
         ,  FromLocType                                                                
         --,  Lottable01                
         ,  TaskDetailkey              
         ,  OrderGroup            
         ,  Priority                
         --,  OrderKey          /*JH02*/          
         --,  OrderLineNumber   /*JH02*/        
      FROM #TMP_PICK                                                                          
      ORDER BY RowRef              
                 
      OPEN CUR_PD              
                 
      FETCH NEXT FROM CUR_PD INTO  @n_RowRef              
                                 , @c_Facility              
                                 , @c_Storerkey              
                                 , @c_Sku              
                                 , @c_UOM              
                                 , @c_Lot              
                                 , @c_FromLoc              
                                 , @c_ID              
                                 , @c_DropID              
                                 , @n_UCCQty              
                                 , @n_Qty              
                                 , @c_PickMethod              
                                 , @c_FromPAZone              
                                 , @c_LogicalFromLoc                                           
                                 , @c_FromLocType                                              
                                 --, @c_Lottable01               
                                 , @c_TaskDetailkey               
                                 , @n_OrderGroup            
                                 , @c_Priority            
                                 --, @c_OrderKey         /*JH02*/          
                                 --, @c_OrderLineNumber  /*JH02*/          
              
      WHILE @@FETCH_STATUS <> -1              
      BEGIN              
              
         SET @c_ToLoc = ''              
         SET @c_ToLocType = ''              
         SET @b_UpdMultiWave = 0                             
     --SET @b_DirectGenPickSlip = 0                           
              
         IF @c_FromLocType = 'DPP'              
         BEGIN              
            --GOTO ADD_PSLIP -- Need to Generate Pickslipno              
            GOTO NextPick              
         END              
              
         IF EXISTS (SELECT 1 FROM TASKDETAIL (NOLOCK) WHERE WAVEKEY <> @c_WaveKey AND TaskType IN ('ASTTPA','RPF','RP1','RPT') AND Caseid = @c_DropID AND STATUS NOT IN ('9', 'X'))              
         BEGIN                           
            GOTO Update_Priority              
         END        
          
         IF @c_UOM = '2' -- Single Order pick           
         BEGIN          
            --Get the OrderKey And OrderLineNumber          
            SELECT @c_OrderKey = OrderKey, @c_OrderLineNumber = OrderLineNumber           
            FROM PickDetail WITH (NOLOCK)           
            WHERE StorerKey = @c_StorerKey AND           
                     WaveKey = @c_WaveKey AND           
                     DropID = @c_DropID AND           
                     SKU = @c_Sku AND          
                     @c_UOM = '2' AND           
                     Status < '5'          
          
            IF EXISTS (SELECT 1 FROM WorkOrderDetail WOD WITH (NOLOCK)           
                           WHERE WOD.ExternWorkOrderKey = @c_OrderKey AND           
                                    WOD.ExternLineNo = @c_OrderLineNumber AND           
                                    WOD.Type = 'PU')          
            BEGIN          
                GOTO FIND_DPP          
            END          
            ELSE          
            BEGIN          
                SET @c_ToLocType = 'PS'  -- Pack Station              
                SELECT TOP 1 @c_ToLoc = L.Loc FROM Loc L WITH (NOLOCK)             
                WHERE L.Facility = @c_Facility AND             
                      L.LocationType = 'OTHER' AND             
                      L.PutawayZone = CASE WHEN @n_OrderGroup = 'B2C' THEN  'CSCPACK' ELSE 'CSCCNVYR' END            
                        
            GOTO ADD_TASK              
            END          
                     
         END                  
             
         IF @c_UOM = '6'              
         BEGIN              
            --Check if same UCC (PICKDETAIL.DropID) is assigned for more than one order START                     
            SET @n_TotatOrderForSameUCC = 0              
            SET @c_ToLocType = 'PICK'            
            SET @c_ToLoc = ''          
          
            SELECT @n_TotatOrderForSameUCC = COUNT(DISTINCT PD.OrderKey)                               
            FROM PICKDETAIL   PD  WITH (NOLOCK)          
            WHERE PD.Wavekey  = @c_Wavekey              
            AND   PD.UOM      = '6'              
            AND   PD.DropID   <>''              
            AND   PD.Status   < '5'             
            AND   PD.DropID   = @c_DropID              
            AND   PD.Storerkey= @c_Storerkey              
            AND   PD.Sku      = @c_Sku              
              
            IF @n_TotatOrderForSameUCC > 1           
            BEGIN              
               SET @c_ToLocType = 'DYNPPICK'            
            END              
            --Check if same UCC (PICKDETAIL.DropID) is assigned for more than one order END              
              
            IF @c_ToLocType = 'PICK'          
            BEGIN              
               --SELECT TOP 1 @c_ToLoc = ISNULL(RTRIM(TD.ToLoc),'')                                 
               SELECT TOP 1 @c_ToLoc = ISNULL(RTRIM(LOC.Loc),'')                                 
               FROM #TMP_LOC_DPP  LOC WITH (NOLOCK)                                                
               --JOIN TASKDETAIL   TD  WITH (NOLOCK) ON (LOC.Loc = TD.ToLoc)              
               --JOIN LOTATTRIBUTE LA  WITH (NOLOCK) ON (TD.Lot = LA.Lot)              
               JOIN SKUxLOC SL WITH (NOLOCK) ON SL.loc = LOC.Loc           
               WHERE LOC.LocationType = 'PICK'--'DYNPICKP'              
               --AND   LOC.LocationHandling = @c_LocationHandling                
               --AND   LOC.LocationCategory = @c_LocationCategory                                                            
               AND LOC.Facility = @c_Facility              
               AND SL.Storerkey =  @c_Storerkey           
         AND   SL.Sku =  @c_Sku                   
               AND   SL.locationType = 'PICK'                 
               AND   LOC.PickZone = LOC.PickZone                
               --AND   TD.TaskType IN ('ASTTPA','RPF','RP1','RPT')              
               --AND   TD.UOM       = '6'              
               --AND   TD.CaseID    <>''              
               --AND   TD.Status    < '9'              
               ----AND   TD.SourceType like 'RCM_WV_Col_DynamicReplen-%'              
               --AND   TD.SourceType = 'msp_RCM_WV_Col_DynamicReplen'              
               --AND   TD.Wavekey  = @c_Wavekey              
               --AND   TD.Storerkey= @c_Storerkey              
               --AND   TD.Sku      = @c_Sku                                                       
               --AND EXISTS (SELECT 1                 
               --            FROM SKUxLOC SL WITH (NOLOCK)                
               --            JOIN LOC L WITH (NOLOCK) ON SL.loc = L.Loc                               
               --            WHERE SL.Storerkey =  @c_Storerkey                
               --            AND   SL.Sku =  @c_Sku                   
               --            AND   SL.locationType = 'PICK'                  
               --            AND   L.LocationType = 'PICK'--'DYNPPICK'                  
               --            AND   L.PickZone = LOC.PickZone                
               --            --AND   L.LocationHandling = @c_LocationHandling                
               --            )                               
               --GROUP BY TD.Storerkey              
               --      --,  TD.Sku                                                                 
               --      ,  TD.ToLoc              
                     --,  ISNULL(LOC.MaxPallet,0)              
               --HAVING ISNULL(LOC.MaxPallet,0) > ISNULL(COUNT( DISTINCT TD.CaseID),0)              
               IF @c_ToLoc = ''          
               BEGIN          
                  SELECT @n_continue = 3;             
                  SELECT @n_err = 94717;             
                  SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ' SKU:' + @c_Sku + ' No PickFace (msp_RCM_WV_Col_DynamicReplen)';           
                  GOTO RETURN_SP;             
               END           
            END              
                      
            IF @c_ToLocType = 'DYNPPICK'          
            BEGIN            
               FIND_DPP:          
          
               --Check BUSR7             
               SET @c_BUSR7= ''          
               SELECT TOP 1 @c_BUSR7 = ISNULL(BUSR7,'') FROM SKU WITH (NOLOCK)             
                           WHERE StorerKey = @c_Storerkey AND SKU = @c_Sku           
               IF @c_BUSR7 = ''                        
               BEGIN             
                  SELECT @n_continue = 3;             
                  SELECT @n_err = 94718;             
                  SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ' SKU:' + @c_Sku + ' No BUSR7 (msp_RCM_WV_Col_DynamicReplen)';             
                  GOTO RETURN_SP;             
               END;             
                         
               --Check PutawayZone          
               SET @c_PutawayZone = ''          
               SELECT TOP 1 @c_PutawayZone = SHORT FROM CODELKUP WITH (NOLOCK)             
                           WHERE StorerKey = @c_Storerkey AND LISTNAME = 'CSCUK01PT' AND Code = @c_BUSR7          
          
               IF @c_PutawayZone = ''                        
               BEGIN             
                  SELECT @n_continue = 3;             
                  SELECT @n_err = 94719;             
                  SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ' ' + @c_Sku + ' ' + @c_BUSR7 + ' No PutawayZone (msp_RCM_WV_Col_DynamicReplen)';             
                  GOTO RETURN_SP;             
               END;          
          
               IF NOT EXISTS (SELECT 1 FROM LOC WITH (NOLOCK)             
                           WHERE Facility = @c_Facility AND LocationType = 'DYNPPICK' AND PutawayZone = @c_PutawayZone)                        
               BEGIN             
                  SELECT @n_continue = 3;             
                  SELECT @n_err = 94720;                            
                  SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ' ' + @c_Sku + ' ' + @c_BUSR7 + ' Incorrect PutawayZone (msp_RCM_WV_Col_DynamicReplen)';             
                  GOTO RETURN_SP;             
               END;          
                        
               --1. Check DPP loc with same sku A from same wave + DPP locLevel > 0 + No of carton < 4          
               SELECT TOP 1 @c_ToLoc = LOC.LOC --ISNULL(RTRIM(TD.ToLoc),'')              
               FROM #TMP_LOC_DP LOC WITH (NOLOCK)                                               
               JOIN TASKDETAIL  TD  WITH (NOLOCK) ON (LOC.Loc = TD.ToLoc)       
               JOIN (SELECT DISTINCT ToLoc, COUNT(Distinct CaseID) AS TotalCaseID  
                     FROM TASKDETAIL WITH (NOLOCK)           
                     WHERE StorerKey = @c_Storerkey AND WaveKey = @c_Wavekey AND Status NOT IN ('9','X')  
                        AND ISNULL(CaseID,'') <> '' GROUP BY ToLoc) TD2 ON (TD.ToLOC = TD2.ToLoc)         
               --JOIN (SELECT Distinct LOC, ID           
               --            FROM LOTXLOCXID WITH (NOLOCK)           
               --            WHERE StorerKey = @c_Storerkey AND SKU = @c_Sku          
               --            AND Qty - QtyPicked > 0 AND ISNULL(ID,'') <> '' GROUP BY Loc, ID) LLI ON (LOC.LOC = LLI.LOC)         
               WHERE LOC.LocationType = 'DYNPPICK'--'DYNPICKP'              
                     AND LOC.LocLevel > 0          
                     AND LOC.Facility = @c_Facility            
                     AND LOC.PickZone = @c_PutawayZone          
                     --AND   LOC.LocationHandling = @c_LocationHandling                
                     --AND   LOC.LocationCategory = @c_LocationCategory                                                                           
                     AND   TD.TaskType IN ('ASTTPA','RPF','RP1','RPT')  --AND   TD.TaskType IN ('RPF','RP1','RPT')            
                     AND   TD.UOM       = '6'              
                     --AND   TD.CaseID    <>''              
                     AND   TD.Status    < '9'              
                     --AND   TD.DropID    = @c_DropID                
                     AND   TD.SourceType = 'msp_RCM_WV_Col_DynamicReplen'             
                     AND   TD.Wavekey  = @c_Wavekey              
                     AND   TD.Storerkey= @c_Storerkey              
                     AND   TD.Sku      = @c_Sku       
                     AND   TD2.TotalCaseID < 4  
               GROUP BY LOC.LOC, LOC.LogicalLocation, TD2.TotalCaseID           
               --HAVING COUNT(DISTINCT LLI.CaseID) < 4          
               ORDER BY LOC.LogicalLocation          
          
               --2. DPP loc with different sku B from same wave + DPP locLevel > 0 + No of carton < 4          
               IF @c_ToLoc = ''          
               BEGIN      
                  SELECT TOP 1 @c_ToLoc = LOC.LOC         
                  FROM #TMP_LOC_DP LOC WITH (NOLOCK)                                               
                  --JOIN TASKDETAIL  TD  WITH (NOLOCK) ON (LOC.Loc = TD.ToLoc)         
                  LEFT JOIN (SELECT Distinct ToLoc, COUNT(Distinct CaseID) AS TotalCaseID, COUNT(Distinct SKU) AS SKU  
                              FROM TASKDETAIL WITH (NOLOCK)           
                              WHERE StorerKey = @c_Storerkey AND WaveKey = @c_Wavekey   AND Status NOT IN ('9','X')  
                              AND ISNULL(CaseID,'') <> '' GROUP BY ToLoc) TD2 ON (LOC.LOC = TD2.ToLoc)     
                  WHERE LOC.LocationType = 'DYNPPICK'--'DYNPICKP'              
                AND LOC.LocLevel > 0          
                        AND LOC.Facility = @c_Facility            
                        AND LOC.PickZone = @c_PutawayZone       
                        AND TD2.TotalCaseID < 4  
                        AND TD2.SKU = 1
                  GROUP BY LOC.LOC, LOC.LogicalLocation, TD2.TotalCaseID , TD2.SKU  
                  --HAVING COUNT(DISTINCT TD2.SKU) = 1         
                  ORDER BY TotalCaseID DESC, LOC.LogicalLocation    
                  ----SELECT TOP 1 @c_ToLoc = LOC.LOC --ISNULL(RTRIM(TD.ToLoc),'')              
                  ----FROM #TMP_LOC_DP LOC WITH (NOLOCK)                                               
                  ----JOIN TASKDETAIL  TD  WITH (NOLOCK) ON (LOC.Loc = TD.ToLoc)  
                  ----JOIN (SELECT DISTINCT ToLoc, COUNT(Distinct CaseID) AS TotalCaseID  
                  ----   FROM TASKDETAIL WITH (NOLOCK)           
                  ----   WHERE StorerKey = @c_Storerkey AND WaveKey = @c_Wavekey AND Status NOT IN ('9','X')  
                  ----      AND ISNULL(CaseID,'') <> '' GROUP BY ToLoc) TD2 ON (TD.ToLOC = TD2.ToLoc)         
                  ----JOIN (SELECT Distinct LOC, SKU          
                  ----            FROM LOTXLOCXID WITH (NOLOCK)           
                  ----            WHERE StorerKey = @c_Storerkey AND SKU <> @c_Sku          
                  ----            AND Qty - QtyPicked > 0 AND ISNULL(ID,'') <> '' GROUP BY Loc, SKU) LLI ON (LOC.LOC = LLI.LOC)          
                  ----WHERE LOC.LocationType = 'DYNPPICK'--'DYNPICKP'              
                  ----      AND LOC.LocLevel > 0          
                  ----      AND LOC.Facility = @c_Facility          
                  ----      AND LOC.PickZone = @c_PutawayZone          
                  ----      --AND   LOC.LocationHandling = @c_LocationHandling                
                  ----      --AND   LOC.LocationCategory = @c_LocationCategory                                                                           
                  ----      AND   TD.TaskType IN ('ASTTPA','RPF','RP1','RPT')  --AND   TD.TaskType IN ('RPF','RP1','RPT')            
                  ----      AND   TD.UOM       = '6'              
                  ----      --AND   TD.CaseID    <>''              
                  ----      AND   TD.Status    < '9'              
                  ----      --AND   TD.DropID    = @c_DropID                
                  ----      AND   TD.SourceType = 'msp_RCM_WV_Col_DynamicReplen'             
                  ----      AND   TD.Wavekey  = @c_Wavekey              
                  ----      AND   TD.Storerkey= @c_Storerkey              
                  ----      AND   TD.Sku      <> @c_Sku        
                  ----      AND   TD2.TotalCaseID < 4  
                  ----GROUP BY LOC.LOC, LOC.LogicalLocation, LLI.SKU          
                  ------HAVING COUNT(DISTINCT LLI.ID) < 4 AND COUNT(DISTINCT LLI.SKU) = 1          
                  ----HAVING COUNT(DISTINCT LLI.SKU) = 1          
                  ----ORDER BY TotalCaseID DESC, LOC.LogicalLocation          
               END          
          
               --3. empty DPP loc ORDER BY locLevel DESC          
               IF @c_ToLoc = ''          
               BEGIN          
                  SELECT TOP 1 @c_ToLoc = LOC.LOC --ISNULL(RTRIM(TD.ToLoc),'')              
                  FROM #TMP_LOC_DP LOC WITH (NOLOCK)               
                  LEFT JOIN (SELECT DISTINCT LOC, SUM(Qty) - SUM (QtyPicked) AS TotalQty          
                              FROM LOTXLOCXID WITH (NOLOCK)           
                              WHERE StorerKey = @c_Storerkey --AND SKU <> @c_Sku          
                              GROUP BY Loc) LLI ON (LOC.LOC = LLI.LOC)          
                  WHERE LOC.LocationType = 'DYNPPICK'--'DYNPICKP'              
                        --AND LOC.LocLevel > 0          
                        AND LOC.Facility = @c_Facility          
                        AND LOC.PickZone = @c_PutawayZone          
                        AND (LLI.TotalQty = 0 OR LLI.LOC IS NULL)      
                        AND LOC.LOC NOT IN (SELECT ToLoc FROM TaskDetail WITH (NOLOCK) WHERE StorerKey = @c_Storerkey AND TaskType = 'RPF' AND Status NOT IN ('9','X') )  
                  GROUP BY LOC.LOC, LOC.LocLevel, LOC.LogicalLocation                                           
                  ORDER BY LOC.LocLevel DESC, LOC.LogicalLocation          
               END             
                        
               IF @c_ToLoc = ''          
               BEGIN          
                  SELECT @n_continue = 3;             
                  SELECT @n_err = 94721;             
                  SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ' ' + @c_Sku + ' ' + @c_PutawayZone + ' No empty DynamicPickFace (msp_RCM_WV_Col_DynamicReplen)';             
                  GOTO RETURN_SP;             
               END           
            END                           
         END             
              
         ADD_TASK:                
                    
            
            IF @c_ToLoc <> ''                      
            BEGIN              
               UPDATE #TMP_PICK              
               SET ToLoc = @c_ToLoc              
               WHERE RowRef = @n_RowRef              
              
               SET @n_err = @@ERROR                
               IF @n_err <> 0                
               BEGIN              
                  SET @n_continue = 3                
                  SET @n_Err = 94723              
                  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update #TMP_PICK Failed. (msp_RCM_WV_Col_DynamicReplen)'               
                  GOTO RETURN_SP              
               END                                 
               ------------------------------------------------------------------------------------              
               -- Create TaskDetail (START)              
               ------------------------------------------------------------------------------------              
               SET @c_TaskDetailkey = ''              
               SET @c_TaskType = 'RPF'              
              
               SET @b_success = 1                
               EXECUTE nspg_getkey                
                     'TaskDetailKey'               
                     , 10                
                     , @c_taskdetailkey OUTPUT                
                     , @b_success   OUTPUT                
                     , @n_err       OUTPUT                
                     , @c_errmsg    OUTPUT              
                               
               IF NOT @b_success = 1                
               BEGIN                
                  SET @n_Continue = 3              
                  GOTO RETURN_SP                
               END                
               
               --SET @c_SourceType = 'ispRLWAV20-' + RTRIM(@c_DispatchPiecePickMethod)              
               --SET @c_SourceType = 'msp_RCM_WV_Col_DynamicReplen'                            
            
               --Get @c_AreaKey            
              SELECT TOP 1 @c_AreaKey = L.PutawayZone FROM PickDetail PD WITH (NOLOCK)             
                     JOIN Orders O WITH (NOLOCK) ON O.OrderKey = PD.OrderKey             
                     JOIN Loc L WITH (NOLOCK) ON L.Loc = PD.Loc AND L.Facility = @c_Facility            
                     --JOIN Loc LocAisle WITH (NOLOCK) ON LocAisle.Facility = L.Facility AND LocAisle.LocAisle = L.LocAisle            
                     WHERE O.UserDefine09 = @c_WaveKey AND             
                           --LocAisle.LocationType = 'PND' AND            
                           PD.Sku = @c_Sku  AND          
                           PD.Loc = @c_Fromloc          
          
               --SELECT @c_LocAisle = LocAisle, @c_AreaKey = PutawayZone FROM Loc WITH (NOLOCK)            
               --         WHERE Facility = @c_Facility AND Loc = @c_Fromloc            
               --Get @LogicalLocation            
               SELECT @c_LogicalToLoc = LogicalLocation FROM Loc WITH (NOLOCK)             
                        WHERE Facility = @c_Facility AND Loc = @c_Toloc            
                SET @c_FinalLoc = @c_Toloc            
                            
               --------SET @c_LogicalToLoc = @c_ToLoc                
                           
               --------SET @c_TransitLoc = ''              
               --------SET @c_FinalLoc = ''              
               --------SET @c_FinalID = ''              
               --------IF @c_ToLocType = 'PS' AND @c_TaskType = 'RPF'                          
               --------   --SET @c_TransitLoc = @c_Toloc              
               --------   SET @c_FinalLoc = @c_Toloc              
               --------ELSE IF @c_ToLocType IN('DP','DPP') AND @c_TaskType = 'RPF'              
               --------BEGIN              
               --------   /*SELECT @c_TransitLoc = 'NK'+LTRIM(ISNULL(LocAisle,''))              
               --------   FROM LOC(NOLOCK)              
               --------   WHERE Loc = @c_ToLoc*/              
                             
               --------   SELECT @c_TransitLoc = PICKZONE.InLoc              
               --------   FROM LOC (NOLOCK)              
               --------   JOIN PICKZONE (NOLOCK) ON LOC.Pickzone = PICKZONE.Pickzone              
               --------   WHERE LOC.Loc = @c_Toloc              
                             
               --------   IF @c_TransitLoc IS NULL              
               --------      SET @c_TransitLoc = ''              
                             
               --------   SET @c_FinalLoc = @c_LogicalToLoc              
               --------   SET @c_FinalID = @c_ID                                                           
               --------END                  
               -- select @c_ToLoc,@c_LocAisle, @c_LogicalToLoc, @c_FinalLoc          
                   
               --USH022 start     
               DECLARE @FromLocAisle NVARCHAR(10)    
               SELECT @FromLocAisle = L.LocAisle    
               FROM LOC L WITH (NOLOCK)    
               WHERE L.Loc = @c_Fromloc    
                 AND L.Facility = @c_Facility    
    
               IF NOT EXISTS (    
                   SELECT 1    
                   FROM LOC L WITH (NOLOCK)    
                   WHERE L.LocAisle = @FromLocAisle    
                     AND L.LocationType = 'PND'    
                     AND L.Facility = @c_Facility    
               )    
               BEGIN    
                   SET @n_continue = 3    
                   SET @n_err = 94799    
                   SET @c_errmsg = 'NSQL' + CONVERT(char(6), @n_err) + ': No PND location found for aisle ' + ISNULL(@FromLocAisle, '') + ' (FromLoc: ' + @c_Fromloc + ')'    
                   GOTO RETURN_SP    
               END    
               --USH022 end     
               INSERT TASKDETAIL                
                  (                
                     TaskDetailKey                
                  ,  TaskType                
                  ,  Storerkey                
                  ,  Sku                
                  ,  UOM                
                  ,  UOMQty                
                  ,  Qty                
                  ,  SystemQty              
                  ,  Lot                
                  ,  FromLoc                
                  ,  FromID                
                  ,  ToLoc                
                  ,  ToID                
                  ,  SourceType                
                  ,  SourceKey                
                  ,  Priority                
                  ,  SourcePriority                
                  ,  Status                
                  ,  LogicalFromLoc                
                  ,  LogicalToLoc                
                  ,  PickMethod              
                  ,  Wavekey              
                  ,  Message02               
                  ,  Areakey              
                  ,  Message03              
                  ,  Caseid              
                  ,  Loadkey              
                  ,  PendingMoveIn                                                                   
                  ,  TransitLoc   --NJOW01                                     
                  ,  FinalLoc --NJOW01              
                  ,  FinalID  --NJOW01                              
                  )                
                  VALUES                
                  (                
                     @c_taskdetailkey                
                  ,  @c_TaskType --Tasktype                
                  ,  @c_Storerkey                
                  ,  @c_Sku                
                  ,  @c_UOM         -- UOM,                
                  ,  @n_UCCQty      -- UOMQty,         
                  ,  @n_UCCQty      --Qty              
                  ,  @n_Qty         --systemqty              
                  ,  @c_Lot                 
                  ,  @c_Fromloc                 
                  ,  ''             --@c_ID          -- from id                
                  ,  @c_FinalLoc    --@c_Toloc               
                  ,  ''             --@c_ID          -- to id                
                  ,  @c_SourceType  --Sourcetype                
                  ,  @c_Wavekey     --Sourcekey                
                  ,  @c_Priority    -- Priority                
                  ,  ''             -- Sourcepriority                
                  ,  '0'            -- Status                
                  ,  @c_LogicalFromLoc --Logical from loc                
                  ,  @c_LogicalToLoc   --Logical to loc                
                  ,  'PP'           --@c_PickMethod              
                  ,  @c_Wavekey              
                  ,  ''               --@c_ToLocType              
                  ,  @c_AreaKey       --''              
                  ,  ''              
                  ,  @c_DropID              
                  ,  ''              
                  ,  CASE WHEN @c_UOM IN ('2') THEN 0 ELSE @n_UCCQty END                         
                  ,  ''               --@c_TransitLoc             
                  ,  @c_FinalLoc             
                  ,  ''              --@c_FinalID             
                  )              
                  
               SET @n_err = @@ERROR                
               IF @n_err <> 0                
               BEGIN              
                  SET @n_continue = 3                
                  SET @n_Err = 97424               
                  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Taskdetail Failed. (msp_RCM_WV_Col_DynamicReplen)'               
                  GOTO RETURN_SP              
               END   

               /*JH05 Start*/
               ---Check other replenishment 
               Update_Priority:
               IF (@n_continue = 1 OR @n_continue = 2)
               BEGIN
                  IF TRY_CAST(@c_Priority AS INT) IS NOT NULL
                  BEGIN
                      UPDATE TASKDETAIL 
                      SET Priority = @c_Priority,              
                          TrafficCop = NULL              
                      WHERE TaskType = 'RPF' 
                        AND STATUS NOT IN ('9','X') 
                        AND CaseID = @c_DropID  
                        AND WaveKey <> @c_WaveKey                        
                        AND TRY_CAST(Priority AS INT) > CAST(@c_Priority AS INT)
                  END
                  ELSE
                  BEGIN                     
                      UPDATE TASKDETAIL 
                      SET Priority = @c_Priority,              
                          TrafficCop = NULL              
                      WHERE TaskType = 'RPF' 
                        AND STATUS NOT IN ('9','X') 
                        AND CaseID = @c_DropID  
                        AND WaveKey <> @c_WaveKey
                        AND Priority > @c_Priority
                  END
                  
                  SET @n_err = @@ERROR                
                  IF @n_err <> 0                
                  BEGIN              
                     SET @n_continue = 3                
                     SET @n_Err = 94722               
                     SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update TASKDETAIL.Priority Failed. (msp_RCM_WV_Col_DynamicReplen)'               
                     GOTO RETURN_SP              
                  END    
               END  /*JH05 End*/

            END              
            --ELSE          
            --BEGIN          
            --   Select           
            --END          
            ------------------------------------------------------------------------------------              
            -- Create TaskDetail (END)              
            ------------------------------------------------------------------------------------              
                       
         NextPick:            
              
       --------     ------------------------------------------------------------------------------------              
       --------     -- Stamp TaskDetailKey & Wavekey to PickDetail (START)              
       --------     ------------------------------------------------------------------------------------              
       ----------(Wan09) - START --Carton to DPP allocate by multiple Wave. Get Other Wave Pickdetail to update taskdetail              
       --------     --IF @c_UOM = '7' AND @c_FromLocType <> 'DPP' AND @c_DropID <> '' --(Wan11)              
       --------     IF @b_UpdMultiWave = 1                                            --(Wan11)              
       --------     BEGIN              
       --------        DECLARE CUR_UPD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR              
       --------        SELECT t.PickDetailKey              
       --------              ,t.Loadkey              
       --------              ,t.Orderkey              
       --------              ,t.Consigneekey                
       --------              ,t.[Route]              
       --------              ,t.ExternOrderkey                
       --------              ,t.Wavekey               
       --------        FROM @t_UPDPICK t              
       --------        ORDER BY RowRef                   
       --------     END              
                  
       ----------     --ELSE IF @b_DirectGenPickSlip = 1                       
       ----------     --BEGIN                      
       ----------     --   DECLARE CUR_UPD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR                        
       ----------     --   SELECT PD.PickDetailKey                        
       ----------    --         ,OH.Loadkey                        
       ----------     --         ,OH.Orderkey                        
       ----------     --         ,Consigneekey = ISNULL(RTRIM(OH.Consigneekey),'')                        
       ----------     --         ,Route = ISNULL(RTRIM(OH.Route),'')                        
       ----------     --         ,ExternOrderkey = ISNULL(RTRIM(OH.ExternOrderkey),'')                        
       ----------     --         ,WD.Wavekey                                     --(Wan09)                        
      ----------     --   FROM WAVEDETAIL WD WITH (NOLOCK)                                              
       ----------     --   JOIN ORDERS     OH WITH (NOLOCK) ON (WD.Orderkey = OH.Orderkey)                                  
       ----------     --   JOIN PICKDETAIL PD WITH (NOLOCK) ON (PD.Orderkey = OH.Orderkey)                                  
       ----------     --   WHERE PD.Lot = @c_Lot                        
       ----------     --   AND   PD.UOM = @c_UOM                        
       ----------     --   AND   PD.DropID = @c_DropID                        
       ----------     --   AND   WD.Wavekey= @c_Wavekey                                                                     
       ----------     --   AND   PD.[Status] < '9'        
       ----------     --END                      
                       
       --------     ELSE              
       --------     BEGIN              
       --------        DECLARE CUR_UPD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR              
       --------        SELECT PD.PickDetailKey              
       --------              ,OH.Loadkey              
       --------              ,OH.Orderkey              
       --------              ,Consigneekey = ISNULL(RTRIM(OH.Consigneekey),'')              
       --------              ,Route = ISNULL(RTRIM(OH.Route),'')              
       --------              ,ExternOrderkey = ISNULL(RTRIM(OH.ExternOrderkey),'')              
       --------              ,WD.Wavekey                                     --(Wan09)              
       --------        FROM WAVEDETAIL WD WITH (NOLOCK)                                                      
       --------        JOIN ORDERS     OH WITH (NOLOCK) ON (WD.Orderkey = OH.Orderkey)                        
 --------        JOIN PICKDETAIL PD WITH (NOLOCK) ON (PD.Orderkey = OH.Orderkey)                        
       --------        WHERE PD.Lot = @c_Lot              
       --------        AND   PD.Loc = @c_FromLoc              
       --------        AND   PD.ID  = @c_Id              
       --------        AND   PD.UOM = @c_UOM              
       --------        AND   PD.DropID = @c_DropID              
       --------        AND   WD.Wavekey= @c_Wavekey                                                           
       --------        AND   PD.[Status] < '9'                                                                              
       --------     END                          
              
       --------     OPEN CUR_UPD              
              
       --------     FETCH NEXT FROM CUR_UPD INTO  @c_PickDetailKey              
       --------                                ,  @c_Loadkey              
       --------                                ,  @c_Orderkey              
       --------                                ,  @c_Consigneekey              
       --------                                ,  @c_Route              
       --------                                ,  @c_ExternOrderkey       --(Wan08)              
       --------                                ,  @c_Wavekey_PD           --(Wan09)              
              
       --------     WHILE @@FETCH_STATUS <> -1              
       --------     BEGIN              
       ----------        SET @c_PickSlipNo = ''              
              
       ----------        SET @c_Zone = '3'                            
       ----------        SET @c_PackOrderkey = @c_Orderkey                
              
       ----------        IF @c_PreCTNLevel = 'L'                     
       ----------        BEGIN              
      ----------           SELECT @c_PickSlipNo = PickHeaderKey              
       ----------           FROM PICKHEADER WITH (NOLOCK)              
       ----------           WHERE ExternOrderkey = @c_Loadkey              
       ----------           AND   Loadkey  = @c_Loadkey              
       ----------           AND   Orderkey = ''              
       ----------           AND   Zone     = '7'              
       ----------           AND   Wavekey  = @c_Wavekey              
              
       ----------           SET @c_Zone = '7'              
       ----------           SET @c_PackOrderkey = ''              
       ----------           SET @c_ExternOrderkey = ''    --(Wan08)              
       ----------        END              
       ----------        ELSE IF @c_Orderkey <> ''                      
       ----------        BEGIN              
       ----------           SELECT @c_PickSlipNo = PickHeaderKey              
       ----------           FROM PICKHEADER WITH (NOLOCK)              
       ---------- WHERE ExternOrderkey = @c_Loadkey              
       ----------           AND   Orderkey = @c_Orderkey              
       ----------           AND   Zone     = '3'    
       ----------        END              
              
       ----------        IF @c_Orderkey <> '' AND @c_PickSlipNo = ''               
       ----------        BEGIN              
       ----------           SET @b_success = 1                
       ----------           EXECUTE nspg_getkey                
       ----------                 'PickSlip'                
       ----------                 , 9                
       ----------                 , @c_PickSlipNo   OUTPUT                
       ----------                 , @b_success      OUTPUT                
       ----------                 , @n_err          OUTPUT                
       ----------                 , @c_errmsg       OUTPUT              
                               
       ----------           IF NOT @b_success = 1                
       ----------           BEGIN                
       ----------              SET @n_continue = 3              
       ----------              GOTO QUIT_SP                
       ----------           END                
               
       ----------           SET @c_Pickslipno = 'P' + @c_Pickslipno              
     
       ----------           INSERT INTO PICKHEADER (PickHeaderKey, ExternOrderKey, Orderkey, PickType, Zone, Loadkey, Wavekey, Storerkey)  --(Wan07)                
       ----------           VALUES (@c_Pickslipno , @c_LoadKey, @c_PackOrderkey, '0', @c_Zone, @c_Loadkey, @c_Wavekey, @c_Storerkey)       --(Wan07)              
                             
       ----------           SET @n_err = @@ERROR                
       ----------           IF @n_err <> 0                
       ----------           BEGIN              
       ----------              SET @n_continue = 3                
       ----------              SET @n_Err = 81080             
       ----------              SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PICKHEADER Failed. (ispRLWAV20)'               
       ----------              GOTO QUIT_SP              
       ----------           END                 
              
       ----------           INSERT INTO PICKINGINFO (PickSlipNo, ScanInDate, PickerID, ScanOutDate)                
       ----------           VALUES (@c_Pickslipno , NULL, NULL, NULL)               
              
       ----------           SET @n_err = @@ERROR                
       ----------           IF @n_err <> 0             
       ----------           BEGIN              
       ----------              SET @n_continue = 3                
       ----------              SET @n_Err = 81090               
       ----------              SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PICKINGINFO Failed. (ispRLWAV20)'               
       ----------              GOTO QUIT_SP              
       ----------           END                 
              
       ----------           IF @c_DispatchPiecePickMethod = 'DTC'     --IF DTC, DO NOT UPDATE PICKSLIP TO Pickdetail & Insert PACKHEADER, PACKHEADER Insert At ECOM PAcking                
       ----------           BEGIN               
       ----------              SET @c_PickSlipNo = ''              
       ----------           END              
       ----------           ELSE              
       ----------           BEGIN              
       ----------              INSERT INTO PACKHEADER (PickSlipNo, Storerkey, Orderkey, Loadkey, Consigneekey, Route, OrderRefNo )                
       ----------              VALUES (@c_Pickslipno , @c_Storerkey, @c_PackOrderkey, @c_Loadkey, @c_Consigneekey, @c_Route, @c_ExternOrderkey)    --(Wan08)              
              
       ----------              SET @n_err = @@ERROR             
       ----------              IF @n_err <> 0                
       ----------              BEGIN              
       ----------                 SET @n_continue = 3                
       ----------                 SET @n_Err = 81100               
       ----------                 SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PACKHEADER Failed. (ispRLWAV20)'               
       ----------                 GOTO QUIT_SP              
       ----------              END                       
       ----------           END              
       ----------        END              
              
       --------        UPDATE PICKDETAIL WITH (ROWLOCK)              
       --------        SET TaskDetailKey = CASE WHEN @c_FromLocType = 'DPP' THEN              
       --------                                 ''              
       --------      ELSE @c_Taskdetailkey END                
       --------           ,Wavekey       = @c_Wavekey_PD--@c_Wavekey               
       --------           --,PickSlipNo    = @c_PickSlipNo              
       --------           ,TrafficCop    = NULL              
       --------           ,EditWho = SUSER_SNAME()              
       --------           ,EditDate= GETDATE()              
       --------        WHERE PickDetailkey = @c_PickDetailKey              
              
       --------        SET @n_err = @@ERROR              
       --------        IF @n_err <> 0               
       --------        BEGIN              
       --------           SET @n_continue = 3              
       --------           SET @n_err = 97421                 
       --------           SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Pickdetail Table Failed. (msp_RCM_WV_Col_DynamicReplen)'               
       --------           GOTO RETURN_SP              
       --------        END               
              
       --------        FETCH NEXT FROM CUR_UPD INTO  @c_PickDetailKey              
       --------                                   ,  @c_Loadkey              
       --------                                   ,  @c_Orderkey              
       --------                                   ,  @c_Consigneekey              
       --------                                   ,  @c_Route              
       --------                                   ,  @c_ExternOrderkey                    
       --------                                   ,  @c_Wavekey_PD                        
                                
       --------     END                          
       --------     CLOSE CUR_UPD              
       --------     DEALLOCATE CUR_UPD              
       ----------     ------------------------------------------------------------------------------------              
       ----------     -- Stamp TaskDetailKey & Wavekey to PickDetail (END)              
       ----------     ------------------------------------------------------------------------------------              
         --SET @c_UOM_Prev = @c_UOM              
              
         FETCH NEXT FROM CUR_PD INTO  @n_RowRef              
                                    , @c_Facility              
                                    , @c_Storerkey              
                                    , @c_Sku              
                                    , @c_UOM              
                                    , @c_Lot              
                                    , @c_FromLoc              
                                    , @c_ID              
                                    , @c_DropID              
                                    , @n_UCCQty              
                                    , @n_Qty              
                                    , @c_PickMethod              
                                    , @c_FromPAZone              
                                    , @c_LogicalFromLoc                                        
                                    , @c_FromLocType                                           
                                    --, @c_Lottable01               
                                    , @c_TaskDetailkey    --(Wan11)                                               
                                    , @n_OrderGroup            
                                    , @c_Priority            
                                    --, @c_OrderKey          /*JH02*/          
                                   --, @c_OrderLineNumber   /*JH02*/          
          
         --IF @n_Continue = 3 AND @c_UOM_Prev = '6' AND (@c_UOM <> '6' OR @@FETCH_STATUS = -1)               
         --BEGIN                          
         --   SET @n_UCCWODPLoc = 0              
         --   SET @n_UCCWOBULKDPLoc = 0              
         --   SELECT @n_UCCWOBULKDPLoc = SUM(CASE WHEN @n_MinPalletCarton > 0 THEN T.TotalCartonInID ELSE 0 END)              
         --         ,@n_UCCWODPLoc = SUM(CASE WHEN @n_MinPalletCarton = 0 THEN T.TotalCartonInID ELSE 0 END)              
         --   FROM (              
         --      SELECT ID              
         --            ,TotalCartonInID = COUNT(DISTINCT DropID)                
         --      FROM #TMP_PICK              
         --      WHERE UOM = '6'                
         --      AND ToLoc = ''              
         --      GROUP BY ID                    
         --      ) T              
              
         --   SET @n_Err = 97422              
         --   SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not enough DP Location. '              
         --                +'No of UCC: ' + CONVERT(NVARCHAR(5),@n_UCCWODPLoc) + ' still need(s) Shelving DP Loc, '              
         --                +'No of UCC: ' + CONVERT(NVARCHAR(5),@n_UCCWOBULKDPLoc) + ' still need(s) BULK DP Loc (msp_RCM_WV_Col_DynamicReplen)'                          
         --   GOTO RETURN_SP              
         --END              
      END              
      CLOSE CUR_PD              
      DEALLOCATE CUR_PD              
            
      --------------------------------------------------------------------------------------              
      ---- Update Loose Qty From Pallet Loc's PickMethod to 'FP' if all UCC go to same toloc              
      --------------------------------------------------------------------------------------              
              
      --DECLARE CUR_ID CURSOR LOCAL FAST_FORWARD READ_ONLY FOR              
      --SELECT TD.FromLoc              
      --   ,   TD.FromID              
      --   ,   ToLoc   = MIN(TD.ToLoc)              
      --   ,   NoOfUCC_Replen = COUNT(DISTINCT TD.CaseID)              
      --FROM TASKDETAIL TD  WITH (NOLOCK)              
      --JOIN LOC        LOC WITH (NOLOCK) ON (TD.FromLoc = LOC.Loc)              
      --WHERE TD.Wavekey = @c_Wavekey              
      ----AND   TD.PickMethod        = 'PP'              
      --AND   TD.FromID            <>''              
      --AND   LOC.LocationHandling = '1'               
      --AND   LOC.LocationType     = 'OTHER'                  
      --AND   LOC.LocationCategory = 'BULK'               
      --GROUP BY TD.FromLoc              
      --      ,  TD.FromID              
      --HAVING COUNT ( DISTINCT TD.Sku )   = 1              
      --AND    COUNT ( DISTINCT TD.ToLoc ) = 1              
      --ORDER BY TD.FromLoc              
      --      ,  TD.FromID              
              
      --OPEN CUR_ID              
                 
      --FETCH NEXT FROM CUR_ID INTO  @c_FromLoc              
      --                           , @c_ID              
      --                           , @c_ToLoc              
      --                           , @n_NoOfUCC_Replen              
      --WHILE @@FETCH_STATUS <> -1              
      --BEGIN              
      --   IF (  SELECT COUNT(DISTINCT UCCNo)               
      --         FROM UCC WITH (NOLOCK)              
      --         WHERE Loc = @c_FromLoc              
      --         AND   ID  = @c_ID              
      --         AND   Status <= '3'              
      --      ) <> @n_NoOfUCC_Replen              
      --   BEGIN              
      --      GOTO NEXT_ID              
      --   END              
              
      --   SET @CUR_UPDPM = CURSOR FAST_FORWARD READ_ONLY FOR              
      --   SELECT TD.TaskDetailKey              
      --   FROM TASKDETAIL TD  WITH (NOLOCK)              
      --   WHERE TD.Wavekey = @c_Wavekey              
      --   AND   TD.FromLoc = @c_FromLoc              
      --   AND   TD.ToID    = @c_ID              
      --   ORDER BY TD.TaskDetailKey              
              
      --   OPEN @CUR_UPDPM                    
              
      --   FETCH NEXT FROM @CUR_UPDPM INTO @c_TaskDetailKey              
              
      --   WHILE @@FETCH_STATUS <> -1              
      --   BEGIN              
      --      UPDATE TASKDETAIL WITH (ROWLOCK)              
      --         SET PickMethod = 'FP'           
      --      WHERE TaskDetailKey = @c_TaskDetailKey              
              
      --      SET @n_err = @@ERROR                
      --      IF @n_err <> 0                
      --      BEGIN              
      --         SET @n_continue = 3                
      --         SET @n_Err = 97422               
      --         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update #TASKDETAIL Failed. (msp_RCM_WV_Col_DynamicReplen)'               
      --         GOTO QUIT_SP              
      --      END               
      --      FETCH NEXT FROM @CUR_UPDPM INTO @c_TaskDetailKey              
      --   END              
                    
      --   NEXT_ID:              
      --   FETCH NEXT FROM CUR_ID INTO  @c_FromLoc              
      --                              , @c_ID              
      --                              , @c_ToLoc              
      --                              , @n_NoOfUCC_Replen              
      --END              
      --CLOSE CUR_ID              
      --DEALLOCATE CUR_ID              
              
      -----------------------------------------------------------------------------------------------              
      ------------ Replenishment - START Enable Gen General replenishment task              
      -----------------------------------------------------------------------------------------------              
      ----------DECLARE @n_RemainingQty INT = 0              
      ----------      , @n_Severity     INT = 0              
              
      ----------      , @CUR_SxL        CURSOR              
      ----------      , @CUR_REPLUCC    CURSOR              
              
              
      ----------IF OBJECT_ID('tempdb..#UCCPAlloc','u') IS NOT NULL              
      ----------   DROP TABLE #UCCPAlloc;              
              
      ----------CREATE TABLE #UCCPAlloc               
    ----------(  SeqNo             INT IDENTITY(1, 1)  PRIMARY Key              
      ----------,  Storerkey         NVARCHAR(15)   NOT NULL DEFAULT ('')               
      ----------,  Sku               NVARCHAR(20)   NOT NULL DEFAULT ('')               
      ----------,  UCCNo             NVARCHAR(20)   NOT NULL DEFAULT ('')               
      ----------,  UCCQtyAvail       INT            NOT NULL DEFAULT (0)               
      ----------)              
              
     ----------IF OBJECT_ID('tempdb..#UCCRepl','u') IS NOT NULL              
      ----------   DROP TABLE #UCCRepl;              
              
      ----------CREATE TABLE #UCCRepl               
      ----------(  SeqNo             INT IDENTITY(1, 1)  PRIMARY Key              
      ----------,  Storerkey         NVARCHAR(15)   NOT NULL DEFAULT ('')               
      ----------,  Sku               NVARCHAR(20)   NOT NULL DEFAULT ('')               
      ----------,  UCCNo             NVARCHAR(20)   NOT NULL DEFAULT ('')               
      ----------,  UCCReplQty        INT            NOT NULL DEFAULT (0)               
      ----------)              
              
      ----------INSERT INTO #UCCPAlloc ( Storerkey, Sku, UCCNo, UCCQtyAvail )              
     ----------SELECT               
      ----------       UCC.Storerkey              
      ----------      ,UCC.Sku              
      ----------      ,UCC.UCCNo                
      ----------      ,UCCQtyAvail = UCC.Qty - ISNULL(SUM(PD.Qty),0)              
      ----------FROM (SELECT DISTINCT Storerkey, Sku FROM #TMP_PICK) S               
      ----------JOIN PICKDETAIL PD (NOLOCK) ON  PD.Storerkey = S.Storerkey              
      ----------                            AND PD.Sku = S.Sku              
      ----------JOIN UCC WITH (NOLOCK) ON  UCC.UCCNo = PD.DropID              
      ----------JOIN LOC L WITH (NOLOCK) ON L.Loc = PD.Loc                
      ----------WHERE UCC.[Status] = '3'              
      ----------AND   UCC.UCCNo <> ''              
      ----------AND   PD.[Status] <= '3' -- Close pallet (to intransit or home location not update pickdetail.status to '5')              
      ----------AND   PD.UOM = '7'              
      ----------AND   PD.DropID <> ''              
      ----------AND   L.Facility = @c_Facility              
      ----------AND   L.LocationType NOT IN ('DYNPPICK')     -- Not In Home loc              
      ----------AND   L.LocationCategory NOT IN ('SHELVING') -- Not In Home loc              
      ----------GROUP BY UCC.Storerkey              
      ----------      ,  UCC.Sku           
      ----------      ,  UCC.UCCNo                
      ----------      ,  UCC.Qty              
              
      ----------INSERT INTO #UCCRepl ( Storerkey, Sku, UCCNo, UCCReplQty )              
      ----------SELECT               
      ----------       UCC.Storerkey              
      ----------      ,UCC.Sku              
      ----------      ,UCC.UCCNo                
      ----------      ,UCC.Qty              
      ----------FROM (SELECT DISTINCT Storerkey, Sku FROM #TMP_PICK) S               
      ----------JOIN UCC WITH (NOLOCK) ON  UCC.Storerkey = S.Storerkey              
      ----------                       AND UCC.Sku = S.Sku              
      ----------JOIN LOC L WITH (NOLOCK) ON L.Loc = UCC.Loc                
      ----------WHERE UCC.[Status] = '1'               
      ----------AND   UCC.UCCNo <> ''              
      ----------AND   L.Facility = @c_Facility              
      ----------AND   EXISTS (SELECT 1 FROM TASKDETAIL TD WITH (NOLOCK) WHERE TD.CaseID = UCC.UCCNo AND TD.[Status] < '9')              
      ----------AND   NOT EXISTS (SELECT 1 FROM #UCCPAlloc AL WHERE AL.UCCNo = UCC.UCCNo)              
              
      ----------SET @CUR_SxL = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR              
      ----------SELECT SxL.Storerkey              
      ----------   ,  SxL.Sku              
      ----------   ,  SxL.Loc              
      ----------   ,  Severity = SxL.QtyLocationLimit - ((SxL.Qty - SxL.QtyAllocated - SxL.QtyPicked) + ISNULL(SUM(AL.UCCQtyAvail),0) + ISNULL(SUM(RP.UCCReplQty),0))              
      ----------   --,  L.LocationHandling              
      ----------   --,  L.LogicalLocation              
      ----------FROM (SELECT T.Storerkey, T.Sku FROM #TMP_PICK T GROUP BY T.Storerkey, T.Sku)  PD              
      ----------JOIN SKUxLOC SxL WITH (NOLOCK) ON  PD.Storerkey = SxL.Storerkey AND PD.Sku = SxL.Sku              
      ----------JOIN LOC L WITH (NOLOCK) ON SxL.Loc = L.Loc              
      ----------LEFT JOIN #UCCPAlloc AL  ON  PD.Storerkey = AL.Storerkey  AND PD.Sku = AL.Sku              
      ----------LEFT JOIN #UCCREPL   RP  ON  PD.Storerkey = RP.Storerkey  AND PD.Sku = RP.Sku              
      ----------WHERE SxL.LocationType = 'PICK'              
      ----------AND   SxL.QtyLocationMinimum > 0              
      ----------AND   SxL.QtyLocationLimit > 0                  
      ----------AND   L.Facility = @c_Facility              
      ----------AND   L.LocationType = 'DYNPPICK'              
      ----------AND   L.LocationCategory = 'SHELVING'                   
      ----------AND   L.LocationFlag NOT IN ('DAMAGE', 'HOLD')                 
      ----------AND   L.[Status] = 'OK'               
      ----------GROUP BY              
      ----------      SxL.Storerkey              
      ----------   ,  SxL.Sku              
      ---------- ,  SxL.Loc              
      ----------   ,  SxL.QtyLocationLimit               
      ----------   ,  SxL.Qty              
      ----------   ,  SxL.QtyAllocated              
      ----------   ,  SxL.QtyPicked              
      ----------   ,  SxL.QtyLocationMinimum              
      ----------   ,  L.LocationHandling              
      ----------HAVING (SxL.Qty - SxL.QtyAllocated - SxL.QtyPicked)  + ISNULL(SUM(AL.UCCQtyAvail),0) + ISNULL(SUM(RP.UCCReplQty),0) <= SxL.QtyLocationMinimum                                                                                 
      ----------ORDER BY Sku              
                 
      ----------OPEN @CUR_SxL              
      ----------FETCH NEXT FROM @CUR_SxL INTO @c_Storerkey              
      ----------                           ,  @c_Sku              
      ----------                           ,  @c_ToLoc              
      ----------      ,  @n_Severity              
      ----------                          -- ,  @c_LocationHandling              
      ----------                          -- ,  @c_LogicalFromLoc              
              
      ----------WHILE @@FETCH_STATUS <> -1              
      ----------BEGIN              
      ----------   SET @n_RemainingQty = @n_Severity              
      ----------   --WHILE @n_RemainingQty > 0              
      ----------   --BEGIN              
      ----------   SET @c_Lot     = ''               
      ----------   SET @c_FromLoc = ''              
      ----------   SET @c_ID      = ''              
      ----------   SET @c_DropID  = ''            
      ----------   SET @n_UCCQty  = 0              
              
      ----------   SET @CUR_REPLUCC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR              
      ----------   SELECT   LLI.Lot              
      ----------         ,  LLI.Loc              
      ----------         ,  LLI.ID              
      ----------         ,  CS.UCCNo              
      ----------         ,  CS.UCCQty              
      ----------    ,  LOC.LogicalLocation              
      ----------   FROM LOTxLOCxID LLI WITH (NOLOCK)                    
      ----------   JOIN LOC WITH (NOLOCK) ON (LLI.Loc = LOC.LOC AND LOC.Status <> 'HOLD')                
      ----------   JOIN ID  WITH (NOLOCK) ON (LLI.Id  = ID.ID   AND ID.STATUS <> 'HOLD')                
      ----------   JOIN LOT WITH (NOLOCK) ON (LLI.LOT = LOT.LOT AND LOT.STATUS <> 'HOLD')              
      ----------   JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LLI.LOT = LA.LOT)              
      ----------   JOIN (   SELECT UCC.UCCNo, UCC.Lot, UCC.Loc, UCC.ID, UCCQty = ISNULL(SUM(UCC.Qty),0)              
      ----------            FROM  UCC WITH (NOLOCK)              
      ----------            WHERE UCC.Storerkey = @c_Storerkey              
      ----------            AND   UCC.[Status] = '1'              
      ----------            AND NOT EXISTS (SELECT 1 FROM TASKDETAIL TD WITH (NOLOCK)                
      ----------                            WHERE TD.CaseID = UCC.UCCNo AND TD.Status < '9'               
      ----------                            )              
      ----------            GROUP BY UCC.UCCNo, UCC.Lot, UCC.Loc, UCC.ID              
      ----------            HAVING COUNT(DISTINCT UCC.Sku) = 1 AND MIN(UCC.Sku)  = @c_Sku              
      ----------         )   CS ON LLI.Lot = CS.Lot AND LLI.Loc = CS.Loc AND LLI.ID = CS.ID              
      ----------   WHERE LLI.Storerkey = @c_Storerkey              
      ----------   AND   LLI.Sku = @c_Sku              
      ----------   AND   LOC.Facility = @c_Facility             --2020-07-09 Fixed              
      ----------   AND   LOC.LocationType = 'OTHER'              
      ----------  AND   LOC.LocationCategory = 'BULK'              
      ----------   --AND   (( @c_LocationHandling = '3' AND LA.Lottable01 IN ( 'A','' ) ) OR              
      ----------   --         ( @c_LocationHandling = '4' AND LA.Lottable01 = 'B' )              
      ----------   --      )              
      ----------   ORDER BY --LOC.LocationHandling DESC ,            
      ----------             LOC.LogicalLocation              
      ----------            ,LOC.Loc              
              
      ----------   OPEN @CUR_REPLUCC              
              
      ----------   FETCH NEXT FROM @CUR_REPLUCC INTO @c_Lot                   
      ----------                                 ,  @c_FromLoc               
      ----------                                 ,  @c_ID                    
      ----------                                 ,  @c_DropID                
      ----------                                 ,  @n_UCCQty                
      ----------                                 ,  @c_LogicalFromLoc              
              
      ----------   WHILE @@FETCH_STATUS <> -1 AND @n_RemainingQty > 0              
      ----------   BEGIN              
      ----------      IF @n_UCCQty > @n_RemainingQty              
      ----------      BEGIN              
      ----------         SET @n_RemainingQty = 0              
      ----------         GOTO NEXT_REPLUCC              
      ----------      END              
              
      ----------      IF @c_DropID = ''              
      ----------      BEGIN              
      ----------         SET @n_RemainingQty = 0              
      ----------         GOTO NEXT_REPLUCC              
      ----------      END              
      ----------      ------------------------------------------------------------------------------------              
      ----------      -- Create TaskDetail (START)              
      ----------      ------------------------------------------------------------------------------------              
      ----------      SET @c_TaskDetailkey = ''              
      ----------      --SET @c_SourceType = 'ispRLWAV20-REPLEN' --+ RTRIM(@c_DispatchPiecePickMethod) --(Wan14)              
      ----------      SET @c_SourceType = 'msp_RCM_WV_Col_DynamicReplen'           
      ----------      SET @c_TaskType = 'RPF'              
      ----------      SET @c_LogicalToLoc = @c_ToLoc              
      ----------      SET @c_ToLocType = 'DPP'              
      ----------      --SET @c_PickMethod= 'PP'              
      ----------      SET @c_UOM = '7'              
      ----------      SET @n_Qty = 0              
              
      ----------      SET @b_success = 1                
      ----------      EXECUTE nspg_getkey                
      ----------            'TaskDetailKey'               
      ----------            , 10                
      ----------            , @c_taskdetailkey OUTPUT                
      ----------            , @b_success   OUTPUT                
      ----------            , @n_err       OUTPUT                
      ----------            , @c_errmsg    OUTPUT              
                               
      ----------      IF NOT @b_success = 1                
      ----------      BEGIN                
      ----------         SET @n_Continue = 3              
      ----------         GOTO RETURN_SP                
      ----------      END                   
                        
      ----------      --Get @c_LocAisle, @c_AreaKey            
      ----------      SELECT @c_LocAisle = LocAisle, @c_AreaKey = PutawayZone FROM Loc WITH (NOLOCK)            
      ----------               WHERE Facility = @c_Facility AND Loc = @c_Fromloc            
      ----------      --Get @LogicalLocation            
      ----------      SELECT @c_LogicalToLoc = LogicalLocation FROM Loc WITH (NOLOCK)             
      ----------               WHERE Facility = @c_Facility AND Loc = @c_Toloc            
            
      ----------    --------  SET @c_TransitLoc = ''              
      ----------    --------  SET @c_FinalLoc = ''              
      ----------    --------  SET @c_FinalID = ''              
      ----------    --------  IF @c_ToLocType = 'PS' AND @c_TaskType = 'RPF'                               
      ----------    --------     SET @c_FinalLoc = @c_Toloc                          
      ----------    --------  ELSE IF @c_ToLocType IN('DP','DPP') AND @c_TaskType = 'RPF'              
      ----------    --------  BEGIN              
      ----------    --------/*SELECT @c_TransitLoc = 'NK'+LTRIM(ISNULL(LocAisle,''))  -- INC1444738             
      ----------    --------        FROM LOC(NOLOCK)              
      ----------    --------        WHERE Loc = @c_ToLoc*/              
                             
      ----------    --------        SELECT @c_TransitLoc = PICKZONE.InLoc               -- INC1444738             
      ----------    --------        FROM LOC (NOLOCK)              
      ----------    --------        JOIN PICKZONE (NOLOCK) ON LOC.Pickzone = PICKZONE.Pickzone              
      ----------    --------        WHERE LOC.Loc = @c_Toloc             
                        
                           
      ----------    --------        IF @c_TransitLoc IS NULL              
      ----------    --------           SET @c_TransitLoc = ''            
                     
                          
      ----------    --------     SET @c_FinalLoc = @c_LogicalToLoc             
      ----------    --------     SET @c_FinalID = @c_ID                                                           
      ----------    --------  END                     
              
      ----------      INSERT TASKDETAIL                
      ----------         (                
      ----------            TaskDetailKey                
      ----------         ,  TaskType                
      ----------         ,  Storerkey                
      ----------         ,  Sku                
      ----------         ,  UOM                
      ----------         ,  UOMQty                
      ----------         ,  Qty                
      ----------         ,  SystemQty              
      ----------         ,  Lot                
      ----------         ,  FromLoc                
      ----------         ,  FromID                
      ----------         ,  ToLoc                
      ----------         ,  ToID                
    ----------         ,  SourceType                
      ----------         ,  SourceKey                
      ----------         ,  [Priority]                
      ----------         ,  SourcePriority                
      ----------         ,  [Status]                
      ----------         ,  LogicalFromLoc                
      ----------         ,  LogicalToLoc                
      ----------         ,  PickMethod              
      ----------         ,  Wavekey              
      ----------         ,  Message02               
      ----------         ,  Areakey              
      ----------         ,  Message03              
      ----------         ,  Caseid              
      ----------         ,  Loadkey              
      ----------         ,  PendingMoveIn                                                                   
      ----------         ,  TransitLoc   --NJOW01                                     
      ----------         ,  FinalLoc --NJOW01              
      ----------         ,  FinalID  --NJOW01                                          
      ----------         )                
      ----------         VALUES                
      ----------         (                
      ----------            @c_taskdetailkey                
      ----------         ,  @c_TaskType    --Tasktype                
      ----------         ,  @c_Storerkey                
      ----------         ,  @c_Sku                
      ----------         ,  @c_UOM         -- UOM,                
      ----------         ,  @n_UCCQty      -- UOMQty,                
      ----------         ,  @n_UCCQty      --Qty              
      ----------         ,  @n_Qty         --systemqty              
      ----------         ,  @c_Lot                 
      ----------         ,  @c_Fromloc                 
      ----------         ,  @c_ID          -- from id                
      ----------         ,  @c_LocAisle   --@c_Toloc   PND            
      ----------         ,  @c_ID          -- to id                
      ----------         ,  @c_SourceType  --Sourcetype                
      ----------         ,  @c_Wavekey     --Sourcekey                
      ----------         ,  '5'            -- Priority                
      ----------         ,  '9'            -- Sourcepriority                
      ----------         ,  '0'  -- Status                
      ----------         ,  @c_LogicalFromLoc --Logical from loc                
      ----------         ,  @c_LogicalToLoc   --Logical to loc                
      ----------    ,  @c_PickMethod              
      ----------         ,  @c_Wavekey              
      ----------         ,  @c_ToLocType              
      ----------         ,  @c_AreaKey --''              
      ----------         ,  ''              
      ----------         ,  @c_DropID              
      ----------         ,  ''              
      ----------         ,  @n_UCCQty                   
      ----------         ,  @c_TransitLoc               
      ----------         ,  @c_FinalLoc               
      ----------         ,  @c_FinalID                           
      ----------         )              
                  
      ----------      SET @n_err = @@ERROR                
      ----------      IF @n_err <> 0                
      ----------      BEGIN              
      ----------         SET @n_continue = 3                
      ----------         SET @n_Err = 97423               
      ----------         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Taskdetail Failed. (msp_RCM_WV_Col_DynamicReplen)'               
      ----------         GOTO RETURN_SP              
      ----------      END                 
              
      ----------      ------------------------------------------------------------------------------------              
      ----------      -- Create TaskDetail (END)              
      ----------      ------------------------------------------------------------------------------------              
      ----------      SET @n_RemainingQty = @n_RemainingQty - @n_UCCQty              
              
      ----------      NEXT_REPLUCC:              
      ----------      FETCH NEXT FROM @CUR_REPLUCC INTO @c_Lot                   
      ----------                                       ,  @c_FromLoc               
      ----------                               ,  @c_ID                    
      ----------                                       ,  @c_DropID                
      ----------                                       ,  @n_UCCQty                
      ----------                             ,  @c_LogicalFromLoc              
      ----------   END              
      ----------   CLOSE @CUR_REPLUCC              
      ----------   DEALLOCATE @CUR_REPLUCC              
              
      ----------   FETCH NEXT FROM @CUR_SxL INTO @c_Storerkey              
      ----------                              ,  @c_Sku              
      ----------                              ,  @c_ToLoc              
      ----------                              ,  @n_Severity              
      ----------                             -- ,  @c_LocationHandling              
      ----------                             -- ,  @c_LogicalFromLoc             
      ----------END              
      ----------CLOSE @CUR_SxL              
      ----------DEALLOCATE @CUR_SxL              
      ----------------------------------------------------------------------------------------------              
      ------------ Replenishment - END              
      ----------------------------------------------------------------------------------------------              
      --                SELECT LDP.PickZone                      
      --      ,LDP.LogicalLocStart                          
      --FROM @t_DPRange  LDP              
                             
      --DECLARE @CUR_DP CURSOR                       
      --SET @CUR_DP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR                            
      --SELECT LDP.PickZone                      
      --      ,LDP.LogicalLocStart                          
      --FROM @t_DPRange  LDP        
      --ORDER BY LDP.PickZone                       
                               
      --OPEN @CUR_DP                            
      --FETCH NEXT FROM @CUR_DP INTO  @c_DPPPKZone                           
      --                           ,  @c_logicalloc                          
                       
      --WHILE @@FETCH_STATUS <> -1                            
      --BEGIN                          
      --   IF EXISTS ( SELECT 1                      
      --               FROM CODELKUP CL WITH (NOLOCK)                      
  --               WHERE CL.ListName = 'COLGBRDPLo'                 
      --               AND   CL.Code = @c_DPPPKZone                      
      --               AND   CL.Storerkey = @c_Storerkey                      
      --             )                     
      --   BEGIN                      
      --      UPDATE CODELKUP                      
      --      SET UDF01 = @c_LogicalLoc                      
      --      WHERE ListName = 'COLGBRDPLo'                      
      --      AND Code = @c_DPPPKZone                      
      --      AND Storerkey = @c_Storerkey                      
      --      AND Code2 = ''                      
      --   END                       
      --   ELSE                      
      --   BEGIN                
      --      IF @c_LogicalLoc <> ''          
      --      BEGIN          
      --         INSERT INTO CODELKUP (ListName, Code, Description, Storerkey, UDF01)                      
      --         VALUES ('COLGBRDPLo', @c_DPPPKZone,  @c_DPPPKZone, @c_Storerkey, @c_LogicalLoc)                      
      --      END          
      --   END                      
                      
      --   IF @@ERROR <> 0                      
      --   BEGIN                      
      --      SET @n_continue = 3                            
      --      SET @n_err = 97423                              
      --      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)                      
      --                   +': Insert/Update Last DP Location into CODELKUP Table for ListName = ''COLGBRDPLo'' Failed. (msp_RCM_WV_Col_DynamicReplen)'                             
      --      GOTO RETURN_SP                       
      --   END                       
                                                                 
      -- FETCH NEXT FROM @CUR_DP INTO @c_DPPPKZone                 
      --                              , @c_logicalloc                       
      --END                      
      --CLOSE @CUR_DP                      
      --DEALLOCATE @CUR_DP                           
             
  IF @n_continue = 1 OR @n_continue = 2             
  BEGIN             
   -- UPdate Wave to Indicate Replenishment Done             
   UPDATE Wave with (ROWLOCK)             
    SET UserDefine01 = 'WaveReplenRelease', EditDate=GETDATE(), TrafficCop=NULL              
   Where WaveKey = @c_WaveKey               
      END            
             
  -- Response Message setting based on @n_continue and @c_SuccessFlag variable             
  IF (@n_continue = 1 OR @n_continue = 2) AND @b_Success = 1            
  BEGIN             
   SELECT @c_errmsg = 'Replenishment Done'             
  END             
  ELSE             
  BEGIN             
      SET @n_err = 97425           
      SELECT @c_errmsg = 'NSQL' + CONVERT(char(6), @n_err) + 'Replenishment not done, Something went wrong in current transaction'             
  END             
             
  RETURN_SP:             
  IF CURSOR_STATUS( 'LOCAL', 'CUR_PD') in (0 , 1)                
      BEGIN              
         CLOSE CUR_PD              
         DEALLOCATE CUR_PD              
      END              
              
      --IF CURSOR_STATUS( 'LOCAL', 'CUR_ID') in (0 , 1)                
      --BEGIN              
      --   CLOSE CUR_ID              
      --   DEALLOCATE CUR_ID              
      --END              
              
      IF CURSOR_STATUS( 'LOCAL', 'CUR_UPD') in (0 , 1)                
      BEGIN              
         CLOSE CUR_UPD              
         DEALLOCATE CUR_UPD              
      END              
                 
      IF OBJECT_ID('tempdb..#TMP_PICK','u') IS NOT NULL              
      BEGIN              
         DROP TABLE #TMP_PICK;              
      END              
              
      IF CURSOR_STATUS( 'LOCAL', 'CUR_DPP') in (0 , 1)                
      BEGIN              
         CLOSE CUR_DPP              
         DEALLOCATE CUR_DPP              
      END              
             
  IF @n_continue=3  -- Error Occured - Process And Return                
      BEGIN                
         SELECT @b_success = 0                
         IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt                
         BEGIN                
            ROLLBACK TRAN                
         END                
         ELSE                
         BEGIN                
            WHILE @@TRANCOUNT > @n_starttcnt                
            BEGIN                
               COMMIT TRAN                
            END                    END                
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_RCM_WV_Col_DynamicReplen'                
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012                
         RETURN                
      END                
      ELSE                
      BEGIN                
         SELECT @b_success = 1                
         WHILE @@TRANCOUNT > @n_starttcnt                
         BEGIN                
            COMMIT TRAN                
         END                
         RETURN                
      END            
END   

GO
GRANT EXECUTE ON [dbo].[msp_RCM_WV_Col_DynamicReplen] TO [NSQL]
GO
