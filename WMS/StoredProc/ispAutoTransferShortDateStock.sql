/************************************************************************/
/* Store Procedure: ispAutoTransferShortDateStock                     */
/* Creation Date: 2025-03-10                                          */
/* Copyright: Maersk                                                  */
/* Written by: Ansuman                                                */
/* Purpose: UWP-30045 Auto Transfer functionality for Short Date products      */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[ispAutoTransferShortDateStock]
    @c_listName NVARCHAR(10),
    @c_StorerKey NVARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE
        @n_StartTCnt   INT = @@TRANCOUNT,
        @c_TransferKey NVARCHAR(10),
        @b_Success INT = 1,
        @n_Err INT = 0,
        @c_ErrMsg NVARCHAR(255) = '',
        @c_Facility NVARCHAR(5),
        @c_UserNameInContext NVARCHAR(128) = '',
        @n_Continue INT = 1,
        @c_FromSku NVARCHAR(205) = '',
        @c_FromLot NVARCHAR(10) = '',
        @c_FromLoc NVARCHAR(10) = '',
        @n_GroupNum INT = 0,
        @n_PrevGroupNum INT = -1,
        @c_FromID NVARCHAR(18) = '',
        @c_Remarks NVARCHAR(200) = '',
        @c_ConditionalStatementFlag NVARCHAR(2) = '',
        @c_Lottable01 NVARCHAR(18) = '',
        @c_Lottable02 NVARCHAR(18) = '',
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
        @c_AlertMessage NVARCHAR(255) = '',
        @b_SuccessLog INT = 1,
        @c_ReasonCode NVARCHAR(10),
        @c_TransferType NVARCHAR(10),
        @c_WhereConditionValue NVARCHAR(MAX)='',
        @c_GroupByValue NVARCHAR(500)='',
        @c_Udf01 NVARCHAR(60),
        @c_LotLocId NVARCHAR(60),
        @c_AutoFinalize NVARCHAR(10),
        @c_CustomerRefNo NVARCHAR(20),
        @cursorQuery NVARCHAR(MAX),
        @c_ReturnSQL NVARCHAR(MAX),
        @c_SQL NVARCHAR(MAX),
        @c_SQLParms NVARCHAR(MAX),
        @c_TransferLineNumber NVARCHAR(5),
        @n_LotNum INT,
        @c_LottableName NVARCHAR(20),
        @c_ReturnValue NVARCHAR(30),
	@c_Short NVARCHAR(10),
	@c_LogicalLoc NVARCHAR(18)

   CREATE TABLE #TMP_CODELKUP (
       [LISTNAME] [nvarchar](10) NULL,
       [Code] [nvarchar](30) NULL,
       [Description] [nvarchar](250) NULL,
       [Short] [nvarchar](10) NULL,
       [Long] [nvarchar](250) NULL,
       [Notes] [nvarchar](4000) NULL,
       [Notes2] [nvarchar](4000) NULL,
       [Storerkey] [nvarchar](50) NULL,
       [UDF01] [nvarchar](60) NULL,
       [UDF02] [nvarchar](60) NULL,
       [UDF03] [nvarchar](60) NULL,
       [UDF04] [nvarchar](60) NULL,
       [UDF05] [nvarchar](60) NULL,
       [code2] [nvarchar](30) NULL
       )
    CREATE INDEX IDX_Code ON #TMP_CODELKUP (Code, Short)

    SET @c_UserNameInContext = SUSER_SNAME()

    WHILE @@TRANCOUNT > 0
    BEGIN
       COMMIT
    END

    DECLARE CUR_STORER CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT SHORT, UDF01, CODE2
       FROM CODELKUP WITH (NOLOCK)
       WHERE StorerKey = @c_StorerKey
       AND LISTNAME = @c_listName --listname = AUTOTRF
       AND Short = 'Y'

    OPEN CUR_STORER

    FETCH NEXT FROM CUR_STORER INTO @c_Short, @c_Udf01, @c_Facility

    WHILE @@FETCH_STATUS = 0
    BEGIN
    	 --reset variables for each storer
    	 SET @n_PrevGroupNum = -1
    	 SET @n_GroupNum = 0
    	 SET @c_WhereConditionValue = ''
    	 SET @c_GroupByValue =''
    	 SET @c_AutoFinalize = 'N'
    	 SET @c_TransferType = ''
    	 SET @c_ReasonCode = ''
    	 SET @c_CustomerRefNo = ''
    	 SET @c_Remarks = ''
    	 SET @n_continue = 1
    	 SET @b_Success = 1
    	 SET @n_err = 0
    	 SET @c_Errmsg = ''

       TRUNCATE TABLE #TMP_CODELKUP

       INSERT INTO #TMP_CODELKUP (ListName, Code, Description, Short, Long, Notes, Notes2, Storerkey,
                                  UDF01, UDF02, UDF03, UDF04, UDF05, Code2)
       SELECT ListName, Code, Description, Short, Long, Notes, Notes2, Storerkey,
              UDF01, UDF02, UDF03, UDF04, UDF05, Code2
       FROM CODELKUP (NOLOCK)
       WHERE StorerKey = @c_StorerKey
       AND LISTNAME = @c_Udf01

    	 --Get groupings, conditions and finalize flag
       SELECT @c_GroupByValue = Notes
       FROM #TMP_CODELKUP
       WHERE CODE = 'GROUPBY'
       AND SHORT = 'SQL'

       SELECT @c_WhereConditionValue = Notes
       FROM #TMP_CODELKUP
       WHERE CODE = 'CONDITIONS'
       AND SHORT = 'SQL'

       SELECT @c_AutoFinalize = Short
       FROM #TMP_CODELKUP
       WHERE CODE = 'AUTOFINALIZE'

       --Get transfer header fields
       SELECT @c_TransferType = ISNULL(Notes, '')
       FROM #TMP_CODELKUP
       WHERE CODE = 'TRANSFERTYPE'
       AND SHORT = 'VAL'

       SELECT @c_ReasonCode = Notes
       FROM #TMP_CODELKUP
       WHERE CODE = 'REASONCODE'
       AND SHORT = 'VAL'

       SELECT @c_CustomerRefNo = Notes
       FROM #TMP_CODELKUP
       WHERE CODE = 'CustomerRefNo'
       AND SHORT = 'VAL'

       SELECT @c_Remarks = Notes
       FROM #TMP_CODELKUP
       WHERE CODE = 'REMARKS'
       AND SHORT = 'VAL'

        SELECT @c_ConditionalStatementFlag = Notes
        FROM #TMP_CODELKUP
        WHERE CODE = 'LOTLOCIDSTATUSWITHLOCFLAG'
        AND SHORT = 'VAL'

       --Set default value for tansfer header if without setting.
       IF ISNULL(@c_TransferType,'') = ''
          SET @c_TransferType = 'RELOT'

       IF ISNULL(@c_ReasonCode,'') = ''
          SET @c_ReasonCode = '01'

       IF ISNULL(@c_WhereConditionValue,'') = ''
          SET @c_WhereConditionValue = ' 1=1 '

       IF ISNULL(@c_ConditionalStatementFlag,'') = ''
          SET @c_ConditionalStatementFlag = 'Y'

       SET @c_Remarks = ISNULL(CONCAT(@c_Remarks, ' ', CONVERT(NVARCHAR, GETDATE(), 120)),'')

			 SET @cursorQuery = N'DECLARE CUR_RELINV CURSOR FAST_FORWARD READ_ONLY FOR ' +
                             N'SELECT Lot = LLI.Lot, ' +
                                     'Loc = LLI.Loc, ' +
                                     'Id = LLI.ID, ' +
                                     CASE WHEN ISNULL(@c_GroupByValue,'') <> '' THEN
                                        'GroupNum = DENSE_RANK() OVER (ORDER BY ' + @c_GroupByValue + '),'  -- FOR SWISSE, EACH FROMLOTTABLE09 SHOULD BE IN A SINGLE TRANSFER)
                                     ELSE ' GroupNum = 1, '  END +
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
                                     'LogicalLocation = ISNULL(RTRIM(LOC.LogicalLocation), ''''), ' +
                                     'Facility = LOC.Facility ' +
                             'FROM LOTxLOCxID LLI WITH (NOLOCK) ' +
                             'JOIN LOT LOT WITH (NOLOCK) ON (LLI.Lot = LOT.Lot) ' +
                             'JOIN LOTATTRIBUTE LOTATTRIBUTE WITH (NOLOCK) ON (LOT.Lot = LOTATTRIBUTE.Lot) ' +
                             'JOIN LOC LOC WITH (NOLOCK) ON (LLI.Loc = LOC.LOC) ' +
                             'JOIN ID ID WITH (NOLOCK) ON (LLI.ID = ID.ID) '  +
                             'JOIN SKU SKU WITH (NOLOCK) ON (LLI.Storerkey = SKU.Storerkey AND LLI.SKU = SKU.SKU) ' +
                             'WHERE ' + @c_WhereConditionValue + ' ' +
                             'AND LLI.Storerkey ='''+ @c_StorerKey   + ''' ' +
                             CASE WHEN ISNULL(@c_Facility,'') <> '' THEN
                                'AND LOC.Facility =''' + @c_Facility + ''' '  --if facility is not set take all facilities
                             ELSE '' END +
                             'AND LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked > 0 ' +
                            CASE WHEN @c_ConditionalStatementFlag = 'Y' THEN
                            'AND LOT.Status = ''OK'' ' +
                            'AND LOC.Status = ''OK'' ' +
                            'AND LOC.LocationFlag NOT IN ( ''HOLD'', ''DAMAGE'' ) ' +
                            'AND ID.Status = ''OK'' '
                            ELSE '' END +
                             'ORDER BY GroupNum, (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked)'

       EXEC sp_ExecuteSQL @cursorQuery

       OPEN CUR_RELINV

       FETCH NEXT FROM CUR_RELINV INTO
           @c_FromLot,
           @c_FromLoc,
           @c_FromID,
           @n_GroupNum,
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
           @c_LogicalLoc,
           @c_Facility

       WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
       BEGIN
       	  IF @n_PrevGroupNum <> @n_GroupNum
       	  BEGIN
             EXECUTE nspg_getkey
                    'TRANSFER', 10,
                     @c_TransferKey OUTPUT, @b_Success OUTPUT,
                     @n_Err OUTPUT, @c_ErrMsg OUTPUT

             IF @b_Success <> 1
               SET @n_continue = 3

			 INSERT INTO TRANSFER (Transferkey, Type, FromStorerkey, ToStorerkey, ReasonCode, Facility, ToFacility, Remarks, CustomerRefNo)
			 VALUES (@c_TransferKey, @c_TransferType, @c_StorerKey, @c_StorerKey, @c_ReasonCode, @c_Facility, @c_Facility, @c_Remarks, @C_CustomerRefNo)

			 SELECT @n_err = @@ERROR

             IF  @n_err <> 0
             BEGIN
                SELECT @n_continue = 3
                SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63504
                SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Transfer Failed! (ispAutoTransferShortDateStock)' + ' ( '
                    + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
             END
          END

          SET @c_LotLocId = CONCAT(@c_FromLot, ',', @c_FromLoc, ',', @c_FromID)
          -- Create Transfer Details

          BEGIN TRY
              EXEC [WM].lsp_TRF_PopulateLLI_Wrapper
                   @c_TransferKey,
                   @c_LotLocId,
                   @b_Success OUTPUT,
                   @n_Err OUTPUT,
                   @c_ErrMsg OUTPUT,
                   @c_username = @c_UserNameInContext

               IF @b_Success <> 1
                  SET @n_continue = 3
          END TRY
          BEGIN CATCH
          	 SET @n_continue = 3
             SET @n_Err = 563005
             SET @c_ErrMsg = ERROR_MESSAGE()
             SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Populate transfer via lsp_TRF_PopulateLLI_Wrapper has failed. (ispAutoTransferShortDateStock)'
                            + '(' + @c_ErrMsg + ')'
          END CATCH

          --get the current added transfer line
          SELECT @c_TransferLineNumber = ''
          SELECT @c_TransferLineNUmber = TransferLineNumber
          FROM TRANSFERDETAIL (NOLOCK)
          WHERE Transferkey = @c_Transferkey
          AND FromStorerkey = @c_Storerkey
          AND FromSku = @c_FromSku
          AND FromLot = @c_FromLot
          AND FromLoc = @c_FromLoc
          AND FromID = @c_FromID

          SET @n_LotNum = 1
          WHILE @n_LotNum <= 15 AND @c_TransferLineNumber <> ''
          BEGIN
          	 SET @c_ReturnValue = ''
          	 SET @c_ReturnSQL = ''
          	 SET @c_LottableName = 'TOLOTTABLE' + RIGHT('00'+ LTRIM(RTRIM(CAST(@n_LotNum AS NVARCHAR))),2)

          	 --VAL configuration to get to lottable value
          	 SET @c_SQL = 'SELECT @c_Returnvalue = Notes
          	              FROM #TMP_CODELKUP (NOLOCK)
          	               WHERE Code = @c_LottableName
          	               AND Short = ''VAL'''

             EXEC sp_ExecuteSQL @c_SQL,
			 N'@c_ReturnValue NVARCHAR(30) OUTPUT,
			   @c_Udf01 NVARCHAR(60),
			   @c_StorerKey NVARCHAR(15),
			   @c_LottableName NVARCHAR(20)'
              ,@c_Returnvalue OUTPUT
			  ,@c_LottableName = @c_LottableName
			  ,@c_Udf01 = @c_Udf01
              ,@c_StorerKey = @c_StorerKey

             --SQL configuration to get to lottable value
             IF @c_ReturnValue = ''
             BEGIN
             	  --get the configured SQL
                SET @c_SQL = N'SELECT @c_ReturnSQL = Notes
          	                  FROM #TMP_CODELKUP (NOLOCK)
          	                  WHERE Code = @c_LottableName
          	                  AND Short = ''SQL'''

                EXEC sp_ExecuteSQL @c_SQL,
				N'@c_ReturnSQL NVARCHAR(MAX) OUTPUT,
				@c_Udf01 NVARCHAR(60),
				@c_StorerKey NVARCHAR(15),
				@c_LottableName NVARCHAR(20)'
               ,@c_ReturnSQL OUTPUT
			   ,@c_LottableName = @c_LottableName
               ,@c_Udf01 = @c_Udf01
               ,@c_StorerKey = @c_StorerKey

                 --run the SQL to get the value
                 IF @c_ReturnSQL <> ''
                 BEGIN
                    SET @c_ReturnSQL = REPLACE (@c_ReturnSQL, 'SELECT', 'SELECT TOP 1 @c_Returnvalue = ')

                    SET @c_SQLParms = N'@c_ReturnSQL NVARCHAR(MAX)'
									+',@c_ReturnValue NVARCHAR(30) OUTPUT'
                                    +',@c_Storerkey NVARCHAR(15)'
                                    +',@c_Sku NVARCHAR(20)'
                                    +',@c_Lot NVARCHAR(10)'
                                    +',@c_Loc NVARCHAR(10)'
                                    +',@c_ID NVARCHAR(18)'
                                    +',@c_Lottable01 NVARCHAR(18)'
                                    +',@c_Lottable02 NVARCHAR(18)'
                                    +',@c_Lottable03 NVARCHAR(18)'
                                    +',@dt_Lottable04 DATETIME'
                                    +',@dt_Lottable05 DATETIME'
                                    +',@c_Lottable06 NVARCHAR(30)'
                                    +',@c_Lottable07 NVARCHAR(30)'
                                    +',@c_Lottable08 NVARCHAR(30)'
                                    +',@c_Lottable09 NVARCHAR(30)'
                                    +',@c_Lottable10 NVARCHAR(30)'
                                    +',@c_Lottable11 NVARCHAR(30)'
                                    +',@c_Lottable12 NVARCHAR(30)'
                                    +',@dt_Lottable13 DATETIME'
                                    +',@dt_Lottable14 DATETIME'
                                    +',@dt_Lottable15 DATETIME'

                    EXEC sp_ExecuteSQL @c_ReturnSQL
                     ,@c_SQLParms
                     ,@c_ReturnValue OUTPUT
                     ,@c_Storerkey=@c_Storerkey
                     ,@c_FromSku=@c_FromSku
                     ,@c_FromLot=@c_FromLot
                     ,@c_FromLoc=@c_FromLoc
                     ,@c_FromID=@c_FromID
                     ,@c_Lottable01=@c_Lottable01
                     ,@c_Lottable02=@c_Lottable02
                     ,@c_Lottable03=@c_Lottable03
                     ,@dt_Lottable04=@dt_Lottable04
                     ,@dt_Lottable05=@dt_Lottable05
                     ,@c_Lottable06=@c_Lottable06
                     ,@c_Lottable07=@c_Lottable07
                     ,@c_Lottable08=@c_Lottable08
                     ,@c_Lottable09=@c_Lottable09
                     ,@c_Lottable10=@c_Lottable10
                     ,@c_Lottable11=@c_Lottable11
                     ,@c_Lottable12=@c_Lottable12
                     ,@dt_Lottable13=@dt_Lottable13
                     ,@dt_Lottable14=@dt_Lottable14
                     ,@dt_Lottable15=@dt_Lottable15
                 END
             END

             IF @c_ReturnValue <> ''
             BEGIN
                SET @c_SQL = N'UPDATE TRANSFERDETAIL WITH (ROWLOCK)
                              SET ' + @c_LottableName + '= @c_ReturnValue, TrafficCop = NULL ' +
                             'WHERE Transferkey = @c_Transferkey
                              AND TransferLineNumber = @c_TransferLineNUmber'

                EXEC sp_ExecuteSQL @c_SQL
                 ,N'@c_ReturnValue NVARCHAR(30), @c_Transferkey NVARCHAR(10), @c_TransferLineNumber NVARCHAR(5)'
                 ,@c_Returnvalue=@c_ReturnValue
                 ,@c_Transferkey=@c_Transferkey
                 ,@c_TransferLineNumber=@c_TransferLineNumber
             END

          	 SET @n_LotNum = @n_LotNum + 1
          END

       	  SET @n_PrevGroupNum = @n_GroupNum

          FETCH NEXT FROM CUR_RELINV INTO
              @c_FromLot,
              @c_FromLoc,
              @c_FromID,
              @n_GroupNum,
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
              @c_LogicalLoc,
              @c_Facility

          --Close the transfer
          IF @n_PrevGroupNum <> @n_GroupNum OR @@FETCH_STATUS = -1
          BEGIN
             IF @c_AutoFinalize = 'Y'
             BEGIN
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
                END
             END
          END
       END
       CLOSE CUR_RELINV
       DEALLOCATE CUR_RELINV

       IF @n_Continue = 3
       BEGIN
          SET @b_Success = 0

		  IF @@TRANCOUNT > 0 AND @@TRANCOUNT > @n_StartTCnt
             ROLLBACK TRAN

          EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispAutoTransferShortDateStock'

          SET @c_AlertMessage = 'There is an error on creating TRANSFER via Auto Transfer. Storer: ' + @c_Storerkey + ' Facility: ' + @c_Facility + 'ListName: ' + @c_UDF01 + ' (' + @c_ErrMsg + ')'

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
       END
       ELSE
       BEGIN
       	  SET @b_Success = 1
          WHILE @@TRANCOUNT > 0
          BEGIN
             COMMIT TRAN
          END
       END

       FETCH NEXT FROM CUR_STORER INTO @c_Short, @c_Udf01, @c_Facility
    END
    CLOSE CUR_STORER
    DEALLOCATE CUR_STORER

    QUIT_SP:

    WHILE @@TRANCOUNT < @n_StartTCnt
    BEGIN
    	BEGIN TRAN
    END
END
GO
GRANT EXECUTE ON [dbo].[ispAutoTransferShortDateStock] TO nSQL
GO
