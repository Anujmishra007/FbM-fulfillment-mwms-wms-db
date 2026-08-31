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
/* 2026-02-25         JHT029      1.6         for reallocation purpose (JH06)                   */  
/* 2026-03-17         JHT029      1.7         FCR-11614 (JH07)                                  */  
/* 2026-03-17         JHT029      1.8         FCR-11629 (JH08)                                  */  
/* 2026-03-25         JHT029      1.9         FCR-11629 skip if taskdetail exists for same dropid*/
/*                                            in other Orders in same wave(JH09)                */  
/* 2026-03-30         JHT029      2.0         FCR-12124 add some validation (JH10)              */
/* 2026-04-01         JHT029      2.1         FCR-12171 TaskDetail.ToLoc change for UOM 2 (JH11)*/
/* 2026-04-14         JHT029      2.2         Undo FCR-12171 and only assign to CSCCNVYR if no VAS(JH12)*/
/* 2026-04-16         JHT029      2.3         Validate sku.PutawayZone in ( 'CSCAP1', 'CSCEA1','CSCFW1')(JH13)*/
/* 2026-04-16         JHT029      2.4         Remove location type CASE (JH14)                  */
/* 2026-04-16         JHT029      2.5         FCR-12582 Add location type CASE and validation (JH15)*/
/* 2026-04-17         JHT029      2.6         FCR-12583 Add ID into TaskDetail (JH16)           */
/* 2026-04-22         JHT029      2.7         Hotfix for lenght of LogicalLocation (JH17)       */
/* 2026-05-08         JHT029      2.8         Remove invalid rfputaway if found (JH18)          */
/* 2026-05-08         JHT029      2.9         FCR-13080 Show SKU without PickFace in error msg(JH19)*/
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
      @c_SkuValidation           NVARCHAR(20) = '', 
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
      @c_TransitLoc              NVARCHAR(10) ,            
      @c_FinalLoc                NVARCHAR(10) ,            
      @c_FinalID                 NVARCHAR(18) ,            
      @c_AllowMinReplenAndWaveRelease NVARCHAR(10) ,            
      @n_NoOfUCC_Replen          INT,            
      @n_OtherTaskQty            INT,            
      @n_CurrentLocQty           INT,            
      @n_AllPickDetailQty        INT,            
      @n_OrderGroup              NVARCHAR(20),            
      @c_Priority                NVARCHAR(10),      
      @c_UOM_Prev                NVARCHAR(10),             
      @n_UCCWODPLoc              INT = 0 ,            
      @n_UCCWOBULKDPLoc          INT = 0 ,            
      @n_MinPalletCarton         INT,                   
      @n_TotalOrderForSameUCC    INT,          
      @n_TotalAllocQtyForSameUCC INT,                              /*JH08*/          
      @c_GetTaskdetailkey        NVARCHAR(10) = '',                /*JH18*/   
      @c_UserName                NVARCHAR(100) = SUSER_SNAME()     /*JH18*/   
          
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
      
      --JH10 Start: Error check for SKU  
      IF @n_continue IN (1, 2)
      BEGIN          
          DECLARE @c_MissingDim VARCHAR(20) = '';

          SELECT TOP 1 
              @c_SkuValidation = S.SKU,             
              @c_MissingDim = CASE 
                                  WHEN ISNULL(S.STDGROSSWGT, 0) = 0 THEN 'STDGROSSWGT'
                                  WHEN ISNULL(P.CubeUOM3, 0) = 0 THEN 'Cube'
                                  WHEN ISNULL(P.LengthUOM3, 0) = 0 THEN 'Length'
                                  WHEN ISNULL(P.WidthUOM3, 0) = 0 THEN 'Width'
                                  WHEN ISNULL(P.HeightUOM3, 0) = 0 THEN 'Height'
                              END
          FROM WAVEDETAIL WD WITH (NOLOCK)
          JOIN PICKDETAIL PD WITH (NOLOCK) ON WD.Orderkey = PD.Orderkey
          JOIN SKU S         WITH (NOLOCK) ON PD.Storerkey = S.Storerkey AND PD.Sku = S.Sku          
          LEFT JOIN PACK P   WITH (NOLOCK) ON P.PackKey = S.PackKey
          WHERE WD.Wavekey = @c_Wavekey 
            AND (                
                (S.STDGROSSWGT IS NULL OR S.STDGROSSWGT = 0)
                OR                
                (P.CubeUOM3 IS NULL OR P.CubeUOM3 = 0)
                OR                 
                (S.BUSR7 = '505' AND (
                    (P.LengthUOM3 IS NULL OR P.LengthUOM3 = 0) OR 
                    (P.WidthUOM3  IS NULL OR P.WidthUOM3  = 0) OR 
                    (P.HeightUOM3 IS NULL OR P.HeightUOM3 = 0)
                ))
            );
          
          IF @c_SkuValidation <> '' AND @c_MissingDim <> ''
          BEGIN
              SELECT @n_continue = 3, @n_err = 94725;
              SELECT @c_errmsg = 'NSQL' + CONVERT(char(6), @n_err) + ' SKU ' + @c_SkuValidation + ' ' + @c_MissingDim + ' is empty. (msp_RCM_WV_Col_DynamicReplen)';
              GOTO RETURN_SP;
          END
      END
      -- JH10 End 

      -- Error check for existing Sku's home location            
      DECLARE @t_PZ TABLE              
         (  PickZone NVARCHAR(10) NULL, 
            Sku      NVARCHAR(20) NULL)              
      INSERT INTO @t_PZ ( PickZone, SKU )              
      SELECT DISTINCT LOC.PickZone, PD.SKU              
      FROM WAVEDETAIL WD    WITH (NOLOCK)               
      JOIN PICKDETAIL PD    WITH (NOLOCK) ON (WD.Orderkey = PD.Orderkey)              
      LEFT JOIN SKUxLOC SxL WITH (NOLOCK) ON (PD.Storerkey = SxL.Storerkey)              
                                          AND(PD.Sku = SxL.Sku)              
                                          AND(SxL.LocationType = 'PICK')                
      LEFT JOIN LOC         WITH (NOLOCK) ON (SxL.Loc = LOC.Loc) AND LOC.Facility = @c_Facility         
      JOIN SKU              WITH (NOLOCK) ON SKU.SKU = PD.Sku AND SKU.StorerKey = PD.Storerkey  /*JH13*/
      WHERE  WD.Wavekey = @c_Wavekey              
      AND    PD.UOM = '2'        
      AND    SKU.PutawayZone in (SELECT Code FROM Codelkup WITH (NOLOCK) WHERE LISTNAME = 'PutawayVal' AND Storerkey = @c_StorerKey)  /*JH13 JH15*/
              
      IF EXISTS (SELECT 1 FROM @t_PZ WHERE PickZone IS NULL)                   
      BEGIN              
         SET @n_Continue = 3              
         SET @n_Err = 94715              
         SET @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err) + ':Sku''s home location not found: [' 
                         + (SELECT STRING_AGG(Sku, ', ') FROM @t_PZ WHERE PickZone IS NULL) + '] (msp_RCM_WV_Col_DynamicReplen)' /*JH19*/
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
      ,  LogicalLocation   NVARCHAR(18)   NOT NULL DEFAULT('')       /*JH17*/                    
      ,  PickZone          NVARCHAR(10)   NOT NULL DEFAULT('')              
      ,  LocLevel          INT            NOT NULL DEFAULT(0)                           
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
      ,  LogicalLocation   NVARCHAR(18)   NOT NULL DEFAULT('')       /*JH17*/                     
      ,  PickZone          NVARCHAR(10)   NOT NULL DEFAULT('')              
      ,  LocLevel          INT            NOT NULL DEFAULT(0)                
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
         ,  LocationType                    
         ,  LocationCategory         
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
            ,PD.PickMethod            
            ,LogicalFromLoc   = ISNULL(RTRIM(LOC.LogicalLocation),'')              
            ,FromLocType = CASE WHEN LOC.LocationType     <> 'PICK' --'DYNPPICK'  
                                 AND SxL.LocationType NOT IN ('PICK','CASE')  /*JH14 JH15*/          
                                 THEN 'BULK'               
                                 ELSE 'DPP' END              
            ,FromPAZone       = ISNULL(RTRIM(LOC.PutawayZone),'')        
            ,LocationType     = ISNULL(RTRIM(LOC.LocationType),'')              
            ,LocationCategory = ISNULL(RTRIM(LOC.LocationCategory),'')    
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
      AND PD.Status < '4'
      AND LOC.LocationType <> 'PND'
      --AND    TD.TaskDetailKey IS NULL  
      AND NOT EXISTS ( SELECT 1                          /*JH06 Start*/
                       FROM TASKDETAIL T (NOLOCK)
                       WHERE T.Storerkey = PD.Storerkey
                       AND T.CaseID = PD.DropID
                       AND T.UOM = PD.UOM
                       --AND T.FromLoc = PD.Loc
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
                     AND SxL.LocationType NOT IN ('PICK','CASE')           /*JH14 JH15*/    
                     THEN 'BULK'               
                     ELSE 'DPP' END              
            , ISNULL(RTRIM(LOC.PutawayZone),'')     
            ,  ISNULL(RTRIM(LOC.LocationType),'')              
            ,  ISNULL(RTRIM(LOC.LocationCategory),'')    
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
                  
      --IF EXISTS ( SELECT 1 FROM #TMP_PICK TP WITH (NOLOCK)  /*JH07*/             
      --            WHERE UOM = '6'              
      --          )              
      --BEGIN              
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
      --END             /*JH07*/  
                 
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

   --Remove invalid rfputaway if found
   IF (@n_continue = 1 OR @n_continue = 2)  --JH18
   BEGIN     
      DECLARE CUR_RFPA CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT RPA.Taskdetailkey, RPA.Sku 
         FROM RFPUTAWAY RPA (NOLOCK)
         LEFT JOIN TASKDETAIL TD (NOLOCK) ON RPA.Taskdetailkey = TD.TaskDetailKey
         WHERE RPA.StorerKey = @c_Storerkey
         AND (TD.Status IS NULL OR TD.Status in ('9','X')) 
         AND RPA.taskdetailkey <> ''      
            
      OPEN CUR_RFPA  
      
      FETCH NEXT FROM CUR_RFPA INTO @c_GetTaskdetailkey, @c_Sku

      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)              
      BEGIN              	      	 
      	 BEGIN TRY
            EXEC rdt.rdt_Putaway_PendingMoveIn 
                @cUserName = ''--@c_UserName
               ,@cType = 'UNLOCK'
               ,@cFromLoc = ''
               ,@cFromID = ''
               ,@cSuggestedLOC = ''
               ,@cStorerKey = @c_Storerkey
               ,@nErrNo = @n_Err OUTPUT
               ,@cErrMsg = @c_Errmsg OUTPUT
               ,@cSKU = @c_Sku
               ,@nPutawayQTY    = 0
               ,@cFromLOT       = ''
               ,@cTaskDetailKey = @c_GetTaskDetailKey
               ,@nFunc = 0
               ,@nPABookingKey = 0
               --,@cMoveQTYAlloc =  '1'                        
                        
            SELECT @n_err = @@ERROR              
         END TRY
         BEGIN CATCH
            SELECT @n_continue = 3      
         END CATCH            
                     	            
         FETCH NEXT FROM CUR_RFPA INTO @c_GetTaskdetailkey, @c_Sku
      END
      CLOSE CUR_RFPA
      DEALLOCATE CUR_RFPA                
   END   /*JH18*/

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
             /*JH12 Start*/ /*JH11 Start*/
            --Get the OrderKey And OrderLineNumber          
            SELECT @c_OrderKey = OrderKey, @c_OrderLineNumber = OrderLineNumber           
            FROM PickDetail WITH (NOLOCK)                       
            WHERE StorerKey = @c_StorerKey AND           
                     --WaveKey = @c_WaveKey AND           
                     OrderKey IN (SELECT OrderKey FROM WAVEDETAIL WITH (NOLOCK) WHERE WaveKey = @c_WaveKey) AND   /*JH07*/  
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
                      L.PutawayZone =  'CSCCNVYR' /*JH12*/   
                      --L.PutawayZone = CASE WHEN @n_OrderGroup = 'B2C' THEN  'CSCPACK' ELSE 'CSCCNVYR' END   /*JH12*/      
            GOTO ADD_TASK              
            END         
            /*JH12 End*//*JH11 End*/
         END                  
             
         IF @c_UOM = '6'              
         BEGIN              
            --Check if same UCC (PICKDETAIL.DropID) is assigned for more than one order START                     
            SET @n_TotalOrderForSameUCC = 0              
            SET @c_ToLocType = 'PICK'            
            SET @c_ToLoc = ''          
          
            SELECT @n_TotalOrderForSameUCC = COUNT(DISTINCT PD.OrderKey)                               
            FROM PICKDETAIL   PD  WITH (NOLOCK)          
            WHERE PD.Wavekey  = @c_Wavekey              
            AND   PD.UOM      = '6'              
            AND   PD.DropID   <>''              
            AND   PD.Status   < '5'             
            AND   PD.DropID   = @c_DropID              
            AND   PD.Storerkey= @c_Storerkey              
            AND   PD.Sku      = @c_Sku       
            
            /*JH08 START*/   
            SELECT @n_TotalAllocQtyForSameUCC = Sum(PD.Qty)                               
            FROM PICKDETAIL   PD  WITH (NOLOCK)          
            WHERE PD.Wavekey  = @c_Wavekey              
            AND   PD.UOM      = '6'              
            AND   PD.DropID   <>''              
            AND   PD.Status   < '5'             
            AND   PD.DropID   = @c_DropID              
            AND   PD.Storerkey= @c_Storerkey              
            AND   PD.Sku      = @c_Sku       
              
            IF @n_TotalOrderForSameUCC = 1           
            BEGIN
               IF @n_TotalAllocQtyForSameUCC = @n_UCCQty 
               BEGIN
                  SET @c_ToLocType = 'DYNPPICK'  
               END 
               ELSE
               BEGIN
                  SET @c_ToLocType = 'PICK'  
               END
            END
            ELSE
            BEGIN
               IF @n_TotalAllocQtyForSameUCC = @n_UCCQty 
               BEGIN
                  /*JH09 Start*/
                  IF EXISTS (SELECT 1 FROM TASKDETAIL WITH (NOLOCK)           
                           WHERE Wavekey  = @c_Wavekey    
                                 AND CASEID = @c_DropID            
                                 AND SKU = @c_Sku            
                                 AND Status = '0')          
                  BEGIN    
                     GOTO NextPick
                  END
                  ELSE
                  BEGIN
                     SET @c_ToLocType = 'DYNPPICK' 
                  END
                  --SET @c_ToLocType = 'DYNPPICK'  
                  /*JH09 END*/
               END 
               ELSE
               BEGIN
                  SET @c_ToLocType = 'PICK'  
               END
            END            
            /*JH08 END*/              
            --Check if same UCC (PICKDETAIL.DropID) is assigned for more than one order END              
              
            IF @c_ToLocType = 'PICK'          
            BEGIN                         
               SELECT TOP 1 @c_ToLoc = ISNULL(RTRIM(LOC.Loc),'')                                 
               FROM #TMP_LOC_DPP  LOC WITH (NOLOCK)                        
               JOIN SKUxLOC SL WITH (NOLOCK) ON SL.loc = LOC.Loc           
               WHERE LOC.LocationType = 'PICK'--'DYNPICKP'             
               AND LOC.Facility = @c_Facility              
               AND SL.Storerkey =  @c_Storerkey           
               AND   SL.Sku =  @c_Sku                   
               AND   SL.locationType = 'PICK'                 
               AND   LOC.PickZone = LOC.PickZone                
                     
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
               WHERE LOC.LocationType = 'DYNPPICK'--'DYNPICKP'              
                     AND LOC.LocLevel > 0          
                     AND LOC.Facility = @c_Facility            
                     AND LOC.PickZone = @c_PutawayZone                                                                                       
                     AND   TD.TaskType IN ('ASTTPA','RPF','RP1','RPT')  --AND   TD.TaskType IN ('RPF','RP1','RPT')            
                     AND   TD.UOM       = '6'           
                     AND   TD.Status    < '9'             
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
                  ,  @c_ID          --from id        JH16        
                  ,  @c_FinalLoc    --@c_Toloc               
                  ,  @c_ID          --to id          JH16      
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
            ------------------------------------------------------------------------------------              
            -- Create TaskDetail (END)              
            ------------------------------------------------------------------------------------              
                       
         NextPick:       
              
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
                                    , @c_TaskDetailkey                                                
                                    , @n_OrderGroup            
                                    , @c_Priority            
                                    --, @c_OrderKey          /*JH02*/          
                                   --, @c_OrderLineNumber   /*JH02*/                    
                    
      END              
      CLOSE CUR_PD              
      DEALLOCATE CUR_PD                    
             
  IF @n_continue = 1 OR @n_continue = 2             
  BEGIN             
   -- Update Wave to Indicate Replenishment Done             
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
