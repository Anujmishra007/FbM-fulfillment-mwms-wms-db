SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: ispFetchStorersAndTriggerAutoHoldExpiredItem          */
/* Creation Date: 30-June-2025                                             */
/* Copyright: Maersk                                                       */
/* Purpose: FCR-4993                                                       */
/* Written by: Bruce                                                       */
/* Purpose: Fetch StorerKeys and Trigger Auto Hold ExpiredItem             */
/* Called By: DB Scheduler                                                 */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author     Ver   Purposes                                  */
/* 02-Sep-2025  MICHAEL    1.1   UWP-40390 - Change Hold Status (ML01)     */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[ispFetchStorersAndTriggerAutoHoldExpiredItem](
   @b_Success        INT          = 1   OUTPUT
,  @n_Err            INT          = 0   OUTPUT
,  @c_ErrMsg         NVARCHAR(250)= ''  OUTPUT

)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    BEGIN
        DECLARE
             @c_StorerKey    NVARCHAR(80)
            ,@n_Continue     INT
            ,@c_AlertMessage NVARCHAR(255) = ''
            ,@b_SuccessLog   INT= 1
            ,@c_Lot          NVARCHAR(10)
            ,@c_OPTION5      NVARCHAR(MAX) = ''   --ML01
            ,@c_HoldStatus   NVARCHAR(10)  = ''   --ML01

        BEGIN
            DECLARE CUR_TEMP CURSOR LOCAL FORWARD_ONLY STATIC FOR
--ML01                SELECT StorerKey FROM [dbo].[StorerConfig] WITH (NOLOCK) WHERE ConfigKey = 'AutoHoldExpiredItem' AND SValue = '1'
            --ML01-S
            SELECT DISTINCT StorerKey, OPTION5
            FROM [dbo].[StorerConfig] WITH (NOLOCK)
            WHERE ConfigKey = 'AutoHoldExpiredItem' AND SValue = '1'
            --ML01-E

            OPEN CUR_TEMP
            FETCH NEXT FROM CUR_TEMP INTO @c_StorerKey
                , @c_OPTION5   --ML01

            WHILE @@FETCH_STATUS <> -1
                BEGIN
                    --ML01-S
                    SET @c_HoldStatus = ''
                    SET @c_HoldStatus = dbo.fnc_GetParamValueFromString('@c_HoldStatus', @c_OPTION5, @c_HoldStatus)
                    IF ISNULL(@c_HoldStatus,'')=''
                        SET @c_HoldStatus = 'Auto-Block'
                    --ML01-E
                    
                    SET @c_Lot = SPACE(10)
                    WHILE(1=1)
                    BEGIN
                         SELECT TOP 1 
                                @c_Lot = LOT.Lot
                           FROM LOTxLOCxID STO WITH(NOLOCK)
                          INNER JOIN LOT WITH(NOLOCK) ON STO.Lot = LOT.Lot
                          INNER JOIN LOTATTRIBUTE ATTR WITH(NOLOCK) ON LOT.Lot = ATTR.Lot
                          INNER JOIN SKU WITH(NOLOCK) ON STO.Storerkey = SKU.Storerkey AND STO.Sku = SKU.Sku
                          WHERE LOT.StorerKey = @c_StorerKey
                            AND LOT.Status = 'OK'
--ML01                            AND STO.Qty > STO.QtyAllocated
                            AND STO.Qty > 0                        --ML01
                            AND SKU.Lottable04Label = 'EXP_DATE'   --ML01
                            AND ATTR.Lottable04 <= GETDATE()
                            AND LOT.Lot > @c_Lot
                           ORDER BY LOT.Lot

                         IF @@ROWCOUNT = 0
                         BEGIN
                           BREAK
                         END

                        EXEC nspInventoryHold
                            @c_Lot,               --lot
                            '',                   --loc
                            '',                   --id
--ML01                            'non NIF',            --status
                            @c_HoldStatus,   --ML01
                            '1',                  --hold
                            @b_Success OUTPUT,
                            @n_Err     OUTPUT,
                            @c_ErrMsg  OUTPUT,
                            'Job'
                        IF @n_Err <> 0
                        BEGIN
                           BREAK
                        END
                    END

                    IF @n_err <> 0
                            BEGIN
                                SET @n_continue = 3
                                SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
                                SET @n_err = 81182
                                SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': The AutoHoldExpiredItem processing has an error . The flow is Scheduler->ispFetchStorersAndTriggerAutoHoldExpiredItem'
                                    + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
                                GOTO ERROR_HANDLE
                            END

                    ERROR_HANDLE:

                    IF @n_continue = 3  -- Error Occured
                            BEGIN
                                --- Error Handling ----
                                SET @c_AlertMessage = 'The AutoHoldExpiredItem processing triggered by scheduler has an error.' +' - ' + @c_ErrMsg
                                BEGIN TRAN
                                    EXEC nspLogAlert
                                          @c_modulename       = 'ispFetchStorersAndTriggerAutoHoldExpiredItem'
                                        , @c_AlertMessage     = @c_AlertMessage
                                        , @n_Severity         = '5'
                                        , @b_success          = @b_SuccessLog OUTPUT
                                        , @n_err              = @n_Err        OUTPUT
                                        , @c_errmsg           = @c_ErrMsg     OUTPUT
                                        , @c_Activity         = 'Scheduled Task'
                                        , @c_Storerkey        = @c_StorerKey
                                        , @c_SKU              = ''
                                        , @c_UOM              = ''
                                        , @c_UOMQty           = ''
                                        , @c_Qty              = 0
                                        , @c_Lot              = @c_Lot
                                        , @c_Loc              = ''
                                        , @c_ID               = ''
                                        , @c_TaskDetailKey    = ''

                                    WHILE @@TRANCOUNT > 0
                                        BEGIN
                                            COMMIT TRAN
                                        END
                            END
                    FETCH NEXT FROM CUR_TEMP INTO @c_StorerKey
                        , @c_OPTION5   --ML01
                END
            CLOSE CUR_TEMP
            DEALLOCATE CUR_TEMP
        END
    END
END
GO