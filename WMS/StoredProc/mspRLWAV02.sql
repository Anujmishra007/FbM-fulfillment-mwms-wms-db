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
/*                                                                       */    
/* Called By: Wave Release                                               */    
/*                                                                       */    
/* PVCS Version: 1.0                                                     */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */    
/*************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV02]        
  @c_wavekey      NVARCHAR(10)    
 ,@b_Success      int        OUTPUT    
 ,@n_err          int        OUTPUT    
 ,@c_errmsg       NVARCHAR(250)  OUTPUT    
 AS    
 BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
      
   DECLARE @n_continue    int = 1     
         , @n_starttcnt   int = @@TRANCOUNT         -- Holds the current transaction count    
         , @n_debug       int = 0 
         , @n_cnt         int = 0
              
   SET @b_success = 0
   SET @n_err = 0
   SET @c_errmsg = ''

   DECLARE @c_Storerkey                NVARCHAR(15)   = ''  
         , @c_Facility                 NVARCHAR(5)    = ''
         , @c_TaskType                 NVARCHAR(10)   = ''           
         , @c_SourceType               NVARCHAR(30)   = ''
         , @c_Sku                      NVARCHAR(20)   = ''
         , @c_Lot                      NVARCHAR(10)   = ''
         , @c_FromLoc                  NVARCHAR(10)   = ''
         , @c_FromID                   NVARCHAR(18)   = ''
         , @c_Toloc                    NVARCHAR(10)   = ''  
         , @c_ToID                     NVARCHAR(18)   = ''   
         , @n_Qty                      INT            = 0
         , @n_UOMQty                   INT            = 0
         , @c_UOM                      NVARCHAR(10)   = ''
         , @c_Orderkey                 NVARCHAR(10)   = ''
         , @c_LoadKey                  NVARCHAR(10)   = ''
         , @c_Groupkey                 NVARCHAR(10)   = ''
         , @c_Priority                 NVARCHAR(10)   = ''           
         , @c_PickMethod               NVARCHAR(10)   = ''           
         , @c_LinkTaskToPick_SQL       NVARCHAR(4000) = '' 
         , @c_Taskdetailkey            NVARCHAR(10)   = ''
         , @c_ID                       NVARCHAR(18)   = ''
         , @cur_WaveReplto             CURSOR
                              
   SET @c_SourceType = 'mspRLWAV02'      
   SET @c_Priority   = '9'  
   SET @c_TaskType   = 'RPF'  
   SET @c_PickMethod = 'FP'  
  
   -----Get Storerkey and facility 
   
   SELECT TOP 1 @c_StorerKey = O.Storerkey,  
               @c_Facility = O.Facility   
   FROM WAVE W (NOLOCK)
   JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey     
   JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey  
   WHERE WD.Wavekey = @c_Wavekey  

   ------Loadplan Validation 

   IF  (@n_continue = 1 OR @n_continue = 2)  
   BEGIN  
      SELECT TOP 1 @c_Loadkey  = ISNULL(lpd.Loadkey,'')
      FROM WAVE W (NOLOCK)  
      JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey  
      JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
      LEFT OUTER JOIN LOADPLANDETAIL lpd (NOLOCK) ON lpd.Orderkey = O.Orderkey
      AND W.Wavekey = @c_Wavekey
      ORDER BY ISNULL(lpd.Loadkey,'')
        
      IF @c_Loadkey = ''
      BEGIN  
         SET @n_continue = 3    
         SET @n_err = 83010    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Loadplan has not generated yet. (mspRLWAV02)'         
      END 
   END

   -----Wave Validation            
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN   
      IF NOT EXISTS (SELECT 1   
                     FROM WAVEDETAIL WD (NOLOCK)  
                     JOIN PICKDETAIL PD (NOLOCK) ON WD.Orderkey = PD.Orderkey  
                     LEFT JOIN TASKDETAIL TD (NOLOCK) ON  PD.Taskdetailkey = TD.Taskdetailkey 
                                                      AND TD.Sourcetype = @c_SourceType 
                                                      AND TD.Tasktype = @c_TaskType
                     WHERE WD.Wavekey = @c_Wavekey                     
                     AND PD.Status = '0' 
                     AND PD.UOM = '7'
                     AND TD.Taskdetailkey IS NULL  
                  )  
      BEGIN  
         SET @n_continue = 3    
         SET @n_err = 83020    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Nothing to release. (mspRLWAV02)'         
      END        
   END  
         
   --Create pickdetail Work in progress temporary table 
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN 
      IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL  
         DROP TABLE #PICKDETAIL_WIP   

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
      ,  [AddDate]         [datetime]     NOT NULL DEFAULT (getdate())  
      ,  [AddWho]          [nvarchar](128)NOT NULL DEFAULT (suser_sname())  
      ,  [EditDate]        [datetime]     NOT NULL DEFAULT (getdate())  
      ,  [EditWho]         [nvarchar](128)NOT NULL DEFAULT (suser_sname())  
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
            
   IF @@TRANCOUNT = 0  
      BEGIN TRAN  
          
   --Initialize Pickdetail work in progress staging table  
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN  
      EXEC isp_CreatePickdetail_WIP  
          @c_Loadkey               = ''   
         ,@c_Wavekey               = @c_wavekey    
         ,@c_WIP_RefNo             = @c_SourceType   
         ,@c_PickCondition_SQL     = ''  
         ,@c_Action                = 'I'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records  
         ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization  
         ,@b_Success               = @b_Success OUTPUT  
         ,@n_Err                   = @n_Err     OUTPUT   
         ,@c_ErrMsg                = @c_ErrMsg  OUTPUT  
             
      IF @b_Success <> 1  
      BEGIN  
         SET @n_continue = 3  
      END            
      ELSE
      BEGIN
         UPDATE #PICKDETAIL_WIP  
         SET #PICKDETAIL_WIP.Taskdetailkey = ''  
         FROM #PICKDETAIL_WIP  
         LEFT JOIN TASKDETAIL TD (NOLOCK) ON  TD.Taskdetailkey = #PICKDETAIL_WIP.Taskdetailkey 
                                          AND TD.Sourcetype = @c_SourceType 
                                          AND TD.Tasktype = @c_TaskType 
                                          AND TD.Status <> 'X'   
         WHERE TD.Taskdetailkey IS NULL 
      END   
   END  
      
   IF @n_continue IN(1,2)   
   BEGIN 
      SET @cur_WaveReplto = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT O.Orderkey
            ,PD.Storerkey, PD.Sku, PD.Lot ,PD.Loc, PD.ID
            ,PD.UOM 
            ,SystemQty = lli.Qty - lli.QtyAllocated - lli.QtyPicked - lli.QtyReplen
      FROM WAVEDETAIL WD (NOLOCK)  
      JOIN WAVE W (NOLOCK) ON WD.Wavekey = W.Wavekey                            
      JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey  
      JOIN #PICKDETAIL_WIP PD (NOLOCK) ON O.Orderkey = PD.Orderkey  
      JOIN LOTxLOCxID lli (NOLOCK) ON  lli.Lot = PD.Lot      
                                   AND lli.Loc = PD.Loc
                                   AND lli.ID  = PD.ID
      LEFT JOIN TASKDETAIL TD (NOLOCK) ON  TD.Taskdetailkey = PD.Taskdetailkey 
                                       AND TD.Sourcetype = @c_SourceType 
                                       AND TD.Tasktype = @c_TaskType 
                                       AND TD.Status <> 'X'              
      WHERE WD.Wavekey = @c_Wavekey  
      AND PD.Status = '0'  
      AND PD.UOM = '7' 
      AND PD.WIP_RefNo = @c_SourceType  
      AND TD.Taskdetailkey IS NULL   
      ORDER BY PD.Storerkey
            ,  PD.Sku
            ,  PD.Lot
            ,  PD.Loc  
            ,  PD.ID
      OPEN @cur_WaveReplto    
         
      FETCH NEXT FROM @cur_WaveReplto INTO @c_Orderkey
                                          ,@c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID
                                          ,@c_UOM, @n_Qty
         
      WHILE @@FETCH_STATUS = 0 AND @n_continue IN (1,2)  
      BEGIN 
         SET @c_ToLoc = ''
         SET @c_ToId  = @c_FromID

         SELECT TOP 1
               @c_ToLoc = SL.Loc
         FROM SKUxLOC SL (NOLOCK) 
         JOIN #PICKDETAIL_WIP PD (NOLOCK) ON PD.Storerkey = SL.Storerkey
         JOIN LOTxLOCxID lli (NOLOCK) ON  lli.StorerKey = SL.StorerKey
                                      AND lli.Sku = SL.Sku
                                      AND lli.Loc = SL.Loc
         WHERE SL.Storerkey = PD.Storerkey 
         AND SL.Sku = PD.Sku  
         AND SL.Loc = PD.Loc  
         AND SL.LocationType IN ('CASE','PICK')  
         GROUP BY SL.StorerKey
               ,  SL.Sku
               ,  SL.Loc
               ,  SL.QtyLocationLimit
         HAVING SL.QtyLocationLimit <= SUM(LLI.PendingMoveIN + LLI.Qty)
         ORDER BY SL.Loc
                                 
         IF ISNULL(@c_Toloc,'') = ''  
         BEGIN           
            SET @n_continue = 3    
            SET @n_err = 83030  -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid To Loc setup at ROUTE. (mspRLWAV02)' 
         END                 

         SET @c_Taskdetailkey = ''  
         SET @c_PickMethod = 'FP'  
         SET @c_GroupKey = @c_Orderkey
         SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.UOM = @c_UOM AND ORDERS.Orderkey = @c_Orderkey'
                                            
         EXEC isp_InsertTaskDetail     
             @c_Taskdetailkey         = @c_Taskdetailkey OUTPUT  
            ,@c_TaskType              = @c_TaskType               
            ,@c_Storerkey             = @c_Storerkey  
            ,@c_Sku                   = @c_Sku  
            ,@c_Lot                   = @c_Lot   
            ,@c_UOM                   = '1'              
            ,@n_UOMQty                = @n_Qty       
            ,@n_Qty                   = @n_Qty        
            ,@c_FromLoc               = @c_Fromloc        
            ,@c_LogicalFromLoc        = @c_FromLoc   
            ,@c_FromID                = @c_FromID       
            ,@c_ToLoc                 = @c_ToLoc         
            ,@c_LogicalToLoc          = @c_ToLoc   
            ,@c_ToID                  = @c_ToID         
            ,@c_PickMethod            = @c_PickMethod  
            ,@c_Priority              = @c_Priority       
            ,@c_SourcePriority        = '9'        
            ,@c_SourceType            = @c_SourceType        
            ,@c_SourceKey             = @c_Wavekey        
            ,@c_OrderKey              = @c_Orderkey        
            ,@c_Groupkey              = @c_Groupkey  
            ,@c_WaveKey               = @c_Wavekey        
            ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey   
            ,@c_Message03             = ''  
            ,@c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
            ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL    
            ,@c_WIP_RefNo             = @c_SourceType  
            ,@b_Success               = @b_Success OUTPUT  
            ,@n_Err                   = @n_err OUTPUT   
            ,@c_ErrMsg                = @c_errmsg OUTPUT          
                
         IF @b_Success <> 1   
         BEGIN  
            SET @n_continue = 3    
         END               
                 
         FETCH NEXT FROM @cur_WaveReplto INTO @c_Orderkey
                                             ,@c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID
                                             ,@c_UOM, @n_Qty
      END  
      CLOSE @cur_WaveReplto  
      DEALLOCATE @cur_WaveReplto         
   END  
                       
   -----Update pickdetail_WIP work in progress staging table back to pickdetail   
   IF @n_continue = 1 or @n_continue = 2  
   BEGIN  
      EXEC isp_CreatePickdetail_WIP  
            @c_Loadkey               = '' 
         ,  @c_Wavekey               = @c_wavekey    
         ,  @c_WIP_RefNo             = @c_SourceType   
         ,  @c_PickCondition_SQL     = ''  
         ,  @c_Action                = 'U'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records  
         ,  @c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization  
         ,  @b_Success               = @b_Success OUTPUT  
         ,  @n_Err                   = @n_Err     OUTPUT   
         ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT  
             
      IF @b_Success <> 1  
      BEGIN  
         SET @n_continue = 3  
      END               
   END  

RETURN_SP:  
  
   -----Delete pickdetail_WIP work in progress staging table  
   IF @n_continue IN (1,2)  
   BEGIN  
      EXEC isp_CreatePickdetail_WIP  
            @c_Loadkey               = ''  
         ,  @c_Wavekey               = @c_wavekey    
         ,  @c_WIP_RefNo             = @c_SourceType   
         ,  @c_PickCondition_SQL     = ''  
         ,  @c_Action                = 'D'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records  
         ,  @c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization  
         ,  @b_Success               = @b_Success OUTPUT  
         ,  @n_Err                   = @n_Err     OUTPUT   
         ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT  
             
      IF @b_Success <> 1  
      BEGIN  
         SET @n_continue = 3  
      END               
   END  
      
   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL  
      DROP TABLE #PICKDETAIL_WIP  
  
   IF @n_continue=3  -- Error Occured - Process And Return    
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