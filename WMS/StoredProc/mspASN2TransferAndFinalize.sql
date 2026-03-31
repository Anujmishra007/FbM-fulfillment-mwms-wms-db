
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: mspASN2TransferAndFinalize                            */
/* Creation Date: 03-FEB-2026                                              */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: UWP-49057 - Enable Customs Import Declaration for HP Operations*/
/*                                        – Transfer flow                  */
/*                      (Create and finalize transfer from ASN)            */
/*                                                                         */
/* Called By:                                                              */
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
/* 03-FEB-2026  SSA01   1.0  Initial development for UWP-49057             */
/***************************************************************************/  
CREATE OR ALTER PROC [dbo].[mspASN2TransferAndFinalize]
(     @c_Receiptkey  NVARCHAR(10)   
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @c_Transferkey NVARCHAR(10),
           @n_Count INT = 1,
           @n_Continue INT,
           @n_StartTranCount INT


   SELECT @b_Success=1, @n_Err=0, @c_ErrMsg='', @n_Continue = 1, @n_StartTranCount=@@TRANCOUNT
    IF @@TRANCOUNT = 0
      BEGIN TRAN
   -- Create temp table once
    IF OBJECT_ID('tempdb..#ReceiptData') IS NOT NULL DROP TABLE #ReceiptData;

    CREATE TABLE #ReceiptData (
        ReceiptLineNumber NVARCHAR(5),
        ContainerKey NVARCHAR(18),
        Storerkey NVARCHAR(15),
        Sku NVARCHAR(20),
        Loc NVARCHAR(10),
        Lot NVARCHAR(10),
        ID NVARCHAR(18),
        Qty INT,
        Packkey NVARCHAR(10),
        UOM NVARCHAR(10),
        Facility NVARCHAR(5),
        ExternReceiptkey NVARCHAR(20),
        TrackingNo NVARCHAR(30),
        Lottable05 datetime
    )

    -- Populate temp table
    INSERT INTO #ReceiptData
    SELECT RD.ReceiptLineNumber,
           R.ContainerKey,
           R.Storerkey,
           RD.Sku,
           RD.ToLoc,
           L.LOT,
           RD.ToID,
           RD.QtyReceived,
           RD.Packkey,
           RD.UOM,
           R.Facility,
           R.ExternReceiptkey,
           R.TrackingNo,
           RD.Lottable05
    FROM RECEIPT R (NOLOCK)
    JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey
    JOIN LOTXLOCXID L (NOLOCK) ON L.Sku = RD.Sku AND L.Loc = RD.ToLoc AND L.ID = RD.ToID
    LEFT JOIN TRANSFERDETAIL TD (NOLOCK) ON TD.LOTTABLE03 = R.ExternReceiptkey
    WHERE RD.Receiptkey = @c_Receiptkey
    AND L.Qty - L.QtyAllocated - L.QtyPicked > 0
    AND TD.LOTTABLE03 IS NULL
    BEGIN TRY

    IF EXISTS (SELECT 1 FROM #ReceiptData)
    BEGIN
      WHILE(@n_Count <= 2)
      BEGIN
        IF @n_Continue = 1 OR @n_Continue = 2
        BEGIN
          SELECT @b_success = 0
                     EXECUTE nspg_getkey
                     'TRANSFER'
                     , 10
                     , @c_TransferKey OUTPUT
                     , @b_success OUTPUT
                     , @n_err OUTPUT
                     , @c_errmsg OUTPUT
             IF @b_success = 1
             BEGIN
            -- Insert into TRANSFER (one row per transfer)
            INSERT INTO TRANSFER (Transferkey, FromStorerkey, ToStorerkey, Type, ReasonCode,
                   CustomerRefNo, Remarks,
                   Facility, ToFacility)
            SELECT TOP 1
                @c_TransferKey,
                Storerkey,
                Storerkey,
                'CUS',
                'T1T2',
                CASE
                WHEN @n_Count = 1 THEN ''
                ELSE TrackingNo
                END AS CustomerRefNo,
                ContainerKey,
                Facility,
                Facility
               FROM #ReceiptData

            SELECT @n_err = @@ERROR
                  IF  @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63506
                     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+'ReceiptKey :'+@c_Receiptkey+': Insert TRANSFER Failed! (mspASN2TransferAndFinalize)' + ' ( '
                                            + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
                     GOTO QUIT_SP
                  END

            -- Insert into TRANSFERDETAIL (one row per receipt line)
            INSERT INTO TRANSFERDETAIL (
                Transferkey, TransferLineNumber, FromStorerkey,ToStorerKey,FromSku,FromLot, FromLoc, FromID, FromQty, FromPackkey, FromUOM,
                ToLoc, ToId, ToLot, ToSku, ToQty, LOTTABLE03, LOTTABLE10, TOLOTTABLE10, TOLOTTABLE12,ToPackkey,ToUOM,tolottable03,Lottable12,
                LOTTABLE05,tolottable05
            )
            SELECT
                @c_TransferKey,
                RIGHT('0000' + RTRIM(CAST(ROW_NUMBER() OVER (ORDER BY RD.ReceiptLineNumber) AS NVARCHAR(5))), 5),
                RD.Storerkey,
                RD.Storerkey,
                RD.Sku,
                CASE
                WHEN @n_Count = 1 THEN RD.Lot
                ELSE (SELECT TOP 1 LOT FROM LOTXLOCXID L (NOLOCK)
                WHERE L.Sku = RD.Sku AND L.Loc = RD.Loc AND L.ID = RD.ID
                AND L.Qty - L.QtyAllocated - L.QtyPicked > 0)
                END AS Lot,
                RD. Loc,
                RD. ID,
                RD.Qty,
                RD.Packkey,
                RD.UOM,
                RD.Loc,
                RD.ID,
                '',
                RD.Sku,
                RD.Qty,
                RD.ExternReceiptkey,
                CASE
                WHEN @n_Count = 1 THEN 'T1-TEMP'
                ELSE 'T2-TEMP'
                END AS LOTTABLE10,
                CASE
                WHEN @n_Count = 1 THEN 'T2-TEMP'
                ELSE 'T2-ENT'
                END AS TOLOTTABLE10,
                RD.TrackingNo,
                RD.Packkey,
                RD.UOM,
                RD.ExternReceiptkey,
                RD.TrackingNo,
                RD.Lottable05,
                RD.Lottable05
            FROM #ReceiptData RD
            SELECT @n_err = @@ERROR
                  IF  @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63507
                     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+'ReceiptKey :'+@c_Receiptkey+': Insert TRANSFER DETAIL Failed! (mspASN2TransferAndFinalize)' + ' ( '
                                            + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
                     GOTO QUIT_SP
                  END
            END
            ELSE
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63508
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+'ReceiptKey :'+@c_Receiptkey+': Get Transfer Key Failed! (mspASN2TransferAndFinalize)' + ' ( '
                                      + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
               GOTO QUIT_SP
            END

           IF @n_Continue IN (1,2) AND ISNULL(@c_Transferkey,'') <> ''
           BEGIN

              EXEC ispFinalizeTransfer @c_Transferkey, @b_Success OUTPUT, @n_err OUTPUT, @c_errmsg OUTPUT
              IF @b_Success <> 1
             BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 63508
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+'ReceiptKey :'+@c_Receiptkey+': Finalize Transfer Failed! (mspASN2TransferAndFinalize)' + ' ( '
                                      + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
                GOTO QUIT_SP
              END
           END
           SET @n_Count = @n_Count + 1
         END
       END
     END
     END TRY
     BEGIN CATCH
        IF @n_err = 0
        BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = ERROR_MESSAGE(), @n_err = ERROR_NUMBER()
           SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+'ReceiptKey :'+@c_Receiptkey+': Unexpected Error Occured! (mspASN2TransferAndFinalize)' + ' ( '
                                  + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
           GOTO QUIT_SP
        END
     END CATCH
  
   QUIT_SP:
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0
      IF @@TRANCOUNT > 0 and @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspASN2TransferAndFinalize'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCount  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN
   END 
END
GO

GRANT EXECUTE ON [dbo].[mspASN2TransferAndFinalize] TO nSQL
GO
