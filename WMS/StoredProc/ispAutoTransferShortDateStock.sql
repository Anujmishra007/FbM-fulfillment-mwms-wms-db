CREATE OR ALTER PROCEDURE [dbo].[ispAutoTransferShortDateStock]
    @c_listName NVARCHAR(20),
    @c_StorerKey NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE
        @c_TransferKey NVARCHAR(10),
        @b_Success INT,
        @n_Err INT,
        @c_ErrMsg NVARCHAR(255),
        @c_Facility NVARCHAR(5),
        @c_UserNameInContext NVARCHAR(128) = '',
        @n_Continue INT,
        @c_TransferKeyForFinalization NVARCHAR(10) = '',
        @c_FromSku NVARCHAR(15) = '',
        @c_FromLot NVARCHAR(10) = '',
        @c_FromLoc NVARCHAR(10) = '',
        @c_FromID NVARCHAR(18) = '',
        @c_Remarks NVARCHAR(200) = '',
        @c_Tolottable09 NVARCHAR(100) = '',
        @c_Lottable01 NVARCHAR(18) = '',
        @c_Lottable03 NVARCHAR(18) = '',
        @dt_Lottable04 DATETIME,
        @dt_Lottable05 DATETIME,
        @c_Lottable06 NVARCHAR(30) = '',
        @c_Lottable07 NVARCHAR(30) = '',
        @c_Lottable08 NVARCHAR(30) = '',
        @c_Lottable09 NVARCHAR(30) = '',
        @c_Lottable10 NVARCHAR(30) = '',
        @c_Lottable11 NVARCHAR(30) = '',
        @c_Lottable12 NVARCHAR(30) = '',
        @dt_Lottable13 DATETIME,
        @dt_Lottable14 DATETIME,
        @dt_Lottable15 DATETIME,
        @n_QtyAvail INT = 0,
        @c_LogicalLoc NVARCHAR(10) = '',
        @c_AlertMessage NVARCHAR(255) = '',
        @b_SuccessLog INT = 1,
        @c_Short NVARCHAR(1),
        @c_ReasonCode NVARCHAR(20),
        @c_TransferType NVARCHAR(20),
        @c_Lottable02 NVARCHAR(20),
        @c_WhereConditionValue NVARCHAR(MAX),
        @c_GroupByValue NVARCHAR(30),
        @c_Udf01 NVARCHAR(60),
        @c_LotLocId NVARCHAR(60),
        @cursorQuery NVARCHAR(MAX);

    -- Fetch the Short value from CODELKUP table
    BEGIN
        DECLARE CUR_STORER CURSOR FOR
            SELECT SHORT, UDF01, CODE2
            FROM CODELKUP WITH (NOLOCK)
            WHERE StorerKey = @c_StorerKey AND LISTNAME = @c_listName; --listname = AUTOTRF

        OPEN CUR_STORER
        FETCH NEXT FROM CUR_STORER INTO @c_Short, @c_Udf01, @c_Facility

        WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Check the Short value and proceed accordingly
                IF @c_Short = 'N'
                    BEGIN
                        CONTINUE -- Dont perform any action
                    END

                IF(@c_Short = 'Y' OR @c_Short = 'C')
                    BEGIN
                        SET @c_UserNameInContext = SUSER_SNAME();
                        SELECT @c_GroupByValue = Notes
                        FROM dbo.CODELKUP WHERE StorerKey = @c_StorerKey AND LISTNAME = @c_Udf01
                                            AND CODE = 'GROUPBY' AND SHORT = 'SQL';
                        SELECT @c_WhereConditionValue = Notes
                        FROM dbo.CODELKUP WHERE StorerKey = @c_StorerKey AND LISTNAME = @c_Udf01
                                            AND CODE = 'CONDITIONS' AND SHORT = 'SQL';
                        SELECT @c_TransferType = Notes
                        FROM CODELKUP WHERE StorerKey = @c_StorerKey AND LISTNAME = @c_Udf01
                                        AND CODE = 'TRANSFERTYPE' AND SHORT = 'VAL';
                        BEGIN
                            SET @cursorQuery = N'DECLARE CUR_RELINV CURSOR FAST_FORWARD READ_ONLY FOR ' +
                                               N'SELECT Lot = LLI.Lot, ' +
                                               'Loc = LLI.Loc, ' +
                                               'Id = LLI.ID, ' +
                                               'FromSku = LLI.Sku, ' +
                                               'Qty_Available = (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked), '  +
                                               'Lottable01 = ISNULL(RTRIM(LOTATTRIBUTE.Lottable01), ''''), ' +
                                               'Lottable03 = ISNULL(RTRIM(LOTATTRIBUTE.Lottable03), ''''), ' +
                                               'Lottable04 = LOTATTRIBUTE.Lottable04, '    +
                                               'Lottable05 = LOTATTRIBUTE.Lottable05, '    +
                                               'Lottable06 = ISNULL(RTRIM(LOTATTRIBUTE.Lottable06), ''''), ' +
                                               'Lottable07 = ISNULL(RTRIM(LOTATTRIBUTE.Lottable07), ''''), ' +
                                               'Lottable08 = ISNULL(RTRIM(LOTATTRIBUTE.Lottable08), ''''), ' +
                                               'Lottable09 = ISNULL(RTRIM(LOTATTRIBUTE.Lottable09), ''''), ' +
                                               'Lottable10 = ISNULL(RTRIM(LOTATTRIBUTE.Lottable10), ''''), ' +
                                               'Lottable11 = ISNULL(RTRIM(LOTATTRIBUTE.Lottable11), ''''), ' +
                                               'Lottable12 = ISNULL(RTRIM(LOTATTRIBUTE.Lottable12), ''''), ' +
                                               'Lottable13 = LOTATTRIBUTE.Lottable13, ' +
                                               'Lottable14 = LOTATTRIBUTE.Lottable14, ' +
                                               'Lottable15 = LOTATTRIBUTE.Lottable15, ' +
                                               'LogicalLocation = ISNULL(RTRIM(LOC.LogicalLocation), '''') ' +
                                               'FROM LOT LOT WITH (NOLOCK) '    +
                                               'JOIN LOTATTRIBUTE LOTATTRIBUTE WITH (NOLOCK) ON (LOT.Lot = LOTATTRIBUTE.Lot) ' +
                                               'JOIN LOTxLOCxID LLI WITH (NOLOCK) ON (LOT.Lot = LLI.Lot) ' +
                                               'JOIN LOC LOC WITH (NOLOCK) ON (LLI.Loc = LOC.LOC) ' +
                                               'JOIN ID ID WITH (NOLOCK) ON (LLI.ID = ID.ID) '  +
                                               'JOIN SKU SKU WITH (NOLOCK) ON (LLI.SKU = SKU.SKU) ' +
                                               'LEFT JOIN (SELECT LOTATTRIBUTE.Storerkey, '     +
                                               'LOTATTRIBUTE.Sku, '   +
                                               'LOC.LocationType, '   +
                                               @c_GroupByValue + ',' + -- FOR SWISSE, EACH FROMLOTTABLE09 SHOULD BE IN A SINGLE TRANSFER)
                                               ' LocQtyAvail = SUM(LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked) ' +
                                               'FROM LOTATTRIBUTE WITH (NOLOCK) '    +
                                               'JOIN LOTxLOCxID WITH (NOLOCK) ON (LOTATTRIBUTE.Lot = LOTxLOCxID.Lot) '  +
                                               'JOIN LOC WITH (NOLOCK) ON (LOTxLOCxID.Loc = LOC.Loc) '   +
                                               'WHERE LOTATTRIBUTE.Storerkey ='''+ @c_StorerKey + ''' ' +
                                               'AND LOC.Facility =''' + @c_Facility+ ''' '+
                                               'GROUP BY LOTATTRIBUTE.Storerkey, '   +
                                               'LOTATTRIBUTE.Sku, '   +
                                               'LOC.LocationType, '         +
                                               @c_GroupByValue + ')' + 'AS LINV '  +
                                               'ON (LINV.Storerkey = LOT.Storerkey) ' +
                                               'AND (LINV.Sku = LOT.Sku) '  +
                                               'AND (LINV.LocationType = LOC.LocationType) ' +
                                               'WHERE ' + @c_WhereConditionValue + ' ' +
                                               'AND LOT.Storerkey ='''+ @c_StorerKey   + ''' ' +
                                               'AND LOC.Facility =''' + @c_Facility + ''' ' +
                                               'AND LOT.Qty - LOT.QtyAllocated - LOT.QtyPicked - LOT.QtyPreAllocated > 0 ' +
                                               'AND LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked > 0 ' +
                                               'AND LOT.Status = ''OK'' ' +
                                               'AND LOC.Status = ''OK'' ' +
                                               'AND LOC.LocationFlag NOT IN (''HOLD'' , ''DAMAGE'') '+
                                               'AND ID.Status = ''OK'' '+
                                               'ORDER BY (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked)'

                            EXEC sp_ExecuteSQL @cursorQuery

                            OPEN CUR_RELINV
                            FETCH NEXT FROM CUR_RELINV INTO
                                @c_FromLot,
                                @c_FromLoc,
                                @c_FromID,
                                @c_FromSku,
                                @n_QtyAvail,
                                @c_Lottable01,
                                @c_Lottable03,
                                @dt_Lottable04,
                                @dt_Lottable05,
                                @c_Lottable06,
                                @c_Lottable07,
                                @c_Lottable08,
                                @c_Lottable09,
                                @c_Lottable10,
                                @c_Lottable11,
                                @c_Lottable12,
                                @dt_Lottable13,
                                @dt_Lottable14,
                                @dt_Lottable15,
                                @c_LogicalLoc

                            IF @@FETCH_STATUS = 0
                                BEGIN
                                    -- Generate Transfer Key
                                    EXECUTE nspg_getkey
                                            'TRANSFER', 10,
                                            @c_TransferKey OUTPUT, @b_Success OUTPUT,
                                            @n_Err OUTPUT, @c_ErrMsg OUTPUT
                                    IF @b_Success = 1
                                        BEGIN
                                            SELECT @c_ReasonCode = Notes
                                            FROM CODELKUP WHERE StorerKey = @c_StorerKey AND LISTNAME = @c_Udf01
                                                            AND CODE = 'REASONCODE' AND SHORT = 'VAL';

                                            -- Create Transfer Header
                                            INSERT INTO TRANSFER (Transferkey, Type, FromStorerkey, ToStorerkey, ReasonCode, Facility, ToFacility)
                                            VALUES (@c_TransferKey, @c_TransferType, @c_StorerKey, @c_StorerKey,@c_ReasonCode,
                                                    @c_Facility, @c_Facility);

                                            SELECT @n_err = @@ERROR
                                            IF  @n_err <> 0
                                                BEGIN
                                                    SELECT @n_continue = 3
                                                    SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63504
                                                    SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Transfer Failed! (ispAutoTransferShortDateStock)' + ' ( '
                                                        + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
                                                    GOTO QUIT_SP
                                                END

                                            WHILE @@FETCH_STATUS <> -1
                                                BEGIN
                                                    SET @c_LotLocId = CONCAT(@c_FromLot, ',', @c_FromLoc, ',', @c_FromID);
                                                    -- Create Transfer Details
                                                    BEGIN TRY
                                                        EXEC [WM].lsp_TRF_PopulateLLI_Wrapper
                                                             @c_TransferKey,
                                                             @c_LotLocId,
                                                             @b_Success OUTPUT,
                                                             @n_Err OUTPUT,
                                                             @c_ErrMsg OUTPUT,
                                                             @c_username = @c_UserNameInContext

                                                    END TRY
                                                    BEGIN CATCH
                                                        BEGIN
                                                            SET @n_err = @@ERROR

                                                            IF @n_err <> 0
                                                                BEGIN
                                                                    SET @n_continue = 3
                                                                    SET @c_errmsg = CONVERT(NVARCHAR(250), @n_err);
                                                                    SET @n_err = 81010
                                                                    SET @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err) + ': Populate transfer via lsp_TRF_PopulateLLI_Wrapper has failed. (ispAutoTransferShortDateStock)'
                                                                        + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) ';
                                                                    GOTO NEXT_TRF
                                                                END
                                                        END
                                                    END CATCH

                                                    NEXT_TRF:
                                                    IF @n_continue = 3  -- Error Occurred
                                                        BEGIN
                                                            SET @b_success = 0
                                                            -- Error Handling
                                                            SET @c_AlertMessage = 'There is error on Auto Transfer ShortDate Product. TransferKey : ' + @c_TransferKey +
                                                                                  ' - ' + @c_ErrMsg
                                                            BEGIN TRAN
                                                                EXEC nspLogAlert
                                                                     @c_modulename = 'ispAutoTransferSHDA',
                                                                     @c_AlertMessage = @c_AlertMessage,
                                                                     @n_Severity = '5',
                                                                     @b_success = @b_SuccessLog OUTPUT,
                                                                     @n_err = @n_Err OUTPUT,
                                                                     @c_errmsg = @c_ErrMsg OUTPUT,
                                                                     @c_Activity = 'Batch process mode',
                                                                     @c_Storerkey = @c_StorerKey,
                                                                     @c_SKU = '',
                                                                     @c_UOM = '',
                                                                     @c_UOMQty = '',
                                                                     @c_Qty = 0,
                                                                     @c_Lot = '',
                                                                     @c_Loc = '',
                                                                     @c_ID = '',
                                                                     @c_TaskDetailKey = '';

                                                                WHILE @@TRANCOUNT > 0
                                                                    BEGIN
                                                                        COMMIT TRAN
                                                                    END
                                                        END

                                                    SET @n_continue = 1 -- resetting error flag
                                                    FETCH NEXT FROM CUR_RELINV INTO
                                                        @c_FromLot,
                                                        @c_FromLoc,
                                                        @c_FromID,
                                                        @c_FromSku,
                                                        @n_QtyAvail,
                                                        @c_Lottable01,
                                                        @c_Lottable03,
                                                        @dt_Lottable04,
                                                        @dt_Lottable05,
                                                        @c_Lottable06,
                                                        @c_Lottable07,
                                                        @c_Lottable08,
                                                        @c_Lottable09,
                                                        @c_Lottable10,
                                                        @c_Lottable11,
                                                        @c_Lottable12,
                                                        @dt_Lottable13,
                                                        @dt_Lottable14,
                                                        @dt_Lottable15,
                                                        @c_LogicalLoc
                                                END
                                            CLOSE CUR_RELINV
                                            DEALLOCATE CUR_RELINV
                                        END

                            SELECT @c_Remarks = Notes
                            FROM CODELKUP WHERE StorerKey = @c_StorerKey AND LISTNAME = @c_Udf01
                                            AND CODE = 'REMARKS' AND SHORT = 'VAL';

                            SELECT @c_Tolottable09 = Notes
                            FROM CODELKUP WHERE StorerKey = @c_StorerKey AND LISTNAME = @c_Udf01
                                            AND CODE = 'TOLOTTABLE09' AND SHORT = 'VAL';

                            SELECT @c_Lottable02 = Notes
                            FROM CODELKUP WHERE StorerKey = @c_StorerKey AND LISTNAME = @c_Udf01
                                            AND CODE = 'LOTTABLE02' AND SHORT = 'VAL';

                            BEGIN
                                UPDATE TRANSFER WITH (ROWLOCK)
                                SET TRANSFER.Remarks = CONCAT(@c_Remarks, ' ', CONVERT(NVARCHAR, GETDATE(), 120))
                                WHERE TransferKey = @c_TransferKey
                            END

                            BEGIN
                                UPDATE TRANSFERDETAIL WITH (ROWLOCK)
                                SET ToLottable09 = @c_Tolottable09 , LOTTABLE02 = @c_Lottable02
                                WHERE TransferKey = @c_TransferKey
                            END
                            -- Finalize Transfer if Short = 'Y'
                            SELECT @c_Short = Short
                            FROM CODELKUP
                            WHERE Storerkey = @c_StorerKey AND LISTNAME = @c_Udf01 AND CODE = 'AUTOFINALIZE';

                            IF @c_Short = 'Y'
                                BEGIN
                                    SET @c_UserNameInContext = SUSER_SNAME();
                                    EXEC [WM].lsp_FinalizeTransfer_Wrapper
                                         @c_TransferKey,
                                         @b_Success OUTPUT,
                                         @n_Err OUTPUT,
                                         @c_ErrMsg OUTPUT,
                                         @c_username = @c_UserNameInContext

                                    IF @n_err <> 0
                                        BEGIN
                                            SET @n_continue = 3
                                            SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
                                            SET @n_err = 81180
                                            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Finalize TRANSFER Failed. (ispAutoTransferShortDateStock->lsp_FinalizeTransfer_Wrapper)'
                                                + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
                                            GOTO ERROR_HANDLE
                                        END
                                    ERROR_HANDLE:

                                    IF @n_continue = 3  -- Error Occured
                                        BEGIN
                                            --- Error Handling ----
                                            SET @c_AlertMessage = 'There is an error on Finalize TRANSFER via Auto Transfer ShortDate Product. TransferKey : ' + @c_TransferKeyForFinalization +
                                                                  ' - ' + @c_ErrMsg
                                            BEGIN TRAN
                                                EXEC nspLogAlert
                                                     @c_modulename       = 'ispAutoTransferShortDateStock'
                                                    , @c_AlertMessage     = @c_AlertMessage
                                                    , @n_Severity         = '5'
                                                    , @b_success          = @b_SuccessLog OUTPUT
                                                    , @n_err              = @n_Err        OUTPUT
                                                    , @c_errmsg           = @c_ErrMsg     OUTPUT
                                                    , @c_Activity         = 'Batch process mode'
                                                    , @c_Storerkey        = @c_StorerKey
                                                    , @c_SKU              = ''
                                                    , @c_UOM              = ''
                                                    , @c_UOMQty           = ''
                                                    , @c_Qty              = 0
                                                    , @c_Lot              = ''
                                                    , @c_Loc              = ''
                                                    , @c_ID               = ''
                                                    , @c_TaskDetailKey    = ''

                                                WHILE @@TRANCOUNT > 0
                                                    BEGIN
                                                        COMMIT TRAN
                                                    END
                                        END
                                END
                        END
                    END
            END
        SET @n_continue = 1 --resetting error flag
        FETCH NEXT FROM CUR_STORER INTO @c_Short, @c_Udf01, @c_Facility
    END
    CLOSE CUR_STORER
    DEALLOCATE CUR_STORER
END
END
QUIT_SP:
