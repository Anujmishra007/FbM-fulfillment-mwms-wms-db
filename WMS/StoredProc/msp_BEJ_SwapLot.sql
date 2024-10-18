SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: msp_BEJ_SwapLot                                         */
/* Creation Date: 2024-10-14                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: UWP-24391 [FCR-837] Unilever Replenishment for Flowrack     */
/*        : locations                                                   */
/*        :                                                             */
/* Called By: Call by SQL Scheduler Job                                 */
/*          :                                                           */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2024-10-08  Wan      1.0   Created.                                  */
/************************************************************************/
CREATE OR ALTER PROC msp_BEJ_SwapLot
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT            = @@TRANCOUNT
         , @n_Continue        INT            = 1
         , @b_Success         INT            = 1
         , @n_Err             INT            = 0
         , @c_ErrMsg          NVARCHAR(255)  = ''
 
         , @c_Storerkey       NVARCHAR(15)   = ''
         , @c_SQL             NVARCHAR(500)  = ''

         , @CUR_JOB           CURSOR
   
   SET @CUR_JOB = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT cl.Storerkey
   FROM   CODELKUP cl WITH (NOLOCK)
   WHERE  cl.ListName = 'BEJSWAPLOT'
   AND    cl.SHORT    = 'Y'            --Short:EnableStep
   ORDER BY cl.UDF01, cl.Code          --UDF01:Priority, Code: JobStep
   
   OPEN @CUR_JOB
   
   FETCH NEXT FROM @CUR_JOB INTO @c_Storerkey 

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      BEGIN TRY
         SET @c_SQL = 'EXEC nsp_ChangePickDetailByStorer @c_StorerKey=@c_Storerkey'
         EXEC sp_ExecuteSQL @c_SQL
                           ,N'@c_Storerkey NVARCHAR(15)'
                           ,@c_Storerkey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @c_ErrMsg = ERROR_MESSAGE()
      END CATCH

      IF (XACT_STATE()) = -1  
      BEGIN
         SET @n_Continue = 3 
         ROLLBACK TRAN
      END  

      FETCH NEXT FROM @CUR_JOB INTO @c_Storerkey
   END
   CLOSE @CUR_JOB
   DEALLOCATE @CUR_JOB  
QUIT_SP:
   IF @n_continue=3    
   BEGIN  
      SET @b_Success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTCnt    
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
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
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
GRANT EXECUTE ON msp_BEJ_SwapLot TO nSQL
GO