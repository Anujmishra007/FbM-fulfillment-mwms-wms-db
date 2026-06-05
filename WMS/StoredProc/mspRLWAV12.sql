SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/  
/* Stored Procedure: mspRLWAV12                                          */  
/* Creation Date: 05-Jun-2026                                            */  
/* Copyright: Maersk                                                     */  
/* Written by: WLChooi                                                   */  
/*                                                                       */  
/* Purpose: FCR-13582 Australia - MWMS V2 CASTLERY PTE LTD - Release Wave*/  
/*          Release pick tasks by UOM:                                   */  
/*          UOM 1: PALLET PICKS (FPK)                                    */  
/*          UOM 2: CASE PICKS (FCP), SPLIT PARTIAL CARTON AS PIECE PICKS */  
/*          UOM 6/7: PIECE PICKS (FPP)                                   */  
/*          Modify from ispRLWVAU1                                       */  
/*                                                                       */  
/* Called By: Wave                                                       */  
/*                                                                       */  
/* Version: 1.0                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */  
/* 05-Jun-2026 WLChooi  1.0   Initial Version                            */  
/*************************************************************************/   
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV12]
   @c_Wavekey NVARCHAR(10)
 , @b_Success INT           OUTPUT
 , @n_err     INT           OUTPUT
 , @c_errmsg  NVARCHAR(250) OUTPUT 
