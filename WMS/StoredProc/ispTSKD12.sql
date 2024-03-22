SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispTSKD12                                             */
/* Creation Date: 22-Mar-2024                                              */
/* Copyright: MAERSK                                                       */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: UWP-16615 - VNA Cancel Task Update TASKDETAIL Column           */
/*                                                                         */
/* Called By: isp_TaskDetail_Wrapper from Taskdetail Trigger               */
/*                                                                         */
/* Called By:                                                              */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 22-Mar-2024  WLChooi 1.0   DevOps Combine Script                        */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[ispTSKD12]   
      @c_Action        NVARCHAR(10),
      @c_Storerkey     NVARCHAR(15),  
      @b_Success       INT      OUTPUT,
      @n_Err           INT      OUTPUT, 
      @c_ErrMsg        NVARCHAR(250) OUTPUT
AS   
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @n_Continue        INT,
           @n_StartTCnt       INT,
           @c_Taskdetailkey   NVARCHAR(10),
           @c_Tasktype        NVARCHAR(10)
                                         
   SELECT @n_Continue = 1, @n_StartTCnt = @@TRANCOUNT, @n_Err = 0, @c_ErrMsg = '', @b_Success = 1
    
   IF @c_Action NOT IN('INSERT','UPDATE','DELETE')
      GOTO QUIT_SP      

   IF OBJECT_ID('tempdb..#INSERTED') IS NULL OR OBJECT_ID('tempdb..#DELETED') IS NULL
   BEGIN
      GOTO QUIT_SP
   END
      
   IF @c_Action = 'UPDATE' 
   BEGIN
      DECLARE Cur_Task CURSOR FAST_FORWARD READ_ONLY FOR
         SELECT I.Taskdetailkey, I.Tasktype
         FROM #INSERTED I 
         JOIN #DELETED D ON I.Taskdetailkey = D.Taskdetailkey
         WHERE I.Storerkey = @c_Storerkey
         AND I.Tasktype IN ('VNAOUT', 'VNAIN')
         AND D.[Status] <> '9'
         AND I.[Status] <> D.[Status]
         AND I.[Status] = 'X'
         AND I.SourceType = 'ispRLWAV69'
                                  
      OPEN Cur_Task
       
      FETCH NEXT FROM Cur_Task INTO @c_Taskdetailkey, @c_Tasktype
            
      WHILE @@FETCH_STATUS <> -1 AND (@n_continue = 1 or @n_continue = 2)
      BEGIN
         UPDATE dbo.TaskDetail
         SET [Status] = 'Q'
           , Userkey = ''
           , ToLoc = IIF(@c_Tasktype = 'VNAOUT', '', ToLoc)
           , LogicalToLoc = IIF(@c_Tasktype = 'VNAOUT', '', LogicalToLoc)
           , PendingMoveIn = IIF(@c_Tasktype = 'VNAOUT', 0, PendingMoveIn)
         WHERE TaskDetailKey = @c_Taskdetailkey

         IF @@ERROR <> 0
         BEGIN
            SELECT @n_Continue = 3 
            SELECT @n_Err = 38020
            SELECT @c_Errmsg = 'NSQL' + CONVERT(varchar(5),@n_Err)+': Update TASKDETAIL Failed. (ispTSKD12)'
         END           
           
         FETCH NEXT FROM Cur_Task INTO @c_Taskdetailkey, @c_Tasktype
      END
      CLOSE Cur_Task
      DEALLOCATE Cur_Task
   END   
       
   QUIT_SP:
   
   IF @n_Continue=3  -- Error Occured - Process AND Return
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'ispTSKD12'      
      --RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END  
END  
GO
GRANT EXECUTE ON [dbo].[ispTSKD12] TO [NSQL]
GO