SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/**************************************************************************/    
/* Stored Procedure: mspRLWAV13_RPF                                       */    
/* Creation Date: 2026-06-18                                              */    
/* Copyright: Maersk                                                      */    
/* Written by: Wan                                                        */    
/*                                                                        */    
/* Purpose: FCR-12980 - AEOMX Release Wave                                */  
/*                                                                        */  
/* Called By: Wave Release                                                */    
/*          :                                                             */    
/* Version: 1.0                                                           */    
/*                                                                        */    
/* Data Modifications:                                                    */    
/*                                                                        */    
/* Updates:                                                               */    
/* Date        Author   Ver   Purposes                                    */ 
/* 2026-07-10  Wan      1.9   FCR-12980. Fix.                             */
/*                            - GroupKey Break by toloclevel, LP capacity */
/**************************************************************************/   
 
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV13_RPF]        
   @c_Wavekey     NVARCHAR(10)
,  @c_Storerkey   NVARCHAR(15)   = '' 
,  @c_Facility    NVARCHAR(5)    = '' 
,  @b_Success     INT            = 1   OUTPUT
,  @n_Err         INT            = 0   OUTPUT
,  @c_ErrMsg      NVARCHAR(255)  = ''  OUTPUT 
,  @n_debug       INT            = 0                     
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
     
   DECLARE
           @n_StartTCnt          INT   = @@TRANCOUNT
         , @n_Continue           INT   = 1
         , @n_UCCCnt             INT   = 0

         , @c_SourceType         NVARCHAR(30)= 'mspRLWAV13'

         , @c_PickDetailKey      NVARCHAR(10)= ''
         , @c_TaskdetailKey      NVARCHAR(10)= ''
         , @c_Sku                NVARCHAR(15)= ''
         , @c_Lot                NVARCHAR(10)= ''
         , @c_FromLoc            NVARCHAR(10)= ''
         , @c_FromID             NVARCHAR(18)= ''
         , @c_UCCNo              NVARCHAR(20)= ''
         , @c_UCCNo_P            NVARCHAR(20)= ''
         , @c_ToLoc              NVARCHAR(10)= ''
         , @c_ToID               NVARCHAR(18)= ''
         , @c_FinalLoc           NVARCHAR(10)= ''
         , @c_FinalID            NVARCHAR(18)= ''
         , @c_TransitLoc         NVARCHAR(10)= ''
         , @c_Priority           NVARCHAR(10)= '1'
         , @c_GroupKey           NVARCHAR(10)= ''
         , @c_SectionKey         NVARCHAR(10)= ''
         , @c_SectionKey_P       NVARCHAR(10)= ''
         , @c_LoseID             NVARCHAR(1) = ''
         , @c_PutawayZone        NVARCHAR(10)= '' 
         , @c_AreaKey_P          NVARCHAR(10)= '' 
         , @c_AreaKey            NVARCHAR(10)= '' 

         , @n_TransitCount       INT         = 0  
         , @n_ToLocLevel         INT         = 0
         , @n_ToLocLevel_P       INT         = 0
         , @n_UCCQty             INT         = 0
         , @n_MaxCapaci_LPN      FLOAT       = 0
         , @c_MaxCapaci_LPN      NVARCHAR(10)= ''

         , @c_SQL                NVARCHAR(MAX) = ''
         , @c_SQLParms           NVARCHAR(2000)= ''                                   
  
         , @cur_RPF              CURSOR

   SET @b_Success = 1    
   SET @n_Err     = 0    
   SET @c_ErrMsg  = ''   

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NULL
   BEGIN
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
      ,  [UOMQty]          [int]          NOT NULL DEFAULT (0)
      ,  [Qty]             [int]          NOT NULL DEFAULT (0)
      ,  [QtyMoved]        [int]          NOT NULL DEFAULT (0)
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
      ,  [LoadKey]         [nvarchar](10) NOT NULL DEFAULT (' ')
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
      ,  [MoveRefKey]      [nvarchar](10) NULL     DEFAULT ('')
      ,  [WIP_Refno]       [nvarchar](30) NULL     DEFAULT ('')
      ,  [Channel_ID]      [bigint]       NULL     DEFAULT (0)
      )
      CREATE INDEX IDX_Case ON #PickDetail_WIP (CaseID, Lot, Loc, ID)
      CREATE INDEX IDX_RPF ON #PickDetail_WIP (ReplenishZone)

      EXEC [dbo].[mspRLWAV13_DATA]        
         @c_Wavekey     = @c_Wavekey 
      ,  @b_Success     = @b_Success   OUTPUT
      ,  @n_Err         = @n_Err       OUTPUT
      ,  @c_ErrMsg      = @c_ErrMsg    OUTPUT 
      ,  @n_debug       = @n_debug  
 
      SET @n_Continue = CASE WHEN @b_Success = 0 THEN 3
                             ELSE 1
                             END
   END

   IF @n_Continue = 1
   BEGIN
      SELECT TOP 1 @c_Storerkey = pw.Storerkey
      FROM #PICKDETAIL_WIP AS pw

      SELECT @c_MaxCapaci_LPN = cl.UDF01  
      FROM Codelkup cl (NOLOCK)
      WHERE cl.ListName = 'MAX_CAPACI'
      AND   cl.Code = 'FULL_UCC'
      AND   cl.Storerkey= @c_Storerkey

      IF ISNUMERIC(@c_MaxCapaci_LPN) = 1
      BEGIN
         SET @n_MaxCapaci_LPN = @c_MaxCapaci_LPN
      END

      SET @cur_RPF = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT DISTINCT
             pw.Storerkey
            ,pw.Sku
            ,pw.Lot
            ,pw.Loc
            ,pw.ID
            ,pw.DropID
            ,msu.Qty
            ,l.Facility
            ,SectionKey = ISNULL(s.BUSR2,'')
      FROM #PICKDETAIL_WIP AS pw
      JOIN Loc l (NOLOCK) ON l.Loc = pw.Loc
      JOIN Sku s (NOLOCK) ON s.Storerkey = pw.Storerkey
                          AND s.Sku = pw.Sku
      CROSS APPLY (SELECT u.UCCNo
                        , Qty = SUM(u.Qty)
                   FROM UCC u (NOLOCK) 
                   WHERE u.Storerkey = pw.Storerkey
                   AND u.UCCNo = pw.DropID
                   AND u.[Status] = '3'
                   GROUP BY u.UCCNo
                   HAVING COUNT(DISTINCT u.Sku) = 1
                  ) msu
      WHERE pw.UOM = '6'
      AND   pw.ToLoc = ''                                --(No RPF yet)
      AND   pw.ReplenishZone = ''      
      AND   l.LocationType = 'BULK'
      ORDER BY ISNULL(s.BUSR2,'')
            ,  pw.DropID

      OPEN @cur_RPF

      FETCH NEXT FROM @cur_RPF INTO @c_Storerkey
                                 ,  @c_Sku
                                 ,  @c_Lot
                                 ,  @c_FromLoc
                                 ,  @c_FromID
                                 ,  @c_UCCNo
                                 ,  @n_UCCQty
                                 ,  @c_Facility
                                 ,  @c_SectionKey

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         SET @c_ToID = ''
         SET @c_FinalID = @c_FromID
 

         IF @n_UCCCnt > @n_MaxCapaci_LPN OR
            @c_SectionKey_P <> @c_SectionKey 
         BEGIN
            SET @n_UCCCnt = 0
            SET @c_GroupKey = ''
         END
                                          
         SET @c_ToLoc = 'PND-MEZZA'                      --FCR specify hardcode
         SET @c_FinalLoc = ''
         SET @c_TransitLOC = @c_ToLoc
         --Find PND
         IF @c_ToLoc = ''
         BEGIN
            SELECT TOP 1 @c_ToLoc = l.Loc
            FROM LOC l (NOLOCK)
            WHERE l.Facility = @c_Facility
            AND   l.LocationType = 'PND'
            ORDER BY l.LogicalLocation
         END

         --FInd DPP
         IF @c_ToLoc > '' AND @c_FinalLoc = ''
         BEGIN
            SELECT TOP 1 @c_FinalLoc = l.Loc
               , @n_ToLocLevel = l.locLevel
               , @c_LoseID = l.LoseID
               , @c_PutawayZone = l.PutawayZone
            FROM LOC l (NOLOCK)
            WHERE l.Facility = @c_Facility
            AND   l.SectionKey = @c_SectionKey
            AND   l.LocationType = 'DYNPPICK'
            AND NOT EXISTS (  SELECT 1
                              FROM LotxLocxID lli (NOLOCK)
                              WHERE lli.Storerkey = @c_Storerkey
                              AND lli.Loc = l.loc
                              AND lli.Qty + lli.PendingMoveIn > 0
                           )
            ORDER BY l.LogicalLocation       -- Logicallocation sequence include Loclevel sorting

            SELECT @c_AreaKey = ad.Areakey
            FROM AREADETAIL ad (NOLOCK) 
            WHERE ad.Putawayzone = @c_PutawayZone

            IF @c_AreaKey = ''
            BEGIN
               SET @n_Continue = 3
               SET @n_Err      = 64020
               SET @c_ErrMsg   = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                               + 'Missing areakey for replenish final loc/picking Loc. Loc: '             
                               + @c_FinalLoc                                           
                               + '. (mspRLWAV13_VLDN)'
            END
         END

         IF @n_Continue = 1
         BEGIN
            IF @c_LoseID = '1'
            BEGIN
               SET @c_FinalID = ''
            END

            IF @n_ToLocLevel_P <> @n_ToLocLevel --OR                                --(Wan)
               --@c_AreaKey_P <> @c_AreaKey                                         --(Wan)
            BEGIN
               SET @n_UCCCnt = 0
               SET @c_GroupKey = ''
            END

            SET @n_ToLocLevel_P = @n_ToLocLevel
            SET @c_AreaKey_P = @c_AreaKey


            IF @c_ToLoc > '' AND @c_FinalLoc > ''
            BEGIN
               SET @b_Success = 1    
               EXECUTE nspg_getkey   
                     @KeyName    = 'TaskDetailKey'             
                  ,  @fieldlength= 10    
                  ,  @keystring  = @c_Taskdetailkey   OUTPUT  
                  ,  @b_Success  = @b_Success         OUTPUT  
                  ,  @n_err      = @n_err             OUTPUT  
                  ,  @c_errmsg   = @c_errmsg          OUTPUT  

               IF @b_Success <> 1    
               BEGIN    
                  SET @n_Continue = 3    
               END  

               IF @n_Continue = 1
               BEGIN
                  IF @c_GroupKey = ''
                  BEGIN
                     SET @c_GroupKey = @c_TaskdetailKey
                  END
                  --Insert Task
                  EXEC isp_InsertTaskDetail     
                     @c_Taskdetailkey         = @c_Taskdetailkey  
                  ,  @c_TaskType              = 'RPF'               
                  ,  @c_Storerkey             = @c_Storerkey  
                  ,  @c_Sku                   = @c_Sku  
                  ,  @c_Lot                   = @c_Lot   
                  ,  @c_UOM                   = '2'         
                  ,  @n_UOMQty                = @n_UCCQty       
                  ,  @n_Qty                   = @n_UCCQty        
                  ,  @c_FromLoc               = @c_Fromloc        
                  ,  @c_LogicalFromLoc        = @c_FromLoc   
                  ,  @c_FromID                = @c_FromID       
                  ,  @c_ToLoc                 = @c_ToLoc         
                  ,  @c_LogicalToLoc          = @c_ToLoc   
                  ,  @c_ToID                  = @c_ToID 
                  ,  @c_CaseID                = @c_UCCNo
                  ,  @c_PickMethod            = 'PP'  
                  ,  @c_Status                = '0'
                  ,  @c_Priority              = @c_Priority    
                  ,  @c_SourcePriority        = @c_Priority      
                  ,  @c_SourceType            = @c_SourceType        
                  ,  @c_SourceKey             = @c_Wavekey        
                  ,  @c_OrderKey              = '' 
                  ,  @c_Wavekey               = @c_Wavekey 
                  ,  @c_Message01             = '' 
                  ,  @c_Message02             = ''                 
                  ,  @c_Message03             = ''  
                  ,  @n_SystemQty             = @n_UCCQty 
                  ,  @c_AreaKey               = '?F'  -- ?F=Get from location areakey                  
                  ,  @n_TransitCount          = @n_TransitCount        
                  ,  @c_TransitLOC            = @c_TransitLOC       
                  ,  @c_FinalLoc              = @c_FinalLoc
                  ,  @c_FinalID               = @c_FinalID
                  ,  @c_Groupkey              = @c_Groupkey 
                  ,  @n_PendingMoveIn         = @n_UCCQty
                  ,  @n_QtyReplen             = 0
                  ,  @c_LinkTaskToPick        = '' -- WIP=Update taskdetailkey to pickdetail_wip  
                  ,  @c_LinkTaskToPick_SQL    = ''    
                  ,  @c_WIP_RefNo             = @c_SourceType  
                  ,  @b_Success               = @b_Success OUTPUT  
                  ,  @n_Err                   = @n_err OUTPUT   
                  ,  @c_ErrMsg                = @c_errmsg OUTPUT  
                
                  IF @b_Success <> 1   
                  BEGIN  
                     SET @n_Continue = 3    
                  END 

                  SET @n_UCCCnt = @n_UCCCnt + 1
               END
            END
         END

         UPDATE pw
            SET pw.ToLoc = @c_FinalLoc
              , pw.ReplenishZone = @c_TaskdetailKey
         FROM #PICKDETAIL_WIP AS pw
         WHERE pw.DropID = @c_UCCNo

         SET @c_SectionKey_P = @c_SectionKey
         FETCH NEXT FROM @cur_RPF INTO @c_Storerkey
                                    ,  @c_Sku
                                    ,  @c_Lot
                                    ,  @c_FromLoc
                                    ,  @c_FromID
                                    ,  @c_UCCNo
                                    ,  @n_UCCQty
                                    ,  @c_Facility
                                    ,  @c_SectionKey
      END
      CLOSE @cur_RPF
      DEALLOCATE @cur_RPF
   END
QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV13_RPF'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      IF @n_Continue = 4 SET @b_Success = 4

      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END 
GO
GRANT EXECUTE ON mspRLWAV13_RPF TO NSQL
GO
