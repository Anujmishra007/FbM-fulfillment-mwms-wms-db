SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: msp_BEJ_AutoAllocation                             */
/* Creation Date: 30-Apr-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: FCR-3955 UWP-32704 - Auto Allocate SO                       */
/*                                                                      */
/* Called By: Call by SQL Scheduler Job                                 */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Rev   Purposes                                  */
/*2024-04-30    SSA01   1.0   Created - UWP-32704 - Auto Allocate SO    */
/*2026-02/04    TPT     1.1   Added @n_Hrs - Ops control ahead allocat  */
/************************************************************************/
CREATE OR ALTER  PROC [dbo].[msp_BEJ_AutoAllocation]
     @c_StorerKey   NVARCHAR(15)   = ''
   , @c_Facility    NVARCHAR(5)    = ''
   , @c_OtherConfig NVARCHAR(4000)  = ''
   , @b_debug       INT = 0

AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE  @n_Continue       INT
            , @b_Success     INT
            , @n_Err         INT
            , @c_ErrMsg      NVARCHAR(250)
            , @n_StartTCnt    INT -- Holds the current transaction count
            , @c_OrderKey     NVARCHAR(10)
            , @n_Qty          INT
            , @n_QtyAvailable INT
            , @c_Source       NVARCHAR(10) = ''
            , @c_APP_DB_Name         NVARCHAR(20)
            , @c_DataStream            VARCHAR(10)
            , @n_ThreadPerAcct         INT
            , @n_ThreadPerStream       INT
            , @n_MilisecondDelay       INT
            , @c_IP                    NVARCHAR(20)
            , @c_PORT                  NVARCHAR(5)
            , @c_IniFilePath           NVARCHAR(200)
            , @c_CmdType               NVARCHAR(10)
            , @c_TaskType              NVARCHAR(1)
            , @c_ExecSPSQL             NVARCHAR(4000)
            , @cMax_SKU_Per_Order      NVARCHAR(1000)
            , @dCutOffDate             DATETIME -- (SWT02)
            , @n_Priority    INT
            , @cCommand                NVARCHAR(2014)
            , @c_Priority              NVARCHAR(1)
            , @c_Status                NVARCHAR(10)
            , @c_PostAllocationSP      NVARCHAR(200)
            , @c_Type                  NVARCHAR(10)
            , @c_OrderLineNo           NVARCHAR(5)
            , @n_Hrs				   INT = 24 --(TPT001)

    SELECT @c_APP_DB_Name           = qcfg.APP_DB_Name
           , @c_DataStream          = qcfg.DataStream
           , @n_ThreadPerAcct       = qcfg.ThreadPerAcct
           , @n_ThreadPerStream     = qcfg.ThreadPerStream
           , @n_MilisecondDelay     = qcfg.MilisecondDelay
           , @c_IP                  = qcfg.IP
           , @c_PORT                = qcfg.PORT
           , @c_IniFilePath         = qcfg.IniFilePath
           , @c_CmdType             = qcfg.CmdType
           , @c_TaskType            = qcfg.TaskType
           , @n_Priority            = qcfg.Priority
      FROM  QCmd_TransmitlogConfig qcfg WITH (NOLOCK)
      WHERE TableName               = 'BACKENDALLOC'
      AND   [App_Name]              = 'WMS'
      AND   StorerKey               = 'ALL'

   SELECT @n_StartTCnt=@@TRANCOUNT , @n_Continue=1, @b_Success=1, @n_Err=0
   SELECT @c_ErrMsg=''
   SET @c_Facility = ''
   SELECT @c_Facility = dbO.fnc_GetParamValueFromString ('@c_Facility',@c_OtherConfig, @c_Facility)

   SET @c_Priority = ''
   SELECT @c_Priority = dbO.fnc_GetParamValueFromString ('@c_Priority',@c_OtherConfig, @c_Priority)

--(TPT001)
   SELECT @n_Hrs = ISNULL(CL.Short,24)
   FROM CODELKUP CL WITH (NOLOCK)
   WHERE CL.ListName = 'JCB_HRS_AL' AND CL.Storerkey=@c_StorerKey
