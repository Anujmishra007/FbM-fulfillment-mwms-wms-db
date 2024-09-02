SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store Procedure: lsp_SOCancelOrderDetails                           */
/* Creation Date: 2024-08-22                                            */
/* Copyright: LFL                                                       */
/* Written by: PPA371                                                   */
/*                                                                      */
/* Purpose: UWP-20104 - To cancel multiple order details                */
/*                                                                      */
/* Called By: SCE                                                       */
/*          :                                                           */
/* PVCS Version: 0.1                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver.  Purposes                                  */
/************************************************************************/
CREATE OR ALTER PROC [WM].[lsp_SOCancelOrderDetails]
      @c_Orderkey             NVARCHAR(10)
   ,  @c_OrderLineNumber      nvarchar(5)
   ,  @b_Success              INT = 1           OUTPUT
   ,  @n_err                  INT = 0           OUTPUT
   ,  @c_ErrMsg               NVARCHAR(255)= '' OUTPUT
   ,  @n_WarningNo            INT          = 0  OUTPUT
   ,  @c_ProceedWithWarning   CHAR(1)      = 'N'
   ,  @c_UserName             NVARCHAR(128) = ''
   ,  @n_ErrGroupKey          INT          = 0  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @n_StartTCnt      INT = @@TRANCOUNT
         ,  @n_Continue       INT = 1
         ,  @c_TableName      NVARCHAR(50)   = 'OrderDetail'
         ,  @c_SourceType     NVARCHAR(50)   = 'lsp_SOCancelOrderDetails'
         ,  @c_Refkey1        NVARCHAR(20)   = ''
         ,  @c_Refkey2        NVARCHAR(20)   = ''
         ,  @c_Refkey3        NVARCHAR(20)   = ''
         ,  @c_WriteType      NVARCHAR(50)   = ''
         ,  @n_LogWarningNo   INT            = 0
         ,  @CUR_ERRLIST      CURSOR
         ,  @c_CancelReasonEnabled NVARCHAR(3)
         ,  @c_StorerKey      NVARCHAR(10)
         ,  @c_CancelReasonCode NVARCHAR(60)
         ,  @c_status NVARCHAR(10)
         ,  @n_RowsUpdated int

   DECLARE  @t_WMSErrorList   TABLE
         (  RowID             INT            IDENTITY(1,1)
         ,  TableName         NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  SourceType        NVARCHAR(50)   NOT NULL DEFAULT('')
         ,  Refkey1           NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  Refkey2           NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  Refkey3           NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  WriteType         NVARCHAR(50)   NOT NULL DEFAULT('')
         ,  LogWarningNo      INT            NOT NULL DEFAULT(0)
         ,  ErrCode           INT            NOT NULL DEFAULT(0)
         ,  Errmsg            NVARCHAR(255)  NOT NULL DEFAULT('')
         )

   SET @b_Success = 1
   SET @n_Err     = 0

   IF SUSER_SNAME() <> @c_UserName
   BEGIN
      EXEC [WM].[lsp_SetUser]
            @c_UserName = @c_UserName  OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT

      IF @n_Err <> 0
      BEGIN
         GOTO EXIT_SP
      END

      EXECUTE AS LOGIN = @c_UserName
   END

   SET @n_WarningNo = 0
   SET @n_ErrGroupKey = 0
   BEGIN TRAN
   BEGIN TRY
   IF(@c_OrderLineNumber <> '')
      BEGIN
         SELECT @c_StorerKey=StorerKey FROM ORDERS WITH (NOLOCK) WHERE OrderKey=@c_Orderkey
         SELECT @c_CancelReasonEnabled=ReasonCodeReqForSOCancel FROM StorerSODefault WITH (NOLOCK)  WHERE StorerKey = @c_storerKey

         select @c_CancelReasonCode=cancelreasoncode ,@c_status= Status
                  from ORDERDETAIL
                  where  OrderKey=@c_Orderkey AND OrderLineNumber= @c_OrderLineNumber

                  IF(ISNULL(@c_CancelReasonCode,'')='')
                     BEGIN
                           SET @n_continue = 3
                           SET @n_err = 556110
                           SET @c_ErrMsg='Please select the cancel reason code for order line number: '

                           INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)
                           VALUES (@c_TableName, @c_SourceType, @c_Orderkey,@c_OrderLineNumber, '', 'ERROR', 0, @n_err, @c_errmsg)
                           GOTO EXIT_SP
                     END

                  IF (@c_status<>'0' AND @c_status<>'CANC')
                     BEGIN
                           SET @n_continue = 3
                           SET @n_err = 556111
                           SET @c_ErrMsg='Order details are not in normal status for line number: '

                           INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)
                           VALUES (@c_TableName, @c_SourceType, @c_Orderkey,@c_OrderLineNumber, '', 'ERROR', 0, @n_err, @c_errmsg)
                           GOTO EXIT_SP
                     END
                  IF (@c_status='CANC')
                     BEGIN
                           SET @n_continue = 3
                           SET @n_err = 556112
                           SET @c_ErrMsg='Order details had been cancelled for line number: '

                           INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)
                           VALUES (@c_TableName, @c_SourceType, @c_Orderkey,@c_OrderLineNumber, '', 'ERROR', 0, @n_err, @c_errmsg)
                           GOTO EXIT_SP
                     END

            IF (@n_Continue=1)
               BEGIN
                  UPDATE ORDERDETAIL WITH (ROWLOCK)
                  SET OpenQty=0, TrafficCop=NULL, Status='CANC'
                  WHERE OrderKey=@c_Orderkey AND OrderLineNumber =@c_OrderLineNumber;

                  set @n_RowsUpdated= @@ROWCOUNT

                  INSERT INTO [dbo].[ORDERDETAIL_CANCLOG]
                        ([OrderKey],[OrderLineNumber],[OrderDetailSysId],[ExternOrderKey],[ExternLineNo]
                        ,[Sku],[StorerKey],[ManufacturerSku],[RetailSku],[AltSku]
                        ,[OriginalQty],[OpenQty],[ShippedQty],[AdjustedQty]
                        ,[QtyPreAllocated],[QtyAllocated],[QtyPicked],[UOM],[PackKey],[PickCode]
                        ,[CartonGroup],[Lot],[ID],[Facility],[Status],[UnitPrice],[Tax01],[Tax02],[ExtendedPrice]
                        ,[UpdateSource],[Lottable01],[Lottable02],[Lottable03],[Lottable04],[Lottable05],[EffectiveDate]
                        ,[AddDate],[AddWho],[EditDate],[EditWho],[TrafficCop],[ArchiveCop],[TariffKey],[FreeGoodQty]
                        ,[GrossWeight],[Capacity],[LoadKey],[MBOLKey],[QtyToProcess],[MinShelfLife],[UserDefine01]
                        ,[UserDefine02],[UserDefine03],[UserDefine04],[UserDefine05],[UserDefine06],[UserDefine07]
                        ,[UserDefine08],[UserDefine09],[POkey],[ExternPOKey],[UserDefine10],[EnteredQTY],[ConsoOrderKey]
                        ,[ExternConsoOrderKey],[ConsoOrderLineNo],[Lottable06],[Lottable07],[Lottable08]
                        ,[Lottable09],[Lottable10],[Lottable11],[Lottable12],[Lottable13],[Lottable14]
                        ,[Lottable15],[Notes],[Notes2],[Channel],[HashValue],[SalesChannel],[CancelReasonCode])
                     select [OrderKey],[OrderLineNumber],[OrderDetailSysId],[ExternOrderKey],[ExternLineNo]
                        ,[Sku],[StorerKey],[ManufacturerSku],[RetailSku],[AltSku]
                        ,[OriginalQty],[OpenQty],[ShippedQty],[AdjustedQty]
                        ,[QtyPreAllocated],[QtyAllocated],[QtyPicked],[UOM],[PackKey],[PickCode]
                        ,[CartonGroup],[Lot],[ID],[Facility],[Status],[UnitPrice],[Tax01],[Tax02],[ExtendedPrice]
                        ,[UpdateSource],[Lottable01],[Lottable02],[Lottable03],[Lottable04],[Lottable05],[EffectiveDate]
                        ,[AddDate],[AddWho],[EditDate],[EditWho],[TrafficCop],[ArchiveCop],[TariffKey],[FreeGoodQty]
                        ,[GrossWeight],[Capacity],[LoadKey],[MBOLKey],[QtyToProcess],[MinShelfLife],[UserDefine01]
                        ,[UserDefine02],[UserDefine03],[UserDefine04],[UserDefine05],[UserDefine06],[UserDefine07]
                        ,[UserDefine08],[UserDefine09],[POkey],[ExternPOKey],[UserDefine10],[EnteredQTY],[ConsoOrderKey]
                        ,[ExternConsoOrderKey],[ConsoOrderLineNo],[Lottable06],[Lottable07],[Lottable08]
                        ,[Lottable09],[Lottable10],[Lottable11],[Lottable12],[Lottable13],[Lottable14]
                        ,[Lottable15],[Notes],[Notes2],[Channel],[HashValue],[SalesChannel],[CancelReasonCode] FROM ORDERDETAIL  WITH (NOLOCK)
                  WHERE OrderKey=@c_Orderkey AND OrderLineNumber =@c_OrderLineNumber

                  IF((SELECT COUNT(OrderKey) from ORDERDETAIL where OrderKey=@c_Orderkey and Status='CANC')= (SELECT COUNT(OrderKey) from ORDERDETAIL where OrderKey=@c_Orderkey))
                     BEGIN
                        UPDATE ORDERS WITH (ROWLOCK)
                              SET [Status] = 'CANC'
                                 ,[SOStatus] = 'CANC'
                                 ,CancelReasonCode=''
                            WHERE Orderkey = @c_Orderkey
                     END
               END
    END
   ELSE
      BEGIN
         SET @n_Continue = 3
			SET @n_Err= 556114
         SET @c_ErrMsg = 'NSQL'+ CONVERT(Char(6),@n_err)+': Order line number is required. (lsp_SOCancelOrderDetails)'

         INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)
         VALUES (@c_TableName, @c_SourceType, @c_Orderkey, @c_OrderLineNumber, '', 'ERROR', 0, @n_err, @c_errmsg)
         GOTO EXIT_SP
      END

      IF @n_continue = 1
      BEGIN

         SET @c_errmsg = 'Order detail is cancelled.'
         IF(@n_RowsUpdated>1)
            BEGIN
               SET @c_errmsg = 'Order details are cancelled.'
            END
         - START
         INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)
         VALUES (@c_TableName, @c_SourceType, @c_Orderkey, @c_OrderLineNumber, '', 'MESSAGE', 0, @n_err, @c_errmsg)
      END

   END TRY

   BEGIN CATCH
      SET @n_continue = 3
      SET @n_Err = 556113
      SET @c_ErrMsg = ERROR_MESSAGE()
      SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': UPDATE Orders fail. (lsp_SOCancelOrderDetails)'
                     + '(' + @c_ErrMsg + ')'


      INSERT INTO @t_WMSErrorList (TableName, SourceType, Refkey1, Refkey2, Refkey3, WriteType, LogWarningNo, ErrCode, ErrMsg)
      VALUES (@c_TableName, @c_SourceType, @c_Orderkey, @c_OrderLineNumber, '', 'ERROR', 0, @n_err, @c_errmsg)

      GOTO EXIT_SP
   END CATCH

