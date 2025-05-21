SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: mspRLWAV07                                          */
/* Creation Date: 15-MAY-2025                                            */
/* Copyright: MAERSK                                                     */
/* Written by:                                                           */
/*                                                                       */
/* Purpose: FCR-4175 VN DIAGEOVN Release Wave for Replenishment and Pick */
/*                                                                       */
/* Called By: wave                                                       */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 15-MAY-2025 NJOW     1.0   Initial version                            */
/*************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV07]
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

    DECLARE @c_Storerkey              NVARCHAR(15)
            ,@c_Facility              NVARCHAR(5)
            ,@c_TaskType              NVARCHAR(10)
            ,@c_SourceType            NVARCHAR(30)
            ,@c_Priority              NVARCHAR(10)
            ,@c_Toloc                 NVARCHAR(10)
            ,@c_PickMethod            NVARCHAR(10)
            ,@c_Message03             NVARCHAR(20)
            ,@c_LinkTaskToPick_SQL    NVARCHAR(4000)
            ,@c_DropID                NVARCHAR(20)
            ,@c_Sku                   NVARCHAR(20)
            ,@c_Lot                   NVARCHAR(10)
            ,@c_FromLoc               NVARCHAR(10)
            ,@c_ID                    NVARCHAR(18)
            ,@c_ToID                  NVARCHAR(18)
            ,@n_Qty                   INT
            ,@c_UOM                   NVARCHAR(10)
            ,@n_UOMQty                INT
            ,@c_SourcePriority        NVARCHAR(10)
            ,@n_UCCQty                INT
            ,@c_PDPickMethod          NVARCHAR(10)
            ,@c_Status                NVARCHAR(10) = '0'
            ,@c_PnDLoc                NVARCHAR(10) = ''
            ,@c_FinalLoc              NVARCHAR(10) = ''
            ,@C_Lottable03            NVARCHAR(18) = ''
            ,@dt_Lottable04           DATETIME
            ,@c_Lottable08            NVARCHAR(30) = ''
            ,@c_Putawayzone           NVARCHAR(10) = ''

    SET @c_SourceType = 'mspRLWAV07'
    SET @c_Priority = '9'
    SET @c_TaskType = 'RPF'
    SET @c_PickMethod = 'PP'

     
    CREATE TABLE #TMP_INV (Loc NVARCHAR(10), 
                           Sku NVARCHAR(20), 
                           Lot NVARCHAR(10),
                           Qty INT)    
                           
    -----Wave Validation-----
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       IF NOT EXISTS (SELECT 1
                      FROM WAVEDETAIL WD (NOLOCK)
                      JOIN PICKDETAIL PD (NOLOCK) ON WD.Orderkey = PD.Orderkey
                      JOIN LOC (NOLOCK) ON PD.LOC = LOC.Loc
                      LEFT JOIN TASKDETAIL TD (NOLOCK) ON PD.Taskdetailkey = TD.Taskdetailkey AND TD.Sourcetype = @c_SourceType AND TD.Tasktype IN('FCP','RPF')
                      WHERE WD.Wavekey = @c_Wavekey
                      AND PD.Status = '0'
                      AND PD.UOM IN('2','7')
                      AND LOC.LocationType = 'BULK'
                      AND TD.Taskdetailkey IS NULL
                     )
       BEGIN
          SELECT @n_continue = 3
          SELECT @n_err = 83000
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Nothing to release from bulk (UOM 2 or 7). (mspRLWAV07)'
       END
    END

    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
        IF EXISTS (SELECT 1 FROM TASKDETAIL TD (NOLOCK)
                   WHERE TD.Wavekey = @c_Wavekey
                   AND TD.Sourcetype = @c_SourceType
                   AND TD.Tasktype IN('FCP','RPF'))
        BEGIN
          SELECT @n_continue = 3
          SELECT @n_err = 83010
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': This Wave has beed released. (mspRLWAV07)'
        END
    END

    IF @@TRANCOUNT = 0
       BEGIN TRAN

    -----Get Storerkey, facility
    IF  (@n_continue = 1 OR @n_continue = 2)
    BEGIN
        SELECT TOP 1 @c_Storerkey = O.Storerkey,
                     @c_Facility = O.Facility
        FROM WAVE W (NOLOCK)
        JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
        JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
        AND W.Wavekey = @c_Wavekey                   
    END

    --Create pickdetail Work in progress temporary table
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       CREATE TABLE #PickDetail_WIP(
          [PickDetailKey] [nvarchar](18) NOT NULL PRIMARY KEY,
          [CaseID] [nvarchar](20) NOT NULL DEFAULT (' '),
          [PickHeaderKey] [nvarchar](18) NOT NULL,
          [OrderKey] [nvarchar](10) NOT NULL,
          [OrderLineNumber] [nvarchar](5) NOT NULL,
          [Lot] [nvarchar](10) NOT NULL,
          [Storerkey] [nvarchar](15) NOT NULL,
          [Sku] [nvarchar](20) NOT NULL,
          [AltSku] [nvarchar](20) NOT NULL DEFAULT (' '),
          [UOM] [nvarchar](10) NOT NULL DEFAULT (' '),
          [UOMQty] [int] NOT NULL DEFAULT ((0)),
          [Qty] [int] NOT NULL DEFAULT ((0)),
          [QtyMoved] [int] NOT NULL DEFAULT ((0)),
          [Status] [nvarchar](10) NOT NULL DEFAULT ('0'),
          [DropID] [nvarchar](20) NOT NULL DEFAULT (''),
          [Loc] [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN'),
          [ID] [nvarchar](18) NOT NULL DEFAULT (' '),
          [PackKey] [nvarchar](10) NULL DEFAULT (' '),
          [UpdateSource] [nvarchar](10) NULL DEFAULT ('0'),
          [CartonGroup] [nvarchar](10) NULL,
          [CartonType] [nvarchar](10) NULL,
          [ToLoc] [nvarchar](10) NULL  DEFAULT (' '),
          [DoReplenish] [nvarchar](1) NULL DEFAULT ('N'),
          [ReplenishZone] [nvarchar](10) NULL DEFAULT (' '),
          [DoCartonize] [nvarchar](1) NULL DEFAULT ('N'),
          [PickMethod] [nvarchar](1) NOT NULL DEFAULT (' '),
          [WaveKey] [nvarchar](10) NOT NULL DEFAULT (' '),
          [EffectiveDate] [datetime] NOT NULL DEFAULT (getdate()),
          [AddDate] [datetime] NOT NULL DEFAULT (getdate()),
          [AddWho] [nvarchar](128) NOT NULL DEFAULT (suser_sname()),
          [EditDate] [datetime] NOT NULL DEFAULT (getdate()),
          [EditWho] [nvarchar](128) NOT NULL DEFAULT (suser_sname()),
          [TrafficCop] [nvarchar](1) NULL,
          [ArchiveCop] [nvarchar](1) NULL,
          [OptimizeCop] [nvarchar](1) NULL,
          [ShipFlag] [nvarchar](1) NULL DEFAULT ('0'),
          [PickSlipNo] [nvarchar](10) NULL,
          [TaskDetailKey] [nvarchar](10) NULL,
          [TaskManagerReasonKey] [nvarchar](10) NULL,
          [Notes] [nvarchar](4000) NULL,
          [MoveRefKey] [nvarchar](10) NULL DEFAULT (''),
          [WIP_Refno] [nvarchar](30) NULL DEFAULT (''),
          [Channel_ID] [bigint] NULL DEFAULT ((0)))

       CREATE INDEX PDWIP_Pickdetailkey ON #PickDetail_WIP (Pickdetailkey)
       CREATE INDEX PDWIP_SKU ON #PickDetail_WIP (Storerkey, Sku)
       CREATE INDEX PDWIP_UOM ON #PickDetail_WIP (UOM)
       CREATE INDEX PDWIP_LLI ON #PickDetail_WIP (Lot, Loc, ID)
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

    --Create full case single order from bulk pick to Packstation (UOM = 2)
    IF @n_continue IN(1,2)
    BEGIN
       DECLARE cur_fullucc CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
          SELECT PD.Storerkey, PD.Sku, MAX(PD.Lot) AS Lot, PD.Loc, PD.ID, SUM(PD.Qty) AS Qty,
                 PD.UOM, SUM(PD.UOMQty) AS UOMQty, PD.DropID, PZ.Outloc
          FROM WAVEDETAIL WD (NOLOCK)
          JOIN WAVE W (NOLOCK) ON WD.Wavekey = W.Wavekey
          JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
          JOIN #PICKDETAIL_WIP PD (NOLOCK) ON O.Orderkey = PD.Orderkey
          --JOIN UCC (NOLOCK) ON PD.Dropid = UCC.UCCNo AND PD.Storerkey = UCC.Storerkey AND PD.Sku = UCC.Sku          
          JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
          JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
          JOIN PICKZONE PZ (NOLOCK) ON LOC.PickZone = PZ.PickZone
          WHERE WD.Wavekey = @c_Wavekey
          AND PD.Status = '0'
          AND PD.WIP_RefNo = @c_SourceType
          AND PD.UOM = '2'
          AND LOC.LocationType = 'BULK'
          GROUP BY PD.Storerkey, PD.Sku, PD.Loc, PD.ID, PD.UOM, PD.DropID, LOC.LogicalLocation, PZ.OutLoc
          ORDER BY Loc.LogicalLocation, PD.Loc

       OPEN cur_fullucc

       FETCH NEXT FROM cur_fullucc INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @n_UOMQty, @c_DropID, @c_ToLoc

       WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
       BEGIN
           IF @c_UOM = '2'
           BEGIN
              SET @c_TaskType = 'FCP'
              SET @c_PickMethod = 'PP'
              SET @c_Message03 = 'FULLUCC'
              SET @c_LinkTaskToPick_SQL = 'AND PICKDETAIL.UOM = @c_UOM AND PICKDETAIL.DropID = @c_DropID '
              SET @c_Priority = '5'
              SET @c_SourcePriority = '5'

              EXEC isp_InsertTaskDetail
                  @c_TaskType              = @c_TaskType
                 ,@c_Storerkey             = @c_Storerkey
                 ,@c_Sku                   = @c_Sku
                 ,@c_Lot                   = @c_Lot
                 ,@c_UOM                   = @c_UOM
                 ,@n_UOMQty                = @n_Qty
                 ,@n_Qty                   = @n_Qty
                 ,@c_FromLoc               = @c_Fromloc
                 ,@c_LogicalFromLoc        = @c_FromLoc
                 ,@c_FromID                = @c_ID
                 ,@c_ToLoc                 = @c_ToLoc
                 ,@c_LogicalToLoc          = @c_ToLoc
                 ,@c_ToID                  = ''
                 ,@c_CaseID                = @c_DropID  
                 ,@c_DropID                = @c_DropID  
                 ,@c_PickMethod            = @c_PickMethod
                 ,@c_Priority              = @c_Priority
                 ,@c_SourcePriority        = @c_SourcePriority
                 ,@c_SourceType            = @c_SourceType
                 ,@c_SourceKey             = @c_Wavekey
                 ,@c_OrderKey              = ''
                 ,@c_WaveKey               = @c_Wavekey
                 ,@c_Loadkey               = ''
                 ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey
                 ,@c_Message03             = @c_Message03
                 ,@c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip
                 ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL
                 ,@c_SplitTaskByCase       ='N'   -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0.
                 ,@c_WIP_RefNo             = @c_SourceType
                 ,@b_Success               = @b_Success OUTPUT
                 ,@n_Err                   = @n_err OUTPUT
                 ,@c_ErrMsg                = @c_errmsg OUTPUT

              IF @b_Success <> 1
              BEGIN
                 SELECT @n_continue = 3
              END
           END

          FETCH NEXT FROM cur_fullucc INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @n_UOMQty, @c_DropID, @c_ToLoc
       END
       CLOSE cur_fullucc
       DEALLOCATE cur_fullucc
    END

    --Create partial UCC case from bulk replen to Pick (PnD) (UOM = 7)
    IF @n_continue IN(1,2)
    BEGIN
       DECLARE cur_replenucc CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
          SELECT PD.Storerkey, PD.Sku, MAX(PD.Lot) AS Lot, PD.Loc, PD.ID, SUM(PD.Qty) AS Qty,
                 PD.UOM, SUM(PD.UOMQty) AS UOMQty, PD.DropID, UCC.Qty, 
                 MAX(CASE WHEN PD.PickMethod = 'C' THEN PD.PickMethod ELSE '' END),
                 PZ.InLoc AS PnD, SKU.Putawayzone
          FROM WAVEDETAIL WD (NOLOCK)
          JOIN WAVE W (NOLOCK) ON WD.Wavekey = W.Wavekey
          JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
          JOIN #PICKDETAIL_WIP PD (NOLOCK) ON O.Orderkey = PD.Orderkey
          JOIN UCC (NOLOCK) ON PD.Dropid = UCC.UCCNo AND PD.Storerkey = UCC.Storerkey AND PD.Sku = UCC.Sku
          JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
          JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
          JOIN PICKZONE PZ (NOLOCK) ON LOC.Pickzone = PZ.Pickzone
          WHERE WD.Wavekey = @c_Wavekey
          AND PD.Status = '0'
          AND PD.WIP_RefNo = @c_SourceType
          AND PD.UOM = '7'
          AND LOC.LocationType = 'BULK'
          GROUP BY PD.Storerkey, PD.Sku, PD.Loc, PD.ID, PD.UOM, PD.DropID, LOC.LogicalLocation, UCC.Qty, PZ.InLoc, SKU.Putawayzone
          ORDER BY Loc.LogicalLocation, PD.Loc

       OPEN cur_replenucc

       FETCH NEXT FROM cur_replenucc INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @n_UOMQty, @c_DropID, @n_UCCQty, 
                                          @c_PDPickMethod, @c_PnDLoc, @c_Putawayzone

       WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
       BEGIN
           SET @c_TaskType = 'RPF'
           SET @c_PickMethod = 'PP'
           SET @c_LinkTaskToPick_SQL = 'AND PICKDETAIL.UOM = @c_UOM AND PICKDETAIL.DropID = @c_CaseID '
           SET @c_Priority = '5'
           SET @c_SourcePriority = '5'
           SET @c_ToLoc = @c_PnDLoc                      
           SET @c_Message03 = 'REPLENUCC'  
           SET @c_FinalLoc = ''
           
           SELECT @C_Lottable03 = LA.Lottable03,
                  @dt_Lottable04 = LA.Lottable04,
                  @c_Lottable08 = LA.Lottable08
           FROM LOTATTRIBUTE LA (NOLOCK)
           WHERE LA.Lot = @c_Lot                         
           
           TRUNCATE TABLE #TMP_INV

           INSERT INTO #TMP_INV (Loc, Sku, Qty, Lot)
           SELECT LOC.Loc, SKU.Sku, SUM((LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn), LLI.Lot
           FROM LOC (NOLOCK)
           JOIN LOTXLOCXID LLI (NOLOCK) ON LOC.Loc = LLI.Loc
		       JOIN SKU (NOLOCK) ON LLI.Storerkey = SKU.Storerkey AND LLI.Sku = SKU.Sku
           WHERE LOC.Facility = @c_Facility
           AND LOC.LocationType = 'PICK'
           AND LLI.Storerkey = @c_Storerkey
           AND (LLI.Qty - LLI.QtyPicked) + LLI.PendingMoveIn > 0
           AND LOC.Putawayzone = @c_Putawayzone
           GROUP BY LOC.Loc, SKU.Sku, LLI.Lot           
               
           IF @c_FinalLoc = ''
           BEGIN              	           	               
           	  SELECT TOP 1 @c_FinalLoc = I.Loc 
           	  FROM #TMP_INV I
           	  JOIN LOTATTRIBUTE LA (NOLOCK) ON I.Lot = LA.Lot
           	  WHERE I.Sku = @c_Sku
           	  AND LA.Lottable03 = @C_Lottable03
           	  AND LA.Lottable04 = @dt_Lottable04
           	  AND LA.Lottable08 = @c_Lottable08           	  
           	  ORDER BY I.Loc
           END                                 
           
           IF @c_FinalLoc = ''
           BEGIN
           	  SELECT TOP 1 @c_FinalLoc = LOC.Loc
           	  FROM LOC (NOLOCK)
              WHERE LOC.Facility = @c_Facility
              AND LOC.LocationType = 'PICK'
              AND LOC.Loc NOT IN (SELECT Loc FROM #TMP_INV)
              AND LOC.Putawayzone = @c_Putawayzone
              ORDER BY LOC.Loc
           END           
           
           IF @c_FinalLoc = ''   
           BEGIN
              SELECT @n_continue = 3
              SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 83020   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
              SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Unable to find Pick loc for Sku ' + RTRIM(@c_Sku)  + ' (mspRLWAV07)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
           END	           	               
                                                                                
           IF @n_continue IN(1,2)
           BEGIN                    
              EXEC isp_InsertTaskDetail
                  @c_TaskType              = @c_TaskType
                 ,@c_Storerkey             = @c_Storerkey
                 ,@c_Sku                   = @c_Sku
                 ,@c_Lot                   = @c_Lot
                 ,@c_UOM                   = @c_UOM
                 ,@n_UOMQty                = @n_UCCQty
                 ,@n_Qty                   = @n_UCCQty
                 ,@c_FromLoc               = @c_Fromloc
                 ,@c_LogicalFromLoc        = @c_FromLoc
                 ,@c_FromID                = @c_ID
                 ,@c_ToLoc                 = @c_ToLoc
                 ,@c_LogicalToLoc          = @c_ToLoc
                 ,@c_ToID                  = ''
                 ,@c_FinalLoc              = @c_FinalLoc
                 ,@c_CaseID                = @c_DropID  
                 ,@c_DropID                = ''  
                 ,@c_PickMethod            = @c_PickMethod
                 ,@c_Priority              = @c_Priority
                 ,@c_SourcePriority        = @c_SourcePriority
                 ,@c_SourceType            = @c_SourceType
                 ,@c_SourceKey             = @c_Wavekey
                 ,@c_OrderKey              = ''
                 ,@c_WaveKey               = @c_Wavekey
                 ,@c_Loadkey               = ''
                 ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey
                 ,@c_Message03             = @c_Message03
                 ,@n_SystemQty             = @n_Qty 
                 ,@c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip
                 ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL
                 ,@c_ReservePendingMoveIn  = 'Y'
                 ,@c_SplitTaskByCase       = 'N'   -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0.
                 ,@c_WIP_RefNo             = @c_SourceType
                 ,@b_Success               = @b_Success OUTPUT
                 ,@n_Err                   = @n_err OUTPUT
                 ,@c_ErrMsg                = @c_errmsg OUTPUT
              
              IF @b_Success <> 1
              BEGIN
                 SELECT @n_continue = 3
              END
           END

           FETCH NEXT FROM cur_replenucc INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @n_UOMQty, @c_DropID, @n_UCCQty, 
                                              @c_PDPickMethod, @c_PnDLoc, @c_Putawayzone
       END
       CLOSE cur_replenucc
       DEALLOCATE cur_replenucc
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
    /*
    IF @n_continue = 1 or @n_continue = 2
    BEGIN
       EXEC isp_CreatePickSlip
            @c_Wavekey = @c_Wavekey
           ,@c_ConsolidateByLoad = 'N'
           ,@c_LinkPickSlipToPick = 'Y'  --Y=Update pickslipno to pickdetail.pickslipno
           ,@c_AutoScanIn = 'N'  --Y=Auto scan in the pickslip N=Not auto scan in
           ,@b_Success = @b_Success OUTPUT
           ,@n_Err = @n_err OUTPUT
           ,@c_ErrMsg = @c_errmsg OUTPUT

       IF @b_Success = 0
          SELECT @n_continue = 3
    END
    */

    -----Update Wave Status-----
    IF @n_continue = 1 or @n_continue = 2
    BEGIN
       UPDATE WAVE WITH (ROWLOCK)
          --SET STATUS = '1' -- Released        
          SET TMReleaseFlag = 'Y'               
           ,  TrafficCop = NULL                 
           ,  EditWho = SUSER_SNAME()           
           ,  EditDate= GETDATE()               
       WHERE WAVEKEY = @c_wavekey
       SELECT @n_err = @@ERROR
       IF @n_err <> 0
       BEGIN
          SELECT @n_continue = 3
          SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 83030   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update on wave Failed (mspRLWAV07)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
       END
    END

RETURN_SP:
    IF @n_continue = 1 or @n_continue = 2
    BEGIN
       -----Delete pickdetail_WIP work in progress staging table
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

    IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
       DROP TABLE #PICKDETAIL_WIP

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
       execute nsp_logerror @n_err, @c_errmsg, "mspRLWAV07"
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
GRANT EXECUTE ON  [dbo].[mspRLWAV07] TO [NSQL]
GO
