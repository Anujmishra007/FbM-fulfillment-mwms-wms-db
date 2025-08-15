SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF

GO
/*************************************************************************/
/* Stored Procedure: ispRLWAV69                                          */
/* Creation Date: 21-Mar-2024                                            */
/* Copyright: MAERSK                                                     */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: UWP-16612 - Wave Release - create VNAOUT tasks during wave   */
/*                      release for Picking                              */
/*                                                                       */
/* Called By:                                                            */
/*                                                                       */
/* Version: 1.6                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author  Ver.  Purposes                                   */
/* 21-Mar-2024  WLChooi 1.0   DevOps Combine Script                      */
/* 23-Oct-2024  Wan01   1.1   UWP-24998 - MLP Outbound Staging Loc       */
/* 13-NOV-2024  VPA235  1.2   UWP-26879 - Change task group key to Load ID */
/* 22-NOV-2024  Wan02   1.3   FCR-1430 - Gap for Overallocation at FrontLoc*/
/* 18-Dec-2024  SSA01   1.4   UWP-28305 -update Status = 0 for FCP tasks */
/* 22-Apr-2025  Wan03   1.5   FCR-2902 - MLP Enhancement - Allocate      */
/*                            Case/Shrink at BULK, Demand Replenishment  */
/*                            to DPP.                                    */
/* 20-Jun-2025  Wan04   1.6   UWP-36410 -MLP Link Repln Task ID in       */
/*                            pickDetail for FCR-2902                    */
/* 21-Jul-2025  Wan05   1.7   FCR-6708 - MLP Cold Store Allocation and   */
/*                            Replenishment Issues                       */
/*                            FCR-2902 Bug Fix                           */
/* 12-Aug-2025  Wan06  1.8    UWP-39035 - Matching RPF Section to find   */
/*                            DPP for FCR-6708 & FCR-2902                */
/* 15-Aug-2025                FCR-6708 Bug Fix                           */
/*************************************************************************/
CREATE OR ALTER PROCEDURE  [dbo].[ispRLWAV69]        
    @c_Wavekey      NVARCHAR(10)    
   ,@b_Success      INT            OUTPUT    
   ,@n_err          INT            OUTPUT    
   ,@c_errmsg       NVARCHAR(250)  OUTPUT    
   ,@b_debug        INT = 0
 AS    
 BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
     
   DECLARE @n_continue  INT
         , @n_Starttcnt INT -- Holds the current transaction count    
         , @n_debug     INT
         , @n_cnt       INT
                    
   SELECT @n_Starttcnt = @@TRANCOUNT, @n_continue = 1, @b_success = 0, @n_err = 0, @c_errmsg = '', @n_cnt = 0   
   SELECT @n_debug = @b_debug 
 
   DECLARE @c_SourceType              NVARCHAR(20)
         , @c_DocType                 NVARCHAR(10)
         , @c_Storerkey               NVARCHAR(15)
         , @c_PickMethod              NVARCHAR(10)
         , @c_ToLoc                   NVARCHAR(10)
         , @c_SourcePriority          NVARCHAR(10)
         , @c_Priority                NVARCHAR(10)  
         , @c_Facility                NVARCHAR(5)
         , @c_UOM                     NVARCHAR(10)
         , @c_Message03               NVARCHAR(20)
         , @c_TaskType                NVARCHAR(10)
         , @c_curPickdetailkey        NVARCHAR(10)
         , @c_PickCondition_SQL       NVARCHAR(4000)
         , @c_LinkTaskToPick_SQL      NVARCHAR(4000)
         , @c_SKU                     NVARCHAR(20)
         , @c_Lot                     NVARCHAR(10)
         , @c_FromLoc                 NVARCHAR(10)
         , @c_ID                      NVARCHAR(20)
         , @n_UOMQty                  INT
         , @n_Qty                     INT
         , @c_Loadkey                 NVARCHAR(10)
         , @c_Taskdetailkey           NVARCHAR(10) = ''
         , @c_FinalLoc                NVARCHAR(10)
         , @c_Orderkey                NVARCHAR(10)

         , @c_RLWav_Opt5               NVARCHAR(1000)= ''                           --(Wan01) 
         , @c_LoadAssignLane           NVARCHAR(10) = 'N'                           --(Wan01)
         , @b_ManualFPK                BIT          = 0                             --(Wan03)
         , @b_FPP                      BIT          = 0                             --(Wan05) --FPP=1: FullPalletPick process, FPP=0: Cherry Pick
         , @c_FPPDefShelfLifeCode      NVARCHAR(36) = 'ML11'                        --(Wan05) 
         , @c_FPPByShelfLifeCode       NVARCHAR(10) = ''                            --(Wan05) 

         , @n_Qty_Pick                 INT         = 0                              --(Wan02)
         , @n_Qty_Avail                INT         = 0                              --(Wan02)
         , @n_Qty_Task                 INT         = 0                              --(Wan02)
         , @n_Qty_Alloc                INT         = 0                              --(Wan02) 
         , @c_PickDetailKey            NVARCHAR(10) = ''                            --(Wan02)            
         , @c_NewPickDetailKey         NVARCHAR(10) = ''                            --(Wan02)   
         , @n_RowID                    INT            = 0                           --2025-07-29   

         , @b_CherryPick               INT            = 0                           --(Wan03)
         , @c_AllowOverAllocations     NVARCHAR(10)   = ''                          --(Wan03)
         , @c_Strategykey              NVARCHAR(10)   = ''                          --(Wan03)
         , @c_Priority_Wave            CHAR(1)        = '7'                         --(Wan03)
         , @c_Priority_RPF             INT            = '1'                         --(Wan03)
         , @c_Priority_PICK            INT            = '2'                         --(Wan03)
         , @c_DPPBatch                 NVARCHAR(500)  = ''                          --(Wan03)
         , @c_DirectionType            NVARCHAR(10)   = ''                          --(Wan03)
         , @c_PZJSon                   NVARCHAR(MAX)  = ''                          --(Wan03)
         , @c_Batch1                   NVARCHAR(50)   = ''                          --(Wan03) 
         , @c_Batch2                   NVARCHAR(50)   = ''                          --(Wan03) 
         , @c_Batch3                   NVARCHAR(50)   = ''                          --(Wan03) 
         , @c_Batch4                   NVARCHAR(50)   = ''                          --(Wan03) 
         , @c_Batch5                   NVARCHAR(50)   = ''                          --(Wan03)
         , @c_LocationType             NVARCHAR(10)   = ''                          --(Wan05)  
         , @c_SectionKey               NVARCHAR(10)   = ''                          --(Wan06)         
         , @c_PutawayZone              NVARCHAR(10)   = ''                          --(Wan03)
         , @c_ReplFromLoc              NVARCHAR(10)   = ''                          --(Wan03)
         , @c_ReplFromID               NVARCHAR(18)   = ''                          --(Wan03)
         , @c_ReplTaskKey              NVARCHAR(10)   = ''                          --(Wan04)
         , @c_FromID                   NVARCHAR(18)   = ''                          --(Wan03)
         , @c_ToID                     NVARCHAR(18)   = ''                          --(Wan03)
         , @c_FinalID                  NVARCHAR(18)   = ''                          --(Wan03)
         , @c_Loseid                   NVARCHAR(1)    = ''                          --(Wan03)
         , @c_LocAisle                 NVARCHAR(10)   = ''                          --(Wan03)
         , @c_TaskStatus               NVARCHAR(10)   = ''                          --(Wan03)
         , @c_GroupKey                 NVARCHAR(10)   = ''                          --(Wan03)
         , @c_ShelfLifeCode            NVARCHAR(36) = ''                            --(Wan03) 
         , @c_SQL                      NVARCHAR(4000) = ''                          --(Wan03) 
         , @c_SQLParms                 NVARCHAR(1000) = ''                          --(Wan03)          
         , @c_SQLBatch                 NVARCHAR(1000) = ''                          --(Wan03)
         , @c_SQLGroupBy               NVARCHAR(1000) = ''                          --(Wan03)
         , @c_SQLCond                  NVARCHAR(2000) = ''                          --(Wan03) 
        
         , @CUR_UPDPICK                CURSOR                                       --(Wan02) 
         , @CUR_VNAOUT_RPF             CURSOR                                       --(Wan03) 

   SET @c_SourceType = 'ispRLWAV69'
            
   -----Get some basic info---------------
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN        
      SELECT TOP 1 @c_Facility  = ORDERS.Facility
                 , @c_Storerkey = ORDERS.Storerkey
                 , @c_DocType   = ORDERS.DocType
                 , @c_Strategykey = WAVE.Strategykey                                --(Wan03)
                 , @c_Priority_Wave = WAVE.UserDefine08                             --(Wan03)
      FROM WAVE (NOLOCK)  
      JOIN WAVEDETAIL (NOLOCK) ON WAVE.Wavekey = WAVEDETAIL.WaveKey  
      JOIN ORDERS (NOLOCK) ON WAVEDETAIL.Orderkey = ORDERS.Orderkey          
      WHERE WAVE.Wavekey = @c_Wavekey  
                          
      IF @n_debug=1  
         SELECT '@c_Wavekey', @c_Wavekey, '@c_Facility', @c_Facility, '@c_DocType', @c_DocType    
   END  
   -----Wave Validation-----  
   IF @n_continue=1 OR @n_continue=2    
   BEGIN    
      IF ISNULL(@c_Wavekey,'') = ''    
      BEGIN    
         SELECT @n_continue = 3    
         SELECT @n_err = 67800    
         SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)+': Invalid Parameters Passed (ispRLWAV69)'    
      END    
   END    
   
   IF @n_continue=1 OR @n_continue=2                                                --(Wan03) - START  
   BEGIN  
      SET @c_Priority_Wave = CASE WHEN @c_Priority_Wave IN ('', NULL)  THEN '7' 
                                  WHEN ISNUMERIC(@c_Priority_Wave) = 0 THEN 'X' 
                                  ELSE @c_Priority_Wave END

      IF @c_Priority_Wave NOT BETWEEN '0' AND '7'
      BEGIN    
         SET @n_continue = 3    
         SET @n_err = 67802    
         SET @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)
                       +': Invalid Wave priority (ispRLWAV69)'    
      END    
   END                                                                              --(Wan03) - END
                        
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN  
      IF EXISTS (SELECT 1 FROM TASKDETAIL TD (NOLOCK)   
                 WHERE TD.Wavekey = @c_Wavekey  
                 AND TD.Sourcetype = @c_SourceType
                 AND TD.Tasktype IN ( 'VNAOUT', 'FCP', 'FPK' )                      --(Wan03)
                 AND TD.Message03 <> 'RPF'                                          --(Wan04)
                 AND TD.[Status] <> 'X'                                             --(Wan03)  
                )   
      BEGIN  
         SELECT @n_continue = 3    
         SELECT @n_err = 67805    
         SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)
                          +': This Wave has been released. (ispRLWAV69)'         
      END                   
   END  

   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN  
      IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK)
                 WHERE UserDefine09 = @c_Wavekey
                 AND (Loadkey IS NULL OR Loadkey = '') )
      BEGIN  
         SELECT @n_continue = 3    
         SELECT @n_err = 67810  
         SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)+': One or more orders are missing Loadkey. (ispRLWAV69)'         
      END                   
   END

   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN  
      IF EXISTS (SELECT 1   
                 FROM WAVEDETAIL WD(NOLOCK)  
                 JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey  
                 WHERE O.Status > '2'  
                 AND WD.Wavekey = @c_Wavekey)  
      BEGIN  
         SELECT @n_continue = 3    
         SELECT @n_err = 67815    
         SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)+': Release is not allowed. Some orders of this Wave are started picking (ispRLWAV69)'           
      END                   
   END   

   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN 
      SELECT @c_RLWav_Opt5 = gr.Option5
      FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'ReleaseWave_SP') gr

      --(Wan01) - START
      SELECT @c_RLWav_Opt5 = gr.ConfigOption5 
      FROM fnc_SelectGetRight (@c_Facility, @c_Storerkey, '', 'ReleaseWave_SP') gr

      SELECT @c_LoadAssignLane = 
      dbo.fnc_GetParamValueFromString('@c_LoadAssignLane', @c_RLWav_Opt5, @c_LoadAssignLane)
      --(Wan01) - END

      --(Wan03) - START
      SET @b_ManualFPK = 0                                                          
      SELECT @b_ManualFPK =
      dbo.fnc_GetParamValueFromString('@b_ManualFPK', @c_RLWav_Opt5, @b_ManualFPK)

      SELECT @c_AllowOverAllocations = gr.Authority
      FROM fnc_SelectGetRight (@c_Facility, @c_Storerkey, '', 'AllowOverAllocations') gr

      SET @c_FPPByShelfLifeCode = 'Y'                                               --(Wan05) - START 
      SELECT @c_FPPByShelfLifeCode =
      dbo.fnc_GetParamValueFromString('@c_FPPByShelfLifeCode', @c_RLWav_Opt5, @c_FPPByShelfLifeCode)
      
      IF @c_FPPByShelfLifeCode = 'N'
      BEGIN
         SET @c_FPPDefShelfLifeCode =''
      END                                                                           --(Wan05) - END
 
      SET @c_Priority_RPF = '1'                        
      SET @c_Priority_PICK= '2'  

      SET @c_Priority_RPF = CONVERT(NVARCHAR(1), CONVERT(INT, @c_Priority_Wave) 
                                               + CONVERT(INT, @c_Priority_RPF))
      SET @c_Priority_PICK= CONVERT(NVARCHAR(1), CONVERT(INT, @c_Priority_Wave) 
                                               + CONVERT(INT, @c_Priority_PICK))
 
      SET @c_DPPBatch = 'SKU.Sku'                                                       
      SELECT @c_DPPBatch = dbo.fnc_GetParamValueFromString('@c_DPPBatch'
                                                          , @c_RLWav_Opt5, @c_DPPBatch) 

      SET @c_DirectionType = 'FWDBWD'
      SELECT @c_DirectionType = dbo.fnc_GetParamValueFromString('@c_DirectionType'         
                                                               , @c_RLWav_Opt5, @c_DirectionType)
                                                               
      SET @b_FPP = 1                                                                --(Wan05)       
      SET @n_Cnt = 0                                                                --(Wan05)
      SET @c_ShelfLifeCode = ''
  
      IF @c_FPPByShelfLifeCode = 'Y'                                                --(Wan05)
      BEGIN
         SELECT @c_ShelfLifeCode = MIN(LA.Lottable07)
               ,@n_Cnt = COUNT(DISTINCT LA.Lottable07)                              --(Wan05)
         FROM WAVEDETAIL WD (NOLOCK)  
         JOIN PICKDETAIL PD (NOLOCK) ON PD.Orderkey = WD.Orderkey 
         JOIN LOTATTRIBUTE LA (NOLOCK) ON LA.Lot = PD.Lot
         WHERE WD.WaveKey = @c_Wavekey
         GROUP BY WD.Wavekey
    
         IF @n_Cnt > 1 AND @c_ShelfLifeCode = ''                                    --(Wan05)
         BEGIN  
            SET @n_continue = 3    
            SET @n_err = 67817    
            SET @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)
                          +': Wave having different pick process found. (ispRLWAV69)'           
         END  
         
         IF @c_ShelfLifeCode <> @c_FPPDefShelfLifeCode                              --(Wan05)
         BEGIN
            -- Charry Pick Process
            SET @b_FPP = 0                                                          --(Wan05)                                                               
         END 
      END    
   END  
   --(Wan03) - END

   IF @@TRANCOUNT = 0
   BEGIN TRAN

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN 
      IF OBJECT_ID('#PickDetail_WIP') IS NOT NULL
      BEGIN 
         DROP TABLE #PickDetail_WIP
      END

      CREATE TABLE #PickDetail_WIP
      (  
         [PickDetailKey]         [NVARCHAR](18)    NOT NULL PRIMARY KEY  
      ,  [CaseID]                [NVARCHAR](20)    NOT NULL DEFAULT (' ')  
      ,  [PickHeaderKey]         [NVARCHAR](18)    NOT NULL  
      ,  [OrderKey]              [NVARCHAR](10)    NOT NULL  
      ,  [OrderLineNumber]       [NVARCHAR](5)     NOT NULL  
      ,  [Lot]                   [nvarchar](10)    NOT NULL  
      ,  [Storerkey]             [nvarchar](15)    NOT NULL  
      ,  [Sku]                   [nvarchar](20)    NOT NULL  
      ,  [AltSku]                [nvarchar](20)    NOT NULL    DEFAULT (' ')  
      ,  [UOM]                   [nvarchar](10)    NOT NULL    DEFAULT (' ')  
      ,  [UOMQty]                [int]             NOT NULL    DEFAULT ((0))  
      ,  [Qty]                   [int]             NOT NULL    DEFAULT ((0))  
      ,  [QtyMoved]              [int]             NOT NULL    DEFAULT ((0))  
      ,  [Status]                [nvarchar](10)    NOT NULL    DEFAULT ('0')  
      ,  [DropID]                [nvarchar](20)    NOT NULL    DEFAULT ('')  
      ,  [Loc]                   [nvarchar](10)    NOT NULL    DEFAULT ('UNKNOWN')  
      ,  [ID]                    [nvarchar](18)    NOT NULL    DEFAULT (' ')  
      ,  [PackKey]               [nvarchar](10)    NULL        DEFAULT (' ')  
      ,  [UpdateSource]          [nvarchar](10)    NULL        DEFAULT ('0')  
      ,  [CartonGroup]           [nvarchar](10)    NULL  
      ,  [CartonType]            [nvarchar](10)    NULL  
      ,  [ToLoc]                 [nvarchar](10)    NULL        DEFAULT (' ')  
      ,  [DoReplenish]           [nvarchar](1)     NULL        DEFAULT ('N')  
      ,  [ReplenishZone]         [nvarchar](10)    NULL        DEFAULT (' ')  
      ,  [DoCartonize]           [nvarchar](1)     NULL        DEFAULT ('N')  
      ,  [PickMethod]            [nvarchar](1)     NOT NULL    DEFAULT (' ')  
      ,  [WaveKey]               [nvarchar](10)    NOT NULL    DEFAULT (' ')  
      ,  [EffectiveDate]         [datetime]        NOT NULL    DEFAULT (getdate())  
      ,  [AddDate]               [datetime]        NOT NULL    DEFAULT (getdate())  
      ,  [AddWho]                [nvarchar](128)   NOT NULL    DEFAULT (suser_sname())  
      ,  [EditDate]              [datetime]        NOT NULL    DEFAULT (getdate())  
      ,  [EditWho]               [nvarchar](128)   NOT NULL    DEFAULT (suser_sname())  
      ,  [TrafficCop]            [nvarchar](1)     NULL  
      ,  [ArchiveCop]            [nvarchar](1)     NULL  
      ,  [OptimizeCop]           [nvarchar](1)     NULL  
      ,  [ShipFlag]              [nvarchar](1)     NULL        DEFAULT ('0')  
      ,  [PickSlipNo]            [nvarchar](10)    NULL  
      ,  [TaskDetailKey]         [nvarchar](10)    NULL  
      ,  [TaskManagerReasonKey]  [nvarchar](10)    NULL  
      ,  [Notes]                 [nvarchar](4000)  NULL  
      ,  [MoveRefKey]            [nvarchar](10)    NULL        DEFAULT ('')  
      ,  [WIP_Refno]             [nvarchar](30)    NOT NULL    DEFAULT ('')  
      ,  [Channel_ID]            [bigint]          NULL        DEFAULT ((0))
      )      
            
      CREATE INDEX PDWIP_Wave ON #PickDetail_WIP (Wavekey, WIP_RefNo, UOM, [Status]) 
   END
   
   IF OBJECT_ID('#ZoneAisle') IS NOT NULL                                          --2025-07-29 - START
   BEGIN 
      DROP TABLE #ZoneAisle
   END

   CREATE TABLE #ZoneAisle
   ( RowID        INT                                    PRIMARY KEY
   , Facility     NVARCHAR(5)    NOT NULL DEFAULT('')
   , [Zone]       NVARCHAR(10)   NOT NULL DEFAULT('')
   , LocAisle     NVARCHAR(10)   NOT NULL DEFAULT('')
   , Direction    NCHAR(1)       NOT NULL DEFAULT('')
   )                                                                                --2025-07-29 - END

    --Initialize Pickdetail work in progress staging table
   IF @n_continue = 1 or @n_continue = 2
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
         ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
           
      IF @b_Success <> 1
      BEGIN
         SET @n_continue = 3
      END          
   END

   --Remove taskdetailkey and add wavekey from pickdetail of the wave      
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN  
      SET @c_curPickdetailkey = ''  

      DECLARE Orders_Pickdet_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
      SELECT Pickdetailkey  
      FROM WAVEDETAIL WITH (NOLOCK)    
      JOIN #PickDetail_WIP PICKDETAIL WITH (NOLOCK) ON WAVEDETAIL.Orderkey = PICKDETAIL.Orderkey
      WHERE WAVEDETAIL.Wavekey = @c_Wavekey   
  
      OPEN Orders_Pickdet_cur   
      FETCH NEXT FROM Orders_Pickdet_cur INTO @c_curPickdetailkey

      WHILE @@FETCH_STATUS = 0   
      BEGIN   
         UPDATE #PickDetail_WIP WITH (ROWLOCK)   
         SET #PickDetail_WIP.TaskdetailKey = '', 
             #PickDetail_WIP.Notes = '',   
             #PickDetail_WIP.Wavekey = @c_Wavekey,   
             EditWho    = SUSER_SNAME(),  
             EditDate   = GETDATE(),     
             TrafficCop = NULL  
         WHERE #PickDetail_WIP.Pickdetailkey = @c_curPickdetailkey
          
         SELECT @n_err = @@ERROR  

         IF @n_err <> 0   
         BEGIN  
            CLOSE Orders_Pickdet_cur   
            DEALLOCATE Orders_Pickdet_cur
            
            SELECT @n_continue = 3    
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 67817   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)+': Update Pickdetail Table Failed. (ispRLWAV69)' + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '    
         END    

         FETCH NEXT FROM Orders_Pickdet_cur INTO @c_curPickdetailkey  
      END  
      CLOSE Orders_Pickdet_cur   
      DEALLOCATE Orders_Pickdet_cur  
   END 

   --VNAOUT for UOM = 2,3 (RPF)                                         
   IF (@n_continue = 1 OR @n_continue = 2) AND                                      --(Wan03) - START                      
       @c_AllowOverAllocations = '0' AND @b_FPP = 1                                 --(Wan05)
   BEGIN
      SET @c_PZJSon = ( SELECT DISTINCT 
                           l.Facility, l.PutawayZone, l.LocAisle       
                        FROM Loc l (NOLOCK) 
                        WHERE l.Facility     = @c_Facility
                        AND   l.LocationType = 'DYNPPICK'
                        FOR JSON AUTO
                      )

      IF @c_DPPBatch > ''
      BEGIN
         ;WITH SplitValues AS (
            SELECT 
               [Value] = LTRIM([Value]),                                            --2025-07-29
               ROW_NUMBER() OVER (ORDER BY (SELECT '')) AS RowNum
            FROM STRING_SPLIT(@c_DPPBatch, ',')
         )
         SELECT @c_SQLBatch=', Batch1 = ' + MAX(CASE WHEN RowNum = 1 THEN [Value] ELSE '''''' END) 
                           +', Batch2 = ' + MAX(CASE WHEN RowNum = 2 THEN [Value] ELSE '''''' END) 
                           +', Batch3 = ' + MAX(CASE WHEN RowNum = 3 THEN [Value] ELSE '''''' END) 
                           +', Batch4 = ' + MAX(CASE WHEN RowNum = 4 THEN [Value] ELSE '''''' END) 
                           +', Batch5 = ' + MAX(CASE WHEN RowNum = 5 THEN [Value] ELSE '''''' END) 
               ,@c_SQLCond = MAX(CASE WHEN RowNum = 1 THEN ' AND ' + [Value]  + '= @c_Batch1' ELSE '' END)
                           + MAX(CASE WHEN RowNum = 2 THEN ' AND ' + [Value]  + '= @c_Batch2' ELSE '' END)
                           + MAX(CASE WHEN RowNum = 3 THEN ' AND ' + [Value]  + '= @c_Batch3' ELSE '' END)
                           + MAX(CASE WHEN RowNum = 4 THEN ' AND ' + [Value]  + '= @c_Batch4' ELSE '' END)
                           + MAX(CASE WHEN RowNum = 5 THEN ' AND ' + [Value]  + '= @c_Batch5' ELSE '' END)  
               ,@c_SQLGroupBy = MAX(CASE WHEN RowNum = 1 THEN ' , ' + [Value] ELSE '' END)
                              + MAX(CASE WHEN RowNum = 2 THEN ' , ' + [Value] ELSE '' END)
                              + MAX(CASE WHEN RowNum = 3 THEN ' , ' + [Value] ELSE '' END)
                              + MAX(CASE WHEN RowNum = 4 THEN ' , ' + [Value] ELSE '' END)
                              + MAX(CASE WHEN RowNum = 5 THEN ' , ' + [Value] ELSE '' END)                
         FROM SplitValues;
      END

      SET @c_SQL = N'SET @CUR_VNAOUT_RPF = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR'
                 + ' SELECT PICKDETAIL.Storerkey' 
                 + ', PICKDETAIL.Sku' 
                 + ', PICKDETAIL.Lot'                                               --(Wan05)
                 + ', PICKDETAIL.Loc' 
                 + ', PICKDETAIL.ID' 
                 + ', ''1'' AS UOM' 
                 + ', LOTxLOCxID.Qty AS UOMQty' 
                 + ', LOTxLOCxID.Qty' 
                 + ', LOC.Sectionkey'                                               --(Wan06) 
                 + ', LOC.PutawayZone' 
                 + ', LOC.LocAisle' 
                 + ', LOC.LocationType'                                             --(Wan05)                   
                 + @c_SQLBatch
                 + ' FROM #PickDetail_WIP PICKDETAIL' 
                 + ' JOIN LOC (NOLOCK) ON LOC.LOC = PICKDETAIL.LOC'
                 + ' JOIN SKU (NOLOCK) ON  SKU.Storerkey = PICKDETAIL.Storerkey'
                 +                   ' AND SKU.Sku = PICKDETAIL.Sku'
                 + ' JOIN LOTxLOCxID (NOLOCK) ON LOTxLOCxID.Lot = PICKDETAIL.LOT'
                 +                         ' AND LOTxLOCxID.Loc = PICKDETAIL.Loc'
                 +                         ' AND LOTxLOCxID.ID  = PICKDETAIL.ID'
                 + CASE WHEN @c_SQLBatch = '' 
                        THEN '' 
                        ELSE ' JOIN LOTATTRIBUTE (NOLOCK) ON LOTATTRIBUTE.Lot = PICKDETAIL.LOT'
                        END
                 + ' WHERE PICKDETAIL.WaveKey = @c_Wavekey'  
                 + ' AND PICKDETAIL.WIP_Refno = @c_SourceType' 
                 + ' AND PICKDETAIL.[Status] = ''0'''  
                 + ' AND PICKDETAIL.UOM IN (''2'',''3'',''6'')'                     --(Wan05)
                 + ' AND LOC.LocationType IN (''VNA'',''BULK'')'                    --(Wan05) Cold Storage
                 + ' AND LOTxLOCxID.Qty - LOTxLOCxID.QtyReplen > 0'
                 + ' AND LOTxLOCxID.Qty > PICKDETAIL.Qty'                           --(Wan05)
                 + ' GROUP BY PICKDETAIL.Storerkey'
                 + ', PICKDETAIL.Sku' 
                 + ', PICKDETAIL.Lot'                                             
                 + ', PICKDETAIL.Loc' 
                 + ', PICKDETAIL.ID'
                 + ', LOTxLOCxID.Qty'
                 + ', LOC.Sectionkey'                                               --(Wan06) 
                 + ', LOC.PutawayZone' 
                 + ', LOC.LocAisle'
                 + ', LOC.LocationType'                                             --(Wan05)                   
                 + @c_SQLGroupBy +';'
                 + ' OPEN @CUR_VNAOUT_RPF;' 

      SET @c_SQLParms = N'@c_Wavekey      NVARCHAR(10)'
                      + ',@c_SourceType   NVARCHAR(30)'
                      + ',@CUR_VNAOUT_RPF CURSOR   OUTPUT'
 
      EXEC sp_ExecuteSQL @c_SQL
                        ,@c_SQLParms
                        ,@c_Wavekey
                        ,@c_SourceType
                        ,@CUR_VNAOUT_RPF  OUTPUT

      FETCH NEXT FROM @CUR_VNAOUT_RPF INTO @c_Storerkey, @c_SKU, @c_Lot, @c_FromLoc, @c_FromID
                                          ,@c_UOM, @n_UOMQty, @n_Qty
                                          ,@c_SectionKey, @c_PutawayZone, @c_LocAisle              --(Wan06)
                                          ,@c_LocationType                                         --(Wan05)                                         
                                          ,@c_Batch1, @c_Batch2, @c_Batch3, @c_Batch4, @c_Batch5

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         SET @c_ToLoc    = ''
         SET @c_ToID     = ''
         SET @c_FinalLoc = ''
         SET @c_FinalID  = ''
         SET @n_RowID    = 0

         
         SET @c_PZJSon = ( SELECT DISTINCT                                          --(Wan06)
                           l.Facility, l.PutawayZone, l.LocAisle       
                           FROM Loc l (NOLOCK) 
                           WHERE l.Facility     = @c_Facility
                           AND   l.SectionKey   = @c_SectionKey
                           AND   l.LocationType = 'DYNPPICK'
                           FOR JSON AUTO
                      )
   
         TRUNCATE TABLE #ZoneAisle;                                                 --2025-07-29
         INSERT INTO #ZoneAisle ( RowID, Facility, [Zone], LocAisle, Direction )
         SELECT  RowID, Facility, [Zone], LocAisle, Direction 
         FROM dbo.fnc_GetToZoneAisle ( @c_Facility
                                    ,  @c_Putawayzone 
                                    ,  ''
                                    ,  @c_LocAisle 
                                    ,  ''
                                    ,  @c_DirectionType 
                                    ,  @c_PZJSon 
                                    ) za 
   
         -- Find DPP 
         -- 1) Same Friend From Same Aisle
         -- 2) Empty Loc From Same Aisle
         -- 3) Same Friend From Others Aisle
         -- 4) Empty Loc From Others Aisle
         IF @c_ToLoc = ''
         BEGIN
            -- Get Same Friend
             SET @c_SQL = N'SELECT TOP 1 @c_ToLoc = l.Loc'                          --2025-07-29 - START
                       + ' , @c_LoseID = l.LoseID'
                       + ' , @n_RowID  = za.RowID'                                  
                       + ' FROM Loc l (NOLOCK)'
                       --+ ' CROSS APPLY dbo.fnc_GetToZoneAisle (l.Facility'
                       --+                                   ',  @c_Putawayzone'
                       --+                                   ',  '''''
                       --+                                   ',  @c_LocAisle'
                       --+                                   ',  '''''
                       --+                                   ',  @c_DirectionType'
                       --+                                   ',  @c_PZJSon'
                       --+                                   ') za'
                       + ' JOIN #ZoneAisle za ON za.facility = l.Facility'                         
                       +                   ' AND za.[Zone] = l.PutawayZone'
                       + CASE WHEN @c_LocAisle > '' THEN ' AND za.LocAisle = l.LocAisle' 
                                                    ELSE '' END
                       + ' CROSS APPLY ( SELECT P.Pallet'
                       +               ' , QtyRepl = SUM(lli.Qty - lli.QtyPicked + lli.PendingMoveIn)'
                       +                         ' + @n_Qty'
                       +               ' FROM LOTxLOCxID lli (NOLOCK) '
                       +               ' JOIN SKU SKU(NOLOCK) '
                       +                        ' ON  SKU.StorerKey = lli.Storerkey'
                       +                        ' AND SKU.Sku = lli.Sku'
                       +               ' JOIN PACK P (NOLOCK) '
                       +                        ' ON  P.Packkey = SKU.Packkey'
                       + CASE WHEN @c_SQLBatch = '' 
                              THEN '' 
                              ELSE ' JOIN LOTATTRIBUTE (NOLOCK)'
                       +                        ' ON LOTATTRIBUTE.Lot = lli.LOT'

                              END
                       +               ' WHERE lli.StorerKey = @c_Storerkey'
                       +               ' AND lli.Loc = l.loc'
                       +               ' AND lli.Qty - lli.QtyPicked + lli.PendingMoveIn > 0'      --2025-07-29
                       +               @c_SQLCond 
                       +               ' GROUP BY P.Pallet'
                       +               ' HAVING P.Pallet * l.MaxPallet <' 
                       +               ' SUM(lli.Qty - lli.QtyPicked + lli.PendingMoveIn) + @n_Qty'
                       +               ' ) inv'
                       + ' WHERE l.Facility  = @c_Facility'
                       + ' AND   l.Sectionkey = @c_Sectionkey'                      --(Wan06)
                       + ' AND   l.LocationType = ''DYNPPICK'''
                       + ' AND   l.LocationFlag NOT IN (''HOLD'', ''DAMAGE'')'
                       + ' AND   l.[Status] = ''OK''' 
                       + ' AND   l.MaxPallet * inv.Pallet >= inv.QtyRepl'
                       + ' ORDER BY za.RowID'
                       +         ', CASE WHEN l.LocAisle = @c_LocAisle THEN 1 ELSE 9 END'
                       +         ', l.LogicalLocation, l.PAlogicalloc'    
                   
            SET @c_SQLParms = N'@c_Facility        NVARCHAR(5)'
                            + ',@c_Storerkey       NVARCHAR(15)'
                            + ',@c_SectionKey      NVARCHAR(10)'                    --(Wan06)
                            + ',@c_Putawayzone     NVARCHAR(10)' 
                            + ',@c_LocAisle        NVARCHAR(10)' 
                            + ',@c_DirectionType   NVARCHAR(10)'
                            + ',@c_PZJSon          NVARCHAR(MAX)'
                            + ',@c_Batch1          NVARCHAR(50)' 
                            + ',@c_Batch2          NVARCHAR(50)'
                            + ',@c_Batch3          NVARCHAR(50)'
                            + ',@c_Batch4          NVARCHAR(50)'
                            + ',@c_Batch5          NVARCHAR(50)'
                            + ',@n_Qty             INT'
                            + ',@c_ToLoc           NVARCHAR(30)   OUTPUT'
                            + ',@c_Loseid          NVARCHAR(1)    OUTPUT'
                            + ',@n_RowID           INT            OUTPUT'
 
            EXEC sp_ExecuteSQL @c_SQL
                              ,@c_SQLParms
                              ,@c_Facility
                              ,@c_Storerkey
                              ,@c_SectionKey                                        --(Wan06)
                              ,@c_PutawayZone
                              ,@c_LocAisle
                              ,@c_DirectionType
                              ,@c_PZJSon
                              ,@c_Batch1      
                              ,@c_Batch2      
                              ,@c_Batch3      
                              ,@c_Batch4      
                              ,@c_Batch5 
                              ,@n_Qty
                              ,@c_ToLoc      OUTPUT   
                              ,@c_Loseid     OUTPUT   
                              ,@n_RowID      OUTPUT    
        END
        
        -- Get Empty Loc, if Toloc > '', Get Empty Loc From Same Aisle and overwritten
        SET @c_SQL  = N' SELECT TOP 1 @c_ToLoc = l.Loc' 
            +          ', @c_LoseID  = l.LoseID' 
            + ' FROM Loc l (NOLOCK)'
            + ' JOIN #ZoneAisle za ON za.facility = l.Facility'                        
            +           ' AND za.[Zone] = l.PutawayZone'
            + CASE WHEN @c_LocAisle > '' THEN ' AND za.LocAisle = l.LocAisle' 
                                          ELSE '' END
            + ' OUTER APPLY ( SELECT Qty = SUM(lli.Qty - lli.QtyPicked + lli.PendingMoveIn)'
            +               ' FROM LOTxLOCxID lli (NOLOCK)'
            +               ' WHERE lli.Storerkey = @c_Storerkey'
            +               ' AND lli.Loc = l.Loc' 
            +               ' GROUP BY lli.Loc'             
            +               ') inv'
            + ' WHERE l.Facility  = @c_Facility' 
            + ' AND   l.Sectionkey = @c_Sectionkey'                                 --(Wan06)
            + ' AND   l.LocationType = ''DYNPPICK'''
            + ' AND   l.LocationFlag NOT IN (''HOLD'', ''DAMAGE'')'
            + ' AND   l.[Status] = ''OK'''
            + ' AND   (inv.Qty = 0 OR inv.Qty IS NULL)'
            + CASE WHEN @c_ToLoc > '' AND @c_LocAisle > '' 
                   THEN ' AND l.@c_LocAisle = @c_LocAisle AND za.RowID < @n_RowID'
                   WHEN @c_ToLoc > '' AND @c_LocAisle = ''
                   THEN ' AND za.RowID < @n_RowID'
                   ELSE '' END
            + ' ORDER BY za.RowID'
            +         ', l.LogicalLocation, l.PAlogicalloc'
 
         SET @c_SQLParms = N'@c_Facility        NVARCHAR(5)'
                         + ',@c_Storerkey       NVARCHAR(15)'
                         + ',@c_SectionKey      NVARCHAR(10)'                       --(Wan06)
                         + ',@c_Putawayzone     NVARCHAR(10)' 
                         + ',@c_LocAisle        NVARCHAR(10)' 
                         + ',@c_ToLoc           NVARCHAR(30)   OUTPUT'
                         + ',@c_Loseid          NVARCHAR(1)    OUTPUT'
                         + ',@n_RowID           INT'
 
         EXEC sp_ExecuteSQL @c_SQL
                           ,@c_SQLParms
                           ,@c_Facility
                           ,@c_Storerkey
                           ,@c_SectionKey                                           --(Wan06)
                           ,@c_PutawayZone
                           ,@c_LocAisle
                           ,@c_ToLoc      OUTPUT   
                           ,@c_Loseid     OUTPUT   
                           ,@n_RowID                                                --2025-07-29 - END
  
         SET @c_ToID = CASE WHEN @c_LoseID = 1 THEN '' ELSE @c_FromID END
         SET @c_FinalLoc = @c_ToLoc
         SET @c_FinalId  = @c_ToID
 
         IF @c_ToLoc = '' AND @c_FinalLoc = ''
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 67819   
            SET @c_Errmsg = 'NSQL'+CONVERT(CHAR(5),@n_err)+': Replenish ToLoc not found. LPN: ' + @c_FromID
                          + ' (ispRLWAV69)'
         END

         IF @n_Continue = 1
         BEGIN
            SET @c_TaskType   = CASE WHEN @b_ManualFPK=0 AND @c_LocationType = 'VNA' --(Wan05)
                                     THEN 'VNAOUT' ELSE 'RPF' END
            SET @c_TaskStatus = CASE WHEN @b_ManualFPK=0 AND @c_LocationType = 'VNA' --(Wan05)
                                     THEN 'Q' ELSE '0' END
            SET @c_ToID       = IIF (@c_LoseID = '1', '', @c_FromID)
            SET @c_Message03  = N'RPF'
            SET @c_Taskdetailkey = ''                                               --2025-07-09
                     
            EXEC isp_InsertTaskDetail     
                 @c_TaskType              = @c_TaskType             
                ,@c_Storerkey             = @c_Storerkey  
                ,@c_Sku                   = @c_Sku  
                ,@c_Lot                   = @c_Lot   
                ,@c_UOM                   = @c_UOM        
                ,@n_UOMQty                = @n_UOMQty     
                ,@n_Qty                   = @n_Qty        
                ,@c_FromLoc               = @c_Fromloc        
                ,@c_FromID                = @c_FromID       
                ,@c_ToLoc                 = @c_ToLoc         
                ,@c_ToID                  = @c_ToID         
                ,@c_PickMethod            = '?TASKQTY' --?TASKQTY=(Qty available - taskqty)   
                ,@c_Priority              = @c_Priority_RPF       
                ,@c_SourcePriority        = '9'        
                ,@c_SourceType            = @c_SourceType 
                ,@c_SourceKey             = @c_Wavekey 
                ,@c_Wavekey               = @c_Wavekey                   
                ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey 
                ,@c_Message03             = @c_Message03 
                ,@c_Groupkey              = ''  
                ,@c_CallSource            = 'WAVE'
                ,@c_Status                = @c_TaskStatus
                ,@c_FinalLoc              = @c_FinalLoc         
                ,@c_FinalID               = @c_FinalID   
                ,@n_QtyReplen             = @n_Qty 
                ,@n_PendingMoveIn         = @n_Qty                                  --2025-08-15 
                ,@c_LinkTaskToReplen      = 'Y'  
                ,@b_Success               = @b_Success   OUTPUT  
                ,@n_Err                   = @n_Err       OUTPUT   
                ,@c_Errmsg                = @c_Errmsg    OUTPUT 
                ,@c_Taskdetailkey         = @c_Taskdetailkey OUTPUT                

            IF @b_Success = 0
            BEGIN
               SET @n_Continue = 3   
            END

            IF @n_Continue = 1                                                          
            BEGIN                
               IF @c_GroupKey = ''                                                      
               BEGIN
                  SET @c_GroupKey = @c_Taskdetailkey
               END 
            
               UPDATE TASKDETAIL WITH (ROWLOCK)
               SET Groupkey = @c_Groupkey
                  ,TrafficCop = NULL
               WHERE TaskDetailKey = @c_Taskdetailkey                                  
            END                                                                      
               
         END
         FETCH NEXT FROM @CUR_VNAOUT_RPF INTO @c_Storerkey, @c_SKU, @c_Lot, @c_FromLoc, @c_FromID
                                             ,@c_UOM, @n_UOMQty, @n_Qty 
                                             ,@c_SectionKey, @c_PutawayZone, @c_LocAisle              --(Wan06)
                                             ,@c_LocationType                                         --(Wan05)                                          
                                             ,@c_Batch1, @c_Batch2, @c_Batch3, @c_Batch4, @c_Batch5
      END
      CLOSE @CUR_VNAOUT_RPF
      DEALLOCATE @CUR_VNAOUT_RPF
   END                                                                              --(Wan03) - END                                                       
   
   --VNAOUT for UOM 1 (Pallet Pick)
   IF (@n_continue = 1 OR @n_continue = 2)                                           
   BEGIN
      DECLARE CUR_PICK_VNAOUT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
         SELECT PICKDETAIL.Storerkey 
            , PICKDETAIL.Sku 
            , PICKDETAIL.Lot
            , PICKDETAIL.Loc 
            , PICKDETAIL.ID 
            , MAX(PICKDETAIL.UOM) AS UOM
            , SUM(PICKDETAIL.UOMQty) AS UOMQty 
            , SUM(PICKDETAIL.Qty) AS Qty 
            , ORDERS.LoadKey
            , ORDERS.OrderKey
         FROM WAVEDETAIL (NOLOCK) 
         JOIN WAVE (NOLOCK) ON WAVEDETAIL.WaveKey = WAVE.WaveKey 
         JOIN ORDERS (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey 
         JOIN #PickDetail_WIP PICKDETAIL ON ORDERS.OrderKey = PICKDETAIL.OrderKey 
         JOIN LOC (NOLOCK) ON LOC.LOC = PICKDETAIL.LOC
         WHERE WAVEDETAIL.WaveKey = @c_Wavekey  
         AND PICKDETAIL.[Status] = '0'  
         AND PICKDETAIL.WIP_Refno = @c_SourceType 
      --AND PICKDETAIL.UOM = '1'                  VPA235
         AND PICKDETAIL.UOM IN ('1','6')
         AND LOC.LocationType = 'VNA'
         GROUP BY PICKDETAIL.Storerkey 
            , PICKDETAIL.Sku 
            , PICKDETAIL.Lot
            , PICKDETAIL.Loc 
            , PICKDETAIL.ID 
            , ORDERS.LoadKey
            , ORDERS.OrderKey
 
      OPEN CUR_PICK_VNAOUT

      FETCH NEXT FROM CUR_PICK_VNAOUT INTO @c_Storerkey, @c_SKU, @c_Lot, @c_FromLoc, @c_ID
                                          ,@c_UOM, @n_UOMQty, @n_Qty, @c_Loadkey, @c_Orderkey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF  @c_AllowOverAllocations = '0' AND @c_UOM = '6'                         --(Wan05) - START
         BEGIN
             IF EXISTS ( SELECT 1
                         FROM LOTxLOCxID lli (NOLOCK) 
                         WHERE lli.Lot = @c_LOT 
                         AND lli.Loc  = @c_FromLoc  
                         AND lli.ID   = @c_ID
                         AND lli.Qty  > @n_Qty
                       )
             BEGIN
                 GOTO NEXT_PICK_VNA
             END
         END                                                                        --(Wan05) - END
         
         SET @c_ToLoc = N''
         SET @c_FinalLoc = N''
         SET @c_PickMethod = N'FP'
         SET @c_TaskType = N'VNAOUT'
         SET @c_Message03 = N'FPK'
         SET @c_SourcePriority = '9'
         SET @c_TaskStatus = 'Q'
         SET @c_Priority = CASE WHEN @c_AllowOverAllocations = '1'                  --(Wan03) - START                                         
                                THEN '4' 
                                ELSE @c_Priority_PICK 
                                END 
                                
         IF @b_FPP = 1 AND @b_ManualFPK = 1                                         --(Wan05)                        
         BEGIN
            SET @c_TaskType = N'FPK'
            SET @c_TaskStatus = '0'
         END 
         ELSE IF @b_FPP = 0                                                         --(Wan05)
         BEGIN
            SET @c_TaskType = N'FPK'
            SET @c_TaskStatus = '0'
         END                                                                        --(Wan03) - END   

         SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.UOM = @c_UOM AND LOC.LocationType = ''VNA'' '

         --(Wan01) - START
         IF @c_LoadAssignLane = 'Y'
         BEGIN
            IF @c_Loadkey <> '' OR @c_Loadkey IS NULL
            BEGIN 
               SELECT TOP 1 @c_FinalLoc = lpld.Loc
               FROM LoadPlanLaneDetail lpld(NOLOCK) 
               WHERE lpld.Loadkey = @c_Loadkey
               AND   lpld.LocationCategory = 'STAGING'
            END
         END
         ELSE
         BEGIN
            SELECT @c_FinalLoc = ISNULL(ORDERS.Door, '')
            FROM ORDERS WITH (NOLOCK)
            WHERE ORDERS.OrderKey = @c_Orderkey
         END
         --(Wan01) - END

         IF ISNULL(@c_FinalLoc,'') = ''
         BEGIN
            SELECT @n_continue = 3  
            SELECT @n_err = 67820    
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)
                             +': Invalid Outbound Staging Loc from '
                             + CASE WHEN @c_LoadAssignLane = 'Y'                    --(Wan01)
                                    THEN 'Assign Lane'
                                    ELSE 'ORDERS.Door'
                                    END
                             +'. (ispRLWAV69)'                
         END
         ELSE IF NOT EXISTS (SELECT 1 FROM LOC (NOLOCK) WHERE LOC = @c_FinalLoc)
         BEGIN
            SELECT @n_continue = 3  
            SELECT @n_err = 67825    
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)+': Loc not found in Loc table. (ispRLWAV69)'         
         END 
         ELSE
         BEGIN
            SET @c_Taskdetailkey = ''
            EXEC isp_InsertTaskDetail @c_TaskType = @c_TaskType
                                    , @c_Storerkey = @c_Storerkey
                                    , @c_Sku = @c_Sku
                                    , @c_Lot = @c_Lot
                                    , @c_UOM = @c_UOM
                                    , @n_UOMQty = @n_UOMQty
                                    , @n_Qty = @n_Qty
                                    , @c_FromLoc = @c_FromLoc
                                    , @c_LogicalFromLoc = '?'
                                    , @c_FromID = @c_ID
                                    , @c_ToLoc = @c_FinalLoc
                                    , @c_LogicalToLoc = '?'
                                    , @c_ToID = @c_ID
                                    , @c_FinalID = @c_ID
                                    , @c_PickMethod = @c_PickMethod
                                    , @c_Priority = @c_Priority
                                    , @c_SourcePriority = @c_SourcePriority
                                    , @c_SourceType = @c_SourceType
                                    , @c_SourceKey = @c_Wavekey
                                    , @c_WaveKey = @c_Wavekey
                                    , @c_Loadkey = @c_Loadkey
                                    , @c_OrderKey = @c_Orderkey
                                    , @c_Message03 = @c_Message03
                                    , @n_SystemQty = @n_Qty
                                    , @c_FinalLoc = @c_FinalLoc
                                    , @c_Status = @c_TaskStatus                     --(Wan03)
                                    , @c_AreaKey = '?F' -- ?F=Get from location areakey  
                                    , @c_UserPosition = '1'
                                    , @c_CallSource = 'WAVE'
                                    , @c_LinkTaskToPick = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                                    , @c_LinkTaskToPick_SQL = @c_LinkTaskToPick_SQL
                                    , @c_WIP_RefNo = @c_SourceType
                                    , @b_Success = @b_Success OUTPUT
                                    , @n_Err = @n_err OUTPUT
                                    , @c_ErrMsg = @c_errmsg OUTPUT
                                    , @c_Taskdetailkey = @c_Taskdetailkey OUTPUT
            
            IF @b_Success <> 1
            BEGIN
               SELECT @n_continue = 3
            END

            IF @n_Continue = 1                                                         --(Wan03) - START
            BEGIN
               IF @c_GroupKey = ''                                                     
               BEGIN
                  SET @c_GroupKey = @c_Taskdetailkey
               END 
               
               UPDATE TASKDETAIL WITH (ROWLOCK)
               SET Groupkey = @c_GroupKey       --@c_Taskdetailkey                     --(Wan03)    
               WHERE TaskDetailKey = @c_Taskdetailkey
            END                                                                        --(Wan03) - END
            
            --Manual Lock Qty for FinalLoc
            --EXEC rdt.rdt_Putaway_PendingMoveIn 
            --             @cUserName = ''
            --            ,@cType = 'LOCK'
            --            ,@cFromLoc = @c_FromLoc
            --            ,@cFromID = @c_ID
            --            ,@cSuggestedLOC = @c_FinalLoc
            --            ,@cStorerKey = @c_Storerkey
            --            ,@nErrNo = @n_Err OUTPUT
            --            ,@cErrMsg = @c_Errmsg OUTPUT
            --            ,@cSKU = @c_Sku
            --            ,@nPutawayQTY    = @n_Qty
            --            ,@cFromLOT       = @c_Lot
            --            ,@cTaskDetailKey = @c_TaskdetailKey
            --            ,@nFunc = 0
            --            ,@nPABookingKey = 0
            --            ,@cMoveQTYAlloc = '1' 
         END

         NEXT_PICK_VNA:                                                             --(Wan05)
         FETCH NEXT FROM CUR_PICK_VNAOUT INTO @c_Storerkey, @c_SKU, @c_Lot, @c_FromLoc, @c_ID
                                             ,@c_UOM, @n_UOMQty, @n_Qty, @c_Loadkey, @c_Orderkey
      END
      CLOSE CUR_PICK_VNAOUT
      DEALLOCATE CUR_PICK_VNAOUT
   END

   --FCP Task for UOM 2/3
   IF (@n_continue = 1 OR @n_continue = 2)                                          --(Wan03)
   BEGIN
      IF @c_AllowOverAllocations = '1' OR @b_FPP = 0                                --(Wan05)
      BEGIN
         DECLARE CUR_PICK_FCP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
          SELECT PICKDETAIL.Storerkey 
               , PICKDETAIL.Sku 
               , PICKDETAIL.Lot
               , PICKDETAIL.Loc 
               , PICKDETAIL.ID 
               , MAX(PICKDETAIL.UOM) 
               , SUM(PICKDETAIL.UOMQty) AS UOMQty 
               , SUM(PICKDETAIL.Qty) AS Qty 
               , ORDERS.LoadKey
               , ORDERS.OrderKey
               , ReplFromLoc = ''                                                   --(Wan03)
               , ReplFromID  = ''                                                   --(Wan03)
               , ReplTaskKey = ''                                                   --(Wan04)                     
          FROM WAVEDETAIL (NOLOCK) 
          JOIN WAVE (NOLOCK) ON WAVEDETAIL.WaveKey = WAVE.WaveKey 
          JOIN ORDERS (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey 
          JOIN #PickDetail_WIP PICKDETAIL ON ORDERS.OrderKey = PICKDETAIL.OrderKey 
          JOIN LOC (NOLOCK) ON LOC.LOC = PICKDETAIL.LOC
          WHERE WAVEDETAIL.WaveKey = @c_Wavekey  
          AND PICKDETAIL.[Status] = '0'  
          AND PICKDETAIL.WIP_Refno = @c_SourceType 
          AND PICKDETAIL.UOM IN ('2','3','6')                                       --2025-07-09 UOM 6 could be manual allocate                                  
          AND LOC.LocationType = 'VNA'
          GROUP BY PICKDETAIL.Storerkey 
               , PICKDETAIL.Sku 
               , PICKDETAIL.Lot
               , PICKDETAIL.Loc 
               , PICKDETAIL.ID 
               , ORDERS.LoadKey
               , ORDERS.OrderKey
      END
      ELSE
      BEGIN
         --ML11 OR No Lot07 ='' with Replenishment
         DECLARE CUR_PICK_FCP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
         SELECT PICKDETAIL.Storerkey 
            , PICKDETAIL.Sku 
            , PICKDETAIL.Lot
            , TaskDetail.FinalLoc 
            , TaskDetail.FinalID
            , MAX(PICKDETAIL.UOM) AS UOM
            , SUM(PICKDETAIL.UOMQty) AS UOMQty 
            , SUM(PICKDETAIL.Qty) AS Qty 
            , ORDERS.LoadKey
            , ORDERS.OrderKey
            , ReplFromLoc = TaskDetail.FromLoc                                      --(Wan03)
            , ReplFromID  = TaskDetail.FromID                                       --(Wan03)
            , ReplTaskKey = TaskDetail.TaskDetailKey                                --(Wan04)            
         FROM WAVEDETAIL (NOLOCK) 
         JOIN WAVE (NOLOCK) ON WAVEDETAIL.WaveKey = WAVE.WaveKey 
         JOIN ORDERS (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey 
         JOIN #PickDetail_WIP PICKDETAIL ON ORDERS.OrderKey = PICKDETAIL.OrderKey 
         JOIN LOC (NOLOCK) ON LOC.LOC = PICKDETAIL.LOC
         JOIN TaskDetail (NOLOCK) ON  TaskDetail.Storerkey = PICKDETAIL.Storerkey
                                  AND TaskDetail.TaskType IN ( 'VNAOUT', 'RPF' )   --2025-07-09 --(Wan03)
                                  AND TaskDetail.FromLoc  = PICKDETAIL.Loc
                                  AND TaskDetail.FromID   = PICKDETAIL.ID
                                  AND TaskDetail.[Status] NOT IN ('9','X')
                                  AND TaskDetail.Message03 = 'RPF'
         WHERE WAVEDETAIL.WaveKey = @c_Wavekey  
         AND PICKDETAIL.[Status] = '0'  
         AND PICKDETAIL.WIP_Refno = @c_SourceType 
         AND PICKDETAIL.UOM IN ('2','3','6')                                        --2025-07-09
         AND LOC.LocationType IN ('VNA','BULK')                                     --(Wan05)
         GROUP BY PICKDETAIL.Storerkey 
            , PICKDETAIL.Sku 
            , PICKDETAIL.Lot
            , TaskDetail.FinalLoc 
            , TaskDetail.FinalID
            , ORDERS.LoadKey
            , ORDERS.OrderKey
            , TaskDetail.FromLoc                                                    --(Wan03)
            , TaskDetail.FromID                                                     --(Wan03)
            , TaskDetail.TaskDetailKey                                              --(Wan04)            
      END

      OPEN CUR_PICK_FCP

      FETCH NEXT FROM CUR_PICK_FCP INTO @c_Storerkey, @c_SKU, @c_Lot, @c_FromLoc, @c_ID
                                       ,@c_UOM, @n_UOMQty, @n_Qty, @c_Loadkey, @c_Orderkey
                                       ,@c_ReplFromLoc, @c_ReplFromID, @c_ReplTaskKey              --(Wan04)                                       

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF  @c_AllowOverAllocations = '0' AND @b_FPP = 0                           --(Wan05) - START
         BEGIN
             IF EXISTS ( SELECT 1
                         FROM TASKDETAIL td (NOLOCK) 
                         WHERE td.Wavekey = @c_Wavekey
                         AND td.TaskType  IN ('VNAOUT', 'FPK')
                         AND td.Storerkey = @c_Storerkey
                         AND td.Status    = '0'
                         AND td.Lot       = @c_LOT 
                         AND td.FromLoc   = @c_FromLoc 
                         AND td.FromID    = @c_ID
                       )
             BEGIN
                 GOTO NEXT_PICK_FCP
             END
         END                                                                        --(Wan05) - END
         
         SET @c_ToLoc = N''
         SET @c_FinalLoc = N''
         SET @c_PickMethod = N'PP'
         SET @c_TaskType = N'FCP'
         SET @c_Message03 = N'FPK'
         SET @c_SourcePriority = '9'
         SET @c_Priority = CASE WHEN @c_AllowOverAllocations = '1 '                 --(Wan03)                                         
                                THEN '9' 
                                ELSE @c_Priority_PICK 
                                END 
         SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.UOM IN (''2'',''3'',''6'') AND '   --2025-07-09 --(Wan03)
                                   + 'LOC.LocationType = ''VNA'''
         SET @c_TaskStatus = CASE WHEN @b_FPP = 1                                   --(Wan05) --(Wan03)
                                  THEN 'H' 
                                  ELSE '0' 
                                  END                                                   

         --(Wan01) - START
         IF @c_LoadAssignLane = 'Y'
         BEGIN
            IF @c_Loadkey <> '' OR @c_Loadkey IS NULL
            BEGIN 
               SELECT TOP 1 @c_ToLoc = lpld.Loc
               FROM LoadPlanLaneDetail lpld(NOLOCK) 
               WHERE lpld.Loadkey = @c_Loadkey
               AND   lpld.LocationCategory = 'STAGING'
            END
         END
         ELSE
         BEGIN
            SELECT @c_ToLoc = ISNULL(ORDERS.Door, '')
            FROM ORDERS WITH (NOLOCK)
            WHERE ORDERS.OrderKey = @c_Orderkey
         END
         --(Wan01) - END

         IF ISNULL(@c_ToLoc,'') = ''
         BEGIN
            SELECT @n_continue = 3  
            SELECT @n_err = 67830    
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)
                             +': Invalid Outbound Staging Loc from '
                             + CASE WHEN @c_LoadAssignLane = 'Y'                    --(Wan01)
                                    THEN 'Assign Lane'
                                    ELSE 'ORDERS.Door'
                                    END
                             +'. (ispRLWAV69)'                
                   
         END
         ELSE IF NOT EXISTS (SELECT 1 FROM LOC (NOLOCK) WHERE LOC = @c_ToLoc)
         BEGIN
            SELECT @n_continue = 3  
            SELECT @n_err = 67835    
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)+': Loc not found in Loc table. (ispRLWAV69)'         
         END 
         ELSE
         BEGIN
            --(Wan02) - START
            SET @n_Qty_Pick = @n_Qty
            SET @n_Qty_Avail = 0
            SET @n_Qty_Task  = 0
               
            IF @c_AllowOverAllocations = '1'                                        --(Wan03) - START 
            BEGIN                                                                    
               SELECT @n_Qty_Avail = lli.Qty - lli.Qtypicked
               FROM LOTxLOCxID lli (NOLOCK)
               WHERE lli.Lot = @c_Lot
               AND   lli.Loc = @c_FromLoc
               AND   lli.ID  = @c_ID

               IF @n_Qty_Avail > 0
               BEGIN
                  SELECT @n_Qty_Task = ISNULL(SUM(qty),0)
                  FROM TaskDetail td(NOLOCK)
                  WHERE td.Storerkey= @c_Storerkey
                  AND   td.Sku      = @c_Sku
                  AND   td.Tasktype = 'FCP'
                  AND   td.Lot      = @c_Lot
                  AND   td.FromLoc  = @c_FromLoc
                  AND   td.FromID   = @c_ID
                  AND   td.[Status] NOT IN ('X', '9')
                  AND   td.CaseID   = ''

                  SET @n_Qty_Avail = @n_Qty_Avail - @n_Qty_Task
               END
            END                                                                     --(Wan03) - END

            WHILE @n_Qty_Pick > 0 AND @n_continue = 1
            BEGIN
               IF @n_Qty_Pick > @n_Qty_Avail AND @n_Qty_Avail > 0
               BEGIN
                  SET @n_Qty = @n_Qty_Avail
               END
               ELSE
               BEGIN
                  SET @n_Qty = @n_Qty_Pick
               END

               SET @n_Qty_Pick = @n_Qty_Pick - @n_Qty                 

               SET @c_Taskdetailkey = ''
               EXEC isp_InsertTaskDetail @c_TaskType = @c_TaskType
                                       , @c_Storerkey = @c_Storerkey
                                       , @c_Sku = @c_Sku
                                       , @c_Lot = @c_Lot
                                       , @c_UOM = @c_UOM
                                       , @n_UOMQty = @n_UOMQty
                                       , @n_Qty = @n_Qty
                                       , @c_FromLoc = @c_FromLoc
                                       , @c_LogicalFromLoc = '?'
                                       , @c_FromID = @c_ID
                                       , @c_ToLoc = @c_ToLoc
                                       , @c_LogicalToLoc = '?'
                                       , @c_ToID = @c_ID
                                       , @c_FinalID = @c_ID
                                       , @c_PickMethod = @c_PickMethod
                                       , @c_Priority = @c_Priority
                                       , @c_SourcePriority = @c_SourcePriority
                                       , @c_SourceType = @c_SourceType
                                       , @c_SourceKey = @c_Wavekey
                                       , @c_WaveKey = @c_Wavekey
                                       , @c_Loadkey = @c_Loadkey
                                       , @c_OrderKey = @c_Orderkey
                                       , @c_Message03 = @c_Message03
                                       , @n_SystemQty = @n_Qty
                                       , @c_Status = @c_TaskStatus                  --(Wan03)--(SSA01)
                                       , @c_AreaKey = '?F' -- ?F=Get from location areakey  
                                       , @c_UserPosition = '1'
                                       , @c_CallSource = 'WAVE'
                                       , @c_ReservePendingMoveIn = 'Y'
                                       , @c_LinkTaskToPick = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                                       , @c_LinkTaskToPick_SQL = @c_LinkTaskToPick_SQL
                                       , @c_WIP_RefNo = @c_SourceType
                                       , @c_RefTaskKey= @c_ReplTaskKey              --(Wan04)
                                       , @b_Success = @b_Success OUTPUT
                                       , @n_Err = @n_err OUTPUT
                                       , @c_ErrMsg = @c_errmsg OUTPUT
                                       , @c_Taskdetailkey = @c_Taskdetailkey OUTPUT
            
               IF @b_Success <> 1
               BEGIN
                  SELECT @n_continue = 3
               END
            
               IF @n_continue = 1
               BEGIN
                  IF @c_GroupKey = ''                                               --(Wan03) - START
                  BEGIN
                     SET @c_GroupKey = @c_Taskdetailkey
                  END                                                               --(Wan03) - END  
    
                  UPDATE TASKDETAIL WITH (ROWLOCK)
              --  SET Groupkey = @c_Taskdetailkey                       VPA235
                  SET Groupkey = CASE WHEN @c_AllowOverAllocations = '1'            --(Wan03)
                                      THEN @c_Loadkey  
                                      ELSE @c_GroupKey
                                      END
                  WHERE TaskDetailKey = @c_Taskdetailkey

                  IF @@ERROR <> 0
                  BEGIN
                     SET @n_continue = 3
                  END
               END
               
               IF @n_continue = 1 AND @c_ReplFromLoc > ''            --(Wan03) - START
               BEGIN
                  UPDATE #PickDetail_WIP
                     SET TaskDetailKey = @c_TaskDetailKey
                  WHERE Lot = @c_Lot
                  AND   Loc = @c_ReplFromLoc
                  AND   ID  = @c_ReplFromID
                  AND   UOM IN ('2','3','6')                         --2025-07-09
               END                                                   --(Wan03) - END
            END                                                      --(Wan02) - END
         END
         
         NEXT_PICK_FCP:                                                             --(Wan05)
         FETCH NEXT FROM CUR_PICK_FCP INTO @c_Storerkey, @c_SKU, @c_Lot, @c_FromLoc, @c_ID
                                          ,@c_UOM, @n_UOMQty, @n_Qty, @c_Loadkey, @c_Orderkey
                                          ,@c_ReplFromLoc, @c_ReplFromID, @c_ReplTaskKey           --(Wan04)                                          
      END
      CLOSE CUR_PICK_FCP
      DEALLOCATE CUR_PICK_FCP
   END

   --NONVNA & NONBULK
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE CUR_PICK_NONVNA CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
      SELECT PICKDETAIL.Storerkey 
         , PICKDETAIL.Sku 
         , PICKDETAIL.Lot
         , PICKDETAIL.Loc 
         , PICKDETAIL.ID 
         , MAX(PICKDETAIL.UOM) 
         , SUM(PICKDETAIL.UOMQty) AS UOMQty 
         , SUM(PICKDETAIL.Qty) AS Qty 
         , ORDERS.LoadKey
         , ORDERS.OrderKey
      FROM WAVEDETAIL (NOLOCK) 
      JOIN WAVE (NOLOCK) ON WAVEDETAIL.WaveKey = WAVE.WaveKey 
      JOIN ORDERS (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey 
      JOIN #PickDetail_WIP PICKDETAIL ON ORDERS.OrderKey = PICKDETAIL.OrderKey 
      JOIN LOC (NOLOCK) ON LOC.LOC = PICKDETAIL.LOC
      WHERE WAVEDETAIL.WaveKey = @c_Wavekey  
      AND PICKDETAIL.[Status] = '0'  
      AND PICKDETAIL.WIP_Refno = @c_SourceType 
      AND LOC.LocationType NOT IN ('VNA')                                           --2025-08-05--(Wan05)
      AND NOT EXISTS (SELECT 1                                                      --2025-08-11- Fixed
                      WHERE PICKDETAIL.UOM > '1'
                      AND PICKDETAIL.TaskDetailKey > ''                             --2025-08-12- Fixed
                      AND @c_AllowOverAllocations = '0' AND @b_FPP = 1
                      )      
      GROUP BY PICKDETAIL.Storerkey 
            , PICKDETAIL.Sku 
            , PICKDETAIL.Lot
            , PICKDETAIL.Loc 
            , PICKDETAIL.ID 
            , ORDERS.LoadKey
            , ORDERS.OrderKey
            , PICKDETAIL.UOM
      ORDER BY PICKDETAIL.UOM, PICKDETAIL.Sku, PICKDETAIL.Lot, PICKDETAIL.Loc, PICKDETAIL.ID

      OPEN CUR_PICK_NONVNA

      FETCH NEXT FROM CUR_PICK_NONVNA INTO @c_Storerkey, @c_SKU, @c_Lot, @c_FromLoc, @c_ID
                                          ,@c_UOM, @n_UOMQty, @n_Qty, @c_Loadkey, @c_Orderkey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @c_ToLoc = N''
         SET @c_FinalLoc = N''
         SET @c_PickMethod = IIF(@c_UOM = '1', N'FP', N'PP')
         SET @c_TaskType   = IIF(@c_UOM = '1', N'FPK', N'FCP')
         SET @c_Message03 = N'FPK'
         SET @c_SourcePriority = '9'
         SET @c_Priority = CASE WHEN @c_AllowOverAllocations = '1'                  --(Wan03)                                         
                                THEN '9' 
                                ELSE @c_Priority_PICK 
                                END 
         SET @c_TaskStatus = '0'                                                    --(Wan03)

         SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.UOM = @c_UOM AND '                 --2025-07-09 --(Wan03) -- 2025-06-20
                                   + 'LOC.LocationType <> ''VNA'''

         --(Wan01) - START
         IF @c_LoadAssignLane = 'Y'  
         BEGIN
            IF @c_Loadkey <> '' OR @c_Loadkey IS NULL
            BEGIN 
               SELECT TOP 1 @c_ToLoc = lpld.Loc
               FROM LoadPlanLaneDetail lpld(NOLOCK) 
               WHERE lpld.Loadkey = @c_Loadkey
               AND   lpld.LocationCategory = 'STAGING'
            END
         END
         ELSE
         BEGIN
            SELECT @c_ToLoc = ISNULL(ORDERS.Door, '')
            FROM ORDERS WITH (NOLOCK)
            WHERE ORDERS.OrderKey = @c_Orderkey
         END
         --(Wan01) - END

         IF ISNULL(@c_ToLoc,'') = ''
         BEGIN
            SELECT @n_continue = 3  
            SELECT @n_err = 67845    
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)
                             +': Invalid Outbound Staging Loc from '
                             + CASE WHEN @c_LoadAssignLane = 'Y'                    --(Wan01)
                                    THEN 'Assign Lane'
                                    ELSE 'ORDERS.Door'
                                    END
                             +'. (ispRLWAV69)'                
         END
         ELSE IF NOT EXISTS (SELECT 1 FROM LOC (NOLOCK) WHERE LOC = @c_ToLoc)
         BEGIN
            SELECT @n_continue = 3  
            SELECT @n_err = 67850    
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)+': Loc not found in Loc table. (ispRLWAV69)'         
         END 
         ELSE
         BEGIN
            --(Wan02) - START
            SET @n_Qty_Pick  = @n_Qty
            SET @n_Qty_Avail = 0
            SET @n_Qty_Task  = 0

            IF @c_UOM IN ('2','3','6') AND @c_AllowOverAllocations = '0'            --2025-07-09 --(Wan03) - START
            BEGIN
               IF EXISTS ( SELECT 1 FROM LOC l (NOLOCK)    --If from manual allocation
                           WHERE l.Loc = @c_FromLoc
                           AND l.LocationType IN ('PND')
                         )
               BEGIN
                  SET @c_TaskStatus = 'H'
               END
            END
            ELSE IF @c_UOM IN ('2','3','6') AND @c_AllowOverAllocations = '1'       --2025-07-09 --(Wan03) - END
            BEGIN
               SELECT @n_Qty_Avail = lli.Qty - lli.Qtypicked
               FROM LOTxLOCxID lli (NOLOCK)
               WHERE lli.Lot = @c_Lot
               AND   lli.Loc = @c_FromLoc
               AND   lli.ID  = @c_ID

               IF @n_Qty_Avail > 0
               BEGIN
                  SELECT @n_Qty_Task = ISNULL(SUM(qty),0)
                  FROM TaskDetail td(NOLOCK)
                  WHERE td.Storerkey= @c_Storerkey
                  AND   td.Sku      = @c_Sku
                  AND   td.Tasktype = 'FCP'
                  AND   td.Lot      = @c_Lot
                  AND   td.FromLoc  = @c_FromLoc
                  AND   td.FromID   = @c_ID
                  AND   td.[Status] NOT IN ('X', '9')
                  AND   td.CaseID   = ''

                  SET @n_Qty_Avail = @n_Qty_Avail - @n_Qty_Task
               END
            END

            WHILE @n_Qty_Pick > 0 AND @n_Continue = 1
            BEGIN
               IF @n_Qty_Pick > @n_Qty_Avail AND @n_Qty_Avail > 0
               BEGIN
                  SET @n_Qty = @n_Qty_Avail
               END               
               ELSE
               BEGIN
                  SET @n_Qty = @n_Qty_Pick
               END
               SET @n_Qty_Pick = @n_Qty_Pick - @n_Qty     

               SET @c_Taskdetailkey = ''
               EXEC isp_InsertTaskDetail @c_TaskType = @c_TaskType
                                       , @c_Storerkey = @c_Storerkey
                                       , @c_Sku = @c_Sku
                                       , @c_Lot = @c_Lot
                                       , @c_UOM = @c_UOM
                                       , @n_UOMQty = @n_UOMQty
                                       , @n_Qty = @n_Qty
                                       , @c_FromLoc = @c_FromLoc
                                       , @c_LogicalFromLoc = '?'
                                       , @c_FromID = @c_ID
                                       , @c_ToLoc = @c_ToLoc
                                       , @c_LogicalToLoc = '?'
                                       , @c_ToID = @c_ID
                                       , @c_FinalID = @c_ID
                                       , @c_PickMethod = @c_PickMethod
                                       , @c_Priority = @c_Priority
                                       , @c_SourcePriority = @c_SourcePriority
                                       , @c_SourceType = @c_SourceType
                                       , @c_SourceKey = @c_Wavekey
                                       , @c_WaveKey = @c_Wavekey
                                       , @c_Loadkey = @c_Loadkey
                                       , @c_OrderKey = @c_Orderkey
                                       , @c_Message03 = @c_Message03
                                       , @n_SystemQty = @n_Qty
                                       , @c_Status = @c_TaskStatus                  --(Wan03)
                                       , @c_AreaKey = '?F' -- ?F=Get from location areakey  
                                       , @c_UserPosition = '1'
                                       , @c_CallSource = 'WAVE'
                                       , @c_LinkTaskToPick = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                                       , @c_LinkTaskToPick_SQL = @c_LinkTaskToPick_SQL
                                       , @c_WIP_RefNo = @c_SourceType
                                       , @b_Success = @b_Success OUTPUT
                                       , @n_Err = @n_err OUTPUT
                                       , @c_ErrMsg = @c_errmsg OUTPUT
                                       , @c_Taskdetailkey = @c_Taskdetailkey OUTPUT
            
               IF @b_Success <> 1
               BEGIN
                  SELECT @n_continue = 3
               END
            
               IF @n_continue = 1
               BEGIN
                  IF @c_GroupKey = ''                                               --(Wan03) - START
                  BEGIN
                     SET @c_GroupKey = @c_Taskdetailkey
                  END                                                               --(Wan03) - END  
    
                  UPDATE TASKDETAIL WITH (ROWLOCK)
            --    SET Groupkey = @c_Taskdetailkey              VPA235
                  SET Groupkey = CASE WHEN @c_AllowOverAllocations = '1'            --(Wan03)
                                      THEN @c_Loadkey  
                                      ELSE @c_GroupKey
                                      END
                  WHERE TaskDetailKey = @c_Taskdetailkey

                  IF @@ERROR <> 0
                  BEGIN
                     SET @n_continue = 3
                  END
               END
            END                                                      --(Wan02) - END
         END

         FETCH NEXT FROM CUR_PICK_NONVNA INTO @c_Storerkey, @c_SKU, @c_Lot, @c_FromLoc, @c_ID
                                             ,@c_UOM, @n_UOMQty, @n_Qty, @c_Loadkey, @c_Orderkey
      END
      CLOSE CUR_PICK_NONVNA
      DEALLOCATE CUR_PICK_NONVNA
   END

   -----Update pickdetail_WIP work in progress staging table back to pickdetail 
   IF @n_continue = 1 or @n_continue = 2
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
         ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
           
      IF @b_Success <> 1
      BEGIN
         SET @n_continue = 3
      END             
   END
 
   -----Generate Discrete Pickslip
   --IF (@n_continue = 1 or @n_continue = 2) AND @c_DocType = 'N'
   --BEGIN
   --   EXEC isp_CreatePickSlip
   --           @c_Wavekey = @c_Wavekey
   --          ,@c_LinkPickSlipToPick = 'Y'  --Y=Update pickslipno to pickdetail.pickslipno 
   --          ,@c_ConsolidateByLoad = 'N'
   --          ,@c_AutoScanIn = 'Y'
   --          ,@c_Refkeylookup = 'N'
   --          ,@b_Success = @b_Success OUTPUT
   --          ,@n_Err = @n_err OUTPUT 
   --          ,@c_ErrMsg = @c_errmsg OUTPUT          
         
   --   IF @b_Success = 0
   --      SELECT @n_continue = 3   
   --END  

   -----Update Wave Status-----
   IF @n_continue = 1 or @n_continue = 2  
   BEGIN  
      UPDATE WAVE     
      SET TMReleaseFlag = 'Y'             
       ,  TrafficCop = NULL               
       ,  EditWho = SUSER_SNAME()         
       ,  EditDate= GETDATE()             
      WHERE WAVEKEY = @c_Wavekey      
   
      SELECT @n_err = @@ERROR
        
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 67840   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_err)+': Update on wave Failed (ispRLWAV69)' + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '  
      END  
   END  

   RETURN_SP:
   -----Delete pickdetail_WIP work in progress staging table
   IF @n_continue = 1 or @n_continue = 2  
   BEGIN
      EXEC isp_CreatePickdetail_WIP
          @c_Loadkey               = ''
         ,@c_Wavekey               = @c_Wavekey  
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
   
   IF OBJECT_ID('#PickDetail_WIP') IS NOT NULL
   BEGIN 
      DROP TABLE #PickDetail_WIP
   END
   
   IF OBJECT_ID('#ZoneAisle') IS NOT NULL                                               --2025-07-29
   BEGIN 
      DROP TABLE #ZoneAisle
   END   

   IF CURSOR_STATUS('LOCAL', 'Orders_Pickdet_cur') IN (0 , 1)
   BEGIN
      CLOSE Orders_Pickdet_cur
      DEALLOCATE Orders_Pickdet_cur   
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_PICK_VNAOUT') IN (0 , 1)
   BEGIN
      CLOSE CUR_PICK_VNAOUT
      DEALLOCATE CUR_PICK_VNAOUT   
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_PICK_FCP') IN (0 , 1)
   BEGIN
      CLOSE CUR_PICK_FCP
      DEALLOCATE CUR_PICK_FCP   
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_PICK_NONVNA') IN (0 , 1)
   BEGIN
      CLOSE CUR_PICK_NONVNA
      DEALLOCATE CUR_PICK_NONVNA   
   END

   IF @n_continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SELECT @b_success = 0    
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_Starttcnt    
      BEGIN    
         ROLLBACK TRAN    
      END    
      ELSE    
      BEGIN    
         WHILE @@TRANCOUNT > @n_Starttcnt    
         BEGIN    
            COMMIT TRAN    
         END    
      END    
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispRLWAV69'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
      RETURN    
   END    
   ELSE    
   BEGIN    
      SELECT @b_success = 1    
      WHILE @@TRANCOUNT > @n_Starttcnt    
      BEGIN    
         COMMIT TRAN    
      END    
      RETURN    
   END
END --sp end
GO
GRANT EXECUTE ON [dbo].[ispRLWAV69] TO [NSQL]
GO