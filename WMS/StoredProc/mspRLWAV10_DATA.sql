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
/* Version: 1.0                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 10-Feb-2026 WLChooi  1.0   Initial Version                            */
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
         , @c_RPFSourceType      NVARCHAR(30)= 'msp_RCM_WV_Col_Dynam'
         , @c_RPFSourceType2     NVARCHAR(30)= 'msp_RCM_WV_Col_DynamicReplen'
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
                            +                '  AND td.Taskdetailkey = ''CPK'''
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
      -- UOM = 2, 1 order = 1 UCCNo to packstation
      -- UOM = 6, RPF To DP,  Pick from DP
      -- UOM = 7, RPF to DPP, Pick from DPP
      UPDATE pw
         SET pw.ToLoc = CASE WHEN td.Taskdetailkey IS NULL THEN pw.Loc 
                             WHEN pw.UOM = '2' THEN pw.Loc 
                             ELSE td.FinalLoc END
            ,pw.UpdateSource = CASE WHEN td.TaskDetailKey IS NOT NULL 
                                    THEN td.TaskDetailKey
                                    ELSE ''
                                    END
      FROM #PICKDETAIL_WIP AS pw
      LEFT OUTER JOIN TaskDetail td (NOLOCK) ON  td.TaskType IN ('RPF','RP1')
                                             AND td.CaseID   = pw.DropID
                                             AND td.Status   NOT IN ('X','9')
                                             AND td.Storerkey= pw.Storerkey
                                             AND td.ToID     = pw.ID
                                             AND td.SourceType IN (@c_RPFSourceType, @c_RPFSourceType2)
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