SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: mspRLWAV08                                          */
/* Creation Date: 27-Oct-2025                                            */
/* Copyright: MAERSK                                                     */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-8650 Sweden - Maersk WMS v2 - SCE Task Release           */
/*                                                                       */
/* Called By: Wave                                                       */
/*                                                                       */
/* Github Version: 1.0                                                   */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 27-Oct-2025 WLChooi  1.0   Initial version                            */
/*************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV08]
      @c_Wavekey      NVARCHAR(10)
    , @b_Success      INT        OUTPUT
    , @n_Err          INT        OUTPUT
    , @c_Errmsg       NVARCHAR(250)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue INT,
           @n_starttcnt INT,         -- Holds the current transaction count
           @n_debug INT,
           @n_cnt INT

   SELECT @n_debug = @n_Err
   SELECT @n_starttcnt = @@TRANCOUNT, @n_Continue = 1, @b_Success = 0, @n_Err = 0, @c_Errmsg = '', @n_cnt = 0

   DECLARE @c_Storerkey            NVARCHAR(15)
         , @c_Facility             NVARCHAR(5)
         , @c_TaskType             NVARCHAR(10)
         , @c_SourceType           NVARCHAR(30)
         , @c_Priority             NVARCHAR(10)
         , @c_PickMethod           NVARCHAR(10)
         , @c_LinkTaskToPick_SQL   NVARCHAR(4000)
         , @c_Sku                  NVARCHAR(20)
         , @c_Lot                  NVARCHAR(10)
         , @c_FromLoc              NVARCHAR(10)
         , @c_ID                   NVARCHAR(18)
         , @n_Qty                  INT
         , @c_UOM                  NVARCHAR(10)
         , @c_SourcePriority       NVARCHAR(10)
         , @c_WaveStatus           NVARCHAR(10) = ''
         , @c_TMReleaseFlag        NVARCHAR(1)  = ''
         , @c_ToLoc                NVARCHAR(10) = ''
         , @c_Orderkey             NVARCHAR(10) = ''
         , @n_UOMQty               INT

   SET @c_SourceType = 'mspRLWAV08'
   
   -----Wave Validation-----
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      SELECT @c_WaveStatus = W.[Status]
           , @c_TMReleaseFlag = W.TMReleaseFlag
           , @c_ToLoc = TRIM(ISNULL(W.UserDefine01, ''))
           , @c_Storerkey = O.StorerKey
           , @c_Facility = O.Facility
      FROM WAVE W WITH (NOLOCK)
      JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
      JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
      WHERE W.Wavekey = @c_Wavekey

      IF EXISTS ( SELECT 1 
                  FROM TASKDETAIL TD (NOLOCK)
                  WHERE TD.Wavekey = @c_Wavekey
                  AND TD.Sourcetype = @c_SourceType
                  AND TD.Tasktype = 'FPK' )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83000
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Wave has been released. (mspRLWAV08)'
      END

      IF @c_WaveStatus < '2'
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83005
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Wave is not fully allocated. (mspRLWAV08)'
      END

      IF ISNULL(@c_ToLoc, '') = ''
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83010
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': ToLoc (Wave.Userdefine01) not assigned. (mspRLWAV08)'
      END

      IF NOT EXISTS ( SELECT 1
                      FROM LOC L WITH (NOLOCK)
                      WHERE L.Facility = @c_Facility
                      AND L.Loc = @c_ToLoc )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83015
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Invalid ToLoc: ' + @c_ToLoc + '. (mspRLWAV08)'
      END
   END

   IF @n_debug = 0
   BEGIN
      WHILE @@TRANCOUNT > 0
         COMMIT TRAN

      IF @@TRANCOUNT = 0
         BEGIN TRAN
   END

   --Create pickdetail Work in progress temporary table
   IF @n_Continue = 1 OR @n_Continue = 2
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
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      EXEC isp_CreatePickdetail_WIP
           @c_Loadkey               = ''
          ,@c_Wavekey               = @c_Wavekey
          ,@c_WIP_RefNo             = @c_SourceType
          ,@c_PickCondition_SQL     = ''
          ,@c_Action                = 'I'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
          ,@c_RemoveTaskdetailkey   = 'Y'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
          ,@b_Success               = @b_Success OUTPUT
          ,@n_Err                   = @n_Err     OUTPUT
          ,@c_Errmsg                = @c_Errmsg  OUTPUT

       IF @b_Success <> 1
       BEGIN
          SET @n_Continue = 3
       END
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      DECLARE CUR_ID CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PD.Storerkey, PD.Sku, MAX(PD.Lot) AS Lot, PD.Loc, PD.ID, SUM(PD.Qty) AS Qty
           , PD.UOM, PD.OrderKey
      FROM #PICKDETAIL_WIP PD
      JOIN LOC L (NOLOCK) ON L.Loc = PD.Loc
      WHERE PD.Wavekey = @c_Wavekey
      AND PD.[Status] = '0'
      AND PD.ID <> ''
      AND PD.WIP_RefNo = @c_SourceType
      GROUP BY PD.Storerkey, PD.Sku, PD.Loc, PD.ID, PD.UOM, L.LogicalLocation, PD.OrderKey
      ORDER BY L.LogicalLocation, PD.Loc

      OPEN CUR_ID

      FETCH NEXT FROM CUR_ID INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @c_Orderkey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         SET @c_TaskType = 'FPK'
         SET @c_PickMethod = 'FP'
         SET @c_LinkTaskToPick_SQL = 'AND PICKDETAIL.UOM = @c_UOM '
         SET @c_Priority = '5'
         SET @c_SourcePriority = '5'
         SET @n_UOMQty = 0

         --Full LPN allocated (UOM = 1)
         IF @c_UOM = '1'
         BEGIN
            SET @n_UOMQty = @n_Qty
         END
         ELSE   --Partial LPN allocated (UOM <> 1)
         BEGIN
            SELECT @n_UOMQty = Qty
            FROM ID (NOLOCK)
            WHERE ID.ID = @c_ID
         END
         
         EXEC isp_InsertTaskDetail
              @c_TaskType              = @c_TaskType
            , @c_Storerkey             = @c_Storerkey
            , @c_Sku                   = @c_Sku
            , @c_Lot                   = @c_Lot
            , @c_UOM                   = '1'
            , @n_UOMQty                = @n_UOMQty
            , @n_Qty                   = @n_Qty
            , @c_FromLoc               = @c_FromLoc
            , @c_LogicalFromLoc        = @c_FromLoc
            , @c_FromID                = @c_ID
            , @c_ToLoc                 = @c_ToLoc
            , @c_LogicalToLoc          = @c_ToLoc
            , @c_ToID                  = @c_ID
            , @c_PickMethod            = @c_PickMethod
            , @c_Priority              = @c_Priority
            , @c_SourcePriority        = @c_SourcePriority
            , @c_SourceType            = @c_SourceType
            , @c_SourceKey             = @c_Wavekey
            , @c_OrderKey              = @c_Orderkey
            , @c_Wavekey               = @c_Wavekey
            , @n_SystemQty             = @n_UOMQty
            , @c_FinalLOC              = @c_ToLoc
            , @c_FinalID               = @c_ID
            , @n_QtyReplen             = @n_UOMQty
            , @c_AreaKey               = '?F'  -- ?F=Get from location areakey
            , @c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip
            , @c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL
            , @c_SplitTaskByCase       = 'N'   -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0.
            , @c_WIP_RefNo             = @c_SourceType
            , @b_Success               = @b_Success OUTPUT
            , @n_Err                   = @n_Err OUTPUT
            , @c_Errmsg                = @c_Errmsg OUTPUT
         
         IF @b_Success <> 1
         BEGIN
            SELECT @n_Continue = 3
         END

         FETCH NEXT FROM CUR_ID INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @c_Orderkey
      END
      CLOSE CUR_ID
      DEALLOCATE CUR_ID
   END

   -----Update pickdetail_WIP work in progress staging table back to pickdetail
   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
      EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
           ,@c_Wavekey               = @c_Wavekey
           ,@c_WIP_RefNo             = @c_SourceType
           ,@c_PickCondition_SQL     = ''
           ,@c_Action                = 'U'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
           ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
           ,@b_Success               = @b_Success OUTPUT
           ,@n_Err                   = @n_Err     OUTPUT
           ,@c_Errmsg                = @c_Errmsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   -----Update Wave Status-----
   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
      UPDATE WAVE WITH (ROWLOCK)
         SET TMReleaseFlag = 'Y'               
          ,  TrafficCop = NULL                 
          ,  EditWho = dbo.fnc_GetUserName()
          ,  EditDate= dbo.fnc_GetDate()
      WHERE WaveKey = @c_Wavekey

      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 83040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update on Wave Failed (mspRLWAV08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END
   END

   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
      -----Delete pickdetail_WIP work in progress staging table
      EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
           ,@c_Wavekey               = @c_Wavekey
           ,@c_WIP_RefNo             = @c_SourceType
           ,@c_PickCondition_SQL     = ''
           ,@c_Action                = 'D'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
           ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
           ,@b_Success               = @b_Success OUTPUT
           ,@n_Err                   = @n_Err     OUTPUT
           ,@c_Errmsg                = @c_Errmsg  OUTPUT
   
      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   IF (XACT_STATE()) = -1
   BEGIN
      IF @@TRANCOUNT > 0 
      BEGIN
         ROLLBACK TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_starttcnt
      BEGIN TRAN

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
      DROP TABLE #PICKDETAIL_WIP

   IF CURSOR_STATUS('LOCAL', 'CUR_ID') IN (0 , 1)
   BEGIN
      CLOSE CUR_ID
      DEALLOCATE CUR_ID   
   END

   IF @n_Continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_Success = 0
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
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'mspRLWAV08'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END --sp end
GO
GRANT EXECUTE ON  [dbo].[mspRLWAV08] TO [NSQL]
GO