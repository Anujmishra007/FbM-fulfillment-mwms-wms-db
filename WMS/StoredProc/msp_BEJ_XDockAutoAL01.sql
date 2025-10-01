SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: msp_BEJ_XDockAutoAL01                              */
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
/* 2025-10-01	AK01	1.0   FCR-6240 bug fixes						*/
/************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_BEJ_XDockAutoAL01]
    @c_StorerKey   NVARCHAR(15)    = '',
    @c_Facility    NVARCHAR(5)     = '',
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
            , @c_PickDetailKey      NVARCHAR(10)   = ''

    DECLARE CUR_OH CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    -- Select orders that are ready for processing
    -- Orders with status 0, storerkey and facility match, ordergroup is not empty,
    -- specialhandling is 'N', SOStatus is '0', userdefine09 is not empty,
    -- and delivery date is tomorrow
    select orders.OrderKey
    from orders (nolock) 
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
        -- Allocate each order
        EXEC nsp_orderprocessing_wrapper
            @c_OrderKey = @c_Orderkey,
            @c_oskey = '',
            @c_docarton = 'N',
            @c_doroute = 'N',
            @c_tblprefix= '',
            @c_Extendparms = '',
            @c_StrategykeyParm = ''

        IF @@ERROR <> 0
        BEGIN
            SET @n_Continue = 3
            SET @n_Err = 68073
            SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5), @n_Err) + 
                            ': Failed to execute nsp_orderprocessing_wrapper. (msp_BEJ_XDockAutoAL01)'
            GOTO QUIT_SP
        END

        IF @n_continue IN(1,2) AND (SELECT Status
            FROM Orders (nolock)  
            where OrderKey = @c_Orderkey) = 2
        BEGIN
            --Create pickslip if the order is fully allocated
            EXEC dbo.isp_CreatePickSlip @c_Orderkey = @c_Orderkey, 
                            @c_Loadkey = N'', 
                            @c_Wavekey = N'', 
                            @c_PickslipType = N'',  
                            @c_ConsolidateByLoad = N'', 
                            @c_Refkeylookup = N'',      
                            @c_LinkPickSlipToPick = N'Y',
                            @c_AutoScanIn = N'',        
                            @b_Success = @b_Success OUTPUT, 
                            @n_Err = @n_Err OUTPUT,         
                            @c_ErrMsg = @c_ErrMsg OUTPUT

            IF @b_Success <> 1      
            BEGIN
                SET @n_Continue = 3
                SET @n_Err = 68074
                SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_Err,0))       
                                            + ': Get PickDetailKey Failed. (msp_BEJ_XDockAutoAL01)'
                GOTO QUIT_SP
            END
            --Update pickdetail status to 5
            IF @n_continue IN(1,2)
            BEGIN
                DECLARE CUR_PD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                SELECT pd.PickDetailKey FROM PICKDETAIL pd (nolock) WHERE pd.OrderKey=@c_Orderkey
                OPEN CUR_PD
                FETCH NEXT FROM CUR_PD INTO @c_PickDetailKey
                WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
                BEGIN
                    -- Update the status of each pickdetail to 5
                    UPDATE PICKDETAIL WITH (ROWLOCK)
                    SET Status = '5'
                    WHERE PickDetailKey = @c_PickDetailKey
                    AND OrderKey = @c_Orderkey

                    IF @@ERROR <> 0
                        BEGIN
                        SET @n_Continue = 3
                        SET @n_Err = 68075
                        SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5), @n_Err) + 
                                    ': Failed to update PICKDETAIL status. (msp_BEJ_XDockAutoAL01)'
                        GOTO QUIT_SP
                    END
					FETCH NEXT FROM CUR_PD INTO @c_PickDetailKey      --AK01
                END
                CLOSE CUR_PD
                DEALLOCATE CUR_PD
            END
        END
		
		FETCH NEXT FROM CUR_OH INTO @c_Orderkey      --AK01
    END
    CLOSE CUR_OH
    DEALLOCATE CUR_OH

    QUIT_SP:
    IF CURSOR_STATUS('LOCAL', 'CUR_OH') in (0 , 1)    
        BEGIN
        CLOSE CUR_OH
        DEALLOCATE CUR_OH
    END
    IF CURSOR_STATUS('LOCAL', 'CUR_PD') in (0 , 1)    
        BEGIN
        CLOSE CUR_PD
        DEALLOCATE CUR_PD
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