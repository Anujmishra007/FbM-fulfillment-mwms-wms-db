SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*****************************************************************************/
/* Store Procedure: isp_UnAllocate_ExtVal_JCB                                */
/* Creation Date: 02/12/2025                                                 */
/* Copyright: MAERSK                                                         */
/* Updates:                                                                  */
/* Date         Author    Ver.  Purposes                                     */
/* 02/12/2025   PPA374    1.0   Not allowing to unallocate when consolidated */
/* 15/01/2026   SKE140    2.0   Updating tasks with status 9 to 0 to delete  */
/*****************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_UnAllocate_ExtVal_JCB]
          @c_Pickdetailkey NVARCHAR(20),
          @c_Orderkey      NVARCHAR(20),
          @b_Success       INT OUTPUT,
          @n_Err           INT OUTPUT,
          @c_ErrMsg        NVARCHAR(250) OUTPUT
AS
BEGIN

   DECLARE @cTaskDetailKey AS NVARCHAR(20)

   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_ErrMsg = ''

   SELECT TOP 1
          @c_Orderkey = OrderKey,
          @cTaskDetailKey = TaskDetailKey
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
        AND PD.StorerKey = 'JCB'
        AND O.Type = '2'
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
      WHERE OrderKey = @c_Orderkey
        AND Status = '9'
        AND Storerkey = 'JCB'
        AND ISNULL(StatusMsg,'') <> 'Swapping'
        AND NOT EXISTS (
           SELECT 1
           FROM dbo.PICKDETAIL PD WITH (NOLOCK)
           WHERE OrderKey = @c_Orderkey
              AND TaskDetail.TaskDetailKey = PD.TaskDetailKey
              AND TaskDetail.Storerkey = PD.Storerkey
              AND PD.Storerkey = 'JCB'
        )
        AND TaskType IN ('FCP','FCP1')

      DELETE FROM dbo.TaskDetail
      WHERE OrderKey = @c_Orderkey
        AND Status NOT IN ('9','X')
        AND Storerkey = 'JCB'
        AND ISNULL(StatusMsg,'') <> 'Swapping'
        AND NOT EXISTS (
           SELECT 1
           FROM dbo.PICKDETAIL PD WITH (NOLOCK)
           WHERE OrderKey = @c_Orderkey
              AND TaskDetail.TaskDetailKey = PD.TaskDetailKey
              AND TaskDetail.Storerkey = PD.Storerkey
              AND PD.Storerkey = 'JCB'
        )
        AND TaskType IN ('FCP','FCP1')
   END
QUIT:
END
