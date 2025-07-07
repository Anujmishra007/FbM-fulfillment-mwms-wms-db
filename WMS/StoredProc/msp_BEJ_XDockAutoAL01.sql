SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: msp_BEJ_msp_BEJ_XDockAutoAL01                      */
/* Creation Date: 07-Jul-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose: FCR-6240                                                    */
/*                                                                      */
/* Called By: Call by SQL Scheduler Job                                 */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Rev   Purposes                                  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_BEJ_msp_BEJ_XDockAutoAL01]
    @c_StorerKey   NVARCHAR(15)   = ''
   ,
    @c_Facility    NVARCHAR(5)    = ''
   ,
    @c_OtherConfig NVARCHAR(4000)  = ''

AS
BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE 
            @b_Success              INT            = 1  
            , @n_Err                INT            = '' 
            , @c_ErrMsg             NVARCHAR(255)  = '' 
            , @n_Cnt                INT            = 0
            , @n_Continue           INT            = 1
            , @n_StartTranCount     INT            = @@TRANCOUNT
            , @c_OrderKey           NVARCHAR(10)   = ''
            , @c_OrderLineNumber    NVARCHAR(10)   = ''
            , @c_SKU                NVARCHAR(30)   = ''
            , @c_UOM                NVARCHAR(10)   = ''
            , @c_WaveKey            NVARCHAR(10)   = ''
            , @c_Lot                NVARCHAR(30)   = ''
            , @n_OrderLineQty       INT            = 0
            , @c_PickDetailKey      NVARCHAR(10)   = ''

    IF OBJECT_ID('tempdb..#TMP_msp_BEJ_XDockAutoAL01_OH') IS NOT NULL DROP TABLE #TMP_msp_BEJ_XDockAutoAL01_OH
    CREATE TABLE #TMP_msp_BEJ_XDockAutoAL01_OH
    (
        RowID INT NOT NULL IDENTITY(1,1) PRIMARY KEY
        ,
        Orderkey NVARCHAR(10) NOT NULL DEFAULT('')
    )
    IF @@ERROR <> 0 
    BEGIN
        SET @n_Continue = 3
        SET @n_Err = 68071
        SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5), @n_Err) + 
                        ': CREATE TABLE #TMP_msp_BEJ_XDockAutoAL01_OH Table Failed. (msp_BEJ_msp_BEJ_XDockAutoAL01)'
        GOTO QUIT_SP
    END

    DECLARE CUR_OH CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    -- Select orders that are ready for processing
    -- Orders with status 0, storerkey and facility match, ordergroup is not empty,
    -- specialhandling is 'N', SOStatus is '0', userdefine09 is not empty,
    -- and delivery date is tomorrow
    select orders.OrderKey
    from orders
    where orders.status = 0
        and orders.storerkey = @c_StorerKey
        and orders.facility = @c_Facility
        and orders.ordergroup <> ''
        and orders.specialhandling = 'N'
        and orders.SOStatus = '0'
        and orders.userdefine09 <> ''
        and CONVERT(date, DeliveryDate) = CONVERT(date, DATEADD(d, 1, GETDATE()))

    OPEN CUR_OH

    FETCH NEXT FROM CUR_OH INTO @c_Orderkey
    WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
    BEGIN
        INSERT INTO #TMP_msp_BEJ_XDockAutoAL01_OH
            (Orderkey)
        VALUES
            (@c_Orderkey)
        IF @@ERROR <> 0 
        BEGIN
            SET @n_Continue = 3
            SET @n_Err = 68072
            SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5), @n_Err) + 
                            ': Insert into TABLE #TMP_msp_BEJ_XDockAutoAL01_OH Table Failed. (msp_BEJ_msp_BEJ_XDockAutoAL01)'
            GOTO QUIT_SP
        END
        -- Allocate each order
        EXEC nsp_orderprocessing_wrapper
            @c_OrderKey = @c_Orderkey,
            @c_oskey = '',
            @c_docarton = 'N',
            @c_doroute = 'N',
            @c_tblprefix= '',
            @c_Extendparms = '',
            @c_StrategykeyParm = ''

        IF @b_Success <> 1 
        BEGIN
            SET @n_Continue = 3
            SET @n_Err = 68073
            SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5), @n_Err) + 
                            ': Failed to execute nsp_orderprocessing_wrapper. (msp_BEJ_msp_BEJ_XDockAutoAL01)'
            GOTO QUIT_SP
        END
        --Create pickslip
        IF @n_continue IN(1,2) AND (SELECT Status FROM Orders where OrderKey = @c_Orderkey) = 2
        BEGIN
            EXEC dbo.isp_CreatePickSlip @c_Orderkey = @c_Orderkey, 
                            @c_Loadkey = N'', 
                            @c_Wavekey = N'', 
                            @c_PickslipType = N'',  
                            @c_ConsolidateByLoad = N'', 
                            @c_Refkeylookup = N'',      
                            @c_LinkPickSlipToPick = N'',
                            @c_AutoScanIn = N'',        
                            @b_Success = @b_Success OUTPUT, 
                            @n_Err = @n_Err OUTPUT,         
                            @c_ErrMsg = @c_ErrMsg OUTPUT

            IF @b_Success <> 1      
            BEGIN
                SET @n_Continue = 3
                SET @n_Err = 68074
                SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_Err,0))       
                                            + ': Get PickDetailKey Failed. (msp_BEJ_msp_BEJ_XDockAutoAL01)'
                GOTO QUIT_SP
            END
        END

    END
    CLOSE CUR_OH
    DEALLOCATE CUR_OH

    DECLARE CUR_OD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    -- Select full allocated orders(status=2) from the temporary table that are ready for processing
    SELECT OD.Orderkey, OD.OrderLineNumber, OD.SKU, OD.UOM, OD.WaveKey, OD.Lot,
        OD.OpenQty - ( OD.QtyAllocated + OD.QtyPreAllocated + OD.QtyPicked ) AS Qty
    FROM ORDERDETAIL OD (NOLOCK)
        JOIN WAVEDETAIL WD (NOLOCK) ON (OD.Orderkey = WD.Orderkey)
    WHERE OD.Orderkey IN (SELECT Orderkey
        FROM #TMP_msp_BEJ_XDockAutoAL01_OH)
        AND OD.Status = 2

    OPEN CUR_OD
    FETCH NEXT FROM CUR_OD INTO @c_Orderkey, @c_OrderLineNumber, @c_SKU, @c_UOM, @c_WaveKey, @c_Lot, @n_OrderLineQty
    WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
    BEGIN
        -- INSERT #PickDetail   
        IF @n_continue IN(1,2)
        BEGIN
            EXECUTE nspg_getkey      
                     'PickDetailKey'      
                     , 10      
                     , @c_PickDetailKey OUTPUT      
                     , @b_Success       OUTPUT      
                     , @n_Err           OUTPUT      
                     , @c_ErrMsg        OUTPUT

            IF @b_Success <> 1      
            BEGIN
                SET @n_Continue = 3
                SET @n_Err = 68075
                SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_Err,0))       
                                            + ': Get PickDetailKey Failed. (msp_BEJ_msp_BEJ_XDockAutoAL01)'
                GOTO QUIT_SP
            END
        END
        IF @n_continue IN(1,2)
        BEGIN
            INSERT INTO PICKDETAIL
                (
                PickDetailKey, PickHeaderKey, OrderKey, OrderLineNumber,
                Lot, StorerKey, Sku, UOM, Qty, Wavekey
                )
            VALUES
                (
                    @c_PickDetailKey, '', @c_OrderKey, @c_OrderLineNumber,
                    @c_Lot, @c_StorerKey, @c_SKU, @c_UOM, @n_OrderLineQty, @c_Wavekey          
            )

            IF @@ERROR <> 0    
            BEGIN
                SET @n_Continue = 3
                SET @n_Err = 68076
                SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_Err,0))     
                         + ': Insert PickDetail Failed. (msp_BEJ_msp_BEJ_XDockAutoAL01)'
                GOTO QUIT_SP
            END
        END
    END
    CLOSE CUR_OD
    DEALLOCATE CUR_OD

    -- Update order(fully allocated with status=2) status to 5
    IF @n_continue IN(1,2)
    BEGIN
        UPDATE ORDERS
            SET STATUS = 5
            WHERE ORDERKEY IN (SELECT Orderkey
            FROM #TMP_msp_BEJ_XDockAutoAL01_OH)
            AND STATUS = 2

        IF @@ERROR <> 0
            BEGIN
            SET @n_Continue = 3
            SET @n_Err = 68077
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_Err,0))     
                         + ': Update Order Status Failed. (msp_BEJ_msp_BEJ_XDockAutoAL01)'
            GOTO QUIT_SP
        END
    END


    QUIT_SP:
    IF OBJECT_ID('tempdb..#TMP_msp_BEJ_XDockAutoAL01_OH') IS NOT NULL DROP TABLE #TMP_msp_BEJ_XDockAutoAL01_OH
    IF CURSOR_STATUS('LOCAL', 'CUR_OH') in (0 , 1)    
        BEGIN
        CLOSE CUR_OH
        DEALLOCATE CUR_OH
    END
    IF CURSOR_STATUS('LOCAL', 'CUR_OD') in (0 , 1)    
        BEGIN
        CLOSE CUR_OD
        DEALLOCATE CUR_OD
    END
    IF @n_continue = 3
        BEGIN
        SET @b_Success = 0
        IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
            BEGIN
            ROLLBACK TRAN
        END
            ELSE
            BEGIN
            WHILE @@TRANCOUNT > @n_StartTranCount
                BEGIN
                COMMIT TRAN
            END
        END
        RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
    END
        ELSE
        BEGIN
        SET @b_Success = 1
        WHILE @@TRANCOUNT > @n_StartTranCount
            BEGIN
            COMMIT TRAN
        END
    END
END