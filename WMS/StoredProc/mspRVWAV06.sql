SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspRVWAV06                                          */    
/* Creation Date: 2025-03-14                                             */
/* Copyright: Maersk Logistics                                           */    
/* Written by: Wan                                                       */    
/*                                                                       */    
/* Purpose: UWP-31639 - [FCR-3286] Generate replenishment from wave release*/  
/*                                                                       */  
/*                                                                       */    
/* Called By: Wave Release                                               */    
/*                                                                       */    
/* PVCS Version: 1.0                                                     */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV06]
  @c_Wavekey      NVARCHAR(10)
 ,@c_Orderkey     NVARCHAR(10)   = ''
 ,@b_Success      int            = 1   OUTPUT
 ,@n_Err          int            = 0   OUTPUT
 ,@c_Errmsg       NVARCHAR(250)  = ''  OUTPUT
 AS
 BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue           INT = 1
         , @n_StartTCnt          INT = @@TRANCOUNT         -- Holds the current transaction count
         , @n_debug              INT = 0
         , @n_cnt                INT = 0

         , @n_UCC_RowRef         INT            = 0
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_Facility           NVARCHAR(5)    = ''
         , @c_SourceType         NVARCHAR(30)   = 'mspRLWAV05'
         , @c_ReplenishmentKey   NVARCHAR(10)    = ''

         , @CUR_DELREPL          CURSOR
 

   SET @b_success = 0
   SET @n_Err = 0
   SET @c_Errmsg = ''

   -----Get Storerkey and facility

   SELECT TOP 1 @c_StorerKey = O.Storerkey,
               @c_Facility = O.Facility
   FROM WAVE W (NOLOCK)
   JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
   JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
   WHERE WD.Wavekey = @c_Wavekey

   IF NOT EXISTS (SELECT 1 FROM REPLENISHMENT rpl (NOLOCK)
                  WHERE rpl.Wavekey = @c_Wavekey
                 ) 
   BEGIN
      SET @n_Continue = 3    
      SET @n_Err   = 81010    
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                   +': Replenishment has not been created (mspRVWAV06)'         
   END

----reject if any task was started  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN 
      IF EXISTS ( SELECT 1 FROM REPLENISHMENT rpl (NOLOCK)
                  WHERE rpl.Wavekey = @c_Wavekey
                  AND rpl.Confirmed IN ('S','Y')
                )
      BEGIN  
          SET @n_Continue = 3    
          SET @n_Err    = 81020    
          SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                       +': Replenishment is in progress/done. Reverse is not allowed (mspRVWAV06)'         
      END                   
   END  
    
   ----delete tasks  
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN 
      SET @CUR_DELREPL = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT rpl.ReplenishmentKey
            ,UCC.UCC_RowRef
      FROM REPLENISHMENT rpl (NOLOCK)
      JOIN UCC (NOLOCK) ON  UCC.Storerkey = rpl.Storerkey
                        AND UCC.UCCNo = rpl.RefNo
                        AND UCC.[Status] = '4'
      WHERE rpl.Wavekey = @c_Wavekey
      AND rpl.Confirmed = 'N'
      ORDER BY ReplenishmentKey

      OPEN @CUR_DELREPL

      FETCH NEXT FROM @CUR_DELREPL INTO @c_ReplenishmentKey, @n_UCC_RowRef
 
      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         DELETE REPLENISHMENT WITH (ROWLOCK)
         WHERE ReplenishmentKey = @c_ReplenishmentKey   
           
         SET @n_err = @@ERROR  
         IF @n_err <> 0   
         BEGIN  
            SET @n_continue = 3    
         END 

         UPDATE UCC WITH (ROWLOCK)
            SET [Status] = '3'
         WHERE UCC_RowRef = @n_UCC_RowRef
         AND Status = '4'

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
         END

         FETCH NEXT FROM @CUR_DELREPL INTO @c_ReplenishmentKey, @n_UCC_RowRef
      END
      CLOSE @CUR_DELREPL
      DEALLOCATE @CUR_DELREPL
   END  

QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0
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
      execute nsp_logerror @n_Err, @c_Errmsg, 'mspRVWAV06'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END
GO
GRANT EXECUTE ON [dbo].[mspRVWAV06] TO [NSQL]
GO
