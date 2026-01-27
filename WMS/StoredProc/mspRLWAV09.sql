SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
/**************************************************************************/    
/* Stored Procedure: mspRLWAV09                                           */    
/* Creation Date: 2025-12-05                                              */    
/* Copyright: Maersk                                                      */    
/* Written by: Wan                                                        */    
/*                                                                        */    
/* Purpose: FCR-9008 - ONBR Release Wave                                  */  
/*                                                                        */  
/* Called By: Wave Release                                                */    
/*          : Duplicate and Modify from Mattel mspRLWAV01                 */    
/* PVCS Version: 1.0                                                      */    
/*                                                                        */    
/* Data Modifications:                                                    */    
/*                                                                        */    
/* Updates:                                                               */    
/* Date        Author   Ver   Purposes                                    */    
/**************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV09]        
   @c_Wavekey     NVARCHAR(10)    
,  @b_Success     INT            = 1   OUTPUT    
,  @n_err         INT            = 0   OUTPUT    
,  @c_errmsg      NVARCHAR(250)  = ''  OUTPUT    
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
      
   DECLARE @n_Continue                 int = 1     
         , @n_starttcnt                int = @@TRANCOUNT         -- Holds the current transaction count    
         , @n_debug                    int = 0 
         , @n_cnt                      int = 0

         , @n_UCCPerToteID             INT = 0
         , @n_MaxUCCPerToteID          INT = 14

   DECLARE @c_Storerkey                NVARCHAR(15)   = ''  
         , @c_Facility                 NVARCHAR(5)    = ''
         , @c_Taskdetailkey            NVARCHAR(10)   = ''
         , @c_TaskType                 NVARCHAR(10)   = ''           
         , @c_SourceType               NVARCHAR(30)   = ''
         , @c_WaveType                 NVARCHAR(10)   = ''
         , @c_Sku                      NVARCHAR(20)   = ''
         , @c_Lot                      NVARCHAR(10)   = ''
         , @c_FromLoc                  NVARCHAR(10)   = ''                       
         , @c_FromID                   NVARCHAR(18)   = ''  
         , @c_Toloc                    NVARCHAR(10)   = '' 
         , @c_ToID                     NVARCHAR(18)   = ''
         , @c_Finalloc                 NVARCHAR(10)   = '' 
         , @c_FinalID                  NVARCHAR(18)   = ''
         , @c_FinalLocPAZone           NVARCHAR(10)   = '' 
         , @c_FinalLocPAZone_P         NVARCHAR(10)   = '' 
         , @c_FinalLocLoseiD           NVARCHAR(10)   = ''  
         , @n_LocLevel                 INT            = 0
         , @n_Qty                      INT            = 0
         , @n_UOMQty                   INT            = 0
         , @c_UOM                      NVARCHAR(10)   = ''
         , @c_Orderkey                 NVARCHAR(10)   = ''
         , @c_LoadKey                  NVARCHAR(10)   = ''
         , @c_RefTaskkey               NVARCHAR(10)   = ''
         , @c_Groupkey                 NVARCHAR(10)   = ''
         , @c_Priority                 NVARCHAR(10)   = ''           
         , @c_PickMethod               NVARCHAR(10)   = ''  
         , @C_Zip                      NVARCHAR(18)   = ''           
         , @c_LinkTaskToPick_SQL       NVARCHAR(4000) = '' 

         , @c_Route                    NVARCHAR(10)   = ''
         , @c_DefaultLoc               NVARCHAR(10)   = ''
         , @c_CustomToLoc              NVARCHAR(10)   = ''                          --2026-01-12
         , @dt_deliveryDate            DATETIME        
         , @c_DispatchCasePickMethod   NVARCHAR(10)   = ''
         , @c_TaskStatus               NVARCHAR(10)   = '0'                            
         , @n_QtyNeed                  INT            = 0                            
         , @n_QtyToReplen              INT            = 0                              
         , @c_LPLDLoc                  NVARCHAR(10)   = ''                           
         , @c_Areakey                  NVARCHAR(10)   = ''
         , @c_Orderkey_P               NVARCHAR(10)   = '' 
         , @c_UOM_P                    NVARCHAR(10)   = '' 
         , @c_Areakey_P                NVARCHAR(10)   = '' 
         , @c_ToLoc_P                  NVARCHAR(10)   = '' 

         , @n_Volume                   FLOAT = 0.00  
         , @n_TTLVolume                FLOAT = 0.00           
         , @n_CubeUOM1                 FLOAT = 0.00        
         , @n_CubeUOM3                 FLOAT = 0.00 
         , @n_MaxSkuVol                FLOAT = 0.00 
         , @n_MaxUCCVol                FLOAT = 0.00          
         , @n_DropIDVol                FLOAT = 0.00  
         , @n_QtyToRelease             INT = 0
         , @n_UOMQtyToRelease          INT = 0
         , @n_NoOfGroup                INT = 0
         , @n_MaxQtyPerGroup           INT = 0
         , @n_Casecnt                  INT = 0
         , @c_UCCNo                    NVARCHAR(20) = ''  
         , @n_UCC_RowRef               INT = 0 

         , @c_SQL                      NVARCHAR(MAX)  = ''
         , @c_SQLParms                 NVARCHAR(1000) = ''

         , @c_KeyName                  NVARCHAR(18)   = '' 
         , @c_Option5                  NVARCHAR(MAX)  = '' 
         , @c_MaxSkuVol                NVARCHAR(10)   = '' 
         , @c_MaxUCCVol                NVARCHAR(10)   = '' 

         , @cur_waveord                CURSOR
         , @cur_WaveReplfr             CURSOR                                        
         , @cur_WaveReplto             CURSOR                                        
         , @cur_WaveReplLot            CURSOR
         , @cur_pick                   CURSOR
 
   SET @b_success = 0
   SET @n_err = 0
   SET @c_errmsg = ''
   SET @c_SourceType = 'mspRLWAV09'      
   SET @c_Priority   = '9'  
   SET @c_TaskType   = 'FCP'  
   SET @c_PickMethod = 'PP'  
  
   -----Get Storerkey and facility  
   IF  (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      SELECT TOP 1 @c_Storerkey = O.Storerkey  
                  ,@c_Facility = O.Facility 
                  ,@c_Loadkey  = O.Loadkey
                  ,@c_WaveType = W.WaveType 
                  ,@c_DispatchCasePickMethod = w.DispatchCasePickMethod
      FROM WAVE W (NOLOCK)  
      JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey  
      JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey  
      AND  W.Wavekey = @c_Wavekey 
      ORDER BY o.Loadkey
        
      IF @c_Loadkey = ''
      BEGIN  
         SET @n_Continue = 3    
         SET @n_err = 83010    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Loadplan has not generated yet. (mspRLWAV09)'         
      END 
   END

   -----Wave Validation-----              
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN   
      IF NOT EXISTS (SELECT 1   
                     FROM WAVEDETAIL WD (NOLOCK)  
                     JOIN PICKDETAIL PD (NOLOCK) ON WD.Orderkey = PD.Orderkey  
                     LEFT JOIN TASKDETAIL TD (NOLOCK) ON  PD.Taskdetailkey = TD.Taskdetailkey 
                                                      AND TD.Sourcetype = @c_SourceType 
                                                      AND TD.Tasktype IN ('FPK','FCP','FPP') 
                                                      AND TD.[Status] <> 'X'                                                       
                     WHERE WD.Wavekey = @c_Wavekey                     
                     AND PD.Status = '0'  
                     AND TD.Taskdetailkey IS NULL  
                  )  
      BEGIN  
         SET @n_Continue = 3    
         SET @n_err = 83020    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Nothing to release. (mspRLWAV09)'         
      END        
   END  
   
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      SELECT @c_Option5 = fgr.Option5 
      FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'ReleaseWave_SP') AS fgr
   
      SELECT @c_MaxSkuVol = dbo.fnc_GetParamValueFromString('@n_MaxSkuVol', @c_Option5, @c_MaxSkuVol) 
      SET @c_MaxUCCVol = '-1' --NOT UCC Pick, IF UCC Picking, Mandatory to setup value >=0
      SELECT @c_MaxUCCVol = dbo.fnc_GetParamValueFromString('@n_MaxUCCVol', @c_Option5, @c_MaxUCCVol)

      IF ISNUMERIC(@c_MaxSkuVol) = 1
         SET @n_MaxSkuVol = CAST(@c_MaxSkuVol AS FLOAT)
      ELSE
         SET @n_MaxSkuVol = 0.00

      IF ISNUMERIC(@c_MaxUCCVol) = 1
         SET @n_MaxUCCVol = CAST(@c_MaxUCCVol AS FLOAT)
      ELSE
         SET @n_MaxUCCVol = -1.00
   END
         
   --Create pickdetail Work in progress temporary table  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN 
      IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL  
         DROP TABLE #PICKDETAIL_WIP   

      CREATE TABLE #PickDetail_WIP
      (  
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
      ,  [UOMQty]          [int] NOT NULL DEFAULT ((0))   
      ,  [Qty]             [int] NOT NULL DEFAULT ((0)) 
      ,  [QtyMoved]        [int] NOT NULL DEFAULT ((0))  
      ,  [Status]          [nvarchar](10) NOT NULL DEFAULT ('0')   
      ,  [DropID]          [nvarchar](20) NOT NULL DEFAULT ('')  
      ,  [Loc]             [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN')   
      ,  [ID]              [nvarchar](18) NOT NULL DEFAULT (' ')   
      ,  [PackKey]         [nvarchar](10) NULL DEFAULT (' ')   
      ,  [UpdateSource]    [nvarchar](10) NULL DEFAULT ('0')   
      ,  [CartonGroup]     [nvarchar](10) NULL  
      ,  [CartonType]      [nvarchar](10) NULL 
      ,  [ToLoc]           [nvarchar](10) NULL  DEFAULT (' ')  
      ,  [DoReplenish]     [nvarchar](1)  NULL DEFAULT ('N') 
      ,  [ReplenishZone]   [nvarchar](10) NULL DEFAULT (' ')   
      ,  [DoCartonize]     [nvarchar](1)  NULL DEFAULT ('N')  
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
      ,  [ShipFlag]        [nvarchar](1)  NULL DEFAULT ('0')  
      ,  [PickSlipNo]      [nvarchar](10) NULL   
      ,  [TaskDetailKey]   [nvarchar](10) NULL   
      ,  [TaskManagerReasonKey] [nvarchar](10) NULL  
      ,  [Notes]           [nvarchar](4000) NULL   
      ,  [MoveRefKey]      [nvarchar](10) NULL DEFAULT ('')  
      ,  [WIP_Refno]       [nvarchar](30) NULL DEFAULT ('')   
      ,  [Channel_ID]      [bigint]       NULL DEFAULT ((0))
      )     
         
      IF OBJECT_ID('tempdb..#TMP_RPFUCC') IS NOT NULL  
      BEGIN
         DROP TABLE #TMP_RPFUCC  
      END

      CREATE TABLE #TMP_RPFUCC
      ( 
         [UCC_RowRef]   [INT]          NOT NULL PRIMARY KEY   
      ,  [UCCNo]        [nvarchar](20) NOT NULL DEFAULT ('') 
      ,  [Storerkey]    [nvarchar](15) NOT NULL DEFAULT('')  
      ,  [Sku]          [nvarchar](20) NOT NULL DEFAULT('') 
      ,  [Lot]          [nvarchar](10) NOT NULL DEFAULT('')
      ,  [ToLoc]        [nvarchar](10) NOT NULL DEFAULT('')
      ,  [ToID]         [nvarchar](18) NOT NULL DEFAULT('')
      ,  [Taskdetailkey][nvarchar](10) NOT NULL DEFAULT ('') 
      )    
      
      IF OBJECT_ID('tempdb..#TMP_CL') IS NOT NULL  
      BEGIN
         DROP TABLE #TMP_CL
      END

      CREATE TABLE #TMP_CL
      (  [RowID]                       INT               IDENTITY(1,1) PRIMARY KEY                   
      ,  [LISTNAME]                    [nvarchar](10)    NULL     
      ,  [Code]                        [nvarchar](30)    NULL  
      ,  [Description]                 [nvarchar](250)   NULL  
      ,  [Short]                       [nvarchar](10)    NULL  
      ,  [Long]                        [nvarchar](250)   NULL  
      ,  [Notes]                       [nvarchar](4000)  NULL  
      ,  [Notes2]                      [nvarchar](4000)  NULL  
      ,  [Storerkey]                   [nvarchar](50)    NOT NULL  
      ,  [UDF01]                       [nvarchar](60)    NOT NULL  
      ,  [UDF02]                       [nvarchar](60)    NOT NULL  
      ,  [UDF03]                       [nvarchar](60)    NOT NULL  
      ,  [UDF04]                       [nvarchar](60)    NOT NULL  
      ,  [UDF05]                       [nvarchar](60)    NOT NULL  
      ,  [code2]                       [nvarchar](30)    NOT NULL 
      )
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
      ELSE
      BEGIN
         UPDATE #PICKDETAIL_WIP  
         SET #PICKDETAIL_WIP.Taskdetailkey = ''  
         FROM #PICKDETAIL_WIP  
         LEFT JOIN TASKDETAIL TD (NOLOCK) ON  TD.Taskdetailkey = #PICKDETAIL_WIP.Taskdetailkey 
                                          AND TD.Sourcetype = @c_SourceType 
                                          AND TD.Tasktype IN ('FPK','FCP','FPP')              
                                          AND TD.Status <> 'X'   
         WHERE TD.Taskdetailkey IS NULL 
      END   
   END  

   --Replenishment By UCCNo
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      SET @cur_WaveReplto = CURSOR FAST_FORWARD READ_ONLY FOR 
      SELECT PD.Storerkey, PD.Sku, PD.Loc
         , PD.Lot                                    
         , QtyNeed = SUM(pd.Qty)-(lli.Qty-lli.QtyPicked)-lli.PendingMoveIn+ISNULL(tdp.QtyAllocated,0) --2026-01-21
         , FinalLocPAZone = l.PutawayZone
         , FinalLocLoseID = l.LoseId
      FROM #PICKDETAIL_WIP PD (NOLOCK)
      JOIN LOTATTRIBUTE la  (NOLOCK) ON pd.Lot = la.Lot
      JOIN LOTxLOCxID   lli (NOLOCK) ON pd.Lot = lli.Lot 
                                    AND pd.Loc = lli.loc
                                    AND pd.ID  = lli.ID
      JOIN LOC l (NOLOCK)  ON pd.loc = l.loc
      LEFT OUTER JOIN TASKDETAIL tdr (NOLOCK) ON tdr.TaskType IN ('RPF','RP1')
                                             AND tdr.Storerkey= pd.Storerkey
                                             AND tdr.Sku   = pd.Sku
                                             AND tdr.FinalLoc = pd.Loc
                                             AND tdr.[Status] NOT IN ('9','X')
      OUTER APPLY (SELECT QtyAllocated = SUM(td.Qty) 
                   FROM TASKDETAIL td (NOLOCK) 
                   WHERE td.TaskType= 'FCP'
                   AND td.Storerkey = pd.Storerkey
                   AND td.Sku       = pd.Sku
                   AND td.fromLoc   = pd.Loc
                   AND td.UOM       = '6'
                   AND td.[Status] NOT IN ('9','X')
                  ) tdp                   
      WHERE PD.UOM = '6'
      AND PD.Qty > 0
      AND PD.[Status] = '0'
      AND PD.TaskdetailKey = ''
      AND tdr.Taskdetailkey IS NULL
      GROUP BY PD.Storerkey, PD.Sku, PD.Loc, PD.Lot                                  
            ,  lli.Qty,lli.QtyPicked,lli.PendingMoveIn,ISNULL(tdp.QtyAllocated,0)
            ,  l.PutawayZone, l.LoseId
      HAVING (lli.Qty-lli.QtyPicked)+lli.PendingMoveIn-ISNULL(tdp.QtyAllocated,0)-SUM(pd.Qty) < 0  
      ORDER BY l.putawayZone, PD.Loc, PD.Lot        
 
      OPEN @cur_WaveReplto    
         
      FETCH NEXT FROM @cur_WaveReplto INTO @c_Storerkey, @c_Sku, @c_FinalLoc,  @c_Lot    
                                        ,  @n_QtyNeed, @c_FinalLocPAZone, @c_FinalLocLoseID                            
         
      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)  
      BEGIN
         SELECT TOP 1 @c_ToLoc = l.Loc
         FROM LOC l (NOLOCK)
         WHERE l.Facility = @c_Facility
         AND   l.LocationType = 'PND'
         AND   l.PutawayZone  = @c_FinalLocPAZone

         IF @c_FinalLocPAZone <> @c_FinalLocPAZone_P
         BEGIN
            SET @n_UCCPerToteID = 0
            SET @c_Groupkey = ''
         END
         
         SET @cur_WaveReplfr = CURSOR FAST_FORWARD READ_ONLY FOR          
         SELECT  FromLoc = lli.Loc
               , FromID  = lli.ID
               , QtyToReplen = lli.qty - lli.QtyPicked - lli.QtyAllocated - lli.QtyReplen
         FROM LOTxLOCxID lli (NOLOCK) 
         JOIN LOT (NOLOCK) ON LOT.Lot = lli.Lot
         JOIN ID  (NOLOCK) ON ID.id   = lli.id
         JOIN LOC (NOLOCK) ON LOC.loc = lli.loc 
         JOIN SKUxLOC sl (NOLOCK) ON  lli.Storerkey = sl.Storerkey 
                                  AND lli.Sku = sl.Sku
                                  AND lli.Loc = sl.Loc
         WHERE lli.Storerkey = @c_Storerkey
         AND   lli.Sku = @c_Sku
         AND   lli.Lot = @c_Lot      
         AND   lli.Loc <> @c_FinalLoc
         AND   lli.qty - lli.QtyPicked - lli.QtyAllocated - lli.QtyReplen >= @n_QtyNeed
         AND   LOC.LocationType NOT IN ('PICK','CASE','DYNPPICK')
         AND   LOT.[Status] = 'OK'
         AND   ID.[Status]  = 'OK'
         AND   LOC.[Status] = 'OK'
         AND   LOC.LocationFlag NOT IN ('DAMAGE','HOLD')
         AND   LOC.LocationType = 'BULK'                    
         AND   LOC.Facility = @c_Facility
         ORDER BY LOC.LogicalLocation
                , lli.qty - lli.QtyPicked - lli.QtyAllocated - lli.QtyReplen DESC 

         OPEN @cur_WaveReplfr

         FETCH NEXT FROM @cur_WaveReplfr INTO  @c_FromLoc, @c_FromID, @n_QtyToReplen

         WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2) AND @n_QtyNeed > 0
         BEGIN
            WHILE @n_QtyToReplen> 0 AND @n_QtyNeed > 0 
            BEGIN
               --From bulk, it is always: 1 UCC = 1 SKU = 1 lot.
               SELECT TOP 1
                     @n_UCC_RowRef = UCC.UCC_RowRef
                  ,  @c_UCCNo = UCC.UCCNo
                  ,  @n_Qty = UCC.Qty
               FROM UCC (NOLOCK)
               WHERE UCC.Lot = @c_Lot
               AND   UCC.Loc = @c_FromLoc
               AND   UCC.ID  = @c_FromID
               AND   UCC.[Status] = '1'
               AND   UCC.Qty <= @n_QtyToReplen
               AND   UCC.Qty >= @n_QtyNeed
               AND   NOT EXISTS (SELECT 1 
                                 FROM #TMP_RPFUCC tru
                                 WHERE tru.UCC_RowRef = UCC.UCC_RowRef
                                )
               ORDER BY UCC_RowRef

               IF @@ROWCOUNT = 0
               BEGIN
                  SET @n_Continue = 3    
                  SET @n_err   = 83030  -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
                  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                               +': No available UCC for Replenishment. Sku: ' + @c_Sku
                               + '. (mspRLWAV09)' 
                  BREAK
               END

               IF @n_UCCPerToteID = @n_MaxUCCVol   --@n_MaxUCCPerToteID
               BEGIN
                  SET @n_UCCPerToteID = 0
                  SET @c_Groupkey = ''
               END
               
               SET @n_QtyToReplen = @n_QtyToReplen - @n_Qty
               SET @n_QtyNeed = @n_QtyNeed - @n_Qty
               SET @c_ToID    = @c_FromID
               SET @c_FinalID = CASE WHEN @c_FinalLocLoseID = 1 THEN '' ELSE @c_FromID END
               SET @c_Taskdetailkey = '' 

               EXEC isp_InsertTaskDetail     
                   @c_Taskdetailkey         = @c_Taskdetailkey OUTPUT  
                  ,@c_TaskType              = 'RPF'               
                  ,@c_Storerkey             = @c_Storerkey  
                  ,@c_Sku                   = @c_Sku  
                  ,@c_Lot                   = @c_Lot   
                  ,@c_UOM                   = '2'         
                  ,@n_UOMQty                = @n_Qty       
                  ,@n_Qty                   = @n_Qty        
                  ,@c_FromLoc               = @c_Fromloc        
                  ,@c_LogicalFromLoc        = @c_FromLoc   
                  ,@c_FromID                = @c_FromID       
                  ,@c_ToLoc                 = @c_ToLoc         
                  ,@c_LogicalToLoc          = @c_ToLoc   
                  ,@c_ToID                  = @c_ToID 
                  ,@c_CaseID                = @c_UCCNo
                  ,@c_PickMethod            = 'PP'  
                  ,@c_Priority              = '5'       
                  ,@c_SourcePriority        = '5'        
                  ,@c_SourceType            = @c_SourceType        
                  ,@c_SourceKey             = @c_Wavekey        
                  ,@c_OrderKey              = '' 
                  ,@c_FinalLoc              = @c_FinalLoc
                  ,@c_FinalID               = @c_FinalID
                  ,@c_Groupkey              = @c_Groupkey
                  ,@n_PendingMoveIn         = @n_Qty
                  ,@n_QtyReplen             = @n_Qty
                  ,@c_Wavekey               = @c_Wavekey        
                  ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey   
                  ,@c_Message03             = ''  
                  ,@c_LinkTaskToPick        = '' -- WIP=Update taskdetailkey to pickdetail_wip  
                  ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL    
                  ,@c_WIP_RefNo             = @c_SourceType  
                  ,@b_Success               = @b_Success OUTPUT  
                  ,@n_Err                   = @n_err OUTPUT   
                  ,@c_ErrMsg                = @c_errmsg OUTPUT  
                
               IF @b_Success <> 1   
               BEGIN  
                  SET @n_Continue = 3    
               END 

               IF @n_Continue = 1 AND @c_GroupKey = ''
               BEGIN
                  SET @c_GroupKey = @c_Taskdetailkey

                  UPDATE TaskDetail WITH (ROWLOCK)
                  SET GroupKey = @c_GroupKey
                  WHERE TaskDetailkey = @c_Taskdetailkey
                  AND GroupKey = ''

                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @n_Continue = 3    
                  END 
               END

               IF @n_Continue = 1
               BEGIN
                  INSERT INTO #TMP_RPFUCC (UCC_RowRef, UCCNo, Storerkey, Sku
                                         , Lot, ToLoc, ToID, TaskdetailKey)
                  VALUES (@n_UCC_RowRef, @c_UCCNo, @c_Storerkey, @c_Sku
                        , @c_Lot, @c_FinalLoc, @c_FinalID, @c_Taskdetailkey)

                  UPDATE UCC WITH (ROWLOCK)
                     SET [Status] = '3'
                  WHERE UCC.UCC_RowRef = @n_UCC_RowRef

                  IF @@ERROR <> 0
                  BEGIN
                     SET @n_Continue = 3
                  END

                  SET @n_UCCPerToteID = @n_UCCPerToteID + 1
               END
            END

            FETCH NEXT FROM @cur_WaveReplfr INTO  @c_FromLoc, @c_FromID, @n_QtyToReplen 
         END
         CLOSE @cur_WaveReplfr
         DEALLOCATE @cur_WaveReplfr

         SET @c_FinalLocPAZone_P = @c_FinalLocPAZone                                --2026-01-27
         FETCH NEXT FROM @cur_WaveReplto INTO @c_Storerkey, @c_Sku, @c_FinalLoc, @c_Lot 
                                             ,@n_QtyNeed, @c_FinalLocPAZone, @c_FinalLocLoseID                          
      END
      CLOSE @cur_WaveReplto
      DEALLOCATE @cur_WaveReplto
   END

   IF @n_Continue IN(1,2)   
   BEGIN  
      SELECT @c_DefaultLoc = CL.Long  
      FROM CODELKUP CL (NOLOCK)  
      JOIN LOC (NOLOCK) ON CL.Long = LOC.Loc  
      WHERE CL.Listname = 'TM_TOLOC'  
      AND CL.Storerkey = @c_Storerkey  
      AND CL.Code = 'DEFAULT'

      INSERT INTO #TMP_CL (Listname, Code, Description, Short, Long                
                          ,Notes, Notes2, Storerkey
                          ,UDF01, UDF02, UDF03, UDF04, UDF05, Code2)  
      SELECT CL.Listname   
           , CL.Code   
           , [Description] = ISNULL(CL.[Description],'')   
           , Short = ISNULL(CL.Short,'')      
           , Long  = ISNULL(CL.Long ,'')     
           , Notes = ISNULL(CL.Notes,'')      
           , Notes2= ISNULL(CL.Notes2,'')           
           , CL.Storerkey  
           , CL.UDF01   
           , CL.UDF02   
           , CL.UDF03   
           , CL.UDF04   
           , CL.UDF05   
           , CL.Code2  
      FROM CODELKUP CL (NOLOCK)  
      WHERE CL.Listname IN ('ONBRMVOUT','ONBRAZONES')  
      ORDER BY  CL.Listname, CL.Code 

      IF @@ROWCOUNT > 0 
      BEGIN
         SET @c_CustomToLoc = 'ONBRMVOUT'
      END
      
      SELECT @c_Priority = CL.Short                                               
      FROM CODELKUP CL (NOLOCK)
      WHERE CL.Storerkey = @c_Storerkey
      AND CL.LISTNAME = 'TMPKPRIORI'
      AND CL.Code = 'Lowest'

      IF ISNULL(@c_Priority,'') = ''                                             
         SET @c_Priority = '9'

      SET @c_SQL =   
            N' SET @cur_pick = CURSOR FAST_FORWARD READ_ONLY FOR'    
          + ' SELECT PD.Storerkey, PD.Sku'
          +       ' ,CASE WHEN @c_DispatchCasePickMethod =''1'''                          
          +             ' THEN PD.Lot ELSE '''' END AS Lot'
          +       ' ,PD.Loc, PD.ID, SUM(PD.Qty) AS Qty '    
          +       ' ,PD.UOM, SUM(PD.UOMQty) AS UOMQty'  
          +       ' ,PD.DropID'               
          +       ' ,O.Route'   
          +       ' ,CASE WHEN @c_DispatchCasePickMethod =''1'''                          
          +             ' THEN O.Orderkey ELSE '''' END AS Orderkey'    
          +       CASE WHEN @c_CustomToLoc > '' OR @c_DefaultLoc = ''  
                       THEN ', ISNULL(TOLOC.Loc,'''') AS ToLoc' 
                              ELSE ', '''' AS ToLoc' 
                              END  
          +       ' ,@c_Priority AS Priority'                                            
          +       ' ,CASE WHEN @c_DispatchCasePickMethod =''1'''                        
          +             ' THEN CONVERT(NVARCHAR(8), O.DeliveryDate, 112) ELSE '''' END AS DeliveryDate'
          +       ' ,'''' AS Loadkey'                                                   
          +        CASE WHEN @c_CustomToLoc = '' 
                        THEN ', ISNULL(LPLD.Loc,'''') AS LPLDLoc' 
                        ELSE ', '''' AS LPLDLoc' 
                        END      
          +       ' ,AD.Areakey'   
          +       ' ,ISNULL(P.CubeUOM1, 0.00)'    
          +       ' ,ISNULL(P.CubeUOM3, 0.00)'    
          +       ' ,LOC.LocLevel'   
          +       ' ,P.Casecnt'   
          + ' FROM WAVEDETAIL WD (NOLOCK)'  
          + ' JOIN WAVE W (NOLOCK) ON WD.Wavekey = W.Wavekey'                            
          + ' JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey'  
          + ' JOIN #PICKDETAIL_WIP PD (NOLOCK) ON O.Orderkey = PD.Orderkey'    
          + ' JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc'  
          + ' JOIN AreaDetail AD (NOLOCK) ON LOC.PutawayZone = AD.PutawayZone'   
          + ' JOIN SKU S (NOLOCK) ON S.StorerKey = PD.Storerkey AND S.SKU = PD.Sku'
          + ' JOIN PACK P (NOLOCK) ON P.PackKey = S.PACKKey'
          +  CASE WHEN @c_CustomToLoc = '' AND @c_DefaultLoc = ''  
                  THEN    
            ' LEFT JOIN STORERSODEFAULT SSO (NOLOCK) ON SSO.Storerkey = O.Consigneekey'
          + ' OUTER APPLY (SELECT TOP 1 TL.Loc FROM LOC TL (NOLOCK) WHERE TL.Putawayzone = SSO.Route) AS TOLOC'  
                  ELSE
            ''    END
          + CASE WHEN @c_CustomToLoc > ''
                 THEN
            ' CROSS APPLY (SELECT VAS = CASE WHEN o.Notes > '''' THEN 1'
          +                                ' WHEN o.Notes2 > '''' THEN 1'
          +                                ' WHEN (SELECT oif.Notes FROM ORDERINFO oif (NOLOCK)'
          +                                      ' WHERE oif.Orderkey = o.Orderkey) > '''' THEN 1'
          +                                ' ELSE 0 END'
          +              ') AS ot'
          + ' OUTER APPLY (SELECT TOP 1' 
          +              ' LOC = CASE WHEN cl1.Short = ''1'' THEN cl2.UDF05'
          +                         ' WHEN cl1.Short = ''2'' AND o.DocType = ''E'' AND o.Ecom_Single_Flag = ''S'' THEN cl2.UDF03'
          +                         ' WHEN cl1.Short = ''2'' AND o.DocType = ''E'' AND o.Ecom_Single_Flag = ''M'' THEN cl2.UDF04'
          +                         ' WHEN cl1.Short = ''2'' AND o.DocType = ''N'' AND ot.VAS = 0 THEN cl2.UDF01'
          +                         ' WHEN cl1.Short = ''2'' AND o.DocType = ''N'' AND ot.VAS = 1 THEN cl2.UDF02'
          +                         ' END'
          +              ' FROM #TMP_CL cl1'  
          +              ' JOIN #TMP_CL cl2 ON cl2.ListName = ''ONBRMVOUT'''
          +                               ' AND cl2.Code = cl1.Code'
          +              ' WHERE cl1.ListName = ''ONBRAZONES'''
          +              ' AND   cl1.Code = LOC.PutawayZone'
          +              ') AS TOLOC'
                 ELSE  
            ' OUTER APPLY (SELECT TOP 1 ISNULL(LPD.Loc, '''') AS Loc'  
          +              ' FROM LoadPlanLaneDetail LPD (NOLOCK)'        
          +              ' WHERE LPD.LoadKey = O.Loadkey) AS LPLD' 
                 END
          + ' WHERE WD.Wavekey = @c_Wavekey'  
          + ' AND PD.Status = ''0'''
          + ' AND PD.Qty > 0'
          + ' AND PD.WIP_RefNo = @c_SourceType' 
          + ' AND PD.Taskdetailkey = '''''          
          + ' GROUP BY PD.Storerkey, PD.Sku'
          +        ' , CASE WHEN @c_DispatchCasePickMethod =''1'''                       
          +        '        THEN PD.Lot ELSE '''' END'
          +        ' , PD.Loc, PD.ID, PD.UOM, O.Route'
          +        ' , PD.DropID'             
          +        ' , CASE WHEN @c_DispatchCasePickMethod =''1'''                        
          +        '    THEN O.Consigneekey ELSE '''' END'
          +        ' , CASE WHEN @c_DispatchCasePickMethod =''1'''                      
          +        '        THEN O.Orderkey ELSE '''' END'
          +        ' , CASE WHEN @c_DispatchCasePickMethod =''1'''                    
          +        '        THEN CONVERT(NVARCHAR(8), O.DeliveryDate, 112) ELSE '''' END'
          +        ' , LOC.LogicalLocation'
          --+ CASE WHEN @c_CustomToLoc > '' 
          --       THEN ' , LOC.PutawayZone, ot.VAS' ELSE '' END    
          + CASE WHEN @c_CustomToLoc > '' OR @c_DefaultLoc = ''  
                 THEN ' , ISNULL(TOLOC.Loc,'''')' ELSE '' END
          + CASE WHEN @c_CustomToLoc = '' 
                 THEN ' , ISNULL(LPLD.Loc,'''')' ELSE '' END
          +        ' , AD.Areakey'
          +        ' , ISNULL(P.CubeUOM1, 0.00)'
          +        ' , ISNULL(P.CubeUOM3, 0.00)'
          +        ' , LOC.LocLevel'
          +        ' , P.Casecnt'
          + ' ORDER BY O.Route'                                                     
          +        ' , CASE WHEN @c_DispatchCasePickMethod =''1''' 
          +        '        THEN O.Consigneekey ELSE '''' END'                                       
          +        ' , CASE WHEN @c_DispatchCasePickMethod =''1'''  
          +        '        THEN O.Orderkey ELSE '''' END'
          + CASE WHEN @c_CustomToLoc = '' 
                 THEN ' , ISNULL(LPLD.Loc,'''')' ELSE ', ISNULL(TOLOC.Loc,'''')' END  
          +        ' , CASE WHEN @n_MaxUCCVol >= 0 THEN PD.UOM ELSE '''' END'
          +        ' , AD.Areakey'   
          +        ' , Loc.LogicalLocation, PD.Loc;' 
          + CHAR(13) 
          + ' OPEN @cur_pick ;'  
  
      SET @c_SQLParms = N'@c_Wavekey      NVARCHAR(10)'
                      + ',@c_SourceType   NVARCHAR(30)'
                      + ',@c_DispatchCasePickMethod NVARCHAR(10)'
                      + ',@c_Priority     NVARCHAR(10)'
                      + ',@n_MaxUCCVol    FLOAT'
                      + ',@cur_pick       CURSOR      OUTPUT'  
  
      EXEC sp_executesql @c_SQL   
         , @c_SQLParms                                          
         , @c_Wavekey  
         , @c_SourceType 
         , @c_DispatchCasePickMethod
         , @c_Priority  
         , @n_MaxUCCVol         
         , @cur_pick OUTPUT

      FETCH NEXT FROM @cur_pick INTO  @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID
                                    , @n_Qty, @c_UOM, @n_UOMQty, @c_UCCNo
                                    , @c_Route, @c_Orderkey, @c_ToLoc, @c_Priority, @dt_DeliveryDate
                                    , @c_Loadkey, @c_LPLDLoc   
                                    , @c_Areakey, @n_CubeUOM1, @n_CubeUOM3, @n_LocLevel   
                                    , @n_Casecnt   
         
      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)  
      BEGIN                       
         SET @c_LinkTaskToPick_SQL = ''   
         SET @c_Groupkey = IIF(@c_UOM = '1', '', @c_Groupkey)
         SET @c_KeyName = LEFT(TRIM(@c_Storerkey) + 'GRPKEY', 18)   --MATTELGRPKEY
         SET @c_ToID = @c_FromID
         SET @c_RefTaskkey  = ''

         IF @c_CustomToLoc = '' AND ISNULL(@c_DefaultLoc,'') <> '' 
           SET @c_ToLoc = @c_DefaultLoc  

         IF ISNULL(@c_LPLDLoc,'') <> ''  
            SET @c_ToLoc = @c_LPLDLoc
                                  
         IF ISNULL(@c_Toloc,'') = ''  
         BEGIN           
            SET @n_Continue = 3    
            SET @n_err = 83040  -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid To Loc setup. (mspRLWAV09)' 
         END    

         SET @c_TaskStatus = '0'                                                   
         IF @c_UOM = '6'
         BEGIN
            SET @n_Cnt = 0
            SET @c_RefTaskKey = ''
            SELECT TOP 1 @n_Cnt = 1
                  , @c_RefTaskKey = trp.TaskdetailKey
            FROM #TMP_RPFUCC trp (NOLOCK) 
            WHERE trp.Storerkey = @c_Storerkey
            AND   trp.Sku       = @c_Sku
            AND   trp.ToLoc     = @c_FromLoc
            
            IF @n_Cnt = 0
            BEGIN
               SELECT TOP 1 @n_Cnt = 1
               FROM dbo.TaskDetail td (NOLOCK) 
               WHERE td.Storerkey = @c_Storerkey
               AND   td.Sku       = @c_Sku
               AND   td.TaskType  = 'RPF'
               AND   td.FinalLOC  = @c_FromLoc
               AND   td.SourceType= @c_SourceType
               AND   td.[Status] BETWEEN '0' AND '8'
               ORDER BY td.TaskDetailKey DESC
            END

            IF @n_Cnt = 1
            BEGIN
               SET @c_TaskStatus = 'H'                         
            END
         END                                                                            

         IF @c_UOM IN ('2', '6')  
         BEGIN
            SET @n_Volume = 0.00
            SET @c_TaskType = 'FCP'  
            SET @c_PickMethod = 'PP'
            SET @n_DropIDVol  = @n_MaxSkuVol
        
            IF @c_DispatchCasePickMethod = '1'
            BEGIN
               SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.UOM = @c_UOM AND ORDERS.Orderkey = @c_Orderkey'
            END
            ELSE
            BEGIN
               SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.UOM = @c_UOM AND ORDERS.Userdefine09 = @c_Wavekey'
            END
            
            IF @c_UOM = '2' AND @c_UCCNo > ''
            BEGIN
               SET @n_Volume = 1          -- Max 14
               SET @n_DropIDVol = @n_MaxUCCVol
            END
            ELSE IF @c_UOM = '2' AND @c_UCCNo = ''
            BEGIN
               IF @n_Casecnt > 0 
               BEGIN
                  SET @n_Volume = @n_CubeUOM1 * (@n_Qty / @n_Casecnt) 
               END
            END
            ELSE IF @c_UOM = '6'
            BEGIN
               SET @n_Volume = @n_CubeUOM3 * @n_Qty      --EA
            END

            SET @n_TTLVolume = ISNULL(@n_TTLVolume, 0.00) + @n_Volume

            IF @c_Groupkey > '' AND @n_TTLVolume > @n_DropIDVol
            BEGIN
               SET @c_Groupkey = ''
            END

            IF @c_Orderkey_P <> @c_Orderkey
            BEGIN
               SET @c_Groupkey = ''
            END

            IF @c_Areakey_P <> @c_Areakey
            BEGIN
               SET @c_Groupkey = ''
            END

            IF @c_ToLoc_P <> @c_ToLoc
            BEGIN
               SET @c_Groupkey = ''
            END

            IF @c_UCCNo > '' AND @c_UOM_P <> @c_UOM
            BEGIN 
               SET @c_Groupkey = ''
            END
            
            SET @n_NoOfGroup = 1
            SET @n_MaxQtyPerGroup = 0
            IF @c_Groupkey = ''  
            BEGIN
               SET @n_TTLVolume = @n_Volume

               IF @n_TTLVolume > @n_DropIDVol AND @c_UCCNo = '' 
               BEGIN
                  --Check if need how many groups
                  IF @n_DropIDVol > 0.00 
                  BEGIN
                     SET @n_NoOfGroup = CEILING(@n_TTLVolume / @n_DropIDVol)
                  END
 
                  IF (@c_UOM = '2' AND @n_CubeUOM1 > 0) OR (@c_UOM > '2' AND @n_CubeUOM3 > 0)
                  BEGIN
                     SET @n_MaxQtyPerGroup = FLOOR(CASE WHEN @c_UOM = '2' and @c_UCCNo = ''
                                                        THEN (@n_DropIDVol / @n_CubeUOM1) * @n_Casecnt
                                                        ELSE  @n_DropIDVol / @n_CubeUOM3
                                                        END
                                                  )
                  END
               END
            END
                 
            SET @n_QtyToRelease = @n_Qty
            WHILE @n_NoOfGroup > 0 AND @n_Continue IN (1,2) 
            BEGIN
               IF @c_Groupkey = ''
               BEGIN
                  EXEC dbo.nspg_GetKey @KeyName = @c_KeyName
                                     , @fieldlength = 10
                                     , @keystring = @c_Groupkey   OUTPUT
                                     , @b_Success = @b_Success    OUTPUT
                                     , @n_err = @n_err            OUTPUT
                                     , @c_errmsg = @c_errmsg      OUTPUT
                  IF @b_Success = 0
                  BEGIN
                     SET @n_Continue = 3
                  END
               END
               
               IF @n_Continue IN (1,2) 
               BEGIN
                  IF @n_MaxQtyPerGroup > 0
                  BEGIN
                     IF @n_QtyToRelease > @n_MaxQtyPerGroup
                     BEGIN
                        SET @n_QtyToRelease = @n_QtyToRelease - @n_MaxQtyPerGroup
                        SET @n_Qty = @n_MaxQtyPerGroup
                     END
                     ELSE
                     BEGIN
                        SET @n_Qty = @n_QtyToRelease
                        SET @n_QtyToRelease = 0
                     END
                  END

                  EXEC isp_InsertTaskDetail     
                      @c_TaskType              = @c_TaskType               
                     ,@c_Storerkey             = @c_Storerkey  
                     ,@c_Sku                   = @c_Sku  
                     ,@c_Lot                   = @c_Lot   
                     ,@c_UOM                   = @c_UOM        
                     ,@n_UOMQty                = @n_UOMQty       
                     ,@n_Qty                   = @n_Qty     
                     ,@c_FromLoc               = @c_Fromloc        
                     ,@c_LogicalFromLoc        = @c_FromLoc   
                     ,@c_FromID                = @c_FromID       
                     ,@c_ToLoc                 = @c_ToLoc         
                     ,@c_LogicalToLoc          = @c_ToLoc   
                     ,@c_ToID                  = @c_ToID   
                     ,@c_CaseID                = @c_UCCNo
                     ,@c_PickMethod            = @c_PickMethod  
                     ,@c_Priority              = @c_Priority       
                     ,@c_SourcePriority        = '9'        
                     ,@c_SourceType            = @c_SourceType        
                     ,@c_SourceKey             = @c_Wavekey        
                     ,@c_OrderKey              = @c_Orderkey  
                     ,@c_Wavekey               = @c_Wavekey  
                     ,@c_Loadkey               = @c_Loadkey                               
                     ,@c_Groupkey              = @c_Groupkey
                     ,@c_RefTaskkey            = @c_RefTaskkey -- if FCP need RPF Qty from other wave, reftaskkey  =''
                     ,@c_AreaKey               = '?F'  -- ?F=Get from location areakey   
                     ,@c_Message03             = ''  
                     ,@c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                     ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL    
                     ,@c_SplitTaskByCase       ='N'   -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0. include last partial carton.  
                     ,@c_WIP_RefNo             = @c_SourceType  
                     ,@b_Success               = @b_Success OUTPUT  
                     ,@n_Err                   = @n_err OUTPUT   
                     ,@c_ErrMsg                = @c_errmsg OUTPUT 
                     ,@c_Status                = @c_TaskStatus         
                      
                  IF @b_Success <> 1   
                  BEGIN  
                     SET @n_Continue = 3  
                     SET @n_NoOfGroup = 0
                  END  

                  SET @n_NoOfGroup = @n_NoOfGroup - 1
               END
            END
         END

         IF @c_UOM = '1' AND @n_Continue IN (1,2)
         BEGIN   
            SET @c_Taskdetailkey = ''  
            SET @c_TaskType   = 'FPK'  
            SET @c_PickMethod = 'FP'  
            IF @c_DispatchCasePickMethod = '1'                                     
            BEGIN
               SET @c_GroupKey = @c_Orderkey
               SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.UOM = @c_UOM AND ORDERS.Orderkey = @c_Orderkey'
            END
            ELSE
            BEGIN
               SET @c_GroupKey = @c_Wavekey
               SET @c_LinkTaskToPick_SQL = 'PICKDETAIL.UOM = @c_UOM AND ORDERS.Userdefine09 = @c_Wavekey'    
            END                                                                    
                
            EXEC isp_InsertTaskDetail     
                @c_Taskdetailkey         = @c_Taskdetailkey OUTPUT  
               ,@c_TaskType              = @c_TaskType               
               ,@c_Storerkey             = @c_Storerkey  
               ,@c_Sku                   = @c_Sku  
               ,@c_Lot                   = @c_Lot   
               ,@c_UOM                   = @c_UOM        
               ,@n_UOMQty                = @n_UOMQty       
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
               ,@c_Wavekey               = @c_Wavekey        
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
               SET @n_Continue = 3    
            END               
            ELSE  
            BEGIN  
               UPDATE TASKDETAIL WITH (ROWLOCK)  
               SET Groupkey = @c_Taskdetailkey  
               WHERE TaskDetailKey = @c_Taskdetailkey    
            END  
         END  

         SET @c_UOM_P     = @c_UOM      
         SET @c_Orderkey_P= @c_Orderkey
         SET @c_Areakey_P = @c_Areakey
         SET @c_ToLoc_P   = @c_ToLoc
 
         FETCH NEXT FROM @cur_pick INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID
                                     ,  @n_Qty, @c_UOM, @n_UOMQty, @c_UCCNo
                                     ,  @c_Route, @c_Orderkey, @c_ToLoc, @c_Priority, @dt_DeliveryDate
                                     ,  @c_Loadkey, @c_LPLDLoc   
                                     ,  @c_Areakey, @n_CubeUOM1, @n_CubeUOM3, @n_LocLevel   
                                     ,  @n_Casecnt  
      END  
      CLOSE @cur_pick  
      DEALLOCATE @cur_pick         
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
         ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT  
             
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
            @c_Loadkey               = '' --@c_Loadkey                                
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
   BEGIN
      DROP TABLE #PICKDETAIL_WIP  
   END

   IF OBJECT_ID('tempdb..#TMP_RPFUCC') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_RPFUCC  
   END
  
   IF OBJECT_ID('tempdb..#TMP_CL') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_CL  
   END

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
      execute nsp_logerror @n_err, @c_errmsg, "mspRLWAV09"    
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


