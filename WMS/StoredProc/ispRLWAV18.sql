if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ispRLWAV18]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ispRLWAV18]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/*************************************************************************/  
/* Stored Procedure: ispRLWAV18                                          */  
/* Creation Date: 21-Aug-2018                                            */  
/* Copyright: LFL                                                        */  
/* Written by:                                                           */  
/*                                                                       */  
/* Purpose: WMS-5651 - CN Livi's B2B Release task                        */
/*          Full case(2) to pack and Conso(6) carton to DPP and          */
/*          replenish overallocated loose(7) from bulk to pick           */
/*                                                                       */  
/* Called By: wave                                                       */  
/*                                                                       */  
/* PVCS Version: 1.3                                                     */  
/*                                                                       */  
/* Version: 7.0                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */  
/* 04/10/2018  NJOW01   1.0   Change replenishment priority to 9         */
/* 08/10/2018  NJOW02   1.1   Conso carton(uom6) to pick loc             */
/* 09/10/2018  NJOW03   1.2   Conso remove update pendingmovein & qtyreplen*/ 
/* 01-04-2020  Wan01    1.3   Sync Exceed & SCE                          */
/*************************************************************************/   

CREATE PROCEDURE [dbo].[ispRLWAV18]      
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
    
    DECLARE @n_continue int,    
            @n_starttcnt int,         -- Holds the current transaction count  
            @n_debug int,
            @n_cnt int
            
    SELECT  @n_starttcnt=@@TRANCOUNT , @n_continue=1, @b_success=0,@n_err=0,@c_errmsg='',@n_cnt=0
    SELECT  @n_debug = 0

    DECLARE @c_Storerkey            NVARCHAR(15)
            ,@c_Facility            NVARCHAR(5)
            ,@c_TaskType            NVARCHAR(10)            
            ,@c_SourceType          NVARCHAR(30)
            ,@c_Priority            NVARCHAR(10)
            ,@c_Toloc               NVARCHAR(10)
            ,@c_PickMethod          NVARCHAR(10)
            ,@c_Message03           NVARCHAR(20)
            ,@c_PickCondition_SQL   NVARCHAR(4000)
            ,@c_LinkTaskToPick_SQL  NVARCHAR(4000)
            ,@c_ToLoc_Strategy      NVARCHAR(30)
            ,@c_ToLoc_StrategyParam NVARCHAR(4000)
            ,@c_WaveType            NVARCHAR(10)
                            
    SET @c_SourceType = 'ispRLWAV18'    
    SET @c_Priority = '9'
    SET @c_TaskType = 'RPF'
    SET @c_PickMethod = 'PP'

    -----Wave Validation-----            
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN 
       IF NOT EXISTS (SELECT 1 
                      FROM WAVEDETAIL WD (NOLOCK)
                      JOIN PICKDETAIL PD (NOLOCK) ON WD.Orderkey = PD.Orderkey
                      LEFT JOIN TASKDETAIL TD (NOLOCK) ON PD.Taskdetailkey = TD.Taskdetailkey AND TD.Sourcetype = @c_SourceType AND TD.Tasktype IN('RPF')
                      WHERE WD.Wavekey = @c_Wavekey                   
                      AND PD.Status = '0'
                      AND TD.Taskdetailkey IS NULL
                     )
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83000  
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Nothing to release. (ispRLWAV18)'       
       END      
    END
    
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
        IF EXISTS (SELECT 1 FROM TASKDETAIL TD (NOLOCK) 
                   WHERE TD.Wavekey = @c_Wavekey
                   AND TD.Sourcetype = @c_SourceType
                   AND TD.Tasktype IN('RPF'))
        BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83010    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': This Wave has beed released. (ispRLWAV18)'       
        END                 
    END

    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
        IF EXISTS (SELECT 1
                   FROM WAVEDETAIL WD (NOLOCK)
                   JOIN ORDERS O (NOLOCK) ON WD.OrderKey = O.OrderKey
                   WHERE WD.WaveKey = @c_wavekey
                   AND ISNULL(O.Loadkey,'') = '')
        BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83020    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Found some orders of this wave without load planning. Release is not allowed. (ispRLWAV18)'       
        END                 
    END
          
    IF @@TRANCOUNT = 0
       BEGIN TRAN
                    
    -----Get Storerkey and facility
    IF  (@n_continue = 1 OR @n_continue = 2)
    BEGIN
        SELECT TOP 1 @c_Storerkey = O.Storerkey, 
                     @c_Facility = O.Facility,
                     @c_WaveType = W.WaveType
        FROM WAVE W (NOLOCK)
        JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
        JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
        AND W.Wavekey = @c_Wavekey 
    END    
        
    --Initialize Pickdetail work in progress staging table
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
           ,@c_Wavekey               = @c_wavekey  
           ,@c_WIP_RefNo             = @c_SourceType 
           ,@c_PickCondition_SQL     = ''
           ,@c_Action                = 'I'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
           ,@c_RemoveTaskdetailkey   = 'Y'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
           ,@b_Success               = @b_Success OUTPUT
           ,@n_Err                   = @n_Err     OUTPUT 
           ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
           
        IF @b_Success <> 1
        BEGIN
           SET @n_continue = 3
        END          
    END
    
    --Full carton to packstation    
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       SET @c_ToLoc = ''
       SET @c_ToLoc_Strategy = '' 
       SET @c_Message03 = 'PACKSTATION'
       SET @c_PickCondition_SQL = 'AND PICKDETAIL.UOM = ''2'' AND LOC.LocationType NOT IN(''PICK'',''DYNPPICK'') AND SKUXLOC.LocationType <> ''PICK'''         
       SET @c_LinkTaskToPick_SQL = 'AND PICKDETAIL.UOM = @c_UOM'
       
       SELECT TOP 1 @c_ToLoc = CL.Short
       FROM CODELKUP CL (NOLOCK)
       JOIN LOC (NOLOCK) ON CL.Short = LOC.Loc
       WHERE CL.Listname = 'LEVISLOC'
       AND CL.Storerkey = @c_Storerkey
       AND CL.Code = 'PACK'
       AND CL.Code2 = @c_WaveType
       
       IF ISNULL(@c_Toloc,'') = ''
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83030    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid pack station setup at codelkup ''LEVISLOC''. (ispRLWAV18)'             
       END
       ELSE
       BEGIN             
          EXEC isp_CreateTaskByPick
               @c_TaskType              = @c_TaskType
              ,@c_Wavekey               = @c_Wavekey  
              ,@c_ToLoc                 = @c_ToLoc       
              ,@c_ToLoc_Strategy        = @c_ToLoc_Strategy
              ,@c_PickMethod            = @c_PickMethod   -- ?=Auto determine FP/PP by inv qty available  ?TASKQTY=(Qty available - taskqty)  ?ROUNDUP=Qty available - (qty - systemqty)
              ,@c_Priority              = @c_Priority      
              ,@c_Message03             = @c_Message03       
              ,@c_SourceType            = @c_SourceType      
              ,@c_SourceKey             = @c_Wavekey         
              ,@c_CallSource            = 'WAVE' -- WAVE / LOADPLAN 
              ,@c_PickCondition_SQL     = @c_PickCondition_SQL   -- Additional condition to filter pickdetail. e.g. AND PICKDETAIL.UOM='2' AND LOC.LocationType = 'OTHER'
              ,@c_LinkTaskToPick        = 'WIP'    -- N=No update taskdetailkey to pickdetail Y=Update taskdetailkey to pickdetail  WIP=Update taskdetailkey to pickdetail_wip
              ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL   -- Additional sql condition to retrieve the pickdetail like AND PICKDETAIL.UOM = @c_UOM or Order BY
              ,@c_ReserveQtyReplen      = 'N'    -- TASKQTY=Reserve all task qty for replenish at Lotxlocxid ROUNDUP=Reserve round up to full carton/pallet qty only (qty - systemqty)
              ,@c_ReservePendingMoveIn  = 'N'    -- N=No update @n_qty to @n_PendingMoveIn Y=Update @n_qty to @n_PendingMoveIn           ,@c_WIP_RefNo             = @c_SourceType     -- referencekey for filtering pickdetail_wip table. optional and only apply for WIP
              ,@c_WIP_RefNo             = @c_SourceType     -- referencekey for filtering pickdetail_wip table. optional and only apply for WIP
              ,@c_RoundUpQty            = 'N'    -- FC=Round up qty to full carton by packkey/ucc FP=Round up qty to full pallet by packkey/ucc  FL=Round up to full location qty
              ,@c_SplitTaskByCase       = 'Y'    -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0. include last partial carton.
              ,@c_CasecntbyLocUCC       = 'Y'    -- N=Get casecnt by packkey Y=Get casecnt by UCC Qty of the lot,loc & ID. All UCC must have same qty.
              ,@c_ZeroSystemQty         = 'N'    -- N=@n_SystemQty will copy from @n_Qty if @n_SystemQty=0 Y=@n_SystemQty force to zero.
              ,@b_Success               = @b_Success OUTPUT
              ,@n_Err                   = @n_Err     OUTPUT        
              ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
              
          IF @b_Success <> 1
          BEGIN
             SET @n_continue = 3
          END                      
       END          
    END

    --Conso carton (6) from bulk to Pick.
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN       
       SET @c_ToLoc = ''
       SET @c_ToLoc_Strategy = 'PICK'  --'ispToLoc_DynamicLoc' 
       SET @c_ToLoc_StrategyParam = '' --'@c_CaseCntByLocUCC=Y'
       SET @c_Message03 = 'PICKLOC'
       SET @c_PickCondition_SQL = 'AND PICKDETAIL.UOM IN(''6'') AND LOC.LocationType NOT IN(''PICK'',''DYNPPICK'') AND SKUXLOC.LocationType <> ''PICK'''         
       SET @c_LinkTaskToPick_SQL = 'AND PICKDETAIL.UOM = @c_UOM'
             
       EXEC isp_CreateTaskByPick
            @c_TaskType              = @c_TaskType
           ,@c_Wavekey               = @c_Wavekey  
           ,@c_ToLoc                 = @c_ToLoc 
           ,@c_ToLoc_Strategy        = @c_ToLoc_Strategy
           ,@c_ToLoc_StrategyParam   = @c_ToLoc_StrategyParam
           ,@c_PickMethod            = @c_PickMethod   -- ?=Auto determine FP/PP by inv qty available  ?TASKQTY=(Qty available - taskqty)  ?ROUNDUP=Qty available - (qty - systemqty)
           ,@c_Priority              = @c_Priority      
           ,@c_Message03             = @c_Message03   
           ,@c_SourceType            = @c_SourceType      
           ,@c_SourceKey             = @c_Wavekey         
           ,@c_CallSource            = 'WAVE' -- WAVE / LOADPLAN 
           ,@c_PickCondition_SQL     = @c_PickCondition_SQL  -- Additional condition to filter pickdetail. e.g. AND PICKDETAIL.UOM='2' AND LOC.LocationType = 'OTHER'
           ,@c_LinkTaskToPick        = 'WIP'    -- N=No update taskdetailkey to pickdetail Y=Update taskdetailkey to pickdetail  WIP=Update taskdetailkey to pickdetail_wip
           ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL     -- Additional sql condition to retrieve the pickdetail like AND PICKDETAIL.UOM = @c_UOM or Order BY
           ,@c_ReserveQtyReplen      = 'N'    -- TASKQTY=Reserve all task qty for replenish at Lotxlocxid ROUNDUP=Reserve round up to full carton/pallet qty only (qty - systemqty)
           ,@c_ReservePendingMoveIn  = 'N'    -- N=No update @n_qty to @n_PendingMoveIn Y=Update @n_qty to @n_PendingMoveIn           ,@c_WIP_RefNo             = @c_SourceType     -- referencekey for filtering pickdetail_wip table. optional and only apply for WIP
           ,@c_WIP_RefNo             = @c_SourceType     -- referencekey for filtering pickdetail_wip table. optional and only apply for WIP
           ,@c_RoundUpQty            = 'N'             -- FC=Round up qty to full carton by packkey/ucc FP=Round up qty to full pallet by packkey/ucc  FL=Round up to full location qty
           ,@c_SplitTaskByCase       = 'Y'              -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0. include last partial carton.
           ,@c_CasecntbyLocUCC       = 'Y'    -- N=Get casecnt by packkey Y=Get casecnt by UCC Qty of the lot,loc & ID. All UCC must have same qty.
           ,@c_ZeroSystemQty         = 'N'              -- N=@n_SystemQty will copy from @n_Qty if @n_SystemQty=0 Y=@n_SystemQty force to zero.
           ,@b_Success               = @b_Success OUTPUT
           ,@n_Err                   = @n_Err     OUTPUT        
           ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
           
       IF @b_Success <> 1
       BEGIN
          SET @n_continue = 3
       END                                
    END
   
    --create replenishment for overallocated pick loc
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       EXEC isp_CreateReplenishTask
            @c_Storerkey = @c_Storerkey
           ,@c_Facility = @c_Facility
           ,@c_PutawayZones = '' --putawayzone list to filter delimited by comma e.g. Zone1, Zone3, Bulkarea, Pickarea
           ,@c_SQLCondition = 'SKUXLOC.Locationtype = ''PICK''' --additional condition to filter the pick/dynamic loc. e.g. LOC.locationhandling = '1' AND SKUXLOC.Locationtype = 'PICK'
           ,@c_CaseLocRoundUpQty  = 'FC' --case pick loc round up qty replen from bulk. FC=Round up to full case  FP=Round up to full pallet  FL=Round up to full location qty
           ,@c_PickLocRoundUpQty  = 'FC' --pick/dynamic loc round up qty replen from bulk. FC=Round up to full case  FP=Round up to full pallet  FL=Round up to full location qty
           ,@c_CaseLocReplenPickCode  = '' --custom replen pickcode for case loc lot sorting. the sp name must start from 'nspRP'. Put 'NOPICKCODE' to use standard lot sorting. put empty to use pickcode from sku table.
           ,@c_PickLocReplenPickCode  = '' --custom replen pickcode for pick/dynamic loc lot sorting. the sp name must start from 'nspRP'. Put 'NOPICKCODE' to use standard lot sorting. put empty to use pickcode from sku table.
           ,@c_QtyReplenFormula       = 'QtyExpectedNoLocLimit' --custom formula to calculate the qty to replenish. e.g. (@n_QtyLocationLimit - (@n_Qty - @n_QtyPicked)) - @n_PendingMoveIn 
                                           --the formula is a stadard sql statement and can apply below variables to calculate. the above example is the default.                                                    
                                           --@n_Qty, @n_QtyPicked, @n_QtyAllocated, @n_QtyLocationLimit, @n_CaseCnt, @n_Pallet, n_QtyExpected, @n_PendingMoveIn, @n_QtyExpectedFinal, @c_LocationType, @c_LocLocationType
                                           --it can pass in preset formula code. QtyExpectedFitLocLimit=try fit the overallocaton qty to location limit. usually apply when @c_BalanceExclQtyAllocated = 'Y' and do not want to replen overallocate qty exceed limit
                                           --QtyExpectedNoLocLimit=replenish overallocated qty without check location limit. 
           ,@c_Priority              = @c_Priority  --task priority default is 5 ?LOC=get the priority from skuxloc.ReplenishmentPriority  ?STOCK=calculate priority by on hand stock level against limit. if empty default is 5.
           ,@c_SplitTaskByCarton     = 'Y' --Y=Slplit the task by carton. Casecnt must set and not applicable if roundupqty is FP,FL. 
           ,@c_CasecntbyLocUCC       = 'Y' --N=Get casecnt by packkey Y=Get casecnt by UCC Qty of the lot,loc & ID. All UCC must have same qty.
           ,@c_OverAllocateOnly      = 'Y' --Y=Only replenish pick/dynamic loc with overallocated qty  N=replen loc with overallocated qty and below minimum qty.
                                           --Dynamic loc only replenish when overallocated.
           ,@c_BalanceExclQtyAllocated = 'N'  --Y=the qtyallocated is deducted when calculate loc balance. N=the qtyallocated is not deducated.
           ,@c_TaskType                = 'RPF'
           ,@c_Wavekey                 = @c_Wavekey   --set to replenish only pick/dynamic loc involved by the wave
           ,@c_Loadkey                 = ''  --set to replenish only pick/dynamic loc involved by the load
           ,@c_SourceType              = @c_SourceType
           ,@c_Message03               = 'PICKLOC'
           ,@c_PickMethod              = 'PP'
           ,@b_Success                 = @b_Success OUTPUT
           ,@n_Err                     = @n_Err     OUTPUT 
           ,@c_ErrMsg                  = @c_ErrMsg  OUTPUT     
       IF @b_Success <> 1
       BEGIN
          SET @n_continue = 3
       END            
    END
                 
    -----Update pickdetail_WIP work in progress staging table back to pickdetail 
    IF @n_continue = 1 or @n_continue = 2
    BEGIN
       EXEC isp_CreatePickdetail_WIP
             @c_Loadkey               = ''
            ,@c_Wavekey               = @c_wavekey  
            ,@c_WIP_RefNo             = @c_SourceType 
            ,@c_PickCondition_SQL     = ''
            ,@c_Action                = 'U'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
            ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
            ,@b_Success               = @b_Success OUTPUT
            ,@n_Err                   = @n_Err     OUTPUT 
            ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
           
       IF @b_Success <> 1
       BEGIN
          SET @n_continue = 3
       END             
    END
      
    -----Generate Pickslip No------
    IF @n_continue = 1 or @n_continue = 2 
    BEGIN
       EXEC isp_CreatePickSlip
            @c_Wavekey = @c_Wavekey
           ,@c_LinkPickSlipToPick = 'Y'  --Y=Update pickslipno to pickdetail.pickslipno 
           ,@c_ConsolidateByLoad = 'Y'
           ,@b_Success = @b_Success OUTPUT
           ,@n_Err = @n_err OUTPUT 
           ,@c_ErrMsg = @c_errmsg OUTPUT        
       
       IF @b_Success = 0
          SELECT @n_continue = 3    
    END
            
    -----Update Wave Status-----
    IF @n_continue = 1 or @n_continue = 2  
    BEGIN  
       UPDATE WAVE 
          --SET STATUS = '1' -- Released        --(Wan01) 
          SET TMReleaseFlag = 'Y'               --(Wan01) 
           ,  TrafficCop = NULL                 --(Wan01) 
           ,  EditWho = SUSER_SNAME()           --(Wan01) 
           ,  EditDate= GETDATE()               --(Wan01)
       WHERE WAVEKEY = @c_wavekey  
       SELECT @n_err = @@ERROR  
       IF @n_err <> 0  
       BEGIN  
          SELECT @n_continue = 3  
          SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 83040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update on wave Failed (ispRLWAV18)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
       END  
    END  
   
RETURN_SP:

    -----Delete pickdetail_WIP work in progress staging table
    IF @n_continue IN (1,2)
    BEGIN
       EXEC isp_CreatePickdetail_WIP
             @c_Loadkey               = ''
            ,@c_Wavekey               = @c_wavekey  
            ,@c_WIP_RefNo             = @c_SourceType 
            ,@c_PickCondition_SQL     = ''
            ,@c_Action                = 'D'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
            ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
            ,@b_Success               = @b_Success OUTPUT
            ,@n_Err                   = @n_Err     OUTPUT 
            ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
           
       IF @b_Success <> 1
       BEGIN
          SET @n_continue = 3
       END             
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
          END  
       END  
       execute nsp_logerror @n_err, @c_errmsg, "ispRLWAV18"  
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
 END --sp end
GO

GRANT EXECUTE ON ispRLWAV18 TO NSQL
GO