--(TPT001)

   IF @b_debug = 1
          BEGIN
            print('@c_Priority:'+@c_Priority)
            print('@c_Facility:'+@c_Facility)
          END

   /* Emergency Order Allocation */
   IF(@c_Priority = '1')
   BEGIN
     IF @n_Continue=1 OR @n_Continue=2
     BEGIN
        DECLARE CUR_EMG_ORDERKEY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT o.OrderKey,sum(od.openqty) as qty
        FROM ORDERS o WITH (NOLOCK)
        JOIN ORDERDETAIL od ON o.OrderKey = od.OrderKey
        WHERE o.StorerKey = @c_StorerKey
        AND o.Facility = @c_Facility
        AND o.Type IN ('0','1','2','6','8')
        AND o.Status IN ('0','1')
        AND o.OrderGroup <> 'XDOCK'
        AND o.Priority = '1'
        AND (o.UserDefine09 is NULL OR o.UserDefine09 = '')
        AND (CASE WHEN ISNULL(SequenceNo,0) = 0 OR (SequenceNo = 99999999) THEN 0 ELSE SequenceNo END) <= 5
        group by o.orderkey
        HAVING sum(od.openqty) > 0


       OPEN CUR_EMG_ORDERKEY

       FETCH NEXT FROM CUR_EMG_ORDERKEY INTO @c_OrderKey,@n_Qty

       WHILE @@FETCH_STATUS <> -1
       BEGIN
          SET @cCommand = N'EXEC [dbo].[nsp_OrderProcessing_Wrapper]' +
                                     N'  @c_OrderKey = ''' + @c_OrderKey + ''' ' +
                                     N', @c_oskey = ''''' +
                                     N', @c_docarton = ''N'' ' +
                                     N', @c_doroute = ''N'' ' +
                                     N', @c_tblprefix = '''' ' +
                                     N', @c_extendparms = '''' '

          IF @b_debug = 1
          BEGIN
            print(@cCommand)
          END
          BEGIN TRY
                  EXEC dbo.isp_QCmd_SubmitTaskToQCommander
                           @cTaskType         = 'O' -- D=By Datastream, T=Transmitlog, O=Others
                         , @cStorerKey        = @c_StorerKey
                         , @cDataStream       = 'BckEndAllo'
                         , @cCmdType          = 'SQL'
                         , @cCommand          = @cCommand
                         , @cTransmitlogKey   = @c_OrderKey
                         , @nThreadPerAcct    = @n_ThreadPerAcct
                         , @nThreadPerStream  = @n_ThreadPerStream
                         , @nMilisecondDelay  = @n_MilisecondDelay
                         , @nSeq              = 1
                         , @cIP               = @c_IP
                         , @cPORT             = @c_PORT
                         , @cIniFilePath      = @c_IniFilePath
                         , @cAPPDBName        = @c_APP_DB_Name
                         , @bSuccess          = @b_Success OUTPUT
                         , @nErr              = @n_Err OUTPUT
                         , @cErrMsg           = @c_ErrMsg OUTPUT
                         , @nPriority         = @n_Priority

                   IF @n_Err <> 0 AND ISNULL(@c_ErrMsg,'') <> ''
                   BEGIN

                      SET @c_ErrMsg = 'Submit Q Task Fail: ' + ISNULL(@c_ErrMsg,'')

                      EXECUTE dbo.nsp_Logerror @n_err = 900001, @c_errmsg= @c_ErrMsg, @c_module='msp_BEJ_AutoAllocation'
                   END
                   SET @c_PostAllocationSP = ''

                   EXEC nspGetRight
                   @c_Facility  = @c_facility,  --NJOW05
                   @c_StorerKey = @c_StorerKey,
                   @c_sku    = NULL,
                   @c_ConfigKey = 'PostAllocationSP',
                   @b_Success   = @b_Success                  OUTPUT,
                   @c_authority = @c_PostAllocationSP         OUTPUT,
                   @n_err       = @n_err                      OUTPUT,
                   @c_errmsg    = @c_errmsg                   OUTPUT

                   IF @c_PostAllocationSP = 'mspPOA01'
                   BEGIN
                     UPDATE ORDERS WITH (ROWLOCK)
                      SET M_Fax2 = 'AUTO ALLOCATION'
                      ,TrafficCop = NULL
                      WHERE Orderkey = @c_Orderkey
                   END
          END TRY
          BEGIN CATCH
                      SET @c_ErrMsg = ERROR_MESSAGE()
                      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoAllocation'
          END CATCH

          FETCH NEXT FROM CUR_EMG_ORDERKEY INTO @c_OrderKey,@n_Qty
       END

       CLOSE CUR_EMG_ORDERKEY
       DEALLOCATE CUR_EMG_ORDERKEY
     END
   END
   ELSE
   BEGIN
       /* Normal orders allocation*/
       
       IF @n_Continue=1 OR @n_Continue=2
       BEGIN
          DECLARE CUR_NORMAL_ORDERKEY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
          SELECT o.OrderKey,sum(od.openqty) as qty,o.Type
          FROM ORDERS o WITH (NOLOCK)
          JOIN ORDERDETAIL od ON o.OrderKey = od.OrderKey
          WHERE o.StorerKey = @c_StorerKey
          AND o.Facility = @c_Facility
          AND o.Type IN ('0','1','2','6','8')
          AND o.Status IN ('0','1')
          AND o.OrderGroup <> 'XDOCK'
          AND o.DeliveryDate <= DATEADD(hh,CASE DATEPART(dw,DATEADD(hh,24,getdate())) WHEN 7 THEN @n_Hrs+48 WHEN 1 THEN @n_Hrs+24 ELSE @n_Hrs END,getdate()) --(TPT001)
          AND o.Priority <> '1'
          ANd od.Lottable03 is NOT NULL
          AND (o.UserDefine09 is NULL OR o.UserDefine09 = '')
          AND (CASE WHEN ISNULL(SequenceNo,0) = 0 OR (SequenceNo = 99999999) THEN 0 ELSE SequenceNo END) < 24
          AND ISNULL(o.Ecom_Platform,'') NOT LIKE '3RDParty%'
          group by o.orderkey,o.Type
          HAVING sum(od.openqty) > 0

         OPEN CUR_NORMAL_ORDERKEY

         FETCH NEXT FROM CUR_NORMAL_ORDERKEY INTO @c_OrderKey,@n_Qty,@c_Type
         WHILE @@FETCH_STATUS <> -1
         BEGIN
         IF @b_debug = 1
          BEGIN
            print(@c_Orderkey)
          END
          BEGIN TRY
            EXEC nsp_OrderProcessing_Wrapper
                  @c_Orderkey,
                  '', --@c_oskey
                  'N', -- @c_docarton,
                  'N', -- @c_doroute,
                  '' --@c_tblprefix
          END TRY
          BEGIN CATCH
              SELECT @n_continue = 3
              SELECT @c_errmsg = ERROR_MESSAGE()           --Wan01
              SET @n_err = 550156
              SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+':'+@c_Orderkey+ '(' + @c_errmsg + '): Execute nsp_orderprocessing_wrapper Failed. (msp_BEJ_AutoAllocation)'
              EXECUTE nsp_logerror @n_err, @c_errmsg, 'msp_BEJ_AutoAllocation'

              UPDATE ORDERS WITH (ROWLOCK)
                 SET Ecom_Platform = 'EMG'
                 , SequenceNo = CASE WHEN ISNULL(Orders.SequenceNo,0) = 0 OR (Orders.SequenceNo = 99999999)
                 THEN 1 ELSE Cast(Orders.SequenceNo as Int)+1 END
                 , TrafficCop = NULL
                 , Notes2 = @c_errmsg
                 WHERE Orderkey = @c_Orderkey
          END CATCH

          SELECT @n_err = @@ERROR

          IF @n_err = 0
          BEGIN

            UPDATE ORDERS WITH (ROWLOCK)
            SET Ecom_Platform = 'EMG'
            ,SequenceNo = CASE WHEN ISNULL(Orders.SequenceNo,0) = 0 OR (Orders.SequenceNo = 99999999)
            THEN 1 ELSE Cast(Orders.SequenceNo as Int)+1 END
            ,TrafficCop = NULL
            WHERE Orderkey = @c_Orderkey

            SELECT @c_Status = ISNULL(Status,'0') from ORDERS WITH (NOLOCK) where Orderkey = @c_Orderkey

             IF @c_Status = '1' AND @c_Type NOT IN ('2','6','8')
             BEGIN
                 EXEC isp_SplitNotFullAllocOrder
                    @c_OrderKey ,
                    @b_success  OUTPUT,
                    @n_err      OUTPUT,
                    @c_errmsg   OUTPUT

                 IF @n_err <> 0 AND ISNULL(@c_errmsg,'') <> ''
                       BEGIN
                          SELECT @n_continue = 3
                          SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 550158
                          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+':'+@c_OrderKey +': Execute isp_SplitNotFullAllocOrder Failed. (msp_BEJ_AutoAllocation)'
                          + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
                          EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoAllocation'
                       END
             END
          END
          FETCH NEXT FROM CUR_NORMAL_ORDERKEY INTO @c_OrderKey,@n_Qty,@c_Type
       END
         CLOSE CUR_NORMAL_ORDERKEY
         DEALLOCATE CUR_NORMAL_ORDERKEY
       END
        /* Third Party Preallocation*/

           IF OBJECT_ID('tempdb..#skuQty','u') IS NOT NULL
           BEGIN
             DROP TABLE #skuQty;
           END

           CREATE TABLE #skuQty
           (
             OrderKey       NVARCHAR(10)   NOT NULL
           , Sku            NVARCHAR(20)   NOT NULL DEFAULT('')
           , QtyAvailable   INT            NOT NULL DEFAULT(0)
           , QtyOpen        INT            NOT NULL DEFAULT(0)
           , OrderLineNo    NVARCHAR(5)    NOT NULL
           )

          INSERT INTO #skuQty
          SELECT o.OrderKey, od.sku, SUM(li.avaialbleQty), od.openQty,od.OrderLineNumber
          FROM ORDERS o WITH (NOLOCK)
          JOIN ORDERDETAIL od WITH (NOLOCK) on od.OrderKey = o.Orderkey
          JOIN ( SELECT LLI.storerkey, LLI.sku, LA.Lottable03, SUM(LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) as avaialbleQty
                   FROM LOTxLOCxID LLI (NOLOCK)
                   JOIN LOC (NOLOCK) ON (LLI.Loc = LOC.LOC)
                   JOIN ID (NOLOCK) ON (LLI.Id = ID.ID)
                   JOIN LOT (NOLOCK) ON (LLI.LOT = LOT.LOT)
                   JOIN LOTATTRIBUTE LA (NOLOCK) ON LOT.LOT = LA.LOT
                   JOIN PUTAWAYZONE PA (NOLOCK) ON LOC.Putawayzone = PA.Putawayzone
                   WHERE LOC.LocationFlag = 'NONE'
                   AND LOC.Status = 'OK'
                   AND LOT.Status = 'OK'
                   AND ID.Status = 'OK'
                   AND LOC.Facility = @c_Facility
                   AND (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) > 0
                   AND LLI.STORERKEY = @c_StorerKey
                   AND pa.ZoneCategory = 'OTHER'
                   GROUP BY LLI.Storerkey, LLI.sku,LA.Lottable03) li ON od.sku = li.sku AND od.Lottable03 = li.Lottable03 AND o.storerkey = li.storerkey
          WHERE o.StorerKey = @c_StorerKey
          AND o.Facility = @c_Facility
          AND o.Type IN ('0','1','2')
          AND o.Status = '0'
          AND o.OrderGroup <> 'XDOCK'
		  AND o.DeliveryDate <= DATEADD(hh,CASE DATEPART(dw,DATEADD(hh,24,getdate())) WHEN 7 THEN @n_Hrs+48 WHEN 1 THEN @n_Hrs+24 ELSE @n_Hrs END,getdate()) --(TPT001)
          AND o.Priority <> '1'
          ANd od.Lottable03 is NOT NULL
          AND (o.UserDefine09 is NULL OR o.UserDefine09 = '')
          AND (CASE WHEN ISNULL(SequenceNo,0) = 0 OR (SequenceNo = 99999999)
          THEN 1 ELSE SequenceNo END) BETWEEN 1 AND 24
          AND ISNULL(o.Ecom_Platform,'') NOT LIKE '3RDParty%'
          AND NOT EXISTS (
                   SELECT 1
                   FROM LOTxLOCxID LLI (NOLOCK)
                   JOIN LOC (NOLOCK) ON (LLI.Loc = LOC.LOC)
                   JOIN ID (NOLOCK) ON (LLI.Id = ID.ID)
                   JOIN LOT (NOLOCK) ON (LLI.LOT = LOT.LOT)
                   JOIN LOTATTRIBUTE LA (NOLOCK) ON LOT.LOT = LA.LOT
                   LEFT JOIN PUTAWAYZONE PA (NOLOCK) ON LOC.Putawayzone = PA.Putawayzone
                   WHERE LOC.LocationFlag = 'NONE'
                   AND LOC.Status = 'OK'
                   AND LOT.Status = 'OK'
                   AND ID.Status = 'OK'
                   AND LOC.Facility = @c_Facility
                   AND (LLI.QTY - LLI.QTYALLOCATED - LLI.QTYPICKED - LLI.QtyReplen) > 0
                   AND LLI.STORERKEY =  @c_StorerKey
                   AND LLI.Sku = od.sku
                   GROUP BY LLI.Storerkey, LLI.sku,LA.Lottable03
				           HAVING COUNT(DISTINCT PA.ZoneCategory) > 1 )
          GROUP BY o.OrderKey,od.sku,od.openQty,od.OrderLineNumber
          HAVING sum(od.openqty) > 0
          ORDER BY o.OrderKey

       DECLARE CUR_THIRD_PARTY_ORDERKEY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT DISTINCT OrderKey, OrderLineNo FROM #skuQty

       OPEN CUR_THIRD_PARTY_ORDERKEY

       FETCH NEXT FROM CUR_THIRD_PARTY_ORDERKEY INTO @c_OrderKey, @c_OrderLineNo

       WHILE @@FETCH_STATUS <> -1
       BEGIN
          IF @b_debug = 1
          BEGIN
            print(@c_Orderkey)
          END

       IF EXISTS (SELECT 1
          FROM #skuQty
          WHERE QtyAvailable < QtyOpen
          AND OrderKey = @c_Orderkey
          AND OrderLineNo = @c_OrderLineNo)
          BEGIN
              UPDATE ORDERDETAIL WITH (ROWLOCK)
              SET UserDefine03 = '3RDPartyQty'
              , TrafficCop = NULL
              WHERE Orderkey = @c_Orderkey
              AND OrderLineNumber = @c_OrderLineNo
          END
       ELSE
          BEGIN
              UPDATE ORDERDETAIL WITH (ROWLOCK)
              SET UserDefine03 = '3RDParty'
              , TrafficCop = NULL
              WHERE Orderkey = @c_Orderkey
              AND OrderLineNumber = @c_OrderLineNo
          END
          FETCH NEXT FROM CUR_THIRD_PARTY_ORDERKEY INTO @c_OrderKey, @c_OrderLineNo
       END
       CLOSE CUR_THIRD_PARTY_ORDERKEY
       DEALLOCATE CUR_THIRD_PARTY_ORDERKEY

       DECLARE CUR_THIRD_PARTY_SPLIT_ORDER CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT DISTINCT OrderKey FROM #skuQty

       OPEN CUR_THIRD_PARTY_SPLIT_ORDER

       FETCH NEXT FROM CUR_THIRD_PARTY_SPLIT_ORDER INTO @c_OrderKey

       WHILE @@FETCH_STATUS <> -1
       BEGIN
          IF @b_debug = 1
          BEGIN
            print(@c_Orderkey)
          END
          EXEC isp_SplitNonThirdPartyOrder
          @c_OrderKey ,
          @b_success  OUTPUT,
          @n_err      OUTPUT,
          @c_errmsg   OUTPUT

          IF @n_err <> 0 AND ISNULL(@c_errmsg,'') <> ''
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 550159
               SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+':'+@c_OrderKey +': Execute isp_SplitNotThirdPartOrder Failed. (msp_BEJ_AutoAllocation)'
               + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
             EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoAllocation'
            END
          FETCH NEXT FROM CUR_THIRD_PARTY_SPLIT_ORDER INTO @c_OrderKey
       END
       CLOSE CUR_THIRD_PARTY_SPLIT_ORDER
       DEALLOCATE CUR_THIRD_PARTY_SPLIT_ORDER

   END
EXIT_SP:
    
   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SELECT @b_Success = 0    
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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'msp_BEJ_AutoAllocation'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
      RETURN    
   END    
   ELSE    
   BEGIN    
      SELECT @b_Success = 1    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
      RETURN    
   END    
    
END -- Procedure  

GO
GRANT EXECUTE ON [dbo].[msp_BEJ_AutoAllocation] TO nSQL
GO