EXIT_SP:
   - START
   IF (XACT_STATE()) = -1
   BEGIN
      SET @n_Continue=3
      ROLLBACK TRAN
   END
   - END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF @n_StartTCnt = 0 AND @@TRANCOUNT > @n_StartTCnt
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
      SET @n_WarningNo = 0
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_SOCancelOrderDetails'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   - START
   SET @CUR_ERRLIST = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT   twl.TableName
         ,  twl.SourceType
         ,  twl.Refkey1
         ,  twl.Refkey2
         ,  twl.Refkey3
         ,  twl.WriteType
         ,  twl.LogWarningNo
         ,  twl.ErrCode
         ,  twl.Errmsg
   FROM @t_WMSErrorList AS twl
   ORDER BY twl.RowID

   OPEN @CUR_ERRLIST

   FETCH NEXT FROM @CUR_ERRLIST INTO   @c_TableName
                                     , @c_SourceType
                                     , @c_Refkey1
                                     , @c_Refkey2
                                     , @c_Refkey3
                                     , @c_WriteType
                                     , @n_LogWarningNo
                                     , @n_Err
                                     , @c_Errmsg

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      EXEC [WM].[lsp_WriteError_List]
         @i_iErrGroupKey= @n_ErrGroupKey OUTPUT
      ,  @c_TableName   = @c_TableName
      ,  @c_SourceType  = @c_SourceType
      ,  @c_Refkey1     = @c_Refkey1
      ,  @c_Refkey2     = @c_Refkey2
      ,  @c_Refkey3     = @c_Refkey3
      ,  @n_LogWarningNo= @n_LogWarningNo
      ,  @c_WriteType   = @c_WriteType
      ,  @n_err2        = @n_err
      ,  @c_errmsg2     = @c_errmsg
      ,  @b_Success     = @b_Success
      ,  @n_err         = @n_err
      ,  @c_errmsg      = @c_errmsg

      FETCH NEXT FROM @CUR_ERRLIST INTO   @c_TableName
                                        , @c_SourceType
                                        , @c_Refkey1
                                        , @c_Refkey2
                                        , @c_Refkey3
                                        , @c_WriteType
                                        , @n_LogWarningNo
                                        , @n_Err
                                        , @c_Errmsg
   END
   CLOSE @CUR_ERRLIST
   DEALLOCATE @CUR_ERRLIST

   - END
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
   REVERT
END
GO
GRANT EXECUTE ON [WM].[lsp_SOCancelOrderDetails] TO nSQL
GO