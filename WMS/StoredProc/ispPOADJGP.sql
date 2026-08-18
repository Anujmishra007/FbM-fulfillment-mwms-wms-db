SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: ispPOADJGP                                                  */
/* Creation Date: 2026-07-14                                            */
/* Copyright: Maersk                                                    */
/* Written by: Michael                                                  */
/*                                                                      */
/* Purpose: Generic SP for PostFinalizeADJSP                            */
/*                                                                      */
/* Called By: isp_FinalizeADJ -> ispPostFinalizeADJWrapper              */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 2026-07-14   Michael   1.0 UWP-61293-PostFinalizeADJSP GenericSP-ML01*/
/************************************************************************/
CREATE OR ALTER PROC ispPOADJGP
  @c_AdjustmentKey  NVARCHAR(10)
, @b_Success        INT = 1  OUTPUT
, @n_err            INT = 0  OUTPUT
, @c_errmsg         NVARCHAR(215) = '' OUTPUT
AS
BEGIN
/* STORERCONFIG
   .ConfigKey = 'PostFinalizeADJSP'
   .SValue    = 'ispPOADJGP'
   .OPTION5   = '@c_ExtPostFinalizeADJSP=xxx'  -- Calling another PostFinalizeADJSP if setup

   CODELKUP
   .ListName  =  'POADJCFG'
   .Code2     =  'ispPOADJGP'
   .Storerkey =  <Storerkey>

   Code                 Description             Short(Enable)   Long(Fieldname)   Notes(SQL)
   SN_UPD_SerialNo      Enalbe Upd S/N          Y/N             Y/N
   SN_SerialNo          SerialNo Exp            Y/N                               <SQL Expresssion>
   SN_SQL_ADJ_JOIN      SN AdjDtl JOIN          Y/N                               <Join Clause>
   SN_SQL_ADJ_WHERE     SN AdjDtl WHERE         Y/N                               <Where Clause>
   SN_SQL_ADJ_SORT      SN AdjDtl ORDER BY      Y/N                               <Order By Clause>
   SN_No_ITrnSN_Adj     No ITrn S/N Adj         Y/N             Y/N
   SN_Update_Lot        Update Lot              Y/N             Y/N
   SN_Update_Loc        Update Loc              Y/N             Y/N
   SN_Update_ID         Update ID               Y/N             Y/N
   SN_TranTypeDPWD      TranType DP/WD          Y/N             Y/N
   EL_ExternLot         ExternLot Exp           Y/N                               <SQL Expression>
   EL_ExternLotStatus   ExternLotStatus Exp     Y/N                               <SQL Expression>
   EL_ExternLottable01  ExternLottable01 Exp    Y/N                               <SQL Expression>
   EL_ExternLottable02  ExternLottable02 Exp    Y/N                               <SQL Expression>
   EL_ExternLottable03  ExternLottable03 Exp    Y/N                               <SQL Expression>
   EL_ExternLottable04  ExternLottable04 Exp    Y/N                               <SQL Expression>
   EL_ExternLottable05  ExternLottable05 Exp    Y/N                               <SQL Expression>
   EL_SQL_ADJ_JOIN      EL AdjDtl JOIN          Y/N                               <Join Clause>
   EL_SQL_ADJ_WHERE     EL AdjDtl WHERE         Y/N                               <Where Clause>
   EL_SQL_ADJ_SORT      EL AdjDtl ORDER BY      Y/N                               <Order By Clause>
   QR_UPD_QtyReplen     Enalbe Upd QtyReplen    Y/N             Y/N
   QR_QtyReplen         QtyReplen Exp           Y/N                               <SQL Expression>
   QR_SQL_ADJ_JOIN      QR AdjDtl JOIN          Y/N                               <Join Clause>
   QR_SQL_ADJ_WHERE     QR AdjDtl WHERE         Y/N                               <Where Clause>
   QR_SQL_ADJ_SORT      QR AdjDtl ORDER BY      Y/N                               <Order By Clause>
   Debug                Debug mode              Y/N
*/
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt        INT = @@TRANCOUNT
         , @n_Continue         INT = 1
         , @b_debug            INT = 0
         , @n_CursorStatus     INT
         , @c_Option5          NVARCHAR(MAX) = ''
         , @c_SP_Name          NVARCHAR(128) = 'ispPOADJGP'
         , @c_x_Storerkey      NVARCHAR(15)  = ''
         , @c_x_Facility       NVARCHAR(15)  = ''
         , @c_AdjKey           NVARCHAR(10)  = ''
         , @c_AdjLineNumber    NVARCHAR(5)   = ''
         , @c_Storerkey        NVARCHAR(15)  = ''
         , @c_Sku              NVARCHAR(20)  = ''
         , @c_Lot              NVARCHAR(10)  = ''
         , @c_Loc              NVARCHAR(10)  = ''
         , @c_ID               NVARCHAR(18)  = ''
         , @n_Qty              INT           = 0
         , @c_SerialNoKey      NVARCHAR(10)  = ''
         , @c_SerialNo         NVARCHAR(50)  = ''
         , @c_Sourcekey        NVARCHAR(20)  = ''
         , @c_TranType         NVARCHAR(10)  = ''
         , @c_Tmp_Lot          NVARCHAR(10)  = ''
         , @c_Tmp_Loc          NVARCHAR(10)  = ''
         , @c_Tmp_ID           NVARCHAR(18)  = ''
         , @c_ExternLot        NVARCHAR(60)  = ''
         , @c_ExternLotStatus  NVARCHAR(10)  = ''
         , @c_ExternLottable01 NVARCHAR(60)  = ''
         , @c_ExternLottable02 NVARCHAR(60)  = ''
         , @c_ExternLottable03 NVARCHAR(60)  = ''
         , @d_ExternLottable04 DATETIME      = ''
         , @d_ExternLottable05 DATETIME      = ''
         , @n_QtyReplen        INT           = 0
         , @c_SN_SerialNo_Exp  NVARCHAR(MAX) = ''
         , @c_SN_SQL_ADJ_JOIN  NVARCHAR(MAX) = ''
         , @c_SN_SQL_ADJ_WHERE NVARCHAR(MAX) = ''
         , @c_SN_SQL_ADJ_SORT  NVARCHAR(MAX) = ''
         , @c_SN_UPD_SerialNo  NVARCHAR(10)  = ''
         , @c_SN_No_ITrnSN_Adj NVARCHAR(10)  = ''
         , @c_SN_Update_Lot    NVARCHAR(10)  = ''
         , @c_SN_Update_Loc    NVARCHAR(10)  = ''
         , @c_SN_Update_ID     NVARCHAR(10)  = ''
         , @c_SN_TranTypeDPWD  NVARCHAR(10)  = ''
         , @c_EL_ExternLot_Exp NVARCHAR(MAX) = ''
         , @c_EL_ExtLotSts_Exp NVARCHAR(MAX) = ''
         , @c_EL_ExtLot01_Exp  NVARCHAR(MAX) = ''
         , @c_EL_ExtLot02_Exp  NVARCHAR(MAX) = ''
         , @c_EL_ExtLot03_Exp  NVARCHAR(MAX) = ''
         , @c_EL_ExtLot04_Exp  NVARCHAR(MAX) = ''
         , @c_EL_ExtLot05_Exp  NVARCHAR(MAX) = ''
         , @c_EL_SQL_ADJ_JOIN  NVARCHAR(MAX) = ''
         , @c_EL_SQL_ADJ_WHERE NVARCHAR(MAX) = ''
         , @c_EL_SQL_ADJ_SORT  NVARCHAR(MAX) = ''
         , @c_QR_QtyReplen_Exp NVARCHAR(MAX) = ''
         , @c_QR_SQL_ADJ_JOIN  NVARCHAR(MAX) = ''
         , @c_QR_SQL_ADJ_WHERE NVARCHAR(MAX) = ''
         , @c_QR_SQL_ADJ_SORT  NVARCHAR(MAX) = ''
         , @c_QR_UPD_QtyReplen NVARCHAR(10)  = ''
         , @c_ListName         NVARCHAR(10)  = 'POADJCFG'
         , @c_SQL              NVARCHAR(MAX)
         , @c_SQLParm          NVARCHAR(MAX)
         , @c_ExtPostFinalizeADJSP NVARCHAR(MAX) = ''

   SET @n_err = 0
   SET @c_errmsg = ''

   SELECT @c_x_Storerkey = Storerkey
        , @c_x_Facility  = Facility
   FROM dbo.ADJUSTMENT WITH(NOLOCK)
   WHERE AdjustmentKey = @c_AdjustmentKey

   -- Extended PostFinalizeADJSP
   SELECT @c_Option5 = SC.Option5
   FROM dbo.fnc_GetRight2(@c_x_Facility, @c_x_Storerkey, '', 'PostFinalizeADJSP') AS SC
   WHERE Authority='ispPOADJGP'

   SELECT @c_ExtPostFinalizeADJSP = dbo.fnc_GetParamValueFromString ('@c_ExtPostFinalizeADJSP', @c_option5, '')

   IF ISNULL(@c_ExtPostFinalizeADJSP,'') NOT IN ('', @c_SP_Name) AND
      EXISTS (SELECT 1 FROM sys.objects WHERE name = @c_ExtPostFinalizeADJSP AND [type] = 'P')
   BEGIN
      SET @c_SQL = N'EXECUTE ' + @c_ExtPostFinalizeADJSP
        + ' @c_AdjustmentKey = @c_AdjustmentKey'
        +', @b_Success  = @b_Success OUTPUT'
        +', @n_Err      = @n_Err     OUTPUT'
        +', @c_ErrMsg   = @c_ErrMsg  OUTPUT'

      SET @c_SQLParm =
          N'@c_AdjustmentKey  NVARCHAR(10)'
        +', @b_Success INT OUTPUT'
        +', @n_Err     INT OUTPUT'
        +', @c_ErrMsg  NVARCHAR(250) OUTPUT '

      EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm
         , @c_AdjustmentKey
         , @b_Success OUTPUT
         , @n_Err     OUTPUT
         , @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
         GOTO QUIT_SP
      END
   END

   -- Get POADJCFG setup
   SELECT @c_SN_SerialNo_Exp  = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_SerialNo'         AND Short = 'Y' THEN Notes END)),'')
        , @c_SN_SQL_ADJ_JOIN  = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_SQL_ADJ_JOIN'     AND Short = 'Y' THEN Notes END)),'')
        , @c_SN_SQL_ADJ_WHERE = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_SQL_ADJ_WHERE'    AND Short = 'Y' THEN Notes END)),'')
        , @c_SN_SQL_ADJ_SORT  = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_SQL_ADJ_SORT'     AND Short = 'Y' THEN Notes END)),'')
        , @c_SN_UPD_SerialNo  = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_UPD_SerialNo'     AND Short = 'Y' THEN Long  END)),'')
        , @c_SN_No_ITrnSN_Adj = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_No_ITrnSN_Adj'    AND Short = 'Y' THEN Long  END)),'')
        , @c_SN_Update_Lot    = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_Update_Lot'       AND Short = 'Y' THEN Long  END)),'')
        , @c_SN_Update_Loc    = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_Update_Loc'       AND Short = 'Y' THEN Long  END)),'')
        , @c_SN_Update_ID     = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_Update_ID'        AND Short = 'Y' THEN Long  END)),'')
        , @c_SN_TranTypeDPWD  = ISNULL(TRIM(MAX(CASE WHEN Code = 'SN_TranTypeDPWD'     AND Short = 'Y' THEN Long  END)),'')
        , @c_EL_ExternLot_Exp = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_ExternLot'        AND Short = 'Y' THEN Notes END)),'')
        , @c_EL_ExtLotSts_Exp = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_ExternLotStatus'  AND Short = 'Y' THEN Notes END)),'')
        , @c_EL_ExtLot01_Exp  = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_ExternLottable01' AND Short = 'Y' THEN Notes END)),'')
        , @c_EL_ExtLot02_Exp  = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_ExternLottable02' AND Short = 'Y' THEN Notes END)),'')
        , @c_EL_ExtLot03_Exp  = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_ExternLottable03' AND Short = 'Y' THEN Notes END)),'')
        , @c_EL_ExtLot04_Exp  = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_ExternLottable04' AND Short = 'Y' THEN Notes END)),'')
        , @c_EL_ExtLot05_Exp  = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_ExternLottable05' AND Short = 'Y' THEN Notes END)),'')
        , @c_EL_SQL_ADJ_JOIN  = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_SQL_ADJ_JOIN'     AND Short = 'Y' THEN Notes END)),'')
        , @c_EL_SQL_ADJ_WHERE = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_SQL_ADJ_WHERE'    AND Short = 'Y' THEN Notes END)),'')
        , @c_EL_SQL_ADJ_SORT  = ISNULL(TRIM(MAX(CASE WHEN Code = 'EL_SQL_ADJ_SORT'     AND Short = 'Y' THEN Notes END)),'')
        , @c_QR_QtyReplen_Exp = ISNULL(TRIM(MAX(CASE WHEN Code = 'QR_QtyReplen'        AND Short = 'Y' THEN Notes END)),'')
        , @c_QR_SQL_ADJ_JOIN  = ISNULL(TRIM(MAX(CASE WHEN Code = 'QR_SQL_ADJ_JOIN'     AND Short = 'Y' THEN Notes END)),'')
        , @c_QR_SQL_ADJ_WHERE = ISNULL(TRIM(MAX(CASE WHEN Code = 'QR_SQL_ADJ_WHERE'    AND Short = 'Y' THEN Notes END)),'')
        , @c_QR_SQL_ADJ_SORT  = ISNULL(TRIM(MAX(CASE WHEN Code = 'QR_SQL_ADJ_SORT'     AND Short = 'Y' THEN Notes END)),'')
        , @c_QR_UPD_QtyReplen = ISNULL(TRIM(MAX(CASE WHEN Code = 'QR_UPD_QtyReplen'    AND Short = 'Y' THEN Long  END)),'')
        , @b_debug            = ISNULL(MAX(CASE WHEN Code = 'Debug' AND Short IN ('1','Y') THEN 1 END),0)
     FROM dbo.CODELKUP WITH(NOLOCK)
    WHERE ListName = @c_ListName
      AND Code2 = @c_SP_Name
      AND Storerkey = @c_x_Storerkey

   IF LEFT(@c_SN_SQL_ADJ_WHERE,4) = 'AND '
      SET @c_SN_SQL_ADJ_WHERE = SUBSTRING(@c_SN_SQL_ADJ_WHERE, 5, LEN(@c_SN_SQL_ADJ_WHERE))

   IF LEFT(@c_EL_SQL_ADJ_WHERE,4) = 'AND '
      SET @c_EL_SQL_ADJ_WHERE = SUBSTRING(@c_EL_SQL_ADJ_WHERE, 5, LEN(@c_EL_SQL_ADJ_WHERE))

   IF LEFT(@c_QR_SQL_ADJ_WHERE,4) = 'AND '
      SET @c_QR_SQL_ADJ_WHERE = SUBSTRING(@c_QR_SQL_ADJ_WHERE, 5, LEN(@c_QR_SQL_ADJ_WHERE))

