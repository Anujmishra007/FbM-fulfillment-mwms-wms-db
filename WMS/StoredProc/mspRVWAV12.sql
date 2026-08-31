SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/  
/* Stored Procedure: mspRVWAV12                                          */  
/* Creation Date: 05-Jun-2026                                            */  
/* Copyright: Maersk                                                     */  
/* Written by: WLChooi                                                   */  
/*                                                                       */  
/* Purpose: FCR-13582 Australia - MWMS V2 CASTLERY PTE LTD - Release Wave*/  
/*          Reverse Wave Release                                         */  
/*          Modify from ispRVWVAU1                                       */  
/*                                                                       */  
/* Called By: Wave                                                       */  
/*                                                                       */  
/* Version: 1.0                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */  
/* 05-Jun-2026 WLChooi  1.0   Initial Version                            */  
/*************************************************************************/  
CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV12]   
      @c_Wavekey      NVARCHAR(10)
    , @c_Orderkey     NVARCHAR(10) = ''
    , @b_Success      INT              OUTPUT
    , @n_Err          INT              OUTPUT
    , @c_Errmsg       NVARCHAR(250)    OUTPUT
AS   
BEGIN   
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF   
  
   DECLARE @n_Continue  INT
         , @n_Starttcnt INT -- Holds the current transaction count   
         , @n_Debug     INT = 0
         , @n_Cnt       INT
  
   SET @n_Debug = ISNULL(@n_Err, 0)

   SELECT @n_Starttcnt = @@TRANCOUNT
        , @n_Continue = 1
        , @b_Success = 0
        , @n_Err = 0
        , @c_Errmsg = ''
        , @n_Cnt = 0

   DECLARE @c_Storerkey     NVARCHAR(15)
         , @c_Sku           NVARCHAR(20)
         , @c_Lot           NVARCHAR(10)
         , @c_ToLoc         NVARCHAR(10)
         , @c_ToID          NVARCHAR(18)
         , @n_Qty           INT
         , @c_Taskdetailkey NVARCHAR(10)
         , @c_Facility      NVARCHAR(5)
         , @c_authority     NVARCHAR(10)
         , @c_FromLoc       NVARCHAR(10)
         , @c_FromID        NVARCHAR(18)

   SELECT TOP 1 @c_Storerkey = O.StorerKey
              , @c_Facility = O.Facility
   FROM WAVEDETAIL WD (NOLOCK)
   JOIN ORDERS O (NOLOCK) ON (WD.OrderKey = O.OrderKey)
   WHERE WD.WaveKey = @c_Wavekey 
  
   ----reject if wave not yet release   
   IF @n_Continue = 1 OR @n_Continue = 2   
   BEGIN   
      IF NOT EXISTS (  SELECT 1
                       FROM TaskDetail TD (NOLOCK)
                       WHERE TD.WaveKey = @c_Wavekey
                       AND   TD.SourceType = 'mspRLWAV12'
                       AND   TD.TaskType IN ( 'FPK', 'FCP', 'FPP' ))
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 81010
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': This Wave has not been released. (mspRVWAV12)'
      END
   END   
  
   ----reject if any task was started   
   IF @n_Continue = 1 OR @n_Continue = 2   
   BEGIN   
      IF EXISTS (  SELECT 1
                   FROM TaskDetail TD (NOLOCK)
                   WHERE TD.WaveKey = @c_Wavekey
                   AND   TD.SourceType = 'mspRLWAV12'
                   AND   TD.TaskType IN ( 'FPK', 'FCP', 'FPP' )
                   AND   TD.Status <> '0')
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 81020
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                            + ': Some Tasks have been started. Not allow to Reverse Wave Released (mspRVWAV12)'
      END  
   END   
   
   IF @n_Debug = 0
      BEGIN TRAN
  
   ----delete tasks   
   IF @n_Continue = 1 OR @n_Continue = 2   
   BEGIN
      BEGIN TRY
         DELETE TaskDetail
         WHERE TaskDetail.WaveKey = @c_Wavekey
         AND   TaskDetail.SourceType = 'mspRLWAV12'
         AND   TaskDetail.TaskType IN ( 'FPK', 'FCP', 'FPP' )
         AND   TaskDetail.[Status] = '0'
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
      END CATCH
   END   
  
   ----Remove taskdetailkey from pickdetail of the wave   
   IF @n_Continue = 1 OR @n_Continue = 2   
   BEGIN
      BEGIN TRY
         UPDATE PICKDETAIL WITH (ROWLOCK)
         SET PICKDETAIL.TaskdetailKey = ''
           , TrafficCop = NULL
         FROM WAVEDETAIL (NOLOCK)
         JOIN PICKDETAIL ON WAVEDETAIL.OrderKey = PICKDETAIL.Orderkey
         WHERE WAVEDETAIL.WaveKey = @c_Wavekey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
      END CATCH
   END   
  
   -----Reverse wave status------   
   IF @n_Continue = 1 or @n_Continue = 2   
   BEGIN
      BEGIN TRY
         UPDATE WAVE
         SET TMReleaseFlag = 'N'
           , TrafficCop = NULL
           , EditWho = SUSER_SNAME()
           , EditDate = GETDATE()
         WHERE WaveKey = @c_Wavekey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
      END CATCH
   END   
  
   -----Reverse SOStatus---------   
   IF @n_Continue = 1 or @n_Continue = 2   
   BEGIN
      SELECT @c_authority = ISNULL(FGR.Authority, '')
      FROM dbo.fnc_GetRight2(@c_Facility, @c_StorerKey, '', 'UpdateSOReleaseTaskStatus') FGR
  
      IF @b_success = 1 AND @c_authority = '1'   
      BEGIN
         BEGIN TRY
            UPDATE O
            SET SOStatus = '0'
              , TrafficCop = NULL
              , EditWho = SUSER_SNAME()
              , EditDate = GETDATE()
            FROM ORDERS O (NOLOCK)
            JOIN WAVEDETAIL WD (NOLOCK) ON O.OrderKey = WD.OrderKey
            WHERE WD.WaveKey = @c_Wavekey 
            AND O.SOStatus = 'TSRELEASED'
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_Err = ERROR_NUMBER()
            SET @c_Errmsg = ERROR_MESSAGE()
         END CATCH
      END   
   END   
  
   RETURN_SP:   
   IF @n_Continue=3  -- Error Occured - Process And Return   
   BEGIN   
      SELECT @b_success = 0   
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_Starttcnt   
      BEGIN   
         ROLLBACK TRAN   
      END   
      ELSE   
      BEGIN   
         WHILE @@TRANCOUNT > @n_Starttcnt   
         BEGIN   
            COMMIT TRAN   
         END   
      END   
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'mspRVWAV12'   
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012   
      RETURN   
   END   
   ELSE   
   BEGIN   
      SELECT @b_success = 1   
      WHILE @@TRANCOUNT > @n_Starttcnt   
      BEGIN   
         COMMIT TRAN   
      END   
      RETURN   
   END   
END -- procedure 
GO
GRANT EXECUTE ON [dbo].[mspRVWAV12] TO [nSQL] 
GO