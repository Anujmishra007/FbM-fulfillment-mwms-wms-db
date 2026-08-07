SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspRLWAV15                                          */    
/* Creation Date: 2026-08-05                                             */
/* Copyright: Maersk Logistics                                           */    
/* Written by: Alex Keoh                                                 */    
/*                                                                       */    
/* Purpose: FCR-14839 - JCBUSA - Wave Release SP                         */  
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
/* 2026-08-05  AlexK    1.0   FCR-14839 - JCBUSA - Wave Release SP       */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV15]
  @c_Wavekey      NVARCHAR(10)
 ,@b_Success      int            = 1   OUTPUT
 ,@n_Err          int            = 0   OUTPUT
 ,@c_ErrMsg       NVARCHAR(250)  = ''  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue    int = 1
         , @n_StartTcnt   int = @@TRANCOUNT         -- Holds the current transaction count
         , @n_Debug       int = 0
         , @n_Cnt         int = 0

   SET @b_Success = 0
   SET @n_Err = 0
   SET @c_ErrMsg = ''

   DECLARE @c_Storerkey                NVARCHAR(15)   = ''
         , @c_Facility                 NVARCHAR(5)    = ''
         , @c_OrderGroup               NVARCHAR(20)   = ''
         , @c_TaskType                 NVARCHAR(10)   = ''
         , @c_SourceType               NVARCHAR(30)   = 'mspRLWAV15'
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
         , @c_PickDetailKey            NVARCHAR(18)   = ''
         , @c_ReplenishmentKey         NVARCHAR(10)   = ''
         , @c_ReplenishmentGroup       NVARCHAR(10)   = ''
         , @n_TaskQty                  INT            = 0          
         , @n_PickQty                  INT            = 0 
         , @c_OrderLineNumber          NVARCHAR(20)   = '' 
         , @c_RPF_TaskDetailKey        NVARCHAR(10)   = ''
         , @c_RPF_ToLoc                NVARCHAR(10)   = ''
         , @c_FCP_TaskDetailKey        NVARCHAR(10)   = ''
         , @c_FCP_ToLoc                NVARCHAR(10)   = ''               
         , @c_LocAisle                 NVARCHAR(10)   = ''
         , @c_PackKey                  NVARCHAR(10)   = ''
         , @n_PackPallet               FLOAT          = 0
         , @c_SQL                      NVARCHAR(MAX)  = ''            
         , @c_SQLParams                NVARCHAR(2000) = ''               

         , @CUR_DYNRPL                 CURSOR
         , @CUR_RPL                    CURSOR
         , @CUR_PICK                   CURSOR

   SET @c_SourceType = 'mspRLWAV15'
   SET @c_Priority   = '9'
   SET @c_TaskType   = 'RPF'
   SET @c_PickMethod = 'FP'

   --Get Storerkey and facility

   SELECT TOP 1 @c_StorerKey = O.Storerkey,
               @c_Facility = O.Facility,
               @c_OrderGroup = O.OrderGroup
   FROM WAVE W (NOLOCK)
   JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
   JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
   WHERE WD.Wavekey = @c_Wavekey

   --Validation
   IF  (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN 
      --Not allow to process wave contains multiple different order group
      IF EXISTS ( SELECT 1
                  FROM WAVE W (NOLOCK)
                  JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
                  JOIN ORDERS ORD (NOLOCK) ON ORD.Orderkey = WD.Orderkey
                  WHERE W.Wavekey = @c_Wavekey
                  HAVING COUNT(DISTINCT ISNULL(ORD.OrderGroup, '')) > 1
                )
      BEGIN
         SET @n_Continue = 3
         SET @n_Err   = 83020
         SET @c_ErrMsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                      +': Wave contains multiple different OrderGroup. (mspRLWAV15)'
      END
   END

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
   END

   --Create FP & PickingTasks for Kitting Orders (UOM=6/Piece)
   IF @n_Continue IN(1,2) AND @c_OrderGroup = 'KITTING'
   BEGIN
      SET @c_FCP_ToLOC = ''
      SELECT TOP 1 @c_FCP_ToLOC = ISNULL(Long, '')
      FROM CODELKUP (NOLOCK) 
      WHERE ListName = 'JCBTOLOC' 
      AND Code2 = '6'
      AND StorerKey = @c_StorerKey
      AND Short = 'Kitting' 
      
      IF @c_FCP_ToLOC = ''
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83030
         SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': ToLoc for FCP Tasks is not configured.' 
                          + RTRIM(@c_Sku) + '. (mspRLWAV15)'
         GOTO QUIT_SP
      END

      SET @CUR_RPL = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PD.Sku
           , PD.Lot
           , PD.Loc
           , PD.ID
           , PD.UOM
           , SUM(PD.Qty)
           , PACK.PackKey
           , PACK.Pallet
           , Loc.LocAisle
      FROM #PickDetail_WIP PD
      JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
      JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.StorerKey AND PD.Sku = SKU.Sku
      JOIN PACK (NOLOCK) ON SKU.PACKKey = PACK.PackKey
      WHERE PD.WaveKey = @c_WaveKey
      AND (PD.TaskDetailKey IS NULL OR PD.TaskDetailKey = '')
      AND PD.UOM = '6'
      AND LOC.LocationType <> 'PICK'
      GROUP BY PD.Sku
             , PD.Lot
             , PD.Loc
             , PD.ID
             , PD.UOM
             , SUM(PD.Qty)
             , PACK.PackKey
             , PACK.Pallet
             , Loc.LocAisle
      ORDER BY PD.Sku
             , PD.Lot
             , PD.Loc
             , PD.ID
             , PD.UOM
             , SUM(PD.Qty)
             , PACK.PackKey
             , PACK.Pallet
             , Loc.LocAisle

      OPEN @CUR_RPL
      FETCH NEXT FROM @CUR_RPL INTO @c_Sku, @c_Lot, @c_FromLoc, @c_FromID, @c_UOM, @n_Qty, @c_PackKey, @n_PackPallet, @c_LocAisle
      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         --Find pickface location
         SELECT TOP 1 @c_RPF_ToLoc = SL.Loc
         FROM SKUxLOC SL (NOLOCK)
         JOIN LOC L (NOLOCK) 
             ON (L.Facility = @c_Facility AND L.Loc = SL.Loc)
         CROSS APPLY (
             SELECT 
                 SUM(ISNULL(LLI.Qty, 0)) AS TotalQty,
                 SUM(ISNULL(LLI.PendingMoveIn, 0)) AS TotalPendingQty
             FROM LOTxLOCxID LLI (NOLOCK)
             WHERE LLI.StorerKey = SL.StorerKey
               AND LLI.Sku       = SL.Sku
               AND LLI.Loc       = SL.Loc
         ) LLI
         WHERE SL.StorerKey    = @c_StorerKey
           AND SL.Sku          = @c_Sku
           AND SL.LocationType = 'PICK'
           AND ((L.MaxPallet * @n_PackPallet) - (LLI.TotalQty + LLI.TotalPendingQty)) >= @n_PackPallet
         ORDER BY L.Loc

         IF @c_RPF_ToLoc = ''
         BEGIN
            --Find empty pick location as pickface from the same aisle
            SELECT TOP 1 @c_RPF_ToLoc = L.Loc
            FROM LOC L (NOLOCK)
            LEFT JOIN LOTXLOCXID LLI (NOLOCK) ON LLI.Loc = L.Loc
            WHERE L.Facility = @c_Facility
            AND   L.LocationType = 'PICK'
            AND   L.LocAisle = @c_LocAisle
            AND   NOT EXISTS ( SELECT 1
                               FROM SKUXLOC SL (NOLOCK)
                               WHERE SL.StorerKey = @c_Storerkey
                               AND SL.Loc = L.Loc
                               AND SL.LocationType = 'PICK' )
            GROUP BY L.Loc
            HAVING SUM(ISNULL(LLI.Qty,0) + ISNULL(LLI.PendingMoveIn,0)) = 0 
            ORDER BY L.Loc

            IF @c_RPF_ToLoc = ''
            BEGIN
               --Any empty pick location as pickface
               SELECT TOP 1 @c_RPF_ToLoc = L.Loc
               FROM LOC L (NOLOCK)
               LEFT JOIN LOTXLOCXID LLI (NOLOCK) ON LLI.Loc = L.Loc
               WHERE L.Facility = @c_Facility
               AND   L.LocationType = 'PICK'
               AND   NOT EXISTS ( SELECT 1
                                  FROM SKUXLOC SL (NOLOCK)
                                  WHERE SL.StorerKey = @c_Storerkey
                                  AND SL.Loc = L.Loc
                                  AND SL.LocationType = 'PICK' )
               GROUP BY L.Loc
               HAVING SUM(ISNULL(LLI.Qty,0) + ISNULL(LLI.PendingMoveIn,0)) = 0 
               ORDER BY L.Loc
            END
         END

         IF @c_RPF_ToLoc = ''
         BEGIN
            SELECT @n_Continue = 3
            SELECT @n_Err = 83031
            SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Unable find destination loc for Sku ' 
                             + RTRIM(@c_Sku) + '. (mspRLWAV15)'
            GOTO QUIT_SP
         END

         --Create RPF tasks
         SET @c_TaskType   = 'RPF'
         SET @c_Priority   = '3'
         SET @c_TaskStatus = '0'

         EXEC isp_InsertTaskDetail 
              @c_TaskDetailKey         = @c_RPF_TaskDetailKey OUTPUT
             ,@c_TaskType              = @c_TaskType             
             ,@c_Storerkey             = @c_Storerkey  
             ,@c_Sku                   = @c_Sku  
             ,@c_Lot                   = @c_Lot   
             ,@c_UOM                   = '1'        
             ,@n_UOMQty                = @n_PackPallet 
             ,@n_Qty                   = @n_PackPallet        
             ,@c_FromLoc               = @c_FromLoc        
             ,@c_FromID                = @c_FromID       
             ,@c_ToLoc                 = @c_RPF_ToLoc         
             ,@c_ToID                  = @c_FromID         
             ,@c_PickMethod            = '?TASKQTY' --?TASKQTY=(Qty available - taskqty)   
             ,@c_Priority              = @c_Priority          
             ,@c_SourceType            = @c_SourceType 
             ,@c_SourceKey             = '' 
             ,@c_Wavekey               = @c_Wavekey                   
             ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey   
             ,@c_Groupkey              = ''  
             ,@c_CallSource            = 'WAVE' 
             ,@c_Status                = @c_TaskStatus
             ,@n_QtyReplen             = 0  
             ,@n_PendingMoveIn         = 0  
             ,@b_Success               = @b_Success   OUTPUT  
             ,@n_Err                   = @n_Err       OUTPUT   
             ,@c_Errmsg                = @c_Errmsg    OUTPUT       

         IF @b_Success <> 1   
         BEGIN  
            SELECT @n_Continue = 3
            SELECT @n_Err = 83032
            SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Generate RPF TaskDetail Failed: ' 
                             + ISNULL(@c_Errmsg, '') + '. (mspRLWAV15)'
            GOTO QUIT_SP  
         END  

         --Create FCP tasks (Picking)
         SET @c_TaskType   = 'FCP'
         SET @c_Priority   = '5'
         SET @c_TaskStatus = 'S'

         EXEC isp_InsertTaskDetail 
              @c_TaskDetailKey         = @c_FCP_TaskDetailKey OUTPUT
             ,@c_TaskType              = @c_TaskType             
             ,@c_Storerkey             = @c_Storerkey  
             ,@c_Sku                   = @c_Sku  
             ,@c_Lot                   = @c_Lot   
             ,@c_UOM                   = @c_UOM        
             ,@n_UOMQty                = @n_Qty     
             ,@n_Qty                   = @n_Qty        
             ,@c_FromLoc               = @c_RPF_ToLoc        
             ,@c_FromID                = @c_FromID       
             ,@c_ToLoc                 = @c_FCP_ToLOC         
             ,@c_ToID                  = @c_FromID         
             ,@c_PickMethod            = '?TASKQTY' --?TASKQTY=(Qty available - taskqty)   
             ,@c_Priority              = @c_Priority          
             ,@c_SourceType            = @c_SourceType 
             ,@c_SourceKey             = '' 
             ,@c_Wavekey               = @c_Wavekey                   
             ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey   
             ,@c_Groupkey              = ''  
             ,@c_CallSource            = 'WAVE' 
             ,@c_Status                = @c_TaskStatus
             ,@n_QtyReplen             = 0  
             ,@n_PendingMoveIn         = 0  
             ,@c_RefTaskKey            = @c_RPF_TaskDetailKey
             ,@b_Success               = @b_Success   OUTPUT  
             ,@n_Err                   = @n_Err       OUTPUT   
             ,@c_Errmsg                = @c_Errmsg    OUTPUT       

         IF @b_Success <> 1   
         BEGIN  
            SELECT @n_Continue = 3
            SELECT @n_Err = 83033
            SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Generate RPF TaskDetail Failed: ' 
                             + ISNULL(@c_Errmsg, '') + '. (mspRLWAV15)'
            GOTO QUIT_SP  
         END  

         --Update PickDetail.TaskDetailKey

         FETCH NEXT FROM @CUR_RPL INTO @c_Sku, @c_Lot, @c_FromLoc, @c_FromID, @c_UOM, @n_Qty, @c_PackKey, @n_PackPallet, @c_LocAisle
      END
      CLOSE @CUR_RPL
      DEALLOCATE @CUR_RPL

   END
 
   IF @n_Continue IN(1,2)
   BEGIN
      
   END

   --Update pickdetail_WIP work in progress staging table back to pickdetail
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
         ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

QUIT_SP:
   --Delete pickdetail_WIP work in progress staging table
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

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
      DROP TABLE #PICKDETAIL_WIP

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTcnt
         BEGIN
            COMMIT TRAN
         END
      END
      execute nsp_logerror @n_Err, @c_ErrMsg, 'mspRLWAV15'
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTcnt
      BEGIN
         COMMIT TRAN
      END
   END
END --sp end
GO
GRANT EXECUTE ON  [dbo].[mspRLWAV15] TO [NSQL]
GO
