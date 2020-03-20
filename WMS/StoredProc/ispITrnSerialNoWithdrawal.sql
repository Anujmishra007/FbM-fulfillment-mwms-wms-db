IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispITrnSerialNoWithdrawal]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispITrnSerialNoWithdrawal]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: ispITrnSerialNoWithdrawal                               */
/* Creation Date: 13-DEC-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: WMS-3543 - CN_DYSON_Close serialno status_CR                */
/*        :                                                             */
/* Called By: ntrITRNAdd                                                */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/
CREATE PROC [dbo].[ispITrnSerialNoWithdrawal]
     @c_ITrnKey      NVARCHAR(10)
   , @c_TranType     NVARCHAR(10)
   , @c_StorerKey    NVARCHAR(15)
   , @c_Sku          NVARCHAR(20)
   , @n_Qty          INT
   , @c_SourceKey    NVARCHAR(20)
   , @c_SourceType   NVARCHAR(30)
   , @b_Success      INT            OUTPUT  
   , @n_Err          INT            OUTPUT  
   , @c_ErrMsg       NVARCHAR(250)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT 

         , @c_PickDetailKey   NVARCHAR(10)
         , @c_SerialNoKey     NVARCHAR(10)
         , @c_SerialNo        NVARCHAR(30)

         , @n_PackSerialQty   INT

   DECLARE @CUR_SN            CURSOR

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @n_err      = 0
   SET @c_errmsg   = ''

   SET @c_PickDetailKey = @c_SourceKey

   SET @CUR_SN = CURSOR FAST_FORWARD READ_ONLY FOR
   SELECT PSN.SerialNo
         ,PSN.Storerkey
         ,PSN.Sku
         ,PSN.Qty 
   FROM  PACKSERIALNO PSN WITH (NOLOCK)
   WHERE PSN.PickDetailkey = @c_PickDetailKey
   ORDER BY PSN.PackSerialNoKey
   
   OPEN @CUR_SN
   
   FETCH NEXT FROM @CUR_SN INTO @c_SerialNo, @c_Storerkey, @c_Sku, @n_PackSerialQty
   WHILE @@FETCH_STATUS <> -1
   BEGIN

      SET @c_SerialNoKey = ''
      SELECT @c_SerialNoKey = SerialNoKey
      FROM SERIALNO WITH (NOLOCK)
      WHERE SerialNo = @c_SerialNo
      AND   Storerkey= @c_Storerkey
      AND   Sku      = @c_Sku 
      AND   Status   = '6'

      IF @c_SerialNoKey <> ''
      BEGIN
         UPDATE SerialNo WITH (ROWLOCK)
         SET   Status ='9'
         WHERE SerialNoKey = @c_SerialNoKey
         AND Status = '6'

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 71000
            SET @c_errmsg = 'NSQL' + CAST( @n_err AS NVARCHAR(6)) + ' UPDATE SerialNo Table fail (ispITrnSerialNoWithdrawal)'
            GOTO QUIT_SP
         END

         SET @n_PackSerialQty = @n_PackSerialQty * -1

         INSERT INTO ITrnSerialNo (ITrnKey, TranType, StorerKey, SKU, SerialNo, QTY, SourceKey, SourceType)
         VALUES (@c_ITrnKey, @c_TranType, @c_StorerKey, @c_SKU, @c_SerialNo, @n_PackSerialQty, @c_SourceKey, @c_SourceType)

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 71010
            SET @c_errmsg = 'NSQL' + CAST( @n_err AS NVARCHAR(6)) + ' Insert ITrnSerialNo fail (ispITrnSerialNoWithdrawal)'
            GOTO QUIT_SP
         END
      END
      
      FETCH NEXT FROM @CUR_SN INTO @c_SerialNo, @c_Storerkey, @c_Sku, @n_PackSerialQty 
   END

QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispITrnSerialNoWithdrawal'
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
GRANT EXECUTE ON [dbo].[ispITrnSerialNoWithdrawal] TO nSQL 
GO
