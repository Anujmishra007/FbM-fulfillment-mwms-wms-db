SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspRLWAV11                                          */    
/* Creation Date: 2026-03-09                                             */
/* Copyright: Maersk Logistics                                           */    
/* Written by:   AYD                                                     */    
/*                                                                       */    
/* Purpose: Release wave SP for VIVO				                         */  
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
/* 2026-03-09  AYD      1.0   FCR-10825: Vivo - Wave Reverse SP          */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV11]
  @c_Wavekey      NVARCHAR(10)
 ,@b_Success      int            = 1   OUTPUT
 ,@n_Err          int            = 0   OUTPUT
 ,@c_Errmsg       NVARCHAR(250)  = ''  OUTPUT
 AS
 BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue    int = 1
         , @n_starttcnt   int = @@TRANCOUNT         -- Holds the current transaction count
         , @n_debug       int = 0
         , @n_cnt         int = 0

   SET @b_success = 0
   SET @n_Err = 0
   SET @c_Errmsg = ''

   DECLARE @c_Storerkey                NVARCHAR(15)   = ''
         , @c_Facility                 NVARCHAR(5)    = ''
         , @c_TaskType                 NVARCHAR(10)   = ''
         , @c_SourceType               NVARCHAR(30)   = 'mspRLWAV11'
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
         , @c_DocType                  NVARCHAR(1)    = ''
         , @c_LoadKey                  NVARCHAR(10)   = ''
         , @c_Groupkey                 NVARCHAR(10)   = ''
         , @c_Priority                 NVARCHAR(10)   = ''
         , @c_TaskStatus               NVARCHAR(10)   = ''
         , @c_PickMethod               NVARCHAR(10)   = ''
         , @c_LinkTaskToPick_SQL       NVARCHAR(4000) = ''
         , @c_Taskdetailkey            NVARCHAR(10)   = ''
         , @c_ReplenishmentKey         NVARCHAR(10)   = ''
         , @c_ReplenishmentGroup       NVARCHAR(10)   = ''
         , @n_TaskQty                  INT            = 0          
         , @n_PickQty                  INT            = 0          
         , @c_EcomSingleFlag           NVARCHAR(1)    = ''
         , @c_OrderLineNumber          NVARCHAR(20)   = '' 
         , @c_SQL                      NVARCHAR(MAX)  = ''            
         , @c_SQLParams                NVARCHAR(2000) = ''               

         , @CUR_DYNRPL                 CURSOR
         , @CUR_PICK                   CURSOR
   SET @c_SourceType = 'mspRLWAV11'
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
   IF  (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF EXISTS ( SELECT TOP 1 lpd.Loadkey
                  FROM WAVE W (NOLOCK)
                  JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
                  JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                  LEFT OUTER JOIN LOADPLANDETAIL lpd (NOLOCK) ON lpd.Orderkey = O.Orderkey
                  WHERE W.Wavekey = @c_Wavekey
                  AND lpd.Loadkey IS NULL)
      BEGIN
        SET @n_Continue = 3
        SET @n_Err = 83010
        SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Loadplan has not generated yet. (mspRLWAV11)'
      END
   END
   --(SSA01) start -----
   IF  (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN 
      IF EXISTS ( SELECT TOP 1 1
                  FROM WAVE W (NOLOCK)
                  JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
                  JOIN LOADPLANDETAIL lpd (NOLOCK) ON lpd.Orderkey = WD.Orderkey
                  LEFT OUTER JOIN LoadPlanLaneDetail lpld (NOLOCK) ON  lpld.LoadKey = lpd.LoadKey
                                                                   AND lpld.LP_LaneNumber > ''
                                                                   AND lpld.LocationCategory = 'STAGING'
                                                                   AND lpld.Loc> ''
                  WHERE W.Wavekey = @c_Wavekey
                  AND lpld.Loadkey IS NULL
                )
      BEGIN
         SET @n_Continue = 3
         SET @n_Err   = 83020
         SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                      +': Order has not assigned any Outbound Staging yet. (mspRLWAV11)'
      END
   END
   --(SSA01) end -----
   --Create pickdetail Work in progress temporary table
   IF @n_Continue = 1 OR @n_Continue = 2
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
      ,  [AddDate]         [datetime]     NOT NULL DEFAULT (getdate())             --(SSA02)
      ,  [AddWho]          [nvarchar](128)NOT NULL DEFAULT (suser_sname())         --(SSA02)
      ,  [EditDate]        [datetime]     NOT NULL DEFAULT (getdate())             --(SSA02)
      ,  [EditWho]         [nvarchar](128)NOT NULL DEFAULT (suser_sname())         --(SSA02)
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

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF EXISTS ( SELECT 1 FROM TASKDETAIL td (NOLOCK)
                  WHERE td.Wavekey = @c_Wavekey
                  AND td.TaskType IN ('RPF', 'FPK', 'FCP', 'ASTCPK')
                  AND td.[Status] <= '9'
                )
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 83030
         SET @c_Errmsg = 'NSQL' + CONVERT(NCHAR(5), @n_Err) + ': Task has been released. (mspRLWAV11)'
      END
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
         ,@c_Errmsg                = @c_Errmsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
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

   IF @n_Continue IN(1,2)
   BEGIN
      SET @CUR_DYNRPL = CURSOR LOCAL FAST_FORWARD READ_ONLY  FOR
      SELECT rpl.ReplenishmentKey
            ,rpl.ReplenishmentGroup
            ,rpl.Storerkey
            ,rpl.Sku
            ,rpl.Lot
            ,rpl.Fromloc
            ,rpl.Toloc
            ,rpl.ID
            ,rpl.ToId       
            ,rpl.UOM
            ,rpl.Qty
      FROM REPLENISHMENT rpl (NOLOCK)
      WHERE rpl.Wavekey = @c_Wavekey
      AND   rpl.ReplenishmentGroup = 'DYNAMIC'
      AND   rpl.Confirmed NOT IN ('S','Y')
      ORDER BY rpl.ReplenishmentKey
    
      OPEN @CUR_DYNRPL

      FETCH NEXT FROM @CUR_DYNRPL INTO @c_ReplenishmentKey, @c_ReplenishmentGroup
                                    ,  @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ToLoc, @c_FromID, @c_ToID
                                    ,  @c_UOM, @n_Qty

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         SET @c_TaskType = 'RPF'
         SET @c_Priority = '5'
         SET @c_TaskStatus   = '0'
         
         
         EXEC isp_InsertTaskDetail     
              @c_TaskType              = @c_TaskType             
             ,@c_Storerkey             = @c_Storerkey  
             ,@c_Sku                   = @c_Sku  
             ,@c_Lot                   = @c_Lot   
             ,@c_UOM                   = @c_UOM        
             ,@n_UOMQty                = @n_Qty     
             ,@n_Qty                   = @n_Qty        
             ,@c_FromLoc               = @c_Fromloc        
             ,@c_FromID                = @c_FromID       
             ,@c_ToLoc                 = @c_ToLoc         
             ,@c_ToID                  = @c_ToID         
             ,@c_PickMethod            = '?TASKQTY' --?TASKQTY=(Qty available - taskqty)   
             ,@c_Priority              = @c_Priority       
             ,@c_SourcePriority        = '9'        
             ,@c_SourceType            = @c_SourceType 
             ,@c_SourceKey             = @c_Replenishmentkey 
             ,@c_Wavekey               = @c_Wavekey                   
             ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey   
             ,@c_Groupkey              = @c_ReplenishmentGroup  
             ,@c_CallSource            = 'REPLENISHMENT' 
             ,@c_Status                = @c_TaskStatus
             ,@n_QtyReplen             = 0  
             ,@n_PendingMoveIn         = 0  
             ,@c_LinkTaskToReplen      = 'Y'  
             ,@b_Success               = @b_Success   OUTPUT  
             ,@n_Err                   = @n_Err       OUTPUT   
             ,@c_Errmsg                = @c_Errmsg    OUTPUT          
            
         IF @b_Success <> 1   
         BEGIN  
            SET @n_Continue = 3    
         END      
 
         FETCH NEXT FROM @CUR_DYNRPL INTO @c_ReplenishmentKey, @c_ReplenishmentGroup
                                       ,  @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ToLoc, @c_FromID, @c_ToID
                                       ,  @c_UOM, @n_Qty
      END
      CLOSE @CUR_DYNRPL
      DEALLOCATE @CUR_DYNRPL
   END
 
   IF @n_Continue IN(1,2)
   BEGIN
      SET @CUR_PICK = CURSOR LOCAL FAST_FORWARD READ_ONLY  FOR
      SELECT p.Orderkey
            ,p.OrderLineNumber
            ,ISNULL(lpd.Loadkey,'')
            ,p.Storerkey
            ,p.Sku
            ,p.Lot
            ,p.loc
            ,p.ID
            ,p.DropID
            ,p.UOM
            ,Qty = SUM(p.Qty)
      FROM #PickDetail_WIP p
      LEFT OUTER JOIN LOADPLANDETAIL lpd (NOLOCK) ON lpd.orderkey = p.orderkey
      WHERE p.WaveKey = @c_Wavekey
      AND   p.[Status] = '0'
      AND   p.UOM IN ('1','2','3','6')    
      GROUP BY p.Orderkey
            ,  ISNULL(lpd.Loadkey,'')
            ,  p.Storerkey
            ,  p.Sku
            ,  p.Lot
            ,  p.loc
            ,  p.ID
            ,  p.DropID
            ,  p.UOM
            ,  p.OrderLineNumber 
      ORDER BY p.UOM 
            ,  MIN(p.PickDetailKey)
    
      OPEN @CUR_PICK

      FETCH NEXT FROM @CUR_PICK INTO @c_Orderkey, @c_OrderLineNumber, @c_Loadkey
                                    ,@c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID, @c_ToID
                                    ,@c_UOM, @n_Qty
 
      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         --AYD START
         SELECT @c_DocType = O.DocType
         , @c_EcomSingleFlag = ISNULL(TRIM(o.ECOM_SINGLE_FLAG),'')
         FROM ORDERS O (NOLOCK)
         WHERE O.Orderkey = @c_Orderkey
         AND O.Storerkey = @c_Storerkey
         AND O.Facility = @c_Facility
         --AYD END

         SET @c_TaskType = 'FCP'
         SET @c_PickMethod= 'PP'
         SET @c_TaskStatus= '0'
         SET @c_LinkTaskToPick_SQL = 'AND PICKDETAIL.Orderkey = @c_Orderkey AND PICKDETAIL.UOM = @c_UOM' 

         IF @c_UOM = '1'
         BEGIN
            SET @c_TaskType   = 'FPK'
            SET @c_PickMethod = 'FP'
         END

         IF @c_DocType = 'E'  
         BEGIN
            SET @c_TaskType   = 'ASTCPK'
         END

         IF EXISTS ( SELECT 1 FROM TaskDetail td (NOLOCK)
                        WHERE td.WaveKey = @c_Wavekey
                        AND   td.TaskType= 'RPF'
                        AND   td.Groupkey= 'DYNAMIC'
                        AND   td.ToLoc = @c_FromLoc
                        AND   td.ToID  = @c_FromID
                        AND   td.[Status] = '0'
                      )
            BEGIN
               SET @c_TaskStatus= 'H'
            END

         SET @c_ToLoc = ''
         SELECT TOP 1 @c_ToLoc = lpld.Loc  
         FROM LOADPLANDETAIL lpd (NOLOCK) 
         JOIN LoadPlanLaneDetail lpld (NOLOCK) ON  lpld.LoadKey = lpd.LoadKey
                                                AND lpld.ExternOrderKey = lpd.ExternOrderKey
                                                AND lpld.ConsigneeKey = lpd.ConsigneeKey
                                                AND lpld.LP_LaneNumber > ''
         WHERE lpd.Loadkey = @c_Loadkey
         AND   lpld.LocationCategory = 'STAGING'
 
         IF @c_ToLoc = ''
         BEGIN
            SET @n_Continue = 3
            SET @n_Err   = 83020
            SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                         +': To Loc not found. (mspRLWAV11)'
         END

         IF @c_TaskType = 'ASTCPK'
         BEGIN
            SELECT TOP 1 @c_TaskDetailkey = pdw.TaskDetailKey
            FROM TASKDETAIL td (NOLOCK)
            JOIN #PICKDETAIL_WIP pdw (NOLOCK) 
               ON pdw.OrderKey = td.OrderKey 
               AND pdw.OrderLineNumber = td.OrderLineNumber 
               AND pdw.StorerKey = td.Storerkey
            WHERE td.WaveKey = @c_Wavekey
            AND td.Storerkey = @c_Storerkey
            AND td.OrderKey = @c_Orderkey
            AND td.OrderLineNumber = @c_OrderLineNumber
         END 
         ELSE
         BEGIN
            SET @c_TaskDetailkey = ''
         END

         IF @n_Continue IN (1,2)
         BEGIN

            SET @c_Priority = '9'
            SET @c_GroupKey = ''
            IF @c_TaskType = 'ATSCPK'
            BEGIN
               SET @c_GroupKey = @c_Wavekey
            END

            IF @c_DocType = 'E' AND @c_EcomSingleFlag = 'S'
            AND EXISTS (SELECT 1 FROM TaskDetail td 
               WHERE td.Wavekey = @c_Wavekey AND td.TaskType = @c_TaskType 
               AND td.FromLoc = @c_FromLoc AND td.SKU = @c_Sku)
            BEGIN
               UPDATE TaskDetail WITH (ROWLOCK)
               SET Qty = ISNULL(Qty, 0) + ISNULL(@n_Qty, 0)
               WHERE FromLoc = @c_FromLoc 
               AND SKU = @c_Sku
               AND TaskType = @c_TaskType
               AND WaveKey = @c_Wavekey
               AND Storerkey = @c_Storerkey

               IF @@ERROR <> 0  
               BEGIN  
                  SET @n_Continue = 3
                  SET @c_ErrMsg = CONVERT(NVARCHAR(250), @n_Err) 
                  SET @n_Err = 83040
                  SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5), @n_Err) + ': Update TaskDetail Fail. (mspRLWAV11)'
                                 + ' ( SQLSvr MESSAGE=' + RTRIM(@c_ErrMsg) + ' )'
                  GOTO QUIT_SP
               END   
            END
            ELSE
            BEGIN
               EXEC isp_InsertTaskDetail     
                  @c_TaskDetailkey          = @c_TaskDetailkey
                  ,@c_TaskType              = @c_TaskType            
                  ,@c_Storerkey             = @c_Storerkey  
                  ,@c_Sku                   = @c_Sku  
                  ,@c_Lot                   = @c_Lot   
                  ,@c_UOM                   = @c_UOM        
                  ,@n_UOMQty                = @n_Qty     
                  ,@n_Qty                   = @n_Qty        
                  ,@c_FromLoc               = @c_Fromloc        
                  ,@c_FromID                = @c_FromID       
                  ,@c_ToLoc                 = @c_Toloc         
                  ,@c_ToID                  = @c_ToID         
                  ,@c_PickMethod            = @c_PickMethod   
                  ,@c_Priority              = @c_Priority       
                  ,@c_SourcePriority        = '9'        
                  ,@c_SourceType            = @c_SourceType 
                  ,@c_SourceKey             = @c_Wavekey     
                  ,@c_Wavekey               = @c_Wavekey   
                  ,@c_LoadKey               = @c_Loadkey   
                  ,@c_Orderkey              = @c_Orderkey
                  ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey   
                  ,@c_Groupkey              = @c_GroupKey 
                  ,@c_CallSource            = 'WAVE'
                  ,@c_LinkTaskToPick        = 'WIP'
                  ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL 
                  ,@c_Status                = @c_TaskStatus
                  ,@n_QtyReplen             = 0  
                  ,@n_PendingMoveIn         = 0  
                  ,@b_Success               = @b_Success   OUTPUT  
                  ,@n_Err                   = @n_Err       OUTPUT   
                  ,@c_Errmsg                = @c_Errmsg    OUTPUT          
               
               IF @b_Success <> 1   
               BEGIN  
                  SET @n_Continue = 3    
               END      
            END
         END

         FETCH NEXT FROM @CUR_PICK INTO @c_Orderkey, @c_OrderLineNumber, @c_Loadkey
                                       ,@c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID, @c_ToID
                                       ,@c_UOM, @n_Qty
      END
      CLOSE @CUR_PICK
      DEALLOCATE @CUR_PICK
   END

   -----Update pickdetail_WIP work in progress staging table back to pickdetail
   IF @n_Continue = 1 or @n_Continue = 2
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
         ,  @c_Errmsg                = @c_Errmsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

QUIT_SP:
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
         ,  @c_Errmsg                = @c_Errmsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
      DROP TABLE #PICKDETAIL_WIP

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
      execute nsp_logerror @n_Err, @c_Errmsg, 'mspRLWAV11'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
   END
END --sp end
GO
GRANT EXECUTE ON  [dbo].[mspRLWAV11] TO [NSQL]
GO
