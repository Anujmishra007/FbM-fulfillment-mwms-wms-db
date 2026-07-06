SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/**************************************************************************/    
/* Stored Procedure: mspRLWAV13_DATA                                      */    
/* Creation Date: 2026-06-16                                              */    
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
/**************************************************************************/   
 
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV13_DATA]        
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
         , @n_RowCount           INT   = 0

         , @c_SourceType         NVARCHAR(30)= 'mspRLWAV13'
         , @c_PickCondition_SQL  NVARCHAR(MAX)= ''

   --@n_Err Start 62010
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
   END

   --@n_Err Start 62010
   SET @c_PickCondition_SQL = 'PICKDETAIL.Status < ''5'' AND PICKDETAIL.Qty > 0'

   IF @n_debug = 5
   BEGIN
      SET @c_PickCondition_SQL = 'PICKDETAIL.Status >= ''0'''
   END
 
   SET @c_PickCondition_SQL = @c_PickCondition_SQL 
                            + ' AND NOT EXISTS (SELECT 1'
                            +                '  FROM TASKDETAIL td (NOLOCK)' 
                            +                '  WHERE td.TaskdetailKey = PICKDETAIL.TaskdetailKey'
                            +                '  AND td.Taskdetailkey = ''FCP'''
                            +                '  AND td.SourceType    = ''mspRLWAV13'''
                            +                '  AND td.[Status]      <> ''X'''
                            +                ' )'
 
   EXEC isp_CreatePickdetail_WIP 
      @c_Loadkey = ''                                 
   ,  @c_Wavekey   = @c_Wavekey
   ,  @c_WIP_RefNo = @c_SourceType
   ,  @c_PickCondition_SQL = @c_PickCondition_SQL  
   ,  @c_Action  = 'I' --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records    
   ,  @c_RemoveTaskdetailkey = 'N' --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
   ,  @b_Success = @b_Success OUTPUT
   ,  @n_Err     = @n_err     OUTPUT
   ,  @c_ErrMsg  = @c_errmsg  OUTPUT
 
   IF @b_Success <> 1
   BEGIN
      SET @n_continue = 3
   END

   IF @b_Success <> 1
   BEGIN
      SET @n_continue = 3
   END
 
   IF @n_Continue = 1
   BEGIN
      UPDATE pw
         SET pw.Taskdetailkey = ''
      FROM #PICKDETAIL_WIP AS pw

      -- Get RPF FinalLoc to Pickdetail WIP ToLoc for Validation, Pre-Cartonization & Picking
      -- UOM = 2  UCC (Multiple Orderkey) 
      -- UOM = 6, RPF to DPP, Pick from DPP
      UPDATE pw
         SET pw.ToLoc        = ISNULL(td.FinalLoc,IIF(pw.UOM = '6' AND pw.DropID = u.UCCNo,'',pw.Loc))  
            ,pw.ReplenishZone= ISNULL(td.TaskDetailKey,'')
      FROM #PICKDETAIL_WIP AS pw
      LEFT OUTER JOIN TaskDetail td (NOLOCK) ON  td.TaskType = 'RPF' 
                                             AND td.CaseID   = pw.DropID
                                             AND td.Status   <> 'X'
                                             AND td.Storerkey= pw.Storerkey
                                             AND td.SourceType = @c_SourceType
      OUTER APPLY (SELECT TOP 1 ucc.UCCNo
                   FROM UCC (NOLOCK) 
                   WHERE ucc.Storerkey = pw.Storerkey
                   AND ucc.UCCNo   = pw.DropID
                   ) u
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV13_DATA'
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
GRANT EXECUTE ON mspRLWAV10_DATA TO NSQL
GO
