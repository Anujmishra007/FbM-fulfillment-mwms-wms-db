SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/
/* Stored Procedure: mspRLWAV14_ITF                                      */
/* Creation Date: 21-Jul-2026                                            */
/* Copyright: Maersk Logistics                                           */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-14547 CANADA MGACA Wave Release                          */
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
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV14_ITF]       
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
           @n_StartTCnt             INT   = @@TRANCOUNT
         , @n_Continue              INT   = 1

         , @c_TableName             NVARCHAR(30)   = 'WSSOMAAC'
         , @c_Key3                  NVARCHAR(20)   = ''
         , @c_Orderkey              NVARCHAR(10)   = ''
         , @c_LabelNo               NVARCHAR(30)   = ''

         , @cur_TL2                 CURSOR

   SET @b_Success = 1
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''

   -- UOM=2 only (B2B userdefine10='Y' / B2C userdefine10='N')
   -- UOM=6 TransmitLog handled by RDT (Fn855) - ignore here
   -- Pack stamps LabelNo onto PickDetail.CaseID for UOM=2
   IF @n_Continue = 1
   BEGIN
      SET @cur_TL2 = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT
             pd.Storerkey
           , pd.OrderKey
           , pd.CaseID
      FROM PICKDETAIL pd (NOLOCK)
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = pd.OrderKey
      WHERE pd.WaveKey = @c_Wavekey
      AND pd.UOM = '2'
      AND pd.Caseid IS NOT NULL AND pd.CaseID <> ''
      AND o.UserDefine10 IN ('Y','N')
      ORDER BY pd.OrderKey, pd.CaseID

      OPEN @cur_TL2
      FETCH NEXT FROM @cur_TL2 INTO @c_Key3, @c_Orderkey, @c_LabelNo

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         BEGIN TRY
            EXEC ispGenTransmitLog2
                 @c_TableName      = @c_TableName
               , @c_Key1           = @c_Orderkey
               , @c_Key2           = @c_LabelNo
               , @c_Key3           = @c_Key3
               , @c_TransmitBatch  = ''
               , @b_Success        = @b_Success OUTPUT
               , @n_err            = @n_Err     OUTPUT
               , @c_errmsg         = @c_ErrMsg  OUTPUT
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_Err = ERROR_NUMBER()
            SET @c_ErrMsg = ERROR_MESSAGE()
         END CATCH

         FETCH NEXT FROM @cur_TL2 INTO @c_Key3, @c_Orderkey, @c_LabelNo
      END
      CLOSE @cur_TL2
      DEALLOCATE @cur_TL2
   END

QUIT_SP:
   IF CURSOR_STATUS('LOCAL', '@cur_TL2') IN (0, 1)
   BEGIN
      CLOSE @cur_TL2
      DEALLOCATE @cur_TL2
   END

   IF @n_Continue = 3
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV14_ITF'
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
GRANT EXECUTE ON [dbo].[mspRLWAV14_ITF] TO [NSQL]
GO
