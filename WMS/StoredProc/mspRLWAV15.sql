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

         , @c_PickDetailKeys           NVARCHAR(4000) = ''
         , @c_Lottable11               NVARCHAR(30)   = ''
         , @c_Top1Sku                  NVARCHAR(20)   = ''
         , @n_SkuCount                 INT
         , @c_TD_Sku                   NVARCHAR(20)   = ''
         , @n_PalletQty                INT 
         , @c_Wave_UDF01               NVARCHAR(20)   = ''
         , @c_TD_CaseID                NVARCHAR(20)   = ''

         , @CUR_RPL                    CURSOR
         , @CUR_PICK                   CURSOR

   --Get Storerkey and facility
   SELECT TOP 1 @c_StorerKey = O.Storerkey
              , @c_Facility = O.Facility
              , @c_OrderGroup = O.OrderGroup
              , @c_Wave_UDF01 = ISNULL(W.UserDefine01, '')
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

   --Create RPF & FCP for Kitting Orders (UOM=6/Piece)
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
      SELECT STRING_AGG(PD.PickDetailKey, ',') AS PickDetailKeys
           , PD.Lot
           , PD.Loc
           , PD.ID
           , PD.UOM
           , SUM(PD.Qty)
           , Loc.LocAisle
      FROM #PickDetail_WIP PD
      JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
      WHERE PD.WaveKey = @c_WaveKey
      AND (PD.TaskDetailKey IS NULL OR PD.TaskDetailKey = '')
      AND PD.UOM = '6'
      AND LOC.LocationType <> 'PICK'
      GROUP BY PD.Lot
             , PD.Loc
             , PD.ID
             , PD.UOM
             , Loc.LocAisle
      ORDER BY PD.Lot
             , PD.Loc
             , PD.ID
             , PD.UOM
             , Loc.LocAisle

      OPEN @CUR_RPL
      FETCH NEXT FROM @CUR_RPL INTO @c_PickDetailKeys, @c_Lot, @c_FromLoc, @c_FromID, @c_UOM, @n_Qty, @c_LocAisle
      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         SET @n_SkuCount = 0
         SET @c_Top1Sku = ''
         SET @c_TD_Sku = ''
         SET @c_RPF_ToLoc = ''

         --Get TOP 1 PickDetail.SKU for ToLOC lookup
         SELECT TOP 1 @c_Top1Sku = PD.Sku
         FROM #PickDetail_WIP PD
         WHERE PickDetailKey IN (
            SELECT RTRIM([Value]) 
            FROM STRING_SPLIT(@c_PickDetailKeys, ',')
         )

         SELECT @n_SkuCount = COUNT(DISTINCT Sku)
         FROM LOTxLOCxID (NOLOCK)
         WHERE Loc = @c_FromLoc AND ID = @c_FromID

         SET @c_TD_Sku = CASE WHEN @n_SkuCount > 1 THEN '' ELSE @c_Top1Sku END

         --Find RPF ToLoc

         --1. Check pickface
         SELECT TOP 1 @c_RPF_ToLoc = SL.Loc
         FROM SKUxLOC SL (NOLOCK)
         JOIN LOC L (NOLOCK) 
            ON (L.Facility = @c_Facility AND L.Loc = SL.Loc)
         CROSS APPLY (
            SELECT 
                COUNT(DISTINCT LLI.ID) AS TotalID
            FROM LOTxLOCxID LLI (NOLOCK)
            WHERE LLI.StorerKey = SL.StorerKey
              AND LLI.Sku       = SL.Sku
              AND LLI.Loc       = SL.Loc
         ) LLI
         WHERE SL.StorerKey    = @c_StorerKey
           AND SL.Sku          = @c_Sku
           AND SL.LocationType = 'PICK'
           AND (L.MaxPallet - LLI.TotalID) > 0
         ORDER BY L.Loc

         --2. Check friend location: Location having same SKU where LOC.LocationType = 'PICK'
         IF @c_RPF_ToLoc = ''
         BEGIN
            SELECT TOP 1 @c_RPF_ToLoc = LLI.Loc
            FROM LOTxLOCxID LLI (NOLOCK)
            JOIN LOC L (NOLOCK) ON (L.Facility = @c_Facility AND L.Loc = LLI.Loc)
            CROSS APPLY (
                SELECT COUNT(DISTINCT LLI.ID) AS DistinctIDCount
                FROM LOTxLOCxID LLI (NOLOCK)
                WHERE LLI.Loc = LLI.Loc
            ) CLLI
            WHERE LLI.StorerKey  = @c_StorerKey
              AND LLI.Sku        = @c_Top1Sku
              AND L.LocationType = 'PICK'
              AND (L.MaxPallet - CLLI.DistinctIDCount) > 0
            ORDER BY L.Loc
         END


         --3. Assign empty location in same AISLE
         IF @c_RPF_ToLoc = ''
         BEGIN
            SELECT TOP 1 @c_RPF_ToLoc = L.Loc
            FROM LOC L (NOLOCK)
            LEFT JOIN LOTXLOCXID LLI (NOLOCK) ON LLI.Loc = L.Loc
            WHERE L.Facility = @c_Facility
            AND   L.LocationType = 'PICK'
            AND   L.LocAisle = @c_LocAisle
            GROUP BY L.Loc
            HAVING SUM(ISNULL(LLI.Qty,0) + ISNULL(LLI.PendingMoveIn,0)) = 0 
            ORDER BY L.Loc
         END

         --4. Assign empty location anywhere in facility with LOC.locationtype = 'PICK'
         IF @c_RPF_ToLoc = ''
         BEGIN
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

         IF @c_RPF_ToLoc = ''
         BEGIN
            SELECT @n_Continue = 3
            SELECT @n_Err = 83031
            SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Unable find destination loc for Sku ' 
                             + RTRIM(@c_Sku) + '. (mspRLWAV15)'
            GOTO QUIT_SP
         END

         --Create RPF tasks
         SET @n_PalletQty  = 0
         SET @c_TaskType   = 'RPF'
         SET @c_Priority   = '3'
         SET @c_TaskStatus = '0'
         SET @c_PickMethod = 'FP'

         SELECT @n_PalletQty = SUM(ISNULL(Qty, 0))
         FROM LOTxLOCxID WITH (NOLOCK) 
         WHERE Lot = @c_Lot
         AND   Loc = @c_FromLoc
         AND   ID  = @c_FromID
         AND   StorerKey = @c_StorerKey

         EXEC isp_InsertTaskDetail 
              @c_TaskDetailKey         = @c_RPF_TaskDetailKey OUTPUT
             ,@c_TaskType              = @c_TaskType             
             ,@c_Storerkey             = @c_Storerkey  
             ,@c_Sku                   = @c_TD_Sku  
             ,@c_Lot                   = @c_Lot   
             ,@c_UOM                   = '1'        
             ,@n_UOMQty                = @n_PalletQty 
             ,@n_Qty                   = @n_PalletQty        
             ,@c_FromLoc               = @c_FromLoc        
             ,@c_FromID                = @c_FromID       
             ,@c_ToLoc                 = @c_RPF_ToLoc         
             ,@c_ToID                  = @c_FromID         
             ,@c_PickMethod            = @c_PickMethod
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
         SET @c_PickMethod = 'PP'

         EXEC isp_InsertTaskDetail 
              @c_TaskDetailKey         = @c_FCP_TaskDetailKey OUTPUT
             ,@c_TaskType              = @c_TaskType             
             ,@c_Storerkey             = @c_Storerkey  
             ,@c_Sku                   = @c_TD_Sku  
             ,@c_Lot                   = @c_Lot   
             ,@c_UOM                   = @c_UOM        
             ,@n_UOMQty                = @n_Qty     
             ,@n_Qty                   = @n_Qty        
             ,@c_FromLoc               = @c_RPF_ToLoc        
             ,@c_FromID                = @c_FromID       
             ,@c_ToLoc                 = @c_FCP_ToLOC         
             ,@c_ToID                  = @c_FromID         
             ,@c_PickMethod            = @c_PickMethod
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
         UPDATE #PickDetail_WIP
         SET TaskDetailKey = @c_FCP_TaskDetailKey
         WHERE PickDetailKey IN (
            SELECT RTRIM([Value]) 
            FROM STRING_SPLIT(@c_PickDetailKeys, ',')
         )

         FETCH NEXT FROM @CUR_RPL INTO @c_PickDetailKeys, @c_Lot, @c_FromLoc, @c_FromID, @c_UOM, @n_Qty, @c_LocAisle
      END
      CLOSE @CUR_RPL
      DEALLOCATE @CUR_RPL

   END
   
   --Create FCP for NORMAL Orders (UOM 1,2) & (UOM 6, LocationType = 'PICK')
   IF @n_Continue IN(1,2)
   BEGIN
      SET @c_TaskType   = 'FCP'
      SET @c_Priority   = '5'
      SET @c_TaskStatus = '0'

      SET @CUR_PICK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT STRING_AGG(PD.PickDetailKey, ',') AS PickDetailKeys
           , PD.Lot
           , PD.Loc                            AS FromLoc
           , PD.ID                             AS FromID
           , PD.UOM
           , ISNULL(LA.Lottable11, '')         AS CaseID
           , SUM(PD.Qty)                       AS TotalQty
      FROM #PickDetail_WIP PD
      JOIN ORDERS O (NOLOCK) ON O.OrderKey = PD.OrderKey
      JOIN LOC (NOLOCK) ON LOC.Loc = PD.Loc
      JOIN LOTATTRIBUTE LA (NOLOCK) ON LA.Lot = PD.Lot AND LA.StorerKey = PD.StorerKey AND LA.Sku = PD.Sku
      WHERE PD.WaveKey = @c_WaveKey
      AND ISNULL(PD.TaskDetailKey, '') = ''
      AND (
         PD.UOM = '1' 
         OR ( PD.UOM = '2' AND LA.Lottable11 IS NOT NULL AND LA.Lottable11 <> '' )
         OR ( PD.UOM = '6' AND LOC.LocationType = 'PICK' )
      )
      GROUP BY O.OrderGroup
             , PD.Lot
             , PD.Loc
             , PD.ID
             , PD.UOM
             , ISNULL(LA.Lottable11, '')

      OPEN @CUR_PICK
      FETCH NEXT FROM @CUR_PICK INTO @c_PickDetailKeys, @c_Lot, @c_FromLoc, @c_FromID, @c_UOM, @c_Lottable11, @n_Qty

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1, 2)
      BEGIN
         SET @c_FCP_TaskDetailKey = ''
         SET @c_FCP_ToLOC         = ''

         -- Find ToLoc for FCP task
         IF @c_OrderGroup = 'KITTING'
         BEGIN
            SELECT TOP 1 @c_FCP_ToLOC = ISNULL(Long, '')
            FROM CODELKUP (NOLOCK) 
            WHERE ListName  = 'JCBTOLOC' 
              AND Code2     = @c_UOM
              AND StorerKey = @c_StorerKey
              AND Short     = 'Kitting'
         END
         ELSE
         BEGIN
            SELECT @c_FCP_ToLOC = ISNULL(@c_Wave_UDF01, '')
            
            IF @c_FCP_ToLOC = ''
            BEGIN
               SELECT TOP 1 @c_FCP_ToLOC = ISNULL(Long, '')
               FROM CODELKUP (NOLOCK)
               WHERE ListName  = 'JCBTOLOC'
                 AND StorerKey = @c_StorerKey
                 AND Short     = 'Standard'
            END
         END

         IF @c_FCP_ToLOC = ''
         BEGIN
            SELECT @n_Continue = 3
            SELECT @n_Err = 83040
            SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': ToLoc for FCP Tasks is not configured.' 
                             + RTRIM(@c_Sku) + '. (mspRLWAV15)'
            GOTO QUIT_SP
         END

         --Check if Multi-SKUs in ID.
         SELECT @n_SkuCount = COUNT(DISTINCT Sku) 
         FROM LOTxLOCxID (NOLOCK) 
         WHERE Lot = @c_Lot
         AND   Loc = @c_FromLoc 
         AND   ID  = @c_FromID

         SELECT TOP 1 @c_Top1Sku = Sku 
         FROM #PickDetail_WIP 
         WHERE PickDetailKey IN (
            SELECT RTRIM(value) FROM STRING_SPLIT(@c_PickDetailKeys, ',')
         )

         SET @c_TD_Sku = CASE WHEN @n_SkuCount > 1 THEN '' ELSE @c_Top1Sku END
         SET @c_TD_CaseID  = CASE WHEN @c_UOM = '2' THEN @c_Lottable11 ELSE '' END

         SET @c_PickMethod = CASE WHEN @c_UOM = '1' THEN 'FP' ELSE 'PP' END
         SET @c_ToID       = CASE WHEN @c_UOM = '1' THEN @c_FromID ELSE '' END

         EXEC isp_InsertTaskDetail 
              @c_TaskDetailKey = @c_FCP_TaskDetailKey OUTPUT
             ,@c_TaskType      = @c_TaskType
             ,@c_Storerkey     = @c_StorerKey
             ,@c_Sku           = @c_TD_Sku
             ,@c_Lot           = @c_Lot
             ,@c_UOM           = @c_UOM
             ,@n_UOMQty        = @n_Qty
             ,@n_Qty           = @n_Qty
             ,@c_FromLoc       = @c_FromLoc
             ,@c_FromID        = @c_FromID
             ,@c_ToLoc         = @c_FCP_ToLOC
             ,@c_ToID          = @c_ToID
             ,@c_Caseid        = @c_TD_CaseID
             ,@c_PickMethod    = @c_PickMethod
             ,@c_Priority      = @c_Priority
             ,@c_SourceType    = @c_SourceType
             ,@c_Wavekey       = @c_WaveKey
             ,@c_AreaKey       = '?F'
             ,@c_Status        = @c_TaskStatus
             ,@b_Success       = @b_Success OUTPUT
             ,@n_Err           = @n_Err OUTPUT
             ,@c_Errmsg        = @c_Errmsg OUTPUT
         
         IF @b_Success <> 1   
         BEGIN  
            SELECT @n_Continue = 3
            SELECT @n_Err = 83033
            SELECT @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Generate RPF TaskDetail Failed: ' 
                             + ISNULL(@c_Errmsg, '') + '. (mspRLWAV15)'
            GOTO QUIT_SP  
         END  

         --Update PickDetail.TaskDetailKey
         UPDATE #PickDetail_WIP
         SET TaskDetailKey = @c_FCP_TaskDetailKey
         WHERE PickDetailKey IN (
            SELECT RTRIM([Value]) 
            FROM STRING_SPLIT(@c_PickDetailKeys, ',')
         )

         FETCH NEXT FROM @CUR_PICK INTO @c_PickDetailKeys, @c_Lot, @c_FromLoc, @c_FromID, @c_UOM, @c_Lottable11, @n_Qty
      END
      CLOSE @CUR_PICK
      DEALLOCATE @CUR_PICK
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
