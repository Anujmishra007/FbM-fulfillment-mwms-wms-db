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
/* 2025-07-08  AlexK01  1.1   FCR-5677 - Bug Fixes                      */
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
         , @CUR_2                   CURSOR

         , @c_OrderGroup            NVARCHAR(20)   = ''
         , @c_SQLCondAddToWave      NVARCHAR(MAX)  = ''
         , @c_LoadKey               NVARCHAR(30) = ''
         , @c_LoadKeyPrev           NVARCHAR(30) = ''
         , @b_PopupWindow           INT   = 0
         , @n_NoOfOrderNoLoad       INT   = 0
         , @n_OrderCount            INT   = 0

         , @n_BatchNo               INT   = 0

         , @c_Priority              NVARCHAR(10) 
         , @c_ExternOrderKey        NVARCHAR(50)
         , @c_Route                 NVARCHAR(10)
         , @d_OrderDate             DateTime  
         , @d_Delivery_Date         DateTime  
         , @n_TotWeight             Float  
         , @n_TotCube               Float  
         , @c_OrderType             NVARCHAR(10)    
         , @c_Door                  NVARCHAR(10)    
         , @c_DeliveryPlace         NVARCHAR(30)    
         , @c_OrderStatus           NVARCHAR(10)   
         , @c_FoundLoadkey          NVARCHAR(10)   = ''
         , @c_FoundMBOLkey          NVARCHAR(10)   = ''
         , @n_TotOrdLine            INT   
         , @c_C_Company             NVARCHAR(45)  
         , @c_ConsigneeKey          NVARCHAR(15)  

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
   , WaveBatchNo     BIGINT         NOT NULL DEFAULT (0)
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

         SET @n_BatchNo = 0
         SET @c_WaveKey = ''
         --To check if any existing WaveKey can be used to top-up
         SELECT TOP 1 
            @c_WaveKey = WD.WaveKey
         FROM WAVEDETAIL WD (NOLOCK)
         JOIN ORDERS O (NOLOCK) ON WD.OrderKey = O.OrderKey
         WHERE O.StorerKey = @c_StorerKey 
         AND O.OrderGroup = @c_OrderGroup
         GROUP BY WD.WaveKey
         HAVING COUNT(1) = COUNT(CASE WHEN O.[Status] = '0' THEN 1 END)
            AND COUNT(1) < CASE WHEN @n_MaxOrdPerBld <> 0 THEN @n_MaxOrdPerBld ELSE COUNT(1) + 1 END -- check order count with MaxOrderPerBatch if it is set.
         ORDER BY MAX(WD.AddDate) DESC
         
         --v1.1 START
         IF @c_WaveKey = ''
         BEGIN
            --Generate a new WaveKey because the condition in @c_SQLCondAddToWave is only applied when @c_WaveKey <> ''
            EXECUTE nspg_GetKey
               'WaveKey'
               , 10
               , @c_WaveKey  OUTPUT
               , @b_Success  OUTPUT
               , @n_err      OUTPUT
               , @c_ErrMsg   OUTPUT

            IF @b_Success = 0
            BEGIN
               SET @n_Continue = 3
            END

            INSERT INTO WAVE (WaveKey, BatchNo)
            VALUES (@c_WaveKey, @n_BatchNo)
         END
         --v1.1 END

         SET @c_SQLCondAddToWave = N' AND ORDERS.OrderGroup = ''' + @c_OrderGroup + ''' '

         SET @c_GenByBuildValue = 'Y'
         EXEC [WM].[lsp_Build_Wave]
           @c_BuildParmKey       = @c_BuildParmKey
         , @c_Facility           = @c_Facility
         , @c_StorerKey          = @c_StorerKey
         , @c_BuildWaveType      = 'BuildWave'
         , @c_GenByBuildValue    = @c_GenByBuildValue
         , @c_SQLBuildWave       = @c_SQLBuildWave OUTPUT
         , @n_BatchNo            = @n_BatchNo      OUTPUT
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
                  ,WaveBatchNo = @n_BatchNo     --v1.1
            FROM #TMP_ORD T
            JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.Orderkey = T.Orderkey
            WHERE T.OrderGroup = @c_OrderGroup
         END

         IF @b_Debug = 1
         BEGIN
            PRINT '>>>> Processing @c_OrderGroup (' + @c_OrderGroup + ') - END'
         END

         -- Generate LoadPlan & MBOL (Begin)
         SET @c_Wavekey = ''
         SET @CUR_2 = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT WaveKey, WaveBatchNo
         FROM #TMP_ORD 
         WHERE OrderGroup = @c_OrderGroup
         AND WaveKey <> ''
         ORDER BY WaveKey

         OPEN @CUR_2
         FETCH NEXT FROM @CUR_2 INTO @c_Wavekey, @n_BatchNo
         WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
         BEGIN
            SET @c_FoundMBOLKey = ''
            IF @b_Debug = 1
            BEGIN
               SELECT @n_OrderCount = COUNT(1)
               FROM #TMP_ORD
               WHERE WaveKey = @c_Wavekey;

               PRINT 'Wave(' + @c_WaveKey +') - Generating LoadPlan & MBOL...'
               PRINT 'NoOfOrdersInWave: ' + CONVERT(NVARCHAR(5), @n_OrderCount);
            END

            --v1.1 - Start
            --Update Wave.BatchNo
            IF @n_BatchNo > 0 
               AND EXISTS ( SELECT 1 FROM dbo.Wave WITH (NOLOCK) WHERE WaveKey = @c_Wavekey AND BatchNo = 0 )
            BEGIN
               IF @b_Debug = 1
               BEGIN
                  PRINT 'Update BatchNo (' + CONVERT(NVARCHAR(10), @n_BatchNo) + ').'
               END

               UPDATE dbo.Wave WITH (ROWLOCK)
               SET BatchNo = @n_BatchNo
               WHERE WaveKey = @c_Wavekey

               IF @@ERROR <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @c_ErrMsg  = ERROR_MESSAGE()
               END
            END
            
            --Generate LoadPlan
            IF @n_Continue = 1
            BEGIN
               SET @c_FoundLoadkey = ''
               SELECT TOP 1 @c_FoundLoadkey = ORDERS.Loadkey
               FROM ORDERS WITH (NOLOCK)
               JOIN WaveDetail WD WITH (NOLOCK) ON (ORDERS.OrderKey = WD.OrderKey)
               WHERE  ORDERS.StorerKey = @c_StorerKey
               AND WD.WaveKey = @c_WaveKey
               AND ORDERS.Status NOT IN ('9','CANC')
               AND ISNULL(ORDERS.LoadKey, '') <> ''
               ORDER BY ORDERS.LoadKey DESC

               IF @c_FoundLoadkey <> ''
               BEGIN
                  --topup order into existing LoadPlanDetail
                  SET @c_OrderKey = ''
                  WHILE @n_Continue = 1
                  BEGIN
                     SELECT TOP 1
                           @c_OrderKey = T.OrderKey
                     FROM #TMP_ORD T
                     WHERE T.WaveKey = @c_WaveKey 
                     AND T.OrderKey > @c_OrderKey
                     ORDER BY T.OrderKey

                     SET @n_Cnt = @@ROWCOUNT

                     IF @n_Cnt = 0
                     BEGIN
                        BREAK
                     END
                     
                     SELECT @d_OrderDate        = O.OrderDate    
                          , @d_Delivery_Date    = O.DeliveryDate    
                          , @c_OrderType        = O.Type    
                          , @c_Door             = O.Door    
                          , @c_Route            = O.Route    
                          , @c_DeliveryPlace    = O.DeliveryPlace    
                          , @c_OrderStatus      = O.Status    
                          , @c_Priority         = O.Priority    
                          , @n_TotWeight        = SUM(OD.OpenQty * SKU.STDGROSSWGT)    
                          , @n_TotCube          = SUM(OD.OpenQty * SKU.STDCUBE)    
                          , @n_TotOrdLine       = COUNT(DISTINCT OD.OrderLineNumber)    
                          , @c_C_Company        = O.C_Company    
                          , @c_ExternOrderKey   = O.ExternOrderKey    
                          , @c_ConsigneeKey     = O.ConsigneeKey    
                     FROM ORDERS O WITH (NOLOCK)    
                     JOIN ORDERDETAIL OD WITH (NOLOCK) ON (O.OrderKey = OD.OrderKey)    
                     JOIN SKU WITH (NOLOCK) ON (OD.StorerKey = SKU.StorerKey AND OD.Sku = SKU.Sku)    
                     WHERE O.OrderKey = @c_OrderKey    
                     GROUP BY O.OrderDate    
                            , O.DeliveryDate    
                            , O.Type    
                            , O.Door    
                            , O.Route    
                            , O.DeliveryPlace    
                            , O.Status    
                            , O.Priority    
                            , O.C_Company    
                            , O.ExternOrderKey    
                            , O.ConsigneeKey 

                     IF @@ROWCOUNT > 0
                     BEGIN
                        EXEC isp_InsertLoadplanDetail @cLoadKey      = @c_FoundLoadkey    
                                                 , @cFacility        = @c_Facility    
                                                 , @cOrderKey        = @c_OrderKey    
                                                 , @cConsigneeKey    = @c_ConsigneeKey    
                                                 , @cPrioriry        = @c_Priority    
                                                 , @dOrderDate       = @d_OrderDate    
                                                 , @dDelivery_Date   = @d_Delivery_Date    
                                                 , @cOrderType       = @c_OrderType    
                                                 , @cDoor            = @c_Door    
                                                 , @cRoute           = @c_Route    
                                                 , @cDeliveryPlace   = @c_DeliveryPlace    
                                                 , @nStdGrossWgt     = @n_TotWeight    
                                                 , @nStdCube         = @n_TotCube    
                                                 , @cExternOrderKey  = @c_ExternOrderKey    
                                                 , @cCustomerName    = @c_C_Company    
                                                 , @nTotOrderLines   = @n_TotOrdLine    
                                                 , @nNoOfCartons     = 0    
                                                 , @cOrderStatus     = @c_OrderStatus --(Wan02)              
                                                 , @b_Success        = @b_Success   OUTPUT    
                                                 , @n_Err            = @n_err       OUTPUT    
                                                 , @c_ErrMsg         = @c_errmsg    OUTPUT  
                        IF @b_Success = 0
                        BEGIN
                           SET @n_Continue = 3
                        END
                     END                     
                  END
               END
               ELSE
               BEGIN
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
               END
            END

            --Generate MBOL
            IF @n_Continue = 1
            BEGIN
               SET @c_FoundMBOLKey = ''
               SELECT TOP 1 @c_FoundMBOLKey = ORDERS.MBOLKey
               FROM ORDERS WITH (NOLOCK)
               JOIN WaveDetail WD WITH (NOLOCK) ON (ORDERS.OrderKey = WD.OrderKey)
               WHERE  ORDERS.StorerKey = @c_StorerKey
               AND WD.WaveKey = @c_WaveKey
               AND ORDERS.Status NOT IN ('9','CANC')
               AND ISNULL(ORDERS.MBOLKey, '') <> ''
               ORDER BY ORDERS.MBOLKey DESC
               
               IF @c_FoundMBOLKey <> ''
               BEGIN
                  --topup order into existing MBOLDetail
                  SET @c_OrderKey = ''
                  WHILE @n_Continue = 1
                  BEGIN
                     SELECT TOP 1
                           @c_OrderKey = T.OrderKey
                     FROM #TMP_ORD T
                     WHERE T.WaveKey = @c_WaveKey 
                     AND T.OrderKey > @c_OrderKey
                     ORDER BY T.OrderKey

                     SET @n_Cnt = @@ROWCOUNT

                     IF @n_Cnt = 0
                     BEGIN
                        BREAK
                     END

                     SELECT @d_OrderDate = O.OrderDate,  
                            @d_Delivery_Date = O.DeliveryDate,  
                            @c_Route = O.Route,  
                            @n_totweight = SUM((OD.Qtyallocated + OD.QtyPicked + OD.ShippedQty) * SKU.StdGrossWgt),  
                            @n_totcube = SUM((OD.Qtyallocated + OD.QtyPicked + OD.ShippedQty) * SKU.StdCube),  
                            @c_ExternOrderkey = O.ExternOrderkey,  
                            @c_Loadkey = ISNULL(O.Loadkey,'')  
                     FROM Orders O WITH (NOLOCK)  
                     JOIN Orderdetail OD WITH (NOLOCK) ON (O.Orderkey = OD.Orderkey)  
                     JOIN SKU WITH (NOLOCK) ON (OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku)  
                     WHERE O.OrderKey = @c_OrderKey  
                     GROUP BY O.OrderDate,  
                              O.DeliveryDate,  
                              O.Route,  
                              O.ExternOrderkey,  
                              ISNULL(O.Loadkey,'')  
                     
                     IF @@ROWCOUNT > 0 
                     BEGIN
                        EXEC isp_InsertMBOLDetail  
                              @cMBOLKey        = @c_FoundMBOLKey,  
                              @cFacility       = @c_Facility,  
                              @cOrderKey       = @c_OrderKey,  
                              @cLoadKey        = @c_Loadkey,  
                              @nStdGrossWgt    = @n_totweight,  
                              @nStdCube        = @n_totcube,  
                              @cExternOrderKey = @c_ExternOrderkey,  
                              @dOrderDate      = @d_OrderDate,  
                              @dDelivery_Date  = @d_Delivery_Date,  
                              @cRoute          = @c_Route,  
                              @b_Success       = @b_Success OUTPUT,  
                              @n_err           = @n_err     OUTPUT,  
                              @c_errmsg        = @c_errmsg  OUTPUT  

                        IF @b_Success = 0
                        BEGIN
                           SET @n_Continue = 3
                        END
                     END
                  END
               END
               ELSE
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
            END
            
            --Update MBOL.ExternMBOLKey = WaveKey
            IF @n_Continue = 1 AND ISNULL(@c_FoundMBOLKey, '') = ''
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
            -- v1.1 - End
            FETCH NEXT FROM @CUR_2 INTO @c_Wavekey, @n_BatchNo
         END
         CLOSE @CUR_2
         DEALLOCATE @CUR_2
         -- Generate LoadPlan & MBOL (END)
         FETCH NEXT FROM @CUR INTO @c_OrderGroup
      END
      CLOSE @CUR
      DEALLOCATE @CUR
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