AS  
BEGIN
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @n_Continue  INT
         , @n_starttcnt INT -- Holds the current transaction count  
         , @n_debug     INT
         , @n_cnt       INT
 
   SELECT @n_debug = ISNULL(@n_err, 0)
   SELECT @n_starttcnt = @@TRANCOUNT, @n_Continue = 1, @b_success = 0, @n_err = 0, @c_errmsg = '', @n_cnt = 0   
 
   DECLARE @c_Storerkey             NVARCHAR(15)  
         , @c_Facility              NVARCHAR(5)  
         , @c_TaskType              NVARCHAR(10)  
         , @c_SourceType            NVARCHAR(30)  
         , @c_WaveType              NVARCHAR(10)  
         , @c_Sku                   NVARCHAR(20)  
         , @c_Lot                   NVARCHAR(10)  
         , @c_FromLoc               NVARCHAR(10)  
         , @c_ID                    NVARCHAR(18)  
         , @n_Qty                   INT  
         , @c_UOM                   NVARCHAR(10)  
         , @n_UOMQty                INT  
         , @c_Orderkey              NVARCHAR(10)  
         , @c_Groupkey              NVARCHAR(10)  
         , @c_Toloc                 NVARCHAR(10)  
         , @c_Priority              NVARCHAR(10)  
         , @c_PickMethod            NVARCHAR(10)  
         , @c_Message03             NVARCHAR(20)  
         , @c_Message02             NVARCHAR(20)  
         , @c_ExternOrderKey        NVARCHAR(20)  
         , @C_Zip                   NVARCHAR(18)  
         , @c_LinkTaskToPick_SQL    NVARCHAR(4000)  
         , @c_SQL                   NVARCHAR(MAX)  
         , @c_Route                 NVARCHAR(10)  
         , @c_Taskdetailkey         NVARCHAR(10)  
         , @c_DefaultLoc            NVARCHAR(10)  
         , @c_Loadkey               NVARCHAR(10)  
         , @dt_deliveryDate         DATETIME
         , @n_LastPartial_Ctn       INT  
         , @n_CaseCNT               INT  
         , @cSTBMAXSKU              NVARCHAR(10)  
         , @cSTCMAXSKU              NVARCHAR(10)  
         , @cSKUBUSR2               NVARCHAR(10)  
         , @nPackMaxSKU             INT
         , @c_PickCode              NVARCHAR(10) = N''
         , @n_QtyAvailable          INT = 0
         , @c_LocationType          NVARCHAR(10) = N''
 
   SET @c_SourceType = N'mspRLWAV12'  
   SET @c_Priority = N'9'  
   SET @c_TaskType = N'FCP'  
   SET @c_PickMethod = N'PP'  
 
   -----Wave Validation-----  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      IF NOT EXISTS ( SELECT 1  
                      FROM WAVEDETAIL WD (NOLOCK)  
                      JOIN PICKDETAIL PD (NOLOCK) ON WD.Orderkey = PD.Orderkey   
                      WHERE WD.Wavekey = @c_Wavekey  
                      AND PD.[Status] = '0'  
                      AND NOT EXISTS ( SELECT 1
                                       FROM TASKDETAIL TD (NOLOCK)
                                       WHERE PD.Taskdetailkey = TD.Taskdetailkey 
                                       AND TD.Sourcetype = @c_SourceType 
                                       AND TD.Tasktype IN ('FPK','FCP','FPP')
                                     )
                    )  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @n_err = 83000  
         SELECT @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Nothing to release. (mspRLWAV12)'  
      END  
 
      IF EXISTS ( SELECT 1  
                  FROM WAVEDETAIL WD (NOLOCK)  
                  JOIN PICKDETAIL PD (NOLOCK) ON WD.Orderkey = PD.Orderkey  
                  JOIN ORDERS O (NOLOCK) ON PD.ORDERKEY = O.Orderkey  
                  JOIN CODELKUP C (NOLOCK) ON O.[TYPE] = C.CODE AND O.STORERKEY = C.STORERKEY  
                                          AND C.LISTNAME = 'mspRLWAV12' AND C.SHORT = '1' 
                                          AND C.LONG = 'NOTALLOWED'  
                  WHERE WD.Wavekey = @c_Wavekey   
                )  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @n_err = 83000  
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Order Type Not Allowed to release. (mspRLWAV12)'  
      END  
 
      --CHECK IF PACK MAX SKU CUSTOMERS' REPLENS ARE DONE  
      IF EXISTS ( SELECT 1  
                  FROM WAVEDETAIL WD (NOLOCK)  
                  JOIN PICKDETAIL PD (NOLOCK) ON WD.Orderkey = PD.Orderkey  
                  JOIN ORDERS O (NOLOCK) ON PD.ORDERKEY = O.Orderkey  
                  JOIN STORER S (NOLOCK) ON O.BILLTOKEY = S.STORERKEY AND O.STORERKEY = S.CONSIGNEEFOR  
                  JOIN LOC L (NOLOCK) ON PD.LOC = L.LOC  
                  WHERE WD.Wavekey = @c_Wavekey  
                  AND O.STORERKEY <> 'HILLSAU'
                  AND O.ORDERKEY = CASE WHEN ISNUMERIC(S.SUSR3) = 1 THEN O.ORDERKEY ELSE 'X' END  
                  AND PD.PickDetailKey = CASE WHEN PD.UOM <> '1' AND L.LOCATIONTYPE = 'BULK' THEN PD.PickDetailKey ELSE 'SKIP' END  
                )  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @n_err = 83000  
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Please Complete Replen. (mspRLWAV12)'  
      END  
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
   END  
 
   IF @@TRANCOUNT = 0  
      BEGIN TRAN  
 
   -----Get Storerkey and facility  
   IF  (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      SELECT TOP 1 @c_Storerkey = O.Storerkey
                 , @c_Facility = O.Facility
                 , @c_WaveType = W.WaveType
      FROM WAVE W (NOLOCK)  
      JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey  
      JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey  
      AND W.Wavekey = @c_Wavekey
   END  
 
   --Initialize Pickdetail work in progress staging table  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      EXEC isp_CreatePickdetail_WIP  
            @c_Loadkey               = ''  
          , @c_Wavekey               = @c_Wavekey  
          , @c_WIP_RefNo             = @c_SourceType  
          , @c_PickCondition_SQL     = ''  
          , @c_Action                = 'I'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records  
          , @c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization  
          , @b_Success               = @b_Success OUTPUT  
          , @n_Err                   = @n_Err     OUTPUT  
          , @c_ErrMsg                = @c_ErrMsg  OUTPUT  
 
      IF @b_Success <> 1  
      BEGIN  
         SET @n_Continue = 3  
      END

      UPDATE #PICKDETAIL_WIP  
      SET #PICKDETAIL_WIP.Taskdetailkey = ''  
      FROM #PICKDETAIL_WIP  
      LEFT JOIN TASKDETAIL TD (NOLOCK) ON TD.Taskdetailkey = #PICKDETAIL_WIP.Taskdetailkey 
                                      AND TD.Sourcetype = @c_SourceType 
                                      AND TD.Tasktype IN ('FPK','PK','FCP','FPP') 
                                      AND TD.Status <> 'X'  
      LEFT JOIN TASKDETAIL TDRPL (NOLOCK) ON TDRPL.Taskdetailkey = #PICKDETAIL_WIP.Taskdetailkey 
                                         AND TDRPL.Tasktype IN ('RPF','RP1','RPT') 
                                         AND TDRPL.Status NOT IN ('X','9')  
      WHERE TD.Taskdetailkey IS NULL  
      AND TDRPL.Taskdetailkey IS NULL
   END
 
   IF @n_Continue IN(1,2)  
   BEGIN  
      SELECT @c_DefaultLoc = CL.Long  
      FROM CODELKUP CL (NOLOCK)  
      JOIN LOC (NOLOCK) ON CL.Long = LOC.Loc  
      WHERE CL.Listname = 'TM_TOLOC'  
      AND CL.Storerkey = @c_Storerkey  
      AND CL.Code = 'DEFAULT'  
 
      DECLARE cur_pick CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PD.StorerKey
           , PD.Sku
           , PD.Lot
           , PD.Loc
           , PD.Id
           , SUM(PD.Qty) AS Qty
           , PD.UOM
           , SUM(PD.UOMQty) AS UOMQty
           , O.Route
           , O.OrderKey
           , O.ExternOrderKey
           , ISNULL(O.LoadKey, '')
           , TOLOC.Loc AS ToLoc
           , ISNULL(CL.Code, '9') AS Priority
           , ISNULL(STB.SUSR3, '') AS STBMAXSKU
           , ISNULL(STC.SUSR3, '') AS STCMAXSKU
           , ISNULL(TTMTYPE.Short, '')
           , ISNULL(TTMTYPE.Long, '')
           , O.DeliveryDate
           , ISNULL(S.PickCode, '')
           , LLI.QtyAvailable
           , P.CaseCnt
           , LOC.LocationType
      FROM WAVEDETAIL WD (NOLOCK)
      JOIN WAVE W (NOLOCK) ON WD.WaveKey = W.WaveKey
      JOIN ORDERS O (NOLOCK) ON WD.OrderKey = O.OrderKey
      JOIN #PICKDETAIL_WIP PD (NOLOCK) ON O.OrderKey = PD.OrderKey
      JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
      LEFT JOIN TaskDetail TD (NOLOCK) ON  PD.TaskDetailKey = TD.TaskDetailKey
                                       AND PD.StorerKey = TD.Storerkey
                                       AND TD.SourceType = @c_SourceType
                                       AND TD.TaskType IN ( 'FPK', 'FCP', 'FPP' )
                                       AND TD.Status <> 'X'
      LEFT JOIN StorerSODefault SSO (NOLOCK) ON SSO.StorerKey = O.ConsigneeKey
      LEFT JOIN StorerSODefault SSOB (NOLOCK) ON SSOB.StorerKey = O.BillToKey
      LEFT JOIN LoadPlan LP (NOLOCK) ON LP.LoadKey = O.LoadKey
      LEFT JOIN STORER STC (NOLOCK) ON STC.StorerKey = O.ConsigneeKey AND STC.ConsigneeFor = O.StorerKey
      LEFT JOIN STORER STB (NOLOCK) ON STB.StorerKey = O.BillToKey AND STB.ConsigneeFor = O.StorerKey
      LEFT JOIN TaskDetail TDRPL (NOLOCK) ON  PD.TaskDetailKey = TDRPL.TaskDetailKey
                                          AND PD.StorerKey = TDRPL.Storerkey
                                          AND TDRPL.TaskType IN ( 'RPF', 'RPT', 'RP1' )
                                          AND TDRPL.Status NOT IN ( '9', 'X' )
      LEFT JOIN REPLENISHMENT RP (NOLOCK) ON  PD.MoveRefKey = RP.MoveRefKey
                                          AND PD.StorerKey = RP.Storerkey 
                                          AND PD.StorerKey = RP.Storerkey
                                          AND RP.Confirmed <> 'Y'
                                          AND ISNULL(RP.MoveRefKey, '') <> ''
      LEFT JOIN CODELKUP TTMTYPE (NOLOCK) ON  TTMTYPE.LISTNAME = 'PKUOM2TTM'
                                          AND TTMTYPE.Storerkey = O.StorerKey
                                          AND TTMTYPE.Code = PD.UOM
      LEFT JOIN CODELKUP CL (NOLOCK) ON O.StorerKey = CL.Storerkey AND CL.LISTNAME = 'TMPRIORITY' 
                                    AND O.Priority = CL.Short
      OUTER APPLY (  SELECT TOP 1 TL.Loc
                     FROM LOC TL (NOLOCK)
                     WHERE TL.PutawayZone <> ''
                     AND   (TL.PutawayZone = SSO.Route OR TL.PutawayZone = SSOB.Route OR TL.PutawayZone = LP.Route)
                     ORDER BY CASE WHEN ISNULL(LP.Route, '') <> '' THEN 1
                                   WHEN ISNULL(SSO.Route, '') <> '' THEN 2
                                   ELSE 3 END) AS TOLOC
      JOIN SKU S WITH (NOLOCK) ON S.StorerKey = PD.Storerkey AND S.SKU = PD.Sku
      JOIN PACK P WITH (NOLOCK) ON S.PACKKEY = P.PACKKEY  
      CROSS APPLY ( SELECT QtyAvailable = SUM(LOTxLOCxID.Qty - LOTxLOCxID.QtyPicked - LOTxLOCxID.QtyAllocated)
                    FROM dbo.LOTxLOCxID WITH (NOLOCK)
                    WHERE LOTxLOCxID.StorerKey = PD.Storerkey
                    AND LOTxLOCxID.Sku = PD.Sku
                    AND LOTxLOCxID.Lot = PD.Lot
                    AND LOTxLOCxID.Loc = PD.Loc
                    AND LOTxLOCxID.ID = PD.ID ) AS LLI
      WHERE WD.WaveKey = @c_Wavekey
      AND   PD.Status = '0'
      AND   PD.PickDetailKey = CASE WHEN PD.UOM <> '1' AND LOC.LocationType = 'BULK' THEN 'SKIP'
                                    ELSE PD.PickDetailKey END
      AND   PD.WIP_RefNo = @c_SourceType
      AND   TD.TaskDetailKey IS NULL 
      AND   (TDRPL.TaskDetailKey IS NULL OR TDRPL.TaskDetailKey = '')
      AND   (RP.ReplenishmentKey IS NULL OR RP.ReplenishmentKey = '')
      GROUP BY PD.StorerKey
             , PD.Sku
             , PD.Lot
             , PD.Loc
             , PD.Id
             , PD.UOM
             , O.Route
             , LOC.LogicalLocation
             , O.OrderKey
             , O.ExternOrderKey
             , O.ConsigneeKey
             , TOLOC.Loc
             , ISNULL(CL.Code, '9')
             , O.DeliveryDate
             , O.LoadKey
             , ISNULL(STB.SUSR3, '')
             , ISNULL(STC.SUSR3, '')
             , ISNULL(TTMTYPE.Short, '')
             , ISNULL(TTMTYPE.Long, '')
             , ISNULL(S.PickCode, '')
             , LLI.QtyAvailable
             , P.CaseCnt
             , LOC.LocationType
      ORDER BY O.Route
             , PD.UOM
             , LOC.LogicalLocation
             , PD.Loc
             , PD.Sku
             , O.OrderKey
 
      OPEN cur_pick  
 
      FETCH NEXT FROM cur_pick INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @n_UOMQty, @c_Route, @c_Orderkey, @c_ExternOrderKey, @c_Loadkey  
                                  , @c_ToLoc, @c_Priority, @cSTBMAXSKU, @cSTCMAXSKU, @c_TaskType, @c_PickMethod, @dt_DeliveryDate
                                  , @c_PickCode, @n_QtyAvailable, @n_CaseCNT, @c_LocationType

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN(1,2)  
      BEGIN  
         SET @c_LinkTaskToPick_SQL = N''  
         SET @c_Groupkey = N''  
 
         SET @nPackMaxSKU = 0  
         IF ISNULL(@cSTCMAXSKU,'') <> '' AND ISNUMERIC(@cSTCMAXSKU) = 1  
            SET @nPackMaxSKU = CAST(@cSTCMAXSKU AS INT)  
 
         IF @nPackMaxSKU = 0  
            IF ISNULL(@cSTBMAXSKU,'') <> '' AND ISNUMERIC(@cSTBMAXSKU) = 1  
               SET @nPackMaxSKU = CAST(@cSTBMAXSKU AS INT)  
 
         IF ISNULL(@c_DefaultLoc,'') <> '' AND ISNULL(@c_ToLoc,'') = ''  
            SET @c_ToLoc = @c_DefaultLoc  
 
         IF ISNULL(@c_Toloc,'') = ''  
         BEGIN  
            SELECT @n_Continue = 3  
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 83020
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid To Loc setup at ROUTE. (ispRLWAV15)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
         END
         
         -- Pick task release rules for CS or EA pick code from non-PICK locations
         IF @n_Continue IN (1, 2)
         BEGIN
            SET @n_Continue = 1

            IF @n_debug = 1
            BEGIN
               PRINT 'Storerkey: ' + TRIM(@c_Storerkey) + ' | '
                   + 'SKU: ' + TRIM(@c_Sku) + CHAR(13)
                   + 'PickCode: ' + TRIM(@c_PickCode) + CHAR(13)
                   + 'AllocatedQty: ' + CAST(@n_Qty AS NVARCHAR) + CHAR(13)
                   + 'InvQty: ' + CAST(@n_QtyAvailable AS NVARCHAR) + CHAR(13)
                   + 'CaseCnt: ' + CAST(@n_CaseCNT AS NVARCHAR) + CHAR(13)
                   + 'LocationType: ' + TRIM(@c_LocationType) + CHAR(13)
            END
            
            IF @c_PickCode = 'CS or EA' AND @c_LocationType <> 'PICK'
            BEGIN
               -- If Allocated Qty is divisible by Pack.CaseCnt (Qty = CaseCnt or full case)
               IF @n_Qty % @n_CaseCNT = 0
               BEGIN
                  SET @n_Continue = 1   -- Release as usual
               END
               -- If Allocated Qty < Pack.CaseCnt
               ELSE IF @n_Qty < @n_CaseCNT
               BEGIN
                  -- If QtyAvailable is not divisible by Pack.CaseCnt and Allocated Qty = QtyAvailable
                  IF @n_QtyAvailable % @n_CaseCNT > 0 AND @n_Qty = @n_QtyAvailable
                     SET @n_Continue = 1   -- Release as usual
                  ELSE
                     SET @n_Continue = 2   -- Do not release
               END
               -- If Allocated Qty > Pack.CaseCnt and not divisible by Pack.CaseCnt
               ELSE IF @n_Qty % @n_CaseCNT > 0
               BEGIN
                  IF @n_Qty > @n_CaseCNT
                  BEGIN
                     SET @n_Continue = 1   -- Release as usual
                     SET @n_Qty = (@n_Qty / @n_CaseCNT) * @n_CaseCNT   -- Round down to full case qty
                  END
               END
            END   -- IF @c_PickCode = 'CS or EA' AND @c_LocationType <> 'PICK'
         END   -- @n_Continue IN (1, 2)

         IF @n_Continue = 1
         BEGIN
            IF @c_UOM = '1'  
            BEGIN
               SET @c_Taskdetailkey = N''  
               IF ISNULL(@c_TaskType,'') = ''  
                  SET @c_TaskType = N'FPK'  
               IF ISNULL(@c_PickMethod,'') = ''  
                  SET @c_PickMethod = N'FP'
                  
               SET @c_GroupKey = ''  
               SET @c_LinkTaskToPick_SQL = N'PICKDETAIL.UOM = @c_UOM AND ORDERS.Orderkey = @c_Orderkey'  
            
               EXEC isp_InsertTaskDetail @c_TaskDetailKey = @c_Taskdetailkey OUTPUT
                                       , @c_TaskType = @c_TaskType
                                       , @c_Storerkey = @c_Storerkey
                                       , @c_Sku = @c_Sku
                                       , @c_Lot = @c_Lot
                                       , @c_UOM = @c_UOM
                                       , @n_UOMQty = @n_UOMQty
                                       , @n_Qty = @n_Qty
                                       , @c_FromLoc = @c_FromLoc
                                       , @c_LogicalFromLoc = @c_FromLoc
                                       , @c_FromID = @c_ID
                                       , @c_ToLoc = @c_Toloc
                                       , @c_LogicalToLoc = @c_Toloc
                                       , @c_ToID = @c_ID
                                       , @c_PickMethod = @c_PickMethod
                                       , @c_Priority = @c_Priority
                                       , @c_SourcePriority = '9'
                                       , @c_SourceType = @c_SourceType
                                       , @c_SourceKey = @c_Wavekey
                                       , @c_OrderKey = @c_Orderkey
                                       , @c_Groupkey = @c_Groupkey
                                       , @c_Wavekey = @c_Wavekey
                                       , @c_LoadKey = @c_Loadkey
                                       , @c_AreaKey = '?F' -- ?F=Get from location areakey  
                                       , @c_Message03 = ''
                                       , @c_Message02 = @c_ExternOrderKey
                                       , @c_LinkTaskToPick = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                                       , @c_LinkTaskToPick_SQL = @c_LinkTaskToPick_SQL
                                       , @c_WIP_RefNo = @c_SourceType
                                       , @b_Success = @b_Success OUTPUT
                                       , @n_Err = @n_err OUTPUT
                                       , @c_ErrMsg = @c_errmsg OUTPUT
            
               IF @b_Success <> 1  
               BEGIN  
                  SELECT @n_Continue = 3  
               END  
               ELSE  
               BEGIN  
                  UPDATE TASKDETAIL WITH (ROWLOCK)  
                  SET Groupkey = @c_Orderkey  
                  WHERE TaskDetailKey = @c_Taskdetailkey  
               END  
            END  
            ELSE IF @c_UOM = '2'  
            BEGIN  
               IF ISNULL(@c_TaskType,'') = ''  
                  SET @c_TaskType = N'FCP'  
               IF ISNULL(@c_PickMethod,'') = ''  
                  SET @c_PickMethod = N'PP'  

               SET @c_GroupKey = @c_Orderkey  
            
               IF @nPackMaxSKU > 0  
               BEGIN  
                  SET @cSKUBUSR2 = N''  
            
                  SELECT @cSKUBUSR2 = ISNULL(BUSR2,'')  
                  FROM SKU WITH (NOLOCK)  
                  WHERE STORERKEY = @c_Storerkey  
                  AND SKU = @c_Sku  
            
               IF ISNULL(@cSKUBUSR2,'') <> ''  
                     SET @c_GroupKey = LEFT( LEFT(@cSKUBUSR2,LEN(@cSKUBUSR2)) + RIGHT(@c_Orderkey,10-IIF(LEN(@cSKUBUSR2)>=10,10,LEN(@cSKUBUSR2))), 10)  
                  ELSE  
                     SET @c_GroupKey = LEFT( (@c_Sku + @c_Orderkey) , 10)  
               END  
            
               SET @c_LinkTaskToPick_SQL = N'PICKDETAIL.UOM = @c_UOM AND ORDERS.Orderkey = @c_Orderkey'  

               SET @n_LastPartial_Ctn = 0  
            
               IF @n_CaseCNT > 0  
                  SET @n_LastPartial_Ctn = @n_Qty % @n_CaseCNT  
            
               IF @n_LastPartial_Ctn > 0  
                  SET @n_Qty = @n_Qty - @n_LastPartial_Ctn  
            
               EXEC isp_InsertTaskDetail @c_TaskType = @c_TaskType
                                       , @c_Storerkey = @c_Storerkey
                                       , @c_Sku = @c_Sku
                                       , @c_Lot = @c_Lot
                                       , @c_UOM = @c_UOM
                                       , @n_UOMQty = @n_UOMQty
                                       , @n_Qty = @n_Qty
                                       , @c_FromLoc = @c_FromLoc
                                       , @c_LogicalFromLoc = @c_FromLoc
                                       , @c_FromID = @c_ID
                                       , @c_ToLoc = @c_Toloc
                                       , @c_LogicalToLoc = @c_Toloc
                                       , @c_ToID = @c_ID
                                       , @c_PickMethod = @c_PickMethod
                                       , @c_Priority = @c_Priority
                                       , @c_SourcePriority = '9'
                                       , @c_SourceType = @c_SourceType
                                       , @c_SourceKey = @c_Wavekey
                                       , @c_OrderKey = @c_Orderkey
                                       , @c_Groupkey = @c_Groupkey
                                       , @c_Wavekey = @c_Wavekey
                                       , @c_LoadKey = @c_Loadkey
                                       , @c_AreaKey = '?F' -- ?F=Get from location areakey  
                                       , @c_Message03 = ''
                                       , @c_Message02 = @c_ExternOrderKey
                                       , @c_LinkTaskToPick = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                                       , @c_LinkTaskToPick_SQL = @c_LinkTaskToPick_SQL
                                       , @c_SplitTaskByCase = 'N' -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0. include last partial carton.  
                                       , @c_WIP_RefNo = @c_SourceType
                                       , @b_Success = @b_Success OUTPUT
                                       , @n_Err = @n_err OUTPUT
                                       , @c_ErrMsg = @c_errmsg OUTPUT
            
               IF @b_Success <> 1  
               BEGIN                   
                  SELECT @n_Continue = 3  
               END  
               ELSE IF @n_LastPartial_Ctn > 0  
               BEGIN  
                  --If found last partial carton, split to different task.  
                  SELECT TOP 1 @c_TaskType = SHORT, @c_PickMethod = LONG  
                  FROM CODELKUP WITH (NOLOCK)  
                  WHERE LISTNAME = 'PKUOM2TTM'  
                  AND CODE = '6'  
            
                  IF ISNULL(@c_TaskType,'') = ''  
                     SET @c_TaskType = N'FCP'  
            
                  IF ISNULL(@c_PickMethod,'') = ''  
                     SET @c_PickMethod = N'PP'  
            
                  SET @c_GroupKey = @c_Orderkey  

                  IF @nPackMaxSKU > 0  
                  BEGIN  
                     SET @cSKUBUSR2 = N''  
            
                     SELECT @cSKUBUSR2 = ISNULL(BUSR2,'')  
                     FROM SKU WITH (NOLOCK)  
                     WHERE STORERKEY = @c_Storerkey  
                     AND SKU = @c_Sku  
            
                     IF ISNULL(@cSKUBUSR2,'') <> ''  
                        SET @c_GroupKey = LEFT(@cSKUBUSR2,10)  
                     ELSE  
                        SET @c_GroupKey = LEFT(@c_Sku,10)  
                  END  
            
                  EXEC isp_InsertTaskDetail @c_TaskType = @c_TaskType
                                          , @c_Storerkey = @c_Storerkey
                                          , @c_Sku = @c_Sku
                                          , @c_Lot = ''
                                          , @c_UOM = @c_UOM
                                          , @n_UOMQty = @n_LastPartial_Ctn
                                          , @n_Qty = @n_LastPartial_Ctn
                                          , @c_FromLoc = @c_FromLoc
                                          , @c_LogicalFromLoc = @c_FromLoc
                                          , @c_FromID = @c_ID
                                          , @c_ToLoc = @c_Toloc
                                          , @c_LogicalToLoc = @c_Toloc
                                          , @c_ToID = @c_ID
                                          , @c_PickMethod = @c_PickMethod
                                          , @c_Priority = @c_Priority
                                          , @c_SourcePriority = '9'
                                          , @c_SourceType = @c_SourceType
                                          , @c_SourceKey = @c_Wavekey
                                          , @c_OrderKey = @c_Orderkey
                                          , @c_Groupkey = @c_Groupkey
                                          , @c_Wavekey = @c_Wavekey
                                          , @c_LoadKey = @c_Loadkey
                                          , @c_AreaKey = '?F' -- ?F=Get from location areakey  
                                          , @c_Message01 = 'Last Partial Carton'
                                          , @c_Message02 = @c_ExternOrderKey
                                          , @c_LinkTaskToPick = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                                          , @c_LinkTaskToPick_SQL = @c_LinkTaskToPick_SQL
                                          , @c_SplitTaskByCase = 'N' -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0. include last partial carton.  
                                          , @c_WIP_RefNo = @c_SourceType
                                          , @b_Success = @b_Success OUTPUT
                                          , @n_Err = @n_err OUTPUT
                                          , @c_ErrMsg = @c_errmsg OUTPUT 
            
                  IF @b_Success <> 1  
                  BEGIN  
                     SELECT @n_Continue = 3  
                  END  
               END  
            END  
            ELSE  
            BEGIN  --UOM 6/7  
               IF ISNULL(@c_TaskType,'') = ''  
                     SET @c_TaskType = N'FCP'  
            
               IF ISNULL(@c_PickMethod,'') = ''  
                  SET @c_PickMethod = N'PP'  

               SET @c_GroupKey = @c_Orderkey  
               SET @c_LinkTaskToPick_SQL = N'PICKDETAIL.UOM = @c_UOM AND ORDERS.Orderkey = @c_Orderkey'  
            
               IF @nPackMaxSKU > 0  
               BEGIN  
                  SET @cSKUBUSR2 = N''  
               
                  SELECT @cSKUBUSR2 = ISNULL(BUSR2,'')  
                  FROM SKU WITH (NOLOCK)  
                  WHERE STORERKEY = @c_Storerkey  
                  AND SKU = @c_Sku  
               
                  IF ISNULL(@cSKUBUSR2,'') <> ''  
                     SET @c_GroupKey = LEFT(@cSKUBUSR2,10)  
                  ELSE  
                     SET @c_GroupKey = LEFT(@c_Sku,10)  
               END
                
               EXEC isp_InsertTaskDetail @c_TaskType = @c_TaskType
                                       , @c_Storerkey = @c_Storerkey
                                       , @c_Sku = @c_Sku
                                       , @c_Lot = @c_Lot
                                       , @c_UOM = @c_UOM
                                       , @n_UOMQty = @n_UOMQty
                                       , @n_Qty = @n_Qty
                                       , @c_FromLoc = @c_FromLoc
                                       , @c_LogicalFromLoc = @c_FromLoc
                                       , @c_FromID = @c_ID
                                       , @c_ToLoc = @c_Toloc
                                       , @c_LogicalToLoc = @c_Toloc
                                       , @c_ToID = @c_ID
                                       , @c_PickMethod = @c_PickMethod
                                       , @c_Priority = @c_Priority
                                       , @c_SourcePriority = '9'
                                       , @c_SourceType = @c_SourceType
                                       , @c_SourceKey = @c_Wavekey
                                       , @c_OrderKey = @c_Orderkey
                                       , @c_Groupkey = @c_Groupkey
                                       , @c_Wavekey = @c_Wavekey
                                       , @c_LoadKey = @c_Loadkey
                                       , @c_AreaKey = '?F' -- ?F=Get from location areakey  
                                       , @c_Message03 = ''
                                       , @c_Message02 = @c_ExternOrderKey
                                       , @c_LinkTaskToPick = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                                       , @c_LinkTaskToPick_SQL = @c_LinkTaskToPick_SQL
                                       , @c_WIP_RefNo = @c_SourceType
                                       , @b_Success = @b_Success OUTPUT
                                       , @n_Err = @n_err OUTPUT
                                       , @c_ErrMsg = @c_errmsg OUTPUT
            
               IF @b_Success <> 1  
               BEGIN  
                  SELECT @n_Continue = 3  
               END  
            END
         END   --@n_Continue IN (1, 2)
 
         FETCH NEXT FROM cur_pick INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @n_UOMQty, @c_Route, @c_Orderkey, @c_ExternOrderKey, @c_Loadkey  
                                     , @c_ToLoc, @c_Priority, @cSTBMAXSKU, @cSTCMAXSKU, @c_TaskType, @c_PickMethod, @dt_DeliveryDate
                                     , @c_PickCode, @n_QtyAvailable, @n_CaseCNT, @c_LocationType
      END  
      CLOSE cur_pick
      DEALLOCATE cur_pick
   END  
 
   -----Update pickdetail_WIP work in progress staging table back to pickdetail  
   IF @n_Continue = 1 or @n_Continue = 2  
   BEGIN  
      EXEC isp_CreatePickdetail_WIP @c_Loadkey = ''
                                  , @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = ''
                                  , @c_Action = 'U' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records  
                                  , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization  
                                  , @b_Success = @b_Success OUTPUT
                                  , @n_Err = @n_err OUTPUT
                                  , @c_ErrMsg = @c_errmsg OUTPUT 
 
      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END  
 
   -----Generate Pickslip No------  
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'AutoScanIn') = '1'
      BEGIN
         EXEC isp_CreatePickSlip @c_Wavekey = @c_Wavekey
                               , @c_LinkPickSlipToPick = 'N' --Y=Update pickslipno to pickdetail.pickslipno  
                               , @c_ConsolidateByLoad = 'N'
                               , @c_AutoScanIn = 'Y' --Y=Auto scan in the pickslip N=Not auto scan in  
                               , @c_PickslipType = '8'
                               , @b_Success = @b_Success OUTPUT
                               , @n_Err = @n_err OUTPUT
                               , @c_ErrMsg = @c_errmsg OUTPUT

         IF @b_Success = 0
            SELECT @n_Continue = 3

         DECLARE cur_waveord CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT OrderKey
         FROM WAVEDETAIL (NOLOCK)
         WHERE WaveKey = @c_Wavekey

         OPEN cur_waveord

         FETCH NEXT FROM cur_waveord INTO @c_Orderkey

         WHILE @@FETCH_STATUS = 0 AND @n_Continue IN ( 1, 2 )
         BEGIN
            UPDATE PICKHEADER WITH (ROWLOCK)
            SET PICKHEADER.Wavekey = @c_Wavekey
              , PICKHEADER.Trafficcop = NULL
            FROM PICKHEADER
            JOIN ORDERS (NOLOCK) ON PICKHEADER.Orderkey = ORDERS.OrderKey
            WHERE PICKHEADER.Orderkey = @c_Orderkey

            FETCH NEXT FROM cur_waveord INTO @c_Orderkey
         END
         CLOSE cur_waveord
         DEALLOCATE cur_waveord
      END
   END
 
   -----Update Wave Status-----  
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      BEGIN TRY
         UPDATE WAVE
         SET TMReleaseFlag = 'Y'
           , TrafficCop = NULL
           , EditWho = SUSER_SNAME()
           , EditDate = GETDATE()
         WHERE WaveKey = @c_Wavekey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
      END CATCH
   END
 
   RETURN_SP:  
   -----Delete pickdetail_WIP work in progress staging table  
   IF @n_Continue IN ( 1, 2 )
   BEGIN
      EXEC isp_CreatePickdetail_WIP @c_Loadkey = ''
                                  , @c_Wavekey = @c_Wavekey
                                  , @c_WIP_RefNo = @c_SourceType
                                  , @c_PickCondition_SQL = ''
                                  , @c_Action = 'D' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records  
                                  , @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization  
                                  , @b_Success = @b_Success OUTPUT
                                  , @n_Err = @n_err OUTPUT
                                  , @c_ErrMsg = @c_errmsg OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END 

   IF CURSOR_STATUS('LOCAL', 'cur_pick') IN (0, 1)
   BEGIN
      CLOSE cur_pick
      DEALLOCATE cur_pick
   END
   ELSE IF CURSOR_STATUS('LOCAL', 'cur_pick') = -1
      DEALLOCATE cur_pick

   IF CURSOR_STATUS('LOCAL', 'cur_waveord') IN (0, 1)
   BEGIN
      CLOSE cur_waveord
      DEALLOCATE cur_waveord
   END
   ELSE IF CURSOR_STATUS('LOCAL', 'cur_waveord') = -1
      DEALLOCATE cur_waveord

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
      DROP TABLE #PICKDETAIL_WIP

   IF @n_Continue = 3  -- Error Occured - Process And Return
   BEGIN  
      SELECT @b_success = 0  
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt  
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'mspRLWAV12'  
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
END -- procedure 
GO
GRANT EXECUTE ON [dbo].[mspRLWAV12] TO [nSQL] 
GO