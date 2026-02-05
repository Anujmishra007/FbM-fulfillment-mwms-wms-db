SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: msp_BEJ_UnWaveLoadShipOrders                            */
/* Creation Date: 2025-07-31                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: AlexK                                                    */
/*                                                                      */
/* Purpose: FCR-6833 HP - HP INC - WaveLoadMbol deletion                */
/*          :                                                           */
/* Called By: Call by SQL Scheduler Job                                 */
/*          :                                                           */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2025-07-31  AlexK    1.0   FCR-6833 - initial.                       */
/* 2025-10-17  AlexK01  1.1   FCR-6833 - Change Request                 */
/* 2026-02-02  suryakanta.sahoo  1.5   FCR-10266 - Change Request       */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_BEJ_UnWaveLoadShipOrders]
     @c_StorerKey   NVARCHAR(15)   = ''
   , @c_Facility    NVARCHAR(5)    = ''
   , @c_OtherConfig NVARCHAR(4000) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt             INT            = @@TRANCOUNT
         , @n_Continue              INT            = 1
         , @b_Success               INT            = 1
         , @n_Err                   INT            = 0
         , @c_ErrMsg                NVARCHAR(255)  = ''
                                    
         , @c_SQL                   NVARCHAR(MAX)  = ''
         , @c_SQLParms              NVARCHAR(500)  = ''
         , @b_Debug                 INT            = 0
         , @c_OrderKey              NVARCHAR(10)   = ''

         , @CUR                     CURSOR

         , @c_WaveDetailKey         NVARCHAR(20)   = ''
         , @c_MbolKey               NVARCHAR(10)
         , @c_MbolLineNumber        NVARCHAR(5)
         , @c_LoadKey               NVARCHAR(10)
         , @c_LoadLineNumber        NVARCHAR(5)
         , @c_WaveKey               NVARCHAR(10)


   IF RIGHT(ISNULL(TRIM(@c_OtherConfig),''),2) = '##'
   BEGIN
      SET @b_Debug = 1
      SET @c_OtherConfig = SUBSTRING(@c_OtherConfig, 1, LEN(@c_OtherConfig)-2)
   END

   IF @b_Debug = 1
   BEGIN
      PRINT '@c_OtherConfig: ' + @c_OtherConfig
   END

   IF @n_Continue = 1
   BEGIN
      SET @CUR = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT OrderKey
      FROM dbo.ORDERS ORD (NOLOCK)
      WHERE StorerKey = @c_StorerKey
      AND [Status] = '0'
      AND OrderGroup <> ''
      --AND UserDefine09 IS NOT NULL
      --AND UserDefine09 <> ''
      AND EXISTS ( SELECT 1 FROM dbo.WAVEDETAIL WD WITH (NOLOCK)
         WHERE WD.OrderKey = ORD.OrderKey)
      --AND SpecialHandling = 'B'
	  AND SOStatus NOT IN ('0', '9')

      UNION
      SELECT ORD2.OrderKey
      FROM dbo.ORDERS ORD2 WITH (NOLOCK)
      WHERE ORD2.StorerKey = @c_StorerKey
        AND ORD2.UserDefine09 IN (
        SELECT UserDefine09
        FROM dbo.ORDERS WITH (NOLOCK)
        WHERE Status = '0'
        AND SOStatus = '0'
        AND OrderGroup <> ''
        AND StorerKey = @c_StorerKey
        GROUP BY UserDefine09
        HAVING COUNT(DISTINCT OrderGroup) <> 1
        )
    ORDER BY OrderKey

OPEN @CUR
      FETCH NEXT FROM @CUR INTO @c_OrderKey
      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         --Reset
         SET @c_WaveDetailKey    = ''
         SET @c_MbolKey          = ''
         SET @c_MbolLineNumber   = ''
         SET @c_LoadKey          = ''
         SET @c_LoadLineNumber   = ''

         BEGIN TRY
            BEGIN TRAN

            -- Delete order from MBOL detail
            SELECT @c_MbolKey          = MbolKey
                  ,@c_MbolLineNumber   = MbolLineNumber
            FROM dbo.MBOLDetail (NOLOCK)
            WHERE OrderKey = @c_OrderKey

            IF ISNULL(@c_MbolKey, '') <> '' AND ISNULL(@c_MbolLineNumber, '') <> ''
            BEGIN
               DELETE FROM dbo.MBOLDetail
               WHERE MbolKey = @c_MbolKey
               AND MbolLineNumber = @c_MbolLineNumber
               --Delete order from MOBL table containing Header details
               DELETE FROM dbo.MBOL
               WHERE MbolKey = @c_MbolKey
            END

            --Delete order from LoadPlan Detail
             SELECT @c_LoadKey         = LoadKey
                   ,@c_LoadLineNumber  = LoadLineNumber
            FROM dbo.LoadPlanDetail (NOLOCK)
            WHERE OrderKey = @c_OrderKey

            IF ISNULL(@c_LoadKey, '') <> '' AND ISNULL(@c_LoadLineNumber, '') <> ''
            BEGIN
               DELETE FROM dbo.LoadPlanDetail
               WHERE LoadKey = @c_LoadKey
               AND LoadLineNumber = @c_LoadLineNumber
            END
            --Delete order from Wave table containing Load Header details
            IF NOT EXISTS ( SELECT 1 FROM dbo.LoadPlanDetail (NOLOCK) WHERE LoadKey = @c_LoadKey )
            BEGIN
                DELETE FROM dbo.LoadPlan
                WHERE LoadKey = @c_LoadKey
            END

            -- Delete order from wave detail
            SELECT @c_WaveDetailKey = WaveDetailKey,
                   @c_WaveKey = WaveKey
            FROM dbo.WaveDetail (NOLOCK)
            WHERE OrderKey = @c_OrderKey

            IF ISNULL(@c_WaveDetailKey, '') <> ''
            BEGIN
               DELETE FROM dbo.WaveDetail
               WHERE WaveDetailKey = @c_WaveDetailKey
            END
            --Delete order from Wave table containing wave Header details
            IF NOT EXISTS ( SELECT 1 FROM dbo.WaveDetail (NOLOCK) WHERE WaveKey = @c_WaveKey )
            BEGIN
                DELETE FROM dbo.WAVE
                WHERE WaveKey = @c_WaveKey
            END
            --Remove OrderGroup from Orders.
            UPDATE dbo.Orders WITH (ROWLOCK)
            SET OrderGroup          = ''
               ,Door                = ''    --AlexK01
               ,[Route]             = ''    --AlexK01
               ,IntermodalVehicle   = ''    --AlexK01
            WHERE OrderKey = @c_OrderKey

            COMMIT TRAN
         END TRY
         BEGIN CATCH
            IF @@TRANCOUNT > 0
               ROLLBACK TRAN;

            SET @n_Continue = 3
            SET @c_ErrMsg = ERROR_MESSAGE()
            IF @b_Debug = 1
            BEGIN
               PRINT 'Error on OrderKey ' + @c_OrderKey + ': ' + @c_ErrMsg;
            END

         END CATCH

         FETCH NEXT FROM @CUR INTO @c_OrderKey
      END
      CLOSE @CUR
      DEALLOCATE @CUR
   END

QUIT_SP:
   IF @n_Continue = 3
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
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
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
