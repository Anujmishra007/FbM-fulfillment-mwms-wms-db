SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: msp_BEJ_BuildWave02                                     */
/* Creation Date: 2025-07-03                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: AlexK                                                    */
/*                                                                      */
/* Purpose: FCR-5677 HP INC - Auto Waving                               */
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
/* 2025-07-03  AlexK    1.0   FCR-5677 - initial.                       */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_BEJ_BuildWave02]
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
                                    
         , @n_FromPos               INT            = 0
         , @n_ToPos                 INT            = 0
         , @n_MaxOpenQty            INT            = 0
                                    
         , @n_MaxOpenQty01          INT            = 0
         , @n_MaxOpenQty02          INT            = 0
         , @n_MaxOpenQty03          INT            = 0
         , @n_MaxOpenQty04          INT            = 0
         , @n_MaxOpenQty05          INT            = 0
         , @n_MaxOrdPerBld          INT            = 0
         , @n_MaxOrdPerBld01        INT            = 0
         , @n_MaxOrdPerBld02        INT            = 0
         , @n_MaxOrdPerBld03        INT            = 0
         , @n_MaxOrdPerBld04        INT            = 0
         , @n_MaxOrdPerBld05        INT            = 0

         , @c_BuildParmKey          NVARCHAR(10)   = ''
         , @c_BuildParmLineNo       NVARCHAR(10)   = ''

         , @c_LPBuildParmKey        NVARCHAR(10)   = ''

         , @c_GenByBuildValue       NCHAR(1)       = 'N'
         , @c_SQLBuildWave          NVARCHAR(MAX)  = ''
         , @c_UserName              NVARCHAR(128)  = SUSER_SNAME()
         , @dt_Date_Fr              DATETIME       = NULL
         , @dt_Date_To              DATETIME       = NULL

         , @c_OrderKey              NVARCHAR(10)   = ''
         , @c_WaveKey               NVARCHAR(10)   = ''
         , @c_ShipperKey            NVARCHAR(15)   = ''
         , @c_ParcelType            NVARCHAR(10)   = ''
         , @c_ParcelTypes           NVARCHAR(500)  = ''
         , @c_ParcelCategory        NVARCHAR(30)   = ''
         , @d_DeliveryDate          DATETIME       = ''

         , @n_Cube_Retail           FLOAT          = 0.00
         , @n_Cube_Box5             FLOAT          = 0.00
         , @n_Cube_Ord              FLOAT          = 0.00
         , @n_OpenQty               INT            = 0

         , @c_SQL                   NVARCHAR(MAX)  = ''
         , @c_SQLParms              NVARCHAR(500)  = ''
         , @c_SQLMaxOrd             NVARCHAR(500)  = ''
         , @b_Debug                 INT            = 0

         , @CUR                     CURSOR

         , @c_OrderGroup            NVARCHAR(20)   = ''
         , @c_SQLCondAddToWave      NVARCHAR(MAX)  = ''
         , @c_LoadKey               NVARCHAR(30) = ''
         , @c_LoadKeyPrev           NVARCHAR(30) = ''
         , @b_PopupWindow           INT   = 0
         , @n_NoOfOrderNoLoad       INT   = 0
         , @n_OrderCount            INT   = 0

   IF RIGHT(ISNULL(TRIM(@c_OtherConfig),''),2) = '##'
   BEGIN
      SET @b_Debug = 1
      SET @c_OtherConfig = SUBSTRING(@c_OtherConfig, 1, LEN(@c_OtherConfig)-2)
   END

   SELECT @c_BuildParmKey = dbO.fnc_GetParamValueFromString ('@c_BuildParmKey',@c_OtherConfig, @c_BuildParmKey)
   SELECT @c_LPBuildParmKey = dbO.fnc_GetParamValueFromString ('@c_LPBuildParmKey',@c_OtherConfig, @c_LPBuildParmKey)

   IF @b_Debug = 1
   BEGIN
      PRINT '@c_BuildParmKey: ' + @c_BuildParmKey
      PRINT '@c_LPBuildParmKey: ' + @c_LPBuildParmKey
      PRINT 'Now: ' + CONVERT(NVARCHAR(25), GETDATE(),121)
      PRINT '@c_OtherConfig: ' + @c_OtherConfig
   END

   IF @c_BuildParmKey = '' OR @c_LPBuildParmKey = ''
   BEGIN
      GOTO QUIT_SP
   END

   BEGIN TRAN
   --Tables use in WM.lsp_Build_Wave
   IF OBJECT_ID('tempdb..#TMP_ORDERS','u') IS NULL
   BEGIN
      CREATE TABLE #TMP_ORDERS
      (
         OrderKey NVARCHAR(10)   NULL
      )
   END
   ELSE
   BEGIN
      TRUNCATE TABLE #TMP_ORDERS;
   END

   --Table uses in current SP
   IF OBJECT_ID('tempdb..#TMP_ORD','u') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_ORD;
   END

   CREATE TABLE #TMP_ORD
   (
     OrderKey        NVARCHAR(10)   NOT NULL DEFAULT ('')   PRIMARY KEY
   , WaveKey         NVARCHAR(10)   NOT NULL DEFAULT ('')
   , OrderGroup      NVARCHAR(20)   NOT NULL DEFAULT ('')
   )

   SELECT  @n_MaxOrdPerBld01= CASE WHEN BP.Restriction01 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue01  ELSE 0 END
         , @n_MaxOrdPerBld02= CASE WHEN BP.Restriction02 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue02  ELSE 0 END
         , @n_MaxOrdPerBld03= CASE WHEN BP.Restriction03 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue03  ELSE 0 END
         , @n_MaxOrdPerBld04= CASE WHEN BP.Restriction04 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue04  ELSE 0 END
         , @n_MaxOrdPerBld05= CASE WHEN BP.Restriction05 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue05  ELSE 0 END
         , @n_MaxOpenQty01  = CASE WHEN BP.Restriction01 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue01  ELSE 0 END
         , @n_MaxOpenQty02  = CASE WHEN BP.Restriction02 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue02  ELSE 0 END
         , @n_MaxOpenQty03  = CASE WHEN BP.Restriction03 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue03  ELSE 0 END
         , @n_MaxOpenQty04  = CASE WHEN BP.Restriction04 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue04  ELSE 0 END
         , @n_MaxOpenQty05  = CASE WHEN BP.Restriction05 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue05  ELSE 0 END
   FROM BUILDPARM BP WITH (NOLOCK)
   WHERE BP.BuildParmKey = @c_BuildParmKey

   SET @n_MaxOrdPerBld= @n_MaxOrdPerBld01

   IF @n_MaxOrdPerBld > 0
   BEGIN
      SET @c_SQLMaxOrd = N',RestrictionBuildValue01=@n_MaxOrdPerBld'
   END
   IF @n_MaxOrdPerBld = 0
  BEGIN
      SET @n_MaxOrdPerBld = @n_MaxOrdPerBld02
      SET @c_SQLMaxOrd = N',RestrictionBuildValue02=@n_MaxOrdPerBld'
   END
   IF @n_MaxOrdPerBld = 0
   BEGIN
      SET @n_MaxOrdPerBld = @n_MaxOrdPerBld03
      SET @c_SQLMaxOrd = N',RestrictionBuildValue03=@n_MaxOrdPerBld'
   END
   IF @n_MaxOrdPerBld = 0
   BEGIN
      SET @n_MaxOrdPerBld = @n_MaxOrdPerBld04
      SET @c_SQLMaxOrd = N',RestrictionBuildValue04=@n_MaxOrdPerBld'
   END
   IF @n_MaxOrdPerBld = 0
   BEGIN
      SET @n_MaxOrdPerBld = @n_MaxOrdPerBld05
      SET @c_SQLMaxOrd = N',RestrictionBuildValue05=@n_MaxOrdPerBld'
   END

   SET @n_MaxOpenQty= @n_MaxOpenQty01
   IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty02
   IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty03
   IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty04
   IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty05

   EXEC [WM].[lsp_Build_Wave]
        @c_BuildParmKey   = @c_BuildParmKey
      , @c_Facility       = @c_Facility
      , @c_StorerKey      = @c_StorerKey
      , @c_BuildWaveType  = 'ANALYSIS'
      , @c_GenByBuildValue= @c_GenByBuildValue
      , @c_SQLBuildWave   = @c_SQLBuildWave OUTPUT
      , @n_BatchNo        = 0
      , @b_Success        = @b_Success      OUTPUT
      , @n_err            = @n_err          OUTPUT
      , @c_ErrMsg         = @c_ErrMsg       OUTPUT
      , @c_UserName       = @c_UserName
      , @dt_Date_Fr       = @dt_Date_Fr
      , @dt_Date_To       = @dt_Date_To

   IF @b_Debug = 1
   BEGIN
      PRINT ''
      PRINT 'MaxOrdPerBld:   ' + CAST(@n_MaxOrdPerBld AS NVARCHAR(5)) + CHAR(13)
          + 'BuildWaveType:   ' + 'ANALYSIS'                          + CHAR(13)
          + 'BuildParmKey:    ' + ISNULL(TRIM(@c_BuildParmKey),'')    + CHAR(13)
          + 'GenByBuildValue: ' + ISNULL(TRIM(@c_GenByBuildValue),'') + CHAR(13)
          + 'SQLBuildWave:    ' + ISNULL(TRIM(@c_SQLBuildWave),'')    + CHAR(13)
          + 'Success:         ' + CAST(@b_Success AS CHAR(5))         + CHAR(13)
          + 'ErrMsg:          ' + ISNULL(TRIM(@c_ErrMsg),'')
   END

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3
   END

   IF @n_Continue = 1
   BEGIN
      SET @n_FromPos = CHARINDEX('FROM ', @c_SQLBuildWave , 1)
      SET @n_ToPos   = LEN(@c_SQLBuildWave) - @n_FromPos + 1
   
      SET @c_SQL  = N'SELECT ORDERS.OrderKey'
                  + ' ' + CHAR(13) + SUBSTRING(@c_SQLBuildWave, @n_FromPos, @n_ToPos)
   
      SET @c_SQLParms = N'@c_Facility     NVARCHAR(5)'
                      + ',@c_StorerKey    NVARCHAR(15)'
                      + ',@n_MaxOpenQty   INT'
   
      INSERT INTO #TMP_ORD (OrderKey)
      EXEC SP_EXECUTESQL
            @c_SQL
         ,  @c_SQLParms
         ,  @c_Facility
         ,  @c_StorerKey
         ,  @n_MaxOpenQty


      UPDATE #TMP_ORD
         SET OrderGroup = ORD.OrderGroup
      FROM #TMP_ORD T
      JOIN ORDERS ORD WITH (NOLOCK) ON ORD.Orderkey = T.Orderkey

      --IF @b_Debug = 1
      --BEGIN
      --   SELECT * FROM #TMP_ORD
      --END
   END

   DECLARE @n_Cnt INT = 1;

   SET @c_WaveKey = ''

   IF @n_Continue = 1
   BEGIN
      SET @CUR = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT OrderGroup
      FROM #TMP_ORD 
      GROUP BY OrderGroup

      OPEN @CUR
      FETCH NEXT FROM @CUR INTO @c_OrderGroup
      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         IF @b_Debug = 1
         BEGIN
            PRINT '>>>> Processing @c_OrderGroup (' + @c_OrderGroup + ') - START'
         END

         SET @c_WaveKey = ''
         --To check if any existing WaveKey can be used to top-up
         SELECT TOP 1 
            @c_WaveKey = WD.WaveKey
         FROM WAVEDETAIL WD (NOLOCK)
         JOIN ORDERS O (NOLOCK) ON WD.OrderKey = O.OrderKey
         WHERE O.StorerKey = @c_StorerKey 
         AND O.OrderGroup = @c_OrderGroup
         GROUP BY WD.WaveKey
         HAVING COUNT(CASE WHEN O.[Status] = '0' THEN 1 END) > 0
            AND COUNT(1) < CASE WHEN @n_MaxOrdPerBld <> 0 THEN @n_MaxOrdPerBld ELSE COUNT(1) + 1 END -- check order count with MaxOrderPerBatch if it is set.
         ORDER BY MAX(WD.AddDate) DESC
         
         SET @c_SQLCondAddToWave = N' AND ORDERS.OrderGroup = ''' + @c_OrderGroup + ''' '

         SET @c_GenByBuildValue = 'Y'
         EXEC [WM].[lsp_Build_Wave]
           @c_BuildParmKey       = @c_BuildParmKey
         , @c_Facility           = @c_Facility
         , @c_StorerKey          = @c_StorerKey
         , @c_BuildWaveType      = 'BuildWave'
         , @c_GenByBuildValue    = @c_GenByBuildValue
         , @c_SQLBuildWave       = @c_SQLBuildWave OUTPUT
         , @n_BatchNo            = 0
         , @b_Success            = @b_Success      OUTPUT
         , @n_err                = @n_err          OUTPUT
         , @c_ErrMsg             = @c_ErrMsg       OUTPUT
         , @c_UserName           = @c_UserName
         , @dt_Date_Fr           = @dt_Date_Fr
         , @dt_Date_To           = @dt_Date_To
         , @c_WaveKey            = @c_WaveKey
         , @c_SQLAddToWaveCond   = @c_SQLCondAddToWave

         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3
         END
         
         IF @n_Continue = 1
         BEGIN
            UPDATE #TMP_ORD
               SET WaveKey = WD.WaveKey
            FROM #TMP_ORD T
            JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.Orderkey = T.Orderkey
            WHERE T.OrderGroup = @c_OrderGroup
         END

         IF @b_Debug = 1
         BEGIN
            PRINT '>>>> Processing @c_OrderGroup (' + @c_OrderGroup + ') - END'
         END
         FETCH NEXT FROM @CUR INTO @c_OrderGroup
      END
      CLOSE @CUR
      DEALLOCATE @CUR

      -- Generate LoadPlan & MBOL (Begin)
      SET @c_Wavekey = ''
      SET @CUR = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT WaveKey
      FROM #TMP_ORD 
      WHERE WaveKey <> ''

      OPEN @CUR
      FETCH NEXT FROM @CUR INTO @c_Wavekey
      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         IF @b_Debug = 1
         BEGIN
            SELECT @n_OrderCount = COUNT(1)
            FROM #TMP_ORD
            WHERE WaveKey = @c_Wavekey;

            PRINT 'Wave(' + @c_WaveKey +') - Generating LoadPlan & MBOL...'
            PRINT 'NoOfOrdersInWave: ' + CONVERT(NVARCHAR(5), @n_OrderCount);
         END

         EXEC [WM].[lsp_WaveGenLoadPlan]
               @c_WaveKey           = @c_WaveKey
            ,  @b_Success           = @b_Success         OUTPUT
            ,  @n_err               = @n_err             OUTPUT
            ,  @c_ErrMsg            = @c_ErrMsg          OUTPUT
            ,  @c_UserName          = @c_UserName
            ,  @b_PopupWindow       = @b_PopupWindow     OUTPUT
            ,  @n_NoOfOrderNoLoad   = @n_NoOfOrderNoLoad OUTPUT
            ,  @c_BuildParmKeys     = @c_LPBuildParmKey
         
         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3
         END
         
         IF @b_Debug = 1
         BEGIN
            PRINT '@n_NoOfOrderNoLoad: ' + CONVERT(NVARCHAR(5), @n_NoOfOrderNoLoad) 
         END

         IF @n_Continue = 1
         BEGIN
            EXEC [WM].[lsp_WaveGenMBOL]
               @c_WaveKey  = @c_WaveKey
            ,  @b_Success  = @b_Success  OUTPUT
            ,  @n_err      = @n_err      OUTPUT
            ,  @c_ErrMsg   = @c_ErrMsg   OUTPUT
            ,  @c_UserName = @c_UserName
         
            IF @b_Success = 0
            BEGIN
               SET @n_Continue = 3
            END
         END
         
         IF @n_Continue = 1
         BEGIN
            UPDATE MBOL WITH (ROWLOCK)
            SET MBOL.ExternMbolKey = @c_WaveKey,
                MBOL.TrafficCop = NULL
            FROM MBOL
            INNER JOIN MBOLDETAIL ON MBOL.MBOLKey = MBOLDETAIL.MBOLKey
            INNER JOIN WaveDetail ON WaveDetail.OrderKey = MBOLDETAIL.OrderKey
            WHERE WaveDetail.WaveKey = @c_WaveKey
         
            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3
               SET @c_ErrMsg  = ERROR_MESSAGE()
            END
         END

         FETCH NEXT FROM @CUR INTO @c_Wavekey
      END
      CLOSE @CUR
      DEALLOCATE @CUR
      -- Generate LoadPlan & MBOL (END)
   END

QUIT_SP:
   IF @n_continue = 3
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