STEP_1:   -- Update SerialNo table
   IF ISNULL(@c_SN_UPD_SerialNo,'') NOT IN ('1', 'Y')
      GOTO STEP_2

   SET @c_SQL =
      N'DECLARE CUR_ADJ_DTL_SN CURSOR FAST_FORWARD READ_ONLY FOR'
     +' SELECT ADJUSTMENTDETAIL.AdjustmentKey'
     +      ', ADJUSTMENTDETAIL.AdjustmentLineNumber'
     +      ', ADJUSTMENTDETAIL.Storerkey'
     +      ', ADJUSTMENTDETAIL.Sku'
     +      ', ADJUSTMENTDETAIL.Lot'
     +      ', ADJUSTMENTDETAIL.Loc'
     +      ', ADJUSTMENTDETAIL.Id'
     +      ', ADJUSTMENTDETAIL.Qty'
     +      ', SerialNo = (' + CASE WHEN ISNULL(@c_SN_SerialNo_Exp,'')<>'' THEN @c_SN_SerialNo_Exp ELSE 'ADJUSTMENTDETAIL.SerialNo' END + ')'
     +' FROM dbo.ADJUSTMENT WITH(NOLOCK)'
     +' JOIN dbo.ADJUSTMENTDETAIL WITH(NOLOCK) ON ADJUSTMENT.AdjustmentKey=ADJUSTMENTDETAIL.AdjustmentKey'

   IF ISNULL(@c_SN_SQL_ADJ_JOIN,'') <> ''
      SET @c_SQL = @c_SQL + ' ' + @c_SN_SQL_ADJ_JOIN

   SET @c_SQL = @c_SQL
     +' WHERE ADJUSTMENT.AdjustmentKey=N''' + ISNULL(REPLACE(@c_AdjustmentKey,'''',''''''),'') + ''''
     +  ' AND ADJUSTMENTDETAIL.FinalizedFlag=''Y'''
     +  ' AND ADJUSTMENTDETAIL.Qty<>0'

   IF ISNULL(@c_SN_SQL_ADJ_WHERE,'') <> ''
      SET @c_SQL = @c_SQL + ' AND (' + @c_SN_SQL_ADJ_WHERE + ')'

   IF ISNULL(@c_SN_SQL_ADJ_SORT,'') <> ''
      SET @c_SQL = @c_SQL + ' ORDER BY ' + @c_SN_SQL_ADJ_SORT
   ELSE
      SET @c_SQL = @c_SQL + ' ORDER BY 1, 2'

   IF @b_debug = 1
      SELECT @c_SQL AS [CUR_ADJ_DTL_SN]

   BEGIN TRY
      EXEC (@c_SQL)
   END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @n_err = 72800
      SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Declare Cursor CUR_ADJ_DTL_SN Error. ('+ISNULL(@c_SP_Name,'')+')'
                    + '(SQLSvr MESSAGE='+ISNULL(ERROR_MESSAGE(),'')+')'
      GOTO QUIT_SP
   END CATCH

   OPEN CUR_ADJ_DTL_SN

   WHILE @n_Continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_ADJ_DTL_SN
       INTO @c_AdjKey, @c_AdjLineNumber, @c_Storerkey, @c_Sku, @c_Lot, @c_Loc, @c_ID, @n_Qty, @c_SerialNo

      IF @@FETCH_STATUS<>0
         BREAK

      IF ISNULL(@c_SerialNo,'')=''
         CONTINUE

      SET @c_Tmp_Lot = CASE WHEN @c_SN_Update_Lot IN ('1','Y') THEN @c_Lot ELSE '' END
      SET @c_Tmp_Loc = CASE WHEN @c_SN_Update_Loc IN ('1','Y') THEN @c_Loc ELSE '' END
      SET @c_Tmp_ID  = CASE WHEN @c_SN_Update_ID  IN ('1','Y') THEN @c_ID  ELSE '' END

      IF @n_Qty > 0
      BEGIN
         SET @c_SerialNoKey = ''

         SELECT TOP 1 @c_SerialNoKey = SerialNoKey
           FROM dbo.SERIALNO WITH(NOLOCK)
          WHERE Storerkey = @c_Storerkey
            AND SerialNo = @c_SerialNo
            AND Status IN ('9','CANC')
          ORDER BY CASE WHEN Sku = @c_Sku THEN 1 ELSE 2 END, SerialNoKey

         IF @c_SerialNoKey <> ''
         BEGIN
            UPDATE dbo.SERIALNO WITH(ROWLOCK)
               SET Status = '1'
                 , Sku    = @c_Sku
                 , Qty    = @n_Qty
                 , Lot    = @c_Tmp_Lot
                 , Loc    = @c_Tmp_Loc
                 , ID     = @c_Tmp_ID
             WHERE SerialNoKey = @c_SerialNoKey
               AND Storerkey = @c_Storerkey
               AND SerialNo = @c_SerialNo
               AND Status IN ('9','CANC')

            SET @n_err = @@ERROR

            IF @n_Err <> 0
            BEGIN
               SET @n_continue = 3
               SET @c_errmsg = CONVERT(NVARCHAR(10),@n_Err)
               SET @n_err = 72801
               SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Update SERIALNO table failed. ('+ISNULL(@c_SP_Name,'')+')('+TRIM(@c_errmsg)+')'
               BREAK
            END
         END
         ELSE IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.SERIALNO WITH(NOLOCK) WHERE Storerkey = @c_Storerkey AND SerialNo = @c_SerialNo)
         BEGIN
            EXEC nspg_GetKey
                 @KeyName     = 'SERIALNO'
               , @fieldlength = 10
               , @keystring   = @c_SerialNoKey OUTPUT
               , @b_success   = @b_success     OUTPUT
               , @n_err       = @n_err         OUTPUT
               , @c_errmsg    = @c_errmsg      OUTPUT
               , @b_resultset = 0
               , @n_batch     = 1

            IF @b_Success <> 1
            BEGIN
               SET @n_continue= 3
               SET @n_err = 72802
               SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Generate SerialNoKey Failed. ('+ISNULL(@c_SP_Name,'')+')('+TRIM(@c_errmsg)+')'
               BREAK
            END


            INSERT INTO dbo.SERIALNO WITH(ROWLOCK) (SerialNoKey, Orderkey, OrderLineNumber, Storerkey, Sku, SerialNo, Qty, Status, Lot, Loc, Id)
            VALUES (@c_SerialNoKey, '', '', @c_Storerkey, @c_Sku, @c_SerialNo, @n_Qty, 1, @c_Tmp_Lot, @c_Tmp_Loc, @c_Tmp_ID)

            SET @n_err = @@ERROR

            IF @n_Err <> 0
            BEGIN
               SET @n_continue= 3
               SET @c_errmsg = CONVERT(NVARCHAR(10),@n_Err)
               SET @n_err = 72803
               SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Insert SERIALNO table failed. ('+ISNULL(@c_SP_Name,'')+')('+TRIM(@c_errmsg)+')'
               BREAK
            END
         END
      END
      ELSE IF EXISTS(SELECT TOP 1 1 FROm dbo.SERIALNO WITH(NOLOCK)
           WHERE Storerkey = @c_Storerkey AND SerialNo = @c_SerialNo AND ISNULL(Status,'') <> 'CANC')
      BEGIN
         UPDATE dbo.SERIALNO WITH(ROWLOCK)
            SET Status = 'CANC'
          WHERE Storerkey = @c_Storerkey
            AND SerialNo = @c_SerialNo
            AND ISNULL(Status,'') <> 'CANC'

         SET @n_err = @@ERROR

         IF @n_Err <> 0
         BEGIN
            SET @n_continue= 3
            SET @c_errmsg = CONVERT(NVARCHAR(10),@n_Err)
            SET @n_err = 72804
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Update SERIALNO table failed. ('+ISNULL(@c_SP_Name,'')+')('+TRIM(@c_errmsg)+')'
            BREAK
         END
      END

      IF @n_Continue IN (1,2) AND ISNULL(@c_SN_No_ITrnSN_Adj,'') NOT IN ('1','Y')
      BEGIN
         SET @c_Sourcekey = RTRIM(@c_AdjKey) + RTRIM(@c_AdjLineNumber)
         SET @c_TranType  = CASE WHEN @c_SN_TranTypeDPWD IN ('1','Y')
                                 THEN IIF(@n_Qty > 0, 'DP', 'WD')
                                 ELSE 'AJ' END

         EXEC ispITrnSerialNoAdjustment
              @c_TranType   = @c_TranType
             ,@c_StorerKey  = @c_Storerkey
             ,@c_SKU        = @c_Sku
             ,@c_SerialNo   = @c_SerialNo
             ,@n_QTY        = @n_Qty
             ,@c_SourceKey  = @c_Sourcekey
             ,@c_SourceType = @c_SP_Name
             ,@b_Success    = @b_Success OUTPUT
             ,@n_Err        = @n_err     OUTPUT
             ,@c_ErrMsg     = @c_errmsg  OUTPUT

         IF @b_Success <> 1
         BEGIN
            SET @n_continue= 3
            SET @n_err  = 72805
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Insert ITrnSerialNo Table Failed. ('+ISNULL(@c_SP_Name,'')+')('+TRIM(@c_errmsg)+')'
            BREAK
         END
      END
   END
   CLOSE CUR_ADJ_DTL_SN
   DEALLOCATE CUR_ADJ_DTL_SN


STEP_2:   -- Update EXTERNLOTATTRIBUTE
   IF ISNULL(@c_EL_ExternLot_Exp,'') = ''
      GOTO STEP_3

   SET @c_SQL =
      N'DECLARE CUR_ADJ_DTL_EL CURSOR FAST_FORWARD READ_ONLY FOR'
     +' SELECT ADJUSTMENTDETAIL.AdjustmentKey'
     +      ', ADJUSTMENTDETAIL.AdjustmentLineNumber'
     +      ', ADJUSTMENTDETAIL.Storerkey'
     +      ', ADJUSTMENTDETAIL.Sku'
     +      ', ExternLot        = (' + CASE WHEN ISNULL(@c_EL_ExternLot_Exp,'')<>'' THEN @c_EL_ExternLot_Exp ELSE '''''' END + ')'
   SET @c_SQL = @c_SQL
     +      ', ExternLotStatus  = (' + CASE WHEN ISNULL(@c_EL_ExtLotSts_Exp,'')<>'' THEN @c_EL_ExtLotSts_Exp ELSE '''ACTIVE''' END + ')'
   SET @c_SQL = @c_SQL
     +      ', ExternLottable01 = (' + CASE WHEN ISNULL(@c_EL_ExtLot01_Exp ,'')<>'' THEN @c_EL_ExtLot01_Exp  ELSE '''''' END + ')'
   SET @c_SQL = @c_SQL
     +      ', ExternLottable02 = (' + CASE WHEN ISNULL(@c_EL_ExtLot02_Exp ,'')<>'' THEN @c_EL_ExtLot02_Exp  ELSE '''''' END + ')'
   SET @c_SQL = @c_SQL
     +      ', ExternLottable03 = (' + CASE WHEN ISNULL(@c_EL_ExtLot03_Exp ,'')<>'' THEN @c_EL_ExtLot03_Exp  ELSE '''''' END + ')'
   SET @c_SQL = @c_SQL
     +      ', ExternLottable04 = (' + CASE WHEN ISNULL(@c_EL_ExtLot04_Exp ,'')<>'' THEN @c_EL_ExtLot04_Exp  ELSE 'NULL' END + ')'
   SET @c_SQL = @c_SQL
     +      ', ExternLottable05 = (' + CASE WHEN ISNULL(@c_EL_ExtLot05_Exp ,'')<>'' THEN @c_EL_ExtLot05_Exp  ELSE 'NULL' END + ')'
     +' FROM dbo.ADJUSTMENT WITH(NOLOCK)'
     +' JOIN dbo.ADJUSTMENTDETAIL WITH(NOLOCK) ON ADJUSTMENT.AdjustmentKey=ADJUSTMENTDETAIL.AdjustmentKey'

   IF ISNULL(@c_EL_SQL_ADJ_JOIN,'') <> ''
      SET @c_SQL = @c_SQL + ' ' + @c_EL_SQL_ADJ_JOIN

   SET @c_SQL = @c_SQL
     +' WHERE ADJUSTMENT.AdjustmentKey=N''' + ISNULL(REPLACE(@c_AdjustmentKey,'''',''''''),'') + ''''
     +  ' AND ADJUSTMENTDETAIL.FinalizedFlag=''Y'''
     +  ' AND ADJUSTMENTDETAIL.Qty<>0'

   IF ISNULL(@c_EL_SQL_ADJ_WHERE,'') <> ''
      SET @c_SQL = @c_SQL + ' AND (' + @c_EL_SQL_ADJ_WHERE + ')'

   IF ISNULL(@c_EL_SQL_ADJ_SORT,'') <> ''
      SET @c_SQL = @c_SQL + ' ORDER BY ' + @c_EL_SQL_ADJ_SORT
   ELSE
      SET @c_SQL = @c_SQL + ' ORDER BY 1, 2'

   IF @b_debug = 1
      SELECT @c_SQL AS [CUR_ADJ_DTL_EL]

   BEGIN TRY
      EXEC (@c_SQL)
   END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @n_err = 72806
      SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Declare Cursor CUR_ADJ_DTL_EL Error. ('+ISNULL(@c_SP_Name,'')+')'
                    + '(SQLSvr MESSAGE='+ISNULL(ERROR_MESSAGE(),'')+')'
      GOTO QUIT_SP
   END CATCH

   OPEN CUR_ADJ_DTL_EL

   WHILE @n_Continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_ADJ_DTL_EL
       INTO @c_AdjKey, @c_AdjLineNumber, @c_Storerkey, @c_Sku
          , @c_ExternLot, @c_ExternLotStatus, @c_ExternLottable01, @c_ExternLottable02, @c_ExternLottable03, @d_ExternLottable04, @d_ExternLottable05

      IF @@FETCH_STATUS<>0
         BREAK

      IF ISNULL(@c_ExternLot,'')=''
         CONTINUE

      IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.EXTERNLOTATTRIBUTE WITH(NOLOCK)
                     WHERE Storerkey = @c_Storerkey AND Sku = @c_Sku AND ExternLot = @c_ExternLot)
      BEGIN
         INSERT INTO dbo.EXTERNLOTATTRIBUTE WITH(ROWLOCK) (StorerKey, SKU, ExternLot, ExternLotStatus,
            ExternLottable01, ExternLottable02, ExternLottable03, ExternLottable04, ExternLottable05)
         VALUES(@c_Storerkey, @c_Sku, @c_ExternLot, @c_ExternLotStatus,
            @c_ExternLottable01, @c_ExternLottable02, @c_ExternLottable03, @d_ExternLottable04, @d_ExternLottable05)

         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SET @n_Continue = 3
            SET @c_errmsg = CONVERT(NVARCHAR(10),@n_Err)
            SET @n_err = 72807
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Insert EXTERNLOTATTRIBUTE Table Failed. ('+ISNULL(@c_SP_Name,'')+')('+TRIM(@c_errmsg)+')'
            BREAK
         END
      END
   END
   CLOSE CUR_ADJ_DTL_EL
   DEALLOCATE CUR_ADJ_DTL_EL


STEP_3:   -- Update LOTxLOCxID.QtyReplen
   IF ISNULL(@c_QR_UPD_QtyReplen,'') NOT IN ('1', 'Y')
      GOTO STEP_4

   SET @c_SQL =
      N'DECLARE CUR_ADJ_DTL_QR CURSOR FAST_FORWARD READ_ONLY FOR'
     +' SELECT ADJUSTMENTDETAIL.AdjustmentKey'
     +      ', ADJUSTMENTDETAIL.AdjustmentLineNumber'
     +      ', ADJUSTMENTDETAIL.Storerkey'
     +      ', ADJUSTMENTDETAIL.Sku'
     +      ', ADJUSTMENTDETAIL.Lot'
     +      ', ADJUSTMENTDETAIL.Loc'
     +      ', ADJUSTMENTDETAIL.Id'
     +      ', ADJUSTMENTDETAIL.Qty'
     +      ', QtyReplen = TRY_PARSE(ISNULL(' + CASE WHEN ISNULL(@c_QR_QtyReplen_Exp,'')<>'' THEN @c_QR_QtyReplen_Exp ELSE '''''' END + ','''') AS INT)'
     +' FROM dbo.ADJUSTMENT WITH(NOLOCK)'
     +' JOIN dbo.ADJUSTMENTDETAIL WITH(NOLOCK) ON ADJUSTMENT.AdjustmentKey=ADJUSTMENTDETAIL.AdjustmentKey'

   IF ISNULL(@c_QR_SQL_ADJ_JOIN,'') <> ''
      SET @c_SQL = @c_SQL + ' ' + @c_QR_SQL_ADJ_JOIN

   SET @c_SQL = @c_SQL
     +' WHERE ADJUSTMENT.AdjustmentKey=N''' + ISNULL(REPLACE(@c_AdjustmentKey,'''',''''''),'') + ''''
     +  ' AND ADJUSTMENTDETAIL.FinalizedFlag=''Y'''
     +  ' AND ADJUSTMENTDETAIL.Qty<>0'

   IF ISNULL(@c_QR_SQL_ADJ_WHERE,'') <> ''
      SET @c_SQL = @c_SQL + ' AND (' + @c_QR_SQL_ADJ_WHERE + ')'

   IF ISNULL(@c_QR_SQL_ADJ_SORT,'') <> ''
      SET @c_SQL = @c_SQL + ' ORDER BY ' + @c_QR_SQL_ADJ_SORT
   ELSE
      SET @c_SQL = @c_SQL + ' ORDER BY 1, 2'

   IF @b_debug = 1
      SELECT @c_SQL AS [CUR_ADJ_DTL_QR]

   BEGIN TRY
      EXEC (@c_SQL)
   END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @n_err = 72808
      SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Declare Cursor CUR_ADJ_DTL_QR Error. ('+ISNULL(@c_SP_Name,'')+')'
                    + '(SQLSvr MESSAGE='+ISNULL(ERROR_MESSAGE(),'')+')'
      GOTO QUIT_SP
   END CATCH

   OPEN CUR_ADJ_DTL_QR

   WHILE @n_Continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_ADJ_DTL_QR
       INTO @c_AdjKey, @c_AdjLineNumber, @c_Storerkey, @c_Sku, @c_Lot, @c_Loc, @c_ID, @n_Qty, @n_QtyReplen

      IF @@FETCH_STATUS<>0
         BREAK

      IF @n_QtyReplen IS NULL
         CONTINUE

      IF EXISTS(SELECT TOP 1 1 FROM dbo.LOTxLOCxID WITH(NOLOCK)
                WHERE Lot = @c_Lot AND Loc = @c_Loc AND ID = @c_ID
                  AND Storerkey = @c_Storerkey AND Sku = @c_Sku
                  AND ISNULL(QtyReplen,0) <> @n_QtyReplen)
      BEGIN
         UPDATE dbo.LOTXLOCXID WITH(ROWLOCK)
            SET QtyReplen = @n_QtyReplen
              , TrafficCop = NULL
          WHERE Lot = @c_Lot AND Loc = @c_Loc AND ID = @c_ID
            AND Storerkey = @c_Storerkey AND Sku = @c_Sku
            AND QtyReplen <> @n_QtyReplen

         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SET @n_Continue = 3
            SET @c_errmsg = CONVERT(NVARCHAR(10),@n_Err)
            SET @n_err = 72809
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(10),@n_err)+': Update LOTXLOCXID Table Failed. ('+ISNULL(@c_SP_Name,'')+')('+TRIM(@c_errmsg)+')'
            BREAK
         END
      END
   END
   CLOSE CUR_ADJ_DTL_QR
   DEALLOCATE CUR_ADJ_DTL_QR


STEP_4:

QUIT_SP:
   IF XACT_STATE() = -1   --(-1 = uncommittable)
      ROLLBACK TRAN

   SET @n_CursorStatus = CURSOR_STATUS('GLOBAL', 'CUR_ADJ_DTL_SN')
   IF @n_CursorStatus >= -1
   BEGIN
      IF @n_CursorStatus >= 0
         CLOSE CUR_ADJ_DTL_SN
      DEALLOCATE CUR_ADJ_DTL_SN
   END

   SET @n_CursorStatus = CURSOR_STATUS('GLOBAL', 'CUR_ADJ_DTL_EL')
   IF @n_CursorStatus >= -1
   BEGIN
      IF @n_CursorStatus >= 0
         CLOSE CUR_ADJ_DTL_EL
      DEALLOCATE CUR_ADJ_DTL_EL
   END

   SET @n_CursorStatus = CURSOR_STATUS('GLOBAL', 'CUR_ADJ_DTL_QR')
   IF @n_CursorStatus >= -1
   BEGIN
      IF @n_CursorStatus >= 0
         CLOSE CUR_ADJ_DTL_QR
      DEALLOCATE CUR_ADJ_DTL_QR
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, @c_SP_Name
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[ispPOADJGP] TO nSQL
GO
