CREATE OR ALTER PROCEDURE [dbo].[ispAutoTransferShortDateStock]
AS
BEGIN
  SET NOCOUNT ON
  SET QUOTED_IDENTIFIER OFF
  SET ANSI_NULLS OFF
  SET CONCAT_NULL_YIELDS_NULL OFF

  DECLARE
    @c_StorerKey NVARCHAR(15),
    @c_TransferKey NVARCHAR(10),
    @b_Success INT,
    @n_Err INT,
    @c_ErrMsg NVARCHAR(255),
    @c_Facility NVARCHAR(5),
    @c_NewTransferLineNo NVARCHAR(5) = '',
    @c_Packkey NVARCHAR(10),
    @c_UOM NVARCHAR(10),
    @c_UserNameInContext NVARCHAR(128) = '',
    @n_Continue INT,
    @c_TransferKeyForFinalization NVARCHAR(10) = '',
    @c_FromSku NVARCHAR(15) = '',
    @c_FromLot NVARCHAR(10) = '',
    @c_FromLoc NVARCHAR(10) = '',
    @c_FromID NVARCHAR(18) = '',
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
    @cursorHasResults INT = 1,
    @b_SuccessLog INT = 1,
    @c_Short NVARCHAR(1);

  -- Fetch the Short value from CODELKUP table
  SELECT @c_Short = Short
  FROM CODELKUP
  WHERE LISTNAME = 'AutoTransf' AND Code = 'ShortDateProduct';

   -- Check the Short value and proceed accordingly
  IF @c_Short = 'N'
  BEGIN
    RETURN -- Exit the procedure if the condition is turned off
  END

  -- Cursor to loop through storers from storerconfig
  BEGIN
	  DECLARE CUR_STORER CURSOR FOR
	  SELECT DISTINCT(StorerKey)
	  FROM dbo.StorerConfig WITH (NOLOCK)
	  WHERE ConfigKey = 'AutoTransferShortDate' AND SValue = '1';

  OPEN CUR_STORER
  FETCH NEXT FROM CUR_STORER INTO @c_StorerKey

  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- Cursor to loop through facilities for each storer
    DECLARE CUR_FACILITY CURSOR FOR
    SELECT Facility
    FROM dbo.StorerConfig WITH (NOLOCK)
    WHERE StorerKey = @c_StorerKey AND ConfigKey = 'AutoTransferShortDate' AND SValue = '1'

    OPEN CUR_FACILITY
    FETCH NEXT FROM CUR_FACILITY INTO @c_Facility

    WHILE @@FETCH_STATUS = 0
    BEGIN
      -- Generate Transfer Key
      EXECUTE nspg_getkey 'TRANSFER', 10, @c_TransferKey OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT

      -- Retrieve Packkey and UOM from SKU table
      SELECT @c_Packkey = PACK.Packkey, @c_UOM = PACK.PackUOM3
      FROM SKU WITH (NOLOCK)
      JOIN PACK WITH (NOLOCK) ON SKU.Packkey = PACK.Packkey
      WHERE SKU.Storerkey = @c_StorerKey

      IF @b_Success = 1
      BEGIN
        DECLARE CUR_RELINV CURSOR LOCAL FORWARD_ONLY STATIC FOR
        SELECT Lot = LLI.Lot,
               Loc = LLI.Loc,
               Id = LLI.ID,
               FromSku = LLI.Sku,
               Qty_Available = (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked),
               Lottable01 = ISNULL(RTRIM(LA.Lottable01), ''),
               Lottable03 = ISNULL(RTRIM(LA.Lottable03), ''),
               Lottable04 = LA.Lottable04,
               Lottable05 = LA.Lottable05,
               Lottable06 = ISNULL(RTRIM(LA.Lottable06), ''),
               Lottable07 = ISNULL(RTRIM(LA.Lottable07), ''),
               Lottable08 = ISNULL(RTRIM(LA.Lottable08), ''),
               Lottable09 = ISNULL(RTRIM(LA.Lottable09), ''),
               Lottable10 = ISNULL(RTRIM(LA.Lottable10), ''),
               Lottable11 = ISNULL(RTRIM(LA.Lottable11), ''),
               Lottable12 = ISNULL(RTRIM(LA.Lottable12), ''),
               Lottable13 = LA.Lottable13,
               Lottable14 = LA.Lottable14,
               Lottable15 = LA.Lottable15,
               LogicalLocation = ISNULL(RTRIM(LOC.LogicalLocation), '')
        FROM LOT LOT WITH (NOLOCK)
        JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON (LOT.Lot = LA.Lot)
        JOIN LOTxLOCxID LLI WITH (NOLOCK) ON (LOT.Lot = LLI.Lot)
        JOIN LOC LOC WITH (NOLOCK) ON (LLI.Loc = LOC.LOC)
        JOIN ID ID WITH (NOLOCK) ON (LLI.ID = ID.ID)
        LEFT JOIN (SELECT LOTATTRIBUTE.Storerkey,
                          LOTATTRIBUTE.Sku,
                          LOC.LocationType,
                          LocQtyAvail = SUM(LOTxLOCxID.Qty - LOTxLOCxID.QtyAllocated - LOTxLOCxID.QtyPicked)
                   FROM LOTATTRIBUTE WITH (NOLOCK)
                   JOIN LOTxLOCxID WITH (NOLOCK) ON (LOTATTRIBUTE.Lot = LOTxLOCxID.Lot)
                   JOIN LOC WITH (NOLOCK) ON (LOTxLOCxID.Loc = LOC.Loc)
                   WHERE LOTATTRIBUTE.Storerkey = @c_StorerKey
                   AND LOTATTRIBUTE.Lottable02 = 'FG'
                   AND LOC.Facility = @c_Facility
                   GROUP BY LOTATTRIBUTE.Storerkey,
                            LOTATTRIBUTE.Sku,
                            LOC.LocationType) AS LINV
        ON (LINV.Storerkey = LOT.Storerkey)
        AND (LINV.Sku = LOT.Sku)
        AND (LINV.LocationType = LOC.LocationType)
        WHERE LOT.Storerkey = @c_StorerKey
        AND LA.Lottable02 = 'FG'
        AND LOC.Facility = @c_Facility
        AND LA.Lottable04 < GETDATE() + 180
        AND LOT.Qty - LOT.QtyAllocated - LOT.QtyPicked - LOT.QtyPreAllocated > 0
        AND LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked > 0
        AND LOT.Status = 'OK'
        AND LOC.Status = 'OK'
        AND LOC.HostWHCode = 'UR'
        AND LOC.LocationFlag NOT IN ('HOLD', 'DAMAGE')
        AND ID.Status = 'OK'
        ORDER BY (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked);

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

        IF (SELECT CURSOR_STATUS('LOCAL', 'CUR_RELINV')) = 0
          SET @cursorHasResults = 0 -- If this cursor returns no result, then transfer header is not updated.
        ELSE
        BEGIN
          -- Create Transfer Header and detail
          INSERT INTO TRANSFER (Transferkey, FromStorerkey, ToStorerkey, Type, ReasonCode, CustomerRefNo, Remarks, Facility, ToFacility)
          VALUES (@c_TransferKey, @c_StorerKey, @c_StorerKey, '344', '0999', '', 'auto transfer', @c_Facility, @c_Facility);

          WHILE @@FETCH_STATUS <> -1
          BEGIN
            -- Create Transfer Details
            SELECT @c_NewTransferLineNo = RIGHT('00000' + CONVERT(VARCHAR(5), MAX(CONVERT(INT, TransferLineNumber)) + 1), 5)
            FROM TRANSFERDETAIL WITH (NOLOCK)
            WHERE Transferkey = @c_Transferkey

            BEGIN TRY
              BEGIN
                INSERT INTO TRANSFERDETAIL (Transferkey, TransferLineNumber, FromStorerkey, FromSku, FromLot, FromLoc, FromID, FromQty, FromPackkey, FromUOM,
                                            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, ToStorerkey, ToSku, ToLot, ToLoc, ToID, ToQty, ToPackkey, ToUOM,
                                            ToLottable01, ToLottable02, ToLottable03, ToLottable04, ToLottable05)
                VALUES (@c_TransferKey, @c_NewTransferLineNo, @c_StorerKey, @c_FromSku, @c_FromLot, @c_FromLoc, @c_FromID, @n_QtyAvail, @c_Packkey, @c_UOM,
                        @c_Lottable01, 'SHDA', @c_Lottable03, @dt_Lottable04, @dt_Lottable05, @c_StorerKey, @c_FromSku, '', @c_FromLoc, @c_FromID, @n_QtyAvail, @c_Packkey, @c_UOM,
                        @c_Lottable01, 'SHDA', @c_Lottable03, @dt_Lottable04, @dt_Lottable05);
              END
            END TRY
            BEGIN CATCH
			 BEGIN
              SET @n_err = @@ERROR

              IF @n_err <> 0
              BEGIN
                SET @n_continue = 3
                SET @c_errmsg = CONVERT(NVARCHAR(250), @n_err);
                SET @n_err = 81010
                SET @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_err) + ': INSERT FOR TRANSFERDETAIL Failed. (ispAutoTransferShortDateStock)'
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
                  @c_modulename = 'ispAutoTransferShortDateStock',
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
          END
          CLOSE CUR_RELINV
          DEALLOCATE CUR_RELINV
          END
          -- Finalize Transfer if Short = 'Y'
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
         SET @n_continue = 1 --resetting error flag
      FETCH NEXT FROM CUR_FACILITY INTO @c_Facility

  CLOSE CUR_FACILITY
  DEALLOCATE CUR_FACILITY

  END

  FETCH NEXT FROM CUR_STORER INTO @c_StorerKey

  CLOSE CUR_STORER
  DEALLOCATE CUR_STORER
  END
END
QUIT_SP:

END
GO
GRANT EXECUTE ON [dbo].[ispAutoTransferShortDateStock] TO nSQL
GO
