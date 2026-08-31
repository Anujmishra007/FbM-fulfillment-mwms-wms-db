SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: mspRVWAV14                                          */
/* Creation Date: 21-Jul-2026                                            */
/* Copyright: Maersk Logistics                                           */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-14547 CANADA MGACA Reverse Wave Released                 */
/*                                                                       */
/* Called By: Wave                                                       */
/*                                                                       */
/* Version: 1.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 21-Jul-2026 WLChooi  1.0   Initial Version                            */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[mspRVWAV14]
      @c_Wavekey      NVARCHAR(10)
    , @c_Orderkey     NVARCHAR(10) = ''
    , @b_Success      INT        OUTPUT
    , @n_Err          INT        OUTPUT
    , @c_Errmsg       NVARCHAR(250)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue INT
         , @n_starttcnt INT
         , @n_debug INT

   SET @n_debug = @n_Err
   SELECT @n_starttcnt = @@TRANCOUNT, @n_Continue = 1, @b_Success = 0, @n_Err = 0, @c_Errmsg = ''

   DECLARE @c_Pickslipno      NVARCHAR(10)   = ''
         , @n_CartonNo        INT            = 0

   -- Reject if wave not yet released
   IF @n_Continue = 1
   BEGIN
      IF NOT EXISTS ( SELECT 1 FROM WAVE W (NOLOCK)
                      WHERE W.Wavekey = @c_Wavekey
                      AND W.TMReleaseFlag = 'Y' )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 67010
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) 
                          + ': This Wave has not been released. (mspRVWAV14)'
      END
   END

   IF @n_debug = 0
   BEGIN
      WHILE @@TRANCOUNT > 0
         COMMIT TRAN

      IF @@TRANCOUNT = 0
         BEGIN TRAN
   END

   -- Delete PackDetail by PickSlipNo + CartonNo (PackInfo deleted by ntrPackDetailDelete)
   -- Then delete PackHeader once per emptied PickSlipNo (not after every carton)
   IF @n_Continue = 1
   BEGIN
      DECLARE CUR_PACK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT PD.PickSlipNo, PD.CartonNo
      FROM WAVEDETAIL WD WITH (NOLOCK)
      JOIN PACKHEADER PH WITH (NOLOCK) ON WD.OrderKey = PH.OrderKey
      JOIN PACKDETAIL PD WITH (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo
      WHERE WD.WaveKey = @c_Wavekey
      ORDER BY PD.PickSlipNo, PD.CartonNo

      OPEN CUR_PACK
      FETCH NEXT FROM CUR_PACK INTO @c_Pickslipno, @n_CartonNo

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         BEGIN TRY
            DELETE FROM dbo.PackDetail
            WHERE PickSlipNo = @c_Pickslipno
            AND CartonNo = @n_CartonNo
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_Err = ERROR_NUMBER()
            SET @c_Errmsg = ERROR_MESSAGE()
            GOTO QUIT_SP
         END CATCH

         FETCH NEXT FROM CUR_PACK INTO @c_Pickslipno, @n_CartonNo
      END
      CLOSE CUR_PACK
      DEALLOCATE CUR_PACK

      IF @n_Continue = 1
      BEGIN
         BEGIN TRY
            DELETE ph
            FROM dbo.PackHeader ph
            WHERE EXISTS ( SELECT 1
                           FROM WAVEDETAIL wd WITH (NOLOCK)
                           WHERE wd.OrderKey = ph.OrderKey
                           AND wd.WaveKey = @c_Wavekey )
            AND NOT EXISTS ( SELECT 1
                             FROM PACKDETAIL pd WITH (NOLOCK)
                             WHERE pd.PickSlipNo = ph.PickSlipNo )
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_Err = ERROR_NUMBER()
            SET @c_Errmsg = ERROR_MESSAGE()
         END CATCH
      END
   END

   -- Clear pack-related fields on pickdetail of the wave
   IF @n_Continue = 1
   BEGIN
      BEGIN TRY
         UPDATE PICKDETAIL WITH (ROWLOCK)
         SET PICKDETAIL.CaseID = ''
           , PICKDETAIL.Pickslipno  = ''
           , PICKDETAIL.CartonGroup = ''
           , PICKDETAIL.CartonType  = ''
           , PICKDETAIL.Notes       = ''
           , TrafficCop = NULL
           , EditWho  = SUSER_SNAME()
           , EditDate = GETDATE()
         FROM WAVEDETAIL (NOLOCK)
         JOIN PICKDETAIL ON WAVEDETAIL.Orderkey = PICKDETAIL.Orderkey
         WHERE WAVEDETAIL.Wavekey = @c_Wavekey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
         GOTO QUIT_SP
      END CATCH
   END

   -- Reverse wave status
   IF @n_Continue = 1
   BEGIN
      BEGIN TRY
         UPDATE WAVE WITH (ROWLOCK)
            SET TMReleaseFlag = 'N'
             ,  TrafficCop = NULL
             ,  EditWho  = SUSER_SNAME()
             ,  EditDate = GETDATE()
         WHERE WaveKey = @c_Wavekey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = ERROR_NUMBER()
         SET @c_Errmsg = ERROR_MESSAGE()
      END CATCH
   END

   QUIT_SP:
   IF (XACT_STATE()) = -1
   BEGIN
      IF @@TRANCOUNT > 0 
      BEGIN
         ROLLBACK TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_starttcnt
      BEGIN TRAN

   IF CURSOR_STATUS('LOCAL', 'CUR_PACK') IN (0 , 1)
   BEGIN
      CLOSE CUR_PACK
      DEALLOCATE CUR_PACK   
   END
   
   IF @n_Continue = 3
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'mspRVWAV14'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON  [dbo].[mspRVWAV14] TO [NSQL]
GO
