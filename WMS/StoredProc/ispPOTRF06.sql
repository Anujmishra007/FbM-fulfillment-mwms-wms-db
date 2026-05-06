SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: ispPOTRF06                                            */
/* Creation Date: 31-JUL-2025                                              */
/* Copyright: MAERSK                                                       */
/* Written by: Michael Lam                                                 */
/*                                                                         */
/* Purpose: FCR-6779 - CN - Capri - Transfer Allocation - CR               */
/*                                                                         */
/* Called By: ispPostFinalizeTransferWrapper                               */
/*                                                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 31-JUL-2025  Michael 1.0   DEVOPS Combine Script                        */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[ispPOTRF06]
(     @c_Transferkey  NVARCHAR(10)
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT
  ,   @c_TransferLineNumber   NVARCHAR(5) = ''
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Debug              INT
         , @n_Cnt                INT
         , @n_Continue           INT
         , @n_StartTCount        INT

   DECLARE @c_Storerkey          NVARCHAR(15) = ''
         , @c_Facility           NVARCHAR(5)  = ''
         , @c_x_Transferkey      NVARCHAR(10) = ''
         , @c_x_TransferLineNo   NVARCHAR(5)  = ''
         , @c_UCCNo              NVARCHAR(20) = ''
         , @c_FromStorerkey      NVARCHAR(15) = ''
         , @c_FromSku            NVARCHAR(15) = ''
         , @c_FromLot            NVARCHAR(10) = ''
         , @c_FromLoc            NVARCHAR(10) = ''
         , @c_FromID             NVARCHAR(18) = ''
         , @c_ToLot              NVARCHAR(10) = ''
         , @n_FromQty            INT          = 0
         , @n_UCCQty             INT          = 0
         , @n_UCC_RowRef         INT          = 0
         , @c_Option5            NVARCHAR(MAX)= ''
         , @c_AllocateUCC        NVARCHAR(10) = ''
         , @CUR_TRFDET           CURSOR

   SET @b_Success= 1
   SET @n_Err    = 0
   SET @c_ErrMsg = ''
   SET @b_Debug = '0'
   SET @n_Continue = 1
   SET @n_StartTCount = @@TRANCOUNT

   SELECT @c_Storerkey = FromStorerkey
        , @c_Facility  = Facility
   FROM TRANSFER (NOLOCK)
   WHERE Transferkey = @c_Transferkey

   SELECT @c_Option5 = Option5 FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey,'','TransferStrategykey')
   SET @c_AllocateUCC = dbo.fnc_GetParamValueFromString('@c_AllocateUCC', @c_Option5, @c_AllocateUCC)

   IF @c_AllocateUCC = 'Y'
   BEGIN
      SET @CUR_TRFDET = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Transferkey, TransferLineNumber, Userdefine05, FromStorerkey, FromSku, FromLot, FromLoc, FromID, FromQty, UCC.Qty, UCC.UCC_RowRef
      FROM TRANSFERDETAIL TD(NOLOCK)
      CROSS APPLY (
         SELECT TOP 1 UCCNo, Storerkey, Sku, Lot, Loc, ID, Qty, UCC_RowRef
         FROM UCC (NOLOCK)
         WHERE UCCNo = TD.Userdefine05 AND Storerkey = TD.FromStorerkey AND Sku = TD.FromSku
           AND Lot = TD.FromLot AND Loc = TD.FromLoc AND ID = TD.FromID AND Status = '1'
      ) UCC
      WHERE TD.Transferkey = @c_Transferkey
        AND TransferLineNumber = CASE WHEN @c_TransferLineNumber<>'' THEN @c_TransferLineNumber ELSE TransferLineNumber END
        AND ISNULL(TD.Userdefine08,'')<>'UpdatedUCC'
        AND TD.Status = '9'
        AND TD.Userdefine05<>''
        AND TD.FromStorerkey = TD.ToStorerkey
        AND TD.FromSku = TD.ToSku
        AND TD.FromLoc = TD.ToLoc
        AND TD.FromID = TD.ToID
        AND TD.FromQty = TD.ToQty

      OPEN @CUR_TRFDET

      WHILE 1=1
      BEGIN
         FETCH NEXT FROM @CUR_TRFDET INTO @c_x_Transferkey, @c_x_TransferLineNo, @c_UCCNo, @c_FromStorerkey, @c_FromSku,
                                          @c_FromLot, @c_FromLoc, @c_FromID, @n_FromQty, @n_UCCQty, @n_UCC_RowRef
         IF @@FETCH_STATUS <> 0
            BREAK

         SET @c_ToLot = ''

         SELECT TOP 1 @c_ToLot = LOT
           FROM ITRN (NOLOCK)
          WHERE StorerKey = @c_FromStorerkey
            AND Sku   = @c_FromSku
            AND ToLoc = @c_FromLoc
            AND ToId  = @c_FromID
            AND SourceKey = @c_x_Transferkey + @c_x_TransferLineNo
            AND TranType = 'DP'
            AND SourceType IN ('ntrTransferDetailAdd', 'ntrTransferDetailUpdate');

         IF @c_ToLot <> '' AND ISNULL(@c_FromLot,'') <> ISNULL(@c_ToLot,'')
         BEGIN
            IF @n_FromQty = @n_UCCQty
            BEGIN
               IF EXISTS(SELECT TOP 1 1
                  FROM UCC (NOLOCK)
                  WHERE UCCNo = @c_UCCNo AND Storerkey = @c_FromStorerkey
                    AND Lot = @c_ToLot AND Loc = @c_FromLoc AND ID = @c_FromID
                    AND Status = '1')
               BEGIN
                  UPDATE TOP (1) UCC WITH(ROWLOCK)
                  SET Qty = Qty + @n_FromQty
                  WHERE UCCNo = @c_UCCNo AND Storerkey = @c_FromStorerkey
                    AND Lot = @c_ToLot AND Loc = @c_FromLoc AND ID = @c_FromID
                    AND Status = '1'

                  DELETE TOP (1) UCC WITH(ROWLOCK)
                  WHERE UCCNo = @c_UCCNo
                    AND Storerkey = @c_FromStorerkey
                    AND UCC_RowRef = @n_UCC_RowRef
                    AND Status = '1'
               END
               ELSE
               BEGIN
                  UPDATE UCC WITH(ROWLOCK)
                  SET Lot = @c_ToLot
                  WHERE UCCNo = @c_UCCNo
                    AND Storerkey = @c_FromStorerkey
                    AND UCC_RowRef = @n_UCC_RowRef
                    AND Status = '1'
               END
            END
            ELSE IF @n_FromQty < @n_UCCQty AND @n_FromQty > 0
            BEGIN
               BEGIN TRAN

               UPDATE UCC WITH(ROWLOCK)
               SET Lot = @c_ToLot
                 , Qty = @n_FromQty
               WHERE UCCNo = @c_UCCNo
                 AND Storerkey = @c_FromStorerkey
                 AND UCC_RowRef = @n_UCC_RowRef
                 AND Status = '1'

               IF EXISTS(SELECT TOP 1 1
                  FROM UCC (NOLOCK)
                  WHERE UCCNo = @c_UCCNo AND Storerkey = @c_FromStorerkey
                    AND Lot = @c_FromLot AND Loc = @c_FromLoc AND ID = @c_FromID
                    AND Status = '1')
               BEGIN
                  UPDATE TOP (1) UCC WITH(ROWLOCK)
                  SET Qty = Qty + @n_UCCQty - @n_FromQty
                  WHERE UCCNo = @c_UCCNo AND Storerkey = @c_FromStorerkey
                    AND Lot = @c_FromLot AND Loc = @c_FromLoc AND ID = @c_FromID
                    AND Status = '1'
               END
               ELSE
               BEGIN
                  INSERT INTO UCC (
                     UCCNo, Storerkey, ExternKey, SKU, Qty, Sourcekey, Sourcetype, Userdefined01, Userdefined02, Userdefined03,
                     Status, Lot, Loc, Id, Receiptkey, ReceiptLineNumber, Orderkey, OrderLineNumber, WaveKey, PickDetailKey,
                     Userdefined04, Userdefined05, Userdefined06, Userdefined07, Userdefined08, Userdefined09, Userdefined10)
                  SELECT UCCNo, Storerkey, ExternKey, SKU, @n_UCCQty - @n_FromQty, Sourcekey, Sourcetype, Userdefined01, Userdefined02, Userdefined03,
                         Status, @c_FromLot, Loc, Id, Receiptkey, ReceiptLineNumber, Orderkey, OrderLineNumber, WaveKey, PickDetailKey,
                         Userdefined04, Userdefined05, Userdefined06, Userdefined07, Userdefined08, Userdefined09, Userdefined10
                  FROM UCC (NOLOCK)
                  WHERE UCCNo = @c_UCCNo
                    AND Storerkey = @c_FromStorerkey
                    AND UCC_RowRef = @n_UCC_RowRef
                    AND Status = '1'
               END

               COMMIT TRAN
            END

            UPDATE TRANSFERDETAIL WITH(ROWLOCK)
            SET Userdefine08 = 'UpdatedUCC'
              , Trafficcop   = NULL
            WHERE Transferkey = @c_x_Transferkey
              AND TRansferLineNumber = @c_x_TransferLineNo
         END
      END
      CLOSE @CUR_TRFDET
      DEALLOCATE @CUR_TRFDET
   END

   QUIT_SP:

   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCount
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCount
         BEGIN
            COMMIT TRAN
         END
      END
      Execute nsp_logerror @n_err, @c_errmsg, 'ispPOTRF06'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCount
      BEGIN
         COMMIT TRAN
      END

      RETURN
   END
END
GO
GRANT EXECUTE ON  [dbo].[ispPOTRF06] TO [NSQL]
GO
