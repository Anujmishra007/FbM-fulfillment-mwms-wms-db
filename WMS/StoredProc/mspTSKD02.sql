SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspTSKD02                                           */    
/* Creation Date: 2026-01-28                                             */
/* Copyright: Maersk Logistics                                           */    
/* Written by: Wan                                                       */      
/*                                                                       */    
/* Purpose: FCR-9008 - ONBR Release Wave                                 */  
/*                                                                       */  
/* Called By: isp_TaskDetailTrigger_Wrapper from Taskdetail Trigger      */ 
/*                                                                       */    
/* Version: 1.1                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/*************************************************************************/

CREATE OR ALTER PROC dbo.mspTSKD02   
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

         , @c_TaskDetailkey      NVARCHAR(10) = ''  
         , @c_Sku                NVARCHAR(20) = '' 
         , @c_Lot                NVARCHAR(10) = ''  
         , @c_FromLoc            NVARCHAR(10) = ''
         , @c_FromID             NVARCHAR(18) = ''         
         , @c_ToLoc              NVARCHAR(10) = ''
         , @c_FinalLoc           NVARCHAR(10) = ''
         , @c_ToID               NVARCHAR(18) = ''
         , @c_UCCNo              NVARCHAR(20) = ''
         , @n_PendingMoveIn      INT          = 0
         , @n_UCC_RowRef         INT          = 0
         , @n_RowRef_rpa         INT          = 0
 
         , @CUR_TASK             CURSOR
 
   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_ErrMsg = ''
       
   IF @c_Action NOT IN ('INSERT','UPDATE','DELETE')
   BEGIN
      GOTO QUIT_SP
   END  

   IF OBJECT_ID('tempdb..#INSERTED') IS NULL OR OBJECT_ID('tempdb..#DELETED') IS NULL
   BEGIN
      GOTO QUIT_SP
   END
 
   -- RPF Task 
   IF @c_Action = 'INSERT'
   BEGIN  
      SET @CUR_TASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT I.Taskdetailkey, I.Storerkey, I.Sku, I.Lot, I.FromLoc, I.FromID, I.FinalLoc
            ,I.PendingMoveIn, I.CaseID
      FROM #INSERTED I
      WHERE I.Storerkey = @c_Storerkey
      AND I.TaskType = 'RPF'  
      AND I.FinalLoc > ''
      AND I.PendingMoveIn > 0
      AND I.[Status] NOT IN ('X','9')
      ORDER BY I.TaskDetailkey
   END
   ELSE IF @c_Action = 'UPDATE'
   BEGIN 
      SET @CUR_TASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT I.Taskdetailkey, I.Storerkey, I.Sku, I.Lot, I.FromLoc, I.FromID, I.FinalLoc
            ,I.PendingMoveIn, I.CaseID
      FROM #INSERTED I
      JOIN #DELETED D ON I.Taskdetailkey = D.Taskdetailkey 
      WHERE I.Storerkey = @c_Storerkey
      AND I.TaskType = 'RPF'  
      AND I.FinalLoc > ''
      AND I.PendingMoveIn > 0
      AND I.[Status] =  'X'
      AND D.[Status] <> 'X'
      UNION
      SELECT td.Taskdetailkey, I.Storerkey, I.Sku, td.Lot, td.FromLoc, td.FromID , td.FinalLoc
            ,td.PendingMoveIn, td.CaseID
      FROM #INSERTED I
      JOIN #DELETED D ON I.Taskdetailkey = D.Taskdetailkey 
      JOIN TaskDetail td (NOLOCK) ON  td.TaskType      = 'RPF'
                                  AND td.Storerkey     = I.Storerkey
                                  AND td.Sku           = I.Sku
                                  AND td.TaskDetailKey = I.Sourcekey
                                  AND td.[Status]      = '9'
                                  AND td.Toloc         = I.FromLoc
                                  AND td.FinalLoc      = I.Toloc
      WHERE I.Storerkey = @c_Storerkey
      AND I.TaskType = 'ASTRPT'  
      AND I.ToLoc    > ''
      AND I.[Status] =  'X'
      AND D.[Status] <> 'X'  
      ORDER BY I.TaskDetailkey
   END
   ELSE IF @c_Action = 'DELETE'
   BEGIN  
      SET @CUR_TASK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT D.Taskdetailkey, D.Storerkey, D.Sku, D.Lot, D.FromLoc, D.FromID, D.FinalLoc
            ,D.PendingMoveIn, D.CaseID
      FROM #DELETED D 
      WHERE D.Storerkey = @c_Storerkey
      AND D.TaskType = 'RPF' 
      AND D.[Status] NOT IN ('9','X')      
      AND D.FinalLoc > ''
      AND D.PendingMoveIn > 0
      UNION
      SELECT td.Taskdetailkey, D.Storerkey, D.Sku, td.Lot, td.FromLoc, td.FromID , td.FinalLoc
            ,td.PendingMoveIn, td.CaseID
      FROM #DELETED D 
      JOIN TaskDetail td (NOLOCK) ON  td.TaskType      = 'RPF'
                                  AND td.Storerkey     = d.Storerkey
                                  AND td.Sku           = d.Sku
                                  AND td.TaskDetailKey = d.Sourcekey
                                  AND td.[Status]      = '9'
                                  AND td.PendingMoveIn > 0
                                  AND td.Toloc         = d.FromLoc
                                  AND td.FinalLoc      = d.Toloc
      WHERE D.Storerkey = @c_Storerkey
      AND D.TaskType = 'ASTRPT' 
      AND D.[Status] NOT IN ('9','X')      
      AND D.ToLoc > ''
      ORDER BY D.TaskDetailkey 
   END

   OPEN @CUR_TASK            
      
   FETCH NEXT FROM @CUR_TASK INTO @c_TaskDetailkey, @c_Storerkey, @c_Sku
                                 ,@c_Lot, @c_FromLoc, @c_FromID, @c_ToLoc
                                 ,@n_PendingMoveIn, @c_UCCNo
            
   WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1    
   BEGIN  
      IF @c_Action = 'INSERT'
      BEGIN
         EXEC rdt.rdt_Putaway_PendingMoveIn   
            @cUserName     = @c_TaskDetailkey 
         ,  @cType         = 'LOCK'  
         ,  @cFromLoc      = @c_FromLoc  
         ,  @cFromID       = @c_FromID
         ,  @cSuggestedLOC = @c_ToLoc
         ,  @cStorerKey    = @c_Storerkey  
         ,  @nErrNo        = @n_Err       OUTPUT  
         ,  @cErrMsg       = @c_Errmsg    OUTPUT  
         ,  @cSKU          = @c_Sku  
         ,  @nPutawayQTY   = @n_PendingMoveIn
         ,  @cFromLOT      = @c_Lot
         ,  @cTaskDetailKey= @c_TaskDetailkey
         ,  @nFunc         = 0  
         ,  @cMoveQTYAlloc = '1'  
                                                                                                               
         SET @n_err = @@ERROR                                                                             
                                                                                                                   
         IF @n_err <> 0                                                                                   
         BEGIN                                                                                            
            SET @n_Continue = 3
         END 

         IF @n_Continue = 1 
         BEGIN
            SET @n_RowRef_rpa = 0
            SELECT @n_RowRef_rpa = rpa.RowRef 
            FROM RFPUTAWAY rpa (NOLOCK)
            WHERE rpa.ptcid = @c_TaskDetailkey
            AND   rpa.Sku   = @c_Sku
            AND   rpa.SuggestedLoc = @c_ToLoc
            AND   rpa.TaskDetailkey = @c_TaskDetailkey

            IF @n_RowRef_rpa > 0
            BEGIN
               UPDATE rpa WITH (ROWLOCK)
                  SET rpa.TaskDetailkey = ''
                    , TrafficCop = NULL
               FROM RFPUTAWAY rpa
               WHERE rpa.RowRef = @n_RowRef_rpa

               SET @n_err = @@ERROR                                                                             
                                                                                                                   
               IF @n_err <> 0                                                                                   
               BEGIN                                                                                            
                  SET @n_Continue = 3
               END 
            END
         END

         IF @n_Continue = 1 AND @c_UCCNo > ''
         BEGIN
            SET @n_UCC_RowRef = 0

            SELECT @n_UCC_RowRef = UCC.UCC_RowRef
            FROM UCC (NOLOCK)
            WHERE UCC.Storerkey = @c_Storerkey
            AND UCC.UCCNo = @c_UCCNo
            AND UCC.Status = '1'

            IF @n_UCC_RowRef > 0
            BEGIN
               UPDATE UCC WITH (ROWLOCK)
               SET UCC.[Status] = '3'
               WHERE UCC.UCC_RowRef = @n_UCC_RowRef

               SET @n_err = @@ERROR                                                                             
                                                                                                                   
               IF @n_err <> 0                                                                                   
               BEGIN                                                                                            
                  SET @n_Continue = 3
                  SET @c_ErrMsg = ERROR_MESSAGE()
               END 
            END
         END
      END
      ELSE
      BEGIN 
         IF @n_Continue = 1 AND @c_UCCNo > ''
         BEGIN
            SET @n_UCC_RowRef = 0

            SELECT @n_UCC_RowRef = UCC.UCC_RowRef
            FROM UCC (NOLOCK)
            WHERE UCC.Storerkey = @c_Storerkey
            AND UCC.UCCNo = @c_UCCNo
            AND UCC.Status = '3'

            IF @n_UCC_RowRef > 0
            BEGIN
               UPDATE UCC WITH (ROWLOCK)
               SET UCC.[Status] = '1'
               WHERE UCC.UCC_RowRef = @n_UCC_RowRef

               SET @n_err = @@ERROR                                                                             
                                                                                                                   
               IF @n_err <> 0                                                                                   
               BEGIN                                                                                            
                  SET @n_Continue = 3
                  SET @c_ErrMsg = ERROR_MESSAGE()
               END 
            END
         END

         IF @n_Continue = 1
         BEGIN
            SELECT @c_Lot  = rpa.Lot
                  ,@c_ToId = rpa.ID
            FROM RFPUTAWAY rpa (NOLOCK)
            WHERE Taskdetailkey = @c_TaskDetailkey
            AND   SuggestedLoc  = @c_ToLoc

            IF EXISTS ( SELECT 1
                        FROM LOTxLOCxID lli (NOLOCK)
                        WHERE lli.Storerkey = @c_Storerkey
                        AND   lli.Lot  = @c_Lot
                        AND   lli.Loc  = @c_ToLoc
                        AND   lli.ID   = @c_ToID
                     )
            BEGIN
               EXEC rdt.rdt_Putaway_PendingMoveIn   
                  @cUserName     = @c_TaskdetailKey  
               ,  @cType         = 'UNLOCK'  
               ,  @cFromLoc      = ''  
               ,  @cFromID       = ''  
               ,  @cSuggestedLOC = @c_ToLoc
               ,  @cStorerKey    = @c_Storerkey  
               ,  @nErrNo        = @n_Err OUTPUT  
               ,  @cErrMsg       = @c_Errmsg OUTPUT  
               ,  @cSKU          = @c_Sku  
               ,  @nPutawayQTY   = 0  
               ,  @cFromLOT      = ''  
               ,  @cTaskDetailKey= ''
               ,  @nFunc         = 0  
                                                                                                               
               SET @n_err = @@ERROR                                                                             
                                                                                                                   
               IF @n_err <> 0                                                                                   
               BEGIN                                                                                            
                  SET @n_Continue = 3
               END 
            END
         END
      END
      FETCH NEXT FROM @CUR_TASK INTO @c_TaskDetailkey, @c_Storerkey, @c_Sku
                                    ,@c_Lot, @c_FromLoc, @c_FromID, @c_ToLoc
                                    ,@n_PendingMoveIn, @c_UCCNo
   END
   CLOSE @CUR_TASK
   DEALLOCATE @CUR_TASK                                                            
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'mspTSKD02'     
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

GRANT EXECUTE ON [mspTSKD02] TO NSQL
GO
