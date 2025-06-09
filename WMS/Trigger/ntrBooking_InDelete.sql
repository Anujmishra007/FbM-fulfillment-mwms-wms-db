SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrBooking_InDelete                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records Deleted                                      */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author     Ver.    Purposes                              */
/* 09-Jun-2025 AYD01      1.1     Fix: Update TMS_Shipment.BookingNo to */
/*                                '0' after deleting Booking            */
/************************************************************************/

CREATE OR ALTER TRIGGER ntrBooking_InDelete
ON  Booking_In
FOR DELETE
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
   @b_Success              int       -- Populated by calls to stored procedures - was the proc successful?
   ,         @n_err        int       -- Error number returned by stored procedure or this trigger
   ,         @n_err2       int       -- For Additional Error Detection
   ,         @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,         @n_continue   int
   ,         @n_starttcnt  int       -- Holds the current transaction count
   ,         @c_preprocess NVARCHAR(250) -- preprocess
   ,         @c_pstprocess NVARCHAR(250) -- post process
   ,         @n_cnt int
   ,         @c_receiptkey NVARCHAR(10)
   ,         @c_containerno NVARCHAR(30)
   ,         @c_Storerkey  NVARCHAR(15)
   ,         @c_Configkey  NVARCHAR(30)
   ,         @c_SValue     NVARCHAR(10)

   ,         @n_BookingNo     INT = 0              --2025-06-09
   ,         @n_RowRef_SHPM   INT = 0              --2025-06-09 
   ,         @c_ShipmentGID   NVARCHAR(50) = ''    --2025-06-09
   ,         @CUR_SHPM        CURSOR               --2025-06-09

   
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   SET @c_Storerkey = ''
   SET @c_Configkey = 'BookSyncContnrTOASN'
   SET @c_SValue    = ''

   IF (SELECT COUNT(*) FROM DELETED) =
   (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END
   
   IF @n_Continue = 1 
   BEGIN
      IF EXISTS (SELECT 1
                 FROM DELETED d
                 WHERE d.Status = '9')
      BEGIN
         SET @n_Continue = 3
         SET @n_err=74905   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)
                      +': Not allow to delete closed booking. (ntrBooking_InDelete)'
         GOTO QUIT_TR
      END
   END

   IF (@n_continue=1 OR @n_continue=2) 
   BEGIN
      SELECT @c_receiptkey = ISNULL(DELETED.Receiptkey,''), 
             @c_containerno = ISNULL(DELETED.ContainerNo,'')
      FROM DELETED
   
      IF @c_receiptkey <> '' AND @c_containerno <> ''
      BEGIN
         SELECT @c_Storerkey = ISNULL(Receipt.Storerkey,'')
         FROM RECEIPT WITH (NOLOCK)
         WHERE Receiptkey = @c_receiptkey

         EXECUTE dbo.nspGetRight NULL                 -- facility
                              ,  @c_Storerkey         -- Storerkey
                              ,  NULL                 -- Sku
                              ,  @c_Configkey         -- Configkey
                              ,  @b_success      OUTPUT
                              ,  @c_SValue       OUTPUT
                              ,  @n_err          OUTPUT
                              ,  @c_errmsg       OUTPUT

         IF @b_success = 0
         BEGIN  
            SET @n_continue = 3 
            SET @n_Err = 74901
            SEt @c_ErrMsg = 'NSQL' +  CONVERT(VARCHAR(255), @n_Err) 
                          + ': Error Getting StorerCongfig for Storer: ' + @c_Storerkey
                          + '. (ntrBooking_InDelete)' 
            GOTO QUIT_TR
         END  

         IF @c_SValue = '1'
         BEGIN
            UPDATE RECEIPT WITH (ROWLOCK)
            SET Containerkey = '',
                TrafficCop = NULL
            WHERE Receiptkey = @c_receiptkey      
            IF @@ERROR <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=74909   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Error on Booking_In. (ntrBooking_InDelete)" + " ( " + " SQLSvr MESSAGE=" + RTrim(ISNULL(@c_errmsg,'')) + " ) "
            END
         END
      END 
   END

   -- Update TMS_Shipment BookingNo to 0 after deleting Booking (AYD01 START)
   SET @CUR_SHPM = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT ts.RowRef
         ,ts.ShipmentGID
   FROM deleted d  
   JOIN dbo.TMS_Shipment AS ts WITH (NOLOCK) ON ts.BookingNo = d.BookingNo 
   ORDER BY d.BookingNo
      
   OPEN @CUR_SHPM
      
   FETCH NEXT FROM @CUR_SHPM INTO @n_RowRef_SHPM
                                 ,@c_ShipmentGID
      
   WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
   BEGIN
             
      UPDATE dbo.TMS_Shipment WITH (ROWLOCK)
      SET BookingNo = 0                      -- (Wan03)
         ,Editwho = SUSER_NAME()
         ,EditDate= GETDATE()
      WHERE Rowref = @n_RowRef_SHPM
            
      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @c_errmsg = CONVERT(CHAR(250),@n_err)
         SET @n_err=74910   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update TMS_Shipment Fail. (ntrBooking_InDelete)'
         GOTO QUIT_TR 
      END
            
      FETCH NEXT FROM @CUR_SHPM INTO @n_RowRef_SHPM
                                    ,@c_ShipmentGID
   END
   CLOSE @CUR_SHPM
   DEALLOCATE @CUR_SHPM 
   -- Update TMS_Shipment BookingNo to 0 after deleting Booking (AYD01 END)
   
   QUIT_TR:
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
      BEGIN
       ROLLBACK TRAN
      END
      ELSE
      BEGIN
       WHILE @@TRANCOUNT > @n_starttcnt
       BEGIN
          COMMIT TRAN
       END
      END
   
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrBooking_InDelete"
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
       COMMIT TRAN
      END
      RETURN
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

