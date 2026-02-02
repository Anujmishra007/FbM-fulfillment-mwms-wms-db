SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspTSKD01                                           */    
/* Creation Date: 2025-04-21                                             */
/* Copyright: Maersk Logistics                                           */    
/* Written by: Wan                                                       */      
/*                                                                       */    
/* Purpose: UWP-32707 - FCR-3957 - JCB Putaway Using TM SCE              */  
/*                                                                       */  
/* Called By: isp_TaskDetailTrigger_Wrapper from Taskdetail Trigger      */ 
/*                                                                       */    
/* Version: 1.1                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 2025-04-21  Wan      1.0   UWP-32707 - FCR-3957 - JCB Putaway Using TM*/
/*                            SCE                                        */ 
/* 2025-05-28  Wan01    1.1   FCR-3958 - JCB Picking Task                */
/*************************************************************************/

CREATE OR ALTER PROC dbo.mspTSKD01   
   @c_Action        NVARCHAR(10)
,  @c_Storerkey     NVARCHAR(15)  
,  @b_Success       INT           = 1  OUTPUT 
,  @n_Err           INT           = 0  OUTPUT 
,  @c_ErrMsg        NVARCHAR(250) = '' OUTPUT 
AS   
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @n_Continue           INT = 1
         , @n_StartTCnt          INT = @@TRANCOUNT
 
         , @c_Type               NVARCHAR(10) = ''
         , @c_MoveQTYAlloc       NVARCHAR(1)  = '' 
         , @c_TaskDetailkey      NVARCHAR(10) = ''  
         , @c_Sku                NVARCHAR(20) = '' 
         , @c_Lot                NVARCHAR(10) = ''  
         , @c_FromLoc            NVARCHAR(10) = ''
         , @c_FromID             NVARCHAR(18) = ''         
         , @c_ToLoc              NVARCHAR(10) = ''
         , @c_FinalLoc           NVARCHAR(10) = ''
         , @c_ToID               NVARCHAR(18) = ''
         , @c_DropID             NVARCHAR(20) = ''
         , @n_PendingMoveIn      INT          = 0
         , @n_QtyReplen          INT          = 0
 
         , @CUR_TASK             CURSOR
 
   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_ErrMsg = ''
       
   IF @c_Action NOT IN('INSERT','UPDATE','DELETE')
   BEGIN
      GOTO QUIT_SP
   END  

   IF OBJECT_ID('tempdb..#INSERTED') IS NULL OR OBJECT_ID('tempdb..#DELETED') IS NULL
   BEGIN
      GOTO QUIT_SP
   END

   -- PAF Task
   IF @c_Action = 'INSERT'
   BEGIN
      SET @c_Type = 'LOCK'
      SET @c_MoveQTYAlloc = '1'
      SET @CUR_TASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT I.Sku, I.Lot, I.FromLoc, I.FinalLoc, I.ToID, I.PendingMoveIn
      FROM #INSERTED I
      WHERE I.Storerkey = @c_Storerkey
      AND I.TaskType = 'PAF'  
      AND I.[Status] NOT IN ('9','X')
      AND I.ToID > '' 
      AND I.FromLoc > '' 
      AND I.ToLoc > '' 
      AND I.FinalLoc > '' AND I.ToLoc <> I.FinalLoc
      GROUP BY I.Sku, I.Lot, I.FromLoc, I.FinalLoc, I.ToID, I.PendingMoveIn, I.[Status], I.SourceKey
      ORDER BY MIN(I.TaskDetailkey)
   END
   ELSE IF @c_Action = 'UPDATE'
   BEGIN  
      SET @c_Type = 'UNLOCK'
      SET @c_MoveQTYAlloc = ''
      SET @CUR_TASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT I.Sku, I.Lot, I.ToLoc, I.FinalLoc, I.ToID, I.PendingMoveIn
      FROM #INSERTED I
      JOIN #DELETED D ON I.Taskdetailkey = D.Taskdetailkey 
      JOIN RFPutaway R (NOLOCK) ON R.SuggestedLoc = I.FinalLoc AND R.FromID = I.ToID
      WHERE I.Storerkey = @c_Storerkey
      AND I.TaskType = 'PAF'  
      AND I.[Status] <> D.[Status] 
      AND I.[Status] = 'X'
      AND I.ToID > ''
      AND I.ToLoc > '' 
      AND I.FinalLoc > ''
      GROUP BY I.Sku, I.Lot, I.ToLoc, I.FinalLoc, I.ToID, I.PendingMoveIn, I.[Status], D.[Status], I.SourceKey
      ORDER BY MIN(I.TaskDetailkey)
   END
   ELSE IF @c_Action = 'DELETE'
   BEGIN  
      SET @c_Type = 'UNLOCK'
      SET @c_MoveQTYAlloc = ''
      SET @CUR_TASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT D.Sku, D.Lot, D.ToLoc, D.FinalLoc, D.ToID, D.PendingMoveIn
      FROM #DELETED D 
      JOIN RFPutaway R (NOLOCK) ON R.SuggestedLoc = D.FinalLoc AND R.FromID = D.ToID
      WHERE D.Storerkey = @c_Storerkey
      AND D.TaskType = 'PAF' 
      AND D.[Status] NOT IN ('9','X')      
      AND D.ToID > '' 
      AND D.ToLoc > '' 
      AND D.FinalLoc > ''
      GROUP BY D.Sku, D.Lot, D.ToLoc, D.FinalLoc, D.ToID, D.PendingMoveIn, D.[Status], D.SourceKey
      ORDER BY MIN(D.TaskDetailkey)
   END

   OPEN @CUR_TASK            
      
   FETCH NEXT FROM @CUR_TASK INTO @c_Sku, @c_Lot, @c_ToLoc, @c_FinalLoc, @c_ToID, @n_PendingMoveIn
            
   WHILE @@FETCH_STATUS <> -1     
   BEGIN   
      EXEC rdt.rdt_Putaway_PendingMoveIn 
         @cUserName     = ''
      ,  @cType         = @c_Type
      ,  @cFromLoc      = @c_ToLoc
      ,  @cFromID       = @c_ToID
      ,  @cSuggestedLOC = @c_FinalLoc
      ,  @cStorerKey    = @c_Storerkey
      ,  @nErrNo        = @n_Err       OUTPUT
      ,  @cErrMsg       = @c_Errmsg    OUTPUT
      ,  @cSKU          = @c_Sku
      ,  @nPutawayQTY   = @n_PendingMoveIn
      ,  @cFromLOT      = @c_Lot
      ,  @cTaskDetailKey= ''
      ,  @nFunc         = 0
      ,  @nPABookingKey = 0
      ,  @cMoveQTYAlloc = @c_MoveQTYAlloc
                                                                                                               
      SET @n_err = @@ERROR                                                                             
                                                                                                                   
      IF @n_err <> 0                                                                                   
      BEGIN                                                                                            
         SET @n_continue = 3
         SET @n_err = 67810 
         SET @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err) 
                       + ': Execute rdt.rdt_Putaway_PendingMoveIn Failed! (mspTSKD01)'
      END           
      FETCH NEXT FROM @CUR_TASK INTO @c_Sku, @c_Lot, @c_ToLoc, @c_FinalLoc, @c_ToID, @n_PendingMoveIn
   END
   CLOSE @CUR_TASK
   DEALLOCATE @CUR_TASK            
 
   -- RPF Task                                                                      --Wan01 - START
   IF @c_Action = 'INSERT'                                                       
   BEGIN
      SET @CUR_TASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT I.Taskdetailkey, I.Sku, inv.Lot, I.FromLoc, I.FromID, I.DropID
            ,inv.QtyReplen 
      FROM #INSERTED I
      CROSS APPLY (  SELECT lli.Lot, QtyReplen = lli.Qty - lli.QtyReplen
                     FROM LOTxLOCxID lli (NOLOCK)
                     JOIN LOTAttribute la (NOLOCK) ON la.Lot = lli.lot
                     WHERE lli.Storerkey  = I.Storerkey
                     AND   lli.Loc  = I.FromLoc
                     AND   lli.ID   = I.FromID
                     AND   lli.Qty - lli.QtyReplen > 0
                     AND   la.Lottable11 = I.DropID
                  ) inv
      WHERE I.Storerkey = @c_Storerkey
      AND I.TaskType = 'RPF'  
      AND I.[Status] NOT IN ('9','X')
      AND I.FromLoc > '' 
      AND I.FromID > '' 
      AND I.ToLoc  > '' 
      AND I.Lot    = ''
      AND I.QtyReplen > 0
      ORDER BY I.TaskDetailkey
   END
   ELSE IF @c_Action = 'UPDATE'
   BEGIN  
      SET @CUR_TASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT I.Taskdetailkey, I.Sku, inv.Lot, I.FromLoc, I.FromID, I.DropID
            ,QtyReplen = CASE WHEN D.QtyReplen = 0 THEN inv.QtyReplen
                              ELSE (inv.QtyReplen * -1)
                              END
      FROM #INSERTED I
      JOIN #DELETED D ON I.Taskdetailkey = D.Taskdetailkey 
      CROSS APPLY (  SELECT lli.Lot, QtyReplen = lli.Qty 
                     FROM LOTxLOCxID lli (NOLOCK)
                     JOIN LOTAttribute la (NOLOCK) ON la.Lot = lli.lot
                     WHERE lli.Storerkey  = I.Storerkey
                     AND   lli.Loc  = I.FromLoc
                     AND   lli.ID   = I.FromID
                     AND   la.Lottable11 = I.DropID
                  ) inv
      WHERE I.Storerkey = @c_Storerkey
      AND I.TaskType = 'RPF'  
      AND ((I.[Status] <> D.[Status] AND I.[Status] IN ('X','9') AND 
            I.QtyReplen > 0) OR
           (I.[Status] NOT IN ('X','9') AND I.QtyReplen <> D.QtyReplen AND
           (I.QtyReplen = 0 OR D.QtyReplen = 0))
          )
      AND I.FromLoc > '' 
      AND I.FromID  > '' 
      AND I.FromLoc = D.FromLoc 
      AND I.FromID  = D.FromID 
      AND I.DropID  = D.DropID 
      AND I.ToLoc   > '' 
      AND I.Lot     = ''
      ORDER BY I.TaskDetailkey
   END
   ELSE IF @c_Action = 'DELETE'
   BEGIN  
      SET @CUR_TASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT D.Taskdetailkey, D.Sku, inv.Lot, D.FromLoc, D.FromID, D.DropID
            ,QtyReplen = (inv.QtyReplen * -1)
      FROM #DELETED D 
      CROSS APPLY (  SELECT lli.Lot, lli.QtyReplen
                     FROM LOTxLOCxID lli (NOLOCK)
                     JOIN LOTAttribute la (NOLOCK) ON la.Lot = lli.lot
                     WHERE lli.Storerkey = D.Storerkey
                     AND   lli.Loc  = D.FromLoc
                     AND   lli.ID   = D.FromID
                     AND   la.Lottable11 = D.DropID
                     AND   lli.QtyReplen > 0
                  ) inv
      WHERE D.Storerkey = @c_Storerkey
      AND D.TaskType = 'RPF' 
      AND D.[Status] NOT IN ('9','X')      
      AND D.FromLoc> '' 
      AND D.FromID > '' 
      AND D.ToLoc  > '' 
      AND D.Lot    = ''
      AND D.QtyReplen > 0
      ORDER BY D.TaskDetailkey 
   END

   OPEN @CUR_TASK            
      
   FETCH NEXT FROM @CUR_TASK INTO @c_TaskDetailkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID
                                 ,@c_DropID, @n_QtyReplen
            
   WHILE @@FETCH_STATUS <> -1     
   BEGIN  
      IF @n_QtyReplen <> 0
      BEGIN
         UPDATE LOTxLOCxID WITH (ROWLOCK)
            SET QtyReplen = QtyReplen + @n_QtyReplen
         WHERE Lot = @c_Lot
         AND   Loc = @c_FromLoc
         AND   ID  = @c_FromID
                                                                                                               
         SET @n_err = @@ERROR                                                                             
                                                                                                                   
         IF @n_err <> 0                                                                                   
         BEGIN                                                                                            
            SET @n_continue = 3
            SET @n_err = 67820 
            SET @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err) 
                          + ': Update LotxLocxID Failed! (mspTSKD01)'
         END     
      END

      IF @c_Action = 'UPDATE' AND @n_QtyReplen < 0 
      BEGIN
         IF EXISTS ( SELECT 1
                     FROM TaskDetail td (NOLOCK)
                     WHERE TaskDetailkey = @c_TaskDetailkey
                     AND QtyReplen > 0
                   )
         BEGIN
            UPDATE TaskDetail WITH (ROWLOCK)
               SET QtyReplen = 0
            WHERE TaskDetailkey = @c_TaskDetailkey
            AND QtyReplen > 0
                                                                                                               
            SET @n_err = @@ERROR                                                                             
                                                                                                                   
            IF @n_err <> 0                                                                                   
            BEGIN                                                                                            
               SET @n_continue = 3
               SET @n_err = 67830 
               SET @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err) 
                             + ': Update Taskdetail Failed! (mspTSKD01)'
            END  
         END          
      END
      FETCH NEXT FROM @CUR_TASK INTO @c_TaskDetailkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID
                                    ,@c_DropID, @n_QtyReplen
   END
   CLOSE @CUR_TASK
   DEALLOCATE @CUR_TASK                                                             --Wan01 - END  
   QUIT_SP:
   
   IF @n_Continue=3  -- Error Occured - Process AND Return
   BEGIN
      SET @b_Success = 0
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'mspTSKD01'     
    END
    ELSE
    BEGIN
       SET @b_Success = 1
       WHILE @@TRANCOUNT > @n_StartTCnt
       BEGIN
         COMMIT TRAN
       END
 
    END  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [mspTSKD01] TO NSQL
GO
