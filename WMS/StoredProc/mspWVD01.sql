SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: mspWVD01                                                */
/* Creation Date: 27-Aug-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: FCR-7589 USA - Maersk WMS v2 - WMS Trigger change for Order */
/*          Status Message                                              */
/*                                                                      */
/* Called By: ntrWaveDetailAdd                                          */
/*            ntrWaveDetailUpdate                                       */
/*            ntrWaveDetailDelete                                       */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 27-Aug-2025 WLChooi  1.0   Initial Version                           */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[mspWVD01]
      @c_Action      NVARCHAR(10)
  ,   @c_Storerkey   NVARCHAR(15)
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT
         , @CUR_TL2           CURSOR
         , @c_Orderkey        NVARCHAR(10) = ''
         , @c_Wavekey         NVARCHAR(10) = ''
         , @c_TableName       NVARCHAR(10) = 'WSWVRLSLVS'

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @n_err      = 0
   SET @c_errmsg   = ''

   IF @c_Action NOT IN ('INSERT')
      GOTO QUIT_SP

   IF OBJECT_ID('tempdb..#INSERTED') IS NULL OR OBJECT_ID('tempdb..#DELETED') IS NULL
   BEGIN
      GOTO QUIT_SP
   END

   IF @c_Action IN ('INSERT')
   BEGIN
      SET @CUR_TL2 = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR        
      SELECT I.Wavekey, I.Orderkey
      FROM #INSERTED I
      JOIN ORDERS O (NOLOCK) ON I.Orderkey = O.Orderkey
      JOIN WAVE W (NOLOCK) ON I.Wavekey = W.Wavekey
      WHERE O.Storerkey = @c_Storerkey
      AND NOT EXISTS ( SELECT 1
                       FROM TransmitLog2 (NOLOCK) 
                       WHERE TableName = @c_TableName 
                       AND Key1 = I.Wavekey 
                       AND Key2 = I.Orderkey 
                       AND Key3 = @c_Storerkey )

      OPEN @CUR_TL2   

      FETCH NEXT FROM @CUR_TL2 INTO @c_Wavekey, @c_Orderkey
      
      WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
      BEGIN
          SET @b_Success = 0
          EXEC dbo.ispGenTransmitLog2 @c_TableName = @c_TableName
                                    , @c_Key1 = @c_Wavekey
                                    , @c_Key2 = @c_Orderkey
                                    , @c_Key3 = @c_Storerkey
                                    , @c_TransmitBatch = N''
                                    , @b_Success = @b_Success OUTPUT
                                    , @n_err = @n_err OUTPUT
                                    , @c_errmsg = @c_errmsg OUTPUT
         IF @b_Success <> 1
         BEGIN
            SELECT @n_Continue = 3
         END
                        
         FETCH NEXT FROM @CUR_TL2 INTO @c_Wavekey, @c_Orderkey
      END
      CLOSE @CUR_TL2
      DEALLOCATE @CUR_TL2      
   END
   
   QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspWVD01'
      --RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[mspWVD01] TO [NSQL]
GO