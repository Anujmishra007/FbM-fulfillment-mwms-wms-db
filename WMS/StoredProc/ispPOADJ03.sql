SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Trigger: ispPOADJ03                                                  */
/* Creation Date: 05-Aug-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: Michael Lam                                              */
/*                                                                      */
/* Purpose: FCR-6197 - CN - Doterra Adjustment Finalize Logic CR        */
/*                                                                      */
/* Called By: ispPostFinalizeADJWrapper                                 */
/*          : Storerconfig PostFinalizeADJSP                            */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 2025-08-05   Michael   DevOps Combine Script                         */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[ispPOADJ03]
            @c_AdjustmentKey  NVARCHAR(10)
         ,  @b_Success        INT = 1  OUTPUT
         ,  @n_err            INT = 0  OUTPUT
         ,  @c_errmsg         NVARCHAR(215) = '' OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt            INT          = @@TRANCOUNT
         , @n_Continue             INT          = 1
         , @c_Storerkey            NVARCHAR(15) = ''
         , @c_SerialNo_ADJ         NVARCHAR(30) = ''
         , @c_AdjustmentLineNumber NVARCHAR(5)
         , @c_Sku                  NVARCHAR(20)
         , @c_SerialNo             NVARCHAR(50)
         , @n_Qty                  INT
         , @c_SerialNoKey          NVARCHAR(10)
         , @c_ItrnKey              NVARCHAR(10)
         , @c_TranType             NVARCHAR(10)

   SET @n_err      = 0
   SET @c_errmsg   = ''

   SELECT @c_Storerkey = Storerkey
     FROM ADJUSTMENT (NOLOCK)
    WHERE AdjustmentKey = @c_AdjustmentKey

   SET @c_SerialNo_ADJ = dbo.fnc_GetRight('', @c_Storerkey, '', 'SerialNo_ADJ')

   IF ISNULL(@c_SerialNo_ADJ,'')<>'1'
      GOTO QUIT_SP

   IF @n_continue IN(1,2)
   BEGIN
      DECLARE CUR_AD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT AD.AdjustmentLineNumber, AD.Storerkey, AD.Sku, AD.SerialNo, AD.Qty
      FROM ADJUSTMENT       AH(NOLOCK)
      JOIN ADJUSTMENTDETAIL AD(NOLOCK) ON AH.Adjustmentkey = AD.Adjustmentkey
      WHERE AH.AdjustmentKey = @c_AdjustmentKey
        AND AD.Finalizedflag = 'Y'
        AND AD.SerialNo <> ''

      OPEN CUR_AD

      WHILE @n_continue IN(1,2)
      BEGIN
         FETCH NEXT FROM CUR_AD INTO @c_AdjustmentLineNumber, @c_Storerkey, @c_Sku, @c_SerialNo, @n_Qty

         IF @@FETCH_STATUS <> 0
            BREAK

         IF @n_Qty > 0
         BEGIN
            SET @c_SerialNoKey = ''

            SELECT TOP 1 @c_SerialNoKey = SerialNoKey
              FROM SERIALNO (NOLOCK)
             WHERE Storerkey = @c_Storerkey
               AND SerialNo = @c_SerialNo
               AND Status IN ('9','CANC')
             ORDER BY CASE WHEN Sku = @c_Sku THEN 1 ELSE 2 END, SerialNoKey

            IF @c_SerialNoKey <> ''
            BEGIN
               UPDATE SERIALNO WITH(ROWLOCK)
                  SET Sku             = @c_Sku
                    , Qty             = @n_Qty
                    , Status          = '1'
                WHERE SerialNoKey = @c_SerialNoKey
                  AND Storerkey = @c_Storerkey
                  AND SerialNo = @c_SerialNo
                  AND Status IN ('9','CANC')
            
               SET @n_Err = @@ERROR
            
               IF @n_Err <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 72800
                  SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update SERIALNO table failed. (ispPOADJ03)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
                  GOTO QUIT_SP
               END
            END
            ELSE IF NOT EXISTS(SELECT TOP 1 1 FROM SERIALNO (NOLOCK) WHERE Storerkey = @c_Storerkey AND SerialNo = @c_SerialNo)
            BEGIN
               EXEC dbo.nspg_GetKey
                    @KeyName = 'SERIALNO'
                  , @fieldlength = 10
                  , @keystring = @c_SerialNoKey OUTPUT
                  , @b_Success = @b_success OUTPUT
                  , @n_err = @n_err OUTPUT
                  , @c_errmsg = @c_errmsg OUTPUT
                  , @b_resultset = 0
                  , @n_batch     = 1
            
               IF @b_Success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  GOTO QUIT_SP
               END
            
               INSERT INTO SERIALNO WITH(ROWLOCK) (SerialNoKey, StorerKey, SKU, SerialNo, Qty, Status)
               VALUES(@c_SerialNoKey, @c_Storerkey, @c_Sku, @c_SerialNo, @n_Qty, '1')
            
               SET @n_Err = @@ERROR
            
               IF @n_Err <> 0
               BEGIN
                 SELECT @n_Continue = 3
                 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 72801
                 SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert SERIALNO table failed. (ispPOADJ03)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
                 GOTO QUIT_SP
               END
            END
         END
         ELSE
         BEGIN
            UPDATE SERIALNO WITH(ROWLOCK)
               SET Status = 'CANC'
             WHERE Storerkey = @c_Storerkey
               AND SerialNo = @c_SerialNo
               AND ISNULL(Status,'') <> 'CANC'
         
            SET @n_Err = @@ERROR
         
            IF @n_Err <> 0
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 72802
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update SERIALNO table failed. (ispPOADJ03)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
               GOTO QUIT_SP
            END
         END

         IF @n_Continue IN(1,2)
         BEGIN
            SET @c_ItrnKey = ''

            SELECT @c_ItrnKey = ItrnKey
              FROM ITRN (NOLOCK)
             WHERE SourceKey  = @c_Adjustmentkey + @c_AdjustmentLineNumber
               AND SourceType Like 'ntrAdjustmentDetail%'
               AND TranType   = 'AJ'
               AND StorerKey = @c_StorerKey
               AND SKU = @c_Sku

            IF @@ROWCOUNT = 1
            BEGIN
               IF NOT EXISTS(SELECT TOP 1 1 FROM ITrnSerialNo (NOLOCK) WHERE ITrnKey = @c_ITrnKey)
               BEGIN
                  SET @c_TranType = CASE WHEN @n_Qty>0 THEN 'DP' ELSE 'WD' END

                  INSERT INTO ITRNSerialNo WITH(ROWLOCK) (ItrnKey, TranType, Storerkey, SKU, QTY, SerialNo, SourceKey, SourceType)
                  VALUES(@c_ItrnKey, @c_TranType, @c_Storerkey, @c_Sku, @n_Qty, @c_SerialNo, @c_Adjustmentkey + @c_AdjustmentLineNumber, 'ispPOADJ03')
         
                  SET @n_Err = @@ERROR
         
                  IF @n_Err <> 0
                  BEGIN
                    SELECT @n_Continue = 3
                    SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 72803
                    SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert ITRNSerialNo table failed. (ispPOADJ03)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
                    GOTO QUIT_SP
                  END
               END
            END
         END
      END

      CLOSE CUR_AD
      DEALLOCATE CUR_AD
   END


   QUIT_SP:

   IF CURSOR_STATUS( 'LOCAL', 'CUR_AD') in (0 , 1)
   BEGIN
      CLOSE CUR_AD
      DEALLOCATE CUR_AD
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispPOADJ03'
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
GRANT EXECUTE ON  [dbo].[ispPOADJ03] TO [NSQL]
GO
