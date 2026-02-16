SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Store Procedure: isp_UnAllocate_ExtVal_JCB                                */
/* Creation Date: 02/12/2025                                                 */
/* Copyright: MAERSK                                                         */
/* Updates:                                                                  */
/* Date         Author    Ver.  Purposes                                     */
/* 02/12/2025   PPA374    1.0   Not allowing to unallocate when consolidated */
/* 15/01/2026   SKE140    2.0   Updating tasks with status 9 to 0 to delete  */
/* 13/02/2026   PPA374    2.1   Adding child logic check to avoid deleting   */
                                parent tasks that got no direct pick detail  */
/*****************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_UnAllocate_ExtVal_JCB]
          @c_Pickdetailkey NVARCHAR(20),
          @c_Orderkey      NVARCHAR(20),
          @b_Success       INT OUTPUT,
          @n_Err           INT OUTPUT,
          @c_ErrMsg        NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
          
   DECLARE @cTaskDetailKey AS NVARCHAR(20)
   DECLARE @cStorerKey     AS NVARCHAR(20)  

   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_ErrMsg = ''

   SELECT TOP 1
          @c_Orderkey = OrderKey,
          @cTaskDetailKey = TaskDetailKey,
		  @cStorerKey = StorerKey 
   FROM #DELETEDPICK WITH (NOLOCK)
   WHERE PickDetailKey = @c_Pickdetailkey

   IF EXISTS (
      SELECT TOP 1 1
      FROM #DELETEDPICK PD WITH (NOLOCK)
      INNER JOIN #DELETEDPICK PD2 WITH (NOLOCK)
         ON PD.ID = PD2.ID
        AND PD.StorerKey = PD2.StorerKey
      INNER JOIN dbo.ORDERS O WITH (NOLOCK)
         ON PD.OrderKey = O.OrderKey
        AND PD.StorerKey = O.StorerKey
      WHERE PD.OrderKey <> @c_Orderkey
        AND PD2.OrderKey = @c_Orderkey
        AND PD.StorerKey = @cStorerKey
        AND O.Type = '2'
		AND PD.DropID <> ''
   )
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 99999
      SET @c_ErrMsg = 'Cannot unallocate consolidated pickdetail'
      GOTO QUIT
   END

   IF ISNULL(@c_Orderkey,'') <> ''
   BEGIN
      -- New: unlock status-9 tasks so they can be removed
      UPDATE dbo.TaskDetail
      SET Status = '0',
          TrafficCop = NULL
      WHERE TaskDetail.OrderKey = @c_Orderkey
         AND TaskDetail.Storerkey = @cStorerKey
         AND TaskDetail.Status = '9'
         AND COALESCE(TaskDetail.StatusMsg,'') <> 'Swapping'
         AND TaskDetail.TaskType IN ('FCP','FCP1')
  
         -- No direct PICKDETAIL exists
         AND NOT EXISTS (
            SELECT 1
            FROM dbo.PICKDETAIL PD WITH(NOLOCK)
            WHERE PD.OrderKey = TaskDetail.OrderKey
               AND PD.TaskDetailKey = TaskDetail.TaskDetailKey
               AND PD.Storerkey = TaskDetail.Storerkey
         )

         -- No PICKDETAIL exists for any TaskDetail where SourceKey = current TaskDetailKey
         AND NOT EXISTS (
            SELECT 1
            FROM dbo.TaskDetail TD1 WITH(NOLOCK)
            INNER JOIN dbo.PICKDETAIL PD WITH(NOLOCK)
               ON PD.TaskDetailKey = TD1.TaskDetailKey
               AND PD.Storerkey = TD1.Storerkey
               AND PD.OrderKey = TD1.OrderKey
            WHERE TD1.SourceKey = TaskDetail.TaskDetailKey
         )

      DELETE FROM dbo.TaskDetail
      WHERE OrderKey = @c_Orderkey
        AND Status NOT IN ('9','X')
        AND Storerkey = @cStorerKey
        AND ISNULL(StatusMsg,'') <> 'Swapping'
        AND NOT EXISTS (
           SELECT 1
           FROM dbo.PICKDETAIL PD WITH (NOLOCK)
           WHERE OrderKey = @c_Orderkey
              AND TaskDetail.TaskDetailKey = PD.TaskDetailKey
              AND TaskDetail.Storerkey = PD.Storerkey
              AND PD.Storerkey = @cStorerKey
        )
        AND TaskType IN ('FCP','FCP1')
		AND NOT EXISTS (
            SELECT 1
            FROM dbo.TaskDetail TD1 WITH(NOLOCK)
            INNER JOIN dbo.PICKDETAIL PD WITH(NOLOCK)
               ON PD.TaskDetailKey = TD1.TaskDetailKey
               AND PD.Storerkey = TD1.Storerkey
               AND PD.OrderKey = TD1.OrderKey
            WHERE TD1.SourceKey = TaskDetail.TaskDetailKey
         )
   END
QUIT:
END
