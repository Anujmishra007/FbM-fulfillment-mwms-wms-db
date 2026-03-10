SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/    
/* Stored Procedure: mspRLWAV10_DATA                                     */    
/* Creation Date: 2026-01-22                                             */    
/* Copyright: Maersk Logistics                                           */    
/* Written by: Wan                                                       */    
/*                                                                       */    
/* Purpose: FCR-10124 - UK Columbia SportWear Release Wave               */   
/*                                                                       */    
/* Called By: Wave                                                       */    
/*                                                                       */    
/* Version: 1.1                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 10-Feb-2026 WLChooi  1.0   Initial Version                            */
/* 10-Mar-2026 WLChooi  1.1   FCR-11514 Update UOM to 6 for PU VAS (WL01)*/
/*************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV10_DATA]        
   @c_Wavekey     NVARCHAR(10)
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

         , @c_Facility           NVARCHAR(5) = ''
         , @c_Storerkey          NVARCHAR(15)= ''
         , @c_SourceType         NVARCHAR(30)= 'mspRLWAV10'
         , @c_PickCondition_SQL  NVARCHAR(MAX)= ''

         , @c_SQL                NVARCHAR(MAX) = ''
         , @c_SQLParms           NVARCHAR(2000)= ''
         , @c_SQLWhere           NVARCHAR(MAX) = ''                                    
  
   --@n_Err Start 62010
   SET @c_PickCondition_SQL = 'PICKDETAIL.Status = ''0'' AND PICKDETAIL.Qty > 0'

   IF @n_debug = 5
   BEGIN
      SET @c_PickCondition_SQL = 'PICKDETAIL.Qty > 0'
   END
 
   SET @c_PickCondition_SQL = @c_PickCondition_SQL 
                            + ' AND NOT EXISTS (SELECT 1'
                            +                '  FROM TASKDETAIL td (NOLOCK)' 
                            +                '  WHERE td.TaskdetailKey = PICKDETAIL.TaskdetailKey'
                            +                '  AND td.Tasktype = ''CPK'''
                            +                '  AND td.SourceType    = ''mspRLWAV10'''
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

   --WL01 S
   IF @n_Continue = 1
   BEGIN
      UPDATE #PickDetail_WIP 
      SET UOM = '6'
        , PickMethod = '3'
      FROM #PickDetail_WIP pd
      JOIN dbo.WorkOrderDetail wod (NOLOCK) ON wod.ExternWorkOrderKey = pd.Orderkey
                                           AND wod.ExternLineNo = pd.OrderLineNumber
      WHERE pd.UOM = '2'
      AND wod.[Type] IN ( 'PU' )
      AND wod.Qty > 0
   END
   --WL01 E
 
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

      -- Stamp RefTaskKey = Taskdetailkey of RPF/ASTPA task by DropID
      -- Set CPK Task FromLoc from Taskdetail
      -- Set CPK Task Status=H
      UPDATE pw
         SET pw.ToLoc = CASE WHEN pw.UOM = '2' THEN pw.Loc
                             WHEN td_rpf.TaskDetailKey IS NOT NULL THEN td_rpf.FinalLoc
                             WHEN td_asttpa.TaskDetailKey IS NOT NULL THEN td_asttpa.ToLoc
                             ELSE pw.Loc END
            ,pw.UpdateSource = CASE WHEN td_rpf.TaskDetailKey IS NOT NULL THEN td_rpf.TaskDetailKey
                                    WHEN td_asttpa.TaskDetailKey IS NOT NULL THEN td_asttpa.TaskDetailKey
                                    ELSE '' END
      FROM #PICKDETAIL_WIP AS pw
      LEFT OUTER JOIN TaskDetail td_rpf (NOLOCK)
             ON td_rpf.TaskType   IN ('RPF','RP1')
            AND td_rpf.CaseID     = pw.DropID
            AND td_rpf.Status     NOT IN ('X','9')
            AND td_rpf.Storerkey  = pw.Storerkey
      LEFT OUTER JOIN TaskDetail td_asttpa (NOLOCK)
             ON td_asttpa.TaskType = 'ASTTPA'
            AND td_asttpa.CaseID   = pw.DropID
            AND td_asttpa.Status   NOT IN ('X','9')
            AND td_asttpa.Storerkey= pw.Storerkey
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV10_DATA'
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
GRANT EXECUTE ON [dbo].[mspRLWAV10_DATA] TO [NSQL]
GO